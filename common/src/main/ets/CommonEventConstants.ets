/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
export namespace CommonEventConstants {

  export const COMMON_EVENT_CHARGING = 'usual.event.CHARGING';
  export const COMMON_EVENT_DISCHARGING = 'usual.event.DISCHARGING';
  export const COMMON_EVENT_SCREEN_OFF = 'usual.event.SCREEN_OFF';
  export const COMMON_EVENT_SCREEN_ON = 'usual.event.SCREEN_ON';
  export const COMMON_EVENT_SPN_INFO_CHANGED = 'usual.event.SPN_INFO_CHANGED';
  export const COMMON_EVENT_SIM_CARD_DEFAULT_VOICE_SUBSCRIPTION_CHANGED =
    'usual.event.SIM.DEFAULT_VOICE_SUBSCRIPTION_CHANGED';
  // 目前单框架上拨打电话性能相比双框架还差这个方案没有落，在启动联系人的时候提前通知call_manager绑服务拉起callui，这个方案预估可以优化120ms左右
  // 单框架广播名称：event.custom.contacts.PAGE_STATE_CHANGE
  // 权限：ohos.permission.SET_TELEPHONY_STATE
  export const CUSTOM_EVENT_PAGE_STATE_CHANGE = 'event.custom.contacts.PAGE_STATE_CHANGE';
  export const CUSTOM_EVENT_PAGE_STATE_CHANGE_PERMISSION = 'ohos.permission.SET_TELEPHONY_STATE';
  export const COMMON_EVENT_THEME_INFO = 'com.ohos.ActivateTheme';

}