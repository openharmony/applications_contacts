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
import {describe, beforeAll, beforeEach, afterAll, afterEach, it, expect} from 'deccjsunit/index'
import FavoritesModel from '../../../main/js/default/model/FavoritesModel.js'
import Constants from '../../../main/js/default/common/constants/Constants.js'

describe('FavoritesModelTest',function(){
    it('queryFavoritesContacts',0,function(){
        var actionData = {
            page: '0',
            limit: '20',
            star: '0'
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        FavoritesModel.queryFavoritesContacts(DAHelper, actionData, result => {
            expect(result.code).assertEqual('0')
        })
    })

    it('queryPhoneNumByContactId',0,function(){
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        var contactId = '1';
        var phoneNumberLabelNames = ['residential', 'Mobile phone','unit', 'Unit fax','Residential fax', 'pagers', 'other', '', '', '', '', 'The switchboard'];
        FavoritesModel.queryPhoneNumByContactId(DAHelper,contactId, phoneNumberLabelNames,result=>{
            expect(result.code).assertEqual('0')
        })
    })

    it('updateFavoriteState',0,function(){
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        var actionData = {'favorite':'0','ids':['14'],'isOperationAll':false}
        FavoritesModel.updateFavoriteState(DAHelper, actionData, result => {
            expect(result).assertEqual('0')
        });
    })

    it('setOrCancelDefaultPhoneNumber',0,function(){
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        var actionData = {'contactId':'18','phoneNumber':'8','isPrimary':1}
        FavoritesModel.setOrCancelDefaultPhoneNumber(DAHelper, actionData, result => {
            expect(result.code).assertEqual('0')
        })
    })

})