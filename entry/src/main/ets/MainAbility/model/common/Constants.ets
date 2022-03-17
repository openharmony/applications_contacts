/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

export enum DeviceType {
  PHONE,
  WGR
}

export default {
  uri: {
    CALLLOG_DB_URI: 'dataability:///com.ohos.calllogability', // 通话记录数据库uri,用于获取通话记录数据库DAHelper
    CALLS_URI_PREFIX: 'dataability:///com.ohos.calllogability/calls/', // 查询calls库各种表uri前缀
    CALL_LOG_URI: 'dataability:///com.ohos.calllogability/calls/calllog', // 通话记录表操作uri

    CONTACT_DB_URI: 'dataability:///com.ohos.contactsdataability', // 连接联系人数据库的uri,用于获取联系人数据库DAHelper
    CONTACTS_URI_PREFIX: 'dataability:///com.ohos.contactsdataability/contacts/', // 查询contacts库各种表uri前缀
    CONTACT_URI: 'dataability:///com.ohos.contactsdataability/contacts/contact',
    ROW_CONTACTS_URI: 'dataability:///com.ohos.contactsdataability/contacts/raw_contact', // 对raw_contacts表操作的uri
    CONTACT_DATA_URI: 'dataability:///com.ohos.contactsdataability/contacts/contact_data', // 对contact_data表操作的uri
    CONTACT_TYPE_URI: 'dataability:///com.ohos.contactsdataability/contacts/contact_type',
    SEARCH_CONTACT_URI: 'dataability:///com.ohos.contactsdataability/contacts/search_contact',
    GROUPS_URI: 'dataability:///com.ohos.contactsdataability/contacts/groups',
    PROFILE_ROW_CONTACTS_URI: 'dataability:///com.ohos.contactsdataability/profile/raw_contact', // 我的名片raw_contact表操作uri
    PROFILE_CONTACT_DATA_URI: 'dataability:///com.ohos.contactsdataability/profile/contact_data', // 我的名片contact_data表操作的uri

    VOICEMAIL_DB_URI: 'dataability:///com.ohos.voicemailability', // 连接语音信箱数据库的uri,用于获取语音信箱数据库DAHelper
    VOICEMAIL_URI_PREFIX: 'dataability:///com.ohos.voicemailability/calls/', // 查询voicemail库各种表uri前缀
    VOICEMAIL_URI: 'dataability:///com.ohos.voicemailability/calls/voicemail'
  },
  background: {
    // 头像背景颜色
    Color: ['#98D4EF', '#9CC998', '#E8889C', '#C891F1', '#F9C273', '#92D6CC'],
    // 详情页背景色
    detailColor: ['#DAEFF9', '#E9F3E8', '#FAD9E0', '#EEDAFD', '#FDECD2', '#DFF5F2'],
  },
  int: {
    // 查询数据库返回结构
    SUCCESS: 0,
    FAILED: -1,
    ZERO: 0
  },
  string: {
    // 轻量级数据库文件名
    PATH_OF_PREFERENCES: 'PREFERENCES_FOR_CONTACTS',
    // 是否是简洁布局
    CONCISE_LAYOUT_SWITCH: 'contacts_settings_concise_layout_switch',
    // 查询联系人类型
    DISPLAY_ACCOUNT_RADIO: 'contacts_settings_display_account_radio',
    // 自定义联系人视图
    CUSTOMIZE_VIEW_INPUT: 'contacts_settings_customize_view_input',
    // 联系人数量
    CONTACTS_COUNT: 'contacts_count',
    EMPTY_STR: '',
    CALL_LOG_MERGE_RULE: 'call_log_merge_rule',
    MMS_BUNDLE_NAME: "com.ohos.mms",
    MMS_ABILITY_NAME: "com.ohos.mms.MainAbility",
    MMS_ENTITIES: 'entity.system.home'
  },
  bool: {
    TRUE: true,
    FALSE: false
  },

  deviceType: DeviceType.WGR
}



