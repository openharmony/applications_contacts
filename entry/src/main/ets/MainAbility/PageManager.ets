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
import { missedCallManager } from '../feature/missedCall/MissedCallManager';
import IndexPresenter from '../presenter/IndexPresenter';
import { PhoneNumber } from '../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { assembleLogUtils } from '../../../../../common/src/main/ets/util/AuditLogUtils';
import Constants from '../../../../../common/src/main/ets/Constants';
import Want from '@ohos.app.ability.Want';
import { ContactBlobSource, paramsInterface } from '../model/type';
import { targetPageClass } from '../model/type/ContactParams';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import MainAbility from './MainAbility';
import emitter from '@ohos.events.emitter';
import { initBlobSourceMap, saveImageToFile, base64StrToPixelMap } from '../util/UserPhoto';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { MissedCallNotifyData } from '../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier';
import { StringUtil, ObjectUtil } from '../../../../../common';
import VcardImportUtil from '../util/VcardImportUtil'
import EmitterConstant from '../data/EmitterConstant';
import { call } from '@kit.TelephonyKit';
import { DialogControllerManager } from './ControllerManager';
import { queryInitSettingMode } from '../model/CallSharingModel';
import { common } from '@kit.AbilityKit';
import { VisionGlassConstants } from '../data/VisionGlassConstants';
import EnvironmentProp from '../feature/EnvironmentProp';
import { QrCodeManager } from '../presenter/qrcode/QrCodeManager';
import { AppStorageConstant } from '../../../../../common/src/main/ets/AppStorageConstant';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import dataShare from '@ohos.data.dataShare';
import { DataShareResultSet } from '@kit.ArkData';

const TAG = 'PageManager';
// 容器内组件代理跳转容器外的选择联系人picker界面的uri
const FLAG_FROM_ANCO_URI = 'content://com.ohos.contacts.MainAbility/page_flag_single_choose';
// 容器内组件代理跳转容器外的新建联系人picker界面的uri，且携带姓名、号码
const FLAG_FROM_ANCO_URI_SAVE_CONTACT = 'content://com.ohos.contacts.MainAbility/page_flag_save_contact';
// 容器内组件代理跳转容器外的联系人列表
const FLAG_FROM_ANCO_URI_CONTACT_LIST = 'content://com.ohos.contacts.MainAbility/contact_list';
let processorId: number = -1

const FILE_PATH = '/data/storage/el2/base/files';
const TMP_FILE_FOLDER = 'importTmp';
const TMP_FILE_NAME = 'importTmpFile.vcf';
const SHARE_VCARD_BUNDLE_NAME = 'com.ohos.instantshare'
const SHARE_VCARD_APP_ID = '5765880207852903673'
// 桌面或搜索点击联系人图标进入联系人应用，不视为外部跳转进入联系人
const CONTACT_ICON_BUNDLE_NAMES = ['com.ohos.sceneboard', 'com.ohos.hmsapp.hisearch'];
// NFC门店体验使用联系人电话
const NFC_PHONENUMBER = '166575543172'

export interface RecordData {
  beginTime: string;
}

const callRecordData: RecordData[] = []

export default class PageManager {
  public mainUrl: string = 'pages/index';
  public context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  /**
   * 外部跳转场景，联系人应用未打开，触发
   * @param want
   */
  onCreate(want: Want) {
    HiLog.i(TAG, 'onCreate');
    this.onRequest(want.parameters as Record<string, Object>, want, true);
  }

  /**
   * 外部跳转场景，联系人应用处于打开中，触发
   * @param want
   */
  onNewWant(want: Want) {
    HiLog.i(TAG, 'onNewWant');
    this.onRequest(want.parameters as Record<string, Object>, want, false);
  }

  onDestroy() {
    HiLog.i(TAG, 'onDestroy')
  }

