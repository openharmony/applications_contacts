/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import {
  ContactInfoGetParamsInCallback,
  SendMessageParams
} from '../../../../../../entry/src/main/ets/model/type/ContactParams';
import { ContactVo, MemberInfo } from '../../model/bean/ContactVo';
import { ResourceUtil } from '../../util/ResourceUtil';
import AlphabetIndexerPresenter from '../contact/alphabetindex/AlphabetIndexerPresenter';
import BatchSelectContactSource from '../../model/bean/BatchSelectContactSource';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import ContactListDataSource from '../../model/bean/ContactListDataSource';
import { Constants } from '../../data/Constants';
import { PhoneNumberInterface } from '../../model/type';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import TraceConstants from '../../../../../../common/src/main/ets/TraceConstants';
import prompt from '@ohos.promptAction';
import { numFormat } from '../../util/NumFormat';
import { emitter } from '@kit.BasicServicesKit';
import TextUtils from '../../../../../../common/src/main/ets/util/TextUtils';

interface EventInterface {
  contactIndex: number
  numberIndex: number
  checked: boolean
}

const TAG = 'IntelligenceGroupSelectMemSendMsgPresenter ';
const MAXIMUM_SELECT_CONTACT = 100;
const DURATION = 1000
export default class IntelligenceGroupSelectMemSendMsgPresenter {
  public pathInfos?: NavPathStack;
  private static sInstance: IntelligenceGroupSelectMemSendMsgPresenter;
  public static INTELLIGENCE_GROUP_SELECT_SENDMSG_CHECKED = 'IntelligenceGroupSelectMemSendMsgChecked';
  public groupName: string = '';
  public categoryIndex: string = '';
  public categoryGroupType: string = '';
  public contactsList: Array<ContactVo> = [];
  public selectedCount: number = 0
  public isSelectAll: boolean = false
  public isSelectNumber: boolean = false
  public contactsCount: number = 0
  public contactsTotal: number = 0
  public selectedNumberMap: Map<number, Record<string, string | number>> = new Map();
  public alphabetIndexPresenter: AlphabetIndexerPresenter = new AlphabetIndexerPresenter();
  public initialIndex: number = 0;
  public sceillOnlenth: number = 0;
  public selectAll: string = ResourceUtil.getStringByResource($r('app.string.select_all'));
  public contactsSource: BatchSelectContactSource = new BatchSelectContactSource();
  public inputKeyword: string = Constants.EMTPY_STR;
  public updateToolbar: AddSelectMemSendMsgUpdateToolbar = {
    updateToolbar: (): void => {
    },
  };
  public addMessage: Resource = $r('app.string.add')
  public icSelectAll: Resource = $r('sys.symbol.checkmark_square_on_square');
  public allSelectMessage: Resource = $r('app.string.select_all');
  public toolBarTextColor: Resource = $r('app.color.skin_icon_emphasize');
  // 查询数据库标记位,并发控制，同一时间只能有一次查询
  private isQueryIntelligenceGroupContactListDoingForMsg: boolean = false;

  public static getInstance(): IntelligenceGroupSelectMemSendMsgPresenter {
    if (IntelligenceGroupSelectMemSendMsgPresenter.sInstance == null) {
      IntelligenceGroupSelectMemSendMsgPresenter.sInstance = new IntelligenceGroupSelectMemSendMsgPresenter();
    }
    return IntelligenceGroupSelectMemSendMsgPresenter.sInstance;
  }

  aboutToAppear() {
    this.alphabetIndexPresenter.clearCache();
    HiLog.i(TAG, `send msg aboutToAppear:${this.groupName?.length},${this.categoryIndex},${this.categoryGroupType}`);
    this.selectedNumberMap.clear();
    if (this.isQueryIntelligenceGroupContactListDoingForMsg) {
      HiLog.i(TAG, `aboutToAppear query is doing.`);
      return;
    } else {
      this.isQueryIntelligenceGroupContactListDoingForMsg = true;
    }
    this.queryIntelligenceGroupContactsForMsg();
  }

  /**
   * 页面从后台切换到前台查询一次最新数据
   */
  async setPageShow() {
    if (this.isQueryIntelligenceGroupContactListDoingForMsg) {
      HiLog.i(TAG, `setPageShow query is doing.`);
      return;
    } else {
      this.isQueryIntelligenceGroupContactListDoingForMsg = true;
    }
    HiLog.i(TAG, `send msg setPageShow:${this.groupName?.length},${this.categoryIndex},${this.categoryGroupType}`);
    this.queryIntelligenceGroupContactsForMsg();
  }

  /**
   * 重置数据
   */
  resetData() {
    this.isQueryIntelligenceGroupContactListDoingForMsg = false;
  }

