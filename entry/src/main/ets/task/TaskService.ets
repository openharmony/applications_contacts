/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { HiLog, sharedPreferencesUtils, ObjectUtil } from '../../../../../common';
import HashMap from '@ohos.util.HashMap';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { RawContacts } from '../../../../../feature/contact';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import common from '@ohos.app.ability.common';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { JSON } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { AuditLogUtils } from '../../../../../common/src/main/ets/util/AuditLogUtils';
import { ContactRepository } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import ContactListActItem from '../../../../../feature/contact/src/main/ets/repo/ContactListActItem'
import {
  UtilAuditLog,
  generateKey1,
  generateKey2
} from '../../../../../common/src/main/ets/util/AuditLogUtils'


/**
 * 通过调用url 合并重复联系人
 * @param context
 * @param autoMergeStatus
 */
export function mergeDuplicateContactsByUrl(context: common.UIAbilityContext) {
  HiLog.w('mergeDuplicateContactsByUrl', 'notifyMergeContact start');
  const MERGE_CONTACT_URL = 'datashare:///com.ohos.contactsdataability/contacts/merge_contact';
  let va: ValuesBucket = {'': null};

  dataShare.createDataShareHelper(context, MERGE_CONTACT_URL).then((dataShareHelper: dataShare.DataShareHelper) => {
    let predicate: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicate.equalTo('id', 1);
    dataShareHelper?.update(MERGE_CONTACT_URL, predicate, va).then((ret) => {
      sharedPreferencesUtils.saveToPreferences('autoMergeTime', new Date().getTime());
      HiLog.w('mergeDuplicateContactsByUrl', 'notifyMergeContact update succeed:' + ret);
    }).catch((error: BusinessError) => {
      HiLog.e('mergeDuplicateContactsByUrl', 'notifyMergeContact update error:' + error.message);
    })
  }).catch((error: BusinessError) => {
    HiLog.e('mergeDuplicateContactsByUrl', 'notifyMergeContact createDataShareHelper error:' + error.message);
  })
}

/**
 * 通过调用url 手动合并重复联系人
 * @param context
 * @param autoMergeStatus
 */
export function manualMergeDuplicateContactsByUrl(
  repeatContactIds: string[][], context: common.UIAbilityContext, callback: () => void) {
  HiLog.w('manualMergeDuplicateContactsByUrl', `notifyMergeContact start. repeatContactIds size: ${repeatContactIds?.length}`);
  const MERGE_CONTACT_URL = 'datashare:///com.ohos.contactsdataability/contacts/merge_contact';
  let va: ValuesBucket = { 'manualMergeIdStr': JSON.stringify(repeatContactIds) };

  dataShare.createDataShareHelper(context, MERGE_CONTACT_URL).then((dataShareHelper: dataShare.DataShareHelper) => {
    let predicate: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicate.equalTo('manualMergeIdStr', JSON.stringify(repeatContactIds));
    predicate.orderByAsc(JSON.stringify(repeatContactIds));

    dataShareHelper?.update(MERGE_CONTACT_URL, predicate, va).then((ret) => {
      callback();
      HiLog.w('manualMergeDuplicateContactsByUrl', 'notifyMergeContact update succeed:' + ret);
    }).catch((error: BusinessError) => {
      HiLog.e('manualMergeDuplicateContactsByUrl', 'notifyMergeContact update error:' + error.message);
    })
  }).catch((error: BusinessError) => {
    HiLog.e('manualMergeDuplicateContactsByUrl', 'notifyMergeContact createDataShareHelper error:' + error.message);
  })
}

