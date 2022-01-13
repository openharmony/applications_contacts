/**
 * @file Recent Contact list
 */
/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import router from '@system.router';
import prompt from '@system.prompt';
import groupReq from '../../../../../../default/model/GroupsModel.js';
import LOG from '../../../../../utils/ContactsLog.js';
import Constants from '../../../../../../default/common/constants/Constants.js';
import backgroundColor from '../../../../../common/constants/color.js';

var TAG = 'recentContactsList...:';

export default {
    data: {
        groupItem: {
            title: '',
            endDate: 0,
            startDate: 0
        }, // Group object
        contactCount: 0,
        layoutState: true,
        dialogInputActive: false, // The input box of dialog is not activated by default
        contactsList: [], // Data list
        operateItem: {}, // Long press and hold the contact item
        newGroupName: '',
        showEmptyPage: false,
        menuContactName: '', // Long press the title of the menu
        page: 0,
        limit: 20, // Number of entries per page
        backgroundColor: backgroundColor.Color
    },
    onInit() {
        LOG.info(TAG + 'onInit success');
        this.conciseLayoutInit();
        this.getContactsList();
    },
    onShow() {
        LOG.info(TAG + 'onShow success');
        this.page = 0;
    },

    conciseLayoutInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_concise_layout_switch', 'false');
        this.layoutState = data == 'true' ? false : true;
    },

    requestItem: function () {
        this.page++;
    },
    getContactsList: function () {
        LOG.info(TAG + 'start getContactsList');
        var actionData = {
            page: this.page,
            limit: this.limit,
            endDate: this.groupItem.endDate,
            startDate: this.groupItem.startDate
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryRecentContacts(DAHelper, actionData, result => {
            if (result.code == 0) {
                if (result.resultList) {
                    this.contactCount = result.totalCount;
                    if (this.page == 0) {
                        this.contactsList = result.resultList;
                    } else {
                        this.contactsList = this.contactsList.concat(result.resultList);
                    }
                } else {
                    this.contactsList = [];
                }
            } else {
                prompt.showToast({
                    message: 'Failed to init data.'
                });
            }
            if (this.contactsList.length == 0) {
                this.showEmptyPage = true;
            } else {
                this.showEmptyPage = false;
            }
        });
        if (this.contactsList.length == 0) {
            this.showEmptyPage = true;
        } else {
            this.showEmptyPage = false;
        }
    },

    jumpToContactDetail: function (item) {
        LOG.info(TAG + 'jumpToContactDetail item' + item);
        router.push({
            uri: 'pages/contacts/contactDetail/contactDetail',
            params: {
                contactId: item.contactId,
                isNewSource: true
            }
        });
    },

    back: function () {
        router.back();
    },

    clickSendMsg: function () {
        router.push({
            uri: 'pages/contacts/groups/selectGroupMembers/selectGroupMembers',
            params: {
                groupId: 1,
                type: 'sendMsg',
                pageParams: 'recentContacts',
                endDate: this.groupItem.endDate,
                startDate: this.groupItem.startDate
            },
        });
    },

    clickSendEmail: function () {
        router.push({
            uri: 'pages/contacts/groups/selectGroupMembers/selectGroupMembers',
            params: {
                groupId: 1,
                type: 'sendEmail',
                pageParams: 'recentContacts',
                endDate: this.groupItem.endDate,
                startDate: this.groupItem.startDate
            },
        });
    }
};
