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
import { HiLog } from './HiLog';
import common from '@ohos.app.ability.common';
import type UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import type audio from '@ohos.multimedia.audio';
const TAG = 'ContactsGlobalContextThisHelper';

export class ContactsGlobalThisHelper {
  private constructor() {
  }

  private static instance: ContactsGlobalThisHelper;
  private objects = new Map<string, Object>();
  static readonly UIContextName: string = 'UIAbilityContext';
  static readonly DataWorkerName: string = 'mDataWorker';
  static readonly IndexPresenterName: string = 'IndexPresenter';
  static readonly TimeFormatName: string = 'SettingTimeFormat';
  static readonly SpeedDialContextName: string = 'SpeedDialContext';
  static readonly CardDialogContextName: string = 'CardDialogContext';
  static readonly CardContextName: string = 'CardContext';
  static readonly CardMissedCallAbilityContextName: string = 'CardMissedCallAbilityContext';
  static readonly CardShortcutAbilityContextName: string = 'CardShortcutAbilityContext';
  static readonly CardSpeedDialAbilityContextName: string = 'CardSpeedDialAbilityContext';
  static readonly CardDialogExtensionAbilityContextName: string = 'CardDialogExtensionAbilityContext';
  // 畅连聊天通信对象；畅连聊天，在点击输入框，键盘弹起后，需要将键盘高度传给畅连聊天，使用此通信对象传递高度信息
  static readonly MeeTimeLoginFlagName: string = 'meeTimeLoginFlagName';
  // 通过UiExtentionAbility访问的应用
  static readonly UiExtentionAbilityFromName: string = 'UiExtentionAbilityFromName';
  static readonly UiExtentionAbilityUIExtensionContentSession: string = 'uIExtensionContentSession';
  static readonly UiExtentionAbilityParams: string = 'UiExtentionAbilityParams';
  static readonly AudioRingMode: string = 'audio.AudioRingMode';
  static readonly ToEditBeforeCallingFromExternalAppFlag: string = 'ToEditBeforeCallingFromExternalAppFlag';

  private static registerKeys = [
    ContactsGlobalThisHelper.UIContextName,
    ContactsGlobalThisHelper.DataWorkerName,
    ContactsGlobalThisHelper.IndexPresenterName,
    ContactsGlobalThisHelper.TimeFormatName,
    ContactsGlobalThisHelper.SpeedDialContextName,
    ContactsGlobalThisHelper.CardDialogContextName,
    ContactsGlobalThisHelper.CardContextName,
    ContactsGlobalThisHelper.CardMissedCallAbilityContextName,
    ContactsGlobalThisHelper.CardShortcutAbilityContextName,
    ContactsGlobalThisHelper.CardSpeedDialAbilityContextName,
    ContactsGlobalThisHelper.CardDialogExtensionAbilityContextName,
    ContactsGlobalThisHelper.UiExtentionAbilityFromName,
    ContactsGlobalThisHelper.UiExtentionAbilityUIExtensionContentSession,
    ContactsGlobalThisHelper.UiExtentionAbilityParams,
    ContactsGlobalThisHelper.MeeTimeLoginFlagName,
    ContactsGlobalThisHelper.AudioRingMode,
    ContactsGlobalThisHelper.ToEditBeforeCallingFromExternalAppFlag,
  ];

  public static GetGlobalThis(): ContactsGlobalThisHelper {
    if (!ContactsGlobalThisHelper.instance) {
      ContactsGlobalThisHelper.instance = new ContactsGlobalThisHelper();
    }
    return ContactsGlobalThisHelper.instance;
  }

  getValue<T>(value: string): T {
    return this.objects.get(value) as T;
  }

  hasValue(key: string): boolean {
    const element = ContactsGlobalThisHelper.registerKeys.find((ele: string) => ele === key);
    if (element === undefined) {
      return false;
    }
    return true;
  }

  set<T extends Object>(key: string, value: T): void {
    const element = ContactsGlobalThisHelper.registerKeys.find((ele: string) => ele === key);
    if (element === undefined) {
      HiLog.i(TAG, "ContactsGlobalThisHelper cant't find register key:" + key);
      return;
    }
    this.objects.set(key, value);
  }

