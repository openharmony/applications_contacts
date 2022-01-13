/**
 * @file Sharing a Contact List
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
import prompt from '@system.prompt';
import LOG from '../../../../utils/ContactsLog.js';
import contactsService from '../../../../../default/model/ContactModel.js';
import groupReq from '../../../../../default/model/GroupsModel.js';
import Constants from '../../../../../default/common/constants/Constants.js';

var TAG = 'shareContactsList...:';

export default {
    data: {
        icShare: '/res/image/ic_share_m.svg',
        title: '', // title
        groupId: 0,
        showEmptyPage: false, // The list page is empty
        noMatchingResults: false, // The displayed search results are empty
        checkedNum: 0, // Number of contacts selected
        contactsList: [], // contact list
        matchingResults: [], // search result
        showSelectAll: true, // Select all,
        addMemberDisabled: true,
        showContactList: true,
        showMatchContactsList: false,
        contactId: '',
        pressIndex: 0,
        index: ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q',
        'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '…']
    },
    onInit() {
        LOG.info(TAG + 'onInit success');
        this.getContactsList();
        this.initTitle();
    },
    onShow() {
        LOG.info(TAG + 'onShow success');
        if (!this.contactsList || this.contactsList.length == 0) {
            this.showEmptyPage = true;
        }
    },
    onDestroy() {
    },
    getContactsList: function () {
        this.page = 0;
        var actionData = {
            page: this.page,
            limit: 200,
            queryContactsType: 'all'
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactsService.queryContacts(DAHelper, actionData, (result) => {
            LOG.info(TAG + 'queryContacts success. result.resultList = ' + result.resultList.length);
            if (result.code == 0) {
                result.resultList.forEach((item) => {
                    item.checked = false;
                });
                this.contactsList = result.resultList;
            } else {
                prompt.showToast({
                    message: 'Failed to init data.'
                });
            }
        });

    },
    clickSearch: function (e) {
        LOG.info(TAG + 'clickSearch e');
        // Search input box
        if (e.text) {
            this.showContactList = false;
            this.showMatchContactsList = true;
            this.searchRequest(e.text);
        } else {
            this.showContactList = true;
            this.showMatchContactsList = false;
            this.noMatchingResults = false;
        }
    },

    /**
     * Search request background
     *
     * @param {string} keyText Input box content
     */
    searchRequest: function (keyText) {
        var requestData = {
            page: 0,
            limit: 0,
            likeValue: keyText
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.searchContacts(DAHelper, requestData, result => {
            if (result.code == 0 && result.contactCount > 0) {
                this.matchingResults = result.data;
            } else {
                this.matchingResults = [];
                LOG.error(TAG + 'select contact request error');
            }
            if (this.matchingResults && this.matchingResults.length == 0) {
                this.noMatchingResults = true;
            } else {
                this.noMatchingResults = false;
            }
            LOG.info(TAG + 'select search request  result');
        });
    },
    itemClick: function (item) {
        LOG.info(TAG + 'itemClick item');
        item.checked = !item.checked;
        var checkedList = [];
        this.contactsList.forEach((contact) => {
            if (contact.checked) {
                checkedList.push(contact);
            }
        });
        if (item.checked) {
            this.checkedNum++;
            if (checkedList.length == this.contactsList.length) {
                this.showSelectAll = false;
            }
        } else {
            this.checkedNum--;
            this.showSelectAll = true;
        }
        if (checkedList.length == 0) {
            this.addMemberDisabled = true;
        } else {
            this.addMemberDisabled = false;
        }
        this.initTitle();
    },
    // Share contacts
    shareContacts: function () {
        var checkedList = [];
        this.contactsList.forEach((item) => {
            if (item.checked) {
                checkedList.push(item);
            }
        });
        LOG.info(TAG + 'shareContacts contactsList' + this.contactsList);
        prompt.showToast({
            message: 'Call share vCard three parties'
        });
    },
    clickSelectAll: function () {
        this.contactsList.forEach((item) => {
            item.checked = true;
        });
        this.checkedNum = this.contactsList.length;
        this.showSelectAll = false;
        this.addMemberDisabled = false;
        this.initTitle();
    },
    clickCancelSelectAll: function () {
        this.contactsList.forEach((item) => {
            item.checked = false;
        });
        this.checkedNum = 0;
        this.showSelectAll = true;
        this.addMemberDisabled = true;
        this.initTitle();
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
};
