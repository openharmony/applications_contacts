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

/**
 * Log Util
 *
 * standard :
 * 1. define TAG, recommend class name。
 * 2. switch IS_DEBUG_ON as true, when debugging.
 * 3. msg should be short and valuable.
 * 4. choose appropriate function.
 * 5. the function execute many times can not print.
 * 6. uniqueness.
 */
export default class HiLog {
  private static readonly IS_DEBUG_ON: boolean = false;
  private static readonly CONTACTS_DOMAIN: string = "00900";
  private static readonly SLASH: string = "/";
  private static readonly COLON: string = ": ";

  constructor() {
  }

  private static prefix(tag: string) {
    return this.CONTACTS_DOMAIN + this.SLASH + tag + this.COLON;
  }

  static d(tag: string, msg: string, ...args: any[]) {
    if (this.IS_DEBUG_ON) {
      console.info(this.prefix(tag) + msg, args);
    } else {
      console.debug(this.prefix(tag) + msg, args);
    }
  }

  static i(tag: string, msg: string, ...args: any[]) {
    console.info(this.prefix(tag) + msg, args);
  }

  static w(tag: string, msg: string, ...args: any[]) {
    console.warn(this.prefix(tag) + msg, args);
  }

  static e(tag: string, msg: string, ...args: any[]) {
    console.error(this.prefix(tag) + msg, args);
  }
}

