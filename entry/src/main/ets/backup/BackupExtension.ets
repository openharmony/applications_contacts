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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { ObjectUtil } from '../../../../../common/src/main/ets/util/ObjectUtil';
import {
  dataShare, dataSharePredicates, DataShareResultSet, preferences, ValuesBucket
} from '@kit.ArkData';
import { BackupExtensionAbility, BackupExtensionContext, BundleVersion } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import ArrangeContactsPresenter from '../presenter/contact/settings/ArrangeContactsPresenter';
import fs from '@ohos.file.fs';
import { convertxml } from '@kit.ArkTS';
import { contextConstant } from '@kit.AbilityKit';
import data_preferences from '@ohos.data.preferences';
import { relationalStore } from '@kit.ArkData';
import { StringUtil } from '../../../../../feature/call/oh_modules/common';

const TAG = 'BackupExtension';

let store: relationalStore.RdbStore | undefined = undefined;

interface _attributes {
  key: string;
  name: string;
  value?: string;
}

interface _elements {
  _text: string;
}

interface _text {
  _text: string;
}

interface PreferenceElement {
  _type: string;
  _name: string;
  _attributes: _attributes;
  _elements?: Array<_text>;
}

interface _elements2 {
  _elements: PreferenceElement[];
}

interface PreferencesRoot {
  _elements: Array<_elements2>;
}

interface SpeedObj {
  index: string;
  item: SpeedDialItem;
}

interface SpeedDialItem {
  number?: number,
  contactName?: string,
  contactTelephone: string,
  portraitColor?: ResourceStr,
  nameSuffix?: string,
  namePrefix?: string,
  portraitPath?: string,
  contactId?: string
}

export default class BackupExtension extends BackupExtensionAbility {
  public UPDATE_URI = 'datashare:///com.ohos.downloadfileability';
  public VIEW_CONTACT_DATA_URI = 'datashare:///com.ohos.contactsdataability/contacts/contact_data';
  public VIEW_RAW_CONTACT_URI = 'datashare:///com.ohos.contactsdataability/contacts/raw_contact';
  public DOUBLE_LOCAL_DATABASE_PATH_CONTACTS_DB = '/data/storage/el2/database/contactsdata/rdb/contacts2_double.db';
  public arrangeContactsPresenter = ArrangeContactsPresenter.getInstance();
  private sourcePath: string = '/data/storage/el1/base/haps/entry/preferences/CONTACT_PREFERENCE';
  private targetPath: string = '/data/storage/el1/base/haps/entry/preferences/CONTACT_PREFERENCE.bk';
  private static readonly TEMPORARILY_COPIED_FILE_TIMEOUT_MS = 1000 * 60;
  private speedDialMap: Record<number, number> = {};
  private hasChinese: RegExp = new RegExp('[\\u4E00-\\u9FA5]');
  private hasEnglish: RegExp = new RegExp('[a-zA-Z]');

  async onBackup() {
    HiLog.i(TAG, `onBackup init`);
    await this.updateSharePreference();
    const result = await this.copyContactPreferences();
    if (result !== 0) {
      HiLog.e(TAG, `Backup failed with code: ${result} -1 sourcepath not found;  -2 else`);
    }
  }

  //创建首先项文件备份，克隆传递备份文件
  async copyContactPreferences(): Promise<number> {
    try {
      const isExist = fs.accessSync(this.sourcePath);
      const backExist = fs.accessSync(this.targetPath);
      if (backExist) {
        await fs.unlink(this.targetPath);
        HiLog.i(TAG, 'Temp file deleted successfully');
      }
      if (!isExist) {
        HiLog.e(TAG, `Source file not found`);
        return -1;
      }
      await fs.copyFile(this.sourcePath, this.targetPath);
      HiLog.i(TAG, `Successfully copied`);
      setTimeout(() => {
        HiLog.w(TAG, 'delete temporarily copied files.');
        fs.access(this.targetPath).then((exists: boolean) => {
          if (exists) {
            fs.unlink(this.targetPath);
          }
        }).catch((err: BusinessError) => {
          HiLog.w(TAG, 'Temp file cleanup error:', err.message);
        });
      }, BackupExtension.TEMPORARILY_COPIED_FILE_TIMEOUT_MS);
      return 0;
    } catch (err) {
      const error = err as BusinessError;
      HiLog.e(TAG, `Copy failed: code=${error.code}, message=${error.message}`);
      return error.code || -2;
    }
  }

