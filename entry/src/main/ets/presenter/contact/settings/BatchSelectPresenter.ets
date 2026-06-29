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
import { ArrayUtil, HiLog, ObjectUtil, StringUtil } from '../../../../../../../common';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import BatchSelectContactSource from '../../../model/bean/BatchSelectContactSource';
import { ContactVo } from '../../../model/bean/ContactVo';
import { ContactInfoGetParamsInCallback } from '../../../model/type/ContactParams';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import AlphabetIndexerPresenter from '../alphabetindex/AlphabetIndexerPresenter';
import prompt from '@ohos.promptAction';
import { numFormat } from '../../../util/NumFormat';

const TAG = 'BatchSelectPresenter ';
const MAXIMUM_SELECT_CONTACT = 1000;

/**
 * Selecting a contact list
 */
export default class BatchSelectPresenter {
  // 路径信息
  public pathInfos?: NavPathStack;
  private static sInstance: BatchSelectPresenter;
  public isLimit: boolean = false;
  public countFromWantParam: number = 0;
  public editContact: number = -1;
  // Search Keyword
  public searchText: string = '';
  public contactsList: Array<ContactVo> = [];
  public contactsSource: BatchSelectContactSource = new BatchSelectContactSource();
  public contactsInfo: ContactsInfo = new ContactsInfo();
  public alphabetIndexPresenter: AlphabetIndexerPresenter = AlphabetIndexerPresenter.getInstance();
  // Selected data for the current population，key:phone number，value:name and number
  public selectedNumberMap: Map<number, Record<string, string | number>> = new Map();
  public selectCount: number = 0;
  public selectDisabled: boolean = true;
  public tabInfo: TabInfo = new TabInfo(1);
  public isSelectAll: boolean = false;
  public icSelectAll: Resource = $r('sys.symbol.checkmark_square_on_square');
  public allSelectMessage: Resource = $r('app.string.select_all');
  public allSelectTextStyle: Resource = $r('app.color.skin_icon_primary');
  public initialIndex: number = 0;
  public emptyViewText: Resource = $r('app.string.no_contacts');
  // Whether to display the search list
  public searchLayoutShow: boolean = false;
  public searchContactList: Array<ContactVo> = [];

  public static getInstance(): BatchSelectPresenter {
    if (BatchSelectPresenter.sInstance == null) {
      BatchSelectPresenter.sInstance = new BatchSelectPresenter();
    }
    return BatchSelectPresenter.sInstance;
  }

  aboutToAppear() {
    this.initParams();
    this.initContactsList();
    this.clearSelection();
  }

  aboutToDisappear() {
  }

  onPageShow() {
  }

  onPageHide() {
  }
  // init params
  initParams() {
    interface ObjInterface {
      contactCount?: number
      isLimit?: boolean
    }

    let obj: ObjInterface = this.pathInfos?.getParamByIndex(this.pathInfos?.size() - 1) as ObjInterface;

    interface ParamsInterface {
      contactCount?: number
      isLimit?: boolean
    }

    let params: ParamsInterface | undefined = AppStorage.get('params');
    if (obj) {
      if (obj.contactCount !== undefined) {
        this.countFromWantParam = obj.contactCount;
      }
      if (obj.isLimit !== undefined) {
        this.isLimit = obj.isLimit;
      }
    } else if (params !== undefined) {
      if (params.contactCount !== undefined) {
        this.countFromWantParam = params.contactCount;
      }
      if (params.isLimit !== undefined) {
        this.isLimit = params.isLimit;
      }
    }
  }

  /**
   * back cancel
   */
  backCancel() {
    this.pathInfos?.pop();
  }

  resetInitialIndex(firstIndex: number) {
    HiLog.i(TAG, 'resetInitialIndex firstIndex is %s', firstIndex.toString());
    this.initialIndex = firstIndex;
  }

