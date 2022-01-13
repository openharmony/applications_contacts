/**
 * @file: The custom model
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

var TAG = 'customizeModel';

export default {

    /**
     * Query group
     *
     * @param {string} DAHelper Database address
     * @param {Object} callback
     */
    queryGroups: async function (DAHelper, callback) {
        var resultColumns = ['id as id', 'group_name as title'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.orderByAsc('id');
        var result = {};
        var resultSet = await DAHelper.query(Constants.uri.CONTACTS_URI_PREFIX
        + 'groups', resultColumns, conditionArgs);
        result.code = 0;
        var resultList = [];
        LOG.info(TAG + 'queryGroups' + 'query customize groups count =' + resultSet.rowCount);
        if (resultSet.rowCount > 0) {
            resultSet.goToFirstRow();
            do {
                var jsonObj = {};
                jsonObj.id = resultSet.getString(resultSet.getColumnIndex('id'));
                jsonObj.title = resultSet.getString(resultSet.getColumnIndex('title'));
                jsonObj.checked = false;
                resultList.push(jsonObj);
            } while (resultSet.goToNextRow());
        }
        result.resultList = resultList;
        LOG.info(TAG + 'queryGroups' + 'query customize groups list =' + result);
        callback(result);
    }
};