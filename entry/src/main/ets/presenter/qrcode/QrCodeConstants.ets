/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

export namespace QrcodeConstants {
  /**
   * mecard报文开头
   */
  export const MECARD_HEADER: string = 'MECARD:';

  /**
   * vcard报文开头
   */
  export const VCARD_HEADER: string = 'BEGIN:VCARD';

  /**
   * vcard报文结尾
   */
  export const VCARD_END: string = 'END:VCARD';

  /**
   * mecard报文开分割长度
   */
  export const MECARD_HEADER_LENGTH: number = 7;

  /**
   * mecard报文单项key value分割
   */
  export const MECARD_KEY_COLON: string = ':';

  /**
   * mecard报文多项分隔符
   */
  export const MECARD_KEY_SEMICOLON: string = ';';

  /**
   * mecard电话号码key
   */
  export const MECARD_KEY_TEL: string = 'TEL';

  /**
   * mecard地址key
   */
  export const MECARD_KEY_ADR: string = 'ADR';

  /**
   * mecard姓名key
   */
  export const MECARD_KEY_NAME: string = 'N';

  /**
   * mecard邮箱key
   */
  export const MECARD_KEY_EMAIL: string = 'EMAIL';

  /**
   * mecard网址key
   */
  export const MECARD_KEY_URL: string = 'URL';

  /**
   * mecard公司key
   */
  export const MECARD_KEY_ORG: string = 'ORG';

  /**
   * mecard职位key
   */
  export const MECARD_KEY_TIL: string = 'TIL';

  /**
   * mecard备注key
   */
  export const MECARD_KEY_NOTE: string = 'NOTE';


  /**
   * vcard电话号码key
   */
  export const VCARD_KEY_TEL: string = 'TEL';

  /**
   * vcard电地址key
   */
  export const VCARD_KEY_ADR: string = 'ADR';

  /**
   * vcard姓名key
   */
  export const VCARD_KEY_NAME: string = 'N';

  /**
   * vcard邮箱key
   */
  export const VCARD_KEY_EMAIL: string = 'EMAIL';

  /**
   * vcard网址key
   */
  export const VCARD_KEY_URL: string = 'URL';

  /**
   * vcard公司key
   */
  export const VCARD_KEY_ORG: string = 'ORG';

  /**
   * vcard职位key
   */
  export const VCARD_KEY_TITLE: string = 'TITLE';

  /**
   * vcard备注key
   */
  export const VCARD_KEY_NOTE: string = 'NOTE';

  /**
   * vcard即时信息key
   */
  export const VCARD_KEY_IM: string = 'X';

  /**
   * vcard QQ key
   */
  export const VCARD_KEY_IM_QQ: string = 'X-QQ';

  /**
   * vcard AIM key
   */
  export const VCARD_KEY_IM_AIM: string = 'X-AIM';

  /**
   * vcard MSN key
   */
  export const VCARD_KEY_IM_MSN: string = 'X-MSN';

  /**
   * vcard雅虎key
   */
  export const VCARD_KEY_IM_YAHOO: string = 'X-YAHOO';

  /**
   * vcard skype key
   */
  export const VCARD_KEY_IM_SKYPE: string = 'X-SKYPE-USERNAME';

  /**
   * vcard 环聊 key
   */
  export const VCARD_KEY_IM_HANGOUTS: string = 'X-GOOGLE-TALK';

  /**
   * vcard ICQ key
   */
  export const VCARD_KEY_IM_ICQ: string = 'X-ICQ';

  /**
   * vcard JABBER key
   */
  export const VCARD_KEY_IM_JABBER: string = 'X-JABBER';

  /**
   * vcard生日key
   */
  export const VCARD_KEY_BDAY: string = 'BDAY';

  /**
   * 不设置年份的默认值
   */
  export const DEFAULT_YEAR: string = '1904';

  /**
   * 扫码服务左滑退出后的错误码
   */
  export const SCAN_CANCELED_CODE: string = '1000500002';

