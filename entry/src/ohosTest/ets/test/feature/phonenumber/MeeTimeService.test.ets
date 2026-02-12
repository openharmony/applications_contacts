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
import { describe, expect, it, MockKit, when } from '@ohos/hypium';
import CallServiceManager from '../../../../../../../feature/phonenumber/src/main/ets/idl/CallServiceManager';
import MeeTimeService from '../../../../../../../feature/phonenumber/src/main/ets/MeeTimeService';

export default function MeeTimeServiceTest() {
  describe('MeeTimeServiceTest', () => {
    it('MeeTimeService_meeTimeCall', 0, () => {
      let result = false;
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(CallServiceManager.getInstance(),CallServiceManager.getInstance().placeCall))('570977632')
        .afterAction(()=>{
          result = true;
          return new Promise<boolean>(resolve => resolve(true));
        });
      MeeTimeService.meeTimeCall('570977632',1);
      expect(result).assertTrue();
      mocker.clear(CallServiceManager.getInstance());
    })

    it('MeeTimeService_meeTimeVideo', 0, () => {
      let result = false;
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(CallServiceManager.getInstance(),CallServiceManager.getInstance().placeCall))('570977632')
        .afterAction(()=>{
          result = true;
          return new Promise<boolean>(resolve => resolve(true));
        });
      MeeTimeService.meeTimeVideo('570977632',1);
      expect(result).assertTrue();
      mocker.clear(CallServiceManager.getInstance());
    })

    it('MeeTimeService_isMeeTimeLogin', 0, async () => {
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(CallServiceManager.getInstance(),CallServiceManager.getInstance().isLoginMeetime))()
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      expect(await MeeTimeService.isMeeTimeLogin()).assertTrue();
      mocker.clear(CallServiceManager.getInstance());
    })

    it('MeeTimeService_syncContactMeeTimeAbility', 0, async () => {
      let mocker:MockKit = new MockKit();
      let phoneNumbers: Record<string, string | number>[] = [{
        '1': '570977632'
      }];
      when(mocker.mockFunc(CallServiceManager.getInstance(),CallServiceManager.getInstance().syncContactMeeTimeAbility))(1)
        .afterReturn(new Promise<string>(resolve => resolve('')));
      expect(await MeeTimeService.syncContactMeeTimeAbility(1,phoneNumbers)).assertEqual('');
      mocker.clear(CallServiceManager.getInstance());
    })
  })
}