  /**
   * 根据分类名称查询发短信联系人名称
   */
  async queryIntelligenceGroupContactsForMsg() {
    if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_COMPANY_CATEGORYTYPE) {
      this.queryContactsByOriganizationForSendMsg(this.groupName);
    } else if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_CITY_CATEGORYTYPE) {
      this.queryContactsByCityForSendMsg(this.groupName);
    } else if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_CONTACT_TIME_CATEGORYTYPE) {
      this.queryContactsByLatestTimeForSendMsg(this.categoryIndex);
    } else {
      this.isQueryIntelligenceGroupContactListDoingForMsg = false;
      HiLog.e(TAG, `send msg categoryGroupType invalid:${this.groupName},${this.categoryIndex}`);
    }
  }

  /**
   * msg page query contact by company
   *
   * @param origanization company
   */
  queryContactsByOriganizationForSendMsg(origanization: string): void {
    HiLog.i(TAG, `queryContactsByOriganizationForSendMsg start,${TextUtils.getMaskString(origanization)}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG_ID);

    let workerWrapper: WorkerWrapper | undefined =
      ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName);
    if (!workerWrapper) {
      HiLog.e(TAG, `The mDataWorker is null or undefined.`)
      this.isQueryIntelligenceGroupContactListDoingForMsg = false;
      return;
    }

    workerWrapper.sendRequest(
      'intelligenceGroupQueryContactsForSendMsgByOrganization',
      {
        origanization: origanization,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      },
      (resultList: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryContactsByOriganizationForSendMsg ${resultList?.contactList?.length}.`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG_ID);
        let listTemp: ContactVo[] = [];
        if (!ArrayUtil.isEmpty(resultList.contactList)) {
          listTemp = this.initContactsList(resultList);
        } else {
          HiLog.e(TAG, 'select contact list is empty!');
        }
        this.isQueryIntelligenceGroupContactListDoingForMsg = false;
        this.contactsList = listTemp;
        this.contactsSource.refresh(this.contactsList);
        this.contactsTotal = Math.min(MAXIMUM_SELECT_CONTACT, this.contactsList.length);
        this.contactsCount = Math.min(MAXIMUM_SELECT_CONTACT, this.contactsList.length);
        this.alphabetIndexPresenter.initContactList(this.contactsList);
        this.alphabetIndexPresenter.initAlphabetIndex(resultList.alphabetIndex);
        this.refreshPageMessage();
      });
  }

  /**
   * msg page query contact by city
   *
   * @param city home area
   */
  queryContactsByCityForSendMsg(city: string): void {
    HiLog.i(TAG, `queryContactsByCityForSendMsg start,${TextUtils.getMaskString(city)}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG_ID);

    let workerWrapper: WorkerWrapper | undefined =
      ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName);
    if (!workerWrapper) {
      HiLog.e(TAG, `The mDataWorker is null or undefined.`)
      this.isQueryIntelligenceGroupContactListDoingForMsg = false;
      return;
    }

    workerWrapper.sendRequest(
      'intelligenceGroupQueryContactsForSendMsgByCity',
      {
        location: city,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      },
      (resultList: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryContactsByCityForSendMsg ${resultList?.contactList?.length}.`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG_ID);
        let listTemp: ContactVo[] = [];
        if (!ArrayUtil.isEmpty(resultList.contactList)) {
          listTemp = this.initContactsList(resultList);
        } else {
          HiLog.e(TAG, 'queryContactsByCityForSendMsg empty!');
        }
        this.isQueryIntelligenceGroupContactListDoingForMsg = false;
        this.contactsList = listTemp;
        this.contactsSource.refresh(this.contactsList);
        this.contactsTotal = Math.min(MAXIMUM_SELECT_CONTACT, this.contactsList.length);
        this.contactsCount = Math.min(MAXIMUM_SELECT_CONTACT, this.contactsList.length);
        this.alphabetIndexPresenter.initContactList(this.contactsList);
        this.alphabetIndexPresenter.initAlphabetIndex(resultList.alphabetIndex);
        this.refreshPageMessage();
      });
  }

  initContactsList(resultList: ContactInfoGetParamsInCallback): ContactVo[] {
    if (resultList.contactList.length > MAXIMUM_SELECT_CONTACT) {
      // 选择联系人数量大于100时，弹toast
      this.maximumSelectedContactShow();
    }
    let listTemp: ContactVo[] = [];
    for (let i = 0; i < resultList.contactList.length; i++) {
      const element: ContactVo = resultList.contactList[i];
      element.name.fullName = element.emptyNameData;
      element.name.namePrefix = element.namePrefix;
      element.name.nameSuffix = element.nameSuffix;
      let phoneTemp: PhoneNumberInterface[] = [];
      if (element.phoneNumbers && element.phoneNumbers.length > 0) {
        // 小于100时，全选
        if (i < MAXIMUM_SELECT_CONTACT) {
          let hasPrimary = false;
          element.phoneNumbers.forEach((childEle, index) => {
            childEle.checked = false;
            childEle.labelName =
              this.getPhoneLabelNameById(childEle.numType, childEle.phoneNumber, childEle.primary) as Resource;
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
          if (!hasPrimary && element.phoneNumbers?.length) {
            element.phoneNumbers[0].checked = true;
            this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber,
              element.name.fullName, element.contactId);
          }
        } else {
          // 超出MAXIMUM_SELECT_CONTACT之后的，全部checked=false
          element.phoneNumbers.forEach(childEle => {
            childEle.checked = false;
            childEle.labelName =
              this.getPhoneLabelNameById(childEle.numType, childEle.phoneNumber, childEle.primary) as Resource;
            phoneTemp.push(childEle);
          });
        }
        element.phoneNumbers = phoneTemp
        listTemp.push(element);
      }
    }
    return listTemp;
  }

  /**
   * msg page query contact by LatestTime
   *
   * @param contactTimeType 0 1 2 3
   */
  queryContactsByLatestTimeForSendMsg(contactTimeType: string): void {
    HiLog.i(TAG, `queryContactsByLatestTimeForSendMsg start,${contactTimeType}`);
    hiTraceMeter.startTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG,
      TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG_ID);

    let workerWrapper: WorkerWrapper | undefined =
      ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName);
    if (!workerWrapper) {
      HiLog.e(TAG, `The mDataWorker is null or undefined.`)
      this.isQueryIntelligenceGroupContactListDoingForMsg = false;
      return;
    }

    workerWrapper.sendRequest(
      'intelligenceGroupQueryContactsForSendMsgByTimestamp',
      {
        contactTimeType: contactTimeType,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      },
      (resultList: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, `queryContactsByLatestTimeForSendMsg ${resultList?.contactList?.length}.`);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG,
          TraceConstants.TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG_ID);
        let listTemp: ContactVo[] = [];
        if (!ArrayUtil.isEmpty(resultList.contactList)) {
          listTemp = this.initContactsList(resultList);
        } else {
          HiLog.e(TAG, 'queryContactsByLatestTimeForSendMsg is empty!');
        }
        this.isQueryIntelligenceGroupContactListDoingForMsg = false;
        this.contactsList = listTemp;
        this.contactsSource.refresh(this.contactsList);
        this.contactsTotal = Math.min(MAXIMUM_SELECT_CONTACT, this.contactsList.length);
        this.contactsCount = Math.min(MAXIMUM_SELECT_CONTACT, this.contactsList.length);
        this.alphabetIndexPresenter.initContactList(this.contactsList);
        this.alphabetIndexPresenter.initAlphabetIndex(resultList.alphabetIndex);
        this.refreshPageMessage();
      });
  }

  maximumSelectedContactShow() {
    try {
      prompt.showToast({
        message: $r('app.string.maximum_selected_contacts', numFormat(MAXIMUM_SELECT_CONTACT)),
        duration: DURATION
      });
    } catch (err) {
      HiLog.e(TAG, `maximumSelectedContactShow, prompt.showToast err: ${err}`);
    };
  }

  isSelectContactExceededLimit(): boolean {
    let isExceeded: boolean = false;
    if (this.selectedNumberMap.size >= MAXIMUM_SELECT_CONTACT) {
      this.maximumSelectedContactShow();
      isExceeded = true;
    }
    return isExceeded;
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageCover start.');
  }

  back() {
    HiLog.i(TAG, 'back.');
    this.pathInfos?.pop();
  }

  setUpdateToolbar(updateToolbar: AddSelectMemSendMsgUpdateToolbar) {
    this.updateToolbar = updateToolbar;
  }

  getPhoneLabelNameById(phoneLabelId: string, phoneNumber: string, isPrimary?: boolean) {
    let labelName: Resource | null = null;
    let phoneNameString = phoneNumber;
    if (isPrimary) {
      phoneNameString = ResourceUtil.getStringByResource($r('app.string.default_value')) + '  ' + phoneNumber
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
        labelName = $r('app.string.phone_type_custom_expansion', phoneNameString);
        break;
      default:
        break;
    }
    return labelName;
  }

  onContactItemClicked(index: number, indexChild: number) {
    let contact = this.contactsList[index];
    if (contact !== undefined) {
      let event: EventInterface = {
        contactIndex: index,
        numberIndex: indexChild,
        checked: !contact.phoneNumbers[indexChild].checked
      }
      this.changeContactsItemState(index, event);
    }
  }

  changeContactsItemState(index: number, event: EventInterface) {
    let contactId = '';
    contactId = this.contactsList[index]?.contactId;
    if (!StringUtil.isEmpty(contactId)) {
      this.checkContactsCount(event, contactId);
    }
  }

  /**
   * Determines whether the current contact element has an option.
   *
   * @param {Object} contact
   * @return {boolean} true，false
   */
  checkIfNeedCount(contact: ContactVo): boolean {
    if (contact.phoneNumbers.length > 0) {
      for (let index = 0; index < contact.phoneNumbers.length; index++) {
        const element = contact.phoneNumbers[index];
        if (element.checked) {
          return true;
        }
      }
    }
    return false;
  }

  checkContactsCount(event: EventInterface, contactId: string) {
    this.contactsList.forEach(element => {
      if (contactId == element.contactId) {
        if (event.checked) {
          if (this.isSelectContactExceededLimit()) {
            return;
          }
          if (!this.checkIfNeedCount(element)) {
            this.contactsCount++;
          }
          element.phoneNumbers[event.numberIndex].checked = true;
          this.addOrUpdateSelectedNumberMap(element.phoneNumbers[event.numberIndex].phoneNumber,
            element.name.fullName, element.contactId);
        } else {
          element.phoneNumbers[event.numberIndex].checked = false;
          if (!this.checkIfNeedCount(element)) {
            this.contactsCount--;
          }
          this.deleteSelectedNumber(element.phoneNumbers[event.numberIndex].phoneNumber,
            element.contactId);
        }
      }
    });
    this.contactsSource.refresh(this.contactsList);
    this.refreshPageMessage();
    emitter.emit(IntelligenceGroupSelectMemSendMsgPresenter.INTELLIGENCE_GROUP_SELECT_SENDMSG_CHECKED);
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
    if (this.contactsCount != 0 && this.contactsCount === this.contactsTotal ||
      this.selectedCount === MAXIMUM_SELECT_CONTACT) {
      this.unSelectAllContactProc();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, this.contactsTotal);
    } else {
      this.selectAllContactProc();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, this.contactsTotal);
    }
    this.contactsSource.refresh(this.contactsList);
    this.refreshPageMessage();
  }

  unSelectAllContactProc() {
    this.contactsList.forEach(element => {
      for (let i = 0; i < element.phoneNumbers.length; i++) {
        if (element.phoneNumbers[i].checked) {
          element.phoneNumbers[i].checked = false;
          this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber, element.contactId);
        }
      }
    });
    this.contactsCount = 0;
  }

  selectAllContactProc() {
    let remaining = MAXIMUM_SELECT_CONTACT - this.selectedNumberMap.size;
    this.contactsList.forEach((item) => {
      if (remaining <= 0) {
        return;
      }
      // 检查该用户是否已经有选中的手机号
      let hasSelected = item.phoneNumbers.some((phone) => phone.checked);
      if (!hasSelected) {
        // 选第一个未选中的手机号
        let firstPhone = item.phoneNumbers.find((phone) => !phone.checked);
        if (firstPhone) {
          firstPhone.checked = true;
          this.addOrUpdateSelectedNumberMap(firstPhone.phoneNumber,
            item.name.fullName, item.contactId);
          remaining--;
        }
      }
    })
    this.contactsCount = this.contactsTotal;
  }

  refreshPageMessage() {
    HiLog.i(TAG, `refreshPageMessage:${this.selectedCount},${this.contactsCount},${this.contactsTotal}`);
    this.selectedCount = this.selectedNumberMap.size;
    // 选择人数大于100时，根据选择手机号判断是否超限
    if (this.selectedCount === MAXIMUM_SELECT_CONTACT) {
      this.isSelectAll = true;
    } else {
      // 选择人数不足100时，根据选择联系人个数判断是否超限
      this.isSelectAll = (this.contactsCount === this.contactsTotal) && this.contactsCount != 0
    }

    if (this.isSelectAll) {
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square_fill');
      this.allSelectMessage = $r('app.string.unselect_all');
    } else {
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square');
      this.allSelectMessage = $r('app.string.select_all');
    }
    this.updateToolbar.updateToolbar();
  }

  dealSelectedContactsMap(element: ContactVo): void {
    if (!element.phoneNumbers[0].checked) {
      element.phoneNumbers[0].checked = true;
      this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber,
        element.name.fullName, element.contactId);
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

  resetInitialIndex(firstIndex: number) {
    HiLog.i(TAG, 'resetInitialIndex firstIndex is %s', firstIndex.toString());
    this.initialIndex = firstIndex;
  }
}


export interface AddSelectMemSendMsgUpdateToolbar {
  updateToolbar: () => void
}