  remove(key: string): void {
    this.objects.delete(key);
  }

  clear(): void {
    let context: common.FormExtensionContext = this.getDefaultCardContext();
    this.objects?.clear();
    this.set(ContactsGlobalThisHelper.CardContextName, context);
  }
  getDefaultUIContext(): common.UIAbilityContext {
    let context: common.UIAbilityContext =
      this.objects.get(ContactsGlobalThisHelper.UIContextName) as common.UIAbilityContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getDefaultUIContext before set value time:' + (new Date()).valueOf());
      return globalThis.context;
    }
    return context;
  }

  getDefaultCardDialogContext(): common.UIAbilityContext {
    let context: common.UIAbilityContext =
      this.objects.get(ContactsGlobalThisHelper.CardDialogContextName) as common.UIAbilityContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getDefaultCardDialogContext before set value');
      return globalThis.context;
    }
    return context;
  }

  getDefaultCardContext(): common.FormExtensionContext {
    let context: common.FormExtensionContext =
      this.objects.get(ContactsGlobalThisHelper.CardContextName) as common.FormExtensionContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getDefaultCardContext before set value');
      return globalThis.context;
    }
    return context;
  }

  getCardMissedCallAbilityContext(): common.UIAbilityContext {
    let context: common.UIAbilityContext =
      this.objects.get(ContactsGlobalThisHelper.CardMissedCallAbilityContextName) as common.UIAbilityContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getCardMissedCallAbilityContext before set value');
      return globalThis.context;
    }
    return context;
  }

  getCardShortcutAbilityContext(): common.UIAbilityContext {
    let context: common.UIAbilityContext =
      this.objects.get(ContactsGlobalThisHelper.CardShortcutAbilityContextName) as common.UIAbilityContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getCardShortcutAbilityContext before set value');
      return globalThis.context;
    }
    return context;
  }

  getCardSpeedDialAbilityContext(): common.UIAbilityContext {
    let context: common.UIAbilityContext =
      this.objects.get(ContactsGlobalThisHelper.CardSpeedDialAbilityContextName) as common.UIAbilityContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getCardSpeedDialAbilityContext before set value');
      return globalThis.context;
    }
    return context;
  }

  getCardDialogExtensionAbilityContext(): common.UIExtensionContext {
    let context: common.UIExtensionContext =
      this.objects.get(ContactsGlobalThisHelper.CardDialogExtensionAbilityContextName) as common.UIExtensionContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getCardDialogExtensionAbilityContext before set value');
      return globalThis.context;
    }
    return context;
  }

  getCardUIContext(): common.UIAbilityContext {
    let context: common.UIAbilityContext =
      this.objects.get(ContactsGlobalThisHelper.CardContextName) as common.UIAbilityContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getDefaultUIContext before set value');
      return globalThis.context;
    }
    return context;
  }
  getDetaultContext(): common.Context {
    let context: common.Context = this.objects.get(ContactsGlobalThisHelper.UIContextName) as common.Context;
    if (context === undefined) {
      HiLog.i(TAG, 'call getDetaultContext before set value' + ' time:' + (new Date()).valueOf());
      return globalThis.context;
    }
    return context;
  }

  getUIExtensionContentSession(): UIExtensionContentSession {
    let uIExtensionContentSession: UIExtensionContentSession =
      this.objects.get(ContactsGlobalThisHelper.UiExtentionAbilityUIExtensionContentSession) as UIExtensionContentSession;
    return uIExtensionContentSession;
  }

  getSpeedDialContext(): common.UIAbilityContext {
    let context: common.UIAbilityContext =
      this.objects.get(ContactsGlobalThisHelper.SpeedDialContextName) as common.UIAbilityContext;
    if (context === undefined) {
      HiLog.i(TAG, 'call getSpeedDialContext before set value');
      return globalThis.context;
    }
    return context;
  }

  getAudioRingMode(): audio.AudioRingMode {
    return this.objects.get(ContactsGlobalThisHelper.AudioRingMode) as audio.AudioRingMode;
  }
}