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

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from "@ohos.data.dataSharePredicates";
import IContactRepository from './IContactRepository';
import Contact from '../entity/Contact';
import RawContact from '../entity/RawContact';
import ContactBuilder from '../entity/ContactBuilder';
import { DataItem } from '../entity/DataItem';
import ContactList from './ContactList';
import DAOperation from './DAOperation';
import ContactDelta from './ContactDelta';
import { RawContacts } from '../contract/RawContacts';
import { Contacts } from '../contract/Contacts';
import { Data } from '../contract/Data';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import ContactListItem from './ContactListItem';
import { DataItemType } from '../contract/DataType';

const TAG = "ContactRepository";

/**
 * Contact storage management, shielding dependency on the CP layer
 * Contacts Only
 */
export class ContactRepository implements IContactRepository {
  static readonly RAW_CONTACT_URL: string = RawContacts.CONTENT_URI;
  private dataShareHelper;
  private static instance: ContactRepository;
  private context: Context

  private constructor() {
  }

  /*
   * init if Call From serviceAbility globalThis.context is Null
   *@param ctx Context used for dataShare
   */
  init(ctx: Context) {
    this.context = ctx;
  }

  public static getInstance(): ContactRepository {
    if (!ContactRepository.instance) {
      ContactRepository.instance = new ContactRepository();
    }
    return ContactRepository.instance;
  }

  saveTest() {
    return false;
  }

  private async getDataAbilityHelper() {
    if (this.dataShareHelper == undefined) {
      this.dataShareHelper = await dataShare.createDataShareHelper(this.context ? this.context : globalThis.context,
          Contacts.CONTENT_URI);
    }
    return this.dataShareHelper;
  }

