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
import { beforeEach, describe, expect, it} from '@ohos/hypium';
import RingTonePresenter from '../../../../../../main/ets/presenter/ringtone/RingTonePresenter';
import { bundleManager } from '@kit.AbilityKit';

export default function RingTonePresenterTest() {
  const MUSIC_APP_BUNDLE_NAME = 'com.ohos.hmsapp.music';
  const MUSIC_APP_METADATA_LOCAL = 'feature-ringtonesetting.localmusic';
  describe('RingTonePresenterTest', () => {

    beforeEach(() => {
    })

    it('RingTonePresenterTest_getInstance_001', 0, async () => {
      let presenter = RingTonePresenter.getInstance();
      expect(presenter).not().assertNull();
    })

    it('RingTonePresenterTest_getTestInstance_001', 0, async () => {
      let presenter = RingTonePresenter.getTestInstance();
      expect(presenter).not().assertNull();
    })

    // bundleInfo null:当前不支持mock namespace函数，mock系统API的方式也不支持切换不同实现，因此暂时无法覆盖各种异常分支
    // it('RingTonePresenterTest_isMusicAppSupportLocalMusic_001', 0, async () => {
    //   let mocker: MockKit = new MockKit();
    //   mocker.mockFunc(bundleManager, bundleManager.getBundleInfo);
    // })

    it('RingTonePresenterTest_isMusicAppSupportLocalMusic_002', 0, async () => {
      let isMusicAppSupport = await RingTonePresenter.getInstance().isMusicAppSupportLocalMusic();

      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfo(MUSIC_APP_BUNDLE_NAME,
          bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
          bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA);
      if (bundleInfo === undefined) {
        expect(isMusicAppSupport).assertFalse();
        return;
      }
      let moduleMetaDataArray: bundleManager.ModuleMetadata[] = bundleInfo.appInfo?.metadataArray;
      if (moduleMetaDataArray === undefined || moduleMetaDataArray.length === 0) {
        expect(isMusicAppSupport).assertFalse();
        return;
      }
      let metaDataArray: bundleManager.Metadata[] = moduleMetaDataArray[0].metadata;
      if (metaDataArray === undefined || metaDataArray.length === 0) {
        expect(isMusicAppSupport).assertFalse();
        return;
      }
      for (let index = 0; index < metaDataArray.length; index++) {
        const metaData = metaDataArray[index];
        if (metaData.name === MUSIC_APP_METADATA_LOCAL && metaData.value !== '0') {
          expect(isMusicAppSupport).assertTrue();
          return;
        }
      }
      expect(isMusicAppSupport).assertFalse();
    })
  })
}