  //数据自动更新存入首选项文件
  private async updateSharePreference(): Promise<void> {
    let resultSet: DataShareResultSet | undefined = undefined;
    let dataHelper: dataShare.DataShareHelper | undefined = undefined;
    try {
      dataHelper = await dataShare.createDataShareHelper(this.context, this.UPDATE_URI);
      resultSet = await new Promise<DataShareResultSet>((resolve, reject) => {
        dataHelper?.query(this.UPDATE_URI, new dataSharePredicates.DataSharePredicates(), [],
          (err, result) => err ? reject(err) : resolve(result))
      });
      if (resultSet?.rowCount > 0) {
        resultSet.goToFirstRow();
        const res = resultSet.getString(resultSet.getColumnIndex('property_value'));
        await this.updateToPreferences(res);
      } else {
        HiLog.w(TAG, 'property_value database not found')
      }
    } catch (err) {
      let error = err as BusinessError;
      HiLog.e(TAG, `query UpdateMode failed, code is ${error.code}, message is ${error.message}`)
    } finally {
      ObjectUtil.closeResultSet(resultSet);
      await dataHelper?.close();
    }
  }

  async updateToPreferences(res: string): Promise<void> {
    this.context.area = contextConstant.AreaMode.EL1;
    const preferences = await data_preferences.getPreferences(this.context, 'CONTACT_PREFERENCE') || undefined;
    if (!preferences) {
      HiLog.e(TAG, 'saveToPreferences, preferences is undefined.');
      return;
    }
    await preferences.put('property_value', res);
    await preferences.flush();
  }

  //用于区分场景
  async onRestore(bundleVersion: BundleVersion): Promise<void> {
    HiLog.e(TAG, ' onRestoreEX start.versionName ' + bundleVersion.name);
    let versionName: string = bundleVersion.name;
    if (versionName === '99.99.99.999') {
      //双到单
      HiLog.e(TAG, 'hmos2next start');
      await this.hmos2nexts();
    } else if (versionName.startsWith('0.0.0.0')) { //双升单
      HiLog.e(TAG, 'hmosupnexts start');
      await this.hmosupnexts();
    } else { // 单单克隆和云备份无法从代码层面判断出类型，默认单单克隆处理
      HiLog.e(TAG, 'default start');
      await this.next2nexts(this.targetPath);
      setTimeout(() => {
        HiLog.w(TAG, 'delete temporarily copied files.');
        fs.access(this.targetPath).then((exists: boolean) => {
          if (exists) {
            fs.unlink(this.targetPath);
          }
        }).catch((err: BusinessError) => {
          HiLog.w(TAG, 'Temp file cleanup error:', err.message);
        });
      }, BackupExtension.TEMPORARILY_COPIED_FILE_TIMEOUT_MS);
    }
  }

