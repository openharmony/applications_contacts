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

import prompt from '@system.prompt';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { DynamicLoader } from '../../../../../../../common/src/main/ets/util/DynamicLoader';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import TraceConstants from '../../../../../../../common/src/main/ets/TraceConstants';
import { DeviceUtils } from '../../../../../../../common/src/main/ets/util/DeviceUtils';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { CallLogRepository } from '../../../../../../../feature/call/src/main/ets/repo/CallLogRepository';
import { CallLog, CallType } from '../../../../../../../feature/call/src/main/ets/entity/CallLog';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import MeeTimeService from '../../../../../../../feature/phonenumber/src/main/ets/MeeTimeService';
import { House } from '../../../../../../../feature/contact/src/main/ets/contract/House';
import { Relation } from '../../../../../../../feature/contact/src/main/ets/contract/Relation';
import { Phone } from '../../../../../../../feature/contact/src/main/ets/contract/Phone';
import { Email } from '../../../../../../../feature/contact/src/main/ets/contract/Email';
import { Birthday } from '../../../../../../../feature/contact/src/main/ets/contract/Birthday';
import { Aim } from '../../../../../../../feature/contact/src/main/ets/contract/Aim';
import MorandiColor from '../../../model/bean/MorandiColor';
import DetailCallLogDataSource from '../../../model/bean/DetailCallLogDataSource';
import ContactDetailDataSource from '../../../model/bean/ContactDetailDataSource';
import MeeTimeDeviceInfoDataSource from '../../../model/bean/MeetimeDeviceInfoDataSource';
import StringFormatUtil from '../../../util/StringFormatUtil';
import { DataItemType } from '../../../../../../../feature/contact';
import { AsyncCallback, BusinessError } from '@ohos.base';
import {
  BaseContackSubInfoModel,
  ContackPhoneSubInfoModel,
  ContactFormModel,
  ContactPickerParam
} from '../../../model/type/ContactParams';
import { RichContactInfo } from '../../../model/bean/RichContactInfo';
import { ObjectUtil, sharedPreferencesUtils } from '../../../../../../../feature/call/oh_modules/common';
import {
  AccountantParams,
  ContactBlobSource,
  ContactIdParam,
  ContactReturnObj,
  FindByNumberActionData,
  SingleSelectContact
} from '../../../model/type';
import CallDetail from '../../../model/bean/CallDetail';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import ability from '@ohos.ability.ability';
import PhoneAccountType from '../../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { delFileById, getPixelMapFromFile, getPhotoPixelMapFromDB, PixelMapManager } from '../../../util/UserPhoto';
import { SpeedDialItem } from '../../../model/type/index';
import connection from '@ohos.net.connection';
import { PhoneNumBean } from '../../../model/bean/PhoneNumBean';
import { Constants } from '../../../../../../../feature/phonenumber/src/main/ets/idl/model/Constants';
import MeeTimeAbilityInfoModel from '../../../../../../../feature/contact/src/main/ets/entity/MeeTimeAbilityInfoModel';
import MeeTimeDeviceInfoModel from '../../../../../../../feature/contact/src/main/ets/entity/MeeTimeDeviceInfoModel';
import sim from '@ohos.telephony.sim';
import { DSDS_MODE_V2 } from '../../../component/mutisim/DsdaConstants';
import LooseObject from '../../../model/type/LooseObject';
import { MeetimeCalls } from '../../../../../../../feature/call/src/main/ets/contract/MeetimeCalls';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import ContactListPresenter from '../ContactListPresenter';
import { MissedCallNotifyData } from '../../../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier';
import Notification from '@ohos.notificationManager';
import resourceManager from '@ohos.resourceManager';
import Calls from '../../../../../../../feature/call/src/main/ets/contract/Calls';
import dataShare from '@ohos.data.dataShare';
import common from '@ohos.app.ability.common';
import CallRecordPresenter from '../../dialer/callRecord/CallRecordPresenter';
import { ProfileUtils } from '../../../util/ProfileUtils';
import { promptAction, window } from '@kit.ArkUI';
import { HashSet, taskpool } from '@kit.ArkTS';
import {
  ContactRepository,
  queryYellowPageByNumber,
  queryUniqueKeyByContactId
} from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import ContactNameNumberInfo from '../../../../../../../feature/contact/src/main/ets/entity/ContactNameNumberInfo';
import NumberMarkUtil from '../../../util/NumberMarkUtil';
import FavoriteListPresenter from '../../favorite/FavoriteListPresenter';
import IndexPresenter from '../../IndexPresenter';
import { DynamicLoadSoUtil } from '../../../../../../../common/src/main/ets/util/DynamicLoadSoUtil';
import { abilityAccessCtrl } from '@kit.AbilityKit';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { Data } from '../../../../../../../feature/contact/src/main/ets/contract/Data';
import {
  AppStorageConstant
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/AppStorageConstant';
import data_preferences from '@ohos.data.preferences';
import SmsManagerUtils from '../../../util/SmsManagerUtils';
import { LimitRefreshDataUtil } from '../../../util/LimitRefreshDataUtil';
import { ContactVo } from '../../../model/bean/ContactVo';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import displaySync from '@ohos.graphics.displaySync';
import { ContactIdsParam } from '../settings/ArrangeContactsPresenter';
import { RingtoneInfo } from '../../../model/ringTone/toneTypes';
import { DateTimeFormat } from '../../../util/DateTimeFormat';
import { checkIsLightColor } from './ColorPickerUtil';
import ContactAbilityModel from '../../../model/ContactAbilityModel';

const TAG = 'DetailPresenter';
const KEY_MISSED_BADGE_NUM = 'missed_badge_number';
const deviceProfileConstants: DeviceTypeEnum = {
  // 畅连消息按位与值
  meetimeMessage: 1 << 1,
  //畅连消息
  supportmessageservicebitMeetimeMessage: 1,
  // 有畅联能力
  hasCapacity: 1,
  // 无畅联能力
  noCapacity: 0
};

export interface DeviceTypeEnum {
  meetimeMessage: number;
  supportmessageservicebitMeetimeMessage: number;
  hasCapacity: number;
  noCapacity: number;
}

export class CapabilityInfo {
  public phoneNumber?: string;
  public accountId?: string;
  public deviceInfo?: string;
  public hasVoice: number = 0;
  public hasVideo: number = 0;
  public hasMessage: number = 0;
  public deviceList?: Array<DeviceInfo>;
  public allDeviceList?: Array<DeviceInfo>;
  public isHavePrivateDevice?: boolean;
  public nickName?: string;
}

export interface DeviceInfo {
  deviceType: number;
  deviceTypeName: string;
  isPrivate: boolean;
  deviceComId: string;
  profile: string;
  policy: string;
  sdkVersion: string;
  deviceIndex: number;
  deviceNotes: string;
  latestLoginTime: number;
  registerTime: number;
  publicName: string;
}

export class MeeTimeChatPageParams {
  public threadInfo: ThreadInfo
  public from: string
  public contactId: number

  constructor(threadInfo: ThreadInfo, from = '', contactId = 0) {
    this.threadInfo = threadInfo
    this.from = from
    this.contactId = contactId
  }
}

export class ThreadInfo {
  public phoneNumber: string;
  public accountId: string
  public comId: string
  public localName: string
  public deviceType: number

  constructor(phoneNumber = '', accountId = '', comId = '', localName = '', deviceType = -1) {
    this.phoneNumber = phoneNumber
    this.accountId = accountId
    this.comId = comId
    this.localName = localName
    this.deviceType = deviceType
  }
}

// Detail Presenter
export default class DetailPresenter {
  public params?: AccountantParams;
  // 畅连头像
  public imageUrlMeetime: string = '';
  // 畅连语音能力类型; 畅连语音能力在二进制下标位置
  public static readonly ABILITY_TYPE_AND_INDEX_AUDIO: number = 2;
  // 畅连视频能力类型; 畅连视频能力在二进制下标位置
  public static readonly ABILITY_TYPE_AND_INDEX_VIDEO: number = 1;
  // 畅连聊天能力类型; 畅连聊天能力在二进制下标位置
  public static readonly ABILITY_TYPE_AND_INDEX_CHAT: number = 0;
  public static readonly PHONE_NUMBER_HAS_NO_MEETIME_ABILIBY_FLAG = 0;
  // 对其畅连，不存在对应联系人id；从通话记录页面，点击手机号进入详情场景；标记id为0
  public static readonly NOT_EXIST_CONTACT_ID = 0;
  // 畅连登录标记
  public isMeeTimeLoginFlag: boolean = false;
  // 存在畅连能力标记
  public isHasMeeTimeAbilityFlag: boolean = false;
  // 畅连能力有哪些标记
  public meeTimeAbilityBinary: string = '000';
  public pathInfos: NavPathStack = new NavPathStack();
  private static sInstance: DetailPresenter;
  /** UI parameters */
  public moreMenuOptions: Resource[] = [$r('app.string.delete_contact')];
  // is favorite
  public isFavorite: boolean = false;
  public showNameLastMenu: string = '';
  public lastUsedSlotId: number = -1;
  public canBeShared: boolean = false;
  /** Display parameters */
  public sourceHasId: boolean = false;
  public sourceHasPhone: boolean = false;
  public sourceHasParam: boolean = false;
  public sourceHasRawId: boolean = false;
  public fromSmsList: boolean = false;
  public phoneNumberShow: string = '';
  public contactId: number = -1;
  public nameRawContactId: number = -1;
  public rawContactId: number = -1;
  public isNewNumber: boolean = true;
  public isNewDetail: boolean = false;
  public topbarBackgroundColor: ResourceColor = Color.Transparent;
  public meeTimeAbilityInfoModel: MeeTimeAbilityInfoModel = new MeeTimeAbilityInfoModel();
  public newNumberBgColor: Resource = $r('sys.color.ohos_id_color_special1');
  public detailsColor: Resource = $r('sys.color.ohos_id_color_special1');
  public isFavorited: string = '0';
  public photoPixelMap: null | PixelMap = null;
  public cardPhotoPixelMap: null | PixelMap = null;
  // 海报头像颜色深浅判断
  public isTitleBarLightColor: boolean = false; // 标题栏区域
  public isNameRegionLight: boolean = false;  // 联系人姓名区域
  public isContactDataReady: boolean = false;
  public displayName: string | Resource = '';
  public displayNameQueryByYellowPageFlag = false;
  public skipInitContact: boolean = false;
  public shareContent: string = '';
  public isPrivateNumber: boolean = false;
  public isMyCard: boolean = false;
  public isMyCardFlagInit: boolean = false;
  public isCnap: boolean = false;
  public pageFlag: string = '';
  // 联系人信息去重展示
  public uniqueData: Record<string, HashSet<string>> = {
    'phones': new HashSet(),
    'emails': new HashSet(),
    'aims': new HashSet(),
    'websites': new HashSet(),
    'houses': new HashSet(),
    'events': new HashSet(),
    'relationships': new HashSet(),
  };
  /** detail parameters */
  public contactForm: ContactFormModel = {
    contactId: -1,
    displayName: '',
    photoFirstName: '',
    company: '',
    position: '',
    phones: [],
    emails: [],
    aims: [],
    nickname: [],
    websites: [],
    houses: [],
    events: [],
    phoneticName: [],
    remarks: '',
    relationships: [],
    numRecords: [],
    portraitColor: MorandiColor.color[0],
    detailsBgColor: MorandiColor.detailColor[0],
    favorite: 0,
    personalRingtone: '',
    personalRingtonePath: '',
    personalNotificationRingtone: '',
  };
  // 通话记录数据源
  public detailCallLogDataSource: DetailCallLogDataSource = new DetailCallLogDataSource();
  // 手机号数据源
  public phoneDataSources: ContactDetailDataSource<ContackPhoneSubInfoModel> = new ContactDetailDataSource();
  // 邮箱等数据源
  public detailInfoRemarksSources: ContactDetailDataSource<BaseContackSubInfoModel> = new ContactDetailDataSource();
  // 畅联能力数据源
  public meeTimeDeviceList: MeeTimeDeviceInfoDataSource = new MeeTimeDeviceInfoDataSource();
  // 是否有非家庭设备的设备，存在的话，才显示畅联手机视频和语音栏
  public isHasNotFamilyDeviceFlag = true;
  private callRecordListenerCallback: AsyncCallback<void> | undefined = undefined;
  // 标记类型
  public markType: string = '0';
  // 标记内容
  public markContent: string = '';
  // 标记来源
  public markSource: string = '';
  // 标记数量
  public markCount: number = -1;
  /** Contact Temporary */
  public contacts: RichContactInfo = new RichContactInfo('');
  // Default value should be DSDS mode
  public dsdsMode: number = DSDS_MODE_V2;
  public changeColor: boolean = false;
  public callRecorderHelper: dataShare.DataShareHelper | null = null;
  public theoryAlltheoryScreenHeight: number = 780;
  public theoryBackgroundHeight: number = 202;
  // 通话记录变更刷新
  public onCallsChange = () => {
    HiLog.i(TAG, 'onCallsChange refresh');
    CallRecordPresenter.getInstance().initStarted = false;
  }
  public updatePhoneNums = () => {
  };
  public showLogTitleFlagRefreshFun = (callLogTotal: number) => {
  };
  public isYellowPage: boolean = false;
  public calendarManager: LooseObject | null = null;
  public refreshDetailUI: () => void = () => {
  };
  public callLogRefreshIndex: number = 0;
  public limitDataRefresh: LimitRefreshDataUtil<FindByNumberActionData, CallLog[]> | undefined = undefined;
  public refreshSystemBar: () => void = () => {
  };
  public blobSource: number = -1;
  public quickSearchKey: number = -1;
  public callLogChangeTaskId: number = -1;
  private uiExtensionSession?: UIExtensionContentSession = ContactsGlobalThisHelper.GetGlobalThis()
    .getUIExtensionContentSession();
  public resultDT: boolean = false;

  /**
   * 获取畅联能力手机号列表
   *
   * @returns
   */
  getMeeTimeAbilityPhoneNumList() {
    let phoneNumberList: Record<string, string | number | boolean>[] = [];
    let record: Record<string, string | number> = {
      'phoneNumber': this.meeTimeAbilityInfoModel.phoneNumber,
      'index': 0
    }

    phoneNumberList.push(record);
    // 最后一行标记
    phoneNumberList[phoneNumberList.length - 1].lastFlag = true;
    return phoneNumberList;
  }

  aboutToAppear() {
    this.initCallLogLimit();
    this.requestContactDetail();
    this.initDsds();
    this.registerCallLogObsever();
  }
  requestContactDetail() {
    // Groups, favorites, contact lists,new contacts.
    if (this.sourceHasRawId) {
      HiLog.w(TAG, 'onShow:sourceHasRawId');
      this.isNewNumber = false;
      this.getContactIdByRawId(this.rawContactId);
    } else if (this.sourceHasId) {
      HiLog.w(TAG, 'onShow:sourceHasId');
      this.isNewNumber = false;
      this.getContactDetail(this.contactId);
    } else if (this.quickSearchKey != -1) {
      HiLog.w(TAG, 'onShow:sourceHasQuickSearchKey' + this.quickSearchKey);
      this.isNewNumber = false;
      this.getContactDetail(this.quickSearchKey);
    } else if (this.sourceHasPhone) {
      // call log, mms.
      HiLog.w(TAG, 'onShow:sourceHasPhone');
      /** Query the contact ID based on the phone number.
      If a contact exists,the contact details are displayed based on the first contact ID.*/
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('getIdByTelephone', {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          phoneNumber: this.phoneNumberShow,
          quickSearchKey: this.quickSearchKey
        }, (contactId: string[]) => {
          HiLog.w(TAG, 'getIdByTelephone success!   contactId: ' + contactId);
          // 存在联系人
          if (!ArrayUtil.isEmpty(contactId)) {
            HiLog.w(TAG, 'contactid is exist');
            // If a contact exists, set isNewNumber to false.
            this.isNewNumber = false;
            this.contactId = Number.parseInt(contactId[0]);
            this.getContactDetail(Number.parseInt(contactId[0]));
          } else {
            // 不存在联系人
            HiLog.w(TAG, 'contactid is not exist');
            // If the contact ID does not exist, the new number is used.
            this.isNewNumber = true;
            this.getNewNumCallLog().then(() => {
              this.refreshDetailUI();
              this.isContactDataReady = true;
            });
          }
        });
    }
  }

  resetContactForm() {
    this.contactForm = {
      displayName: '',
      photoFirstName: '',
      company: '',
      position: '',
      phones: [],
      emails: [],
      aims: [],
      nickname: [],
      websites: [],
      houses: [],
      events: [],
      phoneticName: [],
      remarks: '',
      relationships: [],
      numRecords: [],
      portraitColor: MorandiColor.color[0],
      detailsBgColor: MorandiColor.detailColor[0],
      favorite: 0,
      personalRingtone: '',
      personalRingtonePath: '',
      personalNotificationRingtone: '',
    };
  }

  initDsds() {
    // Read dsds config!双卡双通的模式
    sim.getDsdsMode().then(data => {
      HiLog.i(TAG, 'getDsdsMode: ' + data);
      this.dsdsMode = data;
    });
  }

  initCallLogLimit() {
    this.limitDataRefresh =
      new LimitRefreshDataUtil<FindByNumberActionData, CallLog[]>('findByNumberIn',
        (page: number, limit: number, resultList: CallLog[]) => {
          HiLog.i(TAG, 'limitDataRefresh page:' + page + ' limit:' + limit + 'result.length:' + resultList.length);
          let callDetailList: CallDetail[] = this.getDetailMessage(resultList);
          const isEnd = resultList.length < limit;
          if (resultList.length) {
            ContactsGlobalThisHelper.GetGlobalThis()
              .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
              .sendRequest('getRecorderMessage', { callDetailList: callDetailList }, (result: CallDetail[]) => {
                if (page == 1) {
                  this.callLogRefreshIndex = 0;
                  this.lastUsedSlotId = resultList[0].simId;
                }
                HiLog.w(TAG, `callLogRefreshIndex: ${this.callLogRefreshIndex
                }, result length: ${result.length}, isEnd: ${isEnd}`)
                this.detailCallLogDataSource.refresh(this.callLogRefreshIndex, result, isEnd);
                this.callLogRefreshIndex += resultList.length;
                this.showLogTitleFlagRefreshFun(this.detailCallLogDataSource.totalCount());
              });
          } else {
            if (page == 1) {
              this.lastUsedSlotId = -1;
              this.showLogTitleFlagRefreshFun(0);
              this.detailCallLogDataSource.refresh(0, callDetailList, true);
            }
          }
          return resultList.length < limit;
        });

  }

  /**
   * This method is called when the page is about to disappear.
   */
  aboutToDisappear() {
    HiLog.i(TAG, 'ContactDetail aboutToDisappear!');
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.callLogChange);
    CallLogRepository.getInstance().unRegisterDataChangeObserver(this.onCallsChange);
    this.limitDataRefresh?.release();
    this.cardPhotoPixelMap?.release();
    this.limitDataRefresh = undefined;
  }

  /**
   * 通话记录变更刷新
   */
  public callLogChange = () => {
    HiLog.w(TAG, 'callLogChange');
    if (this.callLogChangeTaskId > 0) {
      clearTimeout(this.callLogChangeTaskId);
    }
    this.callLogChangeTaskId = setTimeout(() => {
      this.callLogChangeTaskId = -1;
      this.refresh();
    }, 500)
  }

  registerCallLogObsever() {
    CallLogRepository.getInstance().registerDataChangeObserver(this.callLogChange);
    CallLogRepository.getInstance().registerDataChangeObserver(this.onCallsChange);
  }

  refresh() {
    if (this.contactId != undefined) {
      HiLog.i(TAG, 'refresh contact detail info');
      this.getContactCallLog().then(() => {
        this.refreshDetailUI();
      })
    } else {
      HiLog.i(TAG, 'refresh callLog detail info');
      this.getNewNumCallLog().then(() => {
        this.refreshDetailUI();
      })
    }
  }

  queryIsMyCard() {
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getMyCard', undefined, (result: ContactVo[]) => {
        if (result.length) {
          let vo = result[0];
          this.initIsMyCardFlag(vo.contactId == this.contactId?.toString());
          AppStorage.setOrCreate(AppStorageConstant.MYCARD_CONTACT_ID, vo.contactId);
        } else {
          this.initIsMyCardFlag(this.isMyCard);
          AppStorage.setOrCreate(AppStorageConstant.MYCARD_CONTACT_ID, '');
        }
      })
  }

  public initIsMyCardFlag(isMyCard: boolean) {
    this.isMyCard = isMyCard;
    this.isMyCardFlagInit = true;
  }

  getContactIdByRawId(rawContactId: number) {
    const requestParam: LooseObject = {
      rawContactId: rawContactId
    };
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactIdByRawId', requestParam, (contactId: string[]) => {
        if (ArrayUtil.isEmpty(contactId) || StringUtil.isEmpty(contactId[0])) {
          HiLog.w(TAG, 'getContactIdByRawId contactId is not exist');
        } else {
          this.contactId = Number.parseInt(contactId[0]);
          HiLog.i(TAG, `getContactIdByRawId result: rawId:${rawContactId} contactId:${contactId}`);
          this.getContactDetail(this.contactId);
        }
      });
  }

  getContactDetail(contactId: number) {
    HiLog.w(TAG, `get ContactDetail by id  contactId == ${contactId}`);
    // 我的卡片标记没被初始化，就通过查询初始化
    if (!this.isMyCardFlagInit) {
      HiLog.w(TAG, `query isMyCard`);
      this.queryIsMyCard();
    }
    this.requestPhotoById(contactId.toString());
    hiTraceMeter.startTrace(TraceConstants.TRACE_DETAIL_GET_DETAIL, TraceConstants.TRACE_DETAIL_GET_DETAIL_ID);
    let task =
      new taskpool.Task(getContactById, contactId, ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    taskpool.execute(task, taskpool.Priority.HIGH).then((result: ContactReturnObj) => {
      HiLog.w(TAG, `getContactById, contactid is not exist ${result.data?.contactID}`);
      // 先清空一下所有元素
      this.resetContactForm();
      // 根据 contactId 没查到信息
      if (ObjectUtil.isEmpty(result.data)) {
        HiLog.w(TAG, `getContactById, contactid is not exist`);
        // If the contact cannot be obtained based on the specified ID, the new number is used.
        // 无对应联系人
        this.getNewNumCallLog().then(() => {
          this.refreshDetailUI();
          this.isContactDataReady = true;
        });
        hiTraceMeter.finishTrace(TraceConstants.TRACE_DETAIL_GET_DETAIL, TraceConstants.TRACE_DETAIL_GET_DETAIL_ID);
        return;
      }
      HiLog.w(TAG, `getContactById, contactid is exist`);
      let resultData = result.data as RichContactInfo;
      this.contacts = resultData;
      this.contactId = Number.parseInt(resultData.contactID);
      // 畅联信息
      let deviceList = this.filterFamilyDevice(this.contacts.meeTimeAbilityInfoModel.meeTimeDeviceInfoModelArr)
      this.updateIsHasNotFamilyDeviceFlag(deviceList,
        this.contacts.meeTimeAbilityInfoModel.meeTimeDeviceInfoModelArr);
      // 刷入家庭设备信息
      this.meeTimeDeviceList.refresh(deviceList);
      this.shareContent = this.shareContentStr();
      // 分享按钮
      this.canBeShared = !StringUtil.isEmpty(this.shareContent);
      // displayName展示
      if (this.contacts.display_name && this.contacts.display_name.length > 0) {
        this.displayName = this.formatContactNameIfIsPhone(this.contacts.display_name, this.contacts.phones);
      } else if (this.contacts.phones.length) {
        const phone = this.contacts.phones[0];
        this.displayName = PhoneNumber.fromString(phone.num).dynamicPhoneFormat();
      } else {
        HiLog.e(TAG, 'get empty display_name, contact id:' + contactId);
        this.displayName = $r('app.string.noName');
      }
      // 头像颜色
      this.contactForm.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(resultData.contactID)) % 6];
      // 背景颜色
      this.contactForm.detailsBgColor =
        MorandiColor.detailColor[Math.abs(Number.parseInt(resultData.contactID, 10)) % 6];
      // 详情颜色
      this.detailsColor = MorandiColor.color[Math.abs(Number.parseInt(resultData.contactID, 10)) % 6];
      // 收藏状态
      this.isFavorited = this.contacts.favorite?.toString();
      // 电话铃声铃音库路径
      this.contactForm.personalRingtone = this.contacts.personalRingtone;
      // 电话铃声文件路径
      this.contactForm.personalRingtonePath = this.contacts.personalRingtonePath;
      // 电话铃声名字
      this.contactForm.personalNotificationRingtone = this.contacts.personalNotificationRingtone;
      //TODO 延时获取
      setTimeout(() => {
        this.refreshPhotoMapById(resultData.contactID);
      }, 200);
      // 手机号、email、aims、houses、events、relationships
      this.getLabelNameByTypeId();
      // 刷新各模块datasource
      this.dealContactsToForm();
      // 获取通话记录
      this.getContactCallLog();
      // 畅连能力
      this.meeTimeAbilityInfoModel = this.contacts.meeTimeAbilityInfoModel;
      this.imageUrlMeetime = this.meeTimeAbilityInfoModel.extra3;
      this.updateMeeTimeAbility(this.meeTimeAbilityInfoModel);
      // 异步的调用畅连接口，查询畅连能力，动态更新最新的畅连能力，然后查询最新的畅连能力
      this.syncAndUpdateMeeTimeAbility(this.contactId, resultData.phones);
      hiTraceMeter.finishTrace(TraceConstants.TRACE_DETAIL_GET_DETAIL, TraceConstants.TRACE_DETAIL_GET_DETAIL_ID);
      this.refreshDetailUI();
      this.isContactDataReady = true;
      this.printDetailInfo(this.contacts);
      this.printMeeTimeAbilityInfo(this.meeTimeAbilityInfoModel, 'after getContactDetail');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'getContactDetail failed. Cause: %s', error.message);
    });
  }

  private updateIsHasNotFamilyDeviceFlag(deviceListFamily: MeeTimeDeviceInfoModel[],
    deviceListTotal: MeeTimeDeviceInfoModel[]) {
    if (!(deviceListTotal instanceof Array)) {
      return;
    }
    // 全部为家庭设备
    if (deviceListTotal && deviceListTotal.length == deviceListFamily.length) {
      this.isHasNotFamilyDeviceFlag = false;
    } else {
      this.isHasNotFamilyDeviceFlag = true;
    }
    HiLog.i(TAG, `device totallen: ${deviceListTotal.length}, fimalyLen: ${
    deviceListFamily.length}, ${this.isHasNotFamilyDeviceFlag}`);
  }

  printDetailInfo(data: RichContactInfo) {
    HiLog.w(TAG, `printDetailInfo start!`);
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    queryUniqueKeyByContactId(context, data.contactID).then((rawIdMap) => {
      HiLog.w(TAG, `printDetailInfo, contactId: ${data.contactID}, name: ${StringUtil.maskSensitiveInfo(data.display_name)}`);
      rawIdMap.forEach((uniqueKey, rawId) => {
        HiLog.w(TAG, `printDetailInfo, contactId: ${data.contactID}, rawId: ${rawId}, uniqueKey: ${uniqueKey}`);
      })
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `printDetailInfo, err: ${err.message}`);
    }).finally(() => {
      data.phones.forEach((phone) => {
        HiLog.w(TAG, `printDetailInfo, labelId: ${phone.numType}, labelName: ${
        StringUtil.maskSensitiveInfo(phone.selectTextCustom)}, phoneNumber: ${StringUtil.maskSensitiveInfo(phone.num)}`);
      })
      data.events.forEach((event) => {
        HiLog.w(TAG, `printDetailInfo, labelId: ${event.eventType}, labelName: ${
        StringUtil.maskSensitiveInfo(event.eventName)}, event: ${event.data.replaceAll('-', '')}`);
      })
      HiLog.w(TAG, `printDetailInfo end!`);
    })
  }

  printMeeTimeAbilityInfo(data: MeeTimeAbilityInfoModel, businessStr: string = '') {
    HiLog.w(TAG, `${businessStr} printMeeTimeAbilityInfo ability: ${
    data.extra4}, number: ${StringUtil.maskSensitiveInfo(data.phoneNumber)}`);
  }

  refreshPhotoMapById(contactId: string) {
    let oldBlobsource = PixelMapManager.getInstance().getBlobSourceById(contactId);

    PixelMapManager.getInstance().deleteMiniPixelMap(contactId);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactIdWithBlobNotNull', {
        'contactIds': [contactId]
      }, (result: ContactBlobSource[]) => {
        if (result) {
          let map = new Map<string, ContactBlobSource>();
          result.forEach((item: ContactBlobSource) => {
            if (contactId == item.contactId) {
              map.set(item.contactId, item);
              if (item.blobSource != oldBlobsource) {
                AppStorage.setOrCreate('contactsWithModifiedPhoto', contactId + '-' + new Date().getTime());
              }
            }
          })
          PixelMapManager.getInstance().updateBlobSourceMap(map, [contactId]);
        }

        this.requestPhotoById(contactId);
      });
  }

  requestPhotoById(contactId: string) {
    HiLog.i(TAG, `requestPhotoById ${contactId}`);
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let needPosterImg = true;
    this.blobSource = PixelMapManager.getInstance().getBlobSourceById(contactId);
    getPixelMapFromFile(contactId, (res: PixelMap | null) => {
      let blobSource = PixelMapManager.getInstance().getBlobSourceById(contactId);
      this.blobSource = blobSource;
      HiLog.i(TAG, `requestPhotoById id:${contactId}, blobSource:${blobSource} res:${res?.getPixelBytesNumber()}`);
      if (blobSource == 3) {
        this.cardPhotoPixelMap = res;
        this.refreshSystemBar?.();
        this.updateLightColor();
      } else {
        this.photoPixelMap = res;
        this.cardPhotoPixelMap = null;
      }
    }, context, needPosterImg);

    if (this.blobSource == 3) {
      getPhotoPixelMapFromDB(contactId, (res: PixelMap | null) => {
        this.photoPixelMap = res;
        HiLog.i(TAG, `getPhotoPixelMapFromDB id:${contactId}, res:${res?.getPixelBytesNumber()}`);
      }, context);
    }
  }

  /**
   * 动态变更最新的畅连能力，动态变更页面的畅连能力展示
   * @param meeTimeAbilityInfoModel
   */
  updateMeeTimeAbility(meeTimeAbilityInfoModel: MeeTimeAbilityInfoModel) {
    AppStorage.setOrCreate('isMeeTimeAbility', true);
    this.isHasMeeTimeAbilityFlag = meeTimeAbilityInfoModel.extra4 > 0 ? true : false;
    this.meeTimeAbilityBinary = meeTimeAbilityInfoModel.extra4Binary;
  }

  /**
   * 调用畅连接口，更新畅连能力到数据库，重新从数据库查询畅连能力
   */
  syncAndUpdateMeeTimeAbility(contactId: number, phoneNumBeans: PhoneNumBean[]) {
    if (ArrayUtil.isEmpty(phoneNumBeans)) {
      return;
    }

    this.isMeeTimeLogin().then(isLogin => {
      this.isMeeTimeLoginFlag = isLogin;
      // 如果有登录畅连，才查询畅连能力
      if (!this.isMeeTimeLoginFlag) {
        HiLog.w(TAG, 'no login meetime, not query meetiem ability by idl');
        return;
      }

      // 如果有网络，才进行畅连接口查询，更新最新畅连能力
      connection.hasDefaultNet().then(hasNetFlag => {
        if (!hasNetFlag) {
          HiLog.w(TAG, 'no net work, not query meetiem ability by idl');
          return;
        }

        // 通过idl查询畅连能力
        // query
        this.syncMeeTimeAbility(contactId, phoneNumBeans).then(syncResult => {
          HiLog.i(TAG, 'query meetime ability response ')
          // 没有对应联系人，说明是仅有电话号码，通过返回值判断能力
          if (contactId == DetailPresenter.NOT_EXIST_CONTACT_ID) {
            this.updateMeetimeAbilityStranger(syncResult, contactId);
            return;
          }

          HiLog.i(TAG, 'query meetime ability response contact query db update meetime ability');
          // 存在联系人id
          // 重新查询畅连能力，替换现在的畅连能力
          ContactsGlobalThisHelper.GetGlobalThis()
            .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
            .sendRequest('getContactMeeTimeAbilityById', {
              context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              contactId: contactId
            }, (result: ContactReturnObj) => {
              if (ObjectUtil.isEmpty(result.data)) {
                return;
              }
              let newMeeTimeAbilityInfoModel = result.data?.meeTimeAbilityInfoModel
              newMeeTimeAbilityInfoModel = newMeeTimeAbilityInfoModel ==
                undefined ? new MeeTimeAbilityInfoModel() : newMeeTimeAbilityInfoModel;
              // 更新最新的畅连能力，如果畅连能力变更，需要更新页面
              if (this.meeTimeAbilityInfoModel.extra4 != newMeeTimeAbilityInfoModel.extra4) {
                this.updateMeeTimeAbility(newMeeTimeAbilityInfoModel);
                let deviceList = this.filterFamilyDevice(newMeeTimeAbilityInfoModel.meeTimeDeviceInfoModelArr)
                this.updateIsHasNotFamilyDeviceFlag(deviceList,
                  newMeeTimeAbilityInfoModel.meeTimeDeviceInfoModelArr);
                this.meeTimeDeviceList.refresh(deviceList);
              }
              if (this.imageUrlMeetime !== this.meeTimeAbilityInfoModel.extra3) {
                this.imageUrlMeetime = this.meeTimeAbilityInfoModel.extra3;
              }
              this.meeTimeAbilityInfoModel = newMeeTimeAbilityInfoModel;
              this.printMeeTimeAbilityInfo(this.meeTimeAbilityInfoModel, 'after syncAbility reQuery ');
            });
        })
      })

    })

  }

  /**
   * 陌生人，更新畅连能力信息
   */
  public updateMeetimeAbilityStranger(syncResult: string, contactId: number) {
    let emptyFlag = StringUtil.isEmpty(syncResult);
    HiLog.i(TAG, 'query meetime ability response stranger, emptyFlag:' + emptyFlag);
    if (emptyFlag) {
      return;
    }
    // 畅联接口返回的畅联能力信息
    let capabilityInfo: CapabilityInfo = JSON.parse(syncResult)
    // 根据畅连能力更新
    let meeTimeAbilityInfoModelNew: MeeTimeAbilityInfoModel =
      new MeeTimeAbilityInfoModel(capabilityInfo.accountId, // 账号id
        capabilityInfo.nickName, // 昵称
        '', // 头像地址
        capabilityInfo.hasVoice * 4 + capabilityInfo.hasVideo * 2 + capabilityInfo.hasMessage * 1// 能力
      )

    meeTimeAbilityInfoModelNew.phoneNumber =
      capabilityInfo.phoneNumber == undefined ? '' : capabilityInfo.phoneNumber;
    // 如果响应号码以+86开头，去掉开头的+86
    if (meeTimeAbilityInfoModelNew?.phoneNumber.startsWith(Constants.PREFIX_OF_PHONE_NUMBER)) {
      meeTimeAbilityInfoModelNew.phoneNumber = meeTimeAbilityInfoModelNew.phoneNumber.substring(
        meeTimeAbilityInfoModelNew.phoneNumber.indexOf(Constants.PREFIX_OF_PHONE_NUMBER) +
        Constants.PREFIX_OF_PHONE_NUMBER.length);
    }
    meeTimeAbilityInfoModelNew.contactId = contactId;

    let meeTimeDeviceInfoModelList: MeeTimeDeviceInfoModel[] = [];
    if (capabilityInfo.allDeviceList != undefined) {
      capabilityInfo.allDeviceList.forEach(element => {
        let meeTimeDeviceInfoModel: MeeTimeDeviceInfoModel =
          new MeeTimeDeviceInfoModel(element.deviceComId, element.deviceType, element.profile)
        meeTimeDeviceInfoModelList.push(meeTimeDeviceInfoModel);
      })
    }
    // 判断是否所有设备均为家庭设备
    meeTimeAbilityInfoModelNew.meeTimeDeviceInfoModelArr = meeTimeDeviceInfoModelList;
    let deviceListFamily = this.filterFamilyDevice(meeTimeAbilityInfoModelNew.meeTimeDeviceInfoModelArr);
    this.updateIsHasNotFamilyDeviceFlag(deviceListFamily,
      meeTimeAbilityInfoModelNew.meeTimeDeviceInfoModelArr);

    // 更新最新的畅连能力，如果畅连能力变更，需要更新页面
    if (this.meeTimeAbilityInfoModel.extra4 != meeTimeAbilityInfoModelNew.extra4) {
      this.updateMeeTimeAbility(meeTimeAbilityInfoModelNew);
    }
    this.meeTimeAbilityInfoModel = meeTimeAbilityInfoModelNew;
    // 陌生人打印畅连能力
    this.printMeeTimeAbilityInfo(this.meeTimeAbilityInfoModel, 'stranger ');
  }

  /**
   * 调用畅连接口，更新数据库畅连能力信息; 如果返回0，表示调用畅连接口，更新畅连能力成功
   * @returns
   */
  syncMeeTimeAbility(contactId: number, phoneNumBeans: PhoneNumBean[]): Promise<string> {
    HiLog.w(TAG, 'call meetime idl meetimeAbility: ' + phoneNumBeans.length);
    let recordList: Record<string, string | number>[] = [];

    phoneNumBeans.forEach((element) => {
      let record: Record<string, string | number> = {
        'phoneNumber': element.num,
        'hasMeeTimeCap': (element.meeTimeAbilityFlag === '' || element.meeTimeAbilityFlag === undefined)
          ? DetailPresenter.PHONE_NUMBER_HAS_NO_MEETIME_ABILIBY_FLAG : Number.parseInt(element.meeTimeAbilityFlag)
      }

      recordList.push(record);

    });

    return MeeTimeService.syncContactMeeTimeAbility(contactId, recordList);

  }

  dealDetailsData() {
    HiLog.w(TAG, 'deal detail data');
    this.getLabelNameByTypeId();
    this.dealContactsToForm();
    // 获取通话记录
    this.getContactCallLog();
  }

  /**
   * 根据select框的typeId，获得对应的lableName；如果typeId为10000，即自定义select，从数据库表中拿到lableName文本
   * 将labelName信息设置到联系人对象对应的信息中
   */
  getLabelNameByTypeId() {

    if (this.contacts.phones.length > 0) {
      this.contacts.phones.forEach((element) => {
        if (Number.parseInt(element.numType) == PhoneAccountType.TYPE_ID_CUSTOM) {
          element.labelName = element.selectTextCustom;
        } else {
          element.labelName = Phone.getTypeLabelResource(Number.parseInt(element.numType, 10));
        }

        element.phoneAddress = element.phoneAddress == 'N' || StringUtil.isEmpty(element.phoneAddress?.toString()) ?
          $r('app.string.unknown') : element.phoneAddress;
      });
    }
    if (this.contacts.emails.length > 0) {
      this.contacts.emails.forEach((element) => {
        if (Number.parseInt(element.emailType) == PhoneAccountType.TYPE_ID_CUSTOM) {
          element.labelName = element.selectTextCustom;
        } else {
          element.labelName = Email.getTypeLabelResource(Number.parseInt(element.emailType, 10));
        }
      });
    }
    if (this.contacts.aims.length > 0) {
      this.contacts.aims.forEach((element) => {
        if (Number.parseInt(element.aimType) == PhoneAccountType.TYPE_ID_CUSTOM) {
          element.labelName = element.selectTextCustom;
        } else {
          element.labelName = Aim.getTypeLabelResource(Number.parseInt(element.aimType, 10));
        }

      });
    }
    if (this.contacts.houses.length > 0) {
      this.contacts.houses.forEach((element) => {
        if (Number.parseInt(element.houseType) == PhoneAccountType.TYPE_ID_CUSTOM) {
          element.labelName = element.selectTextCustom;
        } else {
          element.labelName = House.getTypeLabelResource(Number.parseInt(element.houseType, 10));
        }
      });
    }
    if (this.contacts.events.length > 0) {
      this.contacts.events.forEach((element) => {
        element.labelName = Birthday.getTypeLabelResource(Number.parseInt(element.eventType, 10));
      });
    }
    if (this.contacts.relationships.length > 0) {
      this.contacts.relationships.forEach((element) => {
        if (Number.parseInt(element.associatedType) == PhoneAccountType.TYPE_ID_CUSTOM) {
          element.labelName = element.selectTextCustom;
        } else {
          element.labelName = Relation.getTypeLabelResource(Number.parseInt(element.associatedType, 10));
        }

      });
    }
  }

  //format detail phone number
  formatContactNameIfIsPhone(contactName: string, phones: PhoneNumBean[]) {
    let resultName: string = contactName;
    if (phones !== undefined && phones.length > 0) {
      // noName user must format phone
      let isSamePhoneName: boolean = phones.some((item: LooseObject) => PhoneNumber.fromString(item.num)
        .getNumber() == contactName);
      if (isSamePhoneName) {
        resultName = PhoneNumber.fromString(contactName).dynamicPhoneFormat();
      }
    }
    return resultName;
  }

  /**
   * dealContactsToForm
   * 将数据库查出来的联系人详情，转换为 ContactFormModel 类型
   */
  dealContactsToForm() {
    let newContact = this.contacts;
    let markingInfoList: BaseContackSubInfoModel[] = [];
    this.contactForm.displayName = (newContact.display_name && newContact.display_name.length > 0)
      ? newContact.display_name : $r('app.string.noName');
    this.contactForm.photoFirstName = (newContact.photoFirstName && newContact.photoFirstName.length > 0)
      ? newContact.photoFirstName.toUpperCase() : '-1';
    this.contactForm.company = (newContact.company && newContact.company.length > 0)
      ? newContact.company : '';
    this.contactForm.position = (newContact.position && newContact.position.length > 0)
      ? newContact.position : '';
    this.contactForm.remarks = (newContact.remarks && newContact.remarks.length > 0)
      ? newContact.remarks : '';
    if (newContact.phones && newContact.phones.length > 0) {
      this.uniqueData['phones'].clear();
      this.contactForm.phones = [];
      for (let item of newContact.phones) {
        let itemtemp: ContackPhoneSubInfoModel = {
          data: PhoneNumber.fromString(item.num).getNumber(),
          num: item.num,
          type: item.numType,
          phoneAddress: item.phoneAddress,
          labelName: item.labelName,
          primary: item.primary,
          dataId: item.dataId,
          formatNum: item.formatNum
        }
        if (StringUtil.isEmpty(itemtemp.data)) {
          continue;
        }
        if (!this.uniqueData['phones'].has(itemtemp.data)) {
          this.uniqueData['phones'].add(itemtemp.data);
          if (this.contactForm.phones) {
            if (itemtemp.primary == true) {
              this.contactForm.phones.splice(0, 0, itemtemp);
            } else {
              this.contactForm.phones.push(itemtemp);
            }
          } else {
            this.contactForm.phones = [itemtemp];
          }

        }
      }
      this.phoneDataSources.refresh(this.contactForm.phones);
    }

    if (newContact.emails && newContact.emails.length > 0) {
      this.uniqueData['emails'].clear();
      for (let item of newContact.emails) {
        let itemtemp: BaseContackSubInfoModel = {
          data: item.address,
          type: item.emailType,
          dataType: DataItemType.EMAIL,
          labelName: item.labelName
        }
        if (StringUtil.isEmpty(itemtemp.data)) {
          continue;
        }
        if (!this.uniqueData['emails'].has(itemtemp.data)) {
          this.uniqueData['emails'].add(itemtemp.data);
          if (this.contactForm.emails) {
            this.contactForm.emails.push(itemtemp);
          } else {
            this.contactForm.emails = [itemtemp]
          }
          markingInfoList.push(itemtemp)
        }
      }
      this.detailInfoRemarksSources.refresh(markingInfoList);
    }

    if (newContact.aims && newContact.aims.length > 0) {
      this.uniqueData['aims'].clear();
      for (let item of newContact.aims) {
        let itemtemp: BaseContackSubInfoModel = {
          data: item.aimName,
          type: item.aimType,
          dataType: DataItemType.IM,
          labelName: item.labelName
        };
        if (StringUtil.isEmpty(itemtemp.data)) {
          continue;
        }
        const typeStr = itemtemp.type ? itemtemp.type : '';
        let markStr = itemtemp.data + typeStr;
        if (!this.uniqueData['aims'].has(markStr)) {
          this.uniqueData['aims'].add(markStr);
          if (this.contactForm.aims) {
            this.contactForm.aims.push(itemtemp);
          } else {
            this.contactForm.aims = [itemtemp]
          }
          markingInfoList.push(itemtemp)
        }
      }
      this.detailInfoRemarksSources.refresh(markingInfoList);
    }

    // 网站展示，支持多条展示
    if (newContact.websites && newContact.websites.length > 0) {
      this.uniqueData['websites'].clear();
      for (let item of newContact.websites) {
        let itemtemp: BaseContackSubInfoModel = {
          data: item,
          dataType: DataItemType.WEBSITE,
          labelName: $r('app.string.website')
        };
        if (StringUtil.isEmpty(itemtemp.data)) {
          continue;
        }
        if (!this.uniqueData['websites'].has(itemtemp.data)) {
          this.uniqueData['websites'].add(itemtemp.data);
          if (this.contactForm.websites) {
            this.contactForm.websites.push(itemtemp);
          } else {
            this.contactForm.websites = [itemtemp]
          }
          markingInfoList.push(itemtemp)
        }
      }
      this.detailInfoRemarksSources.refresh(markingInfoList);
    }

    if (newContact.houses && newContact.houses.length > 0) {
      this.uniqueData['houses'].clear();
      for (let item of newContact.houses) {
        let itemtemp: BaseContackSubInfoModel = {
          data: item.houseName,
          type: item.houseType,
          dataType: DataItemType.SIP_ADDRESS,
          labelName: item.labelName
        };
        if (StringUtil.isEmpty(itemtemp.data)) {
          continue;
        }
        if (!this.uniqueData['houses'].has(itemtemp.data)) {
          this.uniqueData['houses'].add(itemtemp.data);
          if (this.contactForm.houses) {
            this.contactForm.houses.push(itemtemp);
          } else {
            this.contactForm.houses = [itemtemp]
          }
          markingInfoList.push(itemtemp)
        }
      }
      this.detailInfoRemarksSources.refresh(markingInfoList);
    }

    if (newContact.events && newContact.events.length > 0) {
      this.uniqueData['events'].clear();
      const numExp = new RegExp('[0-9]', 'g')
      for (let item of newContact.events) {
        let itemtemp: BaseContackSubInfoModel = {
          data: item.data,
          type: item.eventType,
          dataType: DataItemType.EVENT,
          labelName: item.labelName,
          calendarEventId: item.calendarEventId,
          contactDataId: item.contactDataId
        };
        if (StringUtil.isEmpty(itemtemp.data)) {
          continue;
        }
        if (StringFormatUtil.checkEventValid2(itemtemp.data)) {
          itemtemp.data = itemtemp.data?.replaceAll('/', '-')
        } else if (StringFormatUtil.checkEventValid(itemtemp.data)) {
          HiLog.i(TAG, 'default size eventData');
        } else {
          let printStr = itemtemp.data?.replace(numExp, '*');
          HiLog.w(TAG, `event data not valid. data:${printStr}`)
          continue;
        }
        if (!this.uniqueData['events'].has(`${item.labelName?.id}-${itemtemp.data}`)) {
          this.uniqueData['events'].add(`${item.labelName?.id}-${itemtemp.data}`);
          if (this.contactForm.events) {
            this.contactForm.events.push(itemtemp);
          } else {
            this.contactForm.events = [itemtemp]
          }
          markingInfoList.push(itemtemp)
        }
      }
      this.detailInfoRemarksSources.refresh(markingInfoList);
    }

    if (newContact.relationships && newContact.relationships.length > 0) {
      this.uniqueData['relationships'].clear();
      for (let item of newContact.relationships) {
        let itemtemp: BaseContackSubInfoModel = {
          data: item.name,
          type: item.associatedType,
          dataType: DataItemType.RELATION,
          labelName: item.labelName
        };
        if (StringUtil.isEmpty(itemtemp.data)) {
          continue;
        }
        const typeStr = itemtemp.type ? itemtemp.type : '';
        let markStr = itemtemp.data + typeStr;
        if (!this.uniqueData['relationships'].has(markStr)) {
          this.uniqueData['relationships'].add(markStr);
          if (this.contactForm.relationships) {
            this.contactForm.relationships.push(itemtemp);
          } else {
            this.contactForm.relationships = [itemtemp]
          }
          markingInfoList.push(itemtemp)
        }
      }
      this.detailInfoRemarksSources.refresh(markingInfoList);
    }
  }

  //删除联系人时从日历数据库中删除对应的联系人生日日程
  async delCalendarEvent() {
    if (this.contacts.events.length > 0) {
      let calendarManager = await DynamicLoadSoUtil.getInstance().loadCalendarManager();
      let bundleManager = await DynamicLoadSoUtil.getInstance().loadBundleManager();
      this.calendarManager = calendarManager?.default?.getCalendarManager(
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      );
      const calendarAccount: LooseObject = {
        name: bundleManager?.default?.getBundleInfoForSelfSync(
          bundleManager?.default?.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).name,
        type: calendarManager?.default?.CalendarType.BIRTHDAY
      };
      let events: number[] = []
      this.contacts.events.forEach(item => {
        if (item.calendarEventId) {
          events.push(Number(item.calendarEventId))
        }
      })
      if (events.length > 0) {
        this.calendarManager?.getCalendar(calendarAccount).then((getData: LooseObject) => {
          HiLog.i(TAG, `Succeeded in getting calendar`);
          getData.deleteEvents(events).then(() => {
            HiLog.i(TAG, `Succeeded in deleting events`);
          }).catch((err: BusinessError) => {
            HiLog.e(TAG, `Failed to delete events. Code: ${err.code}, message: ${err.message}`);
          });
        }).catch((err: BusinessError) => {
          HiLog.e(TAG, `Failed to get calendar Code: ${err.code}, message: ${err.message}`);
        });
      }
    }
  }

  async getContactCallLog() {
    HiLog.i(TAG, 'get Contact CallLog');
    if (this.isMyCard) {
      HiLog.w(TAG, 'isMyCard, no need get contact callLog');
      return;
    }
    if (!ArrayUtil.isEmpty(this.contactForm.phones)) {
      let numbers: Set<string> = new Set();

      let regexp: RegExp = new RegExp('\\s+', 'g');
      this.contactForm.phones.forEach(element => {
        let phoneNumber = element.data?.replace(regexp, '')
        if (!StringUtil.isEmpty(phoneNumber)) {
          numbers.add(phoneNumber as string);
        }
      });

      /* All call records of all phone numbers of the contact are obtained. */
      this.refreshAllCallRecords(Array.from(numbers), this.contactId);
      /* Encapsulate the attributes required on the detail page based on the obtained raw call record data. */
    }
    // Processing Initialization Data
    const displayName = this.contactForm.displayName.toString();
    this.showNameLastMenu = displayName.length > 6
      ? this.subStringWithEllipsis(displayName, 7) : displayName;

  }

  async getRecorderMessage(start: number, callDetailList: CallDetail[], isEnd: boolean) {
    let param: LooseObject = {
      callDetailList: callDetailList
    };
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getRecorderMessage', param, (result: CallDetail[]) => {
        this.showLogTitleFlagRefreshFun(result.length);
        this.detailCallLogDataSource.refresh(start, result, isEnd);
      });
  }

  // Obtains call records and assembles parameters when the call is not a contact.
  async getNewNumCallLog() {
    // 先清空一下所有元素
    this.resetContactForm();

    this.isNewDetail = true;
    HiLog.i(TAG, 'get new number call log');
    let regExp: RegExp = new RegExp('\\s+', 'g');
    let numbers: string[] = [this.phoneNumberShow.replace(regExp, '')];
    let formatNum = PhoneNumber.fromString(this.phoneNumberShow).getNumber();
    this.contactForm.displayName = StringFormatUtil.clearPhoneNumberSymbols(formatNum);

    /* Creating a Contact Phone List Object */
    // 显示电话号信息
    let itemtemp: ContackPhoneSubInfoModel = {
      id: '0',
      data: formatNum,
      num: this.phoneNumberShow,
      type: '1',
      labelName: $r('app.string.phone_type_mobile'),
      phoneAddress: $r('app.string.unknown'),
    }
    this.contactForm.phones = [itemtemp];
    this.contactForm.portraitColor = MorandiColor.color[0];
    this.contactForm.detailsBgColor = MorandiColor.detailColor[0];
    this.newNumberBgColor = MorandiColor.color[0];
    // 查询黄页
    let contact = await this.queryYellowPage(
      this.phoneNumberShow.replace(regExp, ''), ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    this.transmitYellowPage(contact, numbers);
    this.updatePhoneNums?.();
    this.phoneDataSources.refresh(this.contactForm.phones);

    // 从通话页面，无对应联系人信息，只有电话信息进入详情，查询畅连能力
    HiLog.i(TAG, 'query meetime ability when get new number call log');
    let phoneNumBean: PhoneNumBean = new PhoneNumBean('', formatNum, '', '', '');
    // 查询联系人详情页的通话记录
    this.refreshAllCallRecords(numbers);
    if (this.detailCallLogDataSource.totalCount() > 0) {
      let bgColorId = Math.abs(Number.parseInt(this.detailCallLogDataSource.getData(0)?.callLog?.id, 10));
      this.contactForm.portraitColor = MorandiColor.color[bgColorId % 6];
      this.contactForm.detailsBgColor = MorandiColor.detailColor[bgColorId % 6];
      this.newNumberBgColor = MorandiColor.color[bgColorId % 6];
    } else {
      HiLog.w(TAG, 'callLog totalCount = 0');
    }
    this.phoneDataSources.refresh(this.contactForm.phones);

    // 无联系人的情况，联系人id传-1
    this.syncAndUpdateMeeTimeAbility(DetailPresenter.NOT_EXIST_CONTACT_ID, [phoneNumBean]);
  }

  public transmitYellowPage(contact: Map<string, string> | undefined, numbers: string[]) {
    if (contact && contact.size > 0) {
      contact.forEach((value, key) => {
        let regExp1: RegExp = new RegExp('0[1-2][0-9]' + key);
        let regExp2: RegExp = new RegExp('0[3-9][0-9][0-9]' + key);
        if (numbers[0] === key || regExp1.test(numbers[0]) || regExp2.test(numbers[0])) {
          // 根据黄页设置displayName
          this.displayName = value;
          this.displayNameQueryByYellowPageFlag = true;
          this.contactForm.displayName = value;
          this.contactForm.phones[0].num = key;
          this.contactForm.phones[0].data = PhoneNumber.fromString(key).getNumber();
          this.contactForm.phones[0].labelName = value;
          numbers.push(key);
          return;
        } else {
          numbers.push(key);
        }
        let itemtemp: ContackPhoneSubInfoModel = {
          id: '0',
          data: PhoneNumber.fromString(key).getNumber(),
          num: key,
          type: '10000',
          labelName: value,
          phoneAddress: $r('app.string.unknown')
        };
        this.contactForm.phones.push(itemtemp);
      });
    }
  }

  async addRecorderDataHelperListener() {
    this.callRecordListenerCallback = () => {
      this.limitDataRefresh?.requestItem();
      HiLog.i(TAG, 'callRecorderHelper addRecorderDataHelperListener end');
    }
    let uri = Calls.CALL_RECORDER_LOG_PROXY_URI;
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let callRecorderHelper: dataShare.DataShareHelper = await dataShare.createDataShareHelper(context, uri);
    this.callRecorderHelper = callRecorderHelper;
    callRecorderHelper.on('dataChange', uri, this.callRecordListenerCallback);
  }

  removeRecorderDataHelperListener() {
    let uri = Calls.CALL_RECORDER_LOG_PROXY_URI;
    if (this.callRecorderHelper) {
      this.callRecorderHelper.off('dataChange', uri, this.callRecordListenerCallback);
      this.callRecordListenerCallback = undefined;
    }
  }

  /**
   * Query YellowPage
   * @param {Object} queryYellowPage phone numbers
   * @param {Object} context
   * @param {Object} callBack
   */
  async queryYellowPage(number: string, context: common.UIAbilityContext): Promise<Map<string, string>> {
    return new Promise((resolve) => {
      let task = new taskpool.Task(queryYellowPageByNumber, context, number);
      taskpool.execute(task).then((contactInfos: Object) => {
        let numberMap: Map<string, string> = new Map();
        (contactInfos as ContactNameNumberInfo[]).forEach(item => {
          if (!StringUtil.isEmpty(item.name)) {
            numberMap.set(item.phoneNumber, item.name);
          }
        })
        resolve(numberMap);
      })
    })
  }

  /**
   * Data required for converting the original
   * callLogList content into call record details
   *
   * @param {Array} originList Original Call List
   * @return {Array} resultList
   */
  getDetailMessage(originList: CallLog[]) {
    const resultList: CallDetail[] = [];
    if (ArrayUtil.isEmpty(originList)) {
      return resultList;
    }
    let now: Date = new Date();
    DateTimeFormat.getInstance().initDateTimeFormat();
    originList.forEach(element => {
      resultList.push(this.getCallDetailByCallLog(element, now));
    });
    DateTimeFormat.getInstance().unInitDateTimeFormat();
    return resultList;
  }

  getCallDetailByCallLog(element: CallLog, now: Date) {
    let callTimeDetail = this.getTimeDetailByCallTime(element, now);
    let contactDetailCallsItem = new CallDetail(element.id.toString(), element.phoneNumber,
      element.displayName,
      element.createTime.toString(), element.beginTime.toString(),
      element.callType, element.numberLocation, element.simType.toString(),
      element.simId, element.isSatellite, element.ringDuration,
      element.formattedNumber, this.getTalkTimeMessage(element),
      element.talkDuration,
      callTimeDetail.date, callTimeDetail.time, element.features, element.celiaCallType, element.newCalling,
      element.abstractProfile, element.absStatus, element.notesId, element.absCode,
      element.notesStatus, element.endTime, element.startTime, element.abstractType);
    return contactDetailCallsItem;
  }

  /**
   * Obtain the call details of the call record according to the call record.
   *
   * @param {Object} callLogElement Call log
   * @return {string} resultMessage Status information
   */
  getTalkTimeMessage(callLogElement: CallLog) {
    let resultMessage: Resource | string | null = null;
    switch (callLogElement.callType) {
      case CallType.IN:
        resultMessage = this.getDescriptionByDuration(callLogElement.talkDuration);
        break;
      case CallType.OUT:
        resultMessage = callLogElement.talkDuration == 0
          ? $r('app.string.blockCall') : this.getDescriptionByDuration(callLogElement.talkDuration);
        break;
      case CallType.MISSED:
        resultMessage = this.getDescriptionByDuration(callLogElement.ringDuration);
        break;
      case CallType.REJECTED:
        resultMessage = $r('app.string.reject');
        break;
      case CallType.OTHER:
        resultMessage = $r('app.string.other_devices_answering_calls');
        break;
      default:
        resultMessage = '';
        break;
    }
    return resultMessage;
  }

  /**
   * Obtains the call duration based on the specified timestamp. The unit is s.
   *
   * @param {number} timeDurationSeconds
   * @return {Object} Return time unit
   */
  getDescriptionByDuration(timeDurationSeconds: number) {
    if (timeDurationSeconds < 60) {
      // Less than one minute
      return $r('app.plural.secondsFormat', timeDurationSeconds, timeDurationSeconds);
    } else {
      let newtimeDurationSeconds = $r('app.plural.secondsFormat', timeDurationSeconds % 60, timeDurationSeconds % 60);
      let minutes = Math.floor(timeDurationSeconds / 60);
      if (minutes < 60) {
        // Within an hour
        let newMinutes = $r('app.plural.minuteFormat', minutes, minutes)
        return $r('app.string.hous_minute', newMinutes, newtimeDurationSeconds)
      } else {
        let hours = Math.floor(minutes / 60);
        let oldMinutes = Math.floor(minutes % 60);
        let newHours = $r('app.plural.hoursFormat', hours, hours)
        let newMinutes = $r('app.plural.minuteFormat', oldMinutes, oldMinutes);
        return $r('app.string.hous_minute_sec', newHours, newMinutes, newtimeDurationSeconds);
      }
    }
  }

  /**
   * Obtain the time details based on the call record generation time.
   *
   * @param {number} callTime Initial Talk Time
   * @return {string} timeDetail Talk time after processing
   */
  getTimeDetailByCallTime(element: CallLog, now: Date) {
    let callTime = element.showTime.toString();
    let callLogTime = new Date(Number.parseInt(callTime, 10) * 1000);
    // time detail
    let year = callLogTime.getFullYear();
    let mounth = callLogTime.getMonth() + 1;
    let day = callLogTime.getDate();
    let hour = callLogTime.getHours();
    let minutes = callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes().toString();
    // description
    let timeDetail: Record<string, Resource | string | undefined> = {};
    timeDetail.time = StringFormatUtil.getDayMessage(year, mounth, day, hour, minutes, true);
    if (now.getFullYear() - callLogTime.getFullYear() == 0) {
      if (now.getMonth() - callLogTime.getMonth() == 0) {
        if (now.getDate() - callLogTime.getDate() == 0) {
          timeDetail.date = '';
          return timeDetail;
        }
      }
      timeDetail.date = StringFormatUtil.getMonthmessage(year, mounth - 1, day, true);
    } else {
      timeDetail.date = StringFormatUtil.getYearmessage(year, mounth - 1, day, true);
    }
    return timeDetail;
  }

  // Edit Contact；从联系人详情页编辑联系人
  updateContact() {
    HiLog.w(TAG, `updateContact start, markType: ${this.markType}`);
    let phoneNumbers: Record<string, string | undefined>[] = [{
      'phoneNumber': '',
      'phoneAddress': ''
    }];
    let updateDisplayName: string = this.displayName.toString();
    let displayNameHighlight: boolean = false;
    if (this.isNewNumber) {
      phoneNumbers[0].phoneNumber = this.phoneNumberShow;
      phoneNumbers[0].phoneAddress = this.contactForm?.phones[0]?.phoneAddress?.toString();
    }
    let upDataShow = false;
    if (this.contactId != undefined) {
      upDataShow = true
    }
    if (this.isYellowPage) {
      phoneNumbers = [];
      this.contactForm?.phones.forEach(phone => {
        phoneNumbers.push({
          'phoneNumber': phone.num as string,
          'phoneAddress': phone.phoneAddress?.toString(),
          'labelName': phone.labelName?.toString()
        })
      })
      HiLog.i(TAG, 'copy yellow page to cellphone, number length:' + phoneNumbers.length);
    }
    if (!StringUtil.isEmpty(this.markType) && this.markType != NumberMarkUtil.PRE_NONE_PHONE_DESC) {
      if (this.markType == NumberMarkUtil.OTHER_PHONE_DESC ||
        this.markType == NumberMarkUtil.YELLOW_PAGE_PHONE_DESC ||
        this.markType == NumberMarkUtil.PRE_CUSTOM_PHONE_DESC ||
        this.markType == NumberMarkUtil.MARK_TYPE_ENTERPRISE) {
        updateDisplayName = this.markContent;
      } else {
        updateDisplayName = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
          .resourceManager.getStringSync(NumberMarkUtil.getNumberMarkInfo(this.markType).id);
      }
      displayNameHighlight = true;
      HiLog.i(TAG, 'updateContact, updateDisplayName:' + updateDisplayName);
    }
    let ringtoneInfo: RingtoneInfo = {
      ringtoneName: this.contactForm.personalNotificationRingtone,
      ringtoneFilePath: this.contactForm.personalRingtonePath,
      ringtonePath: this.contactForm.personalRingtone,
    }
    HiLog.i(TAG, `ringtoneInfo: ringtoneName: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtoneName)},
     ringtoneFilePath: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtoneFilePath)},
      ringtonePath: ${StringUtil.maskSensitiveInfo(ringtoneInfo.ringtonePath)}`);
    let contacts: AccountantParams = {
      updataShow: upDataShow,
      sourceHasParam: this.sourceHasParam,
      contactId: Number(this.contactId),
      nameRawContactId: Number(this.contacts.rowContactID),
      phoneNumbers: phoneNumbers,
      disPlayName: updateDisplayName,
      displayNameHighlight: displayNameHighlight,
      relationships: this.contacts.relationships,
      ringtoneInfo: ringtoneInfo,
      isEditMyCard: this.isMyCard,
      avtarDeletedCallBack: () => {
        this.photoPixelMap?.release();
        this.photoPixelMap = null;
        this.cardPhotoPixelMap?.release();
        this.cardPhotoPixelMap = null;
      }
    } as AccountantParams;
    this.params = contacts;
  }

  async clearMissedCallNotificationForCurrentContact() {
    if (ArrayUtil.isEmpty(this.contactForm.phones) || this.contactForm.phones.length < 0) {
      HiLog.w(TAG, 'clearMissedCallNotification no data');
      return;
    }
    try {
      let result: Array<MissedCallNotifyData> = [];
      const notifications: Array<Notification.NotificationRequest> =
        await Notification.getActiveNotifications()
      for (let notify of notifications) {
        if (notify.groupName == 'MissedCall' && notify.extraInfo) {
          result.push(notify.extraInfo as MissedCallNotifyData);
        }
      }
      let ctx = ContactsGlobalThisHelper.GetGlobalThis().getDetaultContext();
      let res = $r('app.string.missed_call');
      let resource: resourceManager.Resource = {
        bundleName: res.bundleName,
        moduleName: res.moduleName,
        id: res.id
      }
      let idList: number[] = [];
      let missCount: number = 0;
      let badgeNumber: number = 0;
      result.forEach((item: MissedCallNotifyData) => {
        if (item.count != undefined) {
          badgeNumber += item.count;
        }
        this.contactForm.phones.forEach(phone => {
          if (item.phoneNumber === phone.num) {
            if (item.id) {
              idList.push(item.id)
            }
            if (item.count != undefined) {
              missCount = item.count;
            }
          }
        })
      })
      let label = ctx.resourceManager.getStringSync(resource);
      idList.forEach(id => {
        Notification.cancel(id, label);
      })
      HiLog.w(TAG, `setMissedCallBadgeNumber missCount->${missCount}`);
      badgeNumber -= missCount;
      HiLog.w(TAG, `setMissedCallBadgeNumber badgeNumber->${badgeNumber}`);
      if (badgeNumber >= 0) {
        Notification.setBadgeNumber(badgeNumber);
        sharedPreferencesUtils.saveToPreferences(KEY_MISSED_BADGE_NUM, badgeNumber);
        HiLog.i(TAG, `setMissedCallBadgeNumber put success`);
      }
    } catch (e) {
      HiLog.e(TAG, 'setMissedCallBadgeNumber catch error: ' + (e as BusinessError).message);
    }
  }

  // clear callLog
  clearAllCallLog() {
    let id: number = -1;
    let ids: Array<number> = [];
    let callLogIds: string[] = [];
    for (let index = 0; index < this.detailCallLogDataSource.totalCount(); index++) {
      id = this.detailCallLogDataSource.getData(index)?.callLog?.id;
      ids.push(id);
      if (id != undefined && id != null) {
        callLogIds.push(id.toString());
      }
    }
    this.removeCallLog(ids);
    // 删除通话记录列表DataSource
    let breakpoint = AppStorage.Get('breakpoint') as string;
    if (breakpoint != 'sm') {
      CallRecordPresenter.getInstance().deleteCallrecord(callLogIds);
    }
    this.clearMissedCallNotificationForCurrentContact();
  }

  // Delete call records based on the ID set.
  removeCallLog(ids: number[]) {
    HiLog.w(TAG, 'removeCallLog');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('deleteCallLogsById', {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      ids: ids
    }, (data: number | undefined) => { // DataShareHelper.delete  callback(number); callback();
      HiLog.i(TAG, 'removeCallLog Success');
    });
  }

  backPageByCancelSave(pathInfos?: NavPathStack) {
    // 如果是uiAbiliby页面跳转跳过来的，弹出pop
    pathInfos?.pop();
  }

  // Delete a contact
  doDeleteContact(index: number = -1) {
    HiLog.w(TAG, `doDeleteContact  index: ${index},contactId=${this.contactId}`);
    // 创建帧监听
    let myDisplaySync: displaySync.DisplaySync = displaySync.create();
    let frameIndex = 0;
    let frameCallback = (frameInfo: displaySync.IntervalInfo) => {
      // 第一帧执行 删除操作
      if (frameIndex >= 1) {
        ContactListPresenter.getInstance().handleDelContact(index, this.contactId);
        hiTraceMeter.finishTrace(TraceConstants.TRACE_DETAIL_DEL, TraceConstants.TRACE_DETAIL_DEL_ID);
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('deleteContactById', {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          contactId: this.contactId,
          operationScenario: 'Manually deleting contacts on the details page'
        }, (result: number | undefined) => {
          if (result == 0 || result == undefined) {
            HiLog.w(TAG, 'doDeleteContact succ');
            this.doAfterDelSuccess(result);

            if (this.isMyCard) {
              this.deleteMyCardTotally(this.contactId?.toString());
            }
          }
        });
        HiLog.i(TAG, `doDeleteContact end!`);
        myDisplaySync.stop();
        myDisplaySync.off('frame', frameCallback);
      }
      frameIndex++;
    };
    myDisplaySync.on('frame', frameCallback);
    myDisplaySync.start();
    hiTraceMeter.startTrace(TraceConstants.TRACE_DETAIL_DEL, TraceConstants.TRACE_DETAIL_DEL_ID);
    HiLog.w(TAG, `doDeleteContact start!`);
    // 第二帧执行页面退出行为
    let isFromMeeTimeDetail = AppStorage.get<boolean>('isFromMeeTimeDetail') as boolean;
    if (isFromMeeTimeDetail && this.uiExtensionSession) {
      HiLog.w(TAG, 'From Meetime Delete sendBackMsg');
      this.sendMsgToMeetime(this.uiExtensionSession, 'notifyHostBackPress');
    } else if (this.fromSmsList) {
      this.cancel();
    } else if (!this.pageFlag) {
      this.backPageByCancelSave(this.pathInfos);
    }
  }

  /**
   * 发送消息给畅连
   */
  sendMsgToMeetime(uiExtensionSession: UIExtensionContentSession, actionType: string) {
    HiLog.w(TAG, 'sendMsgToMeetime');
    let msg: Record<string, string> = {
      'action': actionType
    };
    uiExtensionSession?.sendData(msg);
  }

  doAfterDelSuccess(result: number | undefined) {
    hiTraceMeter.startTrace('doAfterDelSuccess', 121);
    SmsManagerUtils.notifyMmsWhenDeleteContact([this.contactId], result === 0 ? 0 : -1);
    AppStorage.setOrCreate<number>('DetailDeleteContact', 1);
    sharedPreferencesUtils.getFromPreferences('speedDialObjString', '')
      .then((speedString: data_preferences.ValueType) => {
        speedString = speedString as string;
        if (!StringUtil.isEmpty(speedString)) {
          let speedDialArr: Record<string, SpeedDialItem | null> = JSON.parse(speedString);
          Object.entries(speedDialArr).forEach(item => {
            // 如果value不为空
            if (item[1] != null) {
              // 解析contactId，如果为当前id，设置对应的value为空
              if (this.contactId == Number(item[1].contactId)) {
                speedDialArr[item[0]] = null;
              }
            }
          });
          sharedPreferencesUtils.saveToPreferences('speedDialObjString', JSON.stringify(speedDialArr));
        }
      });
    // 删除头像信息？
    delFileById(this.contactId?.toString());
    setTimeout(() => {
      this.delCalendarEvent();
    }, 50);
    hiTraceMeter.finishTrace('doAfterDelSuccess', 121);
  }

  deleteMyCardTotally(contactId: string) {
    HiLog.i(TAG, `deleteMyCardTotally id:${contactId}`);
    let contactIdParam: ContactIdParam = {
      context: getContext(this) as common.UIAbilityContext,
      contactId: contactId
    }
    ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('findRawIdById', contactIdParam, (result: number) => {
        let contactRawIdParam: ContactIdsParam = {
          context: getContext(this) as common.UIAbilityContext,
          ids: [result.toString()]
        }
        HiLog.i(TAG, `findRawIdById rawId :${result}`);
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
          .sendRequest('deleteRecycleContactByIds', contactRawIdParam, (result: number) => {
            HiLog.i(TAG, `deleteMyCardTotally result:${result}`);
          })
      })
  }

  // Sending Messages
  sendMessage(phoneNumber: string, formatNum: string, name: string, contactId?: number) {
    let sendName = name == formatNum ? '' : name;
    PhoneNumber.fromString(phoneNumber).sendMessage(formatNum, sendName, contactId);
  }

  /**
   * 打开畅连通话
   */
  linkMeeTimeCall(number: string, contactId: number, deviceComId?: string, deviceType?: number) {
    HiLog.i(TAG, 'into meetimecall');
    MeeTimeService.meeTimeCall(number, contactId, deviceComId, deviceType);
  }

  /**
   * 打开畅连视频
   */
  linkMeeTimeVideo(number: string, contactId: number, deviceComId?: string, deviceType?: number) {
    HiLog.i(TAG, 'into meetimevideo');
    MeeTimeService.meeTimeVideo(number, contactId, deviceComId, deviceType);
  }

  /**
   * 畅联是否登录了，如果畅联没有登录，就不显示畅联能力部分信息
   */
  isMeeTimeLogin(): Promise<boolean> {
    return MeeTimeService.isMeeTimeLogin();
  }

  setPhonePrimary(index: number, primary: boolean) {
    if (ArrayUtil.isEmpty(this.contactForm.phones) || this.contactForm.phones.length <= index || index < 0) {
      HiLog.w(TAG, 'setPhonePrimary no data or index err');
      return;
    }
    const data = this.contactForm.phones[index];
    if (data.primary == primary) {
      HiLog.w(TAG, 'setPhonePrimary data not change');
      return;
    }
    this.contactForm.phones[0].primary = false;
    data.primary = primary;
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('setPrimary', {
      contactId: this.contactId,
      dataType: DataItemType.PHONE,
      dataId: data.dataId,
      primary: primary
    })
    if (primary) {
      this.contactForm.phones.splice(index, 1);
    }
    this.contactForm.phones = this.contactForm.phones.sort((a, b) => {
      if (a.dataId == undefined) {
        return -1
      }
      if (b.dataId == undefined) {
        return 1
      }
      return a.dataId - b.dataId;
    })
    if (primary) {
      this.contactForm.phones.splice(0, 0, data);
    }
    this.phoneDataSources.refresh(this.contactForm.phones);
  }

  changeTopBarBackgroundColor(isTopForItem: boolean) {
    if (isTopForItem) {
      this.topbarBackgroundColor = Color.White;
    } else {
      this.topbarBackgroundColor = Color.Transparent;
    }
  }

  getTopBarBackgroundColor(): ResourceColor {
    return this.topbarBackgroundColor;
  }

  // Truncates the first five characters of the string plus..
  subStringWithEllipsis(str: string, len: number) {
    let newLength = 0;
    let newStr = '';
    let chineseRegex: RegExp = new RegExp('[^\x00-\xff]', 'g');
    let singleChar = '';
    let strLength = str.replace(chineseRegex, '**').length;
    for (let i = 0; i < strLength; i++) {
      singleChar = str.charAt(i).toString();
      if (singleChar.match(chineseRegex) != null) {
        newLength += 2;
      } else {
        newLength++;
      }
      if (newLength > len) {
        break;
      }
      newStr += singleChar;
    }
    newStr += '..';
    return newStr;
  }

  updateFavorite(favoriteStatus: number) {
    HiLog.i(TAG, 'updateFavorite start.');
    let favoriteForm: Record<string, number> = {};
    favoriteForm.id = this.contactId;
    favoriteForm.favorite = favoriteStatus;
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('updateFavorite', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        favoriteForm: JSON.stringify(favoriteForm)
      }, (arg: number) => {
        HiLog.w(TAG, 'updateFavorite success.');
        if ((AppStorage.get('mainTabsIndex') == IndexPresenter.getInstance().favoriteIndex) &&
          (AppStorage.get('breakpoint') !== 'sm')) {
          FavoriteListPresenter.getInstance().requestItem();
          FavoriteListPresenter.getInstance().setPageShow(true);
        }
      })
  }

  saveExistingContact() {
    HiLog.i(TAG, 'updateFavorite start.');
    const params: ContactPickerParam = {
      phoneNumberShow: this.phoneNumberShow,
      isSaveExistContact: true,
      isDisplayByName: true,
    };

    DynamicLoader.getInstance().fire(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE).then(() => {
      this.pathInfos?.pushPathByName('SingleSelectContactPage', params);
    });
  }

  cancel() {
    let parameters: Record<string, string> = {
      'contactObjects': ''
    };
    const wantPara: Record<string, Record<string, string>> = {
      'parameters': parameters
    }
    const result: ability.AbilityResult = {
      'resultCode': 0,
      'want': wantPara
    };

    ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()?.terminateSelfWithResult(result)
      .then(() => {
        HiLog.i(TAG, 'terminateSelfWithResult Operation succeeded: ');
      })
      .catch((error: BusinessError) => {
        HiLog.e(TAG, 'Operation failed. Cause: %s', error.message);
      });
  }

  /**
   * 畅连无网络提示内容
   * @param abilityType
   * @returns
   */
  getNoNetWorkMsg(abilityType: number) {
    let msg = $r('app.string.meetime_audio_connect_net_msg');
    if (abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO) {
      msg = $r('app.string.meetime_audio_connect_net_msg');
    }
    if (abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO) {
      msg = $r('app.string.meetime_video_connect_net_msg');
    }
    if (abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_CHAT) {
      msg = $r('app.string.meetime_chat_connect_net_msg');
    }
    return msg;
  }

  /**
   * 打开对应畅连能力功能
   * @param abilityType
   * @param isFamilyDeviceFlag
   */
  openMeetimeAbility(abilityType: number, isFamilyDeviceFlag: boolean, deviceType?: number, deviceComId?: string) {
    const phoneNumber = this.meeTimeAbilityInfoModel.phoneNumber;
    // 不是家庭设备，不需要传设备id
    if (!isFamilyDeviceFlag) {
      let oldDeviceComId = deviceComId;
      deviceComId = undefined;
      HiLog.w(TAG, `meetime call pnumber: ${StringUtil.maskSensitiveInfo(phoneNumber)}, abilityType: ${abilityType},
       isFamilyDeviceFlag: N, deviceType: ${deviceType}, oldDeviceComId:
        ${StringUtil.maskSensitiveInfo(oldDeviceComId)}, newDeviceComId: ${StringUtil.maskDeviceId(deviceComId)}`);
    } else {
      HiLog.w(TAG, `meetime call pnumber: ${StringUtil.maskSensitiveInfo(phoneNumber)}, abilityType: ${abilityType},
       isFamilyDeviceFlag: Y, deviceType: ${deviceType}, deviceComId: ${StringUtil.maskDeviceId(deviceComId)}`);
    }

    if (abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_AUDIO) {
      this.linkMeeTimeCall(phoneNumber, this.contactId, deviceComId, deviceType);
      return;
    }

    if (abilityType == DetailPresenter.ABILITY_TYPE_AND_INDEX_VIDEO) {
      this.linkMeeTimeVideo(phoneNumber, this.contactId, deviceComId, deviceType);
      return;
    }

    HiLog.e(TAG, 'openMeetimeAbility incorrect abilityType')
  }

  /**
   *  Return to System Desktop
   */
  returnDesktop() {
    let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    context.terminateSelf().then(() => {
      HiLog.i(TAG, 'terminateSelf success');
    }).catch(() => {
      HiLog.e(TAG, 'terminateSelf error');
    })
  }

  /**
   *  Return to System Desktop
   */
  returnDesktopToBackground() {
    window.getLastWindow(getContext(this), (err, data) => {
      const errCode: number = err.code;
      if (errCode) {
        HiLog.e(TAG, 'Failed to obtain the top window. Cause: ' + errCode + ', msg=' + err.message);
        return;
      }
      HiLog.w(TAG, 'minimize success');
      data.minimize();
    })
  }

  shareContentStr(): string {
    let content: string = ProfileUtils.buildShareTextCard(this.contacts);
    return content;
  }

  /**
   *  filter ContactId
   */
  filterContactId() {
    let value: string | undefined = this.sourceHasId ? this.contactId?.toString() : undefined;
    let regExp: RegExp = new RegExp('^[0-9]+$');
    if (!this.isPrivateNumber &&
      ((value !== undefined && !regExp.test(value)) || (this.sourceHasPhone && !this.phoneNumberShow))) {
      try {
        promptAction.showToast({
          message: $r('app.string.this_contact_was_not_found')
        });
      } catch (err) {
        HiLog.e(TAG, 'filterContactId, prompt.showToast Cause: ' + err.code + ', msg=' + err.message);
      }
    }
  }

  private refreshAllCallRecords(numbers: string[], contactId: number = -1) {
    HiLog.w(TAG, `refreshAllCallRecords start, numbers length is ${numbers.length}, contactId: ${contactId}`);
    this.limitDataRefresh?.setActionData({
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      numbers: numbers,
      contactId: contactId
    });
    this.callLogRefreshIndex = 0;
    this.limitDataRefresh?.requestItem();
    return;
  }

  filterFamilyDevice(deviceInfoModelArr: MeeTimeDeviceInfoModel[]) {
    if (!(deviceInfoModelArr instanceof Array)) {
      return [];
    }
    let resultArr: MeeTimeDeviceInfoModel[] = [];
    for (const model of deviceInfoModelArr) {
      if (DeviceUtils.FAMILY_DEVICE_TYPES.includes(model.deviceType)) {
        resultArr.push(model);
      }
    }
    return resultArr;
  }

  async updateLightColor(): Promise<void> {
    let titleArea: number[] = [0, 0, 1, 0.1];
    let nameArea: number[] = [0.2, 0.65, 0.8, 0.8];

    checkIsLightColor(this.cardPhotoPixelMap, titleArea).then((result) => {
      this.isTitleBarLightColor = result;
      HiLog.i(TAG, `isTitleBarLightColor = ${this.isTitleBarLightColor}`);
    }).catch((e: BusinessError) => {
      HiLog.e(TAG, `updateLightColor error ${e.code}, ${e.message}`);
    });
    checkIsLightColor(this.cardPhotoPixelMap, nameArea).then((result) => {
      this.isNameRegionLight = result;
      HiLog.i(TAG, `isNameRegionLight = ${this.isNameRegionLight}`);
    }).catch((e: BusinessError) => {
      HiLog.e(TAG, `updateLightColor error ${e.code}, ${e.message}`);
    });
  }
}

@Concurrent
async function getContactById(contactId: number,
  context?: common.UIAbilityContext | Context): Promise<ContactReturnObj> {
  return await ContactAbilityModel.getContactByIdSync(contactId, context);
}