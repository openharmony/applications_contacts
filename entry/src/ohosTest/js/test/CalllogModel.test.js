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
import callLogService from '../../../main/js/default/model/CalllogModel.js'
import Constants from '../../../main/js/default/common/constants/Constants.js'


describe('CalllogModelTest',function(){

    it('getAllCalls',0,function(){
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.getAllCalls(DAHelper, data => {
            expect(data.length).notAssertEqual('0');
        })
    })

    it('getCallLogListByPhoneNumber',0,function(){
        var numbers = '18823681567'
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.getCallLogListByPhoneNumber(DAHelper, numbers, (resultList) => {
            expect(resultList.length).notAssertEqual('0');
        })
    })

    it('clearCallLog',0,function(){
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.clearCallLog(DAHelper,()=>{
            var resultData ={}
            expect(resultData.totalCount).assertEqual('0');
        })
    })

    it('deleteCallLogByIds',0,function(){
        var removeIds = ['1']
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.deleteCallLogByIds(DAHelper, removeIds, (result) => {
            expect(result.code).assertEqual('0');
        });
    })

    it('deleteOtherCallLog',0,function(){
        var removeIds = ['1','2']
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.deleteOtherCallLog(DAHelper, removeIds, (result)=>{
            expect(result.code).assertEqual('0')
        });
    })

//
})