  /*
   * Initializing Contact List Data
   */
  initContactsList() {
    HiLog.i(TAG, 'initContactsList start!');
    // 两个条件都是-1
    let favoriteForm: Record<string, number> = {
      'favorite': -1,
      'editContact': this.editContact
    }
    let data: Record<string, Context | string> = {
      'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      'favoriteForm': JSON.stringify(favoriteForm)
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllContactWithPhoneNumbers', data,
        (resultList: ContactInfoGetParamsInCallback) => {
          HiLog.i(TAG, 'initContactsList resultList success.');
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
                  this.initVariableSpan(element);
                });
                listTemp.push(element);
              }
            }
          } else {
            HiLog.e(TAG, 'select contact list is empty!');
          }

          this.contactsList = listTemp;
          this.contactsSource.refresh(this.contactsList);
          this.contactsInfo.contactsListTotal = this.contactsList.length;
          this.alphabetIndexPresenter.initContactList(this.contactsList);
          this.alphabetIndexPresenter.initAlphabetIndex(resultList.alphabetIndex);
        });
  }
  
  clearSelection() {
    HiLog.i(TAG, 'clearSelection start !')
    this.unSelectAllContactProc();
    this.selectedNumberMap.clear();
    this.refreshPageMessage();
  }

  // Header Count Refresh Function
  refreshPageMessage() {
    HiLog.i(TAG, 'refreshPageMessage start !')
    this.selectCount = this.selectedNumberMap.size;
    if (this.selectedNumberMap.size > 0) {
      this.selectDisabled = false;
      this.checkAllClickButtonStyle();
    } else {
      this.selectDisabled = true;
      this.isSelectAll = false;
      this.changeToUnFullSelect();
    }
  }

  /**
   * Verify the display style of the Select All button.
   */
  checkAllClickButtonStyle() {
    if (this.tabInfo.contactsCount === this.tabInfo.contactsTotal) {
      HiLog.i(TAG, 'checkAllClickButtonStyle contact select all ');
      this.changeToFullSelect();
      this.tabInfo.allClickedContacts = true;
    } else {
      HiLog.i(TAG, 'checkAllClickButtonStyle contact unselect all ');
      this.changeToUnFullSelect();
    }
  }

  changeToFullSelect() {
    this.icSelectAll = $r('sys.symbol.checkmark_square_on_square_fill');
    this.allSelectMessage = $r('app.string.unselect_all');
    this.allSelectTextStyle = $r('app.color.skin_confirm');
  }

  changeToUnFullSelect() {
    this.icSelectAll = $r('sys.symbol.checkmark_square_on_square');
    this.allSelectMessage = $r('app.string.select_all');
    this.allSelectTextStyle = $r('app.color.skin_icon_primary');
  }


  unSelectAllContactProc() {
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach((element) => {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          if (element.phoneNumbers[i].checked) {
            element.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber, element.contactId);
          }
        }
      });
    } else {
      this.contactsList.forEach(element => {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          if (element.phoneNumbers[i].checked) {
            element.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber, element.contactId);
          }
        }
      });
      this.contactsSource.refresh(this.contactsList);
    }
  }

  deleteSelectedNumber(number: string, keyOrId: string) {
    HiLog.i(TAG, 'deleteSelectedNumber keyOrId is ' + keyOrId);
    if (StringUtil.isEmpty(number)) {
      return;
    }
    let regex: RegExp = new RegExp('\\s+', 'g');
    let key = Number.parseInt(keyOrId + number.replace(regex, ''));
    this.selectedNumberMap.delete(key);
  }

  /**
   * Assign a custom attribute to prepare for later variable font searches
   *
   * @param {Object} item contacts data
   */
  initVariableSpan(item: ContactVo) {
    // Initialize Variable Names
    let matchString = StringUtil.getMatchedString(item.emptyNameData, this.searchText);
    if (StringUtil.isEmpty(matchString) || StringUtil.isEmpty(this.searchText.trim())) {
      item.name.searchTextStart = '';
      item.name.searchTextMiddle = '';
      item.name.searchTextEnd = item.emptyNameData;
    } else {
      let name = item.emptyNameData;
      let index = name.indexOf(matchString);
      item.name.searchTextStart = name.substr(0, index);
      item.name.searchTextMiddle = name.substr(index, matchString.length);
      item.name.searchTextEnd = name.substr(index + matchString.length);
    }
    // Initialize Variable Numbers
    for (let i = 0; i < item.phoneNumbers.length; i++) {
      let phoneNumber = item.phoneNumbers[i].phoneNumber;
      let matchStringPhone = StringUtil.getMatchedString(phoneNumber, this.searchText);
      if (StringUtil.isEmpty(matchStringPhone) || StringUtil.isEmpty(this.searchText.trim())) {
        item.phoneNumbers[i].startPhone = '';
        item.phoneNumbers[i].middlePhone = '';
        item.phoneNumbers[i].endPhone = phoneNumber;
      } else {
        let phoneIndex = phoneNumber.indexOf(matchStringPhone);
        item.phoneNumbers[i].startPhone = phoneNumber.substr(0, phoneIndex);
        item.phoneNumbers[i].middlePhone = phoneNumber.substr(phoneIndex, matchStringPhone.length);
        item.phoneNumbers[i].endPhone = phoneNumber.substr(phoneIndex + matchStringPhone.length);
      }
    }
  }

  getPhoneLabelNameById(phoneLabelId: string, phoneNumber: string) {
    let labelName: Resource | null = null;
    switch (Number.parseInt(phoneLabelId, 10)) {
      case 1:
        labelName = $r('app.string.phone_type_mobile_expansion', phoneNumber);
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
        labelName = $r('app.string.phone_type_custom_expansion', phoneNumber);
        break;
      default:
        break;
    }
    return labelName;
  }

  selectBatchContact() {
    this.comfirm()
  }

  comfirm() {

  }

  clickSelectAll() {
    if (this.tabInfo.contactsCount != 0 && this.tabInfo.contactsCount === this.tabInfo.contactsTotal) {
      this.tabInfo.allClickedContacts = false;
      this.unSelectAll();
    } else {
      this.tabInfo.allClickedContacts = true;
      this.selectAll();
    }

    this.refreshPageMessage();
  }

  unSelectAll() {
    this.unSelectAllContactProc();
  }

  selectAll() {
    if (this.isSelectContactExceededLimit()) {
      this.selectAllContactProc(true);
      return;
    }
    this.selectAllContactProc(false);
  }

  selectAllContactProc(limit: boolean) {
    HiLog.i(TAG, 'selectAllContactProc limit is ' + limit);
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach((element): void => this.dealSelectedContactsMap(element));
    } else {
      if (limit) {
        this.contactsList.forEach((element) => {
          if (this.selectedNumberMap.size >= MAXIMUM_SELECT_CONTACT - this.countFromWantParam) {
            return;
          }
          this.dealSelectedContactsMap(element)
        });
      } else {
        this.contactsList.forEach((element): void => this.dealSelectedContactsMap(element));
      }
      this.contactsSource.refresh(this.contactsList);
    }
    this.tabInfo.contactsCount = this.tabInfo.contactsTotal;
  }

  dealSelectedContactsMap(element: ContactVo): void {
    if (!element.phoneNumbers[0].checked) {
      element.phoneNumbers[0].checked = true;
      this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber, element.name.fullName, element.contactId);
    }
  }

  addOrUpdateSelectedNumberMap(number: string, name: string, keyOrId: string) {
    HiLog.i(TAG, 'addOrUpdateSelectedNumberMap keyOrId is ' + keyOrId);
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
    this.updataConnectedContact(number, name, keyOrId, true);
  }

  updataConnectedContact(number: string, name: string, keyOrId: string, isAdd: boolean) {
    HiLog.i(TAG, 'updataConnectedContact keyOrId is ' + keyOrId);
    this.contactsList.forEach((element) => {
      if (!ObjectUtil.isEmpty(element) && element.contactId == keyOrId) {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          let childElement = element.phoneNumbers[i];
          if (!ObjectUtil.isEmpty(childElement) &&
            childElement.phoneNumber == number && element.name?.fullName == name) {
            if (isAdd) {
              // If the original data does not contain the selected item before modification,
              // the tab count increases by 1.
              if (!this.checkIfNeedCount(element)) {
                this.tabInfo.contactsCount++;
              }
              childElement.checked = true;
              this.contactsInfo.contactsNumberCount++;
            } else {
              // After the modification,
              // the tab count decreases by 1 when the original data does not contain the selected item.
              childElement.checked = false;
              this.contactsInfo.contactsNumberCount--;
              if (!this.checkIfNeedCount(element)) {
                this.tabInfo.contactsCount--;
              }
            }
          }
        }
        return;
      }
    });
    this.contactsSource.refresh(this.contactsList);
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

  isSelectContactExceededLimit(): boolean {
    let uncheckedCount: number = 0;
    let isExceeded: boolean = false;
    this.contactsList.forEach((item) => {
      if (!item.phoneNumbers[0].checked) {
        uncheckedCount++;
      }
    });

    if ((uncheckedCount + this.countFromWantParam +
    this.selectedNumberMap.size > MAXIMUM_SELECT_CONTACT) && this.isLimit) {
      this.maximumSelectedContactShow();
      isExceeded = true;
    }
    return isExceeded;
  }

  maximumSelectedContactShow() {
    let count = MAXIMUM_SELECT_CONTACT - this.countFromWantParam;
    try {
      prompt.showToast({
        message: $r('app.string.maximum_selected_contacts', numFormat(count)),
        duration: 1000
      });
    } catch (err) {
      HiLog.e(TAG, 'maximumSelectedContactShow, prompt.showToast err: ' + err?.message + ', stack: ' + err?.stack);
    }
  }

  getEmptyText(): Resource {
    return this.emptyViewText;
  }

  onContactItemClicked(index: number, indexChild: number) {
    HiLog.i(TAG, 'onContactItemClicked index is ' + index);
    HiLog.i(TAG, 'onContactItemClicked indexChild is ' + indexChild);

    let contact = this.searchLayoutShow ? this.searchContactList[index] : this.contactsList[index];
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

    if ((this.selectedNumberMap.size + this.countFromWantParam >= MAXIMUM_SELECT_CONTACT) &&
    event.checked && this.isLimit) {
      this.maximumSelectedContactShow();
      return;
    }
    this.changeContactsItemState(index, event);
    this.refreshPageMessage();
  }

  changeContactsItemState(index: number, event: EventInterface) {
    HiLog.i(TAG, 'SHOW changeContactsItemState searchLayoutShow');
    let contactId = '';
    if (!this.contactsInfo.searchLayoutShow) {
      contactId = this.contactsList[index].contactId;
    } else {
      contactId = this.contactsInfo.searchContactList[index].contactId;
    }
    this.checkContactsCount(event, contactId);
  }

  checkContactsCount(event: EventInterface, contactId: string) {
    HiLog.i(TAG, 'SHOW checkContactsCount searchLayoutShow');
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach(element => {
        if (contactId == element.contactId) {
          if (event.checked) {
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount++;
            }
            element.phoneNumbers[event.numberIndex].checked = true;
            this.contactsInfo.contactsNumberCount++;
            this.addOrUpdateSelectedNumberMap(element.phoneNumbers[event.numberIndex].phoneNumber,
              element.name.fullName, element.contactId);
          } else {
            element.phoneNumbers[event.numberIndex].checked = false;
            this.contactsInfo.contactsNumberCount--;
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount--;
            }
            this.deleteSelectedNumber(element.phoneNumbers[event.numberIndex].phoneNumber, element.contactId);
          }
        }
      });
    } else {
      this.contactsList.forEach(element => {
        if (contactId == element.contactId) {
          if (event.checked) {
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount++;
            }
            element.phoneNumbers[event.numberIndex].checked = true;
            this.contactsInfo.contactsNumberCount++;
            this.addOrUpdateSelectedNumberMap(element.phoneNumbers[event.numberIndex].phoneNumber,
              element.name.fullName, element.contactId);
          } else {
            element.phoneNumbers[event.numberIndex].checked = false;
            this.contactsInfo.contactsNumberCount--;
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount--;
            }
            this.deleteSelectedNumber(element.phoneNumbers[event.numberIndex].phoneNumber, element.contactId);
          }
        }
      });
      this.contactsSource.refresh(this.contactsList);
    }
  }
}

