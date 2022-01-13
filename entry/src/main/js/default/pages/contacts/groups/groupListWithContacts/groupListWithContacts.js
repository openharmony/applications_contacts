/**
 * @file Contact Group List
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
import router from '@system.router';
import groupReq from '../../../../../default/model/GroupsModel.js';
import LOG from '../../../../utils/ContactsLog.js';
import Constants from '../../../../../default/common/constants/Constants.js';

var TAG = 'groupListWithContacts...:';

export default {
    props: ['titleShow', 'checkItemState', 'checkedNumberMap'],
    data: {
        page: 0, // Initial load current page
        limit: 20,
        groupList: [],
        favoritesItem: {
            contactBeans: [],
            checked: false,
            expand: false,
            contactCount: 0,
        },
        phoneNumberLabelNames: [],
        title: '', // Page title
        layoutState: true, // Introduction layout
        checkedNum: 0 // Selected quantity
    },
    onInit() {
        LOG.info(TAG + 'onInit success');
        this.title = this.$t('value.contacts.groupsPage.noSelect');

        this.phoneNumberLabelNames = [this.$t('accountants.house'), this.$t('accountants.phone'),
        this.$t('accountants.unit'), this.$t('accountants.unit fax'), this.$t('accountants.home fax'),
        this.$t('accountants.pager'), this.$t('accountants.others'), '', '', '', '',
        this.$t('accountants.switchboard')];

        this.conciseLayoutInit();
        var requestData = {
            page: this.page,
            limit: this.limit,
            phoneNumberLabelNames: this.phoneNumberLabelNames,
            filterItem: 'phone'
        };
        this.getGroupList(requestData);
        this.$app.$def.globalData.batchSelectContactsRefreshFunction.push(()=> {
            this.groupList.forEach((groupItem) => {
                this.refreshContactCheckState(groupItem);
            });
            this.refreshContactCheckState(this.favoritesItem);
        });
    },

    conciseLayoutInit: function () {
        LOG.info(TAG + 'conciseLayoutInit success');
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_concise_layout_switch', 'false');
        this.layoutState = data == 'true' ? false : true;
    },

    refreshCheckState: function () {
        this.groupList.forEach((groupItem) => {
            LOG.info(TAG + 'refreshCheckState groupItem' + groupItem);
            this.refreshContactCheckState(groupItem);
        });
        this.refreshContactCheckState(this.favoritesItem);
    },
    refreshContactCheckState: function (groupItem) {
        LOG.info(TAG + 'refreshContactCheckState groupItem' + groupItem);
        groupItem.checked = false;
        var expandChecked = true; // Do you want to select a group;
        var tempContactBeans = [];
        groupItem.contactBeans.forEach((contactItem) => {
            if (contactItem.phoneNumbers && contactItem.phoneNumbers.length != 0) {
                for (var i = 0; i < contactItem.phoneNumbers.length; i++) {
                    var phoneNumber = contactItem.phoneNumbers[i];
                    if (this.checkedNumberMap.has(phoneNumber.phoneNumber.replace(/\s+/g, ''))) { // Selected
                        phoneNumber.checked = true;
                    } else {
                        if (phoneNumber.checked) {
                            phoneNumber.checked = false;
                        }
                        if (i == 0) { // When the first contact in the group is not selected, the group is not selected
                            expandChecked = false;
                        }
                    }
                }
                tempContactBeans.push(contactItem);
            }
        });
        groupItem.contactBeans = tempContactBeans;
        if (expandChecked) {
            groupItem.checked = true;
        }
    },

    // Cache paging load
    requestItem: function () {
        this.page++;
        var requestData = {
            page: this.page,
            limit: this.limit,
            phoneNumberLabelNames: this.phoneNumberLabelNames,
            filterItem: 'phone'
        };
        LOG.info(TAG + 'requestItem requestData' + requestData);
        this.getGroupList(requestData);
    },

    // Get group list
    getGroupList: function (actionData) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.getGroupListAndContacts(DAHelper, actionData, result=>{
            if (result.code == 0) {
                LOG.info(TAG + 'get group list come code');
                if (result.resultList.length > 0) {
                    // Traverse the default values for the check boxes
                    result.resultList.forEach((groupItem) => {
                        groupItem.checked = false;
                        groupItem.expand = false;
                        var tempContactBeans = [];
                        if (groupItem.contactBeans && groupItem.contactBeans.length > 0) {
                            groupItem.contactBeans.forEach((contactItem) => {
                                if (contactItem.phoneNumbers && contactItem.phoneNumbers.length != 0) {
                                    contactItem.phoneNumbers.forEach((phoneNumber) => {
                                        phoneNumber.checked = false;
                                    });
                                    tempContactBeans.push(contactItem);
                                }
                                LOG.info(TAG + 'logMessage contactItem ' + contactItem);
                            });
                            groupItem.contactBeans = tempContactBeans;
                            if (groupItem.contactCount != 0 && tempContactBeans.length != 0) {
                                this.groupList = this.groupList.concat(groupItem);
                            }
                        }
                    });
                }
            } else {
                LOG.error(TAG + 'query groups code is ' + result.code);
            }
        });
    },

    groupExpand: function (groupItem) {
        LOG.info(TAG + 'groupExpand groupItem' + groupItem);
        groupItem.expand = !groupItem.expand;
    },

    groupItemChecked: function (groupItem) {
        LOG.info(TAG + 'groupItemChecked groupItem' + groupItem);
        groupItem.checked = !groupItem.checked;
        let temNum = 0;
        var checkedList = [];
        var keyNumber = '';
        if (groupItem.checked) {
            groupItem.contactBeans.forEach((contact) => {
                if (!contact.phoneNumbers[0].checked) {
                    temNum++;
                }
                contact.phoneNumbers[0].checked = true;
                keyNumber = contact.phoneNumbers[0].phoneNumber.replace(/\s+/g, '');
                if (!this.checkedNumberMap.has(keyNumber)) {
                    checkedList.push({
                        name: contact.emptyNameData,
                        number: keyNumber
                    });
                }
                this.initOtherGroupCheckbox(0, contact);
            });
            this.checkedNum = this.checkedNum + temNum;
            if (checkedList.length > 0) {
                this.$emit('addCheckedContact', {
                    checkedList: checkedList // Selected number to add
                });
            }
        } else {
            groupItem.contactBeans.forEach((contact) => {
                LOG.info(TAG + 'groupItemChecked contact' + contact);
                contact.phoneNumbers.forEach((phoneNum, phoneNumIndex) => {
                    if (phoneNum.checked) {
                        temNum++;
                        checkedList.push({
                            name: contact.emptyNameData,
                            number: phoneNum.phoneNumber.replace(/\s+/g, '')
                        });
                    }
                    phoneNum.checked = false;
                    this.initOtherGroupCheckbox(phoneNumIndex, contact);
                });
            });
            if (checkedList.length > 0) {
                this.$emit('deleteCheckedContact', {
                    checkedList: checkedList // Selected number to delete
                });
            }
            this.checkedNum = this.checkedNum - temNum;
        }
        this.initTitle();
    },

    contactItemClick: function (phoneNumIndex, contactItem, groupItem) {
        LOG.info(TAG + 'contactItemClick contactItem' + contactItem);
        contactItem.phoneNumbers[phoneNumIndex].checked = !contactItem.phoneNumbers[phoneNumIndex].checked;
        if (contactItem.phoneNumbers[phoneNumIndex].checked) {
            this.checkedNum++;
            this.initOtherGroupCheckbox(phoneNumIndex, contactItem);
            this.$emit('addCheckedContact', {
                checkedList: [{
                                  name: contactItem.emptyNameData,
                                  number: contactItem.phoneNumbers[phoneNumIndex].phoneNumber.replace(/\s+/g, '')
                              }] // Selected number to add
            });
        } else {
            this.checkedNum--;
            this.initOtherGroupCheckbox(phoneNumIndex, contactItem);
            this.$emit('deleteCheckedContact', {
                checkedList: [{
                                  name: contactItem.emptyNameData,
                                  number: contactItem.phoneNumbers[phoneNumIndex].phoneNumber.replace(/\s+/g, '')
                              }] // Selected number to cancel
            });
        }
        this.initTitle();
    },

    initOtherGroupCheckbox: function (phoneNumIndex, contactItem) {
        LOG.info(TAG + 'initOtherGroupCheckbox contactItem' + contactItem);
        // Traverse other groups. If the same contact is selected, other groups also need to be selected
        this.groupList.forEach((group) => {
            this.initGroupContactsCheckBox(group, phoneNumIndex, contactItem);
        });
        this.initGroupContactsCheckBox(this.favoritesItem, phoneNumIndex, contactItem);
    },

    initGroupContactsCheckBox: function (group, phoneNumIndex, contactItem) {
        LOG.info(TAG + 'initGroupContactsCheckBox contactItem' + contactItem);
        var checkedNum = 0;
        group.contactBeans.forEach((contact) => {
            // The same number under the same contact has the same selected status
            if (contact.contactId == contactItem.contactId) {
                contact.phoneNumbers[phoneNumIndex].checked = contactItem.phoneNumbers[phoneNumIndex].checked;
            }

            if (contact.phoneNumbers[0].checked) {
                checkedNum++;
            }
        });
        if (group.contactBeans.length == checkedNum) {
            group.checked = true;
        } else {
            group.checked = false;
        }
    },

    initTitle: function () {
        if (this.checkedNum != 0) {
            this.title = this.$t('value.contacts.groupsPage.alreadySelect').replace('num', this.checkedNum + '');
        } else {
            this.title = this.$t('value.contacts.groupsPage.noSelect');
        }
    },

    back: function () {
        router.back();
    },

    onDestroy() {
        this.$app.$def.globalData.batchSelectContactsRefreshFunction.pop();
    },
};
