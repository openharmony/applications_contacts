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
import Constants from '../../../main/js/default/common/constants/Constants.js';
import groupReq from '../../../main/js/default/model/GroupsModel.js';
import contactsService from '../../../main/js/default/model/ContactModel.js';

describe('mergeModelTest', function () {
    it('addGroup', 0, function () {
        var newGroupName = 'asd'

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.addGroup(DAHelper, newGroupName, result => {
            expect(result).notAssertEqual('0');
        })
    })

    it('queryGroups', 0, function () {
        var actionData = {
            'page':0,
            'limit':20
        }

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryGroups(DAHelper, actionData, result => {
            expect(result.length).notAssertEqual('0');
        })
    })

    it('updateGroup', 0, function () {
        var actionData = {
            'title':'jo',
            'groupId':'4'
        }

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.updateGroup(DAHelper, actionData, data => {
            expect(data).assertEqual('0');
        })
    })

    it('deleteGroups', 0, function () {
        var ids = ['1']

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.deleteGroups(DAHelper,ids,result=>{
            expect(result).notAssertEqual('0');
        })
    })

    it('queryGroupMembers', 0, function () {
        var actionData = {
            'page':0,
            'limit':20,
            'groupId':'4'
        }

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryGroupMembers(DAHelper, actionData, result => {
            expect(result.code).assertEqual('0');
        })
    })

    it('addGroupMembers', 0, function () {
        var actionData = {
            'groupId':'8',
            'contactBeans':[
                {
                    'contactId':'14'
                }
            ],
            'isOperationAll':false
        }

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.addGroupMembers(DAHelper, actionData, result => {
            expect(result).notAssertEqual('0');
        })
    })

    it('getOutOfGroupMembers', 0, function () {
        var actionData = {
            'page':0,
            'limit':20,
            'groupId':'4'
        }

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.getOutOfGroupMembers(DAHelper, actionData, result => {
            expect(result.code).notAssertEqual('0');
        })
    })

    it('deleteGroupMembers', 0, function () {
        var actionData = {
            'groupId':'8',
            'contactBeans':[
                {
                    'contactId':'17'
                }
            ],
            'isOperationAll':false
        }

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.deleteGroupMembers(DAHelper, actionData, result => {
            expect(result).notAssertEqual('0');
        })
    })

    it('getGroupMemberList', 0, function () {
        var actionData = {
            'page': 0,
            'limit': 20,
            'groupId': 4,
            filterItem: 'phone',
            phoneNumberLabelNames: 'residential',
            emailsLabelNames: 'private'
        };

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.getGroupMemberList(DAHelper, actionData, result => {
            expect(result.code).notAssertEqual('0');
        })
    })

    it('getGroupMemberList', 0, function () {
        var actionData = {
            'page':0,
            'limit':20,
            'endDate':30,
            'startDate':7
        }

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryRecentContacts(DAHelper, actionData, result => {
            expect(result.code).notAssertEqual('0');
        })
    })

    it('queryRecentContactsCount', 0, function () {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryRecentContactsCount(DAHelper, result => {
            expect(result.length).notAssertEqual('0');
        })
    })

    it('queryContactsCount', 0, function () {
        var resultSet = {};
        var data = {};
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactsService.queryContactsCount(DAHelper, data, resultSet, (result) => {
            expect(result.length).notAssertEqual('0');
        })
    })

    it('searchContacts', 0, function () {
        var requestData = {};
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.searchContacts(DAHelper, requestData, result => {
            expect(result.code).notAssertEqual('0');
        })
    })
})