  // Go to a specified page.
  // isOnCreate： true为onCreate；false为noNewWant
  async onRequest(parameters: Record<string, Object>, want: Want, isOnCreate: boolean) {
    HiLog.w(TAG, 'show pageRouteHandler routeMessage');
    let url = 'pages/index';
    let urlName = '';
    let params: paramsInterface = {};
    let pageIndex = 1;
    let callerBundleName = parameters['ohos.aafwk.param.callerBundleName'] as string;
    let callerAppIdentifier = parameters['ohos.aafwk.param.callerAppIdentifier'] as string;
    if (callerBundleName !== 'com.ohos.contacts') {
      AppStorage.setOrCreate('startAbilityCallerBundleName', callerBundleName);
    }
    let isEditTakePhoto: boolean = AppStorage.get(AppStorageConstant.EDIT_TAKE_PHOTO) as boolean;
    HiLog.w(TAG, `callerBundleName: ${callerBundleName},isEditTakePhoto:${isEditTakePhoto}`);
    // 如果悬浮窗编辑页拍照，isShowAccountants就为true
    if (!isEditTakePhoto) {
      AppStorage.setOrCreate('isShowAccountants', false);
    }
    if(want.parameters?.beginTime !== undefined && want.parameters?.phoneNumber !== undefined){
      let beginTime: string = want.parameters?.beginTime.toString();
      let phoneNumber: string = want.parameters?.phoneNumber.toString();
      await this.queryRecordByBeginTime(this.context, beginTime, phoneNumber);
      if(AppStorage.get('recordDeleteFlag')){
        want.parameters['pageFlag'] = 'page_flag_dialer';
        AppStorage.setOrCreate('callRecordIsDeleted', true)
        HiLog.i(TAG, 'call record page replace');
      }
    }
    if (parameters?.pageFlag) {
      if (CONTACT_ICON_BUNDLE_NAMES.indexOf(callerBundleName) < 0) {
        // 外部跳转联系人标志位
        AppStorage.setOrCreate('isFromExternalApp', true);
      }
      HiLog.w(TAG, 'pageRouteHandler case is ' + parameters.pageFlag);
      // pageFlag 为true，说明是从其他应用跳转联系人，跳转呼叫前编辑时，不能根据拨号盘拨号逻辑判断是否查询通话记录
      switch (parameters.pageFlag.toString()) {
        case 'page_flag_contacts_list':
          HiLog.i(TAG, 'page_contacts_list.');
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
          urlName = 'pages/index';
          // 联系人应用进入,先展示联系人列表页
          AppStorage.setOrCreate('isClickShowPaste', false);
          break;
        case 'page_flag_dialer':
          urlName = 'pages/index';
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().callIndex);
          params = {
            mainTabsIndex: 0
          }
          if (parameters.isNoMissFormCard === 'true') {
            AppStorage.setOrCreate('isNoMissFormCard', true);
            queryInitSettingMode(this.context as common.UIAbilityContext, '');
          }
          missedCallManager.cancelNotification();
          break;
        case 'page_flag_choose_contacts':
          urlName = 'pages/index';
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
          params = {
            mainTabsIndex: 1
          }
          break;
        case 'page_flag_contact_details':
          if (parameters.isFormCard === 'true') {
            AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().callIndex);
            if (parameters.missedCallId) {
              HiLog.i(TAG, `set missedCallId: ${parameters.missedCallId as number}`)
              AppStorage.setOrCreate('missedCallId', parameters.missedCallId as number);
            }
          } else {
            AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
          }
          urlName = 'ContactDetail';
          pageIndex = 2;
          HiLog.w(TAG, 'page_flag_contact_details');
          if (parameters.contactId) {
            params = {
              sourceHasId: true,
              contactId: parameters.contactId,
              pageFlag: parameters.pageFlag.toString(),
              isFormCard: parameters.isFormCard === 'true' ? true : false
            }
          } else {
            HiLog.w(TAG, 'SHOW pageRouteHandler and routeMessage.phoneNumber ');
            params = {
              sourceHasPhone: true,
              phoneNumberShow: parameters.phoneNumber?.toString(),
              fromSmsList: true,
              sourceHasParam: true,
              isFormCard: parameters.isFormCard === 'true' ? true : false
            }
          }
          break;
        case 'page_flag_edit_before_calling':
          // 其他应用跳转呼叫前编辑页面，不能根据上次电话号码，来判断下次是否需要查询，而应该直接根据号码查询
          let parametersPhoneNumber: string = parameters.phoneNumber?.toString();
          ContactsGlobalThisHelper.GetGlobalThis().set(
            ContactsGlobalThisHelper.ToEditBeforeCallingFromExternalAppFlag, true);
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().callIndex);
          AppStorage.setOrCreate(Constants.storage.teleNumber, parametersPhoneNumber);
          if ('950800' === parametersPhoneNumber) {
            emitter.emit({
              eventId: EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID
            });
          }
          urlName = 'pages/index';
          params = {
            mainTabsIndex: 0,
            teleNumber: parametersPhoneNumber
          }
          let numberLen: number | undefined = parameters.phoneNumber?.toString().length;
          HiLog.w(TAG, `numberLen: ${numberLen}`);
          if (numberLen) {
            HiLog.w(TAG,
              `phoneInfo: ${numberLen >= 11 ? parameters.phoneNumber.toString().substring(0, 3) : 0} : ${numberLen >=
                5 ? parameters.phoneNumber.toString().substring((numberLen - 4), numberLen) : 0}`);
          }
          missedCallManager.cancelNotification();
          break;
        case 'page_flag_save_contact':
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
          urlName = 'Accountants';
          pageIndex = 3;
          let phoneNumber = parameters.phoneNumber?.toString().replace(new RegExp('[^0123456789+]*', 'g'), '');
          params = {
            newContactData: parameters.newContactData,
            disPlayName: parameters.contactName,
            sourceHasParam: true,
          }
          if (!StringUtil.isEmpty(phoneNumber)) {
            params.phoneNumbers = [
              {
                'phoneNumber': phoneNumber
              }
            ]
          }
          break;
        case 'page_flag_save_exist_contact':
          urlName = 'SingleSelectContactPage';
          pageIndex = 4;
          params = {
            phoneNumberShow: parameters.phoneNumber?.toString(),
            isSaveExistContact: true,
            isDisplayByName: true,
          }
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
          break;
        case 'page_flag_sms_forward':
          url = 'pages/contacts/batchselectcontacts/BatchSelectContactsEntry'
          urlName = 'BatchSelectContactsPage';
          pageIndex = 4
          params = {
            selectType: 1
          }
          break;
        case 'page_flag_multi_choose':
          HiLog.w(TAG, 'dadian_multi_choose start');
          pageIndex = 4;
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
          urlName = 'BatchSelectContactsPage';
          params = {
            selectType: 0,
            isLimit: parameters.isLimit,
            contactCount: parameters.contactCount,
            isNotShowTab: (parameters.isNotShowTab ?? false) as boolean,
            isCardEntry: (parameters.isNotShowTab ?? false) as boolean
          }
          HiLog.w(TAG, 'dadian_multi_choose end');
          break;
        case 'page_flag_single_choose':
          pageIndex = 4;
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
          urlName = 'SingleSelectContactPage';
          params = {
            selectType: 0
          }
          break;
        case 'harassment_filter':
          //点击拦截通知时，通过startAbility方式跳转通话防护界面
          pageIndex = 5;
          urlName = 'HarassmentFilter';
          AppStorage.setOrCreate('harassmentPageAbilityName', parameters.abilityName ?? '');
          AppStorage.setOrCreate('harassmentSlotId', parameters.slotId ?? '-1');
          HiLog.i(TAG, 'this.pageAbilityName: ' + parameters.abilityName);
          HiLog.i(TAG, 'this.slotId: ' + parameters.slotId);
          break;
        case 'page_contact_privacy_statement':
          HiLog.w(TAG, 'page_contact_privacy_statement   jumpToSettingSubpage: ' + parameters.jumpToSettingSubpage);
          AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
          AppStorage.setOrCreate('jumpToSettingSubpageParam', parameters.jumpToSettingSubpage);
          urlName = 'Settings';
          pageIndex = 3;
          break;
        default:
          HiLog.e(TAG, 'pageRouteHandler and This page is not open.');
          // 外部跳转联系人标志位
          AppStorage.setOrCreate('isFromExternalApp', false);
          if (isOnCreate) {
            break;
          } else {
            return;
          }
      }
    } else if (parameters?.contactQrCode) {
      if (CONTACT_ICON_BUNDLE_NAMES.indexOf(callerBundleName) < 0) {
        // 外部跳转联系人标志位
        AppStorage.setOrCreate('isFromExternalApp', true);
      }

      AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
      urlName = 'Accountants';
      pageIndex = 3;
      let contactInfo = QrCodeManager.getInstance().handleQrCode(parameters.contactQrCode as string);
      params = {
        newContactData: typeof contactInfo !== 'number' ? contactInfo : {},
        sourceHasParam: true,
      }
    } else if (want.uri && (want.uri == FLAG_FROM_ANCO_URI_SAVE_CONTACT)) {
      HiLog.w(TAG, 'from anco to page_flag_single_choose, want.uri: ' + want?.uri);
      urlName = 'Accountants';
      pageIndex = 3;
      params = {
        phoneNumbers: [
          {
            'phoneNumber': parameters?.phone?.toString().replace(new RegExp('[^0123456789+]*', 'g'), '')
          }
        ],
        disPlayName: parameters?.name,
        sourceHasParam: true,
      }
    } else if (want.uri && (want.uri == FLAG_FROM_ANCO_URI)) {
      HiLog.w(TAG, 'from anco to page_flag_single_choose, want.uri: ' + want?.uri);
      pageIndex = 4;
      url = 'pages/contacts/batchselectcontacts/SingleSelectContactsEntry'
      urlName = 'SingleSelectContactPage';
      params = {
        selectType: 0
      }
    } else if (want.uri && (want.uri == FLAG_FROM_ANCO_URI_CONTACT_LIST)) {
      HiLog.w(TAG, 'from anco to contact_list, want.uri: ' + want?.uri);
      AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
      urlName = 'pages/index';
    } else if (want.uri && (new RegExp('^tel\:').test(want.uri))) {
      HiLog.w(TAG, 'from anco to page_flag_edit_before_calling');
      // 其他应用跳转呼叫前编辑页面，不能根据上次电话号码，来判断下次是否需要查询，而应该直接根据号码查询
      ContactsGlobalThisHelper.GetGlobalThis().set(
        ContactsGlobalThisHelper.ToEditBeforeCallingFromExternalAppFlag, true);
      const phoneNumber = decodeURIComponent(want.uri).replace(new RegExp('^tel\:'), '');
      AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().callIndex);
      AppStorage.setOrCreate(Constants.storage.teleNumber, phoneNumber);
      urlName = 'pages/index';
      params = {
        mainTabsIndex: 0,
        teleNumber: phoneNumber
      }
    } else if (want.action == 'ohos.want.action.viewData') {
      let isKnockShare: boolean = false;
      if (want.uri) {
        let uri = want.uri;
        let uriEnd = uri.toString().split('/');
        if (uriEnd[uriEnd.length-1].match('^contactShare_\\d+\\.vcf$')) {
          isKnockShare = true;
        }
      }
      // 对应联系人碰一碰不弹窗，直接导入vCard
      if (callerAppIdentifier === SHARE_VCARD_APP_ID && callerBundleName === SHARE_VCARD_BUNDLE_NAME && isKnockShare) {
        HiLog.w(TAG, 'importVcardFromWant confirmation');
        this.importVcardFromWant(want);
        return;
      } else {
        HiLog.w(TAG, 'importVcardFromWant dialog confirmation');
        urlName = 'pages/index';
        AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
        AppStorage.setOrCreate('isClickShowPaste', false);
        AppStorage.setOrCreate('importVcardWant', want);
        // 关闭对应状态
        AppStorage.setOrCreate('isContactSearch', false);
        AppStorage.setOrCreate('isShowContactsSettings', false);
      }
    } else if (want.action && want.action === 'action.detect.repair') {
      HiLog.i(TAG, 'create is coming from detection tools start, jumpToSettingSubpage' +
        StringUtil.maskSensitiveInfo(parameters.jumpToSettingSubpage.toString()));
      AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
      AppStorage.setOrCreate('jumpToSettingSubpageParam', parameters.jumpToSettingSubpage);
      urlName = 'Settings';
    } else if (want.uri === 'calllog://voice/main?intent=callProfile') {
      //门店NFC显示
      AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
      urlName = 'ContactDetail';
      pageIndex = 2;
      params = {
        sourceHasPhone: true,
        phoneNumberShow: NFC_PHONENUMBER,
      }
      AppStorage.setOrCreate('isNfcJump', true);
    } else {
      this.requestMissedCallAction(parameters['action'], parameters['missedCallData'] as MissedCallNotifyData)
      let tabsIndex: number | undefined = AppStorage.get('mainTabsIndex');
      if (tabsIndex == IndexPresenter.getInstance().callIndex || tabsIndex == undefined) {
        missedCallManager.cancelNotification()
      }
      let isInVisionGlass = AppStorage.get<boolean>(VisionGlassConstants.KEY_IS_IN_VISION_GLASS);
      if (!isInVisionGlass) { //眼镜上不执行以下操作
        if (!AppStorage.get<boolean>('isVerde')) {
          // v小折叠 内屏切换到外屏时，不执行以下操作
          if ((call.hasVoiceCapability() ||
            AppStorage.get('isDistributedCallPhoneSharing') && AppStorage.get('isDistributedModemState') &&
            AppStorage.get('isDistributedCallSourcePhone')) && !isEditTakePhoto) {
            AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().callIndex);
            urlName = 'pages/index';
          } else {
            if (!this.isContactSearchStatus()) {
              AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
              urlName = 'pages/index';
            }
          }
        }
      }
      if (!isOnCreate) {
        if (!isInVisionGlass) { //眼镜上不执行以下操作
          if (!this.isContactSearchStatus()) {
            IndexPresenter.getInstance().pathInfos.clear(false);
          }
        }
        AppStorage.setOrCreate(Constants.storage.targetPage, new targetPageClass(urlName, pageIndex, params));
        DialogControllerManager.getInstance().closeAll();
        HiLog.w(TAG, 'pageRouteHandler return.');
        return;
      }
    }
    // onCreate
    HiLog.w(TAG, 'onRequest urlName: ' + urlName);
    if (isOnCreate) {
      this.mainUrl = url;
      if (this.mainUrl == 'pages/index') {
        IndexPresenter.getInstance().targetPageChange = () => {
          // 'targetPage' 字符串，对应值位targetDataClass 对象
          // index.ets 监听变化，触发 targetPageChange
          // @StorageLink('targetPage') @Watch('targetPageChange') targetPage: TargetPageInter = {};
          AppStorage.setOrCreate(Constants.storage.targetPage, new targetPageClass(urlName, pageIndex, params))
        }
      }
      if (urlName === 'ContactDetail') {
        HiLog.w(TAG, 'contactDetail updateContactInfo');
        AppStorage.setOrCreate('updateContactInfo', params);
      } else {
        HiLog.w(TAG, 'isOnCreate updateContactInfo');
        AppStorage.setOrCreate('params', params);
      }
      // 请求头像信息
      this.requestItem()
    } else {
      // onNewWant
      AppStorage.setOrCreate(Constants.storage.targetPage, new targetPageClass(urlName, pageIndex, params))
      if (this.mainUrl !== 'pages/index' && this.mainUrl !== url) {
        this.mainUrl = url
        MainAbility.UPDATE_CONTENT
        emitter.emit({
          eventId: MainAbility.UPDATE_CONTENT,
          priority: emitter.EventPriority.HIGH
        })
      }
      HiLog.w(TAG, 'pageRouteHandler finish!');
    }
  }

  isContactSearchStatus(): boolean {
    return (AppStorage.get('isContactSearch') ?? false) && (EnvironmentProp.isDeviceTypeTablet() ?? false) &&
      (!call.hasVoiceCapability() ?? false);
  }

  requestMissedCallAction(action?: Object, data?: MissedCallNotifyData) {
    if ('notification.event.message' == action) {
      HiLog.i(TAG, `requestMissedCallAction action: ${action}`);
      if (data?.phoneNumber != undefined) {
        let phoneNumber = PhoneNumber.fromString(data.phoneNumber);
        phoneNumber.format().then((formatNum: string) => {
          phoneNumber.sendMessage(formatNum, data.displayName, data.id);
        })
      }
      if (data) {
        missedCallManager.cancelNotification(data);
      }
    }
  }

  requestItem(callback?: Function) {
    HiLog.i(TAG, 'Contacts requestItem!');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequestTaskPool('getContactIdToBlobDataMap',
        {}, (resultMap: Map<string, ContactBlobSource>) => {
        if (resultMap) {
          initBlobSourceMap(resultMap);
          AppStorage.setOrCreate('contactListUpdated', new Date().valueOf());
          HiLog.i(TAG, 'Contacts requestItem end: ' + resultMap.size);
          callback?.();
        }
      });
  }

  importVcardFromWant(want: Want) {
    HiLog.i(TAG, 'importVcardFromWant');

    VcardImportUtil.importVcardFromWant(want, (contactId: string) => {
      PageManager.jumpToDetailWithContactId(contactId);
      assembleLogUtils('Tap and Go',{contactId:contactId, operationScenario:'add contact by Tap and Go'})
    });
  }

  public static jumpToDetailWithContactId(contactId: string) {
    let params: paramsInterface = {
      sourceHasId: true,
      contactId: contactId,
      pageFlag: 'page_flag_contact_details',
      isCardSharing: true,
    };
    let urlName = 'ContactDetail';
    let pageIndex = 2;
    AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
    AppStorage.setOrCreate(Constants.storage.targetPage, new targetPageClass(urlName, pageIndex, params));
  }

  async queryRecordByBeginTime(context: common.Context, beginTime: string, phoneNumber: string) {
    const CALL_LOG_DATA = 'datashare:///com.ohos.calllogability';
    const CALL_LOG_URI = 'datashare:///com.ohos.calllogability/calls/calllog';
    //查询条件dataPredicates
    let dataPredicates = new dataSharePredicates.DataSharePredicates();
    dataPredicates.equalTo('begin_time', beginTime);
    dataPredicates.equalTo('phone_number', phoneNumber);
    let dataShareHelper: dataShare.DataShareHelper =
          await dataShare.createDataShareHelper(context, CALL_LOG_DATA)
    //查询字段
    let resultColumns = ['begin_time']

    let resultSet: DataShareResultSet | undefined = undefined;
    try{
      resultSet = await dataShareHelper.query(CALL_LOG_URI, dataPredicates, resultColumns);
      HiLog.i(TAG, `call record num is ${resultSet.rowCount}`)
      if (resultSet.goToFirstRow()) {
        do {
          let beginTime = resultSet.getString(resultSet.getColumnIndex('begin_time'));
          callRecordData.push({beginTime:beginTime})
          HiLog.i(TAG, `call record exist: ${callRecordData[0].beginTime}` )
          AppStorage.setOrCreate('recordDeleteFlag', false)
        } while (resultSet.goToNextRow());
      } else {
        HiLog.i(TAG, 'call record not exist')
        AppStorage.setOrCreate('recordDeleteFlag', true)
      }
    }catch (err){
      AppStorage.setOrCreate('recordDeleteFlag', false)
      HiLog.e(TAG, `err:${err?.code}`)
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
    callRecordData.length = 0
    HiLog.i(TAG, `call record delete flag is: ${AppStorage.get('recordDeleteFlag')}`)
  }
}