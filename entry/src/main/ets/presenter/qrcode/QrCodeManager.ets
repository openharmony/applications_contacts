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
import { common } from '@kit.AbilityKit';
// import { scanBarcode, scanCore } from '@kit.ScanKit';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { QrcodeConstants } from './QrCodeConstants';
import { contact } from '@kit.ContactsKit';
import VCardParse from './VCardParse';

const TAG = 'QrCodeManager';
export class QrCodeManager {
  private static instance: QrCodeManager;

  private constructor() {}

  /**
   * QRCodeManager
   *
   * @return QRCodeManager 单例
   */
  public static getInstance(): QrCodeManager {
    if (!QrCodeManager.instance) {
      QrCodeManager.instance = new QrCodeManager();
    }
    return QrCodeManager.instance;
  }

  /**
   * 确认二维码类型
   *
   * @param result {string} - 扫码结果
   * @returns 类型值
   */
  private identifyQrCode(result: string): number {
    try {
      HiLog.w(TAG, `identifyQRCode enter originalValue length is ${result?.length}`);
      if (result.startsWith(QrcodeConstants.MECARD_HEADER) && result !== QrcodeConstants.MECARD_HEADER) {
        return QrcodeConstants.QRCodeType.MECARD;
      }
      if (result.startsWith(QrcodeConstants.VCARD_HEADER) && result !== QrcodeConstants.VCARD_HEADER) {
        return QrcodeConstants.QRCodeType.VCARD;
      }
      return QrcodeConstants.QRCodeType.UNSUPPORT;
    } catch (err) {
      HiLog.e(TAG, `identifyQRCode err: ${err?.message}`);
    }
    return QrcodeConstants.QRCodeType.UNSUPPORT;
  }

  /**
   * 处理扫码内容
   *
   * @param scanResult {string} - 扫码原始文本
   * @returns 联系人信息
   */
  public handleQrCode(scanResult: string): contact.Contact | number {
    if (StringUtil.isEmpty(scanResult)) {
      HiLog.e(TAG, `handleQrCode error scanResult is empty`);
      return -1;
    }
    const type: number = this.identifyQrCode(scanResult);
    HiLog.w(TAG, `handleQRCode qrCodeType is ${type}`);
    switch (type) {
      case QrcodeConstants.QRCodeType.UNSUPPORT:
        break;
      case QrcodeConstants.QRCodeType.MECARD:
        let mecardDict = this.parseMeCard(scanResult);
        return mecardDict;
      case QrcodeConstants.QRCodeType.VCARD:
        let vcardDict = this.parseVCard(scanResult);
        return vcardDict;
      default:
        HiLog.e(TAG, `unSupport type is ${type}`);
        return -1;
    }
    return -1;
  }

  /**
   * 解析mecard二维码
   *
   * @param meCardText {string} - mecard文本
   * @returns 联系人信息
   */
  private parseMeCard(meCardText: string): contact.Contact {
    const meCardDict: contact.Contact = {};
    meCardDict[QrcodeConstants.meCardKeyMap[QrcodeConstants.MECARD_KEY_TEL]] = [];
    meCardDict[QrcodeConstants.meCardKeyMap[QrcodeConstants.MECARD_KEY_ADR]] = [];
    meCardDict[QrcodeConstants.meCardKeyMap[QrcodeConstants.MECARD_KEY_EMAIL]] = [];
    meCardDict[QrcodeConstants.meCardKeyMap[QrcodeConstants.MECARD_KEY_URL]] = [];
    meCardText = meCardText.substring(QrcodeConstants.MECARD_HEADER_LENGTH);
    if (StringUtil.isEmpty(meCardText)) {
      HiLog.e(TAG, `invalid mecardText`);
      return {};
    }
    const rawFields = meCardText.split(QrcodeConstants.SPLIT_REGEX);
    if (rawFields.length === 0) {
      HiLog.e(TAG, `invalid mecardText fields`);
      return {};
    }
    const fields = rawFields.map(field => field.replace(QrcodeConstants.REPLACE_SEMICOLON_REGEX, ';')
      .replace(QrcodeConstants.REPLACE_COLON_REGEX, ':'));
    let orgContent = '';
    fields.forEach(field => {
      const keyValuePair = field.split(QrcodeConstants.MECARD_KEY_COLON);
      const key = keyValuePair.shift()?.trim();
      const value = keyValuePair.join(QrcodeConstants.MECARD_KEY_COLON).trim();
      if (key && value && QrcodeConstants.meCardKeyMap[key]) {
        HiLog.w(TAG, `key is: ${key}, value length is: ${value.length}`);
        switch (key) {
          case QrcodeConstants.MECARD_KEY_TEL:
            let phoneNumber: contact.PhoneNumber = {
              phoneNumber: value.trim(),
              labelId: contact.PhoneNumber.NUM_MOBILE
            };
            meCardDict[QrcodeConstants.meCardKeyMap[QrcodeConstants.MECARD_KEY_TEL]].push(phoneNumber);
            break;
          case QrcodeConstants.MECARD_KEY_ADR:
            let postalAddress: contact.PostalAddress = {
              postalAddress: value.trim()
            };
            meCardDict[QrcodeConstants.meCardKeyMap[key]].push(postalAddress);
            break;
          case QrcodeConstants.MECARD_KEY_NAME:
            let name: contact.Name = {
              fullName: value.trim()
            };
            meCardDict[QrcodeConstants.meCardKeyMap[key]] = name;
            break;
          case QrcodeConstants.MECARD_KEY_EMAIL:
            let email: contact.Email = {
              email: value.trim()
            }
            meCardDict[QrcodeConstants.meCardKeyMap[key]].push(email);
            break;
          case QrcodeConstants.MECARD_KEY_URL:
            let website: contact.Website = {
              website: value.trim()
            };
            meCardDict[QrcodeConstants.meCardKeyMap[key]].push(website);
            break;
          case QrcodeConstants.MECARD_KEY_ORG:
            let organizationOrg: contact.Organization = {
              name: value.trim()
            };
            meCardDict[QrcodeConstants.meCardKeyMap[key]] = organizationOrg;
            orgContent = value.trim();
            break;
          case QrcodeConstants.MECARD_KEY_TIL:
            let organizationTil: contact.Organization = {
              name: orgContent,
              title: value.trim()
            };
            meCardDict[QrcodeConstants.meCardKeyMap[key]] = organizationTil;
            break;
          case QrcodeConstants.MECARD_KEY_NOTE:
            let note: contact.Note = {
              noteContent: value.trim()
            };
            meCardDict[QrcodeConstants.meCardKeyMap[key]] = note;
            break;
          default:
            meCardDict[QrcodeConstants.meCardKeyMap[key]] = value.trim();
        }
      } else {
        HiLog.w(TAG, `invalid key is: ${key}, value length is: ${value.length}`);
      }
    });
    return meCardDict;
  }

  /**
   * 解析vcard二维码
   *
   * @param vCardString {string} - vcard文本
   * @returns 联系人信息
   */
  private parseVCard(vCardString: string): contact.Contact {
    return VCardParse.getInstance().parseVCard(vCardString);
  }
}