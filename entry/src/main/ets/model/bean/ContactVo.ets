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
import { PhoneNumberInterface } from '../type';

/**

 Contact List Data Structure Entity
 */
export class ContactVo {
  id: string = '';
  suffix: string = '';
  displayName: string = '';
  phoneNumber: string = '';
  quickSearchKey: string = '';
  checked: boolean = false;
  contactId: string;
  namePrefix: string;
  emptyNameData: string;
  company: string;
  position: string;
  portraitColor: string;
  show: boolean;
  portraitPath: string;
  nameSuffix: string = '';
  phoneNum: string;
  showName: string = '';
  phoneNumbers: PhoneNumberInterface[] = [];
  name: NameVo = new NameVo('', '', '');
  title: string = '';
  subTitle: string = '';
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
    this.showName = !StringUtil.isEmpty(this.emptyNameData) ? this.emptyNameData :
      (!StringUtil.isEmpty(this.company) ? this.company : (!StringUtil.isEmpty(this.position) ? this.position : ''))
  }

  public setName(emptyNameData: string, namePrefix: string, nameSuffix: string) {
    this.name = new NameVo(emptyNameData, namePrefix, nameSuffix);
  }

  public setphoneNumbers(phoneNumbers: PhoneNumberInterface[]) {
    this.phoneNumbers = phoneNumbers;
  }

  public setTitle(title: string) {
    this.title = title;
  }

  public setSubTitle(subTitle: string) {
    this.subTitle = subTitle;
  }
}

export class PhoneNumberObj {
  public phoneNumber: string = '';
  public startPhone: string = '';
  public middlePhone: string = '';
  public endPhone: string = '';
  public checked: boolean = false;
  public labelName: Resource | undefined = undefined;
  public numType: string = '';
}

export class CharIndex {
  public char: string;
  public start: number;
  public end: number;

  constructor(char: string = '', start: number = -1, end: number = -1) {
    this.char = char;
    this.start = start;
    this.end = end;
  }
}

export class AlphabetIndexObj {
  /**

   二级索引对应的排序首字母信息
   enPrefix
   start end 对应此二级索引的数据start和end，如A字母下有数据'a啊'，'a给'，'啊啊'，'啊给'，四个值， 下标就是这几个值的起始，终止下标[0, 3]
   char为索引下第一个联系人的photo_first_name
   /
   public enPrefix: CharIndex = new CharIndex();
   /*
   二级索引对应的汉字；
   每个汉字对应start，end：如果汉字索引只有一个对应名字，下标为该名称位置，start==end；
   如果二级索引有多个名字，如 '啊啊'，'啊给'，'啊个'，三个啊，二级索引显示一个，下标为该三个值的起始位置
   */
  public zhPrefix: Array = [];
}
export class NameVo {
  fullName: string;
  namePrefix: string;
  nameSuffix: string;
  searchTextStart: string = '';
  searchTextMiddle: string = '';
  searchTextEnd: string = '';

  constructor(emptyNameData: string, namePrefix: string, nameSuffix: string) {
    this.fullName = emptyNameData;
    this.namePrefix = namePrefix;
    this.nameSuffix = nameSuffix;
  }
}