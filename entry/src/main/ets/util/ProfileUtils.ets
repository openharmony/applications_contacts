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
import PhoneAccountType from '../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { ObjectUtil } from '../../../../../feature/call/oh_modules/common';
import {
    ContactsGlobalThisHelper
} from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { HiLog } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/StringUtil';
import { Aim } from '../../../../../feature/contact/src/main/ets/contract/Aim';
import { Birthday } from '../../../../../feature/contact/src/main/ets/contract/Birthday';
import { Email } from '../../../../../feature/contact/src/main/ets/contract/Email';
import { House } from '../../../../../feature/contact/src/main/ets/contract/House';
import { Phone } from '../../../../../feature/contact/src/main/ets/contract/Phone';
import { Relation } from '../../../../../feature/contact/src/main/ets/contract/Relation';
import { RichContactInfo } from '../model/bean/RichContactInfo';
import { ResourceUtil } from './ResourceUtil';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { ContactReturnObj } from '../model/type';
// import { systemShare } from '@kit.ShareKit';
import { common } from '@kit.AbilityKit';
import utd from '@ohos.data.uniformTypeDescriptor';
import StringFormatUtil from './StringFormatUtil';

export class ProfileUtils {
  private static TAG = 'ProfileUtils';
  private static SHARE_SPLIT: string = ':';
  public static resultDT: string = '';

