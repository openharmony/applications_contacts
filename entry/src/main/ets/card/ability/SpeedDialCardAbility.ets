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
import { FormEditExtensionAbility } from '@kit.FormKit';
import { Want, UIExtensionContentSession } from '@kit.AbilityKit';
import { ExtensionEvent } from '../model/FormExtensionEvent';
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import SpeedDialEditCommon from '../common/SpeedDialEditCommon';
import { SpeedDialDataType } from '../type/speedDial';
import { getHeadChar } from '../../util/UserPhoto';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { BreakpointUtil } from '../../util/BreakpointUtil';
import ScreenFormUtil from '../../util/ScreenFormUtil';
import { display } from '@kit.ArkUI';

const TAG = 'SpeedDialCardAbilityTAG';
const SECOND_EDIT_ABILITY_NAME = 'FormEditExtensionAbility'
const LOCAL: Record<string, string | SpeedDialDataType[]> = { 'formId': '', 'previewFormId': '', 'speedDialData': [] };

export default class SpeedDialCardAbility extends FormEditExtensionAbility {
  public storage: LocalStorage = new LocalStorage(LOCAL);
  public common: SpeedDialEditCommon = new SpeedDialEditCommon();
  public formId: SubscribedAbstractProperty<string> = this.storage.link('formId');
  public previewFormId: SubscribedAbstractProperty<string> = this.storage.link('previewFormId');
  public speedDialData: SubscribedAbstractProperty<SpeedDialDataType[]> = this.storage.link('speedDialData');

  onCreate() {
    HiLog.w(TAG, `Ability onCreate`);
  }

  onForeground(): void {
    HiLog.w(TAG, `Ability onForeground`);
  }

  async onBackground() {
    HiLog.w(TAG, `Ability onBackground`);
  }

  onDestroy() {
    HiLog.w(TAG, `Ability onDestroy`);
  }

  async onSessionCreate(want: Want, session: UIExtensionContentSession) {
    HiLog.w(TAG, `FaFormEditExtensionAbility onSessionCreate start`);

    // 获取编辑卡片id和预览卡片id
    const formId: string | undefined = want.parameters?.cardId as string;
    const previewFormId: string | undefined = want.parameters?.previewCardId as string;
    const abilityName: string | undefined = want.abilityName
    if (formId) {
      this.formId.set(formId);
    }
    if (previewFormId) {
      this.previewFormId.set(previewFormId)
    }
    HiLog.w(TAG, `formId: ${formId}, previewFormId: ${previewFormId}`)

    let res = await this.common.queryContactByFormId(formId, this.context);
    res.forEach(item => {
      if (item) {
        (item as SpeedDialDataType).nameSuffix = getHeadChar((item as SpeedDialDataType).displayName);
      }
    })
    this.speedDialData.set(res);

    AppStorage.setOrCreate('cardFormId', formId)
    AppStorage.setOrCreate('cardPreviewFormId', previewFormId)
    AppStorage.setOrCreate('cardAbilityName', abilityName)

    let extensionEvent: ExtensionEvent = new ExtensionEvent();
    extensionEvent.setStartSecondPage(() => this.startSecondPage());
    this.storage.setOrCreate('extensionEvent', extensionEvent);
    this.storage.setOrCreate('session', session);
    ContactsGlobalThisHelper.GetGlobalThis()
      .set<UIExtensionContentSession>(ContactsGlobalThisHelper.UiExtentionAbilityUIExtensionContentSession, session);

    try {
      ScreenFormUtil.addFoldStatusRegister();
      // 窗口大小
      BreakpointUtil.judgingVerdeBreakpoint(display.getDefaultDisplaySync());
      let windowProxy = session.getUIExtensionHostWindowProxy();
      windowProxy.on('windowSizeChange', (data) => {
        BreakpointUtil.judgingVerdeBreakpoint(display.getDefaultDisplaySync());
      });
    } catch (err) {
      HiLog.e(TAG, `Failed to obtain the window size. code: ${err?.code}, err: ${err?.message}`);
    }

    try {
      session.loadContent('card/pages/SpeedDialEditPage', this.storage);
      HiLog.i(TAG, `loadContent first edit page success`);
      session.setWindowBackgroundColor('#00000000');
    } catch (e) {
      HiLog.e(TAG, `EntryFormEditAbility loadContent err, want: ${e?.message}`);
    }
  }

  private startSecondPage(): void {
    const bundleName: string = this.context.extensionAbilityInfo.bundleName;
    const secPageAbilityName: string = SECOND_EDIT_ABILITY_NAME;
    HiLog.i(TAG, `startSecondPage. bundleName: ${bundleName}, secPageAbilityName: ${secPageAbilityName}.`);
    try {
      this.context.startSecondPage({
        bundleName: bundleName,
        parameters: {
          'secPageAbilityName': secPageAbilityName,
        },
      });
    } catch (err) {
      HiLog.i(TAG, `startSecondPage failed: ${err?.message}`);
    }
  }
}