  /**
   * match数组长度
   */
  export const MATCH_INFO_LENGTH: number = 4;

  /**
   * split数组长度
   */
  export const SPLIT_INFO_LENGTH: number = 2;

  /**
   * hangouts类型值
   */
  export const IM_ADDR_HANGOUTS: number = 9;

  /**
   * 根据;匹配，排除转义的;
   */
  export const SPLIT_REGEX: RegExp = /(?<!\\);/;

  /**
   * 将所有\\; \;替换为;
   */
  export const REPLACE_SEMICOLON_REGEX: RegExp = /\\;/g;

  /**
   * 将所有\\: \:替换为:
   */
  export const REPLACE_COLON_REGEX: RegExp = /\\:/g;


  /**
   * 通讯录字段名  键  数据定义
   * 名称  N  如果是英文名称，可以以逗号,分隔first name和last name。逗号前是last name。分隔的功能根据扫码软件不同效果不同，有的会忽略逗号并不分隔，有的会将逗号作为名称的一部分。
   * 读音  SOUND  因为此码的定义公司是日本的，这个字段主要作用是注明片假名读音使用，也可以和N一样使用逗号分隔。大部分中文扫码软件不支持此字段。
   * 职位  TIL  未知字数上限
   * 电话  TEL  支持1至24个数字
   * 可视电话  TEL-AV  同TEL
   * 邮箱  EMAIL  未知字数上限
   * 备注  NOTE  未知字数上限
   * 生日  BDAY  8位数字，4位年2位月2位日
   * 地址  ADR  未知字数上限，按照英语国家习惯会将国家、州县、市区、街道、房号等分开，可以使用逗号,进行分隔。分隔功能部分中文扫码软件支持。
   * 网址  URL  未知字数上限，但是不能填写协议(http://)和万维网标识(www)。
   * 昵称  NICKNAME  未知字数上限，部分中文扫码软件支持此字段。
   */
  export const meCardKeyMap: Record<string, string> = {
    'N': 'name',
    'TEL': 'phoneNumbers',
    'NOTE': 'note',
    'ORG': 'organization',
    'ADR': 'postalAddresses',
    'EMAIL': 'emails',
    'URL': 'websites',
    'TIL': 'organization'
  };

  export enum QRCodeType {
    /**
     * 扫码错误
     */
    UNSUPPORT = -1,
    /**
     * 文本信息
     */
    TEXT = 0,

    /**
     * MECARD名片
     */
    MECARD = 1,

    /**
     * VCARD名片
     */
    VCARD = 2,
  }

  export const vCardKeyMap: Record<string, string> = {
    'N': 'name',
    'TEL': 'phoneNumbers',
    'NOTE': 'note',
    'ORG': 'organization',
    'ADR': 'postalAddresses',
    'EMAIL': 'emails',
    'URL': 'websites',
    'TITLE': 'organization',
    'X': 'imAddresses',
    'BDAY': 'events',
  };

  export const telTypeToLabel: Record<string, number> = {
    'WORK': contact.PhoneNumber.NUM_WORK,
    'HOME': contact.PhoneNumber.NUM_HOME,
    'CELL': contact.PhoneNumber.NUM_MOBILE,
    'PREF': contact.PhoneNumber.NUM_MAIN,
    'WORK-FAX': contact.PhoneNumber.NUM_FAX_WORK,
    'HOME-FAX': contact.PhoneNumber.NUM_FAX_HOME,
    'PAGER': contact.PhoneNumber.NUM_MAIN,
    'VOICE': contact.PhoneNumber.NUM_OTHER
  };

  export const emailTypeToLabel: Record<string, number> = {
    'WORK': contact.Email.EMAIL_WORK,
    'HOME': contact.Email.EMAIL_HOME,
  };
  export const adrTypeToLabel: Record<string, number> = {
    'WORK': contact.PostalAddress.ADDR_WORK,
    'HOME': contact.PostalAddress.ADDR_HOME,
  };
}