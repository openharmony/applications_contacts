/**
 * @file Sorting out Contacts
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
import LOG from '../../../../utils/ContactsLog.js';

var TAG = 'Manage...:';

export default {
    data: {},

// Initialization page
    onReady() {
        LOG.log(TAG + 'onReady');
    },
    onShow() {
        LOG.log(TAG + 'onShow');
    },
    onHide() {
        LOG.log(TAG + 'onHide');
    },
    mergeContactsClicked: function () {
        router.push({
            uri: 'pages/contacts/settings/manage/merge/merge',
            params: {},
        });
    },
    deleteBatchClicked: function () {
        router.push({
            uri: 'pages/contacts/selectContactsList/selectContactsList',
            params: {
                type: 'deleteBatchContacts'
            },
        });
    },
    recentlyDeleteClicked: function () {
        router.push({
            uri: 'pages/contacts/settings/manage/recentlydel/recentlydel',
            params: {},
        });
    },

// Return to the upper page
    back: function () {
        router.back();
    }
};