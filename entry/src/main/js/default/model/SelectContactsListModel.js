/**
 * @file: Select the contact list Model
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

import ohosDataAbility from '@ohos.data.dataability';
import LOG from '../utils/ContactsLog.js';
import Constants from '../common/constants/Constants.js';
import backgroundColor from '../common/constants/color.js';

var reGu = '^[a-zA-Z\u4e00-\u9fa5]+$';
var re = new RegExp(reGu);
var TAG = 'selectContactsListModel';

export default {

    /**
     * Deleting selected Contacts
     *
     * @param {string} DAHelper Database address
     * @param {boolean} isChecked
     * @param {Array} contactIds
     * @param {Object} callback
     * */
    checkedDelete: async function (DAHelper, isChecked, contactIds, callback) {
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        if (isChecked) {
            LOG.info(TAG + 'checkedDelete' + 'reverse selection');
            contactIds.forEach((id) => {
                conditionArgs.notEqualTo('id', id);
            });
        } else {
            LOG.info(TAG + 'checkedDelete' + 'Positive selection');
            conditionArgs.in('id', contactIds);
        }
        var result = await DAHelper.delete(Constants.uri.CONTACTS_URI_PREFIX + 'contact', conditionArgs);
        LOG.info(TAG + 'checkedDelete' + 'batch delete contacts delete result = ' + result.length);
        callback(result);
    },

    /**
     * Querying a Contact List
     *
     * @param {string} DAHelper Database address
     * @param {Object} actionData
     * @param {Object} callback
     * */
    queryContactList: async function (DAHelper, actionData, callback) {
        var resultColumns = ['id as contactId', 'display_name as emptyNameData', 'sort_first_letter as namePrefix',
        'photo_first_name as nameSuffix', 'company as company', 'position as position'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.equalTo('is_deleted', '0').orderByAsc('sort_first_letter')
            .offsetAs(actionData.page * actionData.limit).limitAs(actionData.limit);
        var result = {};
        var resultSet = await DAHelper.query(Constants.uri.CONTACTS_URI_PREFIX
        + 'contact', resultColumns, conditionArgs);
        result.code = 0;
        var resultList = [];
        if (resultSet.rowCount > 0) {
            resultSet.goToFirstRow();
            do {
                var jsonObj = {};
                jsonObj.contactId = resultSet.getString(resultSet.getColumnIndex('contactId'));
                jsonObj.emptyNameData = resultSet.getString(resultSet.getColumnIndex('emptyNameData'));
                jsonObj.namePrefix = resultSet.getString(resultSet.getColumnIndex('namePrefix'));
                jsonObj.nameSuffix = resultSet.getString(resultSet.getColumnIndex('nameSuffix'));
                jsonObj.company = resultSet.getString(resultSet.getColumnIndex('company'));
                jsonObj.position = resultSet.getString(resultSet.getColumnIndex('position'));
                jsonObj.portraitColor = backgroundColor.Color[Math.abs(jsonObj.contactId) % 6];
                jsonObj.show = false;
                resultList.push(jsonObj);
            } while (resultSet.goToNextRow());
        }
        result.resultList = resultList;
        LOG.info(TAG + 'queryContactList' + 'query batch delete contacts list =' + result.length);
        callback(result);
    },

    getTypeId: async function (DAHelper, actionData, callback) {
        let contactIds = [];
        for (let id of actionData.contactIds) {
            contactIds.push(id + '');
        }
        var resultColumns = [
            'detail_info',
            'contact_id'
        ];
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in('contact_id', contactIds);
        condition.and();
        condition.equalTo('content_type', 'phone');
        var result = {};
        var resultSet = await DAHelper.query(Constants.uri.CONTACTS_URI_PREFIX + 'contact_data', resultColumns, condition);
        var resultList = [];
        if (resultSet.rowCount > 0) {
            resultSet.goToFirstRow();
            do {
                var jsonObj = {};
                jsonObj.detailInfo = resultSet.getString(resultSet.getColumnIndex('detail_info'));
                jsonObj.contactId = resultSet.getString(resultSet.getColumnIndex('contact_id'));
                resultList.push(jsonObj);
            } while (resultSet.goToNextRow());
        }
        resultSet.close();
        result.resultList = resultList;
        callback(result);
    }
};