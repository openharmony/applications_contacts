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

import inputMethod from '@ohos.inputMethod';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { DynamicLoader } from '../../../../../../../common/src/main/ets/util/DynamicLoader';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { ObjectUtil } from '../../../../../../../common/src/main/ets/util/ObjectUtil';
import { AccountTypeService } from '../../../../../../../feature/account/src/main/ets/AccountTypeService';
import { AccountType } from '../../../../../../../feature/account/src/main/ets/type/AccountType';
import { House } from '../../../../../../../feature/contact/src/main/ets/contract/House';
import { Relation } from '../../../../../../../feature/contact/src/main/ets/contract/Relation';
import { Phone } from '../../../../../../../feature/contact/src/main/ets/contract/Phone';
import { Email } from '../../../../../../../feature/contact/src/main/ets/contract/Email';
import { Birthday } from '../../../../../../../feature/contact/src/main/ets/contract/Birthday';
import { Aim } from '../../../../../../../feature/contact/src/main/ets/contract/Aim';
import { EmailBean } from '../../../model/bean/EmailBean';
import { ContactInfo } from '../../../model/bean/ContactInfo';
import { PhoneNumBean } from '../../../model/bean/PhoneNumBean';
import { HouseBean } from '../../../model/bean/HouseBean';
import { AIMBean } from '../../../model/bean/AIMBean';
import { EventBean } from '../../../model/bean/EventBean';
import { AssociatedPersonBean } from '../../../model/bean/AssociatedPersonBean';
import PreferencesUtil from './../../../util/PreferencesUtil';
import Prompt from '@system.prompt';
import EditType from '../../../../../../../feature/account/src/main/ets/type/EditType';
import { RichContactInfo } from '../../../model/bean/RichContactInfo';
import {
  ContactBlobSource,
  ContactReturnObj, CustomizedParams, SingleSelectContact, SpeedDialItem } from '../../../model/type';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import LooseObject from '../../../model/type/LooseObject';
import { ContackPhoneSubInfoModel } from '../../../model/type/ContactParams';
import PhoneAccountType from '../../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import {
  delFileById, getHeadChar, getPixelMapFromFile,
  PixelMapManager,
  saveImageToFile,
  scalePixelMap} from '../../../util/UserPhoto';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import DotUtil from '../../../util/DotUtil';

import ArrangeContactsPresenter from '../settings/ArrangeContactsPresenter';
import { AccountVo } from '../../../model/bean/AccountVo';
import { OriginalDataHandleHelper } from './OriginalDataHandleHelper';
import ability from '@ohos.ability.ability';
import Base, { BusinessError } from '@ohos.base';
import { sharedPreferencesUtils } from '../../../../../../../feature/call/oh_modules/common';
import { call } from '@kit.TelephonyKit';
import SmsManagerUtils from '../../../util/SmsManagerUtils';
import { AppStorageConstant } from '../../../../../../../common/src/main/ets/AppStorageConstant';
import ShortcutEditCommon from '../../../card/common/ShortcutEditCommon';
import SpeedDialEditCommon from '../../../card/common/SpeedDialEditCommon';
import { displaySync } from '@kit.ArkGraphics2D';
import { contact } from '@kit.ContactsKit';
import { RingtoneItem, RingtoneSelectionUtil } from '../../../util/RingtoneSelectionUtil';
import { systemSoundManager } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { taskpool } from '@kit.ArkTS';
import GroupIdUtil from '../../../util/GroupIdUtil';
import fs from '@ohos.file.fs';

const TAG = 'AccountantsPresenter  ';
const SAVE_EVENT = 'SAVE_EVENT';
const PHONE_TYPE_EVENT = 'PHONE_TYPE_EVENT';
const EMAILS_TYPE_EVENT = 'EMAILS_TYPE_EVENT';
const AIMS_TYPE_EVENT = 'AIMS_TYPE_EVENT';
const HOUSES_TYPE_EVENT = 'HOUSES_TYPE_EVENT';
const RELATIONSHIPS_TYPE_EVENT = 'RELATIONSHIPS_TYPE_EVENT';
const EVENTS_TYPE_EVENT = 'EVENTS_TYPE_EVENT';
const shortcutEditCommon = new ShortcutEditCommon()
const speedDialEditCommon = new SpeedDialEditCommon()
const MIN_RESOLUTION = 409600;

/**
 * Select Info Model:Used to process custom information
 * 用于处理自定义信息
 */
export class SelectInfoModel {
  // 自定义select；只会有一个自定义元素，即只需要使用只需要使用editTypeCustomArr【0】，
  // 如果没有自定义，【0】为undefined，有自定义【0】有值
  // EditType的成员变量都不可变，改变的话只能重新赋值
  public editTypeCustomArr = new Array<EditType | undefined>();
  // 【1】当前选中的select   【0】上次选中的select
  // 如果选中了preEditType；然后选中自定义，此时下拉值变为自定义；点击取消，下拉值需要根据【0】回退回去
  public selectInfoArr: EditType[] = [];

  constructor() {
  }
}

/**
 * 联系人选择框部分的信息
 */
export class ContactSelectInfoModel {
  public phones: SelectInfoModel[] = [];
  public emails: SelectInfoModel[] = [];
  public aims: SelectInfoModel[] = [];
  public houses: SelectInfoModel[] = [];
  public relationships: SelectInfoModel[] = [];

  constructor() {
  }
}

/**
 * Add Contact Presenter
 */
