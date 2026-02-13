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
import formProvider from '@ohos.app.form.formProvider';
import formBindingData from '@ohos.app.form.formBindingData';
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import { ParamsType, PhonesType, SpeedDialDataType } from '../type/speedDial';
import { BusinessError } from '@ohos.base';
import { SettingsDataStorage } from './SettingsDatashareCommon';
import { ContactRepository, Contacts, Data } from '../../../../../../feature/contact';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import {
    ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { buffer } from '@kit.ArkTS';
import { DataShareResultSet } from '@kit.ArkData';
import { ObjectUtil } from '../../../../../../common/src/main/ets/util/ObjectUtil';

const TAG = 'SpeedDialEditCommon';

export default class SpeedDialEditCommon {
  public constContacts: SpeedDialDataType[] = [];
  public contacts: SpeedDialDataType[] = [];
  public resultDT: boolean = true;

  public async parseContactForResult(data: Record<string, Object>) {
    if (data && data.resultCode == 0) {
      if (data.want && (data.want as Record<string, Object>)?.parameters) {
        let parameters = (data.want as Record<string, Object>)?.parameters as Record<string, Object>;
        let objectStr: string = parameters.contactObjects as string;
        let param = this.dealContactParams(objectStr);
        HiLog.w(TAG, '[dealContactParams length]' + param.length);
        let newArr: SpeedDialDataType[] = []
        newArr = this.contacts.concat(param.map((item: ParamsType) => {
          let SpeedDialDataItem: SpeedDialDataType = new SpeedDialDataType();
          SpeedDialDataItem.showName = item.contactName;
          SpeedDialDataItem.phones[0] = new PhonesType();
          SpeedDialDataItem.phones[0].num = item.telephone;
          SpeedDialDataItem.id = item.id;
          SpeedDialDataItem.contactId = item.contactId;
          return SpeedDialDataItem;
        }))
        let forData: SpeedDialDataType[] = [];
        for (let i = 0; i < newArr.length; i++) {
          if (!forData.some(e => e.contactId == newArr[i].contactId)) {
            forData.push(newArr[i]);
          }
        }
        if (forData.length > 4) {
          forData = forData.slice(0, 4);
        }
        this.contacts = forData
        HiLog.w(TAG, '[get contacts length]' + this.contacts.length);
      }
    }
    return this.contacts
  }

  private dealContactParams(contactObjects: string): ParamsType[] {
    HiLog.w(TAG, '[dealContactParams contactObjects]');
    let params: ParamsType[] = [];
    try {
      params = JSON.parse(contactObjects);
      HiLog.w(TAG, '[params length is ]' + params.length);
      return params;
    } catch (e) {
      HiLog.e(TAG, 'dealContactParams failed, return!');
      let ele: ParamsType[] = [];
      return ele;
    }
  }

  public updateToCard(formId: string, data: formBindingData.FormBindingData) {
    formProvider.updateForm(formId, data).then(() => {
      HiLog.w(TAG, `formProvider updateForm success formId: ${formId}`);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `[updateToCard err] message: ${err?.message}, code: ${err?.code}, stack: ${err?.stack}, formId: ${formId}`);
    })
  }

  public async updateToSettings(contacts: SpeedDialDataType[]) {
    const added = contacts.filter(item =>!this.constContacts.includes(item)).toString();
    const removed = this.constContacts.filter(item =>!contacts.includes(item)).toString();
    let dataStorage: SettingsDataStorage = new SettingsDataStorage();
    await dataStorage.initData();
    dataStorage.update(added, removed);
  }

  async queryContactFormId(contactId: string, context: Context) {
    HiLog.w(TAG, `queryContactFormId contact: ${contactId}`)
    let formId = ''

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('id', contactId);
      conditionArgs.and()
      conditionArgs.equalTo('is_deleted', '0');
      let dataShareHelper = await ContactRepository.getInstance()
        .init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext())
        .getDataAbilityHelper();
      resultSet = await dataShareHelper.query(Contacts.CONTACT_URI, conditionArgs, ['form_id']);
      HiLog.w(TAG, `queryContactFormId count is ${resultSet?.rowCount}`)
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        formId = resultSet.getString(resultSet.getColumnIndex('form_id'))
      }
      return formId
    } catch (error) {
      HiLog.e(TAG, `queryContactFormId fail ${error?.message}, stack: ${error?.stack}`)
      return formId
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  async updateContactFormId(contactId: string, context: Context, formId: string) {
    HiLog.w(TAG, `updateContactFormId contactId: ${contactId}, formId: ${formId}`)
    try {
      let dataShareHelper = await ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper();
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('id', contactId);

      let insertValues: Record<string, string | number> = {
        'form_id': formId ? formId.toString() : '',
      };
      dataShareHelper.update(
        Contacts.CONTACT_URI,
        conditionArgs,
        insertValues,
      )
    } catch (error) {
      HiLog.e(TAG, `updateContactFormId fail msg:${error?.message}, stack: ${error?.stack}`)
    }
  }

  //通过formId查询被添加到卡片上的联系人
  async queryContactByFormId(formId: string, context: Context) {
    HiLog.w(TAG, `queryContactByFormId formId: ${formId}`)
    let speedDialData: SpeedDialDataType[] = []

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.contains('form_id', formId);
      conditionArgs.and()
      conditionArgs.equalTo('is_deleted', '0');
      let dataShareHelper = await ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper();
      let columnName = ['id', 'display_name', 'form_id', 'photo_first_name']
      resultSet = await dataShareHelper.query(Contacts.CONTACT_URI, conditionArgs, columnName);
      HiLog.w(TAG, `queryContactByFormId count is ${resultSet?.rowCount}`)
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          let nameSuffix: string = resultSet.getString(resultSet.getColumnIndex(Contacts.PHOTO_FIRST_NAME));
          let displayName: string = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME));
          let contactId: string = resultSet.getString(resultSet.getColumnIndex(Contacts.ID));
          let id: string = resultSet.getString(resultSet.getColumnIndex(Contacts.ID));
          let formId: string = resultSet.getString(resultSet.getColumnIndex(Contacts.FORM_ID));
          let obj: SpeedDialDataType = {
            contactId: contactId,
            displayName: displayName,
            nameSuffix: nameSuffix,
            phones:  [],
            showName: displayName,
            id: Number(id),
            formId: formId
          }
          speedDialData.push(obj)
        } while (resultSet.goToNextRow())
      }
      speedDialData = this.speedDailDataSort(speedDialData, formId)
      return speedDialData
    } catch (error) {
      HiLog.e(TAG, `queryContactByFormId fail msg:${error?.message}, stack: ${error?.stack}`)
      return speedDialData
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  //2*2卡片移动排序
  speedDailDataSort(speedDialData: SpeedDialDataType[], formId: string) {
    return speedDialData.sort((a, b) => {
      const aIndex = a.formId.indexOf(formId);
      const bIndex = b.formId.indexOf(formId);
      const aNum = parseInt(a.formId.slice(aIndex + formId.length + 1));
      const bNum = parseInt(b.formId.slice(bIndex + formId.length + 1));
      return aNum - bNum;
    });
  }

  //预览卡片获取联系人头像
  async onAddImage(contactsList: SpeedDialDataType[]) {
    let promiseList: Promise<string>[] = []
    for (let item of contactsList) {
      promiseList.push(
        new Promise(async (resolve: (value: string) => void) => {
          let blob: string = await this.getBlobDataFromId(item.contactId)
          item.base64Str = blob
          resolve(blob as string)
        })
      )
    }
    return Promise.all(promiseList).then(() => {
      return contactsList;
    })
  }

  async getBlobDataFromId(contactId: string) {
    HiLog.w(TAG, `getBlobDataFromId contactId:${contactId}`);

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('contact_id', contactId);
      conditionArgs.equalTo('type_id', 8);
      let dataShareHelper = await ContactRepository.getInstance()
        .init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext())
        .getDataAbilityHelper();
      resultSet = await dataShareHelper.query(Data.CONTENT_URI, conditionArgs, [Data.BLOB_DATA]);
      if (resultSet.rowCount === 0) {
        return '';
      }
      resultSet.goToFirstRow();
      let blobData = resultSet.getBlob(resultSet.getColumnIndex(Data.BLOB_DATA));
      if (!blobData) {
        HiLog.w(TAG, 'Blob data is null');
        return '';
      }
      let result = 'data:image/jpeg;base64,' + buffer.from(blobData.buffer).toString('base64');
      return result
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

}