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
import { beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import common from '@ohos.app.ability.common';
import { HiLog } from '../../../../../../../../feature/call/oh_modules/common';
import resmgr from '@ohos.resourceManager';
import { EnterSingleSelectedMode } from '../../../../../../main/ets/model/type/EnumUtil';
import { BusinessError } from '@ohos.base';
import ResourceAudioManager from '../../../../../../main/ets/presenter/ringtone/ResourceAudioManager';
import { TAG } from '@ohos/hypium/src/main/Constant';


export default function ResourceAudioManagerTest() {
  describe('ResourceAudioManagerTest', () => {

    beforeEach(() => {
      AppStorage.clear();
    })

    it('ResourceAudioManagerTest_playFromFileOnce_001', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let uri: string = '';
      await ResourceAudioManager.playFromFileOnce(uri);
      mocker.verify('i', ['ResourceAudioManager', `playFromFileOnce done`]).once();
      mocker.clear(HiLog);
    })

    it('ResourceAudioManagerTest_playFromFileOnce_002', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let uri: string = '/sys_prod/variant/region_comm/china/resource/media/audio/ringtones/Amusement_Park.ogg';
      await ResourceAudioManager.playFromFileOnce(uri);
      mocker.verify('i', ['ResourceAudioManager', `playFromFileOnce done`]).once();
      mocker.clear(HiLog);
    })

    it('ResourceAudioManagerTest_playFromFileOnce_003', 0, async () => {
      let uri: string = '/sys_prod/variant/region_comm/china/resource/media/audio/ringtones/Amusement_Park.ogg';
      await ResourceAudioManager.playFromFileOnce(uri);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      await ResourceAudioManager.playFromFileOnce(uri);
      mocker.verify('i', ['ResourceAudioManager', `playFromFileOnce done`]).once();
      mocker.clear(HiLog);
    })

    it('ResourceAudioManagerTest_playFromFileLoop_001', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let uri: string = '';
      await ResourceAudioManager.playFromFileLoop(uri);
      mocker.verify('i', ['ResourceAudioManager', `playFromFileLoop done`]).once();
      mocker.clear(HiLog);
    })

    it('ResourceAudioManagerTest_playFromFileLoop_002', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let uri: string = '/sys_prod/variant/region_comm/china/resource/media/audio/ringtones/Amusement_Park.ogg';
      await ResourceAudioManager.playFromFileLoop(uri);
      mocker.verify('i', ['ResourceAudioManager', `playFromFileLoop done`]).once();
      mocker.clear(HiLog);
    })

    it('ResourceAudioManagerTest_playFromFileLoop_003', 0, async () => {
      let uri: string = '/sys_prod/variant/region_comm/china/resource/media/audio/ringtones/Amusement_Park.ogg';
      await ResourceAudioManager.playFromFileOnce(uri);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      await ResourceAudioManager.playFromFileLoop(uri);
      mocker.verify('i', ['ResourceAudioManager', `playFromFileLoop done`]).once();
      mocker.clear(HiLog);
    })

    it('ResourceAudioManagerTest_releaseRing_001', 0, async () => {
      let uri: string = '/sys_prod/variant/region_comm/china/resource/media/audio/ringtones/Amusement_Park.ogg';
      await ResourceAudioManager.playFromFileOnce(uri);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      ResourceAudioManager.releaseRing();
      mocker.verify('i', ['ResourceAudioManager', `releaseRing`]).once();
      mocker.clear(HiLog);
    })
  })
}