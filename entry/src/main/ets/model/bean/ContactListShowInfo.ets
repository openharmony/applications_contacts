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


export default class ContactListShowInfo {
  // 是否展示字母索引
  public isShowIndex: boolean;
  // 是否展示底部分割线
  public isShowDivifer: boolean;
  // 列表展示名称
  public contactTitle: string;
  // 列表副标题，公司、职位等
  public contactSubTitle: string;
  // 联系人唯一标识
  public contactId: string;
  // 查询联系人头像的联系人rawContactId
  public nameRawContactId: string;
  // 头像符号，没有头像时展示，符号展示头像信息
  public headChar: string;
  //联系人头像路径，有头像时，根据路径展示头像
  public portraitPath: string;
  //联系人名称前缀，用于列表首字母展示 #、A、B、C等
  public namePrefix: string;

  constructor(isShowIndex: boolean, isShowDivifer: boolean, contactId: string, nameRawContactId: string,
              headChar: string, portraitPath: string, namePrefix: string, contactTitle: string,
              contactSubTitle: string) {
    this.isShowIndex = isShowIndex;
    this.isShowDivifer = isShowDivifer;
    this.contactId = contactId;
    this.nameRawContactId = nameRawContactId;
    this.headChar = headChar;
    this.portraitPath = portraitPath;
    this.namePrefix = namePrefix;
    this.contactTitle = contactTitle;
    this.contactSubTitle = contactSubTitle;
  }

  public getItemKey(): string {
    return this.contactTitle + this.contactSubTitle + this.contactId + this.nameRawContactId + this.headChar +
    this.portraitPath + this.namePrefix + this.isShowIndex + this.isShowDivifer;
  }
}