  async hmosupnexts() {
    try {
      this.context.area = contextConstant.AreaMode.EL1;
      let preference: preferences.Preferences =
        preferences.getPreferencesSync(this.context, { name: 'CONTACT_PREFERENCE' });
      const srPath =
        this.context.backupDir + 'restore/com.ohos.contacts/ce/shared_prefs/com.ohos.contacts_preferences.xml';
      if (fs.accessSync(srPath)) {
        let isAutoMerge = this.getFromXml(srPath, 'key_prefs_automerge');
        HiLog.i(TAG, `key_prefs_automerge is ${isAutoMerge}`);
        let boolAuto = false;
        if (isAutoMerge === 'true') {
          boolAuto = true;
        }

        await preference.put('isAutoMerge', boolAuto);
        await preference.flush();
      } else {
        HiLog.e(TAG, 'upnext ：com.ohos.contacts_preferences.xml not access');
      }

      const srPath2 = this.context.backupDir +
        'restore/com.ohos.numberidentity/de/shared_prefs/com.ohos.numberidentity_preferences.xml';
      if (fs.accessSync(srPath2)) {
        let taskType = this.getFromXml(srPath2, 'auto_item_all');
        HiLog.i(TAG, `auto_item_all is ${taskType}`);
        if (taskType != null && typeof taskType === 'string') {
          let queryData: ValuesBucket = { 'task_type': this.parseUpdateValue(taskType) };
          await this.updateCurrentUpdateMode(queryData);
        } else {
          HiLog.e(TAG, 'upgrade value task_type error');
        }
      } else {
        HiLog.e(TAG, 'upnext ：com.ohos.numberidentity_preferences.xml not access');
      }

      const srPath3 = this.context.backupDir + 'restore/com.ohos.contacts/de/datebases/contacts_app.db';
      try {
        let speedDialDb = await fs.access(srPath3);
        if (speedDialDb) {
          const STORE_CONFIG: relationalStore.StoreConfig = {
            name: 'contacts_app.db',
            securityLevel: relationalStore.SecurityLevel.S3,
            customDir: 'restore/com.ohos.contacts/de/datebases',
            rootDir: this.context.backupDir
          };

          await relationalStore.getRdbStore(this.context, STORE_CONFIG).then((rdbStore: relationalStore.RdbStore) => {
            store = rdbStore;
            HiLog.i(TAG, 'db success');
          }).catch((err: BusinessError) => {
            HiLog.e(TAG, `db false code：${err.code}，message：${err.message}`);
          });
          if (store != undefined) {
            if (await this.targetTableExistOrNot(store, 'speed_dial')) {
              const tableName = 'speed_dial';
              const columns = [];
              let predicates = new relationalStore.RdbPredicates(tableName);
              let resultSet: relationalStore.ResultSet | null = null;
              try {
                resultSet = await store.query(predicates, columns);
                HiLog.i(TAG,
                  `column count: ${resultSet.columnCount},rowcount:${resultSet.rowCount}`);
                let result = resultSet.goToFirstRow();
                while (result) {
                  let index = resultSet.getLong(resultSet.getColumnIndex('key_number'));
                  let phoneDataIdDouble = resultSet.getLong(resultSet.getColumnIndex('phone_data_id'));
                  HiLog.e(TAG, 'Index is:' + index + ';phone_data_id is:' + phoneDataIdDouble);
                  this.speedDialMap[index] = phoneDataIdDouble;
                  result = resultSet.goToNextRow();
                }
                if (resultSet === null) {
                  HiLog.e(TAG, 'hmosupnext speed_dial not found');
                  return;
                }

                if (Object.keys(this.speedDialMap).length > 0) {
                  //to do 通过phone_data_id 查询双框架数据库联系人的number和name
                }
              } catch (e) {
                const error = e as BusinessError;
                HiLog.e(TAG, `Operation failed: Code=${error.code}, Message=${error.message}`);
              } finally {
                if (resultSet !== null && resultSet !== undefined) {
                  ObjectUtil.closeResultSet(resultSet);
                } else {
                  HiLog.e(TAG, 'hmos2next isAutoMerge not found');
                }
              }
              ;
            }
          }

        }
      } catch (error) {
        HiLog.e(TAG, `db false access：${error.code}，message：${error.message}`);
      }
    } catch (e) {
      HiLog.e(TAG, `hmosupnexts err : ${e} `);
    }
  }

