/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { CallBean } from '../../../../../../main/ets/model/bean/CallBean'

export default function CallBeanTest() {
  describe('CallBeanTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('CallBeanTest_setName', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.name = "name";
      let newname:string = "12345";
      cb.setName(newname);
      expect(cb.name).assertEqual(newname);
    })
    it('CallBeanTest_setCallTime', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.callTime = "123456";
      let newcallTime:string = "12345";
      cb.setCallTime(newcallTime);
      expect(cb.callTime).assertEqual(newcallTime);
    })
    it('CallBeanTest_setBeginTime', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.beginTime = "123456";
      let beginTime:string = "123456";
      cb.setCallTime(beginTime);
      expect(cb.beginTime).assertEqual(beginTime);
    })
    it('CallBeanTest_setCallType', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.callType = "1";
      let newcallType:string = "2";
      cb.setCallType(newcallType);
      expect(cb.callType).assertEqual(newcallType);
    })
    it('CallBeanTest_setCallTag', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.callTag = "1";
      let newcallTag:string = "2";
      cb.setCallTag(newcallTag);
      expect(cb.callTag).assertEqual(newcallTag);
    })
    it('CallBeanTest_setSimType', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.simType = "1";
      let newsimType:string = "2";
      cb.setSimType(newsimType);
      expect(cb.simType).assertEqual(newsimType);
    })
    it('CallBeanTest_setFormatNumber', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.formatNumber = "1";
      let newformatNumber:string = "2";
      cb.setFormatNumber(newformatNumber);
      expect(cb.formatNumber).assertEqual(newformatNumber);
    })
    it('CallBeanTest_setContactKey', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.contactKey = "1";
      let newcontactKey:string = "2";
      cb.setContactKey(newcontactKey);
      expect(cb.contactKey).assertEqual(newcontactKey);
    })
    it('CallBeanTest_setNum', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.num = "1";
      let newnum:string = "2";
      cb.setNum(newnum);
      expect(cb.num).assertEqual(newnum);
    })
    it('CallBeanTest_setIsChecked', 0, () => {
      let cb:CallBean = new CallBean("111",'');
      cb.isChecked = true;
      let newisChecked:boolean = false;
      cb.setIsChecked(newisChecked);
      expect(cb.isChecked).assertEqual(newisChecked);
    })
    it('CallBeanTest_setPortraitColor', 0, () => {
      let cb: CallBean = new CallBean("111", '');
      let res: Resource = $r("app.string.TestAbility_label");
      cb.setPortraitColor(res);
      expect(JSON.stringify(cb.portraitColor)).assertEqual(JSON.stringify(res));
    })
    it('CallBeanTest_setSuffix', 0, () => {
      let cb: CallBean = new CallBean("111", '');
      cb.suffix = "1";
      let newsuffix: string = "12";
      cb.setSuffix(newsuffix);
      expect(cb.suffix).assertEqual(newsuffix);
    })
  })
}