/**
 * @file: Restore deleting contact Model
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

var TAG = 'recoverModel';


export default {

    /**
     * Resume Deleting contacts
     *
     * @param {string} DAHelper Database address
     * @param {Object} data
     * @param {Object} callback
     */
    recoverRlyDelContacts: async function (DAHelper, data, callback) {
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.in('contact_id', data.contactIds);
        var updateParams = {
            'is_deleted': '0'
        };
        let CONTACTS_URI_PREFIX = Constants.uri.CONTACTS_URI_PREFIX;
        var result = await DAHelper.update(CONTACTS_URI_PREFIX + 'raw_contact', updateParams, conditionArgs);
        LOG.info(TAG + 'recoverRlyDelContacts' + 'Recover contact is update state result=' + result.length);
        if (result == 0) {
            conditionArgs = new ohosDataAbility.DataAbilityPredicates();
            conditionArgs.in('contact_id', data.contactIds);
            result = await DAHelper.delete(CONTACTS_URI_PREFIX + 'deleted_raw_contact_record', conditionArgs);
            LOG.info(TAG + 'recoverRlyDelContacts' + 'Recover contact result = ' + result.length);
        } else {
            LOG.error(TAG + 'recoverRlyDelContacts' + 'Recover contact result is failed.');
            result = -1;
        }
        callback(result);
    }
};