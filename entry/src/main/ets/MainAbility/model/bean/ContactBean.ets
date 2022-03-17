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

import {EmailBean} from './EmailBean';
import {RemDayBean} from './RemDayBean';
import {AssociatedPersonBean} from './AssociatedPersonBean';
import {AIMBean} from './AIMBean';
import {HouseBean} from './HouseBean';
import {GroupBean} from './GroupBean';
import {PhoneNumBean} from './PhoneNumBean';

export class ContactBean {
  /**
   * 联系人id主键
   */
  id: string;

  /**
   * 联系人姓名
   */
  name: string;

  /**
   * 公司
   */
  company: string;

  /**
   * 职位
   */
  position: string;


  // 电话列表// 邮箱列表// 昵称// 网站列表// 生日和纪念日// 铃声// 关联人// 备注// 通话记录

  /**
   * 手机号列表
   */
  phoneNumList: PhoneNumBean[];

  /**
   * 邮箱列表
   */
  emailBeanList: EmailBean[];

  /**
   * 昵称
   */
  nickName: string

  /**
   * 网站列表
   */
  webSitList: string[]

  /**
   * 纪念日列表
   */
  remembranceDayList: RemDayBean[]

  /**
   * 铃声
   */
  ringtone: string

  /**
   * 关联人列表
   */
  associatedPersonList: AssociatedPersonBean[]

  /**
   * 备注
   */
  remarks: string

  /**
   * AIM列表
   */
  aimList: AIMBean[]

  /**
   * 住址列表
   */
  houseList: HouseBean[]

  /**
   * 群组列表
   */
  groupList: GroupBean[]

  // 二维码   背景色   铃声id   拼音名

  constructor(
    id: string,
    name: string,
    company: string,
    position: string,
    phoneNumList: PhoneNumBean[],
    emailBeanList: EmailBean[],
    nickName: string,
    webSitList: string[],
    remembranceDayList: RemDayBean[],
    ringtone: string,
    associatedPersonList: AssociatedPersonBean[],
    remarks: string,
    aimList: AIMBean[],
    houseList: HouseBean[],
    groupList: GroupBean[]) {
    this.id = id;
    this.name = name;
    this.company = company;
    this.position = position;
    this.phoneNumList = phoneNumList;
    this.emailBeanList = emailBeanList;
    this.nickName = nickName;
    this.webSitList = webSitList;
    this.remembranceDayList = remembranceDayList;
    this.ringtone = ringtone;
    this.associatedPersonList = associatedPersonList;
    this.remarks = remarks;
    this.aimList = aimList;
    this.houseList = houseList;
    this.groupList = groupList;
  }
}
