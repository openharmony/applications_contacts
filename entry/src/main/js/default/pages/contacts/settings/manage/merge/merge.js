/**
 * @file Merge contacts
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
import LOG from '../../../../../utils/ContactsLog.js';
import Constants from '../../../../../common/constants/Constants.js';
import mergeService from '../../../../../../default/model/mergeModel.js';

var TAG = 'Merge...:';

export default {
    data: {
        mergeList: [],
        mergeTitle: '',
        checkedCount: 0,
        icMergeM: '/res/image/ic_delete_m.svg',
        icSelectAll: '/res/image/ic_select all_m.svg',
        icFreeSpace: '/res/image/ic_contacts_favorite_me_36.svg',
        allSelectMessage: '',
        isSelectAll: false,
        language: '',
        mergeDisabled: true,
        isFree: false,
        timeOutId: ''
    },

    onInit: function () {
        LOG.info(TAG + 'merge onInit --------------end');
    },
    onDestroy: function () {
    },
    onReady: function () {
        LOG.info(TAG + 'merge onReady --------------end');
    },

    onShow: function () {
        this.checkedCount = this.mergeList.length;
        this.language = 'zh';
        this.mergeInitContact(2013, null);
        LOG.info(TAG + 'merge onShow --------------end');
    },

    doMerge: function () {
        LOG.info(TAG + 'merge contacts--------------');
        this.$element('progressDialog').show();
        var checkedList = [];
        var unCheckedList = [];
        var contactIds = [];
        if (this.isSelectAll) { // Select all merge
            checkedList = this.mergeList;
            this.mergeList.forEach(element => {
                element.contactBeans.forEach(item => {
                    contactIds.push(item.contactId);
                });
            });
            this.mergeList = [];
        } else { // Not all selected
            this.mergeList.forEach(element => {
                if (element.checked) {
                    checkedList.push(element);
                    element.contactBeans.forEach(item => {
                        contactIds.push(item.contactId);
                    });
                } else {
                    unCheckedList.push(element);
                }
            });
            this.mergeList = unCheckedList;
        }
        this.checkedCount = 0;
        var data = {};
        data.contactIds = contactIds;
        clearTimeout(this.timeOutId);
        this.timeOutId = setTimeout(() => {
            this.mergeContactData(2014, data);
        }, 1);
        this.$element('progressDialog').close();
    },

    clickCheckedAll: function () {
        LOG.log(TAG + 'select all contacts');
        if (!this.isSelectAll) {
            // Select all
            this.selectAll();
        } else {
            // Deselect all
            this.unSelectAll();
        }
        this.refreshPageTabs();
    },

    selectAll: function () {
        this.checkedCount = 0; // Clear the selected count and increase it again
        this.mergeList.forEach(element => {
            element.checked = true;
            this.checkedCount++;
        });
    },

    unSelectAll: function () {
        this.mergeList.forEach(element => {
            element.checked = false;
            if (this.checkedCount > 0) {
                this.checkedCount--;
            }
        });
    },

    changeCheckState: function (index, e) {
        LOG.info(TAG + 'index is=' + index);
        this.mergeList[index].checked = e.checked;
        e.checked ? this.checkedCount++ : this.checkedCount--;
        this.refreshPageTabs();
    },

    refreshPageTabs: function () {
        LOG.info(TAG + 'refreshPageTabs checkedCount' + this.checkedCount);
        if (this.checkedCount > 0) {
            switch (this.language) {
                case 'zh':
                    this.mergeTitle = this.$t('value.contacts.managePage.mergePage.select')
                    + this.checkedCount + this.$t('value.contacts.managePage.mergePage.count');
                    break;
                case 'en':
                    this.mergeTitle = this.checkedCount + this.$tc('value.contacts.managePage.mergePage'
                    + '.titleMessageSelect', this.checkedCount);
                    break;
                default:
                    this.mergeTitle = '';
                    break;
            }
            this.mergeDisabled = false;
            if (this.checkedCount == this.mergeList.length) { // Select all button status refresh
                this.icSelectAll = '/res/image/ic_select all_filled_m.svg';
                this.allSelectMessage = this.$t('value.contacts.managePage.mergePage.unSelectAll');
                this.isSelectAll = true;
            } else {
                this.icSelectAll = '/res/image/ic_select all_m.svg';
                this.allSelectMessage = this.$t('value.contacts.managePage.mergePage.selectAll');
                this.isSelectAll = false;
            }
        } else {
            this.checkedCount = 0;
            this.icSelectAll = '/res/image/ic_select all_m.svg';
            this.allSelectMessage = this.$t('value.contacts.managePage.mergePage.selectAll');
            this.mergeTitle = this.$t('value.contacts.managePage.mergePage.noSelect');
            this.mergeDisabled = true;
            this.isSelectAll = false;
        }
    },

    onBackPress() {
        LOG.info(TAG + 'onBackPress mergeList.length' + this.mergeList.length);
        if (this.mergeList.length == 0) {
            return false;
        }
        this.$element('saveDialog').show();
        return true;
    },

    back: function () {
        router.back();
    },

    discardClick: function () {
        router.back();
    },
    cancelClick: function () {
        this.$element('saveDialog').close();
    },

    /**
     * Query and merge contact list data
     *
     * @param {number} code 2005 FA and PA access protocol code
     * @param {string} data  contactId The contact ID
     */
    mergeInitContact: function (code, data) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        mergeService.autoMergeContacts(DAHelper, data, result => {
            if (result.code == 0 && result.mergeList.length > 0) {
                this.mergeList = result.mergeList;
                this.mergeList.forEach(element => {
                    if (element.checked) {
                        this.checkedCount++;
                    }
                });
            } else if (result.code == 0 && result.mergeList.length == 0) {
                this.isFree = true;
            } else {
                prompt.showToast({
                    message: 'Failed to init data.'
                });
            }
            this.refreshPageTabs();
        });
    },

    /**
     * Merge contact list data
     *
     * @param {number} code 2005 FA and PA access protocol code
     * @param {number} data contactId The contact ID
     */
    mergeContactData: function (code, data) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        mergeService.mergeContacts(DAHelper, data, result => {
            if (result == 0) {
                this.refreshPageTabs();
                this.isFree = this.mergeList.length == 0 ? true : false;
                this.$element('progressDialog').close();
            } else {
                prompt.showToast({
                    message: 'Failed to merge data.'
                });
            }
        });
    }
};