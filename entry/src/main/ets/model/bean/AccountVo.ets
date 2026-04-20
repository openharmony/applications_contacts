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
 * Account List Data Structure Entity
 */
export class AccountVo {
  public accountId: string;
  public accountName: string;
  public accountType: string;
  public dataInfo: string;

  constructor(accountId: string, accountName: string, accountType: string, dataInfo: string) {
    this.accountId = accountId;
    this.accountName = accountName;
    this.accountType = accountType;
    this.dataInfo = dataInfo;
  }

  setDataInfo(dataInfo: string) {
    this.dataInfo = dataInfo;
  }
}