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
import greetingService from '../../../main/js/default/model/GreetingModel.js';


describe('GreetingModelTest', function () {
    it('queryGreeting', 0, function () {

        var data = {}

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
        greetingService.queryGreeting(DAHelper, data, result => {
            expect(result.code).assertEqual('0');
        })
    })

    it('insertGreeting', 0, function () {

        var data = {}

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
        greetingService.insertGreeting(DAHelper, data, resultId => {
            expect(resultId).notAssertEqual('0');
        })
    })

    it('deleteGreeting', 0, function () {
        var data = {}

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
        greetingService.deleteGreeting(DAHelper, data, result => {
            expect(result).assertEqual('0');
        })
    })

    it('saveCheckedGreeting', 0, function () {

        var data = {}

        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
        greetingService.saveCheckedGreeting(DAHelper, data, result => {
            expect(result).assertEqual('0');
        })
    })

})
