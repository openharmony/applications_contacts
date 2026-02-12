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
import HashMap from '@ohos.util.HashMap';
import { ArrayUtil, HiLog, ObjectUtil } from '../../../../../../../common';
import { ContactVo } from '../../../model/bean/ContactVo';
import RepeatDataSource from '../../../model/bean/RepeatDataSource';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import common from '@ohos.app.ability.common';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import ContactListDataSource from '../../../model/bean/ContactListDataSource';
import { AccountVo } from '../../../model/bean/AccountVo';
import { ContactInfoGetParamsInCallback } from '../../../model/type/ContactParams';
import LooseObject from '../../../model/type/LooseObject';
import { HashSet } from '@kit.ArkTS';
import { DynamicLoader } from '../../../../../../../feature/call/oh_modules/common';
import SmsManagerUtils from '../../../util/SmsManagerUtils';
import { BusinessError } from '@ohos.base';
import { manualMergeDuplicateContactsByUrl } from '../../../task/TaskService';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../../data/EmitterConstant';
import {
  ContactRepository,
  RestoreResultType
} from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import { CountRawContact } from '../../../model/type/ContactParams';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import {
  AuditLogUtils,
  UtilAuditLog,
  assembleLogUtils
} from '../../../../../../../common/src/main/ets/util/AuditLogUtils';


const TAG = 'ArrangeContactsPresenter';
const reg: RegExp = new RegExp('-', 'g');
const regEx: RegExp = new RegExp('@', 'g');
const regExp: RegExp = new RegExp('#', 'g');
const restoreContactsMaxTime = 120 * 1000;

let auditlogUtils: AuditLogUtils = AuditLogUtils.getInstance();

/**
 * 手动合并重复联系人
 */
export default class ArrangeContactsPresenter {
  // 路径信息
  public pathInfos?: NavPathStack;
  public static ARRANGE_CONTACT_ITEM_CHECKED = 'ArrangeContactItemChecked';
  private static sInstance: ArrangeContactsPresenter;
  public contactList: ContactVo[] = []
  public repeatList: RepeatContactVo[] = []
  // 所有账号
  public accountList: AccountVo[] = []
  public repeatDataSource: RepeatDataSource = new RepeatDataSource();
  public refreshContactsEmitterId: number = 108;
  public initialIndex: number = 0;
  // 联系人数量
  public total: number = 0;
  public accountSizeMap: HashMap<string, number> = new HashMap<string, number>();
  public selectedRepeatContacts: HashMap<string, RepeatContactVo> = new HashMap();
  public mergeContactProgress: number = 0;
  public mergeContactProgressTask: number = -1;
  private restoreTimeout: number = -1;
  public selectCount: number = 0;
  public refreshUI: () => void = () => {
  };
  public sceillOnlenth: number = 0;

  constructor() {
  }

  public static getInstance(): ArrangeContactsPresenter {
    if (ArrangeContactsPresenter.sInstance == null) {
      HiLog.w(TAG, 'SettingsPresenter getInstance!');
      ArrangeContactsPresenter.sInstance = new ArrangeContactsPresenter();
    }
    return ArrangeContactsPresenter.sInstance;
  }

  // 查询Raw_contacts表联系人数量
  public getAllRawContactSizeAsync(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('getAllRawContactSize', undefined, (result: CountRawContact) => {
          AppStorage.setOrCreate('rawContactCount', result.count)
          HiLog.w(TAG, 'getAllRawContactSize: total:' + result.count);
          resolve(true);
        })
    });
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  /**
   * 合并联系人，选择重复联系人
   * 初始化联系人列表
   * @param callback
   * @param isOnlyQuery
   */
  initContactList(callback: Function) {
    // 不是收藏
    let favoriteForm: Record<string, number | string> = {
      'favorite': -1,
      'editContact': 0
    }
    favoriteForm.pageTag = 'arrange';
    let data: Record<string, Context | string> = {
      'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      'favoriteForm': JSON.stringify(favoriteForm)
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllContactWithPhoneNumbers', data,
        (resultList: ContactInfoGetParamsInCallback) => {
          HiLog.i(TAG, 'initContactsList resultList success. length:' + resultList.contactList.length);
          let listTemp: ContactVo[] = [];
          if (!ArrayUtil.isEmpty(resultList.contactList)) {
            for (let element of resultList.contactList) {
              element.name.fullName = element.emptyNameData;
              element.name.namePrefix = element.namePrefix;
              element.name.nameSuffix = element.nameSuffix;
              if (element.phoneNumbers != null && element.phoneNumbers.length > 0) {
                element.phoneNumbers.forEach(childEle => {
                  childEle.checked = false;
                  childEle.labelName = this.getPhoneLabelNameById(childEle.numType, childEle.phoneNumber) as Resource;
                });
                listTemp.push(element);
              }
            }
          } else {
            HiLog.e(TAG, 'select contact list is empty!');
          }
          HiLog.i(TAG, 'initContactsList listTemp length:' + listTemp.length);
          this.contactList = listTemp;
          HiLog.i(TAG, 'initContactsList contactList length:' + this.contactList.length);
          this.queryRepeatContacts(0, callback);
        });
  }

  phonenumberFormat(value: string): string {
    if (value) {
      const matches = new RegExp('^(\\d{3})(\\d{4})(\\d{4})$').exec(value);
      if (matches) {
        return matches[1] + '\xa0' + matches[2] + '\xa0' + matches[3];
      }
    }
    return value;
  }

  getPhoneLabelNameById(phoneLabelId: string, phoneNumber: string) {
    let labelName: string | Resource | null = null;
    switch (Number.parseInt(phoneLabelId, 10)) {
      case 1:
        labelName = this.phonenumberFormat(phoneNumber);
        break;
      case 2:
        labelName = $r('app.string.phone_type_home_expansion', phoneNumber);
        break;
      case 3:
        labelName = $r('app.string.phone_type_work_expansion', phoneNumber);
        break;
      case 4:
        labelName = $r('app.string.phone_type_fax_work_expansion', phoneNumber);
        break;
      case 5:
        labelName = $r('app.string.phone_type_fax_home_expansion', phoneNumber);
        break;
      case 6:
        labelName = $r('app.string.phone_type_pager_expansion', phoneNumber);
        break;
      case 7:
        labelName = $r('app.string.phone_type_other_expansion', phoneNumber);
        break;
      case 12:
        labelName = $r('app.string.phone_type_main_expansion', phoneNumber);
        break;
      case 99:
      case 10000:
        labelName = $r('app.string.phone_type_custom_expansion', phoneNumber);
        break;
      default:
        HiLog.w(TAG, `getPhoneLabelNameById, phoneLabelId: ${phoneLabelId}`);
        break;
    }
    return labelName;
  }

  goSelect() {
    DynamicLoader.getInstance().fire(DynamicLoader.SELECT_REPEAT_CONTACT_PAGE, true).then(() => {
      this.pathInfos?.pushPathByName('SelectRepeatContact', '');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'goSelect error: ', error.message);
    });
  }

  repeatListAddData(repeatContactMap: HashMap<string, RepeatContactVo>, idsList: string[][][], count: number,) {
    this.repeatList = []
    if (this.contactList.length > 0) {
      let contactIndex = 0;
      this.contactList.forEach(contactVo => {
        contactVo.displayName = contactVo.displayName.replace(regEx, '').replace(regExp, '').toUpperCase()
        if (repeatContactMap.hasKey(contactVo.displayName)) {
          repeatContactMap.get(contactVo.displayName).add(contactVo);
        } else {
          repeatContactMap.set(contactVo.displayName, new RepeatContactVo([contactVo], contactIndex++))
        }
      });
      repeatContactMap.forEach((value: RepeatContactVo) => {
        if (value.contactList.length > 1) {
          // auto
          if (count == 0) {
            let ids = this.compare(value.contactList);
            if (ids.length > 0) {
              idsList.push(ids);
            }
          }
          this.repeatList.push(value);
        }
      })
    }
  }

  /**
   *
   * @param count
   * @param callback
   * @param isOnlyQuery
   */
  queryRepeatContacts(count: number, callback: Function) {
    HiLog.w(TAG, 'getRepeatContactList start!')
    let repeatContactMap: HashMap<string, RepeatContactVo> = new HashMap();
    HiLog.w(TAG, 'getRepeatContactList contactList length is :' + this.contactList.length)
    let idsList: string[][][] = [];
    this.repeatListAddData(repeatContactMap, idsList, count)
    HiLog.w(TAG, 'getRepeatContactList is succeed! repeatList : ' + this.repeatList.length)
    callback(idsList)
  }

  compare(contactList: ContactVo[]): string[][] {
    let params: string[][] = [];
    let selectedIds: HashSet<string> = new HashSet();
    for (let i = 0; i < contactList.length; i++) {
      const contactI = contactList[i];
      let hasSamePhoneNumbersByIds: string[] = [];
      if (selectedIds.has(contactI.contactId)) {
        continue;
      }
      for (let j = i + 1; j < contactList.length; j++) {
        const contactJ = contactList[j];
        if (selectedIds.has(contactJ.contactId) || contactJ.phoneNumbers.length != contactI.phoneNumbers.length) {
          continue;
        }
        // 同姓名联系人（displayName） 拥有完全相同的电话号码
        let hasSamePhoneNumbers = true;
        let phoneNumberSet: HashSet<string> = new HashSet();
        contactI.phoneNumbers.forEach(value => {
          phoneNumberSet.add(value.phoneNumber.replace(reg, ''));
        })
        contactJ.phoneNumbers.forEach(value => {
          if (!phoneNumberSet.has(value.phoneNumber.replace(reg, ''))) {
            hasSamePhoneNumbers = false;
          }
        })
        if (hasSamePhoneNumbers) {
          hasSamePhoneNumbersByIds.push(contactJ.contactId);
          selectedIds.add(contactJ.contactId);
        }
      }
      if (hasSamePhoneNumbersByIds.length != 0) {
        hasSamePhoneNumbersByIds.push(contactI.contactId);
        selectedIds.add(contactI.contactId);
        hasSamePhoneNumbersByIds.reverse();
        params.push(hasSamePhoneNumbersByIds);
      }
    }
    return params;
  }

  arrange() {
    HiLog.w(TAG, 'arrange start!');
    let repeatContactIds: string[][] = [];
    let allContactIds: string[] = [];

    this.selectedRepeatContacts.forEach((repeatContactVo: RepeatContactVo) => {
      let contactIds: string[] = []
      repeatContactVo.contactList.forEach((contactVo) => {
        contactIds.push(contactVo.contactId);
        allContactIds.push(contactVo.contactId);
      })
      repeatContactIds.push(contactIds);
    });
    HiLog.w(TAG, `arrange repeatContactIds: ${JSON.stringify(repeatContactIds)}`);
    assembleLogUtils('contact_arrange', { ids: allContactIds, operationScenario: 'manul contact_arrange' }).then(() => {
      manualMergeDuplicateContactsByUrl(
        repeatContactIds, ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), () => {
        if (this.mergeContactProgressTask > 0) {
          clearTimeout(this.mergeContactProgressTask);
          this.mergeContactProgressTask = -1;
        }
        let eventData: emitter.EventData = {
          data: {
            'percent': 100,
            'number': 1,
          }
        }
        let innerEvent: emitter.InnerEvent = {
          eventId: EmitterConstant.MERGE_EVENT_ID,
          priority: emitter.EventPriority.HIGH
        }
        emitter.emit(innerEvent, eventData);
      });
    });

    this.updateMergeContactsProgress(repeatContactIds.length, 1);

    // 将本次合并的联系人 从列表中去除
    this.getUnmergedContacts(allContactIds);
  }

  updateMergeContactsProgress(repeatCcount: number, index: number) {
    this.mergeContactProgressTask = setTimeout(() => {
      let percent = Math.floor(100 / repeatCcount) * index;
      let eventData: emitter.EventData = {
        data: {
          'percent': percent > 99 ? 99 : percent,
          'number': 1,
        }
      }
      let innerEvent: emitter.InnerEvent = {
        eventId: EmitterConstant.MERGE_EVENT_ID,
        priority: emitter.EventPriority.HIGH
      }
      emitter.emit(innerEvent, eventData);

      if (percent < 99) {
        this.updateMergeContactsProgress(repeatCcount, ++index);
      }
    }, 1000)
  }

  onDeleteConfirm(item: string[]) {
    HiLog.i(TAG, 'onDeleteConfirm !!! ');
    const contactIdParam: ContactIdsParam = {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      ids: item
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteContactByIds', contactIdParam, (result: number | undefined) => {
        SmsManagerUtils.notifyMmsWhenDeleteContact(contactIdParam.ids.map(Number), result === 0 ? 0 : -1);
        if (result) {
          HiLog.w(TAG, 'deleteContactById error:' + result)
        }
      });
  }

  getUnmergedContacts(allContactIds: string[]) {
    HiLog.i(TAG, 'enter getUnmergedContacts');
    let repeatTemp: RepeatContactVo[] = []
    this.repeatList.forEach(repeatContactVo => {
      let temp = repeatContactVo.contactList.find((contactVo) => {
        return allContactIds.indexOf(contactVo.contactId) != -1
      })
      if (!temp) {
        repeatTemp.push(repeatContactVo)
        return;
      }
    })
    this.repeatList = repeatTemp
    this.repeatDataSource?.refresh([]);
    this.selectedRepeatContacts.clear();
  }

  getAllAccount(callback?: Function) {
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllAccount', undefined, (result: AccountVo[]) => {
        HiLog.i(TAG, 'getAllAccount length:' + result.length)
        if (ObjectUtil.isEmpty(result)) {
          HiLog.w(TAG, 'getAllAccount error empty')
        }
        if (callback) {
          callback(result);
        }
      });
  }

  getAllAccountAndContactSize(callback?: Function) {
    this.total = 0;
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllAccount', undefined, (result: AccountVo[]) => {
        HiLog.i(TAG, 'getAllAccount length:' + result.length)
        if (ObjectUtil.isEmpty(result)) {
          HiLog.w(TAG, 'getAllAccount error empty')
        }
        this.accountList = result;
        this.accountList.forEach(accountVo => {
          this.getContactSizeByAccountId(accountVo.accountId)
        })
        if (callback) {
          callback(this.accountList.length);
        }
      });
  }

  getContactSizeByAccountId(accountId: string) {
    let param: LooseObject = {
      accountId: accountId
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactSize', param, (result: number) => {
        HiLog.i(TAG, 'getContactSize length:' + result)
        this.total += result;
        this.accountSizeMap.set(accountId, result);
      });
  }

  getAccountNameList() {
    HiLog.i(TAG, 'getAllAccount length:' + this.accountList.length)
    let accountNameList: string[] = []
    this.accountList.forEach((item: AccountVo) => {
      accountNameList.push(item.accountName);
    })
    return accountNameList;
  }

  onClickAll() {
    HiLog.w(TAG, `onClickAll selectedRepeatContacts length: ${this.selectedRepeatContacts.length
    }, repeatList length: ${this.repeatList.length}`);
    let isSelectedAll = this.selectedRepeatContacts.length === this.repeatList.length;
    if (isSelectedAll) {
      // 取消全选
      this.selectedRepeatContacts.clear();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, this.repeatList.length);
    } else {
      // 全选
      this.repeatList.forEach((item) => {
        this.selectedRepeatContacts.set(item.repeatId, item);
      })
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, this.repeatList.length);
    }
    emitter.emit(ArrangeContactsPresenter.ARRANGE_CONTACT_ITEM_CHECKED);
    this.selectCount = this.selectedRepeatContacts.length;
    this.refreshUI();
  }

  // 单选checkbox
  onItemClick(item: RepeatContactVo, index: number) {
    HiLog.w(TAG, `onItemClick contactId: ${item.repeatId}, index: ${index}`);
    if (this.selectedRepeatContacts.hasKey(item.repeatId)) {
      this.selectedRepeatContacts.remove(item.repeatId);
    } else {
      this.selectedRepeatContacts.set(item.repeatId, item);
    }
    let eventData: emitter.EventData = {
      data: { 'repeatId': item.repeatId }
    };
    emitter.emit(ArrangeContactsPresenter.ARRANGE_CONTACT_ITEM_CHECKED, eventData);
    this.selectCount = this.selectedRepeatContacts.length;
    this.refreshUI();
  }

  resetInitialIndex(firstIndex: number) {
    HiLog.i(TAG, 'resetInitialIndex firstIndex is %s', firstIndex.toString());
    this.initialIndex = firstIndex;
  }

  restoreContacts(startCallBack: Function, completeCallBack: Function) {
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('restoreContacts', {}, (success: boolean) => {
        HiLog.i(TAG, `start restoreContacts success: ${success}`);
        startCallBack?.(success);
        if (!success) {
          return;
        }
        // 注册监听恢复结果的回调
        this.registerRestoreObs(startCallBack, completeCallBack);

        // 恢复超时，恢复失败
        // register timeout here
        this.restoreTimeout = setTimeout(() => {
          HiLog.i(TAG, 'restore contacts timeout');
          completeCallBack?.(false, $r('app.string.contacts_restore_failed'));
          ContactRepository.getInstance().unRegisterRestoreContactsDataChangeObs();
          this.restoreTimeout = -1;
        },
          restoreContactsMaxTime);
      });
  }

  registerRestoreObs(startCallBack: Function, completeCallBack: Function) {
    ContactRepository.getInstance().registerRestoreContactsDataChangeObs((retType: RestoreResultType) => {
      HiLog.i(TAG, `restoreContacts retType: ${retType}`);
      switch (retType) {
        // 无可恢复的联系人
        case RestoreResultType.NO_CONTACTS_TO_RESTORE: {
          startCallBack?.(false);
          break;
        }
        // 恢复失败
        case RestoreResultType.RESTORE_FAILED: {
          completeCallBack?.(false, $r('app.string.contacts_restore_failed'));
          break;
        }
        // 恢复成功
        case RestoreResultType.RESTORE_SUCCESS: {
          completeCallBack?.(true, $r('app.string.contacts_restore_success'));
          break;
        }
        // 恢复失败
        default: {
          completeCallBack?.(false, $r('app.string.contacts_restore_failed'));
          break;
        }
      }
      ContactRepository.getInstance().unRegisterRestoreContactsDataChangeObs();
      if (this.restoreTimeout != -1) {
        clearTimeout(this.restoreTimeout);
        this.restoreTimeout = -1;
      }
    });
  }
}

export interface ContactIdsParam {
  context: common.UIAbilityContext,
  ids: string[],
  operationScenario?: string
  displayName?: string
  phoneNumbers?: string[]
}

export class RepeatContactVo {
  public contactList: ContactVo[] = [];
  public contactIndex: number = -1;
  public repeatId: string = '';

  constructor(contactList: ContactVo[], contactIndex?: number) {
    this.contactList = contactList;
    this.repeatId = this.contactList[0]?.contactId ?? '';
    if (contactIndex && contactIndex > -1) {
      this.contactIndex = contactIndex;
    }
  }

  add(contactVo: ContactVo) {
    this.contactList.push(contactVo);
    this.repeatId += `-${contactVo.contactId}`;
  }
}