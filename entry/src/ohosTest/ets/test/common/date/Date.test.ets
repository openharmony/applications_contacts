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
import { describe, it, expect } from '@ohos/hypium';
import { MonthInfo, YearData } from '../../../../../../../common/src/main/ets/date/Date'

export default function DateTest() {
  describe('DateTest', () => {

    it('DateTest_YearData_getMonthInfo_undefined', 0, () => {
      let yearData: YearData = new YearData(2024);
      expect(yearData.getMonthInfo(0)).assertUndefined();
    })

    it('DateTest_MonthInfo_getDayData_undefined', 0, () => {
      let monthInfo: MonthInfo = new MonthInfo(2024, 11);
      expect(monthInfo.getDayData(0)).assertUndefined();
    })
  })
}