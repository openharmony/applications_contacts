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
import { describe, it, expect, MockKit, when } from '@ohos/hypium';
import NumberMarkUtil from '../../../../../main/ets/util/NumberMarkUtil';
import { common } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../../testability/TestAbility';


export default function NumberMarkUtilTest() {
  describe('NumberMarkUtilTest', () => {
    let context: common.UIAbilityContext = DTGlobalContext.getContext()
      .getObject("contactContext") as common.UIAbilityContext;

    it('NumberMarkUtilTest_isFromNationalAntiFraudCenter_01', 0, () => {
      expect(NumberMarkUtil.isFromNationalAntiFraudCenter(context)).assertFalse();
    })

    it('NumberMarkUtilTest_getNumberMarkInfo', 0, () => {
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('1'))).assertEqual(JSON.stringify($r('app.string.number_mark_crank')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('2'))).assertEqual(JSON.stringify($r('app.string.number_mark_fraud')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('3'))).assertEqual(JSON.stringify($r('app.string.number_mark_express')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('4'))).assertEqual(JSON.stringify($r('app.string.number_mark_promote_sales')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('5'))).assertEqual(JSON.stringify($r('app.string.number_mark_house_agent')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('6'))).assertEqual(JSON.stringify($r('app.string.number_mark_insurance')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('7'))).assertEqual(JSON.stringify($r('app.string.number_mark_taxi')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('8'))).assertEqual(JSON.stringify($r('app.string.number_mark_customize')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('12'))).assertEqual(JSON.stringify($r('app.string.number_mark_fraud')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkInfo('11'))).assertEqual(JSON.stringify($r('app.string.number_mark_crank')));
    })

    it('NumberMarkUtilTest_getNumberMarkSourceInfo', 0, () => {
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkSourceInfo('0'))).assertEqual(JSON.stringify($r('app.string.number_mark_source_oh')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkSourceInfo('1'))).assertEqual(JSON.stringify($r('app.string.number_mark_source_teddy_bear')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkSourceInfo('2'))).assertEqual(JSON.stringify($r('app.string.number_mark_source_phone_state')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkSourceInfo('3'))).assertEqual(JSON.stringify($r('app.string.number_mark_source_antifraud_center')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkSourceInfo('5'))).assertEqual(JSON.stringify($r('app.string.national_anti_fraud_center')));
      expect(JSON.stringify(NumberMarkUtil.getNumberMarkSourceInfo('7'))).assertEqual(JSON.stringify($r('app.string.number_mark_source_oh')));
    })

    it('NumberMarkUtilTest_getNumberMarkType', 0, () => {
      expect(NumberMarkUtil.getNumberMarkType('none')).assertEqual(NumberMarkUtil.PRE_NONE_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('crank')).assertEqual(NumberMarkUtil.PRE_CRANK_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('fraud')).assertEqual(NumberMarkUtil.PRE_FRAUD_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('express')).assertEqual(NumberMarkUtil.PRE_EXPRESS_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('promote_sales')).assertEqual(NumberMarkUtil.PRE_PROMOTE_SALES_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('house_agent')).assertEqual(NumberMarkUtil.PRE_HOUSE_AGENT_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('insurance')).assertEqual(NumberMarkUtil.PRE_INSURANCE_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('taxi')).assertEqual(NumberMarkUtil.PRE_TAXI_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('custom')).assertEqual(NumberMarkUtil.PRE_CUSTOM_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('others')).assertEqual(NumberMarkUtil.OTHER_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('yellow_page')).assertEqual(NumberMarkUtil.YELLOW_PAGE_PHONE_DESC);
      expect(NumberMarkUtil.getNumberMarkType('enterprise')).assertEqual(NumberMarkUtil.MARK_TYPE_ENTERPRISE);
      expect(NumberMarkUtil.getNumberMarkType('custom11')).assertEqual(NumberMarkUtil.PRE_NONE_PHONE_DESC);
    })
  })
}