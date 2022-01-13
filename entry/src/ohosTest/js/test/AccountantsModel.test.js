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
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index'
import accountantsModel from './../../../main/js/default/model/AccountantsModel.js'
import Constants from '../../../main/js/default/common/constants/Constants.js'

describe('AccountantsModelTest', function () {
    it('addContact', 0, function () {
        var addParams = {
            'name': {
                'fullName': 'A The test user name is added' + Math.floor(Math.random() * 100),
            },
            'phoneNumbers': [
                {
                    'id': 0,
                    'isPrimary': 0,
                    'labelId': 2,
                    'phoneAddress': 'N',
                    'phoneNumber': '19991445854',
                    'showP': true,
                    'blueStyle': false
                }
            ]
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        accountantsModel.addContact(DAHelper, addParams, (contactId) => {
            expect(contactId).notAssertEqual('0');
        });
    })

    it('updateContact', 0, function () {
        var addParams = {
            'name': {
                'fullName': 'A The test user name is added' + Math.floor(Math.random() * 100),
            },
            'phoneNumbers': [
                {
                    'id': 0,
                    'isPrimary': 0,
                    'labelId': 2,
                    'phoneAddress': 'N',
                    'phoneNumber': '19991445854',
                    'showP': true,
                    'blueStyle': false
                }
            ]
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        accountantsModel.updateContact(DAHelper, addParams, (contactId) => {
            expect(contactId).notAssertEqual('0');
        });
    })
})