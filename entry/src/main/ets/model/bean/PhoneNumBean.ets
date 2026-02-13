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
import { contact } from '@kit.ContactsKit';
import { Phone } from '../../../../../../feature/contact/src/main/ets/contract/Phone';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';

/**
 * Phone Number Object
 */
export class PhoneNumBean {
  public static PHONE_NUM_HAS_MEETIME_ABILITY_FLAG = '1';
  // 2023.10.28: before，对应extend7，是一个自增index（对应当前类型数据列表的下标+1），当前不使用；当前extend7作为selectTextCustom对应值
  public id?: string;
  public num: string;
  public numType: string;
  public homeArea: string;
  public carriers: string;
  public primary: boolean;
  public formatNum?: string;
  // 联系人id，contactId和rawContactId不同，不是rawContactId
  public contactId?: string;
  public displayNum?: string
  public numLocation?: Resource | string;
  /**
   * 对应数据库contactdata表ID字段
   */
  public dataId: number;
  public labelName?: Resource | string;
  public phoneAddress?: Resource | string;
  // 对应select下拉框选择信息的文本，如果选择的非自定义信息，不需要设置，可以从代码配置中根据numType拿到对应文本；如果时自定义信息，需要设置此值，存入数据库中
  public selectTextCustom?: string;
  // 1 表示有畅连能力，空表示没有；如果一个联系人有多个手机号，当前仅支持一个有畅连能力的手机号；使用此标记标识使用的具有畅连能力的手机号
  // 对应数据库typeId = 5（标识手机号类型数据）；的extend1字段
  public meeTimeAbilityFlag?: string;
  public highlighting: boolean = false;
  public pickerData: contact.PhoneNumber = {
    phoneNumber: ''
  }

  constructor(selectTextCustom: string, num: string, numType: string, homeArea: string,
              carriers: string, primary: boolean = false, dataId: number = -1, numLocation?: Resource | string) {
    this.selectTextCustom = selectTextCustom;
    this.num = num;
    this.numType = numType;
    this.homeArea = homeArea;
    this.carriers = carriers;
    this.primary = primary;
    this.dataId = dataId;
    this.numLocation = numLocation;
  }

  setPickerData(phoneNumber: string, labelName?: string, labelId?: number) {
    this.pickerData.phoneNumber = phoneNumber;
    this.pickerData.labelName = labelName;
    this.pickerData.labelId = labelId;
  }

  static getBeanByPickerData(phone: contact.PhoneNumber) {
    let labelId: number = Phone.apiTypeToSystemType(phone.labelId ?? contact.PhoneNumber.NUM_MOBILE);
    let labelName: string = '';
    if (labelId === PhoneAccountType.TYPE_ID_CUSTOM) {
      if (StringUtil.isEmpty(phone.labelName)) {
        labelId = Phone.apiTypeToSystemType(contact.PhoneNumber.NUM_MOBILE);
        labelName = '';
      } else {
        labelName = phone.labelName as string;
      }
    }
    return new PhoneNumBean(labelName, phone.phoneNumber, labelId.toString(), '', '');
  }
}