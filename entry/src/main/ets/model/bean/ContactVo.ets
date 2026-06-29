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
import { PhoneNumberInterface } from '../../model/type';
import { getHeadChar } from '../../util/UserPhoto';

export class MemberInfo {
  public member: ContactVo = new ContactVo('', '', '', '', '', '', {
    id: 0,
    type: 0,
    params: [],
    bundleName: '',
    moduleName: '',
  }, true, '', '', '');
  public checked?: boolean;
}


/**
 * Contact List Data Structure Entity
 */
export class ContactVo {
  // 联系人id
  public contactId: string;
  // sortFirstLetter
  public namePrefix: string;
  // 对应emptyNameData（displayName），company，position顺序设置
  public emptyNameData: string;
  public company: string;
  public position: string;
  public portraitColor: Resource;
  public show: boolean;
  public portraitPath: string;
  // photoFirstName
  public nameSuffix: string = '';
  public phoneNum: string;
  // 显示名称，从displayName，
  public showName: string = '';
  public phoneNumbers: PhoneNumberInterface[] = [];
  public title: string = '';
  public subTitle: string = '';
  // 联系人名称Vo
  public name: ContactVoName;
  public displayName: string;
  public phoneNumber: string;
  // 头像符号
  public headChar: string = '';
  public nameRawContactId: string = '';
  // rawContact的id
  public rawContactId: string = '';
  public extra3: string = '';
  public favorite: string = '';
  public sort: string = '';
  public sortKey: string = '';
  public quickSearchKey: string = '';

  constructor(contactId: string,
              namePrefix: string,
              sort: string,
              emptyNameData: string,
              company: string,
              position: string,
              portraitColor: Resource,
              show: boolean,
              portraitPath: string,
              phoneNum: string,
              favorite: string,
              name: ContactVoName = new ContactVoName(),
              displayName: string = '',
              phoneNumber: string = '',
              nameRawContactId: string = '',
              rawContactId: string = '',
              quickSearchKey: string = ''
  ) {
    this.contactId = contactId;
    this.namePrefix = namePrefix;
    this.sort = sort;
    this.emptyNameData = emptyNameData;
    this.company = company;
    this.position = position;
    this.portraitColor = portraitColor;
    this.show = show;
    this.portraitPath = portraitPath;
    this.phoneNum = phoneNum;
    this.name = name;
    this.displayName = displayName;
    this.phoneNumber = phoneNumber;
    this.nameRawContactId = nameRawContactId;
    this.rawContactId = rawContactId;
    this.favorite = favorite;
    this.quickSearchKey = quickSearchKey;
  }

  public setShowName() {
    this.showName = !StringUtil.isEmpty(this.emptyNameData) ?
    this.emptyNameData : (!StringUtil.isEmpty(this.company) ?
      this.company : (!StringUtil.isEmpty(this.position) ? this.position : ''));
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

  public setHeadChar() {
    this.headChar = getHeadChar(this.showName);
  }
}

export const CHINESE_CHAR_CODE = 255;

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
   * 二级索引对应的排序首字母信息
   * enPrefix
   * start end 对应此二级索引的数据start和end，如A字母下有数据'a啊'，'a给'，'啊啊'，'啊给'，四个值， 下标就是这几个值的起始，终止下标[0, 3]
   * char为索引下第一个联系人的photo_first_name
   */
  public enPrefix: CharIndex = new CharIndex();
  /**
   * 二级索引对应的汉字；
   * 每个汉字对应start，end：如果汉字索引只有一个对应名字，下标为该名称位置，start==end；
   *  如果二级索引有多个名字，如 '啊啊'，'啊给'，'啊个'，三个啊，二级索引显示一个，下标为该三个值的起始位置
   */
  public zhPrefix: Array<CharIndex> = [];
}

export class ContactVoName {
  public fullName: string = '';
  public namePrefix: string = '';
  public nameSuffix: string = '';
  public searchTextStart: string = '';
  public searchTextMiddle: string = '';
  public searchTextEnd: string = '';
}

export class ContactVoNamePrefix {
  public namePrefix: string = '';
}