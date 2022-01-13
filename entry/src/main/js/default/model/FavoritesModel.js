/**
 * @file: Collect the Model
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


import LOG from '../utils/ContactsLog.js';
import ohosDataAbility from '@ohos.data.dataability';
import CONSTANTS from '../common/constants/Constants.js';
import backgroundColor from '../common/constants/color.js';

var TAG = 'favoritesModel';

export default {
    /**
     * Query unfavorites contacts
     *
     * @param {string} DAHelper Database address
     * @param {Object} data Maximum number of contacts on the page and whether to favorites
     * @param {Object} callback
     */
    queryUnFavoritesContacts: async function (DAHelper, data, callback) {
        var resultColumns = ['id as contactId', 'display_name as emptyNameData', 'sort_first_letter as namePrefix',
        'photo_first_name as nameSuffix', 'company as company', 'position as position'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.equalTo('is_deleted', '0').equalTo('favorite', data.star + '')
            .offsetAs(data.page * data.limit).limitAs(data.limit);
        var result = {};
        var resultSet = await DAHelper.query(CONSTANTS.uri.CONTACT_URI, resultColumns, conditionArgs);
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
        resultSet.close();
        result.resultList = resultList;
        result.contactCount = resultList.length;
        callback(result);
    },

    /**
     * Querying Favorite Contacts
     *
     * @param {string} DAHelper Database address
     * @param {Object} data Maximum number of contacts on the page and whether to favorites
     * @param {Object} callback
     */
    queryFavoritesContacts: async function (DAHelper, data, callback) {
        var resultColumns = ['id as contactId', 'display_name as emptyNameData', 'sort_first_letter as namePrefix',
        'photo_first_name as nameSuffix', 'company as company', 'position as position', 'favorite_order'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.equalTo('is_deleted', '0').equalTo('favorite', data.star + '').orderByAsc('favorite_order');
        var result = {};
        var resultSet = await DAHelper.query(CONSTANTS.uri.CONTACT_URI, resultColumns, conditionArgs);
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
                jsonObj.favorite_order = resultSet.getLong(resultSet.getColumnIndex('favorite_order'));
                jsonObj.portraitColor = backgroundColor.Color[Math.abs(jsonObj.contactId) % 6];
                jsonObj.show = false;
                jsonObj.star = 1;
                resultList.push(jsonObj);
            } while (resultSet.goToNextRow());
        }
        resultSet.close();
        result.resultList = resultList;
        result.contactCount = resultList.length;
        this.queryFrequentlyContact(DAHelper, data, result, callback);
    },

    /**
     * Query the number of favorite contacts
     *
     * @param {string} DAHelper Database address
     * @param {number} star Whether the collection
     * @param {Object} result Collected contact data
     * @param {Object} callback
     */
    queryFavoriteContactsCount: async function (DAHelper, star, result, callback) {
        var resultColumns = ['id'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.equalTo('favorite', star + '').equalTo('is_deleted', '0');
        var resultSet = await DAHelper.query(CONSTANTS.uri.CONTACT_URI, resultColumns, conditionArgs);
        result.contactCount = resultSet.rowCount;
        resultSet.close();
        callback(result);
    },

    /**
     * Querying Common Contacts
     *
     * @param {string} DAHelper Database address
     * @param {Object} data Maximum number of contacts on the page and whether to favorites
     * @param {Object} result Common Contact Data
     * @param {Object} callback
     */
    queryFrequentlyContact: async function (DAHelper, data, result, callback) {
        var resultColumns = ['type_id as type', 'raw_contact_id as contactId', 'detail_info as detailInfo',
        'photo_first_name as nameSuffix', 'extend7 as labelId', 'custom_data as labelName'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.equalTo('is_deleted', '0').notEqualTo('favorite', data.star + '')
            .greaterThanOrEqualTo('contacted_count', 1).in('type_id', ['6', '5']).orderByAsc('raw_contact_id');
        var resultSet = await DAHelper.query(CONSTANTS.uri.CONTACT_DATA_URI, resultColumns, conditionArgs);
        result.code = 0;
        var resultList = [];
        if (resultSet.rowCount > 0) {
            resultSet.goToFirstRow();
            var resultMap = new Map();
            do {
                var type = resultSet.getString(resultSet.getColumnIndex('type'));
                var contactId = resultSet.getString(resultSet.getColumnIndex('contactId'));
                switch (type) {
                    case '6':
                        if (resultMap.has(contactId)) {
                            var updateJsonObj = resultMap.get(contactId);
                            updateJsonObj.contactId = resultSet.getString(resultSet.getColumnIndex('contactId'));
                            updateJsonObj.name = resultSet.getString(resultSet.getColumnIndex('detailInfo'));
                            updateJsonObj.nameSuffix = resultSet.getString(resultSet.getColumnIndex('nameSuffix'));
                            updateJsonObj.portraitColor = backgroundColor.Color[Math.abs(updateJsonObj.contactId) % 6];
                        } else {
                            var addJsonObj = {};
                            addJsonObj.contactId = resultSet.getString(resultSet.getColumnIndex('contactId'));
                            addJsonObj.name = resultSet.getString(resultSet.getColumnIndex('detailInfo'));
                            addJsonObj.nameSuffix = resultSet.getString(resultSet.getColumnIndex('nameSuffix'));
                            addJsonObj.portraitColor = backgroundColor.Color[Math.abs(addJsonObj.contactId) % 6];
                            resultMap.set(addJsonObj.contactId, addJsonObj);
                        }
                        break;
                    case '5':
                        if (resultMap.has(contactId)) {
                            var jsonObject = resultMap.get(contactId);
                            if (!jsonObject.hasOwnProperty('numbers')) {
                                jsonObject.numberType = resultSet.getString(resultSet.getColumnIndex('labelId'));
                                jsonObject.numbers = resultSet.getString(resultSet.getColumnIndex('detailInfo'));
                                jsonObject.numberTypeLabel = resultSet.getString(resultSet.getColumnIndex('labelName'));
                            }
                        } else {
                            var jsonObj = {};
                            jsonObj.numberType = resultSet.getString(resultSet.getColumnIndex('labelId'));
                            jsonObj.numbers = resultSet.getString(resultSet.getColumnIndex('detailInfo'));
                            jsonObj.numberTypeLabel = resultSet.getString(resultSet.getColumnIndex('labelName'));
                            resultMap.set(contactId, jsonObj);
                        }
                        break;
                    default:
                        break;
                }
            } while (resultSet.goToNextRow());
            resultSet.close();
            resultMap.forEach(function (value, key, mapObj) {
                resultList.push(value);
            });
        }
        result.todoList = resultList;
        result.frequentlyCount = resultList.length;
        callback(result);
    },

    /**
     * Query mobile phone numbers by contact ID
     *
     * @param {string} DAHelper Database address
     * @param {number} contactId The contact ID
     * @param {Array} phoneNumberLabelNames
     * @param {Object} callback
     */
    queryPhoneNumByContactId: async function (DAHelper, contactId, phoneNumberLabelNames, callback) {
        var resultColumns = ['detail_info AS phoneNumber', 'extend7 AS labelId', 'is_preferred_number AS isPrimary'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.equalTo('content_type', 'phone');
        conditionArgs.equalTo('contact_id', contactId);
        var res = await DAHelper.query(CONSTANTS.uri.CONTACT_DATA_URI, resultColumns, conditionArgs);
        var member = {
            phoneNumbers: []
        };
        if (res.rowCount > 0) {
            if (res.goToFirstRow()) {
                do {
                    var phoneNumber = res.getString(res.getColumnIndex('phoneNumber'));
                    var labelId = res.getString(res.getColumnIndex('labelId'));
                    var isPrimary = res.getString(res.getColumnIndex('isPrimary'));
                    member.phoneNumbers.push({
                        phoneNumber: phoneNumber,
                        isPrimary: isPrimary,
                        labelId: labelId,
                        labelName: labelId > 0 ? phoneNumberLabelNames[labelId - 1] : ''
                    });
                } while (res.goToNextRow());
                res.close();
            }
        } else {
            LOG.error(TAG + 'queryPhoneNumByContactId' + 'phoneNumbers is null.');
        }
        var result = {
            'code': 0,
            'data': member
        };
        callback(result);
    },

    /**
     * Update the favorite status of contacts
     *
     * @param {string} DAHelper Database address
     * @param {Object} actionData Contact data
     * @param {Object} callback
     */
    updateFavoriteState(DAHelper, actionData, callback) {
        var condition = new ohosDataAbility.DataAbilityPredicates();

        if (!actionData.isOperationAll) {
            condition.in('contact_id', actionData.ids);
        } else {
            actionData.ids.forEach(contactId => {
                condition.notEqualTo('contact_id', contactId);
            });
        }

        var rawContact = {
            'favorite': actionData.favorite,
            'favorite_order': actionData.favorite_order
        };
        DAHelper.update(
            CONSTANTS.uri.ROW_CONTACTS_URI,
            rawContact,
            condition
        ).then(data => {
            callback(data);
        }).catch(error => {
            LOG.error(TAG + 'updateFavoriteState' + 'updateFavoriteState contact error:' + error);
        });
    },

    /**
     *  Deselect a favorite contact
     *
     * @param {string} DAHelper Database address
     * @param {Object} actionData Contact data
     * @param {Object} callback
     */
    async removeFavoriteState(DAHelper, actionData, callback) {
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo('favorite', '0');
        condition.in('contact_id', actionData.ids);
        var updateParam = {
            'contacted_count': '0'
        };
        var result = await DAHelper.update(CONSTANTS.uri.ROW_CONTACTS_URI, updateParam, condition);
        if (result == 0) {
            condition = new ohosDataAbility.DataAbilityPredicates();
            condition.equalTo('favorite', '1');
            condition.in('contact_id', actionData.ids);
            var rawContact = {
                'favorite': actionData.favorite
            };
            result = await DAHelper.update(CONSTANTS.uri.ROW_CONTACTS_URI, rawContact, condition);
        } else {
            LOG.error(TAG + 'removeFavoriteState' + 'update frequent contacts result is failed.');
            result = -1;
        }
        callback(result);
    },

    /**
     * Click to set the default phone number when dialing
     *
     * @param {string} DAHelper
     * @param {Object} actionData
     * @param {Object} callback
     */
    setOrCancelDefaultPhoneNumber: async function (DAHelper, actionData, callback) {
        var resultColumns = ['id AS rawContactId'];
        var conditionArgs = new ohosDataAbility.DataAbilityPredicates();
        conditionArgs.equalTo('contact_id', actionData.contactId);
        var res = await DAHelper.query(CONSTANTS.uri.ROW_CONTACTS_URI, resultColumns, conditionArgs);
        var rawContactIds = [];

        if (res.rowCount > 0) {
            if (res.goToFirstRow()) {
                do {
                    var rawContactId = res.getString(res.getColumnIndex('rawContactId'));
                    rawContactIds.push(rawContactId);
                } while (res.goToNextRow());
                res.close();
            }
        } else {
            LOG.error(TAG + 'setOrCancelDefaultPhoneNumber' + 'rawContactIds is null.');
        }
        var typeId = this.getTypeId(DAHelper, 'phone');
        if (actionData.isPrimary == 1) {
            var params = new ohosDataAbility.DataAbilityPredicates();
            params.equalTo('type_id', typeId);
            params.equalTo('raw_contact_id', rawContactIds);
            params.equalTo('is_preferred_number', 1);
            params.notEqualTo('detail_info', actionData.phoneNumber);
            var contact = {
                'is_preferred_number': 0
            };
            DAHelper.update(
                CONSTANTS.uri.CONTACT_DATA_URI,
                contact,
                params
            ).then(data => {
                LOG.info(TAG + 'setOrCancelDefaultPhoneNumber' + 'clear other phoneNumber default is .' + data);
            }).catch(error => {
                LOG.error(TAG + 'setOrCancelDefaultPhoneNumber' + 'clear other phoneNumber default  error:' + error);
            });
        }

        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo('type_id', typeId);
        condition.equalTo('raw_contact_id', rawContactIds);
        condition.equalTo('detail_info', actionData.phoneNumber);
        var contact1 = {
            'is_preferred_number': actionData.isPrimary
        };
        DAHelper.update(
            CONSTANTS.uri.CONTACT_DATA_URI,
            contact1,
            condition
        ).then(data => {
            callback({
                code: data
            });
            LOG.info(TAG + 'setOrCancelDefaultPhoneNumber' + 'end setOrCancelDefaultPhoneNumber.');
        }).catch(error => {
            LOG.error(TAG + 'setOrCancelDefaultPhoneNumber' + 'setOrCancelDefaultPhoneNumber contact error:' + error);
        });

    },

    /**
     * Example Query the GROUP type ID
     *
     * @param {string} DAHelper
     * @param {string} typeText
     */
    getTypeId: async function (DAHelper, typeText) {
        var params = new ohosDataAbility.DataAbilityPredicates();
        params.equalTo('content_type', typeText);
        var resultColumns = ['id as typeId'];
        var res = await DAHelper.query(CONSTANTS.uri.CONTACT_TYPE_URI, resultColumns, params);
        var typeId = '';
        if (res.rowCount > 0) {
            if (res.goToFirstRow()) {
                typeId = res.getString(res.getColumnIndex('typeId'));
            }
            res.close();
        } else {
            LOG.error(TAG + 'getTypeId' + 'typeText is null.');
        }
        return typeId;
    }
};