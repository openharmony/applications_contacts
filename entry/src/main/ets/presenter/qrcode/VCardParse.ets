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
import { HiLog } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import { contact } from '@kit.ContactsKit';
import { QrcodeConstants } from './QrCodeConstants';

interface VCard {
  key: string;
  value: object | undefined;
}

const TAG = 'VCardParse';
export default class VCardParse {
  private static instance: VCardParse;
  public static getInstance(): VCardParse {
    if (!VCardParse.instance) {
      VCardParse.instance = new VCardParse();
    }
    return VCardParse.instance;
  }

  /**
   * 解码vCard中的转义字符
   */
  decodeValue(value: string): string {
    if (!value) {
      return '';
    }
    // n,\,;等在vCard中要转义，这里将其还原
    return value
      .replace(/\\n/gi, '\n') // \n转为换行符
      .replace(/\\,/g, ',') // \,转为,
      .replace(/\\;/g, ';') // \;转为;
      .replace(/\\\\/g, '\\'); // \\转为\
  }

  /**
   * 解析vCard 3.0格式的文本为对象数组
   */
  parseVCard(text: string): contact.Contact {
    HiLog.w(TAG, 'start parseVcard, text length:' + text.length);
    const vCardDict: contact.Contact = {};
    vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_TEL]] = [];
    vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_ADR]] = [];
    vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_EMAIL]] = [];
    vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_URL]] = [];
    vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]] = [];
    vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_BDAY]] = [];
    // 处理软换行（行首空格或tab，RFC6350定义的folding），拼接为一行
    const foldedText = text.replace(/\r?\n[ \t]/g, '');
    let lines = foldedText.split(/\r?\n/); // 按换行拆分为多行
    let orgContent = '';
    let organization: contact.Organization = {
      name: '',
      title: ''
    };
    HiLog.w(TAG, 'parseVcard lines length:' + lines.length);
    for (let rawLine of lines) {
      if (!rawLine || rawLine.trim().length === 0) {
        continue; // 跳过空行
      }
      const line = rawLine.trim();
      if (line.toUpperCase() !== QrcodeConstants.VCARD_HEADER && line.toUpperCase() !== QrcodeConstants.VCARD_END) {
        // 处理中间的字段行
        let field = new VCardField(line);
        field.parseFieLdLineContent();
        switch (field.name) {
          case QrcodeConstants.VCARD_KEY_NAME:
            let name: contact.Name = {
              fullName: field.value.trim()
            };
            vCardDict[QrcodeConstants.vCardKeyMap[field.name]] = name;
            break;
          case QrcodeConstants.VCARD_KEY_TEL:
            const telType = field.params?.TYPE ?
              QrcodeConstants.telTypeToLabel[field.params['TYPE']] || contact.PhoneNumber.NUM_OTHER :
            contact.PhoneNumber.NUM_OTHER;
            let phoneNumber: contact.PhoneNumber = {
              phoneNumber: field.value,
              labelId: telType
            };
            vCardDict[QrcodeConstants.vCardKeyMap[field.name]].push(phoneNumber);
            break;
          case QrcodeConstants.VCARD_KEY_EMAIL:
            const emailType = field.params?.TYPE ?
              QrcodeConstants.emailTypeToLabel[field.params['TYPE']] || contact.Email.EMAIL_OTHER :
            contact.Email.EMAIL_OTHER;
            let email: contact.Email = {
              email: field.value,
              labelId: emailType
            };
            vCardDict[QrcodeConstants.vCardKeyMap[field.name]].push(email);
            break;
          case QrcodeConstants.VCARD_KEY_ADR:
            const adrType = field.params?.TYPE ?
              QrcodeConstants.adrTypeToLabel[field.params['TYPE']] || contact.PostalAddress.ADDR_OTHER :
            contact.PostalAddress.ADDR_OTHER;
            let postalAddress: contact.PostalAddress = {
              postalAddress: field.value,
              labelId: adrType
            };
            vCardDict[QrcodeConstants.vCardKeyMap[field.name]].push(postalAddress);
            break;
          case QrcodeConstants.VCARD_KEY_ORG:
            organization = {
              name: field.value
            };
            vCardDict[QrcodeConstants.vCardKeyMap[field.name]] = organization;
            orgContent = field.value;
            break;
          case QrcodeConstants.VCARD_KEY_TITLE:
            organization = {
              name: orgContent,
              title: field.value
            };
            vCardDict[QrcodeConstants.vCardKeyMap[field.name]] = organization;
            break;
          case QrcodeConstants.VCARD_KEY_URL:
            let websites: contact.Website = {
              website: field.value
            };
            vCardDict[QrcodeConstants.vCardKeyMap[field.name]].push(websites);
            break;
          case QrcodeConstants.VCARD_KEY_NOTE:
            let note: contact.Note = {
              noteContent: field.value
            };
            vCardDict[QrcodeConstants.vCardKeyMap[field.name]] = note;
            break;
          case QrcodeConstants.VCARD_KEY_IM_QQ:
            let imQQ: contact.ImAddress = {
              imAddress: field.value,
              labelId: contact.ImAddress.IM_QQ
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]].push(imQQ);
            break;
          case QrcodeConstants.VCARD_KEY_IM_AIM:
            let imAIM: contact.ImAddress = {
              imAddress: field.value,
              labelId: contact.ImAddress.IM_AIM
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]].push(imAIM);
            break;
          case QrcodeConstants.VCARD_KEY_IM_MSN:
            let imMSN: contact.ImAddress = {
              imAddress: field.value,
              labelId: contact.ImAddress.IM_MSN
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]].push(imMSN);
            break;
          case QrcodeConstants.VCARD_KEY_IM_YAHOO:
            let imYAHOO: contact.ImAddress = {
              imAddress: field.value,
              labelId: contact.ImAddress.IM_YAHOO
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]].push(imYAHOO);
            break;
          case QrcodeConstants.VCARD_KEY_IM_ICQ:
            let imICQ: contact.ImAddress = {
              imAddress: field.value,
              labelId: contact.ImAddress.IM_ICQ
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]].push(imICQ);
            break;
          case QrcodeConstants.VCARD_KEY_IM_SKYPE:
            let imSKYPE: contact.ImAddress = {
              imAddress: field.value,
              labelId: contact.ImAddress.IM_SKYPE
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]].push(imSKYPE);
            break;
          case QrcodeConstants.VCARD_KEY_IM_JABBER:
            let imJABBER: contact.ImAddress = {
              imAddress: field.value,
              labelId: contact.ImAddress.IM_JABBER
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]].push(imJABBER);
            break;
          case QrcodeConstants.VCARD_KEY_IM_HANGOUTS:
            let imHangouts: contact.ImAddress = {
              imAddress: field.value,
              labelId: QrcodeConstants.IM_ADDR_HANGOUTS
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_IM]].push(imHangouts);
            break;
          case QrcodeConstants.VCARD_KEY_BDAY:
            let bvalue = field.value;
            let bDay: contact.Event = {
              eventDate: bvalue.startsWith('-') ? QrcodeConstants.DEFAULT_YEAR + bvalue.slice(1) : bvalue,
              labelId: contact.Event.EVENT_BIRTHDAY
            }
            vCardDict[QrcodeConstants.vCardKeyMap[QrcodeConstants.VCARD_KEY_BDAY]].push(bDay);
            break;
          default:
            HiLog.w(TAG, 'unsupport field name:' + field.name);
            break;
        }
      }
    }
    return vCardDict;
  }
}

