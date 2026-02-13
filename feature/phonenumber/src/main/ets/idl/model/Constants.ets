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

export namespace Constants {
  /**
   * 跳转联系人服务 ability 页面路径
   */
  export enum ContactPageUrl {
    CONTACT_DETAIL_PAGE,
    DEVICE_DETAIL_PAGE,
    CREATE_CONTACT_PAGE,
    SELECT_CONTACT_PAGE,
  }

  export const PREFIX_OF_PHONE_NUMBER = '+86';
}

/**
 * 畅连下沉服务bundlename
 */
export const MEETIME_SERVICE_BUNDLE_NAME = 'com.ohos.meetimeservice';

/**
 * 账号service abilityname
 */
export const ACCOUNT_SERVICE_ABILITY_NAME = 'AccountManagerServiceExtension';

/**
 * 通话service abilityname
 */
export const CALL_SERVICE_ABILITY_NAME = 'CallServiceAbility';

/**
 * 联系人service abilityname
 */
export const CONTACT_SERVICE_ABILITY_NAME = 'ContactServiceExtAbility';

export const DSDS_MODE_V2 = 0;

export const DSDS_MODE_V3 = 1;

export const DSDS_MODE_TDM = 2;

export const DSDS_MODE_V5 = 3;

export const DIAL_CALL_COUNTS_EXCEED_LIMIT = 8300008;

export const DSDA_DIAL_INTERNAL_ERROR = DIAL_CALL_COUNTS_EXCEED_LIMIT;

/**
 * "code":8300010,"message":"Currently on a call, unable to initiate a new call"
 */
export const DIAL_INTERNAL_ERROR = 8300010;
