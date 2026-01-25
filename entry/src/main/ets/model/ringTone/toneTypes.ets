/**
 * Copyright (c) 2026 Huawei Device Co., Ltd.
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

import systemSoundManager from '@ohos.multimedia.systemSoundManager';
export interface ToneAttrs {
  title: string,
  fileName: string,
  uri: string,
  customizedType: systemSoundManager.ToneCustomizedType,
}

export interface RingtoneInfo {
  ringtoneName: string,
  ringtoneFilePath: string,
  ringtonePath: string,
  ringtoneType?: string,
}

/**

 本地铃声参数
 */
export class RingtoneParam {
  // 要发送给callui的联系人id
  public contactId?: string;
  // 页面类型 localMusic（本地歌曲）
  public pageType?: string;
  // 铃声类型 phone, message, notification, alarm
  public toneType?: string;
  // SIM卡类型：0, 1
  public card?: string;
  // 音乐app存在时设置选中的铃声路径
  public ringtonePath?: string = '';
  // 设置选中的铃声路径
  public selectedRingtonePath?: string = '';
  // 设置选中的铃声名字
  public selectedRingtoneName?: string = '';
  // 设置选中的铃音库名字
  public selectedLibraryRingtonePath?: string = '';
  // 是否显示标题栏
  public showTitle: boolean = false;
  // 设置选中的铃声id
  public selectRingtoneContentId: string = '';
}
/**

 铃声类型枚举
 */
export enum ToneType {
  RINGTONE = 'phone',
  MESSAGE_TONE = 'message',
  NOTIFICATION_TONE = 'notification',
  INVALID_TONE = 'invalid',
  ALARM = 'alarm',
  CONTACT = 'contact'
}
/**

 页面类型枚举
 */
export enum PageType {
  LOCAL_PAGE_TYPE = 'localMusic',
  ONLINE_PAGE_TYPE = 'onlineRingtone',
}
/**

 页面类型枚举
 */
export enum RingtoneType {
  SYSTEM_TYPE = '0',
  LOCAL_TYPE = '1',
  LOCAL_VIDEO_TYPE = '2',
}