  save(contact: ContactDelta, callback) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let opts = contact.buildDiff();
      return dataAbilityHelper.executeBatch(ContactRepository.RAW_CONTACT_URL, opts)
        .then(resultSet => {
          callback(resultSet);
        })
        .catch(error => {
          HiLog.w(TAG, 'save error:%s' + JSON.stringify(error.message));
          callback();
        });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback();
    });
  }

  findById(id: number, callback) {
    if (id < 0) {
      HiLog.w(TAG, 'findById: id is invalid.');
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(RawContacts.CONTACT_ID, id).orderByAsc(Data.RAW_CONTACT_ID);
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, null).then(resultSet => {
        if (resultSet == undefined || !resultSet.goToFirstRow()) {
          HiLog.w(TAG, 'findById not found.');
          callback();
          return;
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
          if (rawContact != undefined) {
            rawContact.dataItems.push(DataItem.fromResultSet(resultSet));
          }
        } while (resultSet.goToNextRow());
        resultSet.close();
        callback(contactBuilder.buildContact());
      }).catch(error => {
        HiLog.e(TAG, 'findById error:%s' + JSON.stringify(error.message));
        callback();
      });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback();
    });
  }

  findAll(actionData, callback) {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    let offset = actionData.page < 3 ? (actionData.page - 1) * 50 : (actionData.page - 2) * 500 + 50;
    conditionArgs.limit(actionData.limit, offset)
    //      conditionArgs.limitAs(actionData.limit);
    //      conditionArgs.offsetAs(offset);
    conditionArgs.equalTo(RawContacts.IS_DELETED, '0').orderByAsc(RawContacts.SORT_FIRST_LETTER);
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, ContactListItem.COLUMNS)
        .then(resultSet => {
          let rst: ContactListItem[] = [];
          if (resultSet.rowCount === 0) {
            resultSet.close();
            callback(rst);
          } else {
            resultSet.goToFirstRow();
            do {
              rst.push(new ContactListItem(resultSet));
            } while (resultSet.goToNextRow());
            resultSet.close();
            callback(rst);
          }
        })
        .catch(error => {
          HiLog.w(TAG, 'findAll error:%s' + JSON.stringify(error.message));
          callback([]);
        });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback([]);
    });
  }

  findByQuickSearchKey(searchKey: string, callback) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(Contacts.QUICK_SEARCH_KEY, searchKey).orderByAsc(Data.RAW_CONTACT_ID);
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, null).then(resultSet => {
        if (resultSet == undefined || !resultSet.goToFirstRow()) {
          HiLog.w(TAG, 'findByQuickSearchKey not found.');
          callback();
          return;
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
          if (rawContact != undefined) {
            rawContact.dataItems.push(DataItem.fromResultSet(resultSet));
          }
        } while (resultSet.goToNextRow());
        resultSet.close();
        callback(contactBuilder.buildContact());
      }).catch(error => {
        HiLog.e(TAG, 'findByQuickSearchKey error:%s' + JSON.stringify(error.message));
        callback();
      });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback();
    });
  }

  findAllWithBookIndex() {
    return new ContactList({});
  }

  search(queryStr: string) {
    return new ContactList({});
  }

  findByPhoneIsNotNull(callback) {
    this.getAllContactNumbers((contactNumberMap) => {
      this.getDataAbilityHelper().then((dataAbilityHelper) => {
        let conditionArgs = new dataSharePredicates.DataSharePredicates();
        conditionArgs.equalTo(RawContacts.IS_DELETED, '0')
          .and()
          .equalTo(Contacts.HAS_PHONE_NUMBER, '1')
          .orderByAsc(RawContacts.SORT_FIRST_LETTER);
        dataAbilityHelper.query(Contacts.CONTACT_URI, conditionArgs, ContactListItem.COLUMNS)
          .then(resultSet => {
            let rst: ContactListItem[] = [];
            if (resultSet.rowCount === 0) {
              resultSet.close();
              callback(rst);
            } else {
              resultSet.goToFirstRow();
              do {
                let id = resultSet.getLong(resultSet.getColumnIndex(Contacts.ID));
                if (!contactNumberMap.has(id)) {
                  HiLog.w(TAG, 'findAll: contact id is invalid or contact has no phone number.');
                  continue;
                }
                let contactListItem = new ContactListItem(resultSet);
                contactListItem.phoneNumbers = contactNumberMap.get(id);
                rst.push(contactListItem);
              } while (resultSet.goToNextRow());
              resultSet.close();
              callback(rst);
            }
          })
          .catch(error => {
            HiLog.w(TAG, 'findAll error:%s' + JSON.stringify(error.message));
            callback();
          });
      }).catch(error => {
        HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
        callback();
      });
    });
  }

  /**
   * 查询所有联系人手机号
   */
  private getAllContactNumbers(callback) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let resultColumns = [RawContacts.CONTACT_ID, Data.DETAIL_INFO, Data.EXTEND7, Data.CUSTOM_DATA];
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo(Data.TYPE_ID, DataItemType.PHONE).orderByAsc(RawContacts.CONTACT_ID);
      dataAbilityHelper.query(Data.CONTENT_URI, conditionArgs, resultColumns).then(resultSet => {
        // 用于存储联系人及其电话号码的对应关系
        let contactNumberMap = new Map();
        if (resultSet == undefined || !resultSet.goToFirstRow()) {
          HiLog.w(TAG, 'getAllContactNumbers not found.');
          callback(contactNumberMap);
          return;
        }
        let oldContact = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
        let oldPhoneNumber = "";
        let numberList = [];
        do {
          let newContact = resultSet.getLong(resultSet.getColumnIndex(RawContacts.CONTACT_ID));
          let phoneNumberObj = {
            'phoneNumber': resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)),
            'labelId': resultSet.getString(resultSet.getColumnIndex(Data.EXTEND7)),
            'numType': resultSet.getString(resultSet.getColumnIndex(Data.CUSTOM_DATA))
          };
          // 如果是同一联系人则把手机号放到同一个list中
          if (oldContact === newContact) {
            if (oldPhoneNumber != phoneNumberObj.phoneNumber) {
              numberList.push(phoneNumberObj);
            }
          } else {
            // 联系人变化时，存储联系人与手机号码列表的对应关系
            contactNumberMap.set(oldContact, numberList);
            oldContact = newContact;
            // 将最新的号码数据存储到新的numberList
            numberList = [phoneNumberObj];
          }
          oldPhoneNumber = phoneNumberObj.phoneNumber;
        } while (resultSet.goToNextRow());
        contactNumberMap.set(oldContact, numberList);
        resultSet.close();
        callback(contactNumberMap);
      });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback(new Map());
    });
  }

  findByMailIsNotNull() {
    return new ContactList({});
  }

  deleteById(id: number, callback) {
    if (id < 0) {
      callback();
      return;
    }
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(Contacts.ID, id);
      dataAbilityHelper.delete(Contacts.CONTACT_URI, condition).then(data => {
        callback(data);
      }).catch(error => {
        HiLog.w(TAG, 'deleteById error:%s' + JSON.stringify(error.message));
        callback();
      });
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      callback();
    });
  }

  deleteByIdIn(ids: number[]) {
    return false;
  }

  notifyChange() {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.notifyChange(Data.CONTENT_URI).then(() => {
          HiLog.i(TAG, "notifyChange success")
        }).catch(error => {
          HiLog.w(TAG, 'notifyChange error:%s' + JSON.stringify(error.message));
        });
      }
    }).catch(error => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }

  observers:Array<()=>void> = [];

  callback = ()=>{
    HiLog.d(TAG, 'Contacts changed: Notifying observers...');
    for (const observer of this.observers) {
      observer();
    }
  }

  registerDataChangeObserver(observer:()=>void) {
    if (!observer) {
      HiLog.i(TAG, `registerDataChangeObserver: observer is null.`);
      return;
    }
    if (this.observers.length == 0) {
      this.getDataAbilityHelper().then((dataAbilityHelper) => {
        if (dataAbilityHelper) {
          dataAbilityHelper.on("dataChange", Data.CONTENT_URI, this.callback);
        }
      }).catch(error => {
        HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      });
    }
    const isExist = this.observers.includes(observer);
    if (isExist) {
      return HiLog.i(TAG, 'registerDataChangeObserver: Observer has been attached already.');
    }
    HiLog.i(TAG, 'registerDataChangeObserver: Attached an observer.');
    this.observers.push(observer);
  }

  unRegisterDataChangeObserver(observer:()=>void) {
    const observerIndex = this.observers.indexOf(observer);
    if (observerIndex === -1) {
      HiLog.i(TAG, 'unRegisterDataChangeObserver: Nonexistent observer.');
      return
    }
    this.observers.splice(observerIndex, 1);
    HiLog.i(TAG, 'unRegisterDataChangeObserver: Detached an observer.');
    if (this.observers.length == 0) {
      this.getDataAbilityHelper().then((dataAbilityHelper) => {
        if (dataAbilityHelper) {
          dataAbilityHelper.off("dataChange", Data.CONTENT_URI, this.callback);
        }
      }).catch(error => {
        HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
      });
    }
  }

  queryContactDataByNumber(numberList, callback) {
    this.getDataAbilityHelper().then((dataAbilityHelper) => {
      if (!dataAbilityHelper) {
        HiLog.e(TAG, "queryContactDataByNumber, dataAbilityHelper is null");
        callback([]);
        return;
      }
      let resultColumns = [
        "detail_info",
        "display_name",
      ];
      let condition = new dataSharePredicates.DataSharePredicates();
      condition.in("detail_info", numberList);
      condition.and();
      condition.equalTo("type_id", "5");
      condition.and();
      condition.equalTo("is_deleted", "0");
      dataAbilityHelper.query(Data.CONTENT_URI, condition, resultColumns).then(resultSet => {
        callback(this.dealContactResultSet(resultSet));
      }).catch(error => {
        HiLog.e(TAG, "queryContactDataByNumber query, error: " + JSON.stringify(error.message));
      })
    }).catch(error => {
      HiLog.e(TAG, "queryContactDataByNumber, error: " + JSON.stringify(error.message));
      callback([]);
    });
  }

  dealContactResultSet(resultSet) {
    let contacts = [];
    while (resultSet?.goToNextRow()) {
      let contact: {[key: string]: any} = {};
      contact.detailInfo = resultSet.getString(0);
      contact.displayName = resultSet.getString(1);
      contacts.push(contact);
    }
    return contacts;
  }
}