  public static buildShareContent(contactId: string, callBack?:(shareContent: string) => void) {
    if (StringUtil.isEmpty(contactId)) {
      HiLog.e(ProfileUtils.TAG, 'shareContact error ,contact is invalid...');
      if (callBack) {
        callBack('');
      }
      return;
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactById', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        contactId: contactId
      }, (result: ContactReturnObj) => {
        if (ObjectUtil.isEmpty(result)) {
          HiLog.e(ProfileUtils.TAG, 'getContactById failed , result is null');
          if (callBack) {
            callBack('');
          }
          return;
        }
        let resultData = result.data as RichContactInfo;
        if (ObjectUtil.isEmpty(resultData)) {
          if (callBack) {
            callBack('');
          }
          return;
        }
        let content: string = ProfileUtils.buildShareTextCard(resultData);
        if (callBack) {
          callBack(content);
        }
      })
  }

  // 分享内容的方法
  public static shareContent(shareContent: string) {
    if (StringUtil.isEmpty(shareContent)) {
      HiLog.e(ProfileUtils.TAG, 'shareContent error, content is invalid...');
      return;
    }

    let content: string = shareContent;
    try {
      let target = ProfileUtils.findPositionBeforeFirstCRLF(content);
      // let data: systemShare.SharedData = new systemShare.SharedData({
      //   utd: utd.UniformDataType.PLAIN_TEXT,
      //   content: content,
      //   title: content.substring(0, target)
      // });
      // if (data != null) {
      //   let controller: systemShare.ShareController = new systemShare.ShareController(data);
      //   let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      //   controller.show(context, {
      //     previewMode: systemShare.SharePreviewMode.DETAIL,
      //     selectionMode: systemShare.SelectionMode.SINGLE
      //   });
      // }
    } catch (err) {
      HiLog.e(ProfileUtils.TAG, `shareContent` + err?.message + ', stack: ' + err?.stack);
    }
  }

  static findPositionBeforeFirstCRLF(input: string): number {
    const crlfIndex = input.indexOf('\r\n');
    return crlfIndex > 0 ? crlfIndex : -1;
  }

  public static buildShareTextCard(contactInfo: RichContactInfo): string {
    let result: string = '';
    if (ObjectUtil.isEmpty(contactInfo)) {
      HiLog.e(ProfileUtils.TAG, 'buildShareTextCard failed ,contactInfo is null ');
      return result;
    }
    ProfileUtils.getLabelNameByTypeId(contactInfo);
    result = ProfileUtils.buildShareName(result, contactInfo);
    result = ProfileUtils.buildShareCompany(result, contactInfo);
    result = ProfileUtils.buildSharePosition(result, contactInfo);
    result = ProfileUtils.buildSharePhoneticName(result, contactInfo);
    result = ProfileUtils.buildSharePhone(result, contactInfo);
    result = ProfileUtils.buildShareEmails(result, contactInfo);
    result = ProfileUtils.buildShareNickname(result, contactInfo);
    result = ProfileUtils.buildShareWebsites(result, contactInfo);
    result = ProfileUtils.buildShareHouses(result, contactInfo);
    result = ProfileUtils.buildShareEvents(result, contactInfo);
    result = ProfileUtils.buildShareRemarks(result, contactInfo);
    result = ProfileUtils.buildShareAim(result, contactInfo);
    result = ProfileUtils.buildShareRelationships(result, contactInfo);

    result = result.trim();
    return result;
  }

  private static buildShareCompany(result: string, contactInfo: RichContactInfo): string {
    //company
    if (!StringUtil.isEmpty(contactInfo.company)) {
      result += ProfileUtils.buildItem(result,
        ResourceUtil.resourceToString($r('app.string.phone_type_work'), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext()), contactInfo.company);
    }
    return result;
  }

  private static buildSharePosition(result: string, contactInfo: RichContactInfo): string {
    //position
    if (!StringUtil.isEmpty(contactInfo.position)) {
      result += ProfileUtils.buildItem(result,
        ResourceUtil.resourceToString($r('app.string.position'), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext()), contactInfo.position);
    }
    return result;
  }

  private static buildSharePhoneticName(result: string, contactInfo: RichContactInfo): string {
    //phoneticName
    if (!StringUtil.isEmpty(contactInfo.phoneticName)) {
      result += ProfileUtils.buildItem(result,
        ResourceUtil.resourceToString($r('app.string.name_pinyin'), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext()), contactInfo.phoneticName);
    }
    return result;
  }

  private static buildSharePhone(result: string, contactInfo: RichContactInfo): string {
    // phone
    if (contactInfo.phones && contactInfo.phones.length > 0) {
      contactInfo.phones.forEach((item) => {
        let labelName: string = ProfileUtils.getStringLabelName(item.labelName);
        if (StringUtil.isEmpty(labelName)) {
          HiLog.e(ProfileUtils.TAG, 'parse phone failed ,labelName is null')
          return;
        }
        //TODO num 需要进行format
        result += ProfileUtils.buildItem(result,
          labelName, item.num);
      })
    }
    return result;
  }

  private static buildShareEmails(result: string, contactInfo: RichContactInfo): string {
    // email
    if (contactInfo.emails && contactInfo.emails.length > 0) {
      contactInfo.emails.forEach((item) => {
        let labelName: string = ProfileUtils.getStringLabelName(item.labelName);
        if (StringUtil.isEmpty(labelName)) {
          HiLog.e(ProfileUtils.TAG, 'parse emails failed ,labelName is null')
          return;
        }
        result += ProfileUtils.buildItem(result,
          labelName, item.address);
      });
    }
    return result;
  }

  private static buildShareNickname(result: string, contactInfo: RichContactInfo): string {
    //nickname
    if (!StringUtil.isEmpty(contactInfo.nickname)) {
      result += ProfileUtils.buildItem(result,
        ResourceUtil.resourceToString($r('app.string.nickname'), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext()), contactInfo.nickname);
    }
    return result;
  }

  private static buildShareWebsites(result: string, contactInfo: RichContactInfo): string {
    // website
    if (contactInfo.websites && contactInfo.websites.length > 0) {
      contactInfo.websites.forEach((item) => {
        result += ProfileUtils.buildItem(result,
          ResourceUtil.resourceToString($r('app.string.website'), ContactsGlobalThisHelper.GetGlobalThis()
            .getDefaultUIContext()), item);
      })
    }
    return result;
  }

  private static buildShareHouses(result: string, contactInfo: RichContactInfo): string {
    // houses
    if (contactInfo.houses && contactInfo.houses.length > 0) {
      contactInfo.houses.forEach((item) => {
        let labelName: string = ProfileUtils.getStringLabelName(item.labelName);
        if (StringUtil.isEmpty(labelName)) {
          HiLog.e(ProfileUtils.TAG, 'parse houseName failed ,labelName is null')
          return;
        }
        result += ProfileUtils.buildItem(result,
          labelName, item.houseName);
      })
    }
    return result;
  }

  private static buildShareEvents(result: string, contactInfo: RichContactInfo): string {
    // event
    if (contactInfo.events && contactInfo.events.length > 0) {
      contactInfo.events.forEach((item) => {
        let labelName: string = ProfileUtils.getStringLabelName(item.labelName);
        if (StringUtil.isEmpty(labelName)) {
          HiLog.e(ProfileUtils.TAG, 'parse events failed ,labelName is null')
          return;
        }
        const eventType = Number.parseInt(StringUtil.transferEmptyStrIfUndefined(item.eventType));
        const isLunar: boolean = eventType == Birthday.TYPE_LUNARBIRTHDAY;
        const eventStr = StringFormatUtil.stringFormatDateResource(item.data, isLunar)
        result += ProfileUtils.buildItem(result,
          labelName, eventStr.toString());
      })
    }
    return result;
  }

  private static buildShareRemarks(result: string, contactInfo: RichContactInfo): string {
    // remarks
    if (!StringUtil.isEmpty(contactInfo.remarks)) {
      result += ProfileUtils.buildItem(result,
        ResourceUtil.resourceToString($r('app.string.remarks'), ContactsGlobalThisHelper.GetGlobalThis()
          .getDefaultUIContext()), contactInfo.remarks);
    }
    return result;
  }

  private static buildShareAim(result: string, contactInfo: RichContactInfo): string {
    //aim
    if (contactInfo.aims && contactInfo.aims.length > 0) {
      contactInfo.aims.forEach(item => {
        let labelName: string = ProfileUtils.getStringLabelName(item.labelName);
        if (StringUtil.isEmpty(labelName)) {
          HiLog.e(ProfileUtils.TAG, 'parse aims failed ,labelName is null')
          return;
        }
        result += ProfileUtils.buildItem(result,
          labelName, item.aimName);
      })
    }
    return result;
  }

  private static buildShareRelationships(result: string, contactInfo: RichContactInfo): string {
    // relationships
    if (contactInfo.relationships && contactInfo.relationships.length > 0) {
      contactInfo.relationships.forEach(item => {
        let labelName: string = ProfileUtils.getStringLabelName(item.labelName);
        if (StringUtil.isEmpty(labelName)) {
          HiLog.e(ProfileUtils.TAG, 'parse relationships failed ,labelName is null')
          return;
        }
        result += ProfileUtils.buildItem(result,
          labelName, item.name);
      })
    }
    return result;
  }

  private static buildShareName(result: string, contactInfo: RichContactInfo): string {
    //name
    if (contactInfo.nameUpdate !== undefined && contactInfo.nameUpdate as number == 0) {
      if (!StringUtil.isEmpty(contactInfo.display_name)) {
        result += ProfileUtils.buildItem(result,
          ResourceUtil.resourceToString($r('app.string.name'), ContactsGlobalThisHelper.GetGlobalThis()
            .getDefaultUIContext()), contactInfo.display_name);
      }
    }
    return result;
  }

  private static getStringLabelName(labelName: Resource | string | undefined): string {
    let str = '';
    if (labelName == undefined) {
      return str;
    }
    if (typeof labelName == 'object') {
      str = ResourceUtil.resourceToString(labelName, ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext());
    }
    if (typeof labelName == 'string') {
      str = labelName;
    }
    return str;
  }

  private static buildItem(result: string, title: string, data?: string): string {
    //TODO 后续补充镜像语言
    let item: string = title + ProfileUtils.SHARE_SPLIT + data + '\r\n';
    return item;
  }

  /**
   * 根据select框的typeId，获得对应的lableName；如果typeId为10000，即自定义select，从数据库表中拿到lableName文本
   * 将labelName信息设置到联系人对象对应的信息中
   */
  public static getLabelNameByTypeId(contacts: RichContactInfo) {
    ProfileUtils.handlePhoneLabelName(contacts);
    ProfileUtils.handleEmailsLabelName(contacts);
    ProfileUtils.handleAimsLabelName(contacts);
    ProfileUtils.handleHousesLabelName(contacts);
    ProfileUtils.handleEventsLabelName(contacts);
    ProfileUtils.handleRelationshipsLabelName(contacts);
  }

  private static handleEmailsLabelName(contacts: RichContactInfo) {
    if (contacts.emails.length > 0) {
      contacts.emails.forEach((element) => {
        if (!StringUtil.isEmpty(element.emailType) && element.emailType == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          element.labelName = element.selectTextCustom
        } else {
          element.labelName = Email.getTypeLabelResource(Number.parseInt(element.emailType, 10));
        }
      });
    }
  }

  private static handleAimsLabelName(contacts: RichContactInfo) {
    if (contacts.aims.length > 0) {
      contacts.aims.forEach((element) => {
        if (!StringUtil.isEmpty(element.aimType) && element.aimType == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          element.labelName = element.selectTextCustom
        } else {
          element.labelName = Aim.getTypeLabelResource(Number.parseInt(element.aimType, 10));
        }

      });
    }
  }

  private static handleHousesLabelName(contacts: RichContactInfo) {
    if (contacts.houses.length > 0) {
      contacts.houses.forEach((element) => {
        if (!StringUtil.isEmpty(element.houseType) && element.houseType == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          element.labelName = element.selectTextCustom
        } else {
          element.labelName = House.getTypeLabelResource(Number.parseInt(element.houseType, 10));
        }
      });
    }
  }

  private static handleEventsLabelName(contacts: RichContactInfo) {
    if (contacts.events.length > 0) {
      contacts.events.forEach((element) => {
        element.labelName = Birthday.getTypeLabelResource(Number.parseInt(element.eventType, 10));
      });
    }
  }

  private static handleRelationshipsLabelName(contacts: RichContactInfo) {
    if (contacts.relationships.length > 0) {
      contacts.relationships.forEach((element) => {
        if (!StringUtil.isEmpty(element.associatedType) &&
          element.associatedType == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          element.labelName = element.selectTextCustom
        } else {
          element.labelName = Relation.getTypeLabelResource(Number.parseInt(element.associatedType, 10));
        }
      });
    }
  }

  private static handlePhoneLabelName(contacts: RichContactInfo) {
    if (contacts.phones.length > 0) {
      contacts.phones.forEach((element) => {
        if (!StringUtil.isEmpty(element.numType) && element.numType == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          element.labelName = element.selectTextCustom
        } else {
          element.labelName = Phone.getTypeLabelResource(Number.parseInt(element.numType, 10));
        }

        element.phoneAddress = element.phoneAddress == 'N' || StringUtil.isEmpty(element.phoneAddress?.toString()) ?
        $r('app.string.unknown') : element.phoneAddress;
      });
    }
  }
}