/**
 * @file Combined Model
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
import backgroundColor from '../common/constants/color.js';

var reGu = '^[a-zA-Z\u4e00-\u9fa5]+$';
var re = new RegExp(reGu);
var TAG = 'mergeModel';

export default {

    /**
     * Query merged contacts
     *
     * @param {string} DAHelper The database
     * @param {null} data  null
     * @param {Object} callback
     */
    queryMergeContactsList: async function (DAHelper, data, callback) {
        var resultColumns = [];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        var result = {};
        var resultSet = await DAHelper.query(Constants.uri.CONTACTS_URI_PREFIX
        + 'raw_contact/query_merge_list', resultColumns, conditionArgs);
        result.code = 0;
        var resultMap = new Map();
        var mergeList = [];
        if (resultSet.rowCount > 0) {
            resultSet.goToFirstRow();
            var resultSetList = [];
            do {
                var jsonObj = {};
                jsonObj.contactId = resultSet.getString(resultSet.getColumnIndex('raw_contact_id'));
                jsonObj.emptyNameData = resultSet.getString(resultSet.getColumnIndex('display_name'));
                jsonObj.nameSuffix = resultSet.getString(resultSet.getColumnIndex('photo_first_name'));
                jsonObj.phoneNumber = resultSet.getString(resultSet.getColumnIndex('detail_info'));
                jsonObj.portraitColor = backgroundColor.Color[Math.abs(jsonObj.contactId) % 6];
                if (!resultMap.has(jsonObj.emptyNameData)) {
                    resultSetList = [];
                }
                resultSetList.push(jsonObj);
                resultMap.set(jsonObj.emptyNameData, resultSetList);
            } while (resultSet.goToNextRow());
            resultMap.forEach(function (value, key, mapObj) {
                var mergeObj = {};
                mergeObj.contactBeans = value;
                mergeObj.checked = true;
                mergeList.push(mergeObj);
            });
        }
        result.mergeList = mergeList;
        LOG.info(TAG + 'queryMergeContactsList' + ' merge contacts list =' + JSON.stringify(result.mergeList.length));
        callback(result);
    },

    /**
     * Query merged contacts
     *
     * @param {string} DAHelper The database
     * @param {null} data  null
     * @param {Object} callback
     */
    autoMergeContacts: async function (DAHelper, data, callback) {
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        var updateParams = {};
        var result = await DAHelper.update(Constants.uri.CONTACTS_URI_PREFIX
        + 'raw_contact/auto_merge', updateParams, conditionArgs);
        LOG.info(TAG + 'autoMergeContacts' + 'autoMergeContacts get DAHelper.query --------------end');
        this.queryMergeContactsList(DAHelper, data, callback);
    },

    /**
     * Query merged contacts
     *
     * @param {string} DAHelper The database
     * @param {Object} data
     * @param {Object} callback
     */
    mergeContacts: async function (DAHelper, data, callback) {
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.in('raw_contact_id', data.contactIds);
        var updateParams = {};
        var result = await DAHelper.update(Constants.uri.CONTACTS_URI_PREFIX
        + 'raw_contact/manual_merge', updateParams, conditionArgs);
        LOG.info(TAG + 'mergeContacts' + 'mergeContacts get DAHelper.query --------------end');
        callback(result);
    }
};