export default class AccountantsPresenter {
  originalDataHandleHelper: OriginalDataHandleHelper = new OriginalDataHandleHelper();
  // 畅连头像地址
  public imageUrlMeetime: string = '';
  // path parameter
  public pathInfos?: NavPathStack;
  public static readonly timeSub: number = 1000;
  // 获取手机号
  public getPhones: Array<LooseObject> = [];
  // get emails
  public getEmails: Array<LooseObject> = [];
  // contactId
  public contactId: string = '';
  public nameRawContactId: string = '';
  // update mark
  public updateShow: boolean = false;
  public sourceHasParam: boolean = false;
  public isShowPosition: boolean = false;
  public showMore: boolean = false;
  // 如果内容修改了，为true；否则为false
  public addState: boolean = false;
  public phones: ContackPhoneSubInfoModel[] = [];
  public contactSelectInfoModel: ContactSelectInfoModel = new ContactSelectInfoModel();
  public editContact: number = -1;
  public phoneNumberShow: string = '';
  public callId: string = '';
  //关联人
  public relationships: AssociatedPersonBean[] = [];
  // 来自API接口保存至已有联系人的传入联系人信息
  public newContactData?: contact.Contact;
  // refresh mark
  public changed: boolean = false;
  public originalContactInfo =
    JSON.stringify(new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null));
  public nullContactInfo =
    JSON.stringify(new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null));
  // contact detail
  public contactInfoBefore: ContactInfo =
    new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
  public contactInfoAfter: ContactInfo =
    new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
  //
  public originalContactInfoBefore : ContactInfo =
    new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
  public magList: Array<number> = [];
  public refreshState?: (presenter: AccountantsPresenter) => void;
  public clickEnable: boolean = true;
  public isLoadedPhoto: boolean = true;
  public photoChanged: boolean = false;
  public ringToneChanged: boolean = false;
  // photoParam
  public photoPixelMap: PixelMap | null = null;
  public hasInitalPhoto: boolean = false;
  public accountId: number = -1;
  public initDetailsData: boolean = false;
  public photo?: Uint8Array | null = null;
  public itemsShowState: Record<string, boolean> = {
    'phone': false,
    'email': false,
    'phoneticName': false,
    'aims': false,
    'houses': false,
    'nickname': false,
    'websites': false,
    'events': false,
    'relationships': false
  }
  // saveContactDotParams
  public saveContactParams: CustomizedParams = {
    ISNAME: 0,
    ISUNIT: 0,
    ISPHONE: 0,
    ISEMAIL: 0,
    ISMESSAGE: 0,
    ISADDRESS: 0,
    ISREMARKS: 0,
    ISNICKNAME: 0,
    ISWEBSITE: 0,
    ISBIRTHDAYDATE: 0,
    ISASSOCIATED: 0,
    ENC: 0
  };
  public isMyCard: boolean = false;
  public destinationPageShow = (pixelMap: PixelMap, scaledPixelMap: PixelMap) => {}

  init(refreshState?: (presenter: AccountantsPresenter) => void) {
    this.contactId = '';
    this.nameRawContactId = '';
    this.updateShow = false;
    this.magList = [1];
    this.contactInfoBefore =
      new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
    this.contactInfoAfter =
      new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
    this.originalContactInfoBefore =
      new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
    this.refreshState = refreshState;
  }

  cancel() {
    let parameters: Record<string, string> = {
      'contactObjects': ''
    };
    const wantPara: Record<string, Record<string, string>> = {
      'parameters': parameters
    };
    const result: ability.AbilityResult = {
      'resultCode': 0,
      'want': wantPara
    };

    ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()?.terminateSelfWithResult(result)
      .then(() => {
        HiLog.i(TAG, 'terminateSelfWithResult Operation succeeded: ');
      })
      .catch((error: BusinessError) => {
        HiLog.e(TAG, 'Operation failed. Cause: %s', error?.message);
      });
  }

  /**
   * 新建联系人时，初始信息都为空，默认添加一条; 更新联系人时，如果存在为空的信息，默认添加一天
   * @param contactInfo
   */
  setDefaultData(contactInfo: ContactInfo): void {
    if (ArrayUtil.isEmpty(contactInfo.phones)) {
      contactInfo.phones = [new PhoneNumBean('', '', '1', '', '')];
      this.contactSelectInfoModel.phones = [new SelectInfoModel()];
    }

    if (ArrayUtil.isEmpty(contactInfo.emails)) {
      contactInfo.emails = [new EmailBean('', '', '1')];
      this.contactSelectInfoModel.emails = [new SelectInfoModel()];
    }

    if (ArrayUtil.isEmpty(contactInfo.aims)) {
      contactInfo.aims = [new AIMBean('', '', '1', '')];
      this.contactSelectInfoModel.aims = [new SelectInfoModel()];
    }

    if (ArrayUtil.isEmpty(contactInfo.houses)) {
      contactInfo.houses = [new HouseBean('', '', '1', '')];
      this.contactSelectInfoModel.houses = [new SelectInfoModel()];
    }

    if (ArrayUtil.isEmpty(contactInfo.relationships)) {
      contactInfo.relationships = [new AssociatedPersonBean('', '', '', '1')];
      this.contactSelectInfoModel.relationships = [new SelectInfoModel()];
    }

    if (ArrayUtil.isEmpty(contactInfo.websites)) {
      contactInfo.websites = [''];
    }

    if (ArrayUtil.isEmpty(contactInfo.events)) {
      contactInfo.events = [new EventBean('', '', '1', '')];
    }
  }

  // Refreshing
  refresh() {
    this.contactInfoBefore = this.contactInfoAfter;
    this.refreshAddState();
    this.getPhones = this.getArray(this.contactInfoBefore.phones);
    this.getEmails = this.getArray(this.contactInfoBefore.emails);
    this.changed = !this.changed;
    if (this.refreshState) {
      this.refreshState(this);
    }
  }

  refreshAddState() {
    // 判断原始内容和当前内容，是否有修改
    let addState = this.originalContactInfo != this.getExistenceInfoString(this.contactInfoAfter);
    if (this.isMyCard) {
      let hasNameOrPhone = !ArrayUtil.isEmpty(this.contactInfoAfter.phones) ||
        !StringUtil.isEmpty(this.contactInfoAfter.display_name);
      addState = addState && hasNameOrPhone;
    }

    if (this.addState != addState) {
      HiLog.w(TAG, 'refreshAddState addState change:' + addState);
      this.addState = addState;
      this.saveClickEnable();
    }
  }

  // 编辑，更新进入数据初始化
  updatesInit(callBack?: () => void) {
    HiLog.w(TAG, ' init start');
    this.contactInfoAfter.setContactID(this.contactId);
    this.contactInfoAfter.setRowContactId(this.nameRawContactId);
    if (this.updateShow === true) {
      HiLog.w(TAG, ' getPageData start ');
      this.getPageData(this.contactId, callBack ?? undefined);
    }
  }

  // showPhoneAndEmail
  showPhoneAndEmail() {
    this.itemsShowState['phone'] = true;
    this.itemsShowState['email'] = true;
  }

  // get ExistenceInfo
  getExistenceInfoString(afterInfo: ContactInfo) {
    let temp = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
    if (!afterInfo) {
      return JSON.stringify(temp);
    } else {
      if (afterInfo.photo) {
        temp.photo = afterInfo.photo;
      }
      if (!StringUtil.isEmpty(afterInfo.display_name)) {
        temp.display_name = afterInfo.display_name;
      }
      if (!StringUtil.isEmpty(afterInfo.phoneticName)) {
        temp.phoneticName = afterInfo.phoneticName;
      }
      if (!StringUtil.isEmpty(afterInfo.nickname)) {
        temp.nickname = afterInfo.nickname;
      }
      if (!StringUtil.isEmpty(afterInfo.remarks)) {
        temp.remarks = afterInfo.remarks;
      }
      if (!StringUtil.isEmpty(afterInfo.position)) {
        temp.position = afterInfo.position;
      }
      if (!StringUtil.isEmpty(afterInfo.company)) {
        temp.company = afterInfo.company;
      }
      if (afterInfo.photo) {
        temp.photo = afterInfo.photo;
      }
      if (!ArrayUtil.isEmpty(afterInfo.phones)) {
        for (let item of afterInfo.phones) {
          if (!StringUtil.isEmpty(item?.num)) {
            temp.phones.push(item);
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.emails)) {
        for (let item of afterInfo.emails) {
          if (!StringUtil.isEmpty(item?.address)) {
            temp.emails.push(item);
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.aims)) {
        for (let item of afterInfo.aims) {
          if (!StringUtil.isEmpty(item?.aimName)) {
            temp.aims.push(item);
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.houses)) {
        for (let item of afterInfo.houses) {
          if (!StringUtil.isEmpty(item?.houseName)) {
            temp.houses.push(item);
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.websites)) {
        for (let item of afterInfo.websites) {
          if (!StringUtil.isEmpty(item)) {
            temp.websites.push(item);
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.events)) {
        for (let item of afterInfo.events) {
          if (!StringUtil.isEmpty(item?.data)) {
            temp.events.push(item);
          }
        }
      }
      if (!ArrayUtil.isEmpty(afterInfo.relationships)) {
        for (let item of afterInfo.relationships) {
          if (!StringUtil.isEmpty(item?.name)) {
            temp.relationships.push(item);
          }
        }
      }
      return JSON.stringify(temp);
    }
  }

  /**
   * 编辑进入页面
   * @param id
   */
  getPageData(id: string, callBack?: () => void) {
    HiLog.w(TAG, `getPageData   id == ${id}`);
    if (StringUtil.isEmpty(id)) {
      HiLog.e(TAG, 'The parameter ID is empty.');
    }
    let data: Record<string, Context | string> = {
      'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
      'contactId': id
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactById', data, (result: ContactReturnObj) => {
        if (result.data == undefined) {
          HiLog.e(TAG, 'The result in the database is empty.');
          return;
        }
        this.accountId = result.data.accountId;
        this.dealRecordDetailsData(result.data, callBack ?? undefined);
        // 初始化时，设置电话号码原始信息
        this.originalDataHandleHelper.phoneOriginalData(result?.data.phones);
        this.originalDataHandleHelper.eventOriginalData(result?.data.events);
      });
  }

  public getAccountName(): string {
    let accountNameById: string = '';
    if (this.accountId) {
      ArrangeContactsPresenter.getInstance().accountList.forEach((item: AccountVo) => {
        if (this.accountId == Number(item.accountId)) {
          accountNameById = item.accountName;
        }
      })
    }
    return accountNameById;
  }

  onRingToneChange(updataShow: boolean, isAccountRingToneShow: boolean) {
    HiLog.i(TAG, 'onRingToneChange');
    HiLog.i(TAG, `onRingToneChange this.updataShow: ${updataShow}`);

    if (!isAccountRingToneShow) {
      if (this.originalContactInfoBefore.personalRingtone !=
      this.contactInfoAfter.personalRingtone && updataShow) {
        this.ringToneChanged = true;
        HiLog.i(TAG, 'this.ringToneChanged is true ');
      }
      this.saveClickEnable();
    }
  }

  getContactTemp(data: RichContactInfo): ContactInfo {
    let contactTemp = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0, '', '', '', null);
    contactTemp.setContactID(data.contactID);
    contactTemp.setRowContactId(data.rowContactID);
    let nameUpdate = 0;
    if (data.nameUpdate !== undefined) {
      nameUpdate = data.nameUpdate as number;
    }
    if (nameUpdate == 0) {
      contactTemp.setDisplayName(data.display_name);
    }
    contactTemp.setPhoneticName(data.phoneticName);
    contactTemp.setNickName(data.nickname);
    contactTemp.setPhones(data.phones);
    contactTemp.setEmails(data.emails);
    contactTemp.setRemarks(data.remarks);
    contactTemp.setPosition(data.position);
    if (!StringUtil.isEmpty(data.position)) {
      this.isShowPosition = true;
    }
    contactTemp.setCompany(data.company);
    contactTemp.setAims(data.aims);
    contactTemp.setHouses(data.houses);
    contactTemp.setWebsites(data.websites);
    contactTemp.setRelationships(data.relationships);
    contactTemp.setEvents(data.events);
    contactTemp.setGroups(data.groups);
    contactTemp.setPersonalRingtone(data.personalRingtone);
    contactTemp.setPersonalRingtonePath(data.personalRingtonePath);
    contactTemp.setPersonalNotificationRingtone(data.personalNotificationRingtone);
    contactTemp.rawContacts = data.rawContacts;
    return contactTemp;
  }

  /**
   * 根据编辑信息处理
   * @param data
   */
  dealRecordDetailsData(data: RichContactInfo, callBack?: () => void) {
    HiLog.w(TAG, `dealRecordDetailsData start, rowContactID: ${data.rowContactID},
     nameRawContactId: ${this.nameRawContactId}`);
    HiLog.w(TAG, `personalRingtone: ${StringUtil.maskSensitiveInfo(data.personalRingtone)},
     personalNotificationRingtone: ${StringUtil.maskSensitiveInfo(data.personalNotificationRingtone)}`);

    let contactTemp = this.getContactTemp(data);
    this.contactInfoBefore = contactTemp;
    this.originalContactInfo = this.getExistenceInfoString(contactTemp);
    this.originalContactInfoBefore = JSON.parse(JSON.stringify(this.contactInfoBefore));
    if (0 === this.editContact) {
      if (!ArrayUtil.isEmpty(this.phones)) {
        let saveTemp: LooseObject[] = this.getArray(this.phones);
        for (let i = 0; i < saveTemp?.length; i++) {
          let phoneNumBean: PhoneNumBean = new PhoneNumBean('', '', '', '', '');
          phoneNumBean.id = saveTemp[i]?.item?.id;
          phoneNumBean.num = saveTemp[i]?.item?.num;
          phoneNumBean.numType = saveTemp[i]?.item?.type;
          phoneNumBean.homeArea = '';
          phoneNumBean.carriers = '';
          this.contactInfoBefore.phones.push(phoneNumBean);
        }
      }
    } else if (1 === this.editContact || 2 === this.editContact) {
      if (StringUtil.isEmpty(this.phoneNumberShow)) {
        if (this.newContactData) {
          this.parseParamsFromSaveExistContact(this.newContactData);
        }
      } else {
        let phoneNumBean: PhoneNumBean = new PhoneNumBean('', '', '', '', '');
        phoneNumBean.id = this.callId;
        phoneNumBean.num = this.phoneNumberShow;
        phoneNumBean.numType = '';
        phoneNumBean.homeArea = '';
        phoneNumBean.carriers = '';
        phoneNumBean.highlighting = true;
        this.contactInfoBefore.phones.push(phoneNumBean);
      }
    }

    this.getPhones = this.getArray(this.contactInfoBefore.phones);
    this.getEmails = this.getArray(this.contactInfoBefore.emails);
    this.contactInfoAfter = contactTemp;
    // 初始化select框选择信息
    this.initContactSelectInfoModel(this.contactInfoAfter);
    getPixelMapFromFile(contactTemp.contactID, (pixelmap: PixelMap | null) => {
      this.photoPixelMap = pixelmap;
      this.hasInitalPhoto = pixelmap ? true : false;
    })
    this.updateItemsShowState(this.contactInfoAfter);
    this.refreshAddState();
    this.initDetailsData = true;
    callBack && callBack();
  }

  parseParamsFromSaveExistContact(contactData: contact.Contact) {
    if (ObjectUtil.isEmpty(contactData)) {
      HiLog.e(TAG, 'The contactData is null or empty')
      return;
    }
    // 外部拉起新建联系人 支持全字段数据添加
    HiLog.w(TAG, 'parseParams newContactData');

    let uri = contactData.portrait?.uri ?? '';
    if (!StringUtil.isEmpty(uri)) {
      HiLog.w(TAG, `deal uri start`);
      fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
        .then((file) => {
          let imageSourceApi = image.createImageSource(file.fd);
          imageSourceApi?.createPixelMap().then((pixelMap) => {
            HiLog.w(TAG, `createPixelMap success`);
            imageSourceApi?.release();

            let task = new taskpool.Task(scalePixelMap, pixelMap,
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context);
            taskpool.execute(task).then((imgScaledObjct: Object) => {
              HiLog.w(TAG, 'scalePixelMap success')
              let imgScaled = imgScaledObjct as image.PixelMap;
              this.destinationPageShow(pixelMap, imgScaled);
              pixelMap?.release();
            });
          }).catch((err: BusinessError) => {
            HiLog.e(TAG, `createPixelMap err: ${err.message}`);
            imageSourceApi?.release();
          })
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `file open error: ${error?.message}`);
        })
    }

    // 姓名
    let name: string | undefined = contactData.name?.fullName;
    if (name && !StringUtil.isEmpty(name)) {
      this.contactInfoBefore.setDisplayName(name);
    }

    // 单位
    let company: string | undefined = contactData.organization?.name;
    if (company && !StringUtil.isEmpty(company)) {
      this.contactInfoBefore.setCompany(company);
    }

    // 职位
    let position: string | undefined = contactData.organization?.title;
    if (position && !StringUtil.isEmpty(position)) {
      this.contactInfoBefore.setPosition(position);
    }

    // 备注
    let note: string | undefined = contactData.note?.noteContent;
    if (note && !StringUtil.isEmpty(note)) {
      this.contactInfoBefore.setRemarks(note);
    }

    // 电话号码
    let phones: PhoneNumBean[] = [];
    contactData.phoneNumbers?.forEach((phone) => {
      this.contactInfoBefore.phones.push(PhoneNumBean.getBeanByPickerData(phone))
    });

    // 邮件
    let emails: EmailBean[] = [];
    contactData.emails?.forEach((email) => {
      this.contactInfoBefore.emails.push(EmailBean.getBeanByPickerData(email));
    });

    // 网站
    let websites: string[] = [];
    contactData.websites?.forEach((website) => {
      this.contactInfoBefore.websites.push(website.website);
    });

    // 即时信息
    contactData.imAddresses?.forEach((aim) => {
      this.contactInfoBefore.aims.push(AIMBean.getBeanByPickerData(aim));
    });

    // 地址
    contactData.postalAddresses?.forEach((house) => {
      this.contactInfoBefore.houses.push(HouseBean.getBeanByPickerData(house));
    });

    // 生日
    let onlyOneBirthday = false;
    let onlyOneLunarBirthday = false;
    this.contactInfoBefore.events.forEach((event) => {
      if (event.eventType === Birthday.TYPE_GREBIRTHDAY.toString()) {
        onlyOneBirthday = true;
      }
      if (event.eventType === Birthday.TYPE_LUNARBIRTHDAY.toString()) {
        onlyOneLunarBirthday = true;
      }
    });
    contactData.events?.forEach((event) => {
      let eventBean = EventBean.getBeanByPickerData(event);
      // 生日和 农历生日 只支持保存一个
      if (eventBean.eventType === Birthday.TYPE_GREBIRTHDAY.toString()) {
        if (!onlyOneBirthday) {
          onlyOneBirthday = true;
        } else {
          eventBean.eventType = Birthday.TYPE_OTHER.toString();
        }
      } else if (eventBean.eventType === Birthday.TYPE_LUNARBIRTHDAY.toString()) {
        if (!onlyOneLunarBirthday) {
          onlyOneLunarBirthday = true;
        } else {
          eventBean.eventType = Birthday.TYPE_OTHER.toString();
        }
      }
      this.contactInfoBefore.events.push(eventBean);
    })

    // 关联人
    let relationships: AssociatedPersonBean[] = [];
    contactData.relations?.forEach((relation) => {
      this.contactInfoBefore.relationships.push(AssociatedPersonBean.getBeanByPickerData(relation));
    });
  }

  /**
   * 更新时，根据填写的值，初始化选择信息
   * @param contactInfo
   */
  initContactSelectInfoModel(contactInfo: ContactInfo) {
    if (!ArrayUtil.isEmpty(contactInfo.emails)) {
      this.contactSelectInfoModel.emails = [];
      for (let i = 0; i < contactInfo.emails.length; i++) {
        this.contactSelectInfoModel.emails.push(new SelectInfoModel());
      }
    }

    if (!ArrayUtil.isEmpty(contactInfo.phones)) {
      this.contactSelectInfoModel.phones = [];
      for (let i = 0; i < contactInfo.phones.length; i++) {
        this.contactSelectInfoModel.phones.push(new SelectInfoModel());
      }
    }

    if (!ArrayUtil.isEmpty(contactInfo.aims)) {
      this.contactSelectInfoModel.aims = [];
      for (let i = 0; i < contactInfo.aims.length; i++) {
        this.contactSelectInfoModel.aims.push(new SelectInfoModel());
      }
    }

    if (!ArrayUtil.isEmpty(contactInfo.houses)) {
      this.contactSelectInfoModel.houses = [];
      for (let i = 0; i < contactInfo.houses.length; i++) {
        this.contactSelectInfoModel.houses.push(new SelectInfoModel());
      }
    }

    if (!ArrayUtil.isEmpty(contactInfo.relationships)) {
      this.contactSelectInfoModel.relationships = [];
      for (let i = 0; i < contactInfo.relationships.length; i++) {
        this.contactSelectInfoModel.relationships.push(new SelectInfoModel());
      }
    }

  }

  /**
   * 根据type数据类型和index数据下标获取对应的数据
   * @param type
   * @param index
   * @returns
   */
  public getData(type: string, index: number): LooseObject {
    let data: LooseObject[] = [];
    switch (type) {
      case 'phone':
        if (!this.updateShow) {
          data = this.getArray(this.contactInfoBefore.phones);
        } else {
          data = this.getPhones;
        }
        break;
      case 'email':
        if (!this.updateShow) {
          data = this.getArray(this.contactInfoBefore.emails);
        } else {
          data = this.getEmails;
        }
        break;
      case 'AIM':
        data = this.getArray(this.contactInfoBefore.aims);
        break;
      case 'house':
        data = this.getArray(this.contactInfoBefore.houses);
        break;
      case 'relationships':
        data = this.getArray(this.contactInfoBefore.relationships);
        break;
      case 'events':
        data = this.getArray(this.contactInfoBefore.events);
        break;
      case 'website':
        data = this.getArrayCommon(this.contactInfoBefore.websites);
        break;
      default:
        break;
    }
    return data[index];
  }

  /**
   * 根据type数据类型和index数据下标获取对应的数据
   * @param type
   * @param index
   * @returns
   */
  public getSelectInfoModel(type: string, index: number): SelectInfoModel {
    let data = new SelectInfoModel();
    let arr: SelectInfoModel[] = [];
    switch (type) {
      case 'phone':
        arr = this.contactSelectInfoModel.phones
        break;
      case 'email':
        arr = this.contactSelectInfoModel.emails
        break;
      case 'AIM':
        arr = this.contactSelectInfoModel.aims
        break;
      case 'house':
        arr = this.contactSelectInfoModel.houses
        break;
      case 'relationships':
        arr = this.contactSelectInfoModel.relationships
        break;
      default:
        break;
    }

    if (index < arr.length) {
      return arr[index];
    }

    return data;
  }


  public getArray(array: Array<LooseObject>): Array<LooseObject> {
    let itemList: Array<LooseObject> = array;
    if (ArrayUtil.isEmpty(itemList)) {
      itemList = [];
    }
    itemList = itemList.map((item, index: number) => {
      let result: LooseObject = {
        i: index + 1,
        item: item
      }
      return result;
    })
    return itemList;
  }

  /**
   * 为array数组元素增加一个i下标信息，封装为一个LooseObject类型对象；返回LooseObject对象数组
   * @param array
   * @returns
   */
  public getArrayCommon(array: Array<string>): Array<LooseObject> {
    let data: LooseObject[] = [];
    if (ArrayUtil.isEmpty(array)) {
      data = [];
    } else {
      data = array.map((item, index: number) => {
        let result: LooseObject = {
          i: index + 1,
          item: item
        }
        return result;
      })
    }
    return data;
  }

  public getDataArray(type: string) {
    let data = new Array<LooseObject>();
    switch (type) {
      case 'phone':
        if (!this.updateShow) {
          data = this.getArray(this.contactInfoBefore.phones);
        } else {
          data = this.getPhones;
        }
        break;
      case 'email':
        if (!this.updateShow) {
          data = this.getArray(this.contactInfoBefore.emails);
        } else {
          data = this.getEmails;
        }
        break;
      case 'AIM':
        data = this.getArray(this.contactInfoBefore.aims);
        break;
      case 'house':
        data = this.getArray(this.contactInfoBefore.houses);
        break;
      case 'relationships':
        data = this.getArray(this.contactInfoBefore.relationships);
        break;
      case 'events':
        data = this.getArray(this.contactInfoBefore.events);
        break;
      case 'website':
        data = this.getArrayCommon(this.contactInfoBefore.websites);
      default:
        break;
    }
    HiLog.w(TAG, 'getDataArray type: ' + type + ', length: ' + data.length);
    return data;
  }

  /**
   * 添加更多触发，添加一行数据
   * @param type
   */
  public addMore(type: string) {
    switch (type) {
      case 'phone':
        this.contactInfoAfter.phones.push(new PhoneNumBean('', '', '1', '', ''));
        this.contactSelectInfoModel.phones.push(new SelectInfoModel());
        break;
      case 'email':
        this.contactInfoAfter.emails.push(new EmailBean('', '', '1'));
        this.contactSelectInfoModel.emails.push(new SelectInfoModel());
        break;
      case 'AIM':
        this.contactInfoAfter.aims.push(new AIMBean('', '', '1', ''));
        this.contactSelectInfoModel.aims.push(new SelectInfoModel());
        break;
      case 'house':
        this.contactInfoAfter.houses.push(new HouseBean('', '', '1', ''));
        this.contactSelectInfoModel.houses.push(new SelectInfoModel());
        break;
      case 'relationships':
        this.contactInfoAfter.relationships.push(new AssociatedPersonBean('', '', '', '1'));
        this.contactSelectInfoModel.relationships.push(new SelectInfoModel());
        break;
      case 'events':
        let events: EventBean[] = this.contactInfoBefore.events;
        let eventTypes: number[] = [Birthday.TYPE_GREBIRTHDAY, Birthday.TYPE_LUNARBIRTHDAY,
          Birthday.TYPE_ANNIVERSARIES, Birthday.TYPE_OTHER];
        events.forEach((v) => {
          if (v.eventType === Birthday.TYPE_GREBIRTHDAY.toString() ||
            v.eventType === Birthday.TYPE_LUNARBIRTHDAY.toString()) {
            if (eventTypes.indexOf(parseInt(v.eventType)) != -1) {
              eventTypes.splice(eventTypes.indexOf(parseInt(v.eventType)), 1);
            }
          }
        })
        let eventType = '1';
        if (eventTypes === undefined || eventTypes === null || eventTypes.length < 1) {
          eventType = '1';
        } else {
          eventType = eventTypes[0].toString();
        }
        this.contactInfoAfter.events.push(new EventBean('', '', eventType, ''));
        break;
      case 'website':
        this.contactInfoAfter.websites.push('');
      default:
        break;
    }
    this.refresh();
  }

  /**
   * 删除一行，如果有多行数据，就是删除该行；如果只有一条了，就是清空数据
   * @param typeName
   * @param startIndex
   */
  public deleteItem(typeName: string, startIndex: number) {
    HiLog.w(TAG, `deleteItem ${typeName} ${startIndex}`);
    switch (typeName) {
      case 'phone':
        this.contactInfoAfter.phones.splice(startIndex, 1);
        this.contactSelectInfoModel.phones.splice(startIndex, 1);
        break;
      case 'email':
        this.contactInfoAfter.emails.splice(startIndex, 1);
        this.contactSelectInfoModel.emails.splice(startIndex, 1);
        break;
      case 'AIM':
        this.contactInfoAfter.aims.splice(startIndex, 1);
        this.contactSelectInfoModel.aims.splice(startIndex, 1);
        break;
      case 'house':
        this.contactInfoAfter.houses.splice(startIndex, 1);
        this.contactSelectInfoModel.houses.splice(startIndex, 1);
        break;
      case 'relationships':
        this.contactInfoAfter.relationships.splice(startIndex, 1);
        this.contactSelectInfoModel.relationships.splice(startIndex, 1);
        break;
      case 'events':
        this.contactInfoAfter.events.splice(startIndex, 1);
        break;
      case 'website':
        this.contactInfoAfter.websites.splice(startIndex, 1);
      default:
        break;
    }
    this.refresh();
  }

  /**
   * 获取显示的文本，从data对象中对应字段获取文本值
   * @param typeName
   * @param data
   * @returns
   */
  public getTextDisplay(typeName: string, data: LooseObject) {
    let display: string = '';
    if (data !== undefined && data.item !== undefined) {
      switch (typeName) {
        case 'phone':
          display = data?.item?.num ?? display;
          break;
        case 'email':
          display = data?.item?.address ?? display;
          break;
        case 'AIM':
          display = data?.item?.aimName ?? display;
          break;
        case 'house':
          display = data?.item?.houseName ?? display;
          break;
        case 'relationships':
          display = data?.item?.name ?? display;
          break;
        case 'events':
          display = data?.item?.data ?? display;
          break;
        case 'website':
          display = data?.item ?? display;
          break;
        default:
          break;
      }
    }
    return display;
  }

  public listItemChange(typeName: string, data: LooseObject, arg: string) {
    try {
      switch (typeName) {
        case 'phone':
          let num = this.contactInfoAfter.phones[data.i - 1].num.replace(new RegExp('\\s*', 'g'), '');
          let highlighting = (!StringUtil.isEmpty(num) && num != arg)
            ? false : this.contactInfoAfter.phones[data.i - 1].highlighting;
          if (StringUtil.isEmpty(this.contactInfoAfter.phones[data.i - 1].numType)) {
            this.contactInfoAfter.phones[data.i - 1] = new PhoneNumBean('', '', '1', '', '');
          }
          this.contactInfoAfter.phones[data.i - 1].num = arg.toString();
          this.contactInfoAfter.phones[data.i - 1].highlighting = highlighting;
          break;
        case 'email':
          if (StringUtil.isEmpty(this.contactInfoAfter.emails[data.i - 1].emailType)) {
            this.contactInfoAfter.emails[data.i - 1] = new EmailBean('', '', '1');
          }
          this.contactInfoAfter.emails[data.i - 1].address = arg.toString();
          break;
        case 'AIM':
          if (StringUtil.isEmpty(this.contactInfoAfter.aims[data.i - 1].aimType)) {
            this.contactInfoAfter.aims[data.i - 1] = new AIMBean('', '', '1', '');
          }
          this.contactInfoAfter.aims[data.i - 1].aimName = arg.toString();
          break;
        case 'house':
          if (StringUtil.isEmpty(this.contactInfoAfter.houses[data.i - 1].houseType)) {
            this.contactInfoAfter.houses[data.i - 1] = new HouseBean('', '', '1', '');
          }
          this.contactInfoAfter.houses[data.i - 1].houseName = arg.toString();
          break;
        case 'relationships':
          if (StringUtil.isEmpty(this.contactInfoAfter.relationships[data.i - 1].associatedType)) {
            this.contactInfoAfter.relationships[data.i - 1] = new AssociatedPersonBean('', '', '', '1');
          }
          this.contactInfoAfter.relationships[data.i - 1].name = arg.toString();
          break;
        case 'website':
          this.contactInfoAfter.websites[data.i - 1] = arg.toString();
          break;
        default:
          break;
      }
      this.refreshAddState();
    } catch (error) {
      HiLog.e(TAG, 'something error happened: ' + error?.message);
    }
  }


  /**
   * 根据typeName类型信息，如phone，email，AIM ；判断select下拉框 的值的字段名；
   *      如phone类型，根据numType字段的值判断select下拉框选了哪一个；email类型，根据emailType字段的值来判断select下拉框选了哪一个
   * 根据data中对应type字段的值，知道下拉框选了哪一个
   * 先判断是否选择的自定义，再判断是否选择的系统定义好的
   * @param typeName 类型
   * @param editTypeCustom 自定义的下拉框值
   * @param data
   * @returns
   */
  public menuSelectSysAndCustom(typeName: string, data: LooseObject,
    editTypeCustom: EditType | undefined): Resource | string {

    let typeId = 1;
    switch (typeName) {
      case 'phone':
        if (!StringUtil.isEmpty(data?.item?.numType)) {
          typeId = Number(data?.item?.numType);
        }
        if (editTypeCustom != undefined && typeId == editTypeCustom.rawValue) {
          return editTypeCustom.labelRes
        }
        return Phone.getTypeLabelResource(typeId);
      case 'email':
        if (!StringUtil.isEmpty(data?.item?.emailType)) {
          typeId = Number(data?.item?.emailType);
        }
        if (editTypeCustom != undefined && typeId == editTypeCustom.rawValue) {
          return editTypeCustom.labelRes;
        }
        return Email.getTypeLabelResource(typeId);
      case 'AIM':
        if (!StringUtil.isEmpty(data?.item?.aimType)) {
          typeId = Number(data?.item?.aimType);
        }
        if (editTypeCustom != undefined && typeId == editTypeCustom.rawValue) {
          return editTypeCustom.labelRes;
        }
        return Aim.getTypeLabelResource(typeId);
      case 'house':
        if (!StringUtil.isEmpty(data?.item?.houseType)) {
          typeId = Number(data?.item?.houseType);
        }
        if (editTypeCustom != undefined && typeId == editTypeCustom.rawValue) {
          return editTypeCustom.labelRes;
        }
        return House.getTypeLabelResource(typeId);
      case 'relationships':
        if (!StringUtil.isEmpty(data?.item?.associatedType)) {
          typeId = Number(data?.item?.associatedType);
        }
        if (editTypeCustom != undefined && typeId == editTypeCustom.rawValue) {
          return editTypeCustom.labelRes;
        }
        return Relation.getTypeLabelResource(typeId);
      case 'events':
        if (!StringUtil.isEmpty(data?.item?.eventType)) {
          typeId = Number(data?.item?.eventType);
        }
        if (editTypeCustom != undefined && typeId == editTypeCustom.rawValue) {
          return editTypeCustom.labelRes;
        }
        return Birthday.getTypeLabelResource(typeId);
      default:
        return '';
    }
  }

  /**
   * 根据typeName类型信息，来知道记录该类型 判断select下拉框 的值的字段名
   *      如phone类型，根据numType字段的值判断select下拉框选了哪一个；email类型，根据emailType字段的值来判断select下拉框选了哪一个
   * 根据data中对应type字段的值，来查询下拉框选了哪一个
   * @param typeName 类型
   * @param data
   * @returns
   */
  public menuSelect(typeName: string, data: LooseObject): Resource | string {
    let typeId = 1;
    switch (typeName) {
      case 'phone':
        if (!StringUtil.isEmpty(data?.item?.numType)) {
          typeId = Number(data?.item?.numType);
        }
        return Phone.getTypeLabelResource(typeId);
      case 'email':
        if (!StringUtil.isEmpty(data?.item?.emailType)) {
          typeId = Number(data?.item?.emailType);
        }
        return Email.getTypeLabelResource(typeId);
      case 'AIM':
        if (!StringUtil.isEmpty(data?.item?.aimType)) {
          typeId = Number(data?.item?.aimType);
        }
        return Aim.getTypeLabelResource(typeId);
      case 'house':
        if (!StringUtil.isEmpty(data?.item?.houseType)) {
          typeId = Number(data?.item?.houseType);
        }
        return House.getTypeLabelResource(typeId);
      case 'relationships':
        if (!StringUtil.isEmpty(data?.item?.associatedType)) {
          typeId = Number(data?.item?.associatedType);
        }
        return Relation.getTypeLabelResource(typeId);
      case 'events':
        if (!StringUtil.isEmpty(data?.item?.eventType)) {
          typeId = Number(data?.item?.eventType);
        }
        return Birthday.getTypeLabelResource(typeId);
      default:
        return '';
    }
  }

  /**
   * 获取下拉框的EditType类型；如果是自定义的下拉框值，会设置标签名称信息；否则，只设置rawValue
   * @param typeName
   * @param data
   * @returns
   */
  public getSelectType(typeName: string, data: LooseObject) {

    let typeId = 1;
    let labelName = '';
    switch (typeName) {
      case 'phone':
        if (!StringUtil.isEmpty(data?.item?.numType)) {
          typeId = Number(data?.item?.numType);
        }
        if (typeId == PhoneAccountType.TYPE_ID_CUSTOM) {
          labelName = data.item.selectTextCustom as string;
        }
        break;
      case 'email':
        if (!StringUtil.isEmpty(data?.item?.emailType)) {
          typeId = Number(data?.item?.emailType);
        }
        if (typeId == PhoneAccountType.TYPE_ID_CUSTOM) {
          labelName = data.item.selectTextCustom as string;
        }
        break;
      case 'AIM':
        if (!StringUtil.isEmpty(data?.item?.aimType)) {
          typeId = Number(data?.item?.aimType);
        }
        if (typeId == PhoneAccountType.TYPE_ID_CUSTOM) {
          labelName = data.item.selectTextCustom as string;
        }
        break;
      case 'house':
        if (!StringUtil.isEmpty(data?.item?.houseType)) {
          typeId = Number(data?.item?.houseType);
        }
        if (typeId == PhoneAccountType.TYPE_ID_CUSTOM) {
          labelName = data.item.selectTextCustom as string;
        }
        break;
      case 'relationships':
        if (!StringUtil.isEmpty(data?.item?.associatedType)) {
          typeId = Number(data?.item?.associatedType);
        }
        if (typeId == PhoneAccountType.TYPE_ID_CUSTOM) {
          labelName = data.item.selectTextCustom as string;
        }
        break;
      case 'events':
        if (!StringUtil.isEmpty(data?.item?.eventType)) {
          typeId = Number(data?.item?.eventType);
        }
        break;
      default:
        break;
    }
    let editType = new EditType(typeId, labelName);
    return editType;
  }

  /**
   * 获取select框选择的typeId
   * @param typeName
   * @param data
   * @returns
   */
  public getSelectTypeId(typeName: string, data: LooseObject): number {

    let editType = this.getSelectType(typeName, data);
    return editType.rawValue;
  }

  /**
   * 根据typeName，获取本类型可以下拉的菜单的数组(代码中定义好的)
   * @param typeName
   * @returns
   */
  getMenuList(typeName: string) {
    let accountTypeService = new AccountTypeService();
    let menuKindTypeList: EditType[] = [];
    let phoneType = accountTypeService.getAccountType(AccountType.PHONE_ACCOUNT_TYPE);
    switch (typeName) {
      case 'phone':
        menuKindTypeList = phoneType.mineKinds?.get(Phone.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'email':
        menuKindTypeList = phoneType.mineKinds?.get(Email.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'AIM':
        menuKindTypeList = phoneType.mineKinds?.get(Aim.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'house':
        menuKindTypeList = phoneType.mineKinds?.get(House.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'relationships':
        menuKindTypeList = phoneType.mineKinds?.get(Relation.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'events':
        menuKindTypeList = phoneType.mineKinds?.get(Birthday.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      default:
        break;
    }
    return menuKindTypeList;
  }

  /**
   * 根据typeName，和index，获取本类型可以下拉的菜单的数组（系统定义和自定义的）
   * @param typeName ItemList 的类型，电话、邮件、即时信息等
   * @param index 该类型的第几行数据
   * @returns
   */
  getSysAndCustomMenuListByNameAndIndex(typeName: string, index: number): EditType[] {
    // 获取此typeName和index，对应的自定义选择信息
    let selectInfoModel = this.getSelectInfoModel(typeName, index);
    return this.getSysAndCustomMenuList(typeName, selectInfoModel.editTypeCustomArr[0]);
  }


  /**
   * 根据typeName，获取本类型可以下拉的菜单的数组（系统定义和自定义的）
   * @param typeName
   * @param editTypeCustom 自定义下拉值
   * @returns
   */
  getSysAndCustomMenuList(typeName: string, editTypeCustom: EditType | undefined) {
    let accountTypeService = new AccountTypeService();
    let menuKindTypeList: EditType[] = [];
    let phoneType = accountTypeService.getAccountType(AccountType.PHONE_ACCOUNT_TYPE);
    switch (typeName) {
      case 'phone':
        menuKindTypeList = phoneType.mineKinds?.get(Phone.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'email':
        menuKindTypeList = phoneType.mineKinds?.get(Email.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'AIM':
        menuKindTypeList = phoneType.mineKinds?.get(Aim.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'house':
        menuKindTypeList = phoneType.mineKinds?.get(House.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'relationships':
        menuKindTypeList = phoneType.mineKinds?.get(Relation.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      case 'events':
        menuKindTypeList = phoneType.mineKinds?.get(Birthday.CONTENT_ITEM_TYPE)?.typeList as EditType[];
        break;
      default:
        break;
    }

    if (editTypeCustom != undefined) {
      let menuKindTypeListTotal: EditType[] = [];
      menuKindTypeListTotal.push(editTypeCustom);
      for (let i = 0; i < menuKindTypeList.length; i++) {
        menuKindTypeListTotal.push(menuKindTypeList[i]);
      }

      return menuKindTypeListTotal;
    }


    return menuKindTypeList;
  }

  /**
   * 选择自定义，弹出自定义文本框后，不编辑，取消，菜单改变,改为自定义上次的内容; 或选择自定义，编辑自定义文本后确定，需要改为自定义的内容
   * @param typeName
   * @param index
   * @param selectTypeId
   * @param selectText
   */
  public menuChangeByCustomDialogClose(typeName: string, index: number,
    selectTypeId: string, selectText: string | Resource) {
    switch (typeName) {
      case 'phone':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.phones[index])) {
          this.contactInfoAfter.phones[index] = new PhoneNumBean('', '', '', '', '');
        }
        this.contactInfoAfter.phones[index].numType = selectTypeId;
        if (selectTypeId == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          this.contactInfoAfter.phones[index].selectTextCustom = selectText as string;
        } else {
          this.contactInfoAfter.phones[index].selectTextCustom = '';
        }
        break;

      case 'email':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.emails[index])) {
          this.contactInfoAfter.emails[index] = new EmailBean('', '', '');
        }
        this.contactInfoAfter.emails[index].emailType = selectTypeId;
        if (selectTypeId == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          this.contactInfoAfter.emails[index].selectTextCustom = selectText as string;
        } else {
          this.contactInfoAfter.emails[index].selectTextCustom = '';
        }
        break;

      case 'AIM':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.aims[index])) {
          this.contactInfoAfter.aims[index] = new AIMBean('', '', '', '');
        }
        this.contactInfoAfter.aims[index].aimType = selectTypeId;
        if (selectTypeId == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          this.contactInfoAfter.aims[index].selectTextCustom = selectText as string;
        } else {
          this.contactInfoAfter.aims[index].selectTextCustom = '';
        }
        break;

      case 'house':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.houses[index])) {
          this.contactInfoAfter.houses[index] = new HouseBean('', '', '', '');
        }
        this.contactInfoAfter.houses[index].houseType = selectTypeId;
        if (selectTypeId == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          this.contactInfoAfter.houses[index].selectTextCustom = selectText as string;
        } else {
          this.contactInfoAfter.houses[index].selectTextCustom = '';
        }

        break;
      case 'relationships':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.relationships[index])) {
          this.contactInfoAfter.relationships[index] = new AssociatedPersonBean('', '', '', '');
        }
        this.contactInfoAfter.relationships[index].associatedType = selectTypeId;
        if (selectTypeId == PhoneAccountType.TYPE_ID_CUSTOM.toString()) {
          this.contactInfoAfter.relationships[index].selectTextCustom = selectText as string;
        } else {
          this.contactInfoAfter.relationships[index].selectTextCustom = '';
        }

        break;
      case 'events':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.events[index])) {
          this.contactInfoAfter.events[index] = new EventBean('', '', '', '');
        }
        this.contactInfoAfter.events[index].eventType = selectTypeId;
        break;
      default:
        break;
    }
    this.addState = true;
    this.refresh();
  }

  /**
   * 下拉框点中一个触发此方法
   * @param typeName
   * @param data 点击下拉选项所在行的 对应的 编辑的的信息
   * @param item 下拉框点击的选项
   */
  public menuChange(typeName: string, data: LooseObject, item: EditType) {
    switch (typeName) {
      case 'phone':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.phones[data.i - 1])) {
          this.contactInfoAfter.phones[data.i - 1] = new PhoneNumBean('', '', '', '', '');
        }
        this.contactInfoAfter.phones[data.i - 1].numType = item.rawValue.toString();
        // 自定义类型，需要记录自定义的文本信息; 否则，需要清除自定义文本信息
        if (item.rawValue == PhoneAccountType.TYPE_ID_CUSTOM) {
          this.contactInfoAfter.phones[data.i - 1].selectTextCustom = item.labelRes as string;
        } else {
          this.contactInfoAfter.phones[data.i - 1].selectTextCustom = '';
        }
        data.numType = item.rawValue.toString();
        break;
      case 'email':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.emails[data.i - 1])) {
          this.contactInfoAfter.emails[data.i - 1] = new EmailBean('', '', '');
        }
        this.contactInfoAfter.emails[data.i - 1].emailType = item.rawValue.toString();
        if (item.rawValue == PhoneAccountType.TYPE_ID_CUSTOM) {
          this.contactInfoAfter.emails[data.i - 1].selectTextCustom = item.labelRes as string;
        } else {
          this.contactInfoAfter.emails[data.i - 1].selectTextCustom = '';
        }
        data.emailType = item.rawValue.toString();
        break;
      case 'AIM':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.aims[data.i - 1])) {
          this.contactInfoAfter.aims[data.i - 1] = new AIMBean('', '', '', '');
        }
        this.contactInfoAfter.aims[data.i - 1].aimType = item.rawValue.toString();
        if (item.rawValue == PhoneAccountType.TYPE_ID_CUSTOM) {
          this.contactInfoAfter.aims[data.i - 1].selectTextCustom = item.labelRes as string;
        } else {
          this.contactInfoAfter.aims[data.i - 1].selectTextCustom = '';
        }
        break;
      case 'house':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.houses[data.i - 1])) {
          this.contactInfoAfter.houses[data.i - 1] = new HouseBean('', '', '', '');
        }
        this.contactInfoAfter.houses[data.i - 1].houseType = item.rawValue.toString();
        if (item.rawValue == PhoneAccountType.TYPE_ID_CUSTOM) {
          this.contactInfoAfter.houses[data.i - 1].selectTextCustom = item.labelRes as string;
        } else {
          this.contactInfoAfter.houses[data.i - 1].selectTextCustom = '';
        }
        break;
      case 'relationships':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.relationships[data.i - 1])) {
          this.contactInfoAfter.relationships[data.i - 1] = new AssociatedPersonBean('', '', '', '');
        }
        this.contactInfoAfter.relationships[data.i - 1].associatedType = item.rawValue.toString();
        if (item.rawValue == PhoneAccountType.TYPE_ID_CUSTOM) {
          this.contactInfoAfter.relationships[data.i - 1].selectTextCustom = item.labelRes as string;
        } else {
          this.contactInfoAfter.relationships[data.i - 1].selectTextCustom = '';
        }
        break;
      case 'events':
        if (ObjectUtil.isEmpty(this.contactInfoAfter.events[data.i - 1])) {
          this.contactInfoAfter.events[data.i - 1] = new EventBean('', '', '', '');
        }
        this.contactInfoAfter.events[data.i - 1].eventType = item.rawValue.toString();
        break;
      default:
        break;
    }
    this.addState = true;
    this.saveClickEnable();
    this.refresh();
  }

  saveClickEnable() {
    HiLog.w(TAG, 'msl, saveClickEnable in addState:' + this.addState + ',clickEnable:' + this.clickEnable)
    let ret = this.isLoadedPhoto && ((this.addState && this.clickEnable) || this.photoChanged || this.ringToneChanged);
    if (this.isMyCard) {
      let hasNameOrPhone = !ArrayUtil.isEmpty(this.contactInfoAfter.phones) ||
        !StringUtil.isEmpty(this.contactInfoAfter.display_name);
      HiLog.i(TAG, `hasNameOrPhone: ${hasNameOrPhone}`);
      ret = ret && hasNameOrPhone;
    }
    AppStorage.setOrCreate('isSave', ret);
    return ret;
  }

  formatDisplayname() {
    if (!StringUtil.isEmpty(this.contactInfoAfter.display_name)) {
      this.contactInfoAfter.display_name = this.contactInfoAfter.display_name.trim();
    }
  }

  async removeContactLocalRingtone(context: Context) {
    if (this.originalContactInfoBefore.personalRingtone === this.contactInfoAfter.personalRingtone) {
      HiLog.i(TAG, `contactRingtoneInfo is not change`);
      return;
    }
    let personalRingtone: string = this.contactInfoAfter.personalRingtone;
    HiLog.i(TAG, `current LocalRingtone ${personalRingtone}`);
    let ringtoneResult: RingtoneItem | undefined =
      await RingtoneSelectionUtil.findRingtoneFromList(personalRingtone);
    if ((ringtoneResult && !StringUtil.isEmpty(ringtoneResult.path)) ||
    StringUtil.isEmpty(personalRingtone) || personalRingtone === '-1') {
      HiLog.w(TAG, `personalRingtone is not localMusic`);
      return;
    }

    try {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('queryLocalRingToneUsedTimes', {
          id: this.contactId,
          uri: personalRingtone
        }, (result: number) => {
          HiLog.w(TAG, 'queryLocalRingToneUsedTimes succ: ' + result);
          if (result < 1) {
            systemSoundManager.getSystemSoundManager().removeCustomizedTone(context, personalRingtone);
          }
        });
    } catch (error) {
      HiLog.e(TAG, 'removeCustomizedTone error: ' + error?.message);
      return;
    }
  }

  public saveContact(uiExtentionSession?: UIExtensionContentSession, isJumpToContactDetail: boolean = true) {
    if (this.saveClickEnable()) {
      this.checkValueEmpty();
      // 对于123-2345-3544 格式的电话号码，去点中间的'-'
      if (!ArrayUtil.isEmpty(this.contactInfoAfter.phones)) {
        this.contactInfoAfter.phones.forEach((phoneNumBean) => {
          phoneNumBean.num = phoneNumBean.num?.replace(new RegExp('-*', 'g'), '');
        })
      }
      this.formatDisplayname();
      this.clickEnable = false;
      this.saveClickEnable();
      if (this.updateShow === false) {
        // 保存联系人打点--新建
        this.saveContactParams.ENC = 0;
        DotUtil.getInstance().contactDot(this.saveContactParams, SAVE_EVENT);
        let pathInfosParams: SingleSelectContact | undefined =
          this.pathInfos?.getParamByIndex(this.pathInfos.size() - 1) as SingleSelectContact | undefined;
        this.sourceHasParam = pathInfosParams?.sourceHasParam ?? this.sourceHasParam;
        AppStorage.setOrCreate('newContactInfo', {});
        // 新增操作
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
          .sendRequest('addContact',
            {
              context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              contactInfoAfter: JSON.stringify(this.contactInfoAfter),
              photoBlob: this.photo,
              isMyCard: this.isMyCard,
              operationScenario: 'Manually Adding Contacts'
            }
            , (arg: string[]) => {
              HiLog.w(TAG, 'addContact callback  arg == ' + arg);
              this.clickEnable = true;
              this.saveClickEnable();
              if (arg && arg.length > 0) {
                this.contactId = arg[0]; // It's rawContactId actually
                AppStorage.setOrCreate<number>(AppStorageConstant.NEW_CONTACT_ID, Number(this.contactId));
              }
              if (!PreferencesUtil.isUsed()) {
                PreferencesUtil.setIsUsed(true);
              }
              let params: LooseObject;
              if (arg && arg.length === 2) {
                params = {
                  sourceHasId: true,
                  contactId: Number.parseInt(arg[1]),
                  sourceHasParam: this.sourceHasParam,
                  isMyCard: this.isMyCard
                };
              } else {
                params = {
                  sourceHasRawId: true,
                  rawContactId: Number.parseInt(this.contactId),
                  sourceHasParam: this.sourceHasParam,
                  isMyCard: this.isMyCard
                };
              }
              // 触发联系人详情页面显示对应联系人
              AppStorage.setOrCreate('newContactInfo', params);
              if (this.photoPixelMap !== null) {
                this.saveImgByRawId();
              }

              let isFromSaveContactPicker = AppStorage.get<boolean>('isFromSaveContactPicker') as boolean;
              if (isFromSaveContactPicker) {

                let contactIndex = -1;
                if (AppStorage.has(AppStorageConstant.NEW_CONTACT_ID)) {
                  contactIndex = AppStorage.get<number>(AppStorageConstant.NEW_CONTACT_ID) as number;
                  AppStorage.delete(AppStorageConstant.NEW_CONTACT_ID);
                }
                HiLog.i(TAG, 'send back msg: notifyHostBackPress, isFromSaveContactPicker：' + isFromSaveContactPicker + '  contactIndex: ' + contactIndex)
                let backPressMsg: Record<string, string | boolean | number> = {
                  'action': 'notifyHostBackPress',
                  //parameters: {
                  'isFromSaveContactPicker': isFromSaveContactPicker,
                  'contactIndex': contactIndex
                  //}
                }
                setTimeout(() => {
                  HiLog.i(TAG, 'addContact, uiExtentionSession?.sendData')
                  uiExtentionSession?.sendData(backPressMsg);
                }, 500);
              }

            })
        if (AppStorage.get<boolean>('isFromMeeTimeDetail') as boolean) {
          DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
            AppStorage.setOrCreate('selectContactId', this.contactId);
          });
        } else if (!AppStorage.get<boolean>('isFromSaveContactPicker') as boolean) {
          // 添加联系人参数
          const param: LooseObject = {
            addNewContact: true,
            sourceHasParam: this.sourceHasParam,
          };
          this.pathInfos?.pop();
          if (isJumpToContactDetail) {
            DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
              // 手机
              if (AppStorage.get('breakpoint') === 'sm') {
               //跳转位置
                this.pathInfos?.pushPathByName('ContactDetail', param, false);
              } else {
                // 大屏幕
                this.pathInfos?.pushPathByName('ContactDetail', param, false);
              }
            });
          }
        }
      } else {
        // 保存联系人打点--编辑
        this.saveContactParams.ENC = 1;
        DotUtil.getInstance().contactDot(this.saveContactParams, SAVE_EVENT);
        // 如果修改后，内容为空，直接删除
        if (this.nullContactInfo == this.getExistenceInfoString(this.contactInfoAfter) && this.photoPixelMap == null) {
          ContactsGlobalThisHelper.GetGlobalThis()
            .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
            .sendRequest('deleteContactById', {
              context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              contactId: this.contactId,
              operationScenario: 'Empty content after edit'
            }, (result: number | undefined) => {
              SmsManagerUtils.notifyMmsWhenDeleteContact([this.contactId].map(Number), result === 0 ? 0 : -1);
              if (result == 0 || result == undefined) {
                HiLog.w(TAG, 'doDeleteContact succ');
                this.pathInfos?.pop();
              } else {
                HiLog.w(TAG, `doDeleteContact Failed ${result}`);
                Prompt.showToast({
                  message: 'contactDetail Failed to delete data.'
                });
                // 删除记录的话，会回到联系人列表
                this.pathInfos?.pop();
              }
            });
          delFileById(this.contactId, false);
        } else {
          // 继承原始数据
          this.originalDataHandleHelper.inheritOriginalDataHandle(this.contactInfoAfter);
          if (this.photoChanged && this.photoPixelMap === null) {
            PixelMapManager.getInstance().initBlobSourceMapByIds([this.contactId]);
          }
          // 更新操作
          ContactsGlobalThisHelper.GetGlobalThis()
            .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
            .sendRequest('updateContact', {
              context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              contactInfoBefore: this.originalContactInfoBefore,
              contactInfoAfter: this.contactInfoAfter,
              // 新创建、编辑后的头像
              photoBlob: this.photo,
              deletePhoto: this.photoChanged && this.photoPixelMap === null,
              isMyCard: this.isMyCard,
              operationScenario: 'manul update',
            }, async (arg: string) => {
              HiLog.w(TAG, 'updateContact callback  arg == ' + arg);
              this.originalContactInfoBefore = this.contactInfoAfter;
              this.clickEnable = true;
              this.saveClickEnable();
              if (!PreferencesUtil.isUsed()) {
                PreferencesUtil.setIsUsed(true);
              }
              const params: LooseObject = {
                sourceHasId: true,
                contactId: Number.parseInt(this.contactId)
              };
              // 清理对应联系人的头像缓存，防止取到旧头像
              PixelMapManager.getInstance().deleteContactListIdMiniPixelMap(this.contactId);
              PixelMapManager.getInstance().deleteMiniPixelMap(this.contactId);
              if (this.photoPixelMap !== null && this.photoChanged) {
                let imageInfo = await this.photoPixelMap.getImageInfo();
                let blobSource = 3;
                if (imageInfo.size.height * imageInfo.size.width <= MIN_RESOLUTION) {
                  blobSource = 1;
                }
                let contactBlobSource: ContactBlobSource = {
                  contactId: arg,
                  blobSource: blobSource,
                  rawContactId: arg,
                  detailInfo: ''
                }
                HiLog.i(TAG, `updateContact, contactBlobSource contactId: ${contactBlobSource?.contactId}, rawContactId: ${contactBlobSource?.rawContactId},
                 detailInfo: ${contactBlobSource?.detailInfo}`);
                PixelMapManager.getInstance().contactIdBlobSourceMap.set(arg, contactBlobSource);
                saveImageToFile(this.photoPixelMap, this.contactId, () => {
                  AppStorage.setOrCreate('updateContactInfo', params);
                });
              } else {
                if (this.photoPixelMap === null && this.photoChanged) {
                  delFileById(this.contactId, true);
                }
                AppStorage.setOrCreate('updateContactInfo', params);
              }
              let speedDialList: SpeedDialItem[] | undefined = AppStorage.get('speedDialArray')
              this.updateContactInfoToSpeedDial(speedDialList);
              this.deleteCardContact(this.contactInfoAfter);
              let isFromPickerSaveExistContact = AppStorage.get<boolean>('isFromPickerSaveExistContact') as boolean;
              if (isFromPickerSaveExistContact) {
                HiLog.i(TAG, `send back msg:
                isFromPickerSaveExistContact：${isFromPickerSaveExistContact}  contactIndex: ${arg}`);
                let backPressMsg: Record<string, string | boolean | number> = {
                  'action': 'notifyHostBackPress',
                  'isFromSaveContactPicker': isFromPickerSaveExistContact,
                  'isFromSelectBindSheet': isFromPickerSaveExistContact,
                  'contactIndex': Number.parseInt(arg)
                }
                setTimeout(() => {
                  HiLog.i(TAG, 'updataContact uiExtentionSession?.sendData')
                  uiExtentionSession?.sendData(backPressMsg);
                }, 500);
                if (isFromPickerSaveExistContact) {
                  AppStorage.setOrCreate('isShowBindSheet', false);
                }
              }
            })
          if (AppStorage.get<boolean>('isFromMeeTimeDetail') as boolean) {
            DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
              AppStorage.setOrCreate('selectContactId', this.contactId);
            });
          } else if (!AppStorage.get<boolean>('isFromPickerSaveExistContact') as boolean) {
            const param: LooseObject = {
              addNewContact: true
            };
            this.pathInfos?.pop();
            // jumpToDetailPage
            if (isJumpToContactDetail) {
              DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
                this.pathInfos?.pop(false)
                this.pathInfos?.pushPathByName('ContactDetail', param);
              });
            }
          }
        }
      }
    }
  }

  saveImgByRawId() {
    const requestParam: LooseObject = {
      rawContactId: this.contactId
    };
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactIdByRawId', requestParam, (contactId: string[]) => {
        if (ArrayUtil.isEmpty(contactId) || StringUtil.isEmpty(contactId[0])) {
          HiLog.w(TAG, 'getContactIdByRawId contactId is not exist');
        } else {
          this.contactId = contactId[0];
          if (this.photoPixelMap) {
            saveImageToFile(this.photoPixelMap, this.contactId);
          }
        }
      });
  }
  // 编辑页将联系人号码设置为空，卡片删除该联系人
  deleteCardContact(contactInfoAfter: ContactInfo) {
    let context:Context = getContext(this)
    if (contactInfoAfter.phones.length === 0) {
      shortcutEditCommon.updateContactFormId(contactInfoAfter.contactID, context, '')
      speedDialEditCommon.updateContactFormId(contactInfoAfter.contactID, context, '')
    }
  }

  updateContactInfoToSpeedDial(speedDialList: SpeedDialItem[] | undefined) {
    speedDialList?.forEach(async (item) => {
      if (item.contactId === this.contactId) {
        item.contactName = this.contactInfoAfter.display_name;
        item.contactTelephone = this.contactInfoAfter.phones[0].num;
        item.nameSuffix = getHeadChar(this.contactInfoAfter.display_name);
        let speedDials: SpeedDialItem[] =
          JSON.parse(await sharedPreferencesUtils.getFromPreferences('speedDialObjString', '') as string);
        speedDials[String(item.number)] = item;
        sharedPreferencesUtils.saveToPreferences('speedDialObjString', JSON.stringify(speedDials));
        AppStorage.setOrCreate('speedDialFromContact', item);
      }
    })
    AppStorage.setOrCreate('speedDialArray', speedDialList)
  }

  public textChange() {
    this.refresh();
  }

  /**
   * Hide the Keyboard to prevent occlusion dialogs.
   */
  hideKeyboard() {
    inputMethod.getController().hideSoftKeyboard(() => {
    })
  }

  updateItemsShowState(contactInfo: ContactInfo) {
    this.itemsShowState['phone'] = true;
    this.itemsShowState['email'] = true;
    if (!StringUtil.isEmpty(contactInfo.phoneticName)) {
      this.itemsShowState['phoneticName'] = true;
    }
    if (!StringUtil.isEmpty(contactInfo.aims[0]?.aimName)) {
      this.itemsShowState['aims'] = true;
    }
    if (!StringUtil.isEmpty(contactInfo.houses[0]?.houseName)) {
      this.itemsShowState['houses'] = true;
    }
    if (!StringUtil.isEmpty(contactInfo.nickname)) {
      this.itemsShowState['nickname'] = true;
    }
    if (!StringUtil.isEmpty(contactInfo.websites[0])) {
      this.itemsShowState['websites'] = true;
    }
    if (!StringUtil.isEmpty(contactInfo.events[0]?.data)) {
      this.itemsShowState['events'] = true;
    }
    if (!StringUtil.isEmpty(contactInfo.relationships[0]?.name)) {
      this.itemsShowState['relationships'] = true;
    }
  }

  checkPhonesEmpty() {
    for (let i = 0; i < this.contactInfoAfter.phones.length; ++i) {
      if (StringUtil.isEmpty(this.contactInfoAfter.phones[i].num)) {
        this.contactInfoAfter.phones[i].num = '';
      } else {
        //只要有一个电话号码有值 打点参数就赋值为1
        this.saveContactParams.ISPHONE = 1;
        // 联系人打点-电话类型
        let typeParams: CustomizedParams = {
          TYPE: this.contactInfoAfter.phones[i].numType
        }
        DotUtil.getInstance().contactDot(typeParams, PHONE_TYPE_EVENT);
      }
    }
  }

  checkEmailsEmpty() {
    for (let i = 0; i < this.contactInfoAfter.emails.length; ++i) {
      if (StringUtil.isEmpty(this.contactInfoAfter.emails[i].address)) {
        this.contactInfoAfter.emails[i].address = '';
      } else {
        //只要有一个电子邮件有值 打点参数就赋值为1
        this.saveContactParams.ISEMAIL = 1;
        // 联系人打点-邮件类型
        let typeParams: CustomizedParams = {
          TYPE: this.contactInfoAfter.emails[i].emailType
        }
        DotUtil.getInstance().contactDot(typeParams, EMAILS_TYPE_EVENT);
      }
    }
  }

  checkAimsEmpty() {
    for (let i = 0; i < this.contactInfoAfter.aims.length; ++i) {
      if (StringUtil.isEmpty(this.contactInfoAfter.aims[i].aimName)) {
        this.contactInfoAfter.aims[i].aimName = '';
      } else {
        //只要有一条即时消息有值 打点参数就赋值为1
        this.saveContactParams.ISMESSAGE = 1;
        // 联系人打点-aim类型
        let typeParams: CustomizedParams = {
          TYPE: this.contactInfoAfter.aims[i].aimType
        }
        DotUtil.getInstance().contactDot(typeParams, AIMS_TYPE_EVENT);
      }
    }
  }

  checkHousesEmpty() {
    for (let i = 0; i < this.contactInfoAfter.houses.length; ++i) {
      if (StringUtil.isEmpty(this.contactInfoAfter.houses[i].houseName)) {
        this.contactInfoAfter.houses[i].houseName = '';
      } else {
        //只要有一个地址有值 打点参数就赋值为1
        this.saveContactParams.ISADDRESS = 1;
        // 联系人打点-地址类型
        let typeParams: CustomizedParams = {
          TYPE: this.contactInfoAfter.houses[i].houseType
        }
        DotUtil.getInstance().contactDot(typeParams, HOUSES_TYPE_EVENT);
      }
    }
  }

  checkWebsitesEmpty() {
    for (let i = 0; i < this.contactInfoAfter.websites.length; ++i) {
      if (StringUtil.isEmpty(this.contactInfoAfter.websites[i])) {
        this.contactInfoAfter.websites[i] = '';
      } else {
        //只要有一个网站信息有值 打点参数就赋值为1
        this.saveContactParams.ISWEBSITE = 1;
      }
    }
  }

  checkEventsEmpty() {
    for (let i = 0; i < this.contactInfoAfter.events.length; ++i) {
      if (!StringUtil.isEmpty(this.contactInfoAfter.events[i].data)) {
        //只要有一个生日日期不为空 就赋值给1
        this.saveContactParams.ISBIRTHDAYDATE = 1;
        // 联系人打点-日期类型
        let typeParams: CustomizedParams = {
          TYPE: this.contactInfoAfter.events[i].eventType
        }
        DotUtil.getInstance().contactDot(typeParams, EVENTS_TYPE_EVENT);
      }
    }
  }

  checkRelationshipsEmpty() {
    for (let i = 0; i < this.contactInfoAfter.relationships.length; ++i) {
      if (StringUtil.isEmpty(this.contactInfoAfter.relationships[i].name)) {
        this.contactInfoAfter.relationships[i].name = '';
      } else {
        //只要有一个关联人姓名有值 打点参数就赋值为1
        this.saveContactParams.ISASSOCIATED = 1;
        // 联系人打点-关联人类型
        let typeParams: CustomizedParams = {
          TYPE: this.contactInfoAfter.relationships[i].associatedType
        }
        DotUtil.getInstance().contactDot(typeParams, RELATIONSHIPS_TYPE_EVENT);
      }
    }
  }

  checkValueEmpty() {
    if (StringUtil.isEmpty(this.contactInfoAfter.display_name)) {
      this.contactInfoAfter.display_name = '';
    } else {
      //已输入姓名打点ISNAME 赋值1
      this.saveContactParams.ISNAME = 1;
    }
    if (StringUtil.isEmpty(this.contactInfoAfter.phoneticName)) {
      this.contactInfoAfter.phoneticName = '';
    }
    if (StringUtil.isEmpty(this.contactInfoAfter.company)) {
      this.contactInfoAfter.company = '';
    } else {
      //已输入单位打点ISUNIT 赋值为1
      this.saveContactParams.ISUNIT = 1;
    }
    if (StringUtil.isEmpty(this.contactInfoAfter.position)) {
      this.contactInfoAfter.position = '';
    }
    this.checkPhonesEmpty();
    this.checkEmailsEmpty();
    this.checkAimsEmpty();
    this.checkHousesEmpty();
    if (StringUtil.isEmpty(this.contactInfoAfter.remarks)) {
      this.contactInfoAfter.remarks = '';
    } else {
      //只要有一条备注有值 打点参数就赋值为1
      this.saveContactParams.ISREMARKS = 1;
    }
    if (StringUtil.isEmpty(this.contactInfoAfter.nickname)) {
      this.contactInfoAfter.nickname = '';
    } else {
      //只要有一个昵称有值 打点参数就赋值为1
      this.saveContactParams.ISNICKNAME = 1;
    }
    this.checkWebsitesEmpty();
    this.checkEventsEmpty();
    this.checkRelationshipsEmpty();
  }

  // 电话号码一边输入一边格式化
  public async formatPhoneNumber(val: string): Promise<string> {
    if (!val) {
      HiLog.w(TAG, 'formatPhoneNumber params is invalid.');
      return '';
    }
    let removeSpaceStr: RegExp = new RegExp('[\\s]', 'g');
    val = val.replace(removeSpaceStr, '');
    let formatPhoneNumber: string = '';
    if (val && val.length) {
      let formatNumber = await call.formatPhoneNumber(val).catch((err: Base.BusinessError) => {
        HiLog.e(TAG, `format phoneNumber err cause: ${err?.message}.`);
      });
      if (formatNumber) {
        formatPhoneNumber = formatNumber;
      } else {
        formatPhoneNumber = val;
      }
    } else {
      HiLog.w(TAG, 'formatPhoneNumber is invalid.');
      formatPhoneNumber = val;
    }
    return formatPhoneNumber;
  }
}