/**
 * @file recent contacts
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
import LOG from '../../../../utils/ContactsLog.js';

var TAG = 'recentContacts...:';

/**
 * @file recent contacts
 */
export default {
    data: {
        title: 'World',
        recentContactsList: [],
        count1: 0,
        count2: 0,
        count3: 0,
        count4: 0
    },
    onInit() {
        LOG.info(TAG + 'onInit success');
        this.recentContactsList = [
            {
                name: this.$t('value.contacts.groupsPage.oneWeekContacts'),
                count: this.count1,
                id: 1
            },
            {
                name: this.$t('value.contacts.groupsPage.oneMonthContacts'),
                count: this.count2,
                id: 2
            },
            {
                name: this.$t('value.contacts.groupsPage.threeMonthContacts'),
                count: this.count3,
                id: 3
            },
            {
                name: this.$t('value.contacts.groupsPage.moreThreeMonthContacts'),
                count: this.count4,
                id: 4
            }];
    },

    itemClick: function (item) {
        LOG.info(TAG + 'itemClick item' + item);
        var params = {
            title: item.name
        };
        switch (item.id) {
            case 1: // 7 days
                params.startDate = 0;
                params.endDate = 7;
                break;
            case 2: // one month
                params.startDate = 7;
                params.endDate = 30;
                break;
            case 3: // three months
                params.startDate = 30;
                params.endDate = 90;
                break;
            case 4: // More than three months
                params.startDate = -1;
                params.endDate = 90;
                break;
            default:
                LOG.error(TAG + 'ERROR: item id is ' + item);
                break;
        }
        router.push({
            uri: 'pages/contacts/groups/recentContacts/recentContactsList/recentContactsList',
            params: {
                groupItem: params
            },
        });
    },

    back: function () {
        router.back();
    },
    onDestroy() {
    },
};
