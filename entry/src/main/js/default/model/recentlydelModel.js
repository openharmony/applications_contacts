/**
 * @file: Recently deleted model
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
import LOG from '../utils/ContactsLog.js';
import ohosDataAbility from '@ohos.data.dataability';
import Constants from '../common/constants/Constants.js';

var TAG = 'recentlydelModel';

export default {

    /**
     * Query recently deleted contacts
     *
     * @param {string} DAHelper Database address
     * @param {Object} data
     * @param {Object} callback
     */
    queryRecentlyDelContacts: async function (DAHelper, data, callback) {
        var resultColumns = ['contact_id as contactId', 'display_name as name', 'delete_time as deleteTime'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        var now = Date.now();
        LOG.info(TAG + 'queryRecentlyDelContacts' + 'now is =' + now);
        var difValue = now - (30 * 24 * 3600 * 1000);
        var BeforeThirtyTime = difValue < 0 ? 0 : difValue;
        LOG.info(TAG + 'queryRecentlyDelContacts' + '30 days before is =' + BeforeThirtyTime);
        conditionArgs.greaterThan('delete_time', BeforeThirtyTime).orderByDesc('id').offsetAs(data.page * data.limit)
            .limitAs(data.limit).groupBy('contact_id');
        var result = {};
        LOG.info(TAG + 'queryRecentlyDelContacts' + 'RecentlyDelContacts get DAHelper.query --------------start');
        var resultSet = await DAHelper.query(Constants.uri.CONTACTS_URI_PREFIX + 'deleted_raw_contact',
            resultColumns, conditionArgs);
        LOG.info(TAG + 'queryRecentlyDelContacts' + 'RecentlyDelContacts get DAHelper.query --------------end');
        result.code = 0;
        var recentlyList = [];
        if (resultSet.rowCount > 0) {
            resultSet.goToFirstRow();
            do {
                var jsonObj = {};
                jsonObj.contactId = resultSet.getString(resultSet.getColumnIndex('contactId'));
                jsonObj.name = resultSet.getString(resultSet.getColumnIndex('name'));
                jsonObj.deleteTime = resultSet.getString(resultSet.getColumnIndex('deleteTime'));
                var timeDifStamp = now - jsonObj.deleteTime;
                jsonObj.days = 30 - Math.floor(timeDifStamp < 0 ? 0 : timeDifStamp / (24 * 3600 * 1000));
                jsonObj.checked = false;
                recentlyList.push(jsonObj);
            } while (resultSet.goToNextRow());
        }
        result.recentlyList = recentlyList;
        LOG.info(TAG + 'queryRecentlyDelContacts' + 'query recently delete contacts list =' + result.length);
        callback(result);
    },

    /**
     * Clear recently deleted contacts
     *
     * @param {string} DAHelper Database address
     * @param {Object} data
     * @param {Object} callback
     */
    clearRecentlyDelContacts: async function (DAHelper, data, callback) {
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.in('contact_id', data.contactIds);
        var result = await DAHelper.delete(Constants.uri.CONTACTS_URI_PREFIX + 'deleted_raw_contact', conditionArgs);
        LOG.info(TAG + 'clearRecentlyDelContacts' + 'delete recently delete contacts result = ' + result.length);
        callback(result);
    }
};