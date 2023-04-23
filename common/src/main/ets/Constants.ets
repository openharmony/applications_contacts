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

export default {
  SPN_CHINA: {
    // TELECOM
    TELECOM: "中国电信",
    // MOBILE
    MOBILE: "CMCC",
    // UNICOM
    UNICOM: "China Unicom",
  },
  Event: {
    CALLS_CHANGE: 0,
    CONTACTS_CHANGE: 1,
    SLOT_CHANGE: 2,
    SPN_INFO_CHANGED: 3,
    VOLTE_CHANGE: 4,
    CALLS_MERGE: 5
  },

  CONFIG: {
    useDataWorker: false,
    needCache: false
  },

  initConfig(context: Context) {
    this.CONFIG.useDataWorker = context.resourceManager.getBoolean($r('app.boolean.use_data_worker'));
    this.CONFIG.needCache = context.resourceManager.getBoolean($r('app.boolean.cache_page_one'));
    return this.CONFIG
  }
}