export class VCardField {
  public name: string; // 字段名
  public params: Record<string, string>; // 字段参数
  public value: string; // 字段值
  private fieldLineContent: string;

  constructor(fieldLine: string) {
    this.name = '';
    this.params = {};
    this.value = '';
    this.fieldLineContent = fieldLine;
  }

  /**
   * 解析vcard每一行的内容
   */
  public parseFieLdLineContent() {
    const parsed = this.parseFieldLine(this.fieldLineContent);
    this.name = parsed.name;
    this.params = parsed.params;
    this.value = parsed.value;
    HiLog.w(TAG, `parseFieLdLineContent name:${parsed.name}, value length: ${parsed.value?.length}`);
  }

  private parseFieldLine(fieldLine: string): FieldParseResult {
    // 行格式: KEY;PARAM1=VAL1:VAL
    // 正则解析字段名、参数、值
    const match = fieldLine.match(/^([^:;]+)((?:;[^:]+)*):([\s\S]*)$/);
    if (!match || match.length < QrcodeConstants.MATCH_INFO_LENGTH) {
      return {
        name: '',
        params: {},
        value: ''
      };
    }

    const name = match[1].trim().toUpperCase();
    const paramStr = match[2];
    const rawValue = match[3].trim();

    const params: Record<string, string> = {};

    if (paramStr) {
      const paramItems = paramStr.split(';').filter(Boolean);
      const tempParams: Record<string, string[]> = {};

      for (const item of paramItems) {
        let key: string;
        let value: string;
        if (item.includes('=')) {
          const splitArr = item.split('=');
          if (!splitArr || splitArr.length < QrcodeConstants.SPLIT_INFO_LENGTH) {
            key = '';
            value = '';
          } else {
            key = splitArr[0];
            value = splitArr[1];
          }
        } else {
          key = 'TYPE';
          value = item.trim();
        }

        if (key === 'TYPE') {
          if (!tempParams.TYPE) {
            tempParams.TYPE = [];
          }
          tempParams.TYPE.push(value.toUpperCase());
        } else if (!tempParams[key]) {
          tempParams[key] = [value];
        }
      }

      // 处理参数
      Object.keys(tempParams).forEach(k => {
        if (k === 'TYPE') {
          params[k] = tempParams[k].join('-');
        } else {
          params[k] = tempParams[k][0] || '';
        }
      });
    }
    return {
      name,
      params,
      value: this.joinTypeValue(rawValue)
    };
  }

  joinTypeValue(value: string): string {
    if (!value.includes(';')) {
      return value;
    } else {
      // 分割、过滤空、拼接
      let cleaned = value.split(QrcodeConstants.SPLIT_REGEX).filter(s => s.length > 0).join('');
      return cleaned.replace(QrcodeConstants.REPLACE_SEMICOLON_REGEX, ';');

    }
  }
}

// 定义一个接口来描述 parseFieldLine 的返回类型
interface FieldParseResult {
  name: string;
  params: Record<string, string>;
  value: string;
}
