
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

import { describe, it, expect, MockKit } from '@ohos/hypium';
import MeetimeDeviceInfoDataSource from '../../../../../../main/ets/model/bean/MeetimeDeviceInfoDataSource';
import { ArrayUtil } from '../../../../../../../../common/src/main/ets/util/ArrayUtil';
import MeeTimeDeviceInfoModel from '../../../../../../../../feature/contact/src/main/ets/entity/MeeTimeDeviceInfoModel'

export default function MeetimeDeviceInfoDataSourceTest() {
  describe('MeetimeDeviceInfoDataSourceTest', () => {
    it('MeetimeDeviceInfoDataSourceTest_totalCount', 0, () => {
      let cd = new MeetimeDeviceInfoDataSource();
      expect(cd.totalCount()).assertEqual(0);
    })
    it('MeetimeDeviceInfoDataSourceTest_getData', 0, () => {
     let deviceList: MeeTimeDeviceInfoModel[] = [];
     let cd = new MeetimeDeviceInfoDataSource();
      if (ArrayUtil.isEmpty(deviceList)) {
        expect(cd.getData(0)).assertEqual(null)
      }
    })
    it('MeetimeDeviceInfoDataSourceTest_getData_002', 0, () => {
      let index = 1;
      let meeTimeDeviceInfoModel: MeeTimeDeviceInfoModel =
        new MeeTimeDeviceInfoModel('1', 0, '1')
      let deviceList: MeeTimeDeviceInfoModel[] = [meeTimeDeviceInfoModel];
      let cd = new MeetimeDeviceInfoDataSource();
      cd.deviceList = deviceList;
      expect(cd.getData(index)).assertNull();

      expect(JSON.stringify(cd.getData(0))).assertEqual(JSON.stringify(meeTimeDeviceInfoModel));
      expect(JSON.stringify(cd.getAlData())).assertEqual(JSON.stringify(deviceList));
    })
    it('MeetimeDeviceInfoDataSourceTest_refresh', 0, () => {
      let deviceList: MeeTimeDeviceInfoModel[] = [];
      let cd = new MeetimeDeviceInfoDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(deviceList)
      mocker.verify('notifyDataReload',[]).once();
      mocker.clear(cd);
    })
  })
}