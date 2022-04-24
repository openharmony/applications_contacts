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

import HiLog from '../../../util/HiLog';
import callLogService from '../../../model/calllog/CalllogModel';
import Constants from '../../../model/common/Constants';
import ArrayUtil from '../../../util/ArrayUtil';
import StringUtil from '../../../util/StringUtil';
import ContactAbilityModel from '../../../model/ContactAbilityModel';
import featureAbility from '@ohos.ability.featureAbility';
import router from '@system.router';

const TAG = 'BatchSelectContactsPresenter ';

/**
 * Selecting a contact list by SMS
 */
export default class BatchSelectContactsPresenter {
  private static sInstance: BatchSelectContactsPresenter;
  sizeType: SizeType = SizeType.LG;
  selectCount: number = 0;
  // Recent Call Records
  callLogTemp: any[] = [];
  contactsList: any[] = [];
  searchContactList: any[] = [];
  groupList: any[] = [];
  emptyViewText: Resource = $r("app.string.no_recent_contacts");
  controller: TabsController = new TabsController();
  currentIndex: number = 0;
  tabTextSrc: string[] | Resource[] = [$r("app.string.recent"), $r("app.string.contact")];
  tabInfo: TabInfo = new TabInfo(0);
  contactsInfo: ContactsInfo = new ContactsInfo();
  // Whether to display the Select All button at the bottom
  showOption: boolean = false;
  // Search Keyword
  searchText: string = '';
  // Selected data for the current population，key:phone number，value:name and number
  selectedNumberMap: any = new Map();
  // Whether to display the search list
  searchLayoutShow: boolean = false;
  selectDisabled: boolean = true;
  isSelectAll: boolean = false;
  icSelectAll: Resource = $r("app.media.ic_public_select_all");
  allSelectMessage: Resource = $r("app.string.select_all");
  allSelectTextStyle: Resource = $r("sys.color.ohos_id_color_primary");
  initialIndex: number = 0;

  public static getInstance(): BatchSelectContactsPresenter {
    if (BatchSelectContactsPresenter.sInstance == null) {
      BatchSelectContactsPresenter.sInstance = new BatchSelectContactsPresenter();
    }
    return BatchSelectContactsPresenter.sInstance;
  }

  aboutToAppear() {
    this.initCallLog();
    this.initContactsList();
  }

  aboutToDisappear() {
  }

  onPageShow() {
  }

  onPageHide() {
  }

  cancel() {
    router.back();
  }

  resetInitialIndex(firstIndex: number) {
    HiLog.i(TAG, "resetInitialIndex firstIndex is %s", firstIndex);
    this.initialIndex = firstIndex;
  }

  comfirm() {
    let checkedList = [];
    this.selectedNumberMap.forEach((value) => {
      checkedList.push(value);
    });
    let contacts = this.dealContactName(checkedList);
    let parameters = {
      contactObjects: JSON.stringify(contacts)
    };
    let result = {
      resultCode: 0,
      want: {
        parameters: parameters
      }
    };
    // Selecting a contact for creating an SMS message
    featureAbility.terminateSelfWithResult(result)
      .then((data) => {
        HiLog.i(TAG, "terminateSelfWithResult Operation succeeded: ");
      })
      .catch((error) => {
        HiLog.e(TAG, "Operation failed. Cause: %s", JSON.stringify(error.message));
      });
  }

  dealContactName(checkedList) {
    let contacts = [];
    for (let item of checkedList) {
      let contact = {
        contactName: item.name,
        telephone: item.number
      };
      contacts.push(contact);
    }
    return contacts;
  }

  clickSelectAll() {
    switch (this.tabInfo.tabIndex) {
      case 0:
        if (this.tabInfo.recentCount != 0 && this.tabInfo.recentCount === this.tabInfo.recentTotal) {
          this.tabInfo.allClickedRecent = false;
          this.unSelectAll();
        } else {
          this.tabInfo.allClickedRecent = true;
          this.selectAll();
        }
        break;
      case 1:
        if (this.tabInfo.contactsCount != 0 && this.tabInfo.contactsCount === this.tabInfo.contactsTotal) {
          this.tabInfo.allClickedContacts = false;
          this.unSelectAll();
        } else {
          this.tabInfo.allClickedContacts = true;
          this.selectAll();
        }
        break;
      case 2:
        if (this.tabInfo.groupsCount != 0 && this.tabInfo.groupsCount === this.tabInfo.groupsTotal) {
          this.tabInfo.allClickedGroups = false;
          this.unSelectAll();
        } else {
          this.tabInfo.allClickedGroups = true;
          this.selectAll();
        }
        break;
      default:
        break;
    }
    this.refreshPageMessage();
  }

