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
import {describe, beforeAll, beforeEach, afterAll, it, expect} from 'deccjsunit/index'
import contactDetailModel from '../../../main/js/default/model/ContactDetailModel.js'
import Constants from '../../../main/js/default/common/constants/Constants.js'

describe('ContactDetailModelTest',function(){

    it('getContactById',0,function(){
        var requestData = {
            contactId: '1'
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactDetailModel.getContactById(DAHelper, requestData, result => {
            expect(result.data.length).notAssertEqual('0')
        })
    })

    it('getContactIdByNumber',0,function(){
        var phoneNumberShow = '15611452568'
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactDetailModel.getContactIdByNumber(DAHelper, phoneNumberShow, (contactId) => {
            expect(contactId).notAssertEqual('0')
        })
    })
})
