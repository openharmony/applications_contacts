/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// @ts-ignore
import type { HvigorPlugin, HvigorPluginTask, HvigorTaskContext } from '@ohos/hvigor';

declare const require: any;

const path = require('path');
const fs = require('fs');
/**
 * 编写插件逻辑。插件运行时，可以获取到 `moduleName` 和 `path`，
 * 根据 `path` 拼接出打包前的 `module.json` 文件路径。然后，根据 JSON 格式操作文件并更新它。
 * - `moduleName`: 模块名称，示例值为 `sharelibrary`
 * - `modulePath`: 模块路径，示例值为 `D:\PJT\AppShareProvider\sharelibrary`
 *
 * 插件主要实现了在插件生命周期中，根据目标平台生成模块的共享信息，并更新 `module.json` 文件中的依赖信息。
 */
export function sharePlugin(): HvigorPlugin {
  return {
    //必须的配置，插件的id
    pluginId: 'sharePluginId',
    //必须的配置，hvigor生命周期中调用这个函数方法
    apply(pluginContext: HvigorPluginTask): void {
      const hapContext = pluginContext.getContext('com.ohos.hap');
      hapContext.targets(target => {
        const targetName = target.getTargetName();
        // 注册任务
        pluginContext.registerTask({
          // 任务名称
          name: `${targetName}sharePluginTask`,
          // 任务执行体
          run: (taskContext: HvigorTaskContext) => {
            updateModuleConfig(taskContext.moduleName, taskContext.modulePath, target);
          },
          // 任务前置依赖，先执行default@CompileArkTS，再执行sharePluginTask
          dependencies: [`${targetName}@CompileArkTS`],
          // 任务后置依赖，先执行sharePluginTask，再执行default@PackageHsp
          postDependencies: [`${targetName}@PackageHap`]
        });
      });

    }
  };
}

/**
 * 更新模块的共享配置信息
 * @param moduleName 模块名称
 * @param modulePath 模块路径
 * @param targetName 目标平台名称
 */
function updateModuleConfig(moduleName, modulePath, target): void {
  let sharedInfos = getSharedInfos(modulePath);
  updateSharedInfo(modulePath, sharedInfos, target);
}

/**
 * 获取模块共享信息
 * @param modulePath 模块路径
 * @returns 返回包含共享模块信息的数组
 */
function getSharedInfos(modulePath): Array<object> {
  let sharedInfos = [];
  // 本地包总目录
  let moduleFilePath = path.resolve(modulePath, 'oh_modules', '@hw-hmos');
  const moduleFileNames = fs.readdirSync(moduleFilePath);
  moduleFileNames.forEach((moduleFileName) => {
    if (moduleFileName && !moduleFileName.startsWith('.')) {
      if (moduleFileName.startsWith('@')) {
        // 远程仓库或本地应用内共享库
        let cloudModuleFilePath = path.resolve(modulePath, `oh_modules/${moduleFileName}`);
        const cloudModuleFileNames = fs.readdirSync(cloudModuleFilePath);
        cloudModuleFileNames.forEach((cloudModuleFileName) => {
          let srcPath = path.resolve(cloudModuleFilePath, `${cloudModuleFileName}/src/main/module.json`);
          if (!checkFileExists(srcPath)) {
            srcPath = path.resolve(cloudModuleFilePath, `${cloudModuleFileName}/src/main/module.json5`);
          }
          if (checkFileExists(srcPath)) {
            let srcData = fs.readFileSync(srcPath);
            let srcModuleJson = JSON.parse(srcData);
            let srcBundleName = srcModuleJson?.app?.bundleName ?? '';
            let srcVersionCode = srcModuleJson?.app?.versionCode ?? 0;
            let srcModuleName = srcModuleJson?.module?.name ?? '';
            let srcModuleType = srcModuleJson?.module?.type ?? '';
            if (srcModuleType === 'shared' && srcBundleName && srcVersionCode !== 0 && srcModuleName) {
              let shareInfo = {
                'bundleName': srcBundleName,
                'moduleName': srcModuleName,
                'versionCode': srcVersionCode
              };
              sharedInfos.push(shareInfo);
            } else if (srcModuleType === 'shared' && !srcBundleName && srcVersionCode === 0 && srcModuleName) {
              let shareInfo = {
                'moduleName': srcModuleName,
              };
              sharedInfos.push(shareInfo);
            }
          }
        });
      } else {
        // 本地仓库
        let srcPath = path.resolve(moduleFilePath, `${moduleFileName}/src/main/module.json`);
        if (checkFileExists(srcPath)) {
          let srcData = fs.readFileSync(srcPath);
          let srcModuleJson = JSON.parse(srcData);
          let srcBundleName = srcModuleJson?.app?.bundleName ?? '';
          let srcVersionCode = srcModuleJson?.app?.versionCode ?? 0;
          let srcModuleName = srcModuleJson?.module?.name ?? '';
          let srcModuleType = srcModuleJson?.module?.type ?? '';
          if (srcModuleType === 'shared' && srcBundleName && srcVersionCode !== 0 && srcModuleName) {
            let shareInfo = {
              'bundleName': srcBundleName,
              'moduleName': srcModuleName,
              'versionCode': srcVersionCode
            };
            sharedInfos.push(shareInfo);
          }
        }
      }
    }
  });
  return sharedInfos;
}

/**
 * 更新共享信息到模块的配置文件
 * @param modulePath 模块路径
 * @param dependenciesSrc 共享信息
 * @param targetName 目标平台名称
 */
function updateSharedInfo(modulePath, dependenciesSrc, target): void {
  let buildFilePath = path.resolve(target.getBuildTargetOutputPath(), '../../');
  const targetName = target.getTargetName();

  if (checkFileExists(buildFilePath)) {
    if (targetName) {
      let filePath = path.resolve(buildFilePath, `intermediates/res/${targetName}/module.json`);
      let rawData = fs.readFileSync(filePath);
      let moduleJson = JSON.parse(rawData);
      moduleJson.module.dependencies = dependenciesSrc;
      let data = JSON.stringify(moduleJson, null, 2);
      fs.writeFileSync(filePath, data);
    }
  }
}

/**
 * 检查文件是否存在
 * @param filePath 文件路径
 * @returns 如果文件存在则返回 `true`，否则返回 `false`
 */
function checkFileExists(filePath: string): boolean {
  try {
    fs.accessSync(filePath, fs.constants.F_OK);
    return true;
  } catch (err) {
    return false;
  }
}