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
import { Email } from '../../../../../../feature/contact/src/main/ets/contract/Email';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';

/**
 * Mailbox Object
 */
export class EmailBean {
  // 2023.10.28: before，对应extend7，是一个自增index（对应当前类型数据列表的下标+1），当前不使用；当前extend7作为selectTextCustom对应值
  public id?: string;
  public address: string;
  public emailType: string;
  public labelName?: Resource | string;
  // 对应select下拉框选择信息的文本，如果选择的非自定义信息，不需要设置，可以从代码配置中根据numType拿到对应文本；如果时自定义信息，需要设置此值，存入数据库中
  public selectTextCustom?: string;
  public pickerData: contact.Email = {
    email: ''
  }

  constructor(selectTextCustom: string, address: string, emailType: string) {
    this.selectTextCustom = selectTextCustom;
    this.address = address;
    this.emailType = emailType;
  }

  setPickerData(email: string, labelName?: string, labelId?: number) {
    this.pickerData.email = email;
    this.pickerData.labelName = labelName;
    this.pickerData.labelId = labelId;
  }
  
  static getBeanByPickerData(email: contact.Email) {
    let labelId: number = Email.apiTypeToSystemType(email.labelId ?? contact.Email.EMAIL_HOME);
    let labelName: string = '';
    if (labelId === PhoneAccountType.TYPE_ID_CUSTOM) {
      if (StringUtil.isEmpty(email.labelName)) {
        labelId = Email.apiTypeToSystemType(contact.Email.EMAIL_HOME);
        labelName = '';
      } else {
        labelName = email.labelName as string;
      }
    }
    return new EmailBean(labelName, email.email, labelId.toString());
  }
}