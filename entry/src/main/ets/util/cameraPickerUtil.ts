/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// @ts-ignore
import common from '@ohos.app.ability.common';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { DynamicLoadSoUtil } from '../../../../../common/src/main/ets/util/DynamicLoadSoUtil';
import { CameraPosition, PickerMediaType, PickerProfile, PickerResult } from '../model/bean/cameraPicker';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'cameraPickerUtil';

export default class CameraPickerUtil {
  static async pick(context: common.UIAbilityContext, callback: Function): Promise<void> {
    HiLog.i(TAG, 'importVCard start');
    try {
      let cameraPicker = await DynamicLoadSoUtil.getInstance().loadCameraPicker();
      const pickerProfile: PickerProfile = {
        cameraPosition: CameraPosition.CAMERA_POSITION_BACK,
      };
      cameraPicker?.default?.pick(context, [PickerMediaType.PHOTO],
        pickerProfile).then((data: PickerResult) => {
        callback(data);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `cameraPicker error: ${error?.code}`);
      });
    } catch (error) {
      HiLog.e(TAG, `import cameraPicker error ${error?.message}`);
    }
  }
}