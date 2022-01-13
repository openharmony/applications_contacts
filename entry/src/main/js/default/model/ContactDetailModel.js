/**
 * @file: Contact Details Model
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

import ohosDataAbility from '@ohos.data.dataability';
import Utils from '../../default/utils/utils.js';
import LOG from '../utils/ContactsLog.js';
import CONSTANTS from '../common/constants/Constants.js';
import backgroundColor from '../common/constants/color.js';

var PortraitColor = backgroundColor.Color;
var DetailsBgColor = backgroundColor.detailColor;

var TAG = 'contactDetailModel';

export default {

    /**
     * Obtain contact details
     *
     * @param {string} DAHelper Database path
     * @param {Object} actionData Contact data
     * @param {Object} callback Contact Details
    */
    getContactById: function (DAHelper, actionData, callback) {
        var contactId = actionData.contactId;
        var resultColumns = [
            'contact_id',
            'favorite',
            'display_name',
            'detail_info',
            'type_id',
            'content_type',
            'alpha_name',
            'phonetic_name',
            'position',
            'group_name',
            'extend7',
            'custom_data',
            'is_preferred_number',
            'photo_first_name'
        ];
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo('contact_id', contactId);
        DAHelper.query(CONSTANTS.uri.CONTACT_DATA_URI, resultColumns, condition).then(resultSet => {
            var contactDetailInfo = {};
            // If it is a search, the match type is passed out
            if (actionData.searchMimetype) {
                contactDetailInfo.searchMimetype = [];
            }
            do {
                this.dealResult(resultSet, contactDetailInfo, actionData);
            } while (resultSet.goToNextRow());
            resultSet.close();
            LOG.info(TAG + 'getContactById' + '  contactDetailInfo is ==' + contactDetailInfo);
            var res = {};
            res.data = contactDetailInfo;
            callback(res);
        }).catch(error => {
            LOG.info(TAG + 'getContactById' + ' get call log error:' + error);
        });
    },

    /**
     * Process contact details
     *
     * @param {Object} resultSet
     * @param {Object} contactDetailInfo Contact Details
     * @param {Object} actionData Contact data
     */
    dealResult: function (resultSet, contactDetailInfo, actionData) {
        var contactId = resultSet.getString(resultSet.getColumnIndex('contact_id'));
        var rawContactId = resultSet.getString(resultSet.getColumnIndex('raw_contact_id'));
        var favorite = resultSet.getString(resultSet.getColumnIndex('favorite'));
        var nameSuffix = resultSet.getString(resultSet.getColumnIndex('photo_first_name'));
        var typeText = resultSet.getString(resultSet.getColumnIndex('content_type'));
        var detailInfo = resultSet.getString(resultSet.getColumnIndex('detail_info'));
        var displayName = resultSet.getString(resultSet.getColumnIndex('display_name'));
        var alphaName = resultSet.getString(resultSet.getColumnIndex('alpha_name'));
        var familyNamePhonetic = resultSet.getString(resultSet.getColumnIndex('phonetic_name'));
        var labelId = resultSet.getString(resultSet.getColumnIndex('extend7'));
        var labelName = resultSet.getString(resultSet.getColumnIndex('custom_data'));
        labelName = labelName ? labelName : '';
        var groupName = resultSet.getString(resultSet.getColumnIndex('group_name'));
        var position = resultSet.getString(resultSet.getColumnIndex('position'));
        var isPrimaryNum = resultSet.getString(resultSet.getColumnIndex('is_preferred_number'));

        contactDetailInfo.emptyNameData = displayName;

        if (favorite == 0) {
            contactDetailInfo.favorite = false;
            contactDetailInfo.starred = 0;
        } else {
            contactDetailInfo.favorite = true;
            contactDetailInfo.starred = 1;
        }

        // If it is a search, the match type is passed out
        if (actionData.searchMimetype) {
            if (detailInfo.indexOf(actionData.searchValue) != -1 || position.indexOf(actionData.searchValue) != -1) {
                contactDetailInfo.searchMimetype.push('/' + typeText);
            }
        }

        contactDetailInfo.nameSuffix = nameSuffix;

        contactDetailInfo.contactId = contactId;

        contactDetailInfo.rawContactId = rawContactId;

        contactDetailInfo.portraitColor = PortraitColor[contactId % 6];

        contactDetailInfo.detailsBgColor = DetailsBgColor[contactId % 6];

        this.determineFieldType(typeText, detailInfo, labelId, labelName, contactDetailInfo, position, isPrimaryNum,
            familyNamePhonetic, nameSuffix, groupName, alphaName);
    },

    /**
     * Determine the field type
     *
     * @param {string} typeText
     * @param {string} detailInfo
     * @param {number} labelId
     * @param {string} labelName
     * @param {Object} contactDetailInfo Contact Details
     * @param {string} position
     * @param {number} isPrimaryNum
     * @param {string} familyNamePhonetic
     * @param {string} nameSuffix
     * @param {string} groupName
     * @param {string} alphaName
     */
    determineFieldType: function (typeText, detailInfo, labelId, labelName, contactDetailInfo, position, isPrimaryNum,
                                  familyNamePhonetic, nameSuffix, groupName, alphaName) {
        var determineInfo = {
            'typeText': typeText,
            'detailInfo': detailInfo,
            'nameSuffix': nameSuffix,
            'labelId': labelId,
            'labelName': labelName,
            'contactDetailInfo': contactDetailInfo,
            'position': position,
            'isPrimaryNum': isPrimaryNum,
            'familyNamePhonetic': familyNamePhonetic,
            'groupName': groupName,
            'alphaName': alphaName
        }

        switch (determineInfo.typeText) {
            case 'email':
                var email = {
                    'email': determineInfo.detailInfo,
                    'labelId': determineInfo.labelId,
                    'labelName': determineInfo.labelName,
                    'showP': true
                };
                if (determineInfo.contactDetailInfo.emails) {
                    determineInfo.contactDetailInfo.emails.push(email);
                } else {
                    determineInfo.contactDetailInfo.emails = [email];
                }
                break;
            case 'im':
                var imAddress = {
                    'imAddress': determineInfo.detailInfo,
                    'labelId': determineInfo.labelId,
                    'labelName': determineInfo.labelName,
                    'showP': true
                };
                if (determineInfo.contactDetailInfo.imAddresses) {
                    determineInfo.contactDetailInfo.imAddresses.push(imAddress);
                } else {
                    determineInfo.contactDetailInfo.imAddresses = [imAddress];
                }
                break;
            case 'nickname':
                determineInfo.contactDetailInfo.nickName = {
                    'nickName': determineInfo.detailInfo
                };
                break;
            case 'organization':
                determineInfo.contactDetailInfo.organization = {
                    'name': determineInfo.detailInfo,
                    'title': determineInfo.position
                };
                break;
            case 'phone':
                var phoneNumber = {
                    'isPrimary': determineInfo.isPrimaryNum,
                    'labelId': determineInfo.labelId,
                    'labelName': determineInfo.labelName,
                    'phoneAddress': 'N',
                    'phoneNumber': determineInfo.detailInfo,
                    'showP': true,
                    'blueStyle': false
                };
                if (determineInfo.contactDetailInfo.phoneNumbers) {
                    determineInfo.contactDetailInfo.phoneNumbers.push(phoneNumber);
                } else {
                    determineInfo.contactDetailInfo.phoneNumbers = [phoneNumber];
                }
                break;
        }
        this.switchNext(determineInfo);
    },
    switchNext: function (determineInfo) {
        switch (determineInfo.typeText) {
            case 'name':
                determineInfo.contactDetailInfo.name = {
                    'familyNamePhonetic': determineInfo.familyNamePhonetic,
                    'fullName': determineInfo.detailInfo,
                    'middleName': '',
                    'givenName': '',
                    'nameSuffix': determineInfo.nameSuffix,
                    'alphaName': determineInfo.alphaName
                };
                break;
            case 'postal_address':
                var postalAddress = {
                    'labelId': determineInfo.labelId,
                    'labelName': determineInfo.labelName,
                    'postalAddress': determineInfo.detailInfo,
                    'showP': true
                };
                if (determineInfo.contactDetailInfo.postalAddresses) {
                    determineInfo.contactDetailInfo.postalAddresses.push(postalAddress);
                } else {
                    determineInfo.contactDetailInfo.postalAddresses = [postalAddress];
                }
                break;
            case 'photo':
                break;
            case 'group_membership':
                var group = {
                    title: determineInfo.groupName,
                    groupId: determineInfo.detailInfo
                };
                if (determineInfo.contactDetailInfo.groups) {
                    determineInfo.contactDetailInfo.groups.push(group);
                } else {
                    determineInfo.contactDetailInfo.groups = [group];
                }
                break;
            case 'note':
                determineInfo.contactDetailInfo.note = {
                    'noteContent': determineInfo.detailInfo
                };
                break;
            case 'contact_event':
                var event = {
                    'labelId': determineInfo.labelId,
                    'labelName': determineInfo.labelName,
                    'eventDate': determineInfo.detailInfo,
                    'showP': true,
                    'showF': true,
                    'showS': true
                };
                if (determineInfo.contactDetailInfo.events) {
                    determineInfo.contactDetailInfo.events.push(event);
                } else {
                    determineInfo.contactDetailInfo.events = [event];
                }
                break;
            case 'website':
                var website = {
                    'website': determineInfo.detailInfo,
                    'showP': false
                };
                if (determineInfo.contactDetailInfo.websites) {
                    determineInfo.contactDetailInfo.websites.push(website);
                } else {
                    determineInfo.contactDetailInfo.websites = [website];
                }
                break;
            case 'relation':
                var relation = {
                    'labelId': determineInfo.labelId,
                    'labelName': determineInfo.labelName,
                    'relationName': determineInfo.detailInfo,
                    'showP': true
                };
                if (determineInfo.contactDetailInfo.relations) {
                    determineInfo.contactDetailInfo.relations.push(relation);
                } else {
                    determineInfo.contactDetailInfo.relations = [relation];
                }
                break;
            default:
                break;
        }
    },

    /**
     * Obtain the contact ID of a phone number
     *
     * @param {string} DAHelper
     * @param {number} number
     * @param {Object} callBack The contact ID
     */
    getContactIdByNumber: async function (DAHelper, number, callBack) {
        if (Utils.isEmpty(number)) {
            return;
        }
        var resultColumns = [
            'raw_contact_id',
        ];
        var cleanNumber = Utils.removeSpace(number);
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo('detail_info', cleanNumber);
        condition.and();
        condition.equalTo('is_deleted', 0);
        var resultSet = await DAHelper.query(CONSTANTS.uri.CONTACT_DATA_URI, resultColumns, condition);
        if (Utils.isEmpty(resultSet) || resultSet.rowCount == 0) {
            LOG.info(TAG + 'getContactIdByNumber' + ' contactId resultSet is empty!');
            callBack();
            return;
        }
        resultSet.goToFirstRow();
        var contactId = resultSet.getString(0);
        resultSet.close();
        callBack(contactId);
    }
};