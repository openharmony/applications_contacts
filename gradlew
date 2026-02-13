#!/bin/bash
#
# Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -ex

echo "old NODE_HOME is ${NODE_HOME}"

# NODE_HOME的环境变量多配置了一个bin目录, 在这里去除掉
[[ "${NODE_HOME}" =~ .*\bin$ ]] && NODE_HOME=${NODE_HOME%\bin*}
echo "new NODE_HOME is ${NODE_HOME}"
echo "HM_SDK_HOME is ${HM_SDK_HOME}"
echo "OHOS_SDK_HOME is ${OHOS_SDK_HOME}"
echo "OHOS_BASE_SDK_HOME is ${OHOS_BASE_SDK_HOME}"
node -v
npm -v

# 初始化相关路径
PROJECT_PATH="`pwd -P`"  # 工程目录
TOOLS_INSTALL_DIR="`pwd -P`"  # commandline-tools安装目录，流水线下载命令行工具的安装路径

# Setup npm
npm config set registry
npm config set @ohos:registry 
npm config set strict-ssl false
#npm config set sslVerify false

# 安装ohpm, 若镜像中已存在ohpm，则无需重新安装
function init_ohpm {
    # 下载
    cd ${TOOLS_INSTALL_DIR}
    commandlineVersion=2.0.1.0
    ohpmVersion=1.7.1
    OHPM_HOME=${TOOLS_INSTALL_DIR}/ohpm-${ohpmVersion}
    mkdir -p ${OHPM_HOME}
    wget --no-check-certificate -q "/artifactory/cmc-software-release/DevEco%20Developer%20Suite/deveco-studio-command-line-tools/${commandlineVersion}/ohcommandline-tools-linux-${commandlineVersion}.zip?_t=$(date +%s)" -O ohcommandline-tools-linux.zip
    unzip -oq ohcommandline-tools-linux.zip

    # 安装ohpm
    cd ${OHPM_HOME}
    wget --no-check-certificate -q "/artifactory/sz-software-release/devecomanagercloud/release/PackageManagerCLI/${ohpmVersion}/ohpm.zip"
    unzip -oq ohpm.zip
    export PATH=${OHPM_HOME}/bin:${PATH}
    ohpm -v

    # 配置仓库地址
    ohpm config set registry /artifactory/api/ohpm/product_ohpm/,/artifactory/api/npm/product_npm/,/npm/,/ohpm/
    ohpm config set /artifactory/api/ohpm/product_ohpm/:_read_auth ""
    ohpm config set strict_ssl false
}

function ohpm_install {
    cd  $1
    ohpm install
}

# 环境适配
function build {
    # 根据业务情况适配local.properties
    cd ${PROJECT_PATH}
    echo "sdk.dir=${HM_SDK_HOME}"  > ./local.properties
    echo "nodejs.dir=${NODE_HOME}" >> ./local.properties

	# 根据业务情况安装ohpm三方库依赖,
    ohpm_install "${PROJECT_PATH}"
    ohpm_install "${PROJECT_PATH}/entry"
    ohpm_install "${PROJECT_PATH}/common"
    ohpm_install "${PROJECT_PATH}/feature/contact"
    ohpm_install "${PROJECT_PATH}/feature/call"
    ohpm_install "${PROJECT_PATH}/feature/phonenumber"
    ohpm_install "${PROJECT_PATH}/feature/account"
    ohpm_install "${PROJECT_PATH}/feature/dialpad"

   # 如果构建过程报错 ERR_PNPM_OUTDATED_LOCKFILE，需要增加配置：lockfile=false
    cat ${HOME}/.npmrc | grep 'lockfile=false' || echo 'lockfile=false' >> ${HOME}/.npmrc

    # 获得签名jar文件
    cd $PROJECT_PATH/sign
    chmod +x build.sh
    ./build.sh

    # 根据业务情况，采用对应的构建命令，可以参考IDE构建日志中的命令
    cd ${PROJECT_PATH}
    chmod +x hvigorw
    ./hvigorw clean --no-daemon
    ./hvigorw assembleHap --mode module -p product=default -p debuggable=false -p ohos-test-coverage=true --no-daemon
    ./hvigorw --mode module -p module=entry@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon --stacktrace
    ./hvigorw assembleHap --mode module -p product=default -p debuggable=false
    echo "-----------------handle DTPipeline.zip--------------------"
    hasPackageDTPipeline=0
    if [ -e "build/DTPipeline.zip" ];then
      file_size=$(stat -c%s "build/DTPipeline.zip")
      if [ $file_size -gt 0 ]; then
        echo "DTPipeline.zip is normal"
      else
        hasPackageDTPipeline=1
        rm -rf build/DTPipeline.zip
        echo "DTPipeline.zip size is 0"
      fi
    else
      hasPackageDTPipeline=1
      echo "build/DTPipeline.zip is not exist"
    fi
    if [ $hasPackageDTPipeline -eq 1 ];then
      pushd build/outputs
      if [ $? -ne 0 ];then
             echo "build/outputs is not exist"
             exit 1
      fi
      zip -r ../DTPipeline.zip ./*
      popd
    fi
}

function main {
  local startTime=$(date '+%s')

  init_ohpm
  build

  local endTime=$(date '+%s')
  local elapsedTime=$(expr $endTime - $startTime)
  echo "build success in ${elapsedTime}s..."
}

main