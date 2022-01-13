/**
 * @file Resume Deleting contacts
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
import LOG from '../../../../../../utils/ContactsLog.js';
import recoverService from '../../../../../../model/recoverModel.js';
import recentlyDelService from '../../../../../../model/recentlydelModel.js';
import Constants from '../../../../../../common/constants/Constants.js';
import prompt from '@system.prompt';

var TAG = 'Recover...:';

export default {
    data: {
        props: ['defaultRecentlyList'],
        icDeleteM: '/res/image/ic_delete_m.svg',
        icFreeSpace: '/res/image/ic_contacts_favorite_me_36.svg',
        icSelectAll: '/res/image/ic_select all_m.svg',
        icRecoverM: '/res/image/ic_delete_m.svg',
        allSelectMessage: '',
        isFree: false,
        recentlyTitle: '',
        checkedCount: 0,
        language: '',
        deleteDisabled: true,
        recoverDisabled: true,
        isSelectAll: false,
        warningInfo: '',
        dialogHeight: '',
        bottom: '',
        recentlyList: []
    },

    onInit() {
        LOG.info(TAG + 'onInit success');
        this.language = 'zh';
        switch (this.language) {
            case 'zh':
                this.dialogHeight = '255px';
                this.bottom = '0px';
                break;
            case 'en':
                this.dialogHeight = '215px';
                this.bottom = '30px';
                break;
            default:
                break;
        }
        this.recentlyList = this.defaultRecentlyList;
        this.recentlyList[this.index].checked = true;
        this.checkedCount++;
        this.refreshPageTabs();
    },
    onReady() {
        LOG.log(TAG + 'onReady');
    },
    onShow() {
        LOG.log(TAG + 'onShow');
    },
    onHide() {
        LOG.log(TAG + 'onHide');
    },
    onDestroy() {
    },
    doRecover: function () {
        this.$element('recoverDialog').show();
        this.$element('recoverDialog').close();
        var data = {
            contactIds: []
        };
        var unCheckList = [];
        this.recentlyList.forEach((element) => {
            if (element.checked) {
                data.contactIds.push(element.contactId);
            } else {
                unCheckList.push(element);
            }
        });
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        recoverService.recoverRlyDelContacts(DAHelper, data, result => {
            LOG.info(TAG + 'doRecover result');
            if (result  == 0) {
                this.recentlyList = unCheckList;
                this.$emit('eventType', {
                    type: 'recover',
                    isRecover: true,
                    checkedCount: this.checkedCount,
                    recentlyList: this.recentlyList
                });
            } else {
                prompt.showToast({
                    message: 'Failed to recover contact.'
                });
            }
        });
    },

    doDelete: function () {
        LOG.info(TAG + 'doDelete isSelectAll');
        if (this.isSelectAll) {
            this.warningInfo = this.$t('value.contacts.managePage.recentlyPage.deleteAllWarningInfo');
        } else {
            switch (this.checkedCount) {
                case 1:
                    this.warningInfo = this.$t('value.contacts.managePage.recentlyPage.deleteOneWarningInfo');
                    break;
                default:
                    this.warningInfo = this.language == 'zh' ? this.checkedCount + this.$t('value.contacts.managePage'
                    + '.recentlyPage.deleteOthersWarningInfo') : this.$t('value.contacts.managePage.recentlyPage'
                    + '.deleteOthersPrefix') + this.checkedCount + this.$t('value.contacts.managePage'
                    + '.recentlyPage.deleteOthersSuffix');
                    break;
            }
        }
        this.$element('deleteDialog').show();
    },
    deleteClick: function () {
        this.$element('deleteDialog').close();
        var data = {
            contactIds: []
        };
        var unCheckList = [];
        this.recentlyList.forEach((element) => {
            LOG.info(TAG + 'deleteClick element' + element);
            if (element.checked) {
                data.contactIds.push(element.contactId);
            } else {
                unCheckList.push(element);
            }
        });
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        recentlyDelService.clearRecentlyDelContacts(DAHelper, data, result => {
            if (result  == 0) {
                this.recentlyList = unCheckList;
                this.isFree = true;
                this.$emit('eventType', {
                    type: 'delete',
                    isRecover: true,
                    recentlyList: this.recentlyList
                });
            } else {
                prompt.showToast({
                    message: 'Failed to completely delete contact.'
                });
            }
        });
    },
    cancelClick: function () {
        this.$element('deleteDialog').close();
    },
    onClickChange: function (index) {
        LOG.info(TAG + 'onClickChange index' + index);
        this.recentlyList[index].checked = !this.recentlyList[index].checked;
        this.recentlyList[index].checked ? this.checkedCount++ : this.checkedCount--;
        this.refreshPageTabs();
    },

    clickCheckedAll: function () {
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
        LOG.info(TAG + 'select All this');
        this.recentlyList.forEach(element => {
            element.checked = true;
            this.checkedCount++;
        });
    },

    unSelectAll: function () {
        LOG.info(TAG + 'unselect All this');
        this.recentlyList.forEach(element => {
            element.checked = false;
            if (this.checkedCount > 0) {
                this.checkedCount--;
            }
        });
    },

    changeCheckState: function (index, e) {
        LOG.info(TAG + 'changeCheckState index' + index);
        this.recentlyList[index].checked = e.checked;
        e.checked ? this.checkedCount++ : this.checkedCount--;
        this.refreshPageTabs();
    },

    refreshPageTabs: function () {
        LOG.info(TAG + 'refreshPageTabs checkedCount' + this.checkedCount);
        if (this.checkedCount > 0) {
            switch (this.language) {
                case 'zh':
                    this.recentlyTitle = this.$t('value.contacts.managePage.recentlyPage.select')
                    + this.checkedCount + this.$t('value.contacts.managePage.recentlyPage.count');
                    break;
                case 'en':
                    this.recentlyTitle = this.checkedCount + this.$tc('value.contacts.managePage'
                    + '.recentlyPage.titleMessageSelect', this.checkedCount);
                    break;
                default:
                    this.recentlyTitle = '';
                    break;
            }
            this.deleteDisabled = false;
            this.recoverDisabled = false;
            if (this.checkedCount == this.recentlyList.length) { // Select all button status refresh
                this.icSelectAll = '/res/image/ic_select all_filled_m.svg';
                this.allSelectMessage = this.$t('value.contacts.managePage.recentlyPage.unSelectAll');
                this.isSelectAll = true;
            } else {
                this.icSelectAll = '/res/image/ic_select all_m.svg';
                this.allSelectMessage = this.$t('value.contacts.managePage.recentlyPage.selectAll');
                this.isSelectAll = false;
            }
        } else {
            this.checkedCount = 0;
            this.icSelectAll = '/res/image/ic_select all_m.svg';
            this.allSelectMessage = this.$t('value.contacts.managePage.recentlyPage.selectAll');
            this.recentlyTitle = this.$t('value.contacts.managePage.recentlyPage.noSelect');
            this.deleteDisabled = true;
            this.recoverDisabled = true;
            this.isSelectAll = false;
        }
    },

    back: function () {
        router.back();
    }
};