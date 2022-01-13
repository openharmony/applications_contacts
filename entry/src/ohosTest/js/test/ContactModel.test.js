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
import {describe, beforeAll,beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index'
import Constants from '../../../main/js/default/common/constants/Constants.js'
import contactsService from '../../../main/js/default/model/ContactModel.js'

describe('ContactModelTest',function(){

    it('queryCustomizeGroups',0,function(){
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        var data = {
            page: '0',
            limit: '20',
            queryContactsType: 'all'
        };
        contactsService.queryCustomizeGroups(DAHelper, data, (result) => {
            expect(result.code).assertEqual('0')
        });
    })


    it('queryContacts',0,function(){
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        var data = {
            page: '0',
            limit: '20',
            queryContactsType: 'all'
        };
        contactsService.queryContacts(DAHelper, data, (result) => {
            expect(result.code).assertEqual('0')
        });
    })

    it('queryContactsCount',0,function(){
        var data = {}
        var resultSet = {}
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactsService.queryContactsCount(DAHelper, data, resultSet, (result) => {
            expect(result.contactsCount).notAssertEqual('0')
        })
    })

    it('deleteContacts',0,function(){
        var data = {'contactId':'14'}
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactsService.deleteContacts(DAHelper, data, (result) => {
            expect(result).assertEqual('0')
        })
    })
})