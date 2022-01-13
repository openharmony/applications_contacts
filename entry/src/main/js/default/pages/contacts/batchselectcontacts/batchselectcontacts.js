/**
 * @file Batch Selecting Contacts
 */
/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http:// www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import callLogService from '../../../../default/model/CalllogModel.js';
import selectContactsAbility from '../../../../default/model/SelectcontactsModel.js';
import httpcontact from '../../../../default/model/ContactModel.js';
import Utils from '../../../../default/utils/utils.js';
import LOG from '../../../utils/ContactsLog.js';
import Constants from '../../../../default/common/constants/Constants.js';
import featureAbility from '@ohos.ability.featureAbility';
import backgroundColor from '../../../common/constants/color.js';
import router from '@system.router';

const SELECT_CONFIRM = 1000; // Confirm interface selection
const SEARCH_CONTACTS = 2012; // Searching for Contacts

var TAG = 'batchSelectContacts';

export default {
    data: {
        callLogTemp: [], // Recent call history
        contactsList: [], // Contact list
        layoutState: true, // Concise layout
        groupList: [],
        backgroundColor: backgroundColor.Color,
        showGroupList: true,
        selectedNumberMap: new Map(),
        searchText: '',
        icCancelM: '/res/image/ic_cancel_m.svg',
        icDeleteM: '/res/image/ic_delete_m.svg',
        icSelectAll: '/res/image/ic_select all_m.svg',
        icComFirm: '/res/image/ic_comfirm.svg',
        titleMessage: '',
        selectCount: 0,
        allSelectMessage: '',
        allSelectTextStyle: 'batch-select-text',
        selectMessage: '',
        isSelectAll: false,
        selectAllClicked: false,
        selectDisabled: true,
        refreshBatchDeleteLogId: 0,
        isFirstInit: true,
        showOption: false,
        contactListShow: false,
        pageInfo: {
            pageIndex: 0,
            pageSize: 50,
        },
        emptyDataImage: {
            icSelectNoRecent: '',
            icSelectNoContacts: '/res/image/ic_contacts_empty_contact_72.svg',
            icSelectNoGroups: '/res/image/ic_contacts_empty_group.svg',
        },
        tabInfo: {
            tabIndex: 0,
            recentTotal: 0,
            contactsTotal: 0,
            groupsTotal: 0,
            allClickedRecent: false,
            allClickedContacts: false,
            allClickedGroups: false,
            recentCount: 0,
            contactsCount: 0,
            groupsCount: 0,
            refreshGroupItemState: false
        },
        contactsInfo: { // Contact list data
            searchContactList: [],
            selectedContactMap: new Map(),
            searchLayoutShow: false, // Whether to display the search page
            searchPhoneNum: 0,
            showSearchList: false,
            showDefaultNumber: true,
            showNumberList: true,
            phoneCheckShow: true,
            childPhoneCheckShow: true,
            contactsListCount: 0,
            contactsListTotal: 0,
            contactsNumberCount: 0,
        }
    },
    onInit() {
        this.initCallLog();
        this.conciseLayoutInit();
        this.initContactsList();
        this.titleMessage = this.$t('value.callRecords.titleMessageNoSelect');
        this.allSelectMessage = this.$t('value.callRecords.selectAll');
        this.allSelectTextStyle = 'batch-select-text';
    },
    onShow() {
    },

    // The clean layout option is initialized
    conciseLayoutInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_concise_layout_switch', 'false');
        this.layoutState = data == 'true' ? false : true;
    },

    /**
     * Change the TAB selection
     *
     * @param {Object} e
     */
    changeSelectTab(e) {
        this.tabInfo.tabIndex = e.index;
        this.checkTabListStyle(); // Verify the current TAB list data selection status
        this.checkOptionState(); // Verify that the current TAB selection button is displayed
    },

    checkOptionState() {
        switch (this.tabInfo.tabIndex) {
            case 0:
                    Utils.isEmptyList(this.callLogTemp) ? this.showOption = false : this.showOption = true;
                break;

            case 1:
                    Utils.isEmptyList(this.contactsList) ? this.showOption = false : this.showOption = true;
                break;

            case 2:
                    Utils.isEmptyList(this.groupList) ? this.showOption = false : this.showOption = true;
                break;

            default:
                break;
        }
    },

    clickSelectAll(e) {
        switch (this.tabInfo.tabIndex) {
            case 0:
                if (this.tabInfo.recentCount != 0 && this.tabInfo.recentCount == this.tabInfo.recentTotal) { // 已经全选，则取消全选
                    this.tabInfo.allClickedRecent = false;
                    this.unSelectAll();
                } else {
                    this.tabInfo.allClickedRecent = true;
                    this.selectAll();
                }
                break;

            case 1: // Contact list TAB
                if (this.tabInfo.contactsCount != 0 && this.tabInfo.contactsCount == this.tabInfo.contactsTotal) { // 已经全选，则取消全选
                    this.tabInfo.allClickedContacts = false;
                    this.unSelectAll();
                } else {
                    this.tabInfo.allClickedContacts = true;
                    this.selectAll();
                }
                break;

            case 2: // Groups TAB
                if (this.tabInfo.groupsCount != 0 && this.tabInfo.groupsCount == this.tabInfo.groupsTotal) { // 已经全选，则取消全选
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
    },

    /**
     * The status of the list check box changes
     *
     * @param {number} index
     * @param {Object} e
     */
    checkStateChange(index, e) {
        switch (this.tabInfo.tabIndex) {
            case 0:
                this.changeCallLogItemState(index, e);
                break;

            case 1:
                this.changeContactsItemState(index, e);
                break;

            case 2:
                this.changeGroupsItemState(index, e);
                break;

            default:
                break;
        }
        this.refreshPageMessage();
    },

    /**
     * The status of the TAB Call History check box changed recently
     *
     * @param {number} index
     * @param {Object} e
     */
    changeCallLogItemState: function (index, e) {
        this.callLogTemp[index].checked = e.checked;
        if (this.callLogTemp[index].checked) {
            this.addOrUpdateSelectedNumberMap(this.callLogTemp[index].phone, this.callLogTemp[index].name);
            this.tabInfo.recentCount++;
        } else {
            this.deleteSelectedNumber(this.callLogTemp[index].phone);
            this.tabInfo.recentCount--;
        }
    },

    /**
     * Contact list TAB The status of the call history check box changes
     *
     * @param {number} index
     * @param {Object} e
     */
    changeContactsItemState: function (index, e) {
        var contactId = '';
        if (!this.contactsInfo.searchLayoutShow) { // Contact main list interface click the check box
            contactId = this.contactsList[index].contactId;
        } else { // On the contact search list screen, click the check box
            contactId = this.contactsInfo.searchContactList[index].contactId;
        }
        this.checkContactsCount(e, contactId);
    },

    /**
     * Determine whether to increase or decrease the contact count. If all subnumbers and major numbers are unselected,
     * decrease by 1. If all numbers are selected, increase by 1
     *
     * @param {Object} e
     * @param {number} contactId The contact ID
     */
    checkContactsCount(e, contactId) {
        if (this.contactsInfo.searchLayoutShow) {
            this.contactsInfo.searchContactList.forEach(element => {
                if (contactId == element.contactId) {
                    if (e.detail.checked) {
                        if (!this.checkIfNeedCount(element)) {
                            this.tabInfo.contactsCount++;
                        }
                        element.phoneNumbers[e.detail.numberIndex].checked = true;
                        this.contactsInfo.contactsNumberCount++;
                        this.addOrUpdateSelectedNumberMap(element.phoneNumbers[e.detail.numberIndex].phoneNumber,
                            element.name.fullName);
                    } else {
                        element.phoneNumbers[e.detail.numberIndex].checked = false;
                        this.contactsInfo.contactsNumberCount--;
                        if (!this.checkIfNeedCount(element)) {
                            this.tabInfo.contactsCount--;
                        }
                        this.deleteSelectedNumber(element.phoneNumbers[e.detail.numberIndex].phoneNumber);
                    }
                }
            });
        } else {
            this.contactsList.forEach(element => {
                if (contactId == element.contactId) {
                    if (e.detail.checked) {
                        if (!this.checkIfNeedCount(element)) {
                            this.tabInfo.contactsCount++;
                        }
                        element.phoneNumbers[e.detail.numberIndex].checked = true;
                        this.contactsInfo.contactsNumberCount++;
                        this.addOrUpdateSelectedNumberMap(element.phoneNumbers[e.detail.numberIndex].phoneNumber,
                            element.name.fullName);
                    } else {
                        element.phoneNumbers[e.detail.numberIndex].checked = false;
                        this.contactsInfo.contactsNumberCount--;
                        if (!this.checkIfNeedCount(element)) {
                            this.tabInfo.contactsCount--;
                        }
                        this.deleteSelectedNumber(element.phoneNumbers[e.detail.numberIndex].phoneNumber);
                    }
                }
            });
        }
    },

    /**
     * Checks whether the current contact element has an option, negating true if it does, and false if it does not
     *
     * @param {Object} contact Contact data
     * @return {boolean}
     */
    checkIfNeedCount: function (contact) {
        if (contact.phoneNumbers.length > 0) {
            for (var index = 0; index < contact.phoneNumbers.length; index++) {
                const element = contact.phoneNumbers[index];
                if (element.checked) {
                    return true;
                }
            }
        }
        return false;
    },

    /**
     * Group TAB The status of the call record check box changes
     *
     * @param {number} index
     * @param {Object} e
     */
    changeGroupsItemState: function (index, e) {
        this.groupList[index].checked = e.checked;
        if (this.groupList[index].checked) {
            this.tabInfo.groupsCount++;
        } else {
            this.tabInfo.groupsCount--;
        }
    },

    selectAll() {
        switch (this.tabInfo.tabIndex) {
            case 0: // Recent TAB.
                this.selectAllRecentProc();
                break;

            case 1: // Contact list TAB
                this.selectAllContactProc();
                break;

            case 2: // Groups TAB.
                this.groupList.forEach(element => {
                    element.checked = true;
                });
                this.tabInfo.groupsCount = this.tabInfo.groupsTotal;
                break;

            default:
                break;
        }
    },

    selectAllRecentProc: function () {
        this.callLogTemp.forEach(element => {
            element.checked = true;
            this.addOrUpdateSelectedNumberMap(element.phone, element.name);
        });
        this.tabInfo.recentCount = this.tabInfo.recentTotal;
    },

    selectAllContactProc: function () {
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
    },

    /**
     * Verifies whether the master list contact needs to be selected, returning true if selected, false otherwise
     *
     * @param {Array} element Data for the current element
     * @return {boolean}
     */
    checkIfNeedSelected: function (element) {
        if (this.contactsInfo.selectedContactList.length > 0) {
            this.contactsInfo.selectedContactList.forEach(selectedElement => {
                if (selectedElement.contactId == element.contactId) {
                    return true;
                }
            });
        }
        return false;
    },

    unSelectAll() {
        switch (this.tabInfo.tabIndex) {
            case 0: // Recent TAB.
                this.unSelectAllRecentProc();
                break;

            case 1: // Contact list TAB
                this.unSelectAllContactProc();
                break;

            case 2: // Groups TAB.
                this.groupList.forEach(element => {
                    element.checked = false;
                });
                this.tabInfo.groupsCount = 0;
                break;

            default:
                break;
        }
    },

    unSelectAllRecentProc: function () {
        this.callLogTemp.forEach(element => {
            element.checked = false;
            if (this.checkIfSelectedNumber(element.phone)) {
                this.deleteSelectedNumber(element.phone);
            }
        });
        this.tabInfo.recentCount = 0;
    },

    unSelectAllContactProc: function () {
        if (this.contactsInfo.searchLayoutShow) {
            this.contactsInfo.searchContactList.forEach(element => {
                for (var i = 0; i < element.phoneNumbers.length; i++) {
                    if (element.phoneNumbers[i].checked) {
                        element.phoneNumbers[i].checked = false;
                        this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber);
                    }
                }
            });
        } else {
            this.contactsList.forEach(element => {
                for (var i = 0; i < element.phoneNumbers.length; i++) {
                    if (element.phoneNumbers[i].checked) {
                        element.phoneNumbers[i].checked = false;
                        this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber);
                    }
                }
            });
        }
        this.tabInfo.contactsCount = 0;
    },

    /**
     * Refresh selected Map data
     *
     * @param {number} number
     * @param {string} name
     */
    addOrUpdateSelectedNumberMap: function (number, name) {
        if (Utils.isEmpty(number)) {
            return;
        }
        this.selectedNumberMap.set(number.replace(/\s+/g, ''), {
            name: name,
            number: number.replace(/\s+/g, '')
        });
    },

    /**
     * Delete the selected number from the list
     *
     * @param {number} number
     */
    deleteSelectedNumber: function (number) {
        if (Utils.isEmpty(number)) {
            return;
        }
        this.selectedNumberMap.delete(number.replace(/\s+/g, ''));
    },

    /**
     * Verify whether the current number is selected
     *
     * @param {number} number
     * @return {Object}
     */
    checkIfSelectedNumber: function (number) {
        if (Utils.isEmpty(number)) {
            return false;
        }
        return this.selectedNumberMap.has(number.replace(/\s+/g, ''));
    },

    refreshPageMessage() {
        if (this.selectedNumberMap.size > 0) {
            this.titleMessage = this.$t('value.callRecords.titleMessageSelect') + this.selectedNumberMap.size
            + this.$t('value.callRecords.titleMessageUnit');
            this.selectDisabled = false;
            this.checkAllClickButtonStyle();
        } else {
            this.icSelectAll = '/res/image/ic_select all_m.svg';
            this.allSelectMessage = this.$t('value.callRecords.selectAll');
            this.allSelectTextStyle = 'batch-select-text';
            this.titleMessage = this.$t('value.callRecords.titleMessageNoSelect');
            this.selectDisabled = true;
            this.isSelectAll = false;
        }
    },

    checkTabListStyle: function () {
        switch (this.tabInfo.tabIndex) {
            case 0: // Recent TAB to update the call history list
                this.checkRecentListSelectState();
                break;

            case 1: // Contact list TAB
                this.checkContactsListSelectState();
                break;

            case 2: // Groups TAB.
                this.checkGroupsListSelectState();
                break;

            default:
                break;
        }
        this.checkAllClickButtonStyle();
    },

    checkGroupsListSelectState: function () {
        if (this.$app.$def.globalData.batchSelectContactsRefreshFunction.length > 0) {
            this.$app.$def.globalData.batchSelectContactsRefreshFunction.forEach((refreshFunction) => {
                refreshFunction();
            });
        } // Only the property value changes. The lower level group component refreshes its list check box status when it detects the change
    },

    checkRecentListSelectState: function () {
        this.tabInfo.recentCount = 0;
        this.callLogTemp.forEach(element => {
            if (this.checkIfSelectedNumber(element.phone)) { // The number is selected
                element.checked = true;
            } else if (element.checked) {
                element.checked = false;
            }
            if (element.checked) { // According to the result of final judgment, if the status is selected, then the TAB count is increased by 1;
                this.tabInfo.recentCount++;
            }
        });
    },

    checkContactsListSelectState: function () {
        var tempList = this.contactsInfo.searchLayoutShow ? this.contactsInfo.searchContactList : this.contactsList;
        this.tabInfo.contactsCount = 0;
        tempList.forEach(element => {
            for (var i = 0; i < element.phoneNumbers.length; i++) {
                if (this.checkIfSelectedNumber(element.phoneNumbers[i].phoneNumber)) {
                    element.phoneNumbers[i].checked = true;
                } else if (element.phoneNumbers[i].checked) {
                    element.phoneNumbers[i].checked = false;
                }
            }
            if (this.checkIfNeedCount(element)) {
                this.tabInfo.contactsCount++;
            }
        });
        this.contactsInfo.searchLayoutShow ? this.contactsInfo.searchContactList
                                             = tempList : this.contactsList = tempList;
    },

    checkAllClickButtonStyle: function () {
        switch (this.tabInfo.tabIndex) {
            case 0:
                if (this.tabInfo.recentCount == this.tabInfo.recentTotal) {
                    this.changeToFullSelect();
                    this.tabInfo.allClickedRecent = true;
                } else {
                    this.changeToUnFullSelect();
                }
                break;

            case 1:
                if (this.tabInfo.contactsCount == this.tabInfo.contactsTotal) {
                    this.changeToFullSelect();
                    this.tabInfo.allClickedContacts = true;
                } else {
                    this.changeToUnFullSelect();
                }
                break;

            case 2:
                if (this.tabInfo.groupsCount == this.tabInfo.groupsTotal) {
                    this.changeToFullSelect();
                    this.tabInfo.allClickedGroups = true;
                }
                break;
            default:
                break;
        }
    },

    changeToFullSelect: function () {
        this.icSelectAll = '/res/image/ic_select all_filled_m.svg';
        this.allSelectMessage = this.$t('value.callRecords.unSelectAll');
        this.allSelectTextStyle = 'batch-select-text-selected';
    },

    changeToUnFullSelect: function () {
        this.icSelectAll = '/res/image/ic_select all_m.svg';
        this.allSelectMessage = this.$t('value.callRecords.selectAll');
        this.allSelectTextStyle = 'batch-select-text';
    },

    /**
     * The checkbox is also selected or deselected when clicking on a single call record
     *
     * @param {number} index
     */
    clickCallLog(index) {
        this.checkStateChange(index, {
            checked: !this.callLogTemp[index].checked
        });
    },

    doSelect() {
        var checkedList = [];
        this.selectedNumberMap.forEach((value) => {
            checkedList.push(value);
        });
        let contacts = this.dealContactName(checkedList);
        let parameters = {
            contactObjects: JSON.stringify(contacts)
        };
        var result = {
            resultCode: 0,
            want: {
                parameters: parameters
            }
        };
        if (this.selectType == 1) {
        } else {
            featureAbility.finishWithResult(result);
            featureAbility.terminateSelf();
        }
    },

    /**
     * Processes information about the selected contact
     *
     * @param {Array} checkedList
     * @return {boolean}
     */
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
    },

    back() {
        router.back();
    },

    initCallLog() {
        var tempMap = new Map();
        var tempList = [];
        var mergeRule = this.$app.$def.globalData.storage.getSync('call_log_merge_rule', 'from_time');
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.getAllCalls(DAHelper, mergeRule, data => {
            this.$app.$def.globalData.callLogTotalData = data;
            for (var i = 0; i < this.$app.$def.globalData.callLogTotalData.callLogList.length; i++) {
                var element = this.$app.$def.globalData.callLogTotalData.callLogList[i];
                var bgColorIndex = parseInt(element.id, 10) % (this.backgroundColor.length);
                element.portraitColor = this.backgroundColor[bgColorIndex];
                element.suffix = Utils.isEmpty(element.name) ? '' : element.name.substr(element.name.length - 1);
                if (!tempMap.has(Utils.removeSpace(element.phone))) {
                    tempList.push(element);
                    tempMap.set(element.phone, null);
                }
                if (tempList.length > 50) {
                    break;
                }
            }
            this.callLogTemp = tempList;
            this.tabInfo.recentTotal = this.callLogTemp.length;
            this.checkOptionState();
        });
    },

    getPhoneLabelNameById: function (phoneLabelId) {
        var labelName = '';
        switch (parseInt(phoneLabelId, 10)) {
            case 1:
                labelName = this.$t('accountants.house');
                break;

            case 2:
                labelName = this.$t('accountants.phone');
                break;

            case 3:
                labelName = this.$t('accountants.unit');
                break;

            case 4:
                labelName = this.$t('accountants.unit fax');
                break;

            case 5:
                labelName = this.$t('accountants.home fax');
                break;

            case 6:
                labelName = this.$t('accountants.pager');
                break;

            case 7:
                labelName = this.$t('accountants.others');
                break;

            case 12:
                labelName = this.$t('accountants.switchboard');
                break;

            case 99:
                labelName = this.$t('accountants.customize');
                break;

            default:
                break;
        }
        return labelName;
    },

    initContactsList: function () {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        selectContactsAbility.queryContacts(DAHelper, (resultList) => {
            var listTemp = [];
            if (!Utils.isEmptyList(resultList)) {
                for (let element of resultList) {
                    element.name = {};
                    element.name.fullName = element.emptyNameData;
                    element.name.namePrefix = element.namePrefix;
                    element.name.nameSuffix = element.nameSuffix;
                    element.portraitPath = false;
                    if (element.phoneNumbers != null && element.phoneNumbers.length > 0) {
                        element.phoneNumbers.forEach(childEle => {
                            childEle.checked = false;
                            childEle.labelName = this.getPhoneLabelNameById(childEle.labelId);
                            this.initVariableSpan(element);
                        });
                        listTemp.push(element);
                    }
                }
                this.contactsList = listTemp;
                this.tabInfo.contactsTotal = this.contactsList.length;
                this.contactsInfo.contactsListTotal = this.contactsList.length;
            } else {
                LOG.error(TAG + 'select contact list is empty!');
            }
        });
    },

    /**
     * The phone number is resold
     *
     * @param {Object} result
     * @return {Object} result
     */
    duplicateRemoval: function (result) {
        if (Utils.isEmptyList(result.data)) {
            return result;
        }
        var resultList = result.data;
        for (var i = 0; i < resultList.length; i++) {
            var item = resultList[i];
            var phoneNumbersList = [];
            for (var j = item.phoneNumbers.length - 1; j >= 0; j--) {
                item.phoneNumbers[j].checked = false;
                var indexOf = this.indexOf(item.phoneNumbers[j], phoneNumbersList);
                if (indexOf == -1) {
                    phoneNumbersList.push(item.phoneNumbers[j]);
                }
            }
            this.initVariableSpan(item);
            item.phoneNumbers = phoneNumbersList;
        }
        return result;
    },

    /**
     * Click on the event
     *
     * @param {Object} params
     */
    selectClick: function (params) {
        var item = this.contactsList[params.detail.index];
        var index = params.detail.index;
        var indexChild = params.detail.indexChild;
        var speedNumber = item.phoneNumbers[indexChild].phoneNumber;
        this.$app.$def.setSpeedSelectResultData(item, index, indexChild, speedNumber);
    },

    onTextChange: function (text) {

        this.searchText = text.text;
        this.onSearchTextChange(text.text);
    },
    touchStartSearch: function () {
        this.$element('search').focus({
            focus: true
        })
    },
    indexOf: function (item, phoneNumbersList) {
        var index = -1;
        if (Utils.isEmptyList(phoneNumbersList)) {
            return index;
        }
        for (var i = 0; i < phoneNumbersList.length; i++) {
            if (item.phoneNumber == phoneNumbersList[i].phoneNumber) {
                index = i;
                break;
            }
        }
        return index;
    },

    /**
     * Click on the event
     *
     * @param {string} text Value
     */
    onSearchTextChange: function (text) {
        var requestData = {
            page: 0,
            limit: 0,
            likeValue: text
        };
        var internal = 1;
        var sync = 0;
        var messageCode = SEARCH_CONTACTS;
        var actionData = requestData;
        httpcontact.contactHttp(internal, sync, messageCode, actionData, (result) => {
            if (result.code == 0 && result.contactCount > 0) {
                var resultData = this.duplicateRemoval(result);
                this.contactsInfo.searchContactList = resultData.data;
            } else {
                this.searchContactList = [];
            }
            this.refreshSearchList(text);
        });
    },

    refreshSearchList: function (text) {
        this.contactsInfo.searchPhoneNum = this.contactsInfo.searchContactList.length;
        if (Utils.isEmpty(text)) {
            this.contactsInfo.searchLayoutShow = false;
            this.tabInfo.contactsTotal = this.contactsInfo.contactsListTotal;
            this.emptyText = this.$t('value.selectContact.page.empty');
            if (this.tabInfo.tabIndex == 1) {
                this.checkTabListStyle();
            }
        } else if (Utils.isEmptyList(this.contactsInfo.searchContactList)) {
            this.emptyText = this.$t('value.selectContact.page.emptyText');
            this.contactListShow = false;
            this.contactsInfo.searchLayoutShow = false;
            this.tabInfo.contactsTotal = this.contactsInfo.contactsListTotal;
            if (this.tabInfo.tabIndex == 1) {
                this.checkTabListStyle();
            }
        } else {
            this.contactsInfo.searchLayoutShow = true;
            this.tabInfo.contactsTotal = this.contactsInfo.searchContactList.length;
            this.contactListShow = true;
            this.emptyText = this.$t('value.selectContact.page.empty');
            if (this.tabInfo.tabIndex == 1) {
                this.checkTabListStyle();
            }
        }
    },

    /**
     * Contact the main list or search list by clicking the checkbox event
     *
     * @param {Object} e event事件
     */
    changeContactState: function (e) {
        this.checkStateChange(e.detail.contactIndex, e);
    },

    /**
     * Assign custom attributes in preparation for later variable font searches
     *
     * @param {Object} item Contact data
     */
    initVariableSpan: function (item) {
        var matchString = Utils.getMatchedString(item.emptyNameData, this.searchText);
        if (Utils.isEmpty(matchString) || Utils.isEmpty(this.searchText.trim())) {
            item.name.searchTextStart = '';
            item.name.searchTextMiddle = '';
            item.name.searchTextEnd = item.emptyNameData;
        } else {
            var name = item.emptyNameData;
            var index = name.indexOf(matchString);
            item.name.searchTextStart = name.substr(0, index);
            item.name.searchTextMiddle = name.substr(index, matchString.length);
            item.name.searchTextEnd = name.substr(index + matchString.length);
        }
        for (var i = 0; i < item.phoneNumbers.length; i++) {
            var phoneNumber = item.phoneNumbers[i].phoneNumber;
            var matchStringPhone = Utils.getMatchedString(phoneNumber, this.searchText);
            if (Utils.isEmpty(matchStringPhone) || Utils.isEmpty(this.searchText.trim())) {
                item.phoneNumbers[i].startPhone = '';
                item.phoneNumbers[i].middlePhone = '';
                item.phoneNumbers[i].endPhone = phoneNumber;
            } else {
                var phoneIndex = phoneNumber.indexOf(matchStringPhone);
                item.phoneNumbers[i].startPhone = phoneNumber.substr(0, phoneIndex);
                item.phoneNumbers[i].middlePhone = phoneNumber.substr(phoneIndex, matchStringPhone.length);
                item.phoneNumbers[i].endPhone = phoneNumber.substr(phoneIndex + matchStringPhone.length);
            }
        }
    },

    /**
     * Add a contact from the group list
     *
     * @param {Object} e
     */
    addCheckedContact(e) {
        e.detail.checkedList.forEach(element => {
            this.selectedNumberMap.set(element.number.replace(/\s+/g, ''), element);
        });
        this.refreshPageMessage();
    },

    /**
     * Delete a contact from the group list
     *
     * @param {Object} e
     */
    deleteCheckedContact(e) {
        e.detail.checkedList.forEach(element => {
            this.selectedNumberMap.delete(element.number.replace(/\s+/g, ''));
        });
        this.refreshPageMessage();
    },

    /**
     * Example Change the group list status
     *
     * @param {Object} e
     */
    changeGroupShowState(e) {
        this.showGroupList = e.detail.showGroupList;
    },
};