  //双到单
  async hmos2nexts() {
    let bkdir = this.context.backupDir;
    try {
      let dataExist: boolean = fs.accessSync(this.context.backupDir + 'restore/NumberIdentity.db');
      if (dataExist) {
        let taskType = await this.getFromNumberIdentity(bkdir);
        HiLog.i(TAG, ` task_type is : ${taskType} `);
        if (taskType !== 'error_value') {
          let queryData: ValuesBucket = { 'task_type': taskType };
          await this.updateCurrentUpdateMode(queryData);
        }
      } else {
        HiLog.i(TAG, `dataExist not :  ${dataExist} `);
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, ` accessSync failed with error message: ${err.message}  , error code: ${err.code}`);
    }
    let autoExist: boolean = false;
    try {
      autoExist = fs.accessSync(this.context.backupDir + 'restore/ContactsSettings.db');
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, ` accessSync failed with error message: ${err.message}  , error code: ${err.code}`);
    }
    if (autoExist) {
      const STORE_CONFIG: relationalStore.StoreConfig = {
        name: 'ContactsSettings.db',
        securityLevel: relationalStore.SecurityLevel.S3,
        customDir: 'restore',
        rootDir: bkdir
      };
      const oldVar = this.context.area;
      this.context.area = contextConstant.AreaMode.EL1;
      let preferences = await data_preferences.getPreferences(this.context, 'CONTACT_PREFERENCE') || undefined;
      if (!preferences) {
        HiLog.e(TAG, 'saveToPreferences, preferences is undefined');
        return;
      }
      await relationalStore.getRdbStore(this.context, STORE_CONFIG).then((rdbStore: relationalStore.RdbStore) => {
        store = rdbStore;
        HiLog.i(TAG, 'db success');
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `db false code：${err.code}，message：${err.message}`);
      });
      // 查询参数配置
      let resultSet: relationalStore.ResultSet | null = null;
      if (store != undefined) {
        if (await this.targetTableExistOrNot(store, 'comhuaweicontactsclonesettings_sharepref_file_tb')) {
          const tableName = 'comhuaweicontactsclonesettings_sharepref_file_tb';
          const columns = [];
          let predicates = new relationalStore.RdbPredicates(tableName);
          try {
            resultSet = await store.query(predicates, columns);

            HiLog.i(TAG,
              ` column count: ${resultSet.columnCount},rowcount:${resultSet.rowCount}`);
            if (resultSet?.rowCount > 0) {
              resultSet.goToFirstRow();
              let columnIndex = resultSet.getColumnIndex('column_auto_merge_enabled');
              let res = resultSet.getString(columnIndex);
              let boolAuto = false;
              if (res === 'true') {
                boolAuto = true;
              }
              HiLog.i(TAG, `isAutoMerge :${boolAuto}`);
              await preferences.put('isAutoMerge', boolAuto);
              await preferences.flush();
            }
            if (resultSet === null) {
              HiLog.e(TAG, 'hmos2next isAutoMerge not found');
              return;
            }
          } catch (e) {
            const error = e as BusinessError;
            HiLog.e(TAG, `Operation failed: Code=${error.code}, Message=${error.message}`);
          } finally {
            this.context.area = oldVar;
            if (resultSet !== null && resultSet !== undefined) {
              ObjectUtil.closeResultSet(resultSet);
            } else {
              HiLog.e(TAG, 'hmos2next isAutoMerge not found');
            }
          }
        }
        let flag = await this.targetTableExistOrNot(store, 'comhuaweicontactsclonesettings_speed_dial_tb');
        if (flag) {
          await this.getFromSpeedDialTable(store, preferences);
        }
      } else {
        HiLog.e(TAG, 'store is undefined');
      }
    }
  }

  private async targetTableExistOrNot(
    store: relationalStore.RdbStore | undefined,
    targetTable: string
  ): Promise<boolean> {
    if (!store) {
      return false;
    }
    const tableName = 'sqlite_master';
    let predicates = new relationalStore.RdbPredicates(tableName);
    predicates.equalTo('name', targetTable);

    return new Promise<boolean>((resolve, _) => {
      store.query(predicates, [], (err, resultSet) => {
        try {
          if (err) {
            HiLog.e(TAG, `Query failed, Code=${err.code}, Message=${err.message}`);
            resolve(false);
            return;
          }
          resolve(resultSet?.rowCount > 0);
        } finally {
          ObjectUtil.closeResultSet(resultSet);
        }
      });
    });
  }

  async getFromSpeedDialTable(store: relationalStore.RdbStore, preferences: preferences.Preferences) {
    // 查询参数配置
    const tableName = 'comhuaweicontactsclonesettings_speed_dial_tb';
    const columns = [];
    let predicates = new relationalStore.RdbPredicates(tableName);
    let resultSet: relationalStore.ResultSet | null = null;
    if (store != undefined) {
      try {
        resultSet = await store.query(predicates, columns);

        const speedObjArray: SpeedObj[] = [];
        HiLog.i(TAG,
          ` column count: ${resultSet.columnCount},rowcount:${resultSet.rowCount}`);
        let result = resultSet.goToFirstRow();
        while (result) {
          let index = resultSet.getString(resultSet.getColumnIndex('key_number'));
          let contactTelephone = resultSet.getString(resultSet.getColumnIndex('data1'));
          let contactName = resultSet.getString(resultSet.getColumnIndex('display_name'));
          HiLog.i(TAG, `old phone speedDial key : ${index}`);
          let nameSuffix = this.getHeadChar(contactName);
          speedObjArray.push({
            index: index,
            item: {
              number: parseInt(index),
              contactName: contactName || '',
              contactTelephone: contactTelephone.replace(/\s/g, ''),
              portraitColor: '',
              nameSuffix: nameSuffix,
              portraitPath: '',
              contactId: ''
            }
          });
          result = resultSet.goToNextRow();
        }
        if (resultSet === null) {
          HiLog.e(TAG, 'hmos2next isAutoMerge not found');
          return;
        }
        await this.saveSpeedDialForResult(speedObjArray, preferences);
      } catch (e) {
        const error = e as BusinessError;
        HiLog.e(TAG, `Operation failed: Code=${error.code}, Message=${error.message}`);
      } finally {
        if (resultSet !== null && resultSet !== undefined) {
          ObjectUtil.closeResultSet(resultSet);
        } else {
          HiLog.e(TAG, 'hmos2next isAutoMerge not found');
        }
      }
      ;
    } else {
      HiLog.e(TAG, 'store is undefined');
    }
  }

  async getFromNumberIdentity(bkdir: string): Promise<string> {
    let resultSet: relationalStore.ResultSet | null = null;
    const STORE_CONFIG2: relationalStore.StoreConfig = {
      name: 'NumberIdentity.db',
      securityLevel: relationalStore.SecurityLevel.S3,
      customDir: 'restore',
      rootDir: bkdir
    };
    try {
      const store = await relationalStore.getRdbStore(this.context, STORE_CONFIG2);
      HiLog.i(TAG, 'db success');
      const predicates2 = new relationalStore.RdbPredicates('comhuaweinumberidentityupdatebackupauto_update_tb');
      resultSet = await new Promise<relationalStore.ResultSet>((resolve, reject) => {
        store.query(predicates2, [], (err, result) => {
          err ? reject(err) : resolve(result);
        });
      });

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        const value = resultSet.getString(resultSet.getColumnIndex('auto_update'));
        return Promise.resolve(this.parseUpdateValue(value)); // 抽取值解析逻辑
      }
      return 'error_value';
    } catch (err) {
      HiLog.e(TAG, `error: ${err.message}`);
      return 'error_value'; // 统一错误处理
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  private parseUpdateValue(res: string): string {
    switch (res) {
      case '2':
        return 'close_update';
      case '1':
        return 'wlan_only';
      case '0':
        return 'all_network';
      default:
        return 'error_value'; // 处理未知值
    }
  }

  async next2nexts(targetPath: string) {
    try {
      let isAutoMerge = this.getFromXml(targetPath, 'isAutoMerge');
      let boolAuto = false;
      if (isAutoMerge === 'true') {
        boolAuto = true;
      }
      this.context.area = contextConstant.AreaMode.EL1;
      let preferences = await data_preferences.getPreferences(this.context, 'CONTACT_PREFERENCE') || undefined;
      if (!preferences) {
        HiLog.e(TAG, 'saveToPreferences, preferences is undefined.');
        return;
      }
      await preferences.put('isAutoMerge', boolAuto);

      let speedDialObjString = this.getFromXml(targetPath, 'speedDialObjString');
      if (speedDialObjString) {
        let rawData: SpeedDialItem[] = JSON.parse(speedDialObjString!);

        const speedObjArray: SpeedObj[] = [];
        Object.entries(rawData).forEach((entry) => {
          const index = entry[0];
          const value = entry[1];
          if(value){
            HiLog.i(TAG, `old phone speedDial key : ${index}`);
          }
          const item = value as SpeedDialItem;
          if (item) {
            speedObjArray.push({
              index: index,
              item: {
                number: item.number,
                contactName: item.contactName || '',
                contactTelephone: item.contactTelephone,
                portraitColor: item.portraitColor || '',
                nameSuffix: item.nameSuffix || '',
                portraitPath: item.portraitPath || '',
                contactId: ''
              }
            });
          }
        });
        await this.saveSpeedDialForResult(speedObjArray, preferences);
      }

      await preferences.flush();
      let propertyValue = this.getFromXml(targetPath, 'property_value');
      let queryData: ValuesBucket = { 'task_type': propertyValue };
      await this.updateCurrentUpdateMode(queryData);
    } catch (e) {
      HiLog.e(TAG, 'updateSetting error:' + e);
    }
  }

  getFromXml(targetPath: string, targetItem: string): string | null {
    let xmlContent = fs.readTextSync(targetPath);
    let conv = new convertxml.ConvertXML();
    let jsObj = conv.fastConvertToJSObject(xmlContent) as PreferencesRoot;
    const findKeyValue = (root: PreferencesRoot, targetKey: string): string | null => {
      // 遍历外层_elements数组
      for (const wrapper of root._elements) {
        // 遍历内层偏好设置元素
        for (const element of wrapper._elements) {
          if (element._attributes.key === targetKey || element._attributes.name === targetKey) {
            switch (element._name) {
              case 'boolean':
                return element._attributes?.value ?? null;
              case 'bool':
                return element._attributes?.value ?? null;
              case 'double':
                return element._attributes?.value ?? null;
              case 'int':
                return element._attributes?.value ?? null;
              case 'string':
                return element._elements?.[0]._text ?? null;
              default:
                return null;
            }
          }
        }
      }
      return null;
    }
    let result = findKeyValue(jsObj, targetItem);
    return result;
  }

  async updateCurrentUpdateMode(queryData: ValuesBucket): Promise<void> {
    try {
      let selectsEq = new dataSharePredicates.DataSharePredicates;
      let dataHelper = await dataShare.createDataShareHelper(this.context,
        this.UPDATE_URI);
      let result = await dataHelper.query(this.UPDATE_URI, selectsEq, ['task_type']);
      HiLog.i(TAG, ` query succeed, rowCount:${result?.rowCount} `);
      if (result?.rowCount === 0) {
        let number = await dataHelper.insert(this.UPDATE_URI, queryData);
        HiLog.i(TAG, ` insert succeed, rowCount:${number} `);
      } else {
        let number = await dataHelper.update(this.UPDATE_URI, selectsEq, queryData)
        HiLog.i(TAG, ` update succeed, rowCount:${number} `);
      }
      ObjectUtil.closeResultSet(result);
      await dataHelper?.close();
    } catch (e) {
      let err = e as BusinessError;
      HiLog.e(TAG, `update error: code: ${err?.code}, message: ${err?.message}`)
      return;
    }
  }

  async saveSpeedDialForResult(speedObj: SpeedObj[], preferences: preferences.Preferences) {
    HiLog.i(TAG, 'start saveSpeedDialForResult');
    if (!speedObj || speedObj.length == 0) {
      HiLog.i(TAG, 'SpeedDial not find');
      return;
    }
    let speedDial: Record<string, SpeedDialItem> = {};
    await this.getContactId(speedObj);
    let flag = false;
    let value = preferences.getSync('speedDialObjString', '') as string;
    if (value != '') {
      speedDial = JSON.parse(value);
      flag = true;
      Object.keys(speedDial).forEach((key: string) => {
        if (speedDial[key] != null) {
          HiLog.i(TAG, `new phone already have key: ${key}`);
        }
      });
    }
    let result: Record<string, SpeedDialItem> = speedDial;
    try {
      speedObj.forEach((item: SpeedObj) => {
        if (flag && speedDial[item.index] != null) {
          HiLog.i(TAG, `number :  ${item.index}`);
        } else {
          result[item.index] = item.item;
        }
      })
      await preferences.put('speedDialObjString', JSON.stringify(result));
      HiLog.i(TAG, 'updateSpeedDial done');
      await preferences.flush();
    } catch (e) {
      HiLog.e(TAG, 'updateSpeedDial error:' + e);
    }
  }

  async getContactId(speedObj: SpeedObj[]) {
    try {
      let dataHelperData = await dataShare.createDataShareHelper(this.context, this.VIEW_CONTACT_DATA_URI);
      let dataHelperRaw = await dataShare.createDataShareHelper(this.context, this.VIEW_RAW_CONTACT_URI);

      for (const item of speedObj) {
        let rawContact: number = -1;
        const destructedItem = item.item;
        const name = destructedItem.contactName;
        const phoneNumber = destructedItem.contactTelephone;

        let result: DataShareResultSet | null = null;
        let resultContact: DataShareResultSet | null = null;

        try { // 单条数据错误捕获
          // 构建查询条件
          const selectsEq = new dataSharePredicates.DataSharePredicates();
          selectsEq.notEqualTo('is_deleted', 1)
            .beginWrap()
            .equalTo('type_id', 5)
            .equalTo('detail_info', phoneNumber)
            .endWrap()
            .or()
            .beginWrap()
            .equalTo('type_id', 6)
            .equalTo('detail_info', name)
            .endWrap();

          // 执行查询并处理结果
          result = await dataHelperData.query(this.VIEW_CONTACT_DATA_URI, selectsEq, ['raw_contact_id']);
          let set = new Set<number>();
          let flag = result?.goToFirstRow();
          while (flag) {
            const rawContactId = result.getLong(result.getColumnIndex('raw_contact_id'));
            if (set.has(rawContactId)) {
              rawContact = rawContactId;
              break;
            }
            set.add(rawContactId);
            flag = result?.goToNextRow();
          }
          HiLog.i(TAG, 'rawContactId :' + rawContact);

          if (rawContact != -1) {
            const selectsEqRaw = new dataSharePredicates.DataSharePredicates();
            selectsEqRaw.equalTo('id', rawContact);
            resultContact = await dataHelperRaw.query(this.VIEW_RAW_CONTACT_URI, selectsEqRaw, ['contact_id']);
            if (resultContact?.goToFirstRow()) {
              HiLog.i(TAG, 'contact_id :' + resultContact.getString(resultContact.getColumnIndex('contact_id')));
              item.item.contactId = resultContact.getString(resultContact.getColumnIndex('contact_id'));
            }
          } else {
            item.item.contactId = '';
          }
        } catch (e) {
          HiLog.e(TAG, `Process item error: ${e}`);
          continue;
        } finally {
          ObjectUtil.closeResultSet(result);
          ObjectUtil.closeResultSet(resultContact);
        }
      }
    } catch (e) {
      HiLog.e(TAG, 'getContactId error:' + e);
    }
  }
  getHeadChar(name?: string): string {
    if (StringUtil.isEmpty(name) || (typeof name !== 'string')) {
      return '';
    }
    name = name.replace(new RegExp('<\/?.+?>', 'g'), '')
    let headChar = '';

    if (this.hasChinese.test(name)) {
      for (let i = name.length - 1; i >= 0; --i) {
        if (this.hasChinese.test(name[i])) {
          headChar = name[i];
          break;
        }
      }
    } else if (this.hasEnglish.test(name[0])) {
      headChar = name[0];
    } else {
      headChar = '';
    }
    return headChar;
  }
}
