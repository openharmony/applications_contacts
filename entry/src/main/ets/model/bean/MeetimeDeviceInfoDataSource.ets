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
import BasicDataSource from './BasicDataSource';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import MeeTimeDeviceInfoModel from '../../../../../../feature/contact/src/main/ets/entity/MeeTimeDeviceInfoModel';
const TAG = 'MeetimeDeviceInfoDataSource';

export default class MeetimeDeviceInfoDataSource extends BasicDataSource {
  public deviceList: MeeTimeDeviceInfoModel[] = [];

  public totalCount(): number {
    return this.deviceList.length;
  }

  public getData(index: number): MeeTimeDeviceInfoModel | null | undefined {
    if (ArrayUtil.isEmpty(this.deviceList)) {
      HiLog.i(TAG, 'getData MeetimeDeviceInfoDataSource is empty')
      return null;
    }
    if (index >= this.deviceList.length) {
      HiLog.i(TAG, 'getData MetimeDeviceInfoDataSource index exceed list lenth');
      return null;
    }
    const deviceInfo = this.deviceList[index];
    return deviceInfo;
  }

  public refresh(deviceInfoModelArr: MeeTimeDeviceInfoModel[]) {
    HiLog.i(TAG, `refresh target count: ${deviceInfoModelArr.length}`);
    this.deviceList = deviceInfoModelArr;
    this.notifyDataReload();
  }

  public getAlData(): MeeTimeDeviceInfoModel[] {
    return this.deviceList;
  }
}