/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

export default class HiCarContactListShowInfo {
  // 是否展示字母索引
  public isShowIndex: boolean;
  // 列表展示名称
  public contactTitle: string;
  // 联系人唯一标识
  public contactId: string;
  //联系人名称前缀，用于列表首字母展示 #、A、B、C等
  public namePrefix: string;
  //是否被收藏
  public isFavorited: string;
  //是否显示hicar联系人下划线
  public isShowContactDivifer: boolean;

  constructor(isShowIndex: boolean, contactTitle: string, contactId: string, namePrefix: string, isFavorited: string,
              isShowContactDivifer: boolean) {
    this.isShowIndex = isShowIndex;
    this.contactTitle = contactTitle;
    this.contactId = contactId;
    this.namePrefix = namePrefix;
    this.isFavorited = isFavorited;
    this.isShowContactDivifer = isShowContactDivifer;
  }
}