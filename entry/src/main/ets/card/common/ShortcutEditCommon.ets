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
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import { ObjectUtil } from '../../../../../../common/src/main/ets/util/ObjectUtil';
import formBindingData from '@ohos.app.form.formBindingData';
import { BusinessError } from '@ohos.base';
import { ParamsType, PhonesType, ShortcutDataType } from '../type/shortcut';
import { ContactRepository, Contacts, Data } from '../../../../../../feature/contact';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';

const TAG = 'ShortcutEditCommon';

export default class ShortcutEditCommon {
  public contact: ShortcutDataType[] = [];

  public async parseContactForResult(data: Record<string, Object>) {
    if (data && data.resultCode == 0) {
      if (data.want && (data.want as Record<string, Object>)?.parameters) {
        let parameters = (data.want as Record<string, Object>)?.parameters as Record<string, Object>;
        let objectStr: string = parameters.contactObjects as string;
        let param = this.dealContactParams(objectStr);
        if (param.length === 0) {
          this.contact = [];
        } else {
          let item = param[0];
          let da = new ShortcutDataType();
          da.showName = item.contactName;
          da.phones[0] = new PhonesType();
          da.phones[0].num = item.telephone;
          da.id = item.id;
          da.contactId = item.contactId;
          this.contact = [];
          this.contact.push(da);
        }
      }
    }
    return this.contact
  }

  private dealContactParams(contactObjects: string): ParamsType[] {
    HiLog.i(TAG, '[dealContactParams contactObjects] contactObjects length: ' + contactObjects?.length);
    let params: ParamsType[] = [];
    try {
      params = JSON.parse(contactObjects);
      HiLog.i(TAG, '[dealContactParams params] params.length: ' + params?.length);
      return params;
    } catch (e) {
      HiLog.e(TAG, 'dealContactParams failed, return!');
      let ele: ParamsType[] = [];
      return ele;
    }
  }

  public updateToCard = (formId: string, data: formBindingData.FormBindingData) => {
    formProvider.updateForm(formId, data).then(() => {
      HiLog.w(TAG, `formProvider updateForm success formId: ${formId}`);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `[updateToCard err] ${err?.message} formId: ${formId}`);
    })
  }

  async queryContactFormId(contactId: string, context: Context) {
    HiLog.w(TAG, `queryContactFormId contact: ${contactId}`)
    let formId: string = ''
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('id', contactId);
      conditionArgs.and()
      conditionArgs.equalTo('is_deleted', '0');
      let dataShareHelper = await ContactRepository.getInstance()
        .init(context)
        .getDataAbilityHelper();
      resultSet = await dataShareHelper.query(Contacts.CONTACT_URI, conditionArgs, ['form_id']);
      HiLog.w(TAG, `queryContactFormId count is ${resultSet?.rowCount}`)
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        formId = resultSet.getString(resultSet.getColumnIndex('form_id'))
      }
      return formId
    } catch (error) {
      HiLog.e(TAG, `queryContactFormId fail ${error?.message}`)
      return formId
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  async updateContactFormId(contactId: string, context: Context, formId: string | null) {
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
      HiLog.w(TAG, `updateContactFormId success`)
    } catch (error) {
      HiLog.e(TAG, `updateContactFormId fail msg:${error?.message}`)
    }
  }

  async queryContactByFormId(formId: string, context: Context) {
    HiLog.w(TAG, `queryContactByFormId formId: ${formId}`)
    let shortcutData: ShortcutDataType[] = []

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
          let obj: ShortcutDataType = {
            contactId: contactId,
            phones: [],
            showName: displayName,
            id: Number(id),
            formId: formId,
            photoFirstName: nameSuffix
          }
          shortcutData.push(obj)
        } while (resultSet.goToNextRow())
      }
      return shortcutData
    } catch (error) {
      HiLog.e(TAG, `updateContactFormId fail msg:${error?.message}, stack: ${error?.stack}`)
      return shortcutData
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }
}