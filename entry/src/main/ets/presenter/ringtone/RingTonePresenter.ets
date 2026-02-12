/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { HiLog, StringUtil } from '../../../../../../common';
import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  ContactsGlobalThisHelper
} from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { systemSoundManager } from '@kit.AudioKit';
import { RingtoneInfo } from '../../model/ringTone/toneTypes';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import { RingtoneItem, RingtoneSelectionUtil } from '../../util/RingtoneSelectionUtil';
import GroupIdUtil from '../../util/GroupIdUtil';
import fs from '@ohos.file.fs';

const TAG = 'RingTonePresenter ';
const NO_RING_TONE: string = '-1';
const MUSIC_APP_BUNDLE_NAME = 'com.ohos.hmsapp.music';
const MUSIC_APP_METADATA_LOCAL = 'feature-ringtonesetting.localmusic';

export default class RingTonePresenter {
  public pathInfos: NavPathStack = new NavPathStack();
  private static instance: RingTonePresenter | null;
  public contactId: string = '';
  // 是否从本地音乐界面返回选择铃声界面
  public isFromLocalMusic: boolean = false;
  // 是否从选择视频铃声界面返回选择铃声界面
  public isFromVideoMusic: boolean = false;
  // 选择铃声过程中记录选中的铃声，也是最后需要保存的铃声信息
  public selectedRingtoneInfo: RingtoneInfo = {
    ringtoneName: '',
    ringtoneFilePath: '',
    ringtonePath: '',
    ringtoneType: '0',
  };

  // 记录该联系人之前的铃音uri
  public originalContactRingtoneInfo: string = '';
  // 本地铃声页面返回时触发的回调函数
  public backFromLocalMusic = () => {
  }

  private systemSoundManagerInstance: systemSoundManager.SystemSoundManager | undefined =
    systemSoundManager.getSystemSoundManager();

  public static getInstance(): RingTonePresenter {
    if (!RingTonePresenter.instance) {
      RingTonePresenter.instance = new RingTonePresenter();
    }
    return RingTonePresenter.instance;
  }

  public static getTestInstance(): RingTonePresenter {
    return new RingTonePresenter();
  }

  /**
   * 判断音乐App是否已安装场景
   * @param want
   */
  async isMusicAppSupportLocalMusic(): Promise<boolean> {
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfo(MUSIC_APP_BUNDLE_NAME,
          bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
          bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA);
      if (bundleInfo === undefined) {
        HiLog.w(TAG, `isMusicAppSupportLocalMusic bundleInfo is undefined`);
        return false;
      }
      let moduleMetaDataArray: bundleManager.ModuleMetadata[] = bundleInfo.appInfo?.metadataArray;
      if (moduleMetaDataArray === undefined || moduleMetaDataArray.length === 0) {
        HiLog.w(TAG, `isMusicAppSupportLocalMusic moduleMetaDataArray is empty`);
        return false;
      }
      let metaDataArray: bundleManager.Metadata[] = moduleMetaDataArray[0].metadata;
      if (metaDataArray === undefined || metaDataArray.length === 0) {
        HiLog.w(TAG, `isMusicAppSupportLocalMusic metaDataArray is empty`);
        return false;
      }
      for (let index = 0; index < metaDataArray.length; index++) {
        const metaData = metaDataArray[index];
        if (metaData.name === MUSIC_APP_METADATA_LOCAL && metaData.value !== '0') {
          HiLog.w(TAG, `isMusicAppSupportLocalMusic true`);
          return true;
        }
      }
      HiLog.w(TAG, `isMusicAppSupportLocalMusic no support metaData, metaDataArray size: ${metaDataArray?.length}`);
      return false;
    } catch (error) {
      HiLog.w(TAG,
        `isMusicAppSupportLocalMusic error: ${(error as BusinessError).message} ${(error as BusinessError).code}`);
    }
    return false;
  }

  // 保存联系人铃声数据到数据库
  saveRingToneToContact(context: Context) {
    if (StringUtil.isEmpty(this.contactId)) {
      HiLog.e(TAG, 'contact is not existed ');
      return;
    }
    try {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('saveRingToneToContact', {
          id: this.contactId,
          uri: this.selectedRingtoneInfo.ringtonePath,
          ringToneName: this.selectedRingtoneInfo.ringtoneName,
          ringToneFilePath: this.selectedRingtoneInfo.ringtoneFilePath
        }, async (result: boolean) => {
          HiLog.w(TAG, `saveRingToneToContact succ: ${result}`);
          this.removeContactLocalRingtone(context);
        });
    } catch (error) {
      HiLog.e(TAG, `saveRingToneToContact error: ${error?.message}`);
      return;
    }
  }

  async removeContactLocalRingtone(context: Context) {
    HiLog.i(TAG, `removeContactLocalRingtone ${this.originalContactRingtoneInfo}`);
    if (!context) {
      HiLog.w(TAG, `context is undefined`);
      context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    }
    let ringtoneResult: RingtoneItem | undefined =
      await RingtoneSelectionUtil.findRingtoneFromList(this.originalContactRingtoneInfo);
    if ((ringtoneResult && !StringUtil.isEmpty(ringtoneResult.path)) ||
    StringUtil.isEmpty(this.originalContactRingtoneInfo) || this.originalContactRingtoneInfo === NO_RING_TONE) {
      HiLog.w(TAG, `originalContactRingtoneInfo is not localMusic`);
      return;
    }
    if (this.originalContactRingtoneInfo === this.selectedRingtoneInfo.ringtonePath) {
      HiLog.w(TAG, `originalContactRingtoneInfo is not change`);
      return;
    }

    try {

      // 代码可能还有用，请不要删除
      // 当前铃音库已经处理多联系人对应同一本地音乐场景，即每一个联系人的本地音乐铃声URI都是独一无二的
      // 联系人暂不用处理数据库中相同铃音URI的数量大于一时调用removeCustomizedTone接口
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('queryLocalRingToneUsedTimes', {
          id: this.contactId,
          uri: this.originalContactRingtoneInfo
        }, (result: number) => {
          HiLog.w(TAG, `queryLocalRingToneUsedTimes succ: ${result}`);
          if (result < 1) {
            if (!this.systemSoundManagerInstance) {
              this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
            }
            this.systemSoundManagerInstance.removeCustomizedTone(context, this.originalContactRingtoneInfo);
          }
        });
    } catch (error) {
      HiLog.e(TAG, `removeCustomizedTone error: ${error?.message}`);
      return;
    }
  }

  async removeContactLocalVideoRingtone(context: Context, originalContactRingtoneInfo: string) {
    HiLog.i(TAG, `removeContactLocalVideoRingtone ${originalContactRingtoneInfo}`);
    if (!context) {
      HiLog.w(TAG, `video ringtone context is undefined`);
      context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    }
    if (originalContactRingtoneInfo === this.selectedRingtoneInfo.ringtonePath) {
      HiLog.w(TAG, `originalContactRingtoneInfo is not change`);
      return;
    }

    try {
      if (!this.systemSoundManagerInstance) {
        this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
      }
      this.systemSoundManagerInstance.removeCustomizedTone(context, originalContactRingtoneInfo);
    } catch (error) {
      HiLog.e(TAG, `removeCustomizedTone error: ${error?.message}`);
      return;
    }
  }
}