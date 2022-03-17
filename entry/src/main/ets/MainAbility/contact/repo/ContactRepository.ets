/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import IContactRepository from './IContactRepository';
import Contact from '../entity/Contact';
import RawContact from '../entity/RawContact';
import ContactBuilder from '../entity/ContactBuilder';
import DataItem from '../entity/DataItem';
import ContactList from './ContactList';
import FeatureAbility from '@ohos.ability.featureAbility';
import DAOperation from './DAOperation';
import ContactDelta from './ContactDelta';
import RawContacts from '../contract/RawContacts';
import Contacts from '../contract/Contacts';
import Data from '../contract/Data';
import StringUtil from '../../util/StringUtil';
import DataAbility from '@ohos.data.dataAbility';
import HiLog from '../../util/HiLog';
import ContactListItem from './ContactListItem';

const TAG = "ContactRepository";

/**
 * 联系人存储管理，屏蔽对cp层的依赖
 * 仅限联系人
 */
export default class ContactRepository implements IContactRepository {
  static readonly RAW_CONTACT_URL: string = RawContacts.CONTENT_URI;
  private _dataAbilityHelper = FeatureAbility.acquireDataAbilityHelper(Contacts.CONTENT_URI);
  private static instance: ContactRepository

  private constructor() {
  }

  public static getInstance(): ContactRepository {
    if (!ContactRepository.instance) {
      ContactRepository.instance = new ContactRepository()
    }
    return ContactRepository.instance
  }

  saveTest() {
    return false;
  }

  private getDataAbilityHelper(){
    if (this._dataAbilityHelper == undefined || this._dataAbilityHelper == null || this._dataAbilityHelper.length == 0) {
      this._dataAbilityHelper = FeatureAbility.acquireDataAbilityHelper(Contacts.CONTENT_URI);
    }
    return this._dataAbilityHelper;
  }

  save(contact: ContactDelta) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<Array<any>>(function (resolve, reject) {
      let opts = contact.buildDiff();
      return dataAbilityHelper.executeBatch(ContactRepository.RAW_CONTACT_URL, opts)
        .then(resultSet => {
          resolve(resultSet);
        })
        .catch(error => {
          HiLog.w(TAG, 'save error:%s', JSON.stringify(error.message));
          reject(error);
        });
    });

  }

  findById(id: number) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<Contact>(function (resolve, reject) {
      if (id < 0) {
        HiLog.w(TAG, 'findById: id is invalid.');
        reject();
        return;
      }
      let conditionArgs = new DataAbility.DataAbilityPredicates();
      conditionArgs.equalTo(RawContacts.CONTACT_ID, id).orderByAsc(Data.RAW_CONTACT_ID);
      dataAbilityHelper.query(Data.CONTENT_URI, null, conditionArgs).then(resultSet => {
        if (resultSet == undefined || !resultSet.goToFirstRow()) {
          HiLog.w(TAG, 'findById not found.');
          reject();
        }
        let contactBuilder = ContactBuilder.fromResultSet(resultSet);
        let currentRawContactId = -1;
        let rawContact: RawContact = null;
        do {
          let rawContactId = resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
          if (rawContactId != currentRawContactId) {
            currentRawContactId = rawContactId;
            rawContact = RawContact.fromResultSet(resultSet);
            contactBuilder.rowContacts.push(rawContact);
          }
          if (!resultSet.isColumnNull(resultSet.getColumnIndex(Data.ID)) && rawContact != undefined) {
            rawContact.dataItems.push(DataItem.fromResultSet(resultSet));
          }
        } while (resultSet.goToNextRow());
        resultSet.close();
        resolve(contactBuilder.buildContact());
      }).catch(error => {
        HiLog.e(TAG, 'findById error:%s', JSON.stringify(error.message));
        reject(error);
      });
    });
  }

  findAll() {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<ContactListItem[]>(function (resolve, reject) {
      let conditionArgs = new DataAbility.DataAbilityPredicates();
      conditionArgs.equalTo(RawContacts.IS_DELETED, '0').orderByAsc(RawContacts.SORT_FIRST_LETTER);
      dataAbilityHelper.query(Contacts.CONTACT_URI, ContactListItem.COLUMNS, conditionArgs)
        .then(resultSet => {
          let rst: ContactListItem[] = [];
          resultSet.goToFirstRow();
          do {
            let id = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
            if (id < 0) {
              HiLog.w(TAG, 'findAll: contact id is invalid.');
              continue;
            }
            rst.push(new ContactListItem(resultSet));
          } while (resultSet.goToNextRow());
          resultSet.close();
          resolve(rst);
        })
        .catch(error => {
          HiLog.w(TAG, 'findAll error:%s', JSON.stringify(error.message));
          reject(error);
        });
    });
  }

  findByQuickSearchKey(searchKey: string) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<Contact>(function (resolve, reject) {
      let conditionArgs = new DataAbility.DataAbilityPredicates();
      conditionArgs.equalTo(Contacts.QUICK_SEARCH_KEY, searchKey).orderByAsc(Data.RAW_CONTACT_ID);
      dataAbilityHelper.query(Data.CONTENT_URI, null, conditionArgs).then(resultSet => {
        if (resultSet == undefined || !resultSet.goToFirstRow()) {
          HiLog.w(TAG, 'findByQuickSearchKey not found.');
          reject();
        }
        let contactBuilder = ContactBuilder.fromResultSet(resultSet);
        let currentRawContactId = -1;
        let rawContact: RawContact = null;
        do {
          let rawContactId = resultSet.getLong(resultSet.getColumnIndex(Data.RAW_CONTACT_ID));
          if (rawContactId != currentRawContactId) {
            currentRawContactId = rawContactId;
            rawContact = RawContact.fromResultSet(resultSet);
            contactBuilder.rowContacts.push(rawContact);
          }
          if (!resultSet.isColumnNull(resultSet.getColumnIndex(Data.ID)) && rawContact != undefined) {
            rawContact.dataItems.push(DataItem.fromResultSet(resultSet));
          }
        } while (resultSet.goToNextRow());
        resultSet.close();
        resolve(contactBuilder.buildContact());
      }).catch(error => {
        HiLog.e(TAG, 'findByQuickSearchKey error:%s', JSON.stringify(error.message));
        reject(error);
      });
    });
  }

  findAllWithBookIndex() {
    return new ContactList({});
  }

  search(queryStr:string) {
    return new ContactList({});
  }

  findByPhoneIsNotNull() {
    return new Promise<ContactListItem[]>(function (resolve, reject) {
      reject();
    });
  }

  findByMailIsNotNull() {
    return new ContactList({});
  }

  deleteById(id: number) {
    let dataAbilityHelper = this.getDataAbilityHelper();
    return new Promise<number>(function (resolve, reject) {
      if (id < 0) {
        reject();
        return;
      }
      let condition = new DataAbility.DataAbilityPredicates();
      condition.equalTo(Contacts.ID, id);
      dataAbilityHelper.delete(Contacts.CONTACT_URI, condition).then(data => {
        resolve(data);
      }).catch(error => {
        HiLog.w(TAG, 'deleteById error:%s', JSON.stringify(error.message));
        reject(error);
      });
    });
  }

  deleteByIdIn(ids: number[]) {
    return false;
  }
}