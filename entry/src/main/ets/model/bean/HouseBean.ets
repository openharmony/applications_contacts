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
import { House } from '../../../../../../feature/contact/src/main/ets/contract/House';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';

export class HouseBean {
  // Contact ID primary key.
  public id?: string;
  // 2023.10.28: before，对应extend7，是一个自增index（对应当前类型数据列表的下标+1），当前不使用；当前extend7作为selectTextCustom对应值
  public houseId: string = '';
  public houseType: string;
  //Residential address
  public houseName: string;
  public labelName?: Resource | string;
  // 对应select下拉框选择信息的文本，如果选择的非自定义信息，不需要设置，可以从代码配置中根据numType拿到对应文本；如果时自定义信息，需要设置此值，存入数据库中
  public selectTextCustom?: string;
  public pickerData: contact.PostalAddress = {
    postalAddress: ''
  }

  constructor(id: string, selectTextCustom: string, houseType: string, houseName: string) {
    this.id = id;
    this.selectTextCustom = selectTextCustom;
    this.houseType = houseType;
    this.houseName = houseName;
  }

  setPickerData(postalAddress: string, labelName?: string, labelId?: number) {
    this.pickerData.postalAddress = postalAddress;
    this.pickerData.labelName = labelName;
    this.pickerData.labelId = labelId;
  }

  static getBeanByPickerData(house: contact.PostalAddress) {
    let labelId: number = House.apiTypeToSystemType(house.labelId ?? contact.PostalAddress.ADDR_HOME);
    let labelName: string = '';
    if (labelId === PhoneAccountType.TYPE_ID_CUSTOM) {
      if (StringUtil.isEmpty(house.labelName)) {
        labelId = House.apiTypeToSystemType(contact.PostalAddress.ADDR_HOME);
        labelName = '';
      } else {
        labelName = house.labelName as string;
      }
    }
    return new HouseBean('', labelName, labelId.toString(), house.postalAddress);
  }
}