export class TabInfo {
  public tabIndex: number = 0;
  public recentTotal: number = 0;
  public contactsTotal: number = 0;
  public groupsTotal: number = 0;
  // Select All Clicked
  public allClickedRecent: boolean = false;
  public allClickedContacts: boolean = false;
  public allClickedGroups: boolean = false;
  // Count on each tab page
  public recentCount: number = 0;
  public contactsCount: number = 0;
  public groupsCount: number = 0;
  public refreshGroupItemState: boolean = false;

  constructor(tabIndex: number) {
    this.tabIndex = tabIndex;
  }
}

/**
 * Data related to the contact list
 */
export class ContactsInfo {
  public searchContactList: Array<ContactVo> = [];
  // Whether to display the search page
  public searchLayoutShow: boolean = false;
  // Number of Matched Search Records
  public searchPhoneNum: number = 0;
  // Indicates whether to search a list.
  public showSearchList: boolean = false;
  // Display Default Number
  public showDefaultNumber: boolean = true;
  // Indicates whether to display the child number list.
  public showNumberList: boolean = true;
  // Display primary number check box
  public phoneCheckShow: boolean = true;
  // Display child number list check box
  public childPhoneCheckShow: boolean = true;
  public contactsListCount: number = 0;
  public contactsListTotal: number = 0;
  // Count of selected numbers in the contact list
  public contactsNumberCount: number = 0;

  constructor() {
  }
}

export interface EventInterface {
  contactIndex: number
  numberIndex: number
  checked: boolean
}