@Concurrent
export async function queryRepeatContacts(context: common.UIAbilityContext): Promise<number> {
  return new Promise(async (resolve, reject) => {
    HiLog.w('queryRepeatContacts', 'Start to query repeat contacts ');
    let repeatNum: number = 0;
    let uniqueKeyCount: HashMap<string, Set<number>> = new HashMap();
    // 查询 UNIQUE_KEY 不为空的联系人
    dataShare.createDataShareHelper(context, RawContacts.CONTENT_URI)
      .then((dataAbilityHelper: dataShare.DataShareHelper) => {
        let condition = new dataSharePredicates.DataSharePredicates();
        condition
          .notEqualTo(RawContacts.UNIQUE_KEY, '')
          .and()
          .isNotNull(RawContacts.UNIQUE_KEY)
          .and()
          .equalTo(RawContacts.IS_DELETED, 0)
          .and()
          .notEqualTo(RawContacts.MARK_MY_CARD, 1)
          .groupBy([RawContacts.UNIQUE_KEY])
        let resultColumns = [RawContacts.UNIQUE_KEY, 'COUNT(DISTINCT ' + RawContacts.CONTACT_ID + ') as count'];

        dataAbilityHelper.query(RawContacts.CONTENT_URI, condition, resultColumns)
          .then((resultSet: DataShareResultSet) => {
            try {
              if (resultSet == undefined || !resultSet.goToFirstRow()) {
                HiLog.w('queryRepeatContacts', 'not repeat contacts.');
              } else {
                HiLog.w('queryRepeatContacts', `resultSet.rowCount: ${resultSet.rowCount}`);
                resultSet.goToFirstRow();
                let contactIdSum: number = 0;
                do {
                  contactIdSum += resultSet.getLong(resultSet.getColumnIndex('count'));
                } while (resultSet.goToNextRow());
                repeatNum = contactIdSum - resultSet.rowCount;
              }
              HiLog.w('queryRepeatContacts', `queryRepeatContacts is succeed! repeatNum: ${repeatNum}`);
              resolve(repeatNum);
            } finally {
              ObjectUtil.closeResultSet(resultSet);
            }
          }).catch((error: BusinessError) => {
          HiLog.e('queryRepeatContacts', 'queryRepeatContacts query error:' + error.message);
          resolve(repeatNum);
        }).finally(() => {
          dataAbilityHelper.close();
        })
      }).catch((error: BusinessError) => {
      HiLog.e('queryRepeatContacts', 'queryRepeatContacts createDataShareHelper error:' + error.message);
      resolve(repeatNum);
    })
  })
}

/**
 * 通过调用url 重建索引数据
 * @param context
 * @param autoMergeStatus
 */
export function rebuildContactSearchIndex(context: common.UIAbilityContext, callback: (result: number) => void) {
  HiLog.w('rebuildContactSearchIndex', 'notifyRebuildContact start');
  const REBUILD_CONTACT_URL = 'datashare:///com.ohos.contactsdataability/contacts/rebuild_contact_search_index';
  let va: ValuesBucket = { '': null };
  let result: number = -1;
  dataShare.createDataShareHelper(context, REBUILD_CONTACT_URL).then((dataShareHelper: dataShare.DataShareHelper) => {
    let predicate: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicate.equalTo('id', 1);
    return dataShareHelper?.update(REBUILD_CONTACT_URL, predicate, va);
  }).then((ret) => {
      HiLog.w('rebuildContactSearchIndex', 'notifyRebuildContact update succeed:' + ret);
      result = ret;
      callback(result);
    }).catch((error: BusinessError) => {
      HiLog.e('rebuildContactSearchIndex', 'notifyRebuildContact update error: ' + error.message);
      result = error.code;
      callback(result);
    }).finally(() => {
      // 这里不执行任何操作，因为回调已经在 then/catch 中调用,确保 callback 只会被调用一次
    });
}

@Concurrent
export async function backupAllLogs(context?: Context) {
  HiLog.i('TaskService', 'backupAllLogs started');
  let logUtils: AuditLogUtils = AuditLogUtils.getInstance();
  ContactRepository.getInstance().init(context);
  let contactList: ContactListActItem[] = await ContactRepository.getInstance().queryAllContactInfo();

  await Promise.all(contactList.map(async (contactItem, index: number) => {
    let key1 = '';
    if (contactItem.name) {
      key1 = await generateKey1(contactItem.name);
    }
    let key2Array: string[] = [];
    await Promise.all(contactItem.phone.map(async (simPhoneNumber, index: number) => {
      if (simPhoneNumber !== contactItem.name) {
        key2Array.push(await generateKey2(contactItem.name, simPhoneNumber));
      }
    }))
    let key2 = key2Array.join('|');

    let otherInfo: number = contactItem.getOtherInfo();

    let utilAuditLog: UtilAuditLog = new UtilAuditLog();

    utilAuditLog.happenTime = AuditLogUtils.getFormatTime();
    utilAuditLog.packageName = 'com.ohos.contacts';
    utilAuditLog.isForeground = false;
    utilAuditLog.isUserBehavior = false;
    utilAuditLog.key1 = key1;
    utilAuditLog.key2 = key2;
    utilAuditLog.contactId = contactItem.rawContactId;
    utilAuditLog.otherInfo = otherInfo.toString();
    utilAuditLog.operationScenario = 'Full log backup';
    logUtils.writeAuditEvent(utilAuditLog);
  }));

}