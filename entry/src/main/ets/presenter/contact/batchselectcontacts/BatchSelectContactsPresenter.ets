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

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import callLogService from '../../../model/calllog/CalllogModel';
import MorandiColor from '../../../model/bean/MorandiColor';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { ObjectUtil } from '../../../../../../../common/src/main/ets/util/ObjectUtil';
import ContactAbilityModel from '../../../model/ContactAbilityModel';
import router from '@ohos.router';
import BatchSelectRecentSource from '../../../model/bean/BatchSelectRecentSource';
import BatchSelectContactSource from '../../../model/bean/BatchSelectContactSource';
import CallLogSetting from "../../../../../../../feature/call/src/main/ets/CallLogSetting"

const TAG = 'BatchSelectContactsPresenter ';

/**
 * Selecting a contact list by SMS
 */
export default class BatchSelectContactsPresenter {
  private static sInstance: BatchSelectContactsPresenter;
  sizeType: SizeType = SizeType.LG;
  selectCount: number = 0;
  // Recent Call Records
  callLogTemp: Array<any> = [];
  contactsList: Array<any> = [];
  searchContactList: Array<any> = [];
  groupList: Array<any> = [];
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
  selectedNumberMap: Map<number, any> = new Map();
  // Whether to display the search list
  searchLayoutShow: boolean = false;
  selectDisabled: boolean = true;
  isSelectAll: boolean = false;
  icSelectAll: Resource = $r("app.media.ic_public_select_all");
  allSelectMessage: Resource = $r("app.string.select_all");
  allSelectTextStyle: Resource = $r("sys.color.ohos_id_color_primary");
  initialIndex: number = 0;
  recentSource: BatchSelectRecentSource = new BatchSelectRecentSource();
  contactsSource: BatchSelectContactSource = new BatchSelectContactSource();
  actionData: { [key: string]: any } = {};

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
    let parameters = {
      contactObjects: ""
    };
    let result = {
      resultCode: 0,
      want: {
        parameters: parameters
      }
    };
    // Selecting a contact for creating an SMS message
    globalThis.context?.terminateSelfWithResult(result)
      .then((data) => {
        HiLog.i(TAG, "terminateSelfWithResult Operation succeeded: ");
      })
      .catch((error) => {
        HiLog.e(TAG, "Operation failed. Cause: %s", JSON.stringify(error.message));
      });
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
    globalThis.context?.terminateSelfWithResult(result)
      .then((data) => {
        HiLog.i(TAG, "terminateSelfWithResult Operation succeeded ");
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
      if (element.checked) {
        element.checked = false;
        this.deleteSelectedNumber(element.phoneNumber, element.displayName, true, element.quickSearchKey);
      }
    });
    this.recentSource.refresh(this.callLogTemp);
    this.tabInfo.recentCount = 0;
  }

  unSelectAllContactProc() {
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach(element => {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          if (element.phoneNumbers[i].checked) {
            element.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber, element.name.fullName, false, element.contactId);
          }
        }
      });
    } else {
      this.contactsList.forEach(element => {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          if (element.phoneNumbers[i].checked) {
            element.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber, element.name.fullName, false, element.contactId);
          }
        }
      });
      this.contactsSource.refresh(this.contactsList);
    }
    this.tabInfo.contactsCount = 0;
  }

  selectAllRecentProc() {
    this.callLogTemp.forEach(element => {
      element.checked = true;
      this.addOrUpdateSelectedNumberMap(element.phoneNumber, element.displayName, true, element.quickSearchKey);
    });
    this.recentSource.refresh(this.callLogTemp);
    this.tabInfo.recentCount = this.tabInfo.recentTotal;
  }

  selectAllContactProc() {
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach(element => {
        if (!element.phoneNumbers[0].checked) {
          element.phoneNumbers[0].checked = true;
          this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber, element.name.fullName, false, element.contactId);
        }
      });
    } else {
      this.contactsList.forEach(element => {
        if (!element.phoneNumbers[0].checked) {
          element.phoneNumbers[0].checked = true;
          this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber, element.name.fullName, false, element.contactId);
        }
      });
      this.contactsSource.refresh(this.contactsList);
    }
    this.tabInfo.contactsCount = this.tabInfo.contactsTotal;
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

  onSingleContactItemClick(num: number, name: string) {
    HiLog.i(TAG, 'onSingleContactItemClick in ');
    this.selectedNumberMap.set(num, {
      name: name,
      number: num
    });
    this.comfirm();
  }

  onContactItemClicked(index: number, indexChild: number) {
    HiLog.i(TAG, 'onContactItemClicked index is ' + index);
    HiLog.i(TAG, 'onContactItemClicked indexChild is ' + indexChild);
    let event = {
      contactIndex: index,
      numberIndex: indexChild,
      checked: this.searchLayoutShow ? !(this.searchContactList[index].phoneNumbers[indexChild].checked)
                                     : !(this.contactsList[index].phoneNumbers[indexChild].checked)
    }
    this.checkStateChange(index, event);
  }

  checkStateChange(index, event) {
    HiLog.i(TAG, 'checkStateChange event:  ' + JSON.stringify(event));
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
    HiLog.i(TAG, 'changeCallLogItemState event :  ' + JSON.stringify(event));
    this.callLogTemp[index].checked = event.checked;
    this.recentSource.refreshSpecificOne(index, event.checked)

    if (this.callLogTemp[index].checked) {
      this.addOrUpdateSelectedNumberMap(this.callLogTemp[index].phoneNumber, this.callLogTemp[index].displayName, true, this.callLogTemp[index].quickSearchKey);
      this.tabInfo.recentCount++;
    } else {
      this.deleteSelectedNumber(this.callLogTemp[index].phoneNumber, this.callLogTemp[index].displayName, true, this.callLogTemp[index].quickSearchKey);
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
            element.name.fullName, false, element.contactId);
          } else {
            element.phoneNumbers[event.numberIndex].checked = false;
            this.contactsInfo.contactsNumberCount--;
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount--;
            }
            this.deleteSelectedNumber(element.phoneNumbers[event.numberIndex].phoneNumber, element.name.fullName, false, element.contactId);
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
            element.name.fullName, false, element.contactId);
          } else {
            element.phoneNumbers[event.numberIndex].checked = false;
            this.contactsInfo.contactsNumberCount--;
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount--;
            }
            this.deleteSelectedNumber(element.phoneNumbers[event.numberIndex].phoneNumber, element.name.fullName, false, element.contactId);
          }
        }
      });
      this.contactsSource.refresh(this.contactsList);
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

  addOrUpdateSelectedNumberMap(number, name, isCalllogs, keyOrId) {
    HiLog.i(TAG, "addOrUpdateSelectedNumberMap isCalllogs is " + isCalllogs + " , keyOrId is " + keyOrId);
    if (StringUtil.isEmpty(number)) {
      return;
    }
    this.selectedNumberMap.set((keyOrId + number.replace(/\s+/g, '')), {
      name: name,
      number: number.replace(/\s+/g, '')
    });
    this.updataConnectedContact(number, name, isCalllogs, keyOrId, true);
  }

  deleteSelectedNumber(number, name, isCalllogs, keyOrId) {
    HiLog.i(TAG, "deleteSelectedNumber isCalllogs is " + isCalllogs + " , keyOrId is " + keyOrId);
    if (StringUtil.isEmpty(number)) {
      return;
    }
    this.selectedNumberMap.delete(keyOrId + number.replace(/\s+/g, ''));
    this.updataConnectedContact(number, name, isCalllogs, keyOrId, false);
  }

  updataConnectedContact(number, name, isCalllogs, keyOrId, isAdd) {
    HiLog.i(TAG, "updataConnectedContact isCalllogs is " + isCalllogs + " , keyOrId is " + keyOrId);
    if (isCalllogs) {
      this.contactsList.forEach(element => {
        if (!ObjectUtil.isEmpty(element) && element.contactId == keyOrId) {
          for (let i = 0; i < element.phoneNumbers.length; i++) {
            let childElement = element.phoneNumbers[i];
            if (!ObjectUtil.isEmpty(childElement) && childElement.phoneNumber == number && element.name.fullName == name) {
              if (isAdd) {
                // If the original data does not contain the selected item before modification, the tab count increases by 1.
                if (!this.checkIfNeedCount(element)) {
                  this.tabInfo.contactsCount++;
                }
                childElement.checked = true;
                this.contactsInfo.contactsNumberCount++;
              } else {
                // After the modification, the tab count decreases by 1 when the original data does not contain the selected item.
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
    } else {
      this.callLogTemp.forEach(element => {
        if (!ObjectUtil.isEmpty(element) && element.quickSearchKey == keyOrId && element.phoneNumber == number && element.displayName == name) {
          element.checked = isAdd;
          if (isAdd) {
            this.tabInfo.recentCount++;
          } else {
            this.tabInfo.recentCount--;
          }
          return;
        }
      })
      this.recentSource.refresh(this.callLogTemp);
    }
  }

  /**
   * Obtaining Recent Call Records
   * */
  initCallLog() {
    HiLog.i(TAG, 'initCallLog start !');
    let tempMap = new Map();
    let tempList: any[] = [];

    globalThis.DataWorker?.sendRequest("getAllCalls", {
      context: globalThis.context,
      mergeRule: CallLogSetting.getInstance().getMergeRule(),
      actionData: this.actionData
    }, (data) => {
      if (data.hasOwnProperty('callLogList') && !ArrayUtil.isEmpty(data.callLogList)) {
        HiLog.i(TAG, 'data  has callLogList key');
        for (let i = 0; i < data.callLogList.length; i++) {
          let element = data.callLogList[i];
          let bgColorIndex = parseInt(element.id, 10) % (MorandiColor.Color.length);
          element.portraitColor = MorandiColor.Color[bgColorIndex];
          element.suffix = StringUtil.isEmpty(element.displayName) ? '' : element.displayName.substr(element.displayName.length - 1);
          element.checked = false;
          // 重复的号码无需显示
          if (!tempMap.has(StringUtil.removeSpace(element.phoneNumber))) {
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
      this.recentSource.refresh(this.callLogTemp);
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
    globalThis.DataWorker.sendRequest("getAllContactWithPhoneNumbers", {
      context: globalThis.context
    }, (resultList) => {
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
              childEle.labelName = this.getPhoneLabelNameById(childEle.numType, childEle.phoneNumber);
              this.initVariableSpan(element);
            });
            listTemp.push(element);
          }
        }
        this.contactsList = listTemp;
        this.contactsSource.refresh(this.contactsList);
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

  getPhoneLabelNameById(phoneLabelId: string, phoneNumber) {
    let labelName: Resource;
    switch (parseInt(phoneLabelId, 10)) {
      case 1:
        labelName = $r("app.string.phone_type_mobile_expansion", phoneNumber);
        break;
      case 2:
        labelName = $r("app.string.phone_type_home_expansion", phoneNumber);
        break;
      case 3:
        labelName = $r("app.string.phone_type_work_expansion", phoneNumber);
        break;
      case 4:
        labelName = $r("app.string.phone_type_fax_work_expansion", phoneNumber);
        break;
      case 5:
        labelName = $r("app.string.phone_type_fax_home_expansion", phoneNumber);
        break;
      case 6:
        labelName = $r("app.string.phone_type_pager_expansion", phoneNumber);
        break;
      case 7:
        labelName = $r("app.string.phone_type_other_expansion", phoneNumber);
        break;
      case 12:
        labelName = $r("app.string.phone_type_main_expansion", phoneNumber);
        break;
      case 99:
        labelName = $r("app.string.phone_type_custom_expansion", phoneNumber);
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