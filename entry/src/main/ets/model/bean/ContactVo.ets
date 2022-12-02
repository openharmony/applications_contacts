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

import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';

/**
 * Contact List Data Structure Entity
 */
export class ContactVo {
  contactId: string;
  namePrefix: string;
  emptyNameData: string;
  company: string;
  position: string;
  portraitColor: string;
  show: boolean;
  portraitPath: string;
  nameSuffix: string;
  phoneNum: string;
  showName: string;
  phoneNumbers: object[];
  name: NameVo;
  title: string;
  subTitle: string;
  constructor(contactId: string,
              namePrefix: string,
              emptyNameData: string,
              company: string,
              position: string,
              portraitColor: string,
              show: boolean,
              portraitPath: string,
              phoneNum: string
  ) {
    this.contactId = contactId;
    this.namePrefix = namePrefix;
    this.emptyNameData = emptyNameData;
    this.company = company;
    this.position = position;
    this.portraitColor = portraitColor;
    this.show = show;
    this.portraitPath = portraitPath;
    this.phoneNum = phoneNum;
  }

  public setShowName() {
    this.showName = !StringUtil.isEmpty(this.emptyNameData) ? this.emptyNameData : (!StringUtil.isEmpty(this.company) ? this.company : (!StringUtil.isEmpty(this.position) ? this.position : ""))
  }

  public setName(emptyNameData: string, namePrefix: string, nameSuffix: string) {
    this.name = new NameVo(emptyNameData, namePrefix, nameSuffix);
  }

  public setphoneNumbers(phoneNumbers: object[]) {
    this.phoneNumbers = phoneNumbers;
  }

  public setTitle(title: string) {
    this.title = title;
  }

  public setSubTitle(subTitle: string) {
    this.subTitle = subTitle;
  }
}

export class NameVo {
  fullName: string;
  namePrefix: string;
  nameSuffix: string;
  searchTextStart: string;
  searchTextMiddle: string;
  searchTextEnd: string;
  constructor(emptyNameData: string, namePrefix: string, nameSuffix: string) {
    this.fullName = emptyNameData;
    this.namePrefix = namePrefix;
    this.nameSuffix = nameSuffix;
  }
}