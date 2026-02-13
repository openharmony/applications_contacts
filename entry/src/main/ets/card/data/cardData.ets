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
class InfoStringClass {
  public CONTACT_BUNDLE_NAME: string = '';
  public CONTACT_ABILITY_NAME: string = '';
  public COMMON_ENTITIES: string = '';
}

export const infoString: InfoStringClass = {
  CONTACT_BUNDLE_NAME: 'com.ohos.contacts',
  CONTACT_ABILITY_NAME: 'com.ohos.contacts.MainAbility',
  COMMON_ENTITIES: 'entity.system.home'
}

class ContactPageClass {
  public PAGE_FLAG_CONTACT_DETAILS: string = '';
  public PAGE_FLAG_DIALER: string = '';
  public MULTI_NUM_DIALOG: string = '';
  public MULTI_SIM_DIALOG: string = '';
  public PAGE_FLAG_EDIT_BEFORE_CALLING: string = '';
}

export const contactPage: ContactPageClass = {
  PAGE_FLAG_CONTACT_DETAILS: 'page_flag_contact_details',
  PAGE_FLAG_DIALER: 'page_flag_dialer',
  MULTI_NUM_DIALOG: 'multi_num_dialog',
  MULTI_SIM_DIALOG: 'multi_sim_dialog',
  PAGE_FLAG_EDIT_BEFORE_CALLING: 'page_flag_edit_before_calling'
}