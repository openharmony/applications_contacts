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
import { describe, it, expect } from '@ohos/hypium'
import { CallRecordTimeFormatUtils } from '../../../../../../../feature/call/oh_modules/common'

export default function CallRecordTimeFormatUtilsTest() {
  describe('CallRecordTimeFormatUtilsTest', () => {

    it("CallRecordTimeFormatUtilsTest_duration01", 0, () => {
      const str = CallRecordTimeFormatUtils.duration(3600000);
      expect(str).assertEqual('1小时 0分0秒');
    })

    it("CallRecordTimeFormatUtilsTest_duration02", 0, () => {
      const str = CallRecordTimeFormatUtils.duration(182000);
      expect(str).assertEqual('3 分 2 秒');
    })

    it("CallRecordTimeFormatUtilsTest_duration03", 0, () => {
      const str = CallRecordTimeFormatUtils.duration(30000);
      expect(str).assertEqual('30 秒');
    })

    it("CallRecordTimeFormatUtilsTest_getYear01", 0, () => {
      const time = CallRecordTimeFormatUtils.getYear(2024);
      expect(time).assertEqual('1970年01月01日 08:00');
    })

    it("CallRecordTimeFormatUtilsTest_getYear02", 0, () => {
      let param: number = new Date(new Date().setHours(0, 0, 0, 0)).getTime() + 100;
      let now = new Date(param) as Date;
      let h = (now.getHours() < 10 ? '0' + now.getHours() : now.getHours());
      let m = (now.getMinutes() < 10 ? '0' + now.getMinutes() : now.getMinutes());

      const time = CallRecordTimeFormatUtils.getYear(param);

      expect(time).assertEqual(h + ':' + m);
    })

    it("CallRecordTimeFormatUtilsTest_getYear03", 0, () => {
      let param: number = new Date(new Date().setHours(0, 0, 0, 0)).getTime();

      let now = new Date(param) as Date;
      let M = (now.getMonth() + 1 < 10 ? '0' + (now.getMonth() + 1) : now.getMonth() + 1);
      let D = (now.getDate() < 10 ? '0' + now.getDate() : now.getDate());
      let h = (now.getHours() < 10 ? '0' + now.getHours() : now.getHours());
      let m = (now.getMinutes() < 10 ? '0' + now.getMinutes() : now.getMinutes());

      const time = CallRecordTimeFormatUtils.getYear(param);

      expect(time).assertEqual(M + '月' + D + '日 ' + h + ':' + m);
    })
  })
}