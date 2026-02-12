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
import { RadioDataType } from '../type/missedCall';

class commonDataClass {
  public string: stringClass = new stringClass();
}

class stringClass {
  public CONTACT_BUNDLE_NAME: string = '';
  public CONTACT_ABILITY_NAME: string = '';
  public COMMON_ENTITIES: string = '';
  public PAGE_FLAG_SINGLE_CHOOSE: string = '';
  public PAGE_FLAG_MULTI_CHOOSE: string = '';
}

export const commonData: commonDataClass = {
  string: {
    CONTACT_BUNDLE_NAME: 'com.ohos.contacts',
    CONTACT_ABILITY_NAME: 'com.ohos.contacts.MainAbility',
    COMMON_ENTITIES: 'entity.system.home',
    PAGE_FLAG_SINGLE_CHOOSE: 'page_flag_single_choose',
    PAGE_FLAG_MULTI_CHOOSE: 'page_flag_multi_choose'
  }
}

export const missedCallRadioData: RadioDataType[] = [
  { title: $r('app.string.card_missed_proprietor'), value: 'all' },
  { title: $r('app.string.card_missed_contacts_only'), value: 'contacts' },
  { title: $r('app.string.card_missed_favorite_contacts_only'), value: 'favorite' }
]

export class CallSharingClass {
  public static readonly ON_DISTRIBUTED_MODEM_STATE = '1_sink';
  public static readonly DISTRIBUTED_MODEM_STATE = 'distributed_modem_state';
  public static readonly ON_CALL_PHONE_SHARING = 1;
  public static readonly DISTRIBUTED_CALL_PHONE_SHARING = 'distributed_call_phone_sharing_sink';
  public static readonly ON_CALL_SMS_SHARING = 1;
  public static readonly DISTRIBUTED_CALL_SMS_SHARING = 'distributed_call_sms_sharing_sink';
  public static readonly ON_DISTRIBUTED_CALL_SOURCE_PHONE = 1;
  public static readonly DISTRIBUTED_CALL_SOURCE_PHONE = 'distributed_call_source_phone';
}