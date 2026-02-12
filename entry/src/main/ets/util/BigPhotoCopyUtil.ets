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
import { HiLog, ObjectUtil, sharedPreferencesUtils } from '../../../../../common';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { ContactRepository, Contacts } from '../../../../../feature/contact';
import fs from '@ohos.file.fs';
import GroupIdUtil from './GroupIdUtil';
import { saveImageFileInfoToRdb } from '../util/UserPhoto';
import { systemDateTime } from '@kit.BasicServicesKit';

const TAG = 'BigPhotoCopyUtil';

export default class BigPhotoCopyUtil {
  private static instance: BigPhotoCopyUtil;
  public resultDT: boolean = true;

  public static getInstance(): BigPhotoCopyUtil {
    if (!BigPhotoCopyUtil.instance) {
      BigPhotoCopyUtil.instance = new BigPhotoCopyUtil();
    }
    return BigPhotoCopyUtil.instance;
  }

  // 将联系人大头像文件拷贝至群组沙箱下
  async copyPhotoFile() {
    HiLog.w(TAG, 'bigPhotoFromFile copyPhotoFile coming');
    try {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('bigPhotoFileCopy', {}, (result: string) => {
          HiLog.w(TAG, `bigPhotoFromFile copyPhotoFile result: ${result}`);
        });
    } catch (error) {
      HiLog.e(TAG, `bigPhotoFromFile copyPhotoFile error: ${error?.message}`);
      return;
    }
  }

  async bigPhotoFileCopy(callback: Function) {
    HiLog.w(TAG, 'bigPhotoFromFile bigPhotoFileCopy coming');
    try {
      let ctx = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      // 群组沙箱路径 + /photo
      let groupDir = await GroupIdUtil.getInstance().getGroupDir(ctx.getApplicationContext());
      // 1.首先获取首选项中的标记位，判断是否需要做拷贝操作
      sharedPreferencesUtils.init(ctx);
      let num: number = await sharedPreferencesUtils.getFromPreferences('bigPhotoFileCopyFlag', 2) as number;
      // 当num为1时，表示需要首次拷贝文件
      if (num === 2) {
        // 防重入，进入判断后将首选项设置为临时值1
        await sharedPreferencesUtils.saveToPreferences('bigPhotoFileCopyFlag', 1);
        let groupFileDir = groupDir + '/photo';
        let resGroupFileDir = await fs.access(groupFileDir);
        if (!resGroupFileDir) {
          await fs.mkdir(groupFileDir);
        }
        // 联系人应用沙箱路径 + /photo
        let appSandBoxFileDir = ctx.getApplicationContext().filesDir + '/photo';
        let resAppSandBoxFileDir = await fs.access(appSandBoxFileDir);
        // 当前存在 联系人沙箱目录 + /photo 文件夹时，才进行拷贝
        if (!resAppSandBoxFileDir) {
          callback?.('bigPhotoFileCopy appSandBoxFileDir not exist');
        } else {
          // 打印耗时
          let startTime = systemDateTime.getTime(false);
          // 然后再单独执行一下联系人大头像文件的判断，将信息存入数据库中
          let contactIds: string[] = await this.queryContactDataInfo();
          if (contactIds && contactIds.length > 0) {
            for (let id of contactIds) {
              // 根据contactId获取rawContactIds
              let rawContactIdList = await ContactRepository.getInstance().getRawContactIdsByContactId(id);
              for (let rawContactId of rawContactIdList) {
                let groupFilePath = groupFileDir + '/' + id + '_' + rawContactId;
                let resGroupFilePath = await fs.access(groupFilePath);
                let appSandBoxFilePath = appSandBoxFileDir + '/' + id;
                let resAppSandBoxFilePath = await fs.access(appSandBoxFilePath);
                if (!resGroupFilePath && resAppSandBoxFilePath) {
                  // 如果群组沙箱不存在此id的文件，而原来的联系人应用沙箱存在此id的文件，才做迁移
                  await fs.copyFile(appSandBoxFilePath, groupFilePath);
                  // 将fileName存储至contact_data表中，用于后续获取大头像文件使用
                  saveImageFileInfoToRdb(groupFilePath, id, [rawContactId]);
                }
              }
            }
            callback?.('bigPhotoFileCopy copy finish');
          } else {
            callback?.('bigPhotoFileCopy rawContactIds is null');
          }
          let endTime = systemDateTime.getTime(false);
          let timeRequired = endTime - startTime;
          HiLog.w(TAG, `bigPhotoFromFile bigPhotoFileCopy take times: ${timeRequired.toString()}ms`);
        }
        // 将首选项中的标记位置为0，之后不再触发文件拷贝操作
        await sharedPreferencesUtils.saveToPreferences('bigPhotoFileCopyFlag', 0);
      } else {
        callback?.('bigPhotoFileCopy bigPhotoFileCopyFlag is 0');
      }
    } catch (error) {
      HiLog.e(TAG, `bigPhotoFromFile bigPhotoFileCopy error: ${error?.message}`);
      await sharedPreferencesUtils.saveToPreferences('bigPhotoFileCopyFlag', 2);
      callback?.(`bigPhotoFileCopy error: ${error?.message}`);
    }
  }

  // 查询contact_data表type_id为8的所有raw_contact_id
  async queryContactDataInfo() {
    let contactIds: string[] = [];

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance()
          .init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext())
          .getDataAbilityHelper();
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.orderByAsc('id');
      resultSet = await daHelper.query(Contacts.CONTACT_URI, predicates, ['id']);
      if (resultSet && resultSet.goToFirstRow()) {
        do {
          let contactId = resultSet.getString(resultSet.getColumnIndex('id'));
          if (contactId != null && contactId != undefined && contactId != '') {
            contactIds.push(contactId);
          }
        } while (resultSet.goToNextRow());
      }
      HiLog.w(TAG, `bigPhotoFromFile queryContactDataInfo contactIds: ${contactIds.toString()}`);
      return contactIds;
    } catch (error) {
      HiLog.e(TAG, `bigPhotoFromFile queryContactDataInfo error: ${error?.message}`);
      return contactIds;
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }
}