  unSelectAll() {
    switch (this.tabInfo.tabIndex) {
      case 0:
        this.unSelectAllRecentProc();
        break;
      case 1:
        this.unSelectAllContactProc();
        break;
      case 2:
        this.groupList.forEach(element => {
          element.checked = false;
        });
        this.tabInfo.groupsCount = 0;
        break;
      default:
        break;
    }
  }

  selectAll() {
    switch (this.tabInfo.tabIndex) {
      case 0:
        this.selectAllRecentProc();
        break;
      case 1:
        this.selectAllContactProc();
        break;
      case 2:
        this.groupList.forEach(element => {
          element.checked = true;
        });
        this.tabInfo.groupsCount = this.tabInfo.groupsTotal;
        break;
      default:
        break;
    }
  }

  unSelectAllRecentProc() {
    this.callLogTemp.forEach(element => {
      element.checked = false;
      if (this.checkIfSelectedNumber(element.phoneNumber)) {
        this.deleteSelectedNumber(element.phoneNumber);
      }
    });
    this.tabInfo.recentCount = 0;
  }

  unSelectAllContactProc() {
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach(element => {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          if (element.phoneNumbers[i].checked) {
            element.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber);
          }
        }
      });
    } else {
      this.contactsList.forEach(element => {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          if (element.phoneNumbers[i].checked) {
            element.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber);
          }
        }
      });
    }
    this.tabInfo.contactsCount = 0;
  }

  selectAllRecentProc() {
    this.callLogTemp.forEach(element => {
      element.checked = true;
      this.addOrUpdateSelectedNumberMap(element.phoneNumber, element.displayName);
    });
    this.tabInfo.recentCount = this.tabInfo.recentTotal;
  }

  selectAllContactProc() {
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach(element => {
        if (!element.phoneNumbers[0].checked) {
          element.phoneNumbers[0].checked = true;
          this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber, element.name.fullName);
        }
      });
    } else {
      this.contactsList.forEach(element => {
        if (!element.phoneNumbers[0].checked) {
          element.phoneNumbers[0].checked = true;
          this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber, element.name.fullName);
        }
      });
    }
    this.tabInfo.contactsCount = this.tabInfo.contactsTotal;
  }

  checkIfSelectedNumber(number): boolean {
    if (StringUtil.isEmpty(number)) {
      return false;
    }
    return this.selectedNumberMap.has(number.replace(/\s+/g, ''));
  }

  onTabChange(tabIndex: number) {
    HiLog.i(TAG, 'onTabChange tabIndex is %s', tabIndex);
    this.tabInfo.tabIndex = tabIndex;
    this.refreshPageMessage();
  }

  getEmptyText(): Resource {
    switch (this.tabInfo.tabIndex) {
      case 0:
        this.emptyViewText = $r("app.string.no_recent_contacts");
        break
      case 1:
        this.emptyViewText = $r("app.string.no_select_contacts");
        break
      case 2:
        this.emptyViewText = $r("app.string.no_group_contacts");
        break
      default:
        this.emptyViewText = $r("app.string.no_recent_contacts");
        break
    }
    return this.emptyViewText;
  }

  onRecentItemClicked(index: number) {
    HiLog.i(TAG, 'onRecentItemClicked index is %s', index);
    this.checkStateChange(index, {
      checked: !(this.callLogTemp[index].checked)
    });
  }

  onContactItemClicked(index: number, indexChild: number) {
    HiLog.i(TAG, 'onContactItemClicked index is %s', index);
    HiLog.i(TAG, 'onContactItemClicked indexChild is %s', indexChild);
    let event = {
      contactIndex: index,
      numberIndex: indexChild,
      checked: this.searchLayoutShow ? !(this.searchContactList[index].phoneNumbers[indexChild].checked)
                                     : !(this.contactsList[index].phoneNumbers[indexChild].checked)
    }
    this.checkStateChange(index, event);
  }

  checkStateChange(index, event) {
    HiLog.i(TAG, 'checkStateChange event: %s ', JSON.stringify(event));
    switch (this.tabInfo.tabIndex) {
      case 0:
        this.changeCallLogItemState(index, event);
        break;
      case 1:
        this.changeContactsItemState(index, event);
        break;
      default:
        break;
    }
    this.refreshPageMessage();
  }

  changeContactState(event) {
    this.checkStateChange(event.contactIndex, event);
  }

  changeCallLogItemState(index, event) {
    HiLog.i(TAG, 'changeCallLogItemState event : %s ', JSON.stringify(event));
    this.callLogTemp[index].checked = event.checked;
    if (this.callLogTemp[index].checked) {
      this.addOrUpdateSelectedNumberMap(this.callLogTemp[index].phoneNumber, this.callLogTemp[index].displayName);
      this.tabInfo.recentCount++;
    } else {
      this.deleteSelectedNumber(this.callLogTemp[index].phoneNumber);
      this.tabInfo.recentCount--;
    }
  }

  changeContactsItemState(index, event) {
    HiLog.i(TAG, "SHOW changeContactsItemState searchLayoutShow");
    let contactId = '';
    if (!this.contactsInfo.searchLayoutShow) {
      contactId = this.contactsList[index].contactId;
    } else {
      contactId = this.contactsInfo.searchContactList[index].contactId;
    }
    this.checkContactsCount(event, contactId);
  }

  checkContactsCount(event, contactId) {
    HiLog.i(TAG, "SHOW checkContactsCount searchLayoutShow");
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
              element.name.fullName);
          } else {
            element.phoneNumbers[event.numberIndex].checked = false;
            this.contactsInfo.contactsNumberCount--;
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount--;
            }
            this.deleteSelectedNumber(element.phoneNumbers[event.numberIndex].phoneNumber);
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
              element.name.fullName);
          } else {
            element.phoneNumbers[event.numberIndex].checked = false;
            this.contactsInfo.contactsNumberCount--;
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount--;
            }
            this.deleteSelectedNumber(element.phoneNumbers[event.numberIndex].phoneNumber);
          }
        }
      });
    }
  }

  /**
    * Determines whether the current contact element has an option.
    *
    * @param {Object} contact
    * @return {boolean} true，false
    */
  checkIfNeedCount(contact) {
    if (contact.phoneNumbers.length > 0) {
      for (let index = 0; index < contact.phoneNumbers.length; index++) {
        const element = contact.phoneNumbers[index];
        if (element.checked) {
          return true;
        }
      }
    } else {
      return false;
    }
  }

  // Header Count Refresh Function
  refreshPageMessage() {
    HiLog.i(TAG, "refreshPageMessage start !")
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
    HiLog.i(TAG, "checkAllClickButtonStyle start , and tabIndex is " + this.tabInfo.tabIndex);
    switch (this.tabInfo.tabIndex) {
      case 0:
        if (this.tabInfo.recentCount === this.tabInfo.recentTotal) {
          HiLog.i(TAG, "checkAllClickButtonStyle recent select all ");
          this.changeToFullSelect();
          this.tabInfo.allClickedRecent = true;
        } else {
          HiLog.i(TAG, "checkAllClickButtonStyle recent unselect all ");
          this.changeToUnFullSelect();
        }
        break;
      case 1:
        if (this.tabInfo.contactsCount === this.tabInfo.contactsTotal) {
          HiLog.i(TAG, "checkAllClickButtonStyle contact select all ");
          this.changeToFullSelect();
          this.tabInfo.allClickedContacts = true;
        } else {
          HiLog.i(TAG, "checkAllClickButtonStyle contact unselect all ");
          this.changeToUnFullSelect();
        }
        break;
      default:
        break;
    }
  }

  changeToFullSelect() {
    this.icSelectAll = $r("app.media.ic_public_select_all_filled");
    this.allSelectMessage = $r("app.string.unselect_all");
    this.allSelectTextStyle = $r("sys.color.ohos_id_color_connected");
  }

  changeToUnFullSelect() {
    this.icSelectAll = $r("app.media.ic_public_select_all");
    this.allSelectMessage = $r("app.string.select_all");
    this.allSelectTextStyle = $r("sys.color.ohos_id_color_primary");
  }

  addOrUpdateSelectedNumberMap(number, name) {
    if (StringUtil.isEmpty(number)) {
      return;
    }
    this.selectedNumberMap.set(number.replace(/\s+/g, ''), {
      name: name,
      number: number.replace(/\s+/g, '')
    });
  }

  deleteSelectedNumber(number) {
    if (StringUtil.isEmpty(number)) {
      return;
    }
    this.selectedNumberMap.delete(number.replace(/\s+/g, ''));
  }

  /**
   * Obtaining Recent Call Records
   * */
  initCallLog() {
    HiLog.i(TAG, 'initCallLog start !');
    let tempMap = new Map();
    let tempList: any[] = [];

    callLogService.getAllCalls(data => {
      if (data.hasOwnProperty('callLogList') && !ArrayUtil.isEmpty(data.callLogList)) {
        HiLog.i(TAG, 'data  has callLogList key');
        for (let i = 0; i < data.callLogList.length; i++) {
          HiLog.i(TAG, 'callLogList index is %s', i);
          let element = data.callLogList[i];
          let bgColorIndex = parseInt(element.id, 10) % (Constants.background.Color.length);
          element.portraitColor = Constants.background.Color[bgColorIndex];
          element.suffix = StringUtil.isEmpty(element.displayName) ? '' : element.displayName.substr(element.displayName.length - 1);
          element.checked = false;
          // 重复的号码无需显示
          if (!tempMap.has(StringUtil.removeSpace(element.phoneNumber))) {
            HiLog.i(TAG, 'callLogList remove same');
            tempList.push(element);
            tempMap.set(element.phoneNumber, null);
          }
          //Displays the 50 numbers that have generated the latest call records.
          if (tempList.length > 50) {
            HiLog.i(TAG, 'callLogList more 50 break!');
            break;
          }
        }
      }
      this.callLogTemp = tempList;
      this.tabInfo.recentTotal = this.callLogTemp.length;
      this.checkOptionState();
    });
  }

  /**
   * Check whether the Select All button at the bottom needs to be displayed.
   * */
  checkOptionState() {
    switch (this.tabInfo.tabIndex) {
      case 0:
        ArrayUtil.isEmpty(this.callLogTemp) ? this.showOption = false : this.showOption = true;
        break;
      case 1:
        ArrayUtil.isEmpty(this.contactsList) ? this.showOption = false : this.showOption = true;
        break;
      case 2:
        ArrayUtil.isEmpty(this.groupList) ? this.showOption = false : this.showOption = true;
        break;
      default:
        break;
    }
  }

  /*
   * Initializing Contact List Data
   */
  initContactsList() {
    HiLog.i(TAG, 'initContactsList start!');
    ContactAbilityModel.getAllContactWithPhoneNumbers((resultList) => {
      HiLog.i(TAG, 'initContactsList resultList success ' + resultList.length);
      let listTemp: any[] = [];
      if (!ArrayUtil.isEmpty(resultList)) {
        for (let element of resultList) {
          element.name = {};
          element.name.fullName = element.emptyNameData;
          element.name.namePrefix = element.namePrefix;
          element.name.nameSuffix = element.nameSuffix;
          if (element.phoneNumbers != null && element.phoneNumbers.length > 0) {
            element.phoneNumbers.forEach(childEle => {
              childEle.checked = false;
              childEle.labelName = this.getPhoneLabelNameById(childEle.numType);
              this.initVariableSpan(element);
            });
            listTemp.push(element);
          }
        }
        this.contactsList = listTemp;
        this.tabInfo.contactsTotal = this.contactsList.length;
        this.contactsInfo.contactsListTotal = this.contactsList.length;
      } else {
        HiLog.e(TAG, 'select contact list is empty!');
      }
    });
  }


  /**
   * Assign a custom attribute to prepare for later variable font searches
   *
   * @param {Object} item contacts data
   */
  initVariableSpan(item) {
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

  getPhoneLabelNameById(phoneLabelId: string) {
    let labelName: string | Resource = '';
    switch (parseInt(phoneLabelId, 10)) {
      case 1:
        labelName = "住宅";
        break;
      case 2:
        labelName = "电话";
        break;
      case 3:
        labelName = "单位";
        break;
      case 4:
        labelName = "单位传真";
        break;
      case 5:
        labelName = "住宅传真";
        break;
      case 6:
        labelName = "寻呼机";
        break;
      case 7:
        labelName = "其他";
        break;
      case 12:
        labelName = "总机";
        break;
      case 99:
        labelName = "自定义";
        break;
      default:
        break;
    }
    return labelName;
  }
}

export class TabInfo {
  tabIndex: number = 0;
  recentTotal: number = 0;
  contactsTotal: number = 0;
  groupsTotal: number = 0;
  // Select All Clicked
  allClickedRecent: boolean = false;
  allClickedContacts: boolean = false;
  allClickedGroups: boolean = false;
  // Count on each tab page
  recentCount: number = 0;
  contactsCount: number = 0;
  groupsCount: number = 0;
  refreshGroupItemState: boolean = false;
  constructor(tabIndex: number) {
    this.tabIndex = tabIndex;
  }
}

/**
 * Data related to the contact list
 */
export class ContactsInfo {
  searchContactList = [];
  // List of selected contacts, which will be used for big data.
  selectedContactMap = new Map();
  // Whether to display the search page
  searchLayoutShow: boolean = false;
  // Number of Matched Search Records
  searchPhoneNum: number = 0;
  // Indicates whether to search a list.
  showSearchList: boolean = false;
  // Display Default Number
  showDefaultNumber: boolean = true;
  // Indicates whether to display the child number list.
  showNumberList: boolean = true;
  // Display primary number check box
  phoneCheckShow: boolean = true;
  // Display child number list check box
  childPhoneCheckShow: boolean = true;
  contactsListCount: number = 0;
  contactsListTotal: number = 0;
  // Count of selected numbers in the contact list
  contactsNumberCount: number = 0;
  constructor() {
  }
}