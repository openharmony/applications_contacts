/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import GroupMemberDataSource from '../../model/bean/GroupMemberDataSource';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { SendMessageParams } from '../../../../../../entry/src/main/ets/model/type/ContactParams';
import { ContactVo, MemberInfo } from '../../model/bean/ContactVo';
import { PhoneNumberInterface } from '../../model/type';
import { ResourceUtil } from '../../util/ResourceUtil';
import prompt from '@ohos.promptAction';
import { numFormat } from '../../util/NumFormat';

interface EventInterface {
  contactIndex: number
  numberIndex: number
  checked: boolean
}

const TAG = 'SelectMemberSendMessagePresenter ';
const MAXIMUM_SELECT_CONTACT = 100;
export default class SelectMemberSendMessagePresenter {
  public pathInfos?: NavPathStack;
  private static sInstance: SelectMemberSendMessagePresenter;
  public groupMemberDataSource: GroupMemberDataSource = new GroupMemberDataSource()
  public groupId: number = 0
  public memberList: Array<MemberInfo> = [];
  public selectedCount: number = 0
  public isSelectAll: boolean = false
  public isSelectNumber: boolean = false
  public contactsCount: number = 0
  public contactsTotal: number = 0
  public selectedNumberMap: Map<number, Record<string, string | number>> = new Map();

  public static getInstance(): SelectMemberSendMessagePresenter {
    if (SelectMemberSendMessagePresenter.sInstance == null) {
      SelectMemberSendMessagePresenter.sInstance = new SelectMemberSendMessagePresenter();
    }
    return SelectMemberSendMessagePresenter.sInstance;
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear start.');
    this.initParams();
    this.selectedNumberMap.clear();
    this.initContactsList();
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageCover start.');
  }

  initParams() {
    this.groupId = this.pathInfos?.getParamByIndex(this.pathInfos?.size() - 1) as number;
  }

  back() {
    HiLog.i(TAG, 'back.');
    this.pathInfos?.pop();
  }

  getPhoneLabelNameById(phoneLabelId: string, phoneNumber: string, isPrimary?: boolean) {
    let labelName: Resource | null = null;
    let phoneNameString = phoneNumber;
    if (isPrimary) {
      phoneNameString = ResourceUtil.getStringByResource($r("app.string.default_value")) + "  " + phoneNumber
    }
    switch (Number.parseInt(phoneLabelId, 10)) {
      case 1:
        labelName = $r('app.string.phone_type_mobile_expansion', phoneNameString);
        break;
      case 2:
        labelName = $r('app.string.phone_type_home_expansion', phoneNameString);
        break;
      case 3:
        labelName = $r('app.string.phone_type_work_expansion', phoneNameString);
        break;
      case 4:
        labelName = $r('app.string.phone_type_fax_work_expansion', phoneNameString);
        break;
      case 5:
        labelName = $r('app.string.phone_type_fax_home_expansion', phoneNameString);
        break;
      case 6:
        labelName = $r('app.string.phone_type_pager_expansion', phoneNameString);
        break;
      case 7:
        labelName = $r('app.string.phone_type_other_expansion', phoneNameString);
        break;
      case 12:
        labelName = $r('app.string.phone_type_main_expansion', phoneNameString);
        break;
      case 99:
      case 10000:
        labelName = $r('app.string.phone_type_custom_expansion', phoneNameString);
        break;
      default:
        break;
    }
    return labelName;
  }

  initContactsList() {
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('findMemberByPhoneIsNotNull', {
        groupId: this.groupId,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      },
        (resultList: ContactVo[]) => {
          HiLog.i(TAG, 'initContactsList resultList success.');
          let listTemp: MemberInfo[] = [];
          this.memberList = [];
          if (!ArrayUtil.isEmpty(resultList)) {
            if (resultList.length > MAXIMUM_SELECT_CONTACT) {
              this.maximumSelectedContactShow(); // 弹toast
            }
            for (let i = 0; i < resultList.length; i++) {
              const element = resultList[i];
              element.name.fullName = element.emptyNameData;
              let phoneTemp: PhoneNumberInterface[] = [];

              if (element.phoneNumbers != null && element.phoneNumbers.length > 0) {
                if (i < MAXIMUM_SELECT_CONTACT) {
                  let hasPrimary = false
                  element.phoneNumbers.forEach((childEle, index) => {
                    childEle.labelName = this.getPhoneLabelNameById(childEle.numType, childEle.phoneNumber, childEle.primary) as Resource;
                    if (childEle.primary) {
                      hasPrimary = true
                      childEle.checked = true;
                      this.addOrUpdateSelectedNumberMap(element.phoneNumbers[index].phoneNumber,
                        element.name.fullName, element.contactId);
                      phoneTemp.unshift(childEle)
                    } else {
                      childEle.checked = false;
                      phoneTemp.push(childEle)
                    }
                  });
                  if (!hasPrimary) {
                    element.phoneNumbers[0].checked = true;
                    this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber,
                      element.name.fullName, element.contactId);
                  }
                } else {
                  // 超出MAXIMUM_SELECT_CONTACT之后的，全部checked=false
                  element.phoneNumbers.forEach(childEle => {
                    childEle.checked = false;
                    childEle.labelName = this.getPhoneLabelNameById(childEle.numType, childEle.phoneNumber, childEle.primary) as Resource;
                    phoneTemp.push(childEle);
                  });
                }
                element.phoneNumbers = phoneTemp;
                listTemp.push({
                  member: element, checked: false
                });
              }
            }
            this.isSelectNumber = true;
          } else {
            this.isSelectNumber = false;
            HiLog.e(TAG, 'select contact list is empty!');
          }
          this.memberList = listTemp;
          this.groupMemberDataSource.refresh(this.memberList);
          this.contactsTotal = Math.min(MAXIMUM_SELECT_CONTACT, this.memberList.length);
          this.contactsCount = Math.min(MAXIMUM_SELECT_CONTACT, this.memberList.length);
          this.refreshPageMessage()
        });
  }

  maximumSelectedContactShow() {
    try {
      prompt.showToast({
        message: $r('app.string.maximum_selected_contacts', numFormat(MAXIMUM_SELECT_CONTACT)),
        duration: 1000
      });
    } catch (err) {
      HiLog.e(TAG, 'maximumSelectedContactShow, prompt.showToast err: ' + err?.message + ', stack: ' + err?.stack);
    }
  }

  isSelectContactExceededLimit(): boolean {
    let isExceeded: boolean = false;
    if (this.selectedNumberMap.size >= MAXIMUM_SELECT_CONTACT) {
      this.maximumSelectedContactShow();
      isExceeded = true;
    }
    return isExceeded;
  }

  onContactItemClicked(index: number, indexChild: number) {
    HiLog.i(TAG, 'onContactItemClicked index is ' + index);
    HiLog.i(TAG, 'onContactItemClicked indexChild is ' + indexChild);
    let contact = this.memberList[index].member;
    if (contact !== undefined) {
      let event: EventInterface = {
        contactIndex: index,
        numberIndex: indexChild,
        checked: !contact.phoneNumbers[indexChild].checked
      }
      this.checkStateChange(index, event);
    }
  }

  checkStateChange(index: number, event: EventInterface) {
    HiLog.i(TAG, `checkStateChange event contactIndex: ${event?.contactIndex}, numberIndex: ${event?.numberIndex},
     checked: ${event?.checked}`);
    let contactId = '';
    contactId = this.memberList[index].member.contactId;
    this.checkContactsCount(event, contactId);
  }

  checkIfNeedCount(contact: MemberInfo): boolean {
    if (contact.member.phoneNumbers.length > 0) {
      for (let index = 0; index < contact.member.phoneNumbers.length; index++) {
        const element = contact.member.phoneNumbers[index];
        if (element.checked) {
          return true;
        }
      }
    }
    return false;
  }

  checkContactsCount(event: EventInterface, contactId: string) {
    HiLog.i(TAG, 'checkContactsCount start');
    this.memberList.forEach(element => {
      if (contactId == element.member.contactId) {
        if (event.checked) {
          if (this.isSelectContactExceededLimit()) {
            return;
          }
          if (!this.checkIfNeedCount(element)) {
            this.contactsCount++;
          }
          element.member.phoneNumbers[event.numberIndex].checked = true;
          this.addOrUpdateSelectedNumberMap(element.member.phoneNumbers[event.numberIndex].phoneNumber,
            element.member.name.fullName, element.member.contactId);
        } else {
          element.member.phoneNumbers[event.numberIndex].checked = false;
          if (!this.checkIfNeedCount(element)) {
            this.contactsCount--;
          }
          this.deleteSelectedNumber(element.member.phoneNumbers[event.numberIndex].phoneNumber,
            element.member.contactId);
        }
      }
    })
    this.groupMemberDataSource.refresh(this.memberList);
    this.refreshPageMessage();
  }

  deleteSelectedNumber(number: string, keyOrId: string) {
    if (StringUtil.isEmpty(number)) {
      return;
    }
    let regex: RegExp = new RegExp('\\s+', 'g');
    let key = Number.parseInt(keyOrId + number.replace(regex, ''));
    this.selectedNumberMap.delete(key);
  }

  addOrUpdateSelectedNumberMap(number: string, name: string, keyOrId: string) {
    if (StringUtil.isEmpty(number)) {
      return;
    }
    let regex: RegExp = new RegExp('\\s+', 'g');
    let key = Number.parseInt(keyOrId + number.replace(regex, ''))
    let value: Record<string, string | number> = {
      'name': name,
      'number': number.replace(regex, ''),
      'id': parseInt(keyOrId),
      'contactId': keyOrId.toString()
    }
    this.selectedNumberMap.set(key, value);
  }

  clickSelectAll() {
    if ((this.contactsCount === this.contactsTotal && this.contactsCount != 0) ||
      this.selectedCount === MAXIMUM_SELECT_CONTACT) {
      // 取消全选逻辑
      this.memberList.forEach((item) => {
        for (let i = 0; i < item.member.phoneNumbers.length; i++) {
          if (item.member.phoneNumbers[i].checked) {
            item.member.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(item.member.phoneNumbers[i].phoneNumber, item.member.contactId);
          }
        }
      })
      this.contactsCount = 0;
    } else {
      let remaining = MAXIMUM_SELECT_CONTACT - this.selectedNumberMap.size;
      this.memberList.forEach((item) => {
        if (remaining <= 0) {
          return;
        }
        // 检查该用户是否已经有选中的手机号
        let hasSelected = item.member.phoneNumbers.some((phone) => phone.checked);
        if (!hasSelected) {
          // 选第一个未选中的手机号
          let firstPhone = item.member.phoneNumbers.find((phone) => !phone.checked);
          if (firstPhone) {
            firstPhone.checked = true;
            this.addOrUpdateSelectedNumberMap(item.member.phoneNumbers[0].phoneNumber,
              item.member.name.fullName, item.member.contactId);
            remaining--;
          }
        }
      })
      this.contactsCount = this.contactsTotal;
    }
    this.groupMemberDataSource.refresh(this.memberList);
    this.refreshPageMessage();
  }

  refreshPageMessage() {
    HiLog.i(TAG, 'refreshPageMessage start !')
    this.selectedCount = this.selectedNumberMap.size;
    if (this.selectedCount === MAXIMUM_SELECT_CONTACT) {
      this.isSelectAll = true;
    } else {
      this.isSelectAll = (this.contactsCount === this.contactsTotal) && this.contactsCount != 0;
    }
  }

  dealSelectedContactsMap(element: MemberInfo): void {
    if (!element.member.phoneNumbers[0].checked) {
      element.member.phoneNumbers[0].checked = true;
      this.addOrUpdateSelectedNumberMap(element.member.phoneNumbers[0].phoneNumber,
        element.member.name.fullName, element.member.contactId);
    }
  }

  sendMessage() {
    let params: SendMessageParams[] = [];
    this.selectedNumberMap.forEach((value) => {
      params.push(new SendMessageParams(StringUtil.removeSpace(value.number.toString()),
        value.number.toString(), value.name.toString()));
    });
    PhoneNumber.groupSendMessage(params);
  }
}