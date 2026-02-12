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
import image from '@ohos.multimedia.image';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { ObjectUtil } from '../../../../../../../common/src/main/ets/util/ObjectUtil';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { DynamicLoader } from '../../../../../../../common/src/main/ets/util/DynamicLoader';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { DynamicLoadSoUtil } from '../../../../../../../common/src/main/ets/util/DynamicLoadSoUtil';
import { PhoneNumBean } from '../../../model/bean/PhoneNumBean';
import AccountantsPresenter from '../../../presenter/contact/accountants/AccountantsPresenter';
import { ItemList } from '../../../component/contact/accountants/ItemList';
import curves from '@ohos.curves';
import { AccountantParams, ContactInterface, CustomizedParams, SingleSelectContact } from '../../../model/type';
import { BusinessError } from '@ohos.base';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import common from '@ohos.app.ability.common';
import emitter from '@ohos.events.emitter';
import ArrangeContactsPresenter from '../../../presenter/contact/settings/ArrangeContactsPresenter';
import { AccountVo } from '../../../model/bean/AccountVo';
import { sharedPreferencesUtils } from '../../../../../../../common';
import { getImagePackingData, scalePixelMap } from '../../../util/UserPhoto';
import LooseObject from '../../../model/type/LooseObject';
import DotUtil from '../../../util/DotUtil';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import EmitterConstant from '../../../data/EmitterConstant';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { EditAvatar } from '../../../component/avatar/AvaterCutout';
import inputMethod from '@ohos.inputMethod';
import CameraPickerUtil from '../../../util/cameraPickerUtil';
import { PickerResult } from '../../../model/bean/cameraPicker';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { FontScaleState } from '../../../util/fontScaleState';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { LengthMetrics } from '@kit.ArkUI';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository'
import dataShare from '@ohos.data.dataShare';
import ContactListItem from '../../../../../../../feature/contact/src/main/ets/repo/ContactListItem';
import { Contacts } from '../../../../../../../feature/contact/src/main/ets/contract/Contacts';
import Constants from '../../../../../../../common/src/main/ets/Constants';
import { EmailBean } from '../../../model/bean/EmailBean';
import { EventBean } from '../../../model/bean/EventBean';
import { AIMBean } from '../../../model/bean/AIMBean';
import { HouseBean } from '../../../model/bean/HouseBean';
import { AssociatedPersonBean } from '../../../model/bean/AssociatedPersonBean';
import { Birthday } from '../../../../../../../feature/contact/src/main/ets/contract/Birthday';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import { i18n } from '@kit.LocalizationKit';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { PCDeviceConstant } from '../../../data/PCDeviceConstant';
import { VisionGlassConstants } from '../../../data/VisionGlassConstants';
import { UIExtensionContentSession } from '@kit.AbilityKit';
// import { ringtone } from '@kit.RingtoneKit';
import { RingtoneInfo } from '../../../model/ringTone/toneTypes';
import { ItemEvent } from '../../../component/contact/accountants/ItemEvent';
import ResourceAudioManager from '../../../presenter/ringtone/ResourceAudioManager';
import RingtoneSelection from '../../ringtoneSelection/RingtoneIndex';
import { fileIo } from '@kit.CoreFileKit';
import { taskpool } from '@kit.ArkTS';
import call from '@ohos.telephony.call';
import { SystemModeController, showToast } from '../../../util/SystemModeController';
import { AppStorageConstant } from '../../../../../../../common/src/main/ets/AppStorageConstant';
import { Cause } from '../../../../../../../common/src/main/ets/util/AuditLogUtils';;

const TAG = 'AddContact';
const CANCEL_ADD_CONTACT_EVENT = 'CANCEL_ADD_CONTACT_EVENT';
const CLICK_ADD_MORE_EVENT = 'CLICK_ADD_MORE_EVENT';
const CONTENT_END_OFFSET: number = EnvironmentProp.isPC() ? 16 : 44;
let storage = LocalStorage.GetShared();
const emitterIdAddAccountants = 210;

const context = getContext(this);


@Extend(Button)
function buttonStyles() {
  .type(EnvironmentProp.isPC() ? ButtonType.Normal : ButtonType.Circle)
  .height(EnvironmentProp.isPC() ? $r('app.float.id_card_margin_max') : $r('app.float.id_card_image_mid'))
  .width(EnvironmentProp.isPC() ? $r('app.float.id_card_margin_max') : $r('app.float.id_card_image_mid'))
  .borderRadius(EnvironmentProp.isPC() ? $r('sys.float.corner_radius_level2') : $r('sys.float.corner_radius_level4'))
  .buttonStyle(EnvironmentProp.isPC() ? ButtonStyleMode.TEXTUAL : ButtonStyleMode.NORMAL)
  .stateEffect(true)
}

@Component
export default struct Accountants {
  @Provide inShowCalendar: boolean = false;
  @Prop params?: SingleSelectContact;
  @Link isShowAccountants: boolean;
  @StorageLink('accountantTitleClass') accountantTitleClass: AccountantTitleClass = new AccountantTitleClass();
  @Prop isCreateMyCard: boolean = false;
  @Prop isEditMyCard: boolean = false;
  // pathInfos
  @Consume('pathInfos') pathInfos: NavPathStack;
  // mPresenter
  @State mPresenter: AccountantsPresenter = new AccountantsPresenter();
  // eventItemId
  @State eventItemId: number = 0;
  @State eventType: number = 1;
  @State isPortraitDisplayCarMachine: boolean = false;
  @State isPortraitDisplay: boolean = false;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('fullScreenPadding') @Watch('onChangeFullScreenPadding') fullScreenPadding: Padding = {};
  // 键盘高度
  @LocalStorageProp('keyBoardHeightPx') keyBoardHeight: number = 0;
  @Provide('updataShow') updataShow: boolean = false;
  // 新建、编辑联系人选择铃声半模态页面显示/关闭
  @StorageLink('isAccountRingToneShow') @Watch('onRingToneChange') isAccountRingToneShow: boolean = false;
  @State @Watch('onRingToneInfoChange') ringtoneInfo: RingtoneInfo = {
    ringtoneName: '',
    ringtoneFilePath: '',
    ringtonePath: '',
  };
  @State pageTitle: Resource = $r('app.string.create_contact'); //新建联系人半模态弹窗标题
  @State avatarUrl: string = ''
  @State photoPixelMap: PixelMap | null = null;
  @StorageLink('isSaveContact') isSaveCon: number = 0;
  @State isShow: boolean = false;
  @State avatarImageUrl: string = '';
  @State editIsShowMore: boolean = false;
  @State nameTextInputFocus: boolean = false;
  @State showPhoneNumberList: boolean = false;
  @State paddingBottom: Length | undefined = undefined;
  @State isExpandMore: boolean = false;
  @StorageLink('showDialBtn') showDialBtn: boolean = true;
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageProp('isMainAbilityForeground') @Watch('onForegroundChange') isMainAbilityForeground: boolean = true;
  @Provide('enableKeyboardOnFocus') enableKeyboardOnFocus: boolean = true;
  @StorageProp('currentColorMode') currentMode: number = ColorMode.LIGHT;
  @StorageProp('isSave') @Watch('updateAccountantTitleClass') isSave: boolean = false;
  @StorageProp('fontSizeScale') @Watch('updateAccountantTitleClass') fontSizeScale: number = 0;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') @Watch('updateAccountantTitleClass') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) @Watch('updateAccountantTitleClass') isOpenAccessibility: boolean = false;
  // 是否滚动停止
  isScrollStop: boolean = true;
  //分屏状态
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  @StorageLink('isShowPickerMaskLayer') isShowPickerMaskLayer: boolean = false;

  @State isExpand: boolean = false;
  @State isShowMore: boolean = false;
  @State isShowAddPhoneNumber: boolean = false;
  @State isShowAddEmail: boolean = false;
  @State isShowAddWebsite: boolean = false;
  @State isShowAddMessaging: boolean = false;
  @State isShowAddAddress: boolean = false;
  @State isShowAddBirthday: boolean = false;
  @State isShowAddAssociation: boolean = false;
  private mSystemModeController = SystemModeController.getInstance();

  systemLanguageIsRtl():boolean {
    return i18n.isRTL(i18n.System.getSystemLanguage())
  }

  // listScroller
  private listScroller: Scroller = new Scroller();
  private isPC: boolean = EnvironmentProp.isPC();
  photoDeleted: boolean = false;
  public avtarDeletedCallBack: () => void = () => {};
  // 获取session
  private uiExtentionSession?: UIExtensionContentSession = ContactsGlobalThisHelper.GetGlobalThis()
    .getUIExtensionContentSession();

  cancelAddContactParams: CustomizedParams = {
    ISPOP: 0,
    ISSAVE: 0
  };
  customizedParams: CustomizedParams = {};
  @State accountName: string = '';

  deleteDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.save_dialog_title'),
      primaryButton: {
        value: $r('app.string.dialog_not_save'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          this.isShowAccountants = false;
          this.enableKeyboardOnFocus = false;
          HiLog.i(TAG, 'AlertDialog cancel');
          // 点击取消不保存打点
          this.cancelAddContactParams.ISPOP = 1;
          this.cancelAddContactParams.ISSAVE = 0;
          DotUtil.getInstance().contactDot(this.cancelAddContactParams, CANCEL_ADD_CONTACT_EVENT);
          this.isSaveCon = 0;
          // 取消编辑联系人时判断是否移除铃音库中的自定义铃声
          this.mPresenter.removeContactLocalRingtone(getContext(this));
          if (this.uiExtentionSession != undefined && (!AppStorage.get('isFromMeetime'))) {
            this.sendBackMsg(this.uiExtentionSession);
          }
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          if (this.updataShow === false) {
            AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility,
              'contactList_contacts_titleGuideClick_btn', 20);
          }
        },
      },
      secondaryButton: {
        value: $r('app.string.save'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          HiLog.i(TAG, 'AlertDialog saveContact');
          // 点击取消保存打点
          this.cancelAddContactParams.ISPOP = 1;
          this.cancelAddContactParams.ISSAVE = 1;
          DotUtil.getInstance().contactDot(this.cancelAddContactParams, CANCEL_ADD_CONTACT_EVENT);
          this.isSaveCon = 0;
          this.mPresenter.saveContact(this.uiExtentionSession);
          this.emitterUpdata();
          if (this.curBp !== 'sm') {
            if (IndexPresenter.getInstance().curIndex === IndexPresenter.getInstance().callIndex) {
              CallRecordPresenter.getInstance().setPageShow(true);
            }
          }
          if (this.photoDeleted) {
            this.avtarDeletedCallBack?.();
          }
          this.isShowAccountants = false;
          this.enableKeyboardOnFocus = false;
        }
      }
    }),
    autoCancel: true,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  /**
   * 发送回退消息
   * @param uiExtentionSession
   */
  sendBackMsg(uiExtentionSession?: UIExtensionContentSession) {
    HiLog.i(TAG, 'send back msg: notifyHostBackPress, uiExtentionSession has value：' + (uiExtentionSession != undefined))
    let isFromSaveContactPicker = AppStorage.get<boolean>('isFromSaveContactPicker') as boolean;
    let contactIndex = -1;
    if (AppStorage.has('newContactId')) {
      contactIndex = AppStorage.get<number>('newContactId') as number;
      AppStorage.delete('newContactId');
    }
    HiLog.i(TAG, `send back msg: notifyHostBackPress, isFromSaveContactPicker：${ isFromSaveContactPicker },
        contactIndex: ${contactIndex} `);
    let backPressMsg: Record<string, string | boolean | number> =  {
      'action': 'notifyHostBackPress',
      'isFromSaveContactPicker': isFromSaveContactPicker,
      'contactIndex': contactIndex
    }
    uiExtentionSession?.sendData(backPressMsg);
  }

  onRingToneInfoChange() {
    HiLog.i(TAG, `onRingToneInfoChange, ringtoneName: ${StringUtil.maskSensitiveInfo(this.ringtoneInfo?.ringtoneName)}`);
    this.mPresenter.contactInfoAfter.personalRingtone = this.ringtoneInfo.ringtonePath;
    this.mPresenter.contactInfoAfter.personalRingtonePath = this.ringtoneInfo.ringtoneFilePath;
    this.mPresenter.contactInfoAfter.personalNotificationRingtone = this.ringtoneInfo.ringtoneName;
  }

  emitterUpdata() {
    let eventData: emitter.EventData = {
      data: {
        'displayName': this.mPresenter.contactInfoBefore.display_name
      }
    }
    emitter.emit({
      eventId: EmitterConstant.EMITTER_ACCOUNTANTS_EMITTER_ID,
      priority: emitter.EventPriority.HIGH
    }, eventData)
  }

  onChangeFullScreenPadding() {
    if (this.paddingBottom !== this.fullScreenPadding.bottom) {
      this.paddingBottom = this.fullScreenPadding.bottom;
    }
  }

  parseParams(obj: AccountantParams) {
    if (!ObjectUtil.isEmpty(obj)) {
      // 判断新建或者编辑
      if (obj.updataShow !== undefined) {
        this.updataShow = obj.updataShow;
      }

      if (this.params?.ringtoneInfo) {
        this.ringtoneInfo = this.params?.ringtoneInfo;
      }
      this.isCreateMyCard = obj.isCreateMyCard ?? false;
      this.isEditMyCard = obj.isEditMyCard ?? false;

      // 外部拉起新建联系人 支持全字段数据添加
      if (obj.newContactData) {
        HiLog.w(TAG, 'parseParams newContactData');

        let uri = obj.newContactData.portrait?.uri ?? '';
        if (!StringUtil.isEmpty(uri)) {
          HiLog.w(TAG, `deal uri start`);
          fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE).then((file) => {
            let imageSourceApi = image.createImageSource(file.fd);
            imageSourceApi?.createPixelMap().then((pixelMap) => {
              HiLog.w(TAG, `createPixelMap success`);
              imageSourceApi?.release();

              let task = new taskpool.Task(scalePixelMap, pixelMap, context);
              taskpool.execute(task).then((imgScaledObjct: Object) => {
                HiLog.w(TAG, 'scalePixelMap success')
                let imgScaled = imgScaledObjct as image.PixelMap;
                this.destinationPageShow(pixelMap, imgScaled);
              });
            }).catch((err: BusinessError) => {
              imageSourceApi?.release();
              HiLog.e(TAG, `createPixelMap err: ${err.message}`);
            })
          })
        }

        // 姓名
        let name = obj.newContactData.name?.fullName ?? '';
        this.mPresenter.contactInfoBefore.setDisplayName(name);
        this.mPresenter.contactInfoAfter.setDisplayName(name);

        // 单位
        let company: string = obj.newContactData.organization?.name ?? ''
        this.mPresenter.contactInfoBefore.setCompany(company);
        this.mPresenter.contactInfoAfter.setCompany(company);

        // 职位
        let position: string = obj.newContactData.organization?.title ?? ''
        this.mPresenter.contactInfoBefore.setPosition(position);
        this.mPresenter.contactInfoAfter.setPosition(position);

        // 备注
        let note: string = obj.newContactData.note?.noteContent ?? '';
        this.mPresenter.contactInfoBefore.setRemarks(note);
        this.mPresenter.contactInfoAfter.setRemarks(note);
        // 单位 或者 备注 非空时，页面需展开
        if (!StringUtil.isEmpty(company) || !StringUtil.isEmpty(position) || !StringUtil.isEmpty(note)) {
          this.isExpand = true;
        }

        // 电话号码
        let phones: PhoneNumBean[] = [];
        obj.newContactData.phoneNumbers?.forEach((phone) => {
          phones.push(PhoneNumBean.getBeanByPickerData(phone));
        })
        this.mPresenter.contactInfoBefore.setPhones(phones);
        this.mPresenter.contactInfoAfter.setPhones(phones);

        // 邮件
        let emails: EmailBean[] = [];
        obj.newContactData.emails?.forEach((email) => {
          emails.push(EmailBean.getBeanByPickerData(email));
        })
        this.mPresenter.contactInfoBefore.setEmails(emails);
        this.mPresenter.contactInfoAfter.setEmails(emails);

        // 网站
        let websites: string[] = [];
        obj.newContactData.websites?.forEach((website) => {
          websites.push(website.website);
        })
        this.mPresenter.contactInfoBefore.setWebsites(websites);
        this.mPresenter.contactInfoAfter.setWebsites(websites);

        // 即时信息
        let aims: AIMBean[] = [];
        obj.newContactData.imAddresses?.forEach((aim) => {
          aims.push(AIMBean.getBeanByPickerData(aim));
        })
        this.mPresenter.contactInfoBefore.setAims(aims);
        this.mPresenter.contactInfoAfter.setAims(aims);

        // 地址
        let houses: HouseBean[] = [];
        obj.newContactData.postalAddresses?.forEach((house) => {
          houses.push(HouseBean.getBeanByPickerData(house));
        })
        this.mPresenter.contactInfoBefore.setHouses(houses);
        this.mPresenter.contactInfoAfter.setHouses(houses);

        // 生日
        let events: EventBean[] = [];
        let onlyOneBirthday = false;
        let onlyOneLunarBirthday = false;
        obj.newContactData.events?.forEach((event) => {
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
          events.push(eventBean);
        })
        this.mPresenter.contactInfoBefore.setEvents(events);
        this.mPresenter.contactInfoAfter.setEvents(events);

        // 关联人
        let relationships: AssociatedPersonBean[] = [];
        obj.newContactData.relations?.forEach((relation) => {
          relationships.push(AssociatedPersonBean.getBeanByPickerData(relation));
        })
        this.mPresenter.contactInfoBefore.setRelationships(relationships);
        this.mPresenter.contactInfoAfter.setRelationships(relationships);
        // 展开更多项
        if (emails.length > 0 || websites.length > 0 || aims.length > 0 || houses.length > 0 ||
          events.length > 0 || relationships.length > 0) {
          this.isShowMore = true;
          this.isExpandMore = true;
        }

        if (!StringUtil.isEmpty(name) || phones.length > 0 || this.isExpand || this.isShowMore) {
          this.mPresenter.initContactSelectInfoModel(this.mPresenter.contactInfoAfter);
          this.mPresenter.addState = true;
        }

      } else {
        if (obj.phoneNumbers !== undefined && !ArrayUtil.isEmpty(obj.phoneNumbers) &&
          this.updataShow === false) {
          let phoTemp: PhoneNumBean[] = [];
          obj.phoneNumbers.forEach(item => {
            phoTemp.push(StringUtil.isEmpty(item.labelName) ?
              new PhoneNumBean('', item.phoneNumber, '1', '', '') :
              new PhoneNumBean(item.labelName, item.phoneNumber, '10000', '', ''));
          });
          if (obj.disPlayName === undefined || StringUtil.isEmpty(obj.disPlayName)) {
            phoTemp[0].highlighting = true;
          }
          this.mPresenter.contactInfoBefore.setPhones(phoTemp);
          this.mPresenter.contactInfoAfter.setPhones(phoTemp);
          this.mPresenter.initContactSelectInfoModel(this.mPresenter.contactInfoAfter);
          this.mPresenter.addState = true;
        }
        if (obj.disPlayName !== undefined && (!StringUtil.isEmpty(obj.disPlayName)) &&
          this.updataShow === false) {
          this.mPresenter.contactInfoBefore.setDisplayName(obj.disPlayName);
          this.mPresenter.contactInfoAfter.setDisplayName(obj.disPlayName);
          this.mPresenter.addState = true;
        }
        if (obj.sourceHasParam) {
          this.mPresenter.sourceHasParam = obj.sourceHasParam;
        }
        //判断是否有关联人
        if (!ArrayUtil.isEmpty(obj.relationships)) {
          this.mPresenter.contactInfoBefore.setRelationships(obj.relationships);
          this.mPresenter.contactInfoBefore.setRelationships(obj.relationships);
          //展开更多
          this.isExpandMore = true;
          this.isShowMore = true;
        }
      }
    }
  }

  onForegroundChange() {
    // v小折叠 外屏展示回到前台的时候，新建页面收起
    if (this.isVerde && this.isMainAbilityForeground) {
      this.showDialBtn = false;
      this.isShowAccountants = false;
      AppStorage.setOrCreate(Constants.storage.mainTabsIndex, IndexPresenter.getInstance().contactIndex);
      if (this.mPresenter.saveClickEnable()) {
        HiLog.i(TAG, 'onVChange save');
        this.saveOnClick();
      }
    }
    if (!this.isMainAbilityForeground) {
      this.isAccountRingToneShow = false;
      ResourceAudioManager.releaseRing();
    }
  }

  onRingToneChange() {
    HiLog.i(TAG, 'onRingToneChange');
    this.mPresenter.onRingToneChange(this.updataShow, this.isAccountRingToneShow);
  }

  getIsEnableKeyboardOnFocus(): boolean {
    return (!this.updataShow && this.enableKeyboardOnFocus && !this.isShowPickerMaskLayer);
  }

  aboutToAppear() {
    HiLog.i(TAG, 'the Page aboutToAppear Begin !!');
    HiLog.i(TAG, `aboutToAppear isMyCard:${this.isEditMyCard}`);
    this.mPresenter.destinationPageShow = this.destinationPageShow;
    this.mPresenter.init();
    sharedPreferencesUtils.getFromPreferences('accountType', -1).then((accountId) => {
      ArrangeContactsPresenter.getInstance().getAllAccount((result: AccountVo[]) => {
        HiLog.i(TAG, 'account length is:' + result.length);
        let accountVo: AccountVo | undefined = result
          .find((accountVo: AccountVo) => {
            return accountVo?.accountId == accountId;
          })
        if (accountVo != undefined && accountVo.accountId != '1') {
          this.accountName = accountVo.accountName;
        }
      })
    });
    this.mPresenter.pathInfos = this.pathInfos;

    // 参数解析
    if (ObjectUtil.isEmpty(this.params)) {
      HiLog.w(TAG, 'this.params is empty');
      this.params = AppStorage.get('accountantParams') as AccountantParams | undefined;
      AppStorage.delete('accountantParams');
    }
    this.parseParams(this.params as AccountantParams);

    if (this.updataShow === true && this.params) {
      this.pageTitle = $r('app.string.edit_contact');
      this.mPresenter.contactId = this.params?.contactId.toString();
      this.mPresenter.nameRawContactId = this.params?.nameRawContactId?.toString() ?? '';
      this.mPresenter.updateShow = true;
      this.mPresenter.phones = this.params?.phones;
      this.mPresenter.editContact = this.params?.editContact;
      this.mPresenter.phoneNumberShow = this.params?.phoneNumberShow;
      this.mPresenter.callId = this.params?.callId;
      this.mPresenter.relationships = this.params?.relationships;
      this.mPresenter.newContactData = this.params?.newContactData;
      this.mPresenter.updatesInit(() => {
        this.expandNameCard();
        this.expandMoreInfo();
        this.refreshRingtoneInfo();
      });
    } else {
      this.mPresenter.showPhoneAndEmail();
    }

    // 判断我的名片
    if (this.isCreateMyCard || this.isEditMyCard) {
      this.pageTitle = $r('app.string.edit_my_card')
      this.mPresenter.isMyCard = true;
    }

    // 注册 新建/编辑联系人半模态 返回方法监听
    let accountInnerEventSearchs: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_ACCOUNTANTS_EVENT_ID_HIDE,
      priority: emitter.EventPriority.HIGH,
    }
    emitter.off(EmitterConstant.EMITTER_ACCOUNTANTS_EVENT_ID_HIDE);
    emitter.on(accountInnerEventSearchs, () => {
      // 侧滑返回 会触发，此时若键盘抬起，则先收起键盘
      if (this.keyBoardHeight > 0) {
        // 焦点转移，收起键盘
        focusControl.requestFocus('avatar');
      } else {
        this.destinationBackPress();
      }
    })

    // 注册 页面上下滑动的监听
    let textAreaEmitter: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_ACCOUNTANTS_TEXTAREA_ID,
      priority: emitter.EventPriority.HIGH,
    }
    emitter.on(textAreaEmitter, (data: emitter.EventData) => {
      this.listScroller.scrollBy(0, data.data?.height as number);
    })

    this.updateAccountantTitleClass();
    this.mPresenter.saveClickEnable();
    HiLog.i(TAG, 'the Page aboutToAppear End');
  }

  // 更新标题类
  updateAccountantTitleClass() {
    this.accountantTitleClass.isThemeActive = this.isThemeActive;
    this.accountantTitleClass.isOpenAccessibility = this.isOpenAccessibility;
    this.accountantTitleClass.fontSizeScale = this.fontSizeScale;
    this.accountantTitleClass.pageTitle = this.pageTitle;
    this.accountantTitleClass.isSave = this.isSave;
    this.accountantTitleClass.cancelOnClick = this.cancelOnClick;
    this.accountantTitleClass.savelOnClick = this.saveOnClick;
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear');
    emitter.off(emitterIdAddAccountants);
    emitter.off(EmitterConstant.EMITTER_ACCOUNTANTS_TEXTAREA_ID);
    this.deleteDialogController = null;
  }

  destinationPageShow(pixelMap: image.PixelMap, scaledPixelMap: image.PixelMap) {
    if (pixelMap) {
      this.mPresenter.photoChanged = true;
      this.mPresenter.photoPixelMap = pixelMap;
      this.photoPixelMap = scaledPixelMap;
      this.getImagePixelMap(scaledPixelMap);
      this.mPresenter.saveClickEnable();
    }
  }

  destinationBackPress() {
    HiLog.i(TAG, 'onBackPress');
    if (this.mPresenter.saveClickEnable()) {
      if (this.deleteDialogController) {
        this.deleteDialogController.open();
        DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
      }
    } else {
      if (this.updataShow === true) {
        this.isShowAccountants = false;
        DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
          AppStorage.setOrCreate('selectContactId', this.mPresenter.contactId);
        });
      } else {
        setTimeout(() => {
          this.isShowAccountants = false;
          if (this.updataShow === false) {
            AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility,
              'contactList_contacts_titleGuideClick_btn', 20);
          }
        }, this.isShowSmartWindow ? 50 : 0);
        // 取消保存不弹窗-值未作改动
        this.cancelAddContactParams.ISPOP = 0;
        this.cancelAddContactParams.ISSAVE = -1;
        DotUtil.getInstance().contactDot(this.cancelAddContactParams, CANCEL_ADD_CONTACT_EVENT);
        this.isSaveCon = 0;
      }
      if (this.uiExtentionSession != undefined) {
        this.sendBackMsg(this.uiExtentionSession);
      }
    }
  }

  // take photo
  async doTakePhoto() {
    try {
      // 如果是悬浮窗,设置拍照标记位
      if (AppStorage.get('isShowSmartWindow')) {
        AppStorage.setOrCreate(AppStorageConstant.EDIT_TAKE_PHOTO, true);
      }
      let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      CameraPickerUtil.pick(context, (pickerResult: PickerResult) => {
        if (pickerResult.resultCode === 0) {
          this.avatarImageUrl = pickerResult.resultUri;
          if (!StringUtil.isEmpty(this.avatarImageUrl)) {
            this.isShow = true;
          }
        } else {
          HiLog.e(TAG, 'camerapicker error,error code is: ' + pickerResult.resultCode);
          this.mPresenter.isLoadedPhoto = true;
          this.mPresenter.saveClickEnable();
        }
        AppStorage.setOrCreate(AppStorageConstant.EDIT_TAKE_PHOTO, false);
      })
    } catch (err) {
      AppStorage.setOrCreate(AppStorageConstant.EDIT_TAKE_PHOTO, false);
      this.mPresenter.isLoadedPhoto = true;
      this.mPresenter.saveClickEnable();
      HiLog.e(TAG, 'selected imageList error ' + err?.message + ', stack: ' + err?.stack);
    }
  }

  getImagePixelMap(pixelMap: image.PixelMap) {
    if (pixelMap) {
      getImagePackingData(pixelMap, (data: ArrayBuffer | null) => {
        if (data != null) {
          this.mPresenter.photo = new Uint8Array(data);
        }
      })
    }
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_ohos_id_color_list_separator'))
      .strokeWidth('1px')
      .width('100%')
      .alignSelf(ItemAlign.Stretch)
      .visibility(Visibility.Visible)
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  }

  @Builder
  doClickAvatar() {
    Menu() {
      if (this.mPresenter.photoPixelMap) {
        MenuItem({ content: $r('app.string.delete_picture') })
          .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
          .onChange(() => {
            this.mPresenter.photo = null;
            this.mPresenter?.photoPixelMap?.release();
            this.mPresenter.photoPixelMap = null;
            this.mPresenter.photoChanged = !this.mPresenter.photoChanged;
            this.mPresenter.textChange();
            this.mPresenter.saveClickEnable();
            this.photoDeleted = true;
          })
        if (!this.isPC) {
          this.MenuDivider();
        }
      }

      if (!this.isInVisionGlass) {
        MenuItem({ content: $r('app.string.take_photo') })
          .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .onChange(async () => {
            HiLog.i(TAG, 'take_photo');
            this.mPresenter.isLoadedPhoto = false;
            this.mPresenter.saveClickEnable();
            this.doTakePhoto();
          })
        if (!this.isPC) {
          this.MenuDivider();
        }
      }
      MenuItem({ content: $r('app.string.select_picture') })
        .margin({ top: this.isPC ? $r('sys.float.padding_level1') : $r('sys.float.padding_level0')})
        .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .height(this.isPC ? $r('app.float.id_card_image_mid') : undefined)
        .onChange(async () => {
          try {
            let photoAccessHelper = await DynamicLoadSoUtil.getInstance().loadPhotoAccessHelper();
            let photoSelectOptions = new photoAccessHelper.default.PhotoSelectOptions();
            photoSelectOptions.MIMEType = photoAccessHelper.default.PhotoViewMIMETypes.IMAGE_TYPE;
            photoSelectOptions.maxSelectNumber = 1;
            let photoPicker = new photoAccessHelper.default.PhotoViewPicker();
            photoPicker.select(photoSelectOptions).then((photoSelectResult: LooseObject) => {
              if (photoSelectResult) {
                HiLog.i(TAG, 'PhotoViewPicker.select successfully');
                this.avatarImageUrl = photoSelectResult.photoUris[0];
                if (!StringUtil.isEmpty(this.avatarImageUrl)) {
                  this.isShow = true;
                }
              }
            }).catch((err: BusinessError) => {
              HiLog.e(TAG, 'PhotoViewPicker.select failed with err: ' + err?.message + ', stack: ' + err?.stack);
            });
          } catch (err) {
            HiLog.e(TAG, 'PhotoViewPicker failed with err: ' + err);
          }
        })
    }
    .id('picture_edit')
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
      top: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2')
    })
    .backgroundBlurStyle(this.isPC ? BlurStyle.COMPONENT_REGULAR : undefined)
    .shadow({
      radius: this.isPC ? $r('sys.float.ohos_id_default_shadow_s') : 0
    })
    .radius(this.isPC ? $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
    .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }

  @Builder
  expandMore() {
    Button() {
      SymbolGlyph(this.isExpand ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
        .fontSize($r('app.float.id_card_image_small'))
        .fontColor([$r('app.color.skin_ohos_id_color_tertiary')])
        .flexShrink(0)
    }
    .id('chevron_btn')
    .accessibilityText(AccessibilityUtil.getInstance()
      .setAccessibilityText(this.isOpenAccessibility,
        this.isExpand ? $r('app.string.accessibility_collapse') : $r('app.string.accessibility_expand')))
    .height($r('app.float.id_item_height_mid'))
    .buttonStyle(ButtonStyleMode.TEXTUAL)
    .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })
    .stateEffect(false)
    .align(Alignment.Center)
    .margin({
      end: LengthMetrics.resource($r('app.float.id_card_margin_xl'))
    })
    .onClick(() => {
      HiLog.i(TAG, `expandMore onClick, isExpand: ${this.isExpand}`);
      this.isExpand = !this.isExpand;
      if (this.isExpand) {
        AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'workItemInitially', 100);
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(
          ResourceUtil.getStringByResource($r('app.string.accessibility_expanded')));
      } else {
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(
          ResourceUtil.getStringByResource($r('app.string.accessibility_collapsed')));
      }
    })
  }

  cancelOnClick = () => {
    if (this.isShowPickerMaskLayer) {
      this.isShowAccountants = false;
      if (this.uiExtentionSession != undefined) {
        this.sendBackMsg(this.uiExtentionSession);
      }
    } else {
      this.enableKeyboardOnFocus = false;
      focusControl.requestFocus('avatar');
      this.destinationBackPress();
    }
  }
  saveOnClick = () => {
    this.isSaveCon = 0;
    this.mPresenter.saveContact(ContactsGlobalThisHelper.GetGlobalThis().getUIExtensionContentSession(), !this.isVerde);
    if (this.curBp !== 'sm') {
      if (IndexPresenter.getInstance().curIndex === IndexPresenter.getInstance().callIndex) {
        CallRecordPresenter.getInstance().setPageShow(true);
      }
    }
    if (this.photoDeleted) {
      this.avtarDeletedCallBack?.()
    }
    this.emitterUpdata();
    this.isShowAccountants = false;
  }

  @Builder
  CutoutAvatar() {
    Column() {
      EditAvatar({
        isShow: $isShow,
        uri: this.avatarImageUrl,
        onFinish: this.destinationPageShow.bind(this),
        displayTitle: this.getDisplayTitle(),
        displaySubTitle: this.getSubTitle()
      })
    }
    .width('100%')
    .height('100%')
  }
  getDisplayTitle() : string {
    if (!StringUtil.isEmpty(this.mPresenter.contactInfoBefore.display_name)) {
      return this.mPresenter.contactInfoBefore.display_name;
    } else {
      return ResourceUtil.getStringByResource($r('app.string.name'))
    }
  }
  getSubTitle() : string {
    if (!StringUtil.isEmpty(this.mPresenter.contactInfoAfter.company)) {
      return this.mPresenter.contactInfoAfter.company;
    } else if (!StringUtil.isEmpty(this.mPresenter.contactInfoAfter.remarks)) {
      return this.mPresenter.contactInfoAfter.remarks;
    } else if (this.mPresenter.contactInfoAfter.phones.length > 0) {
      let phoneNum = this.mPresenter.getTextDisplay('phone', this.mPresenter.getData('phone', 0));
      return PhoneNumber.fromString(phoneNum).phoneNumFormat();
    } else {
      return '';
    }
  }
  // 编辑状态下是否展开姓名、公司、备注、职位
  expandNameCard() {
    this.isExpand = this.updataShow && !!(this.mPresenter.contactInfoBefore.company ||
    this.mPresenter.contactInfoBefore.position || this.mPresenter.contactInfoBefore.remarks);
  }

  // 编辑状态下是否显示电话号码信息
  isShowPhoneNumberList(): boolean {
    return this.mPresenter.getArray(this.mPresenter.contactInfoBefore.phones).length > 0
  }
  // 刷新铃声信息
  refreshRingtoneInfo() {
    // 刷新铃声
    let ringtoneTmp: RingtoneInfo = {
      ringtoneName: this.mPresenter.contactInfoBefore.personalNotificationRingtone,
      ringtoneFilePath: this.mPresenter.contactInfoBefore.personalRingtonePath,
      ringtonePath: this.mPresenter.contactInfoBefore.personalRingtone,
    };
    HiLog.w(TAG, `refreshRingtoneInfo, ringtoneInfo: ${StringUtil.maskSensitiveInfo(this.ringtoneInfo?.ringtoneName)},
     ringtoneTmp: ${StringUtil.maskSensitiveInfo(ringtoneTmp?.ringtoneName)}`);
    this.ringtoneInfo = ringtoneTmp;
  }

  // 是否展开更多个人信息
  expandMoreInfo() {
    let emailIsNull: boolean = !!(this.mPresenter.getEmails.length && this.mPresenter.getEmails[0].item.address);
    let websiteIsNull: boolean = !!(this.mPresenter.getArrayCommon(this.mPresenter.contactInfoBefore.websites)
      .length && this.mPresenter.getArrayCommon(this.mPresenter.contactInfoBefore.websites)[0].item);
    let aimIsNull: boolean = !!(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.aims)
      .length && this.mPresenter.getArray(this.mPresenter.contactInfoBefore.aims)[0].item.aimName);
    let housesIsNull: boolean = !!(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.houses)
      .length && this.mPresenter.getArray(this.mPresenter.contactInfoBefore.houses)[0].item.houseName);
    let eventsIsNull: boolean = !!(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.events)
      .length && this.mPresenter.getArray(this.mPresenter.contactInfoBefore.events)[0].item.data);
    let relationshipsIsNull: boolean = !!(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.relationships)
      .length && this.mPresenter.getArray(this.mPresenter.contactInfoBefore.relationships)[0].item.relationships);
    let ringtoneIsNull: boolean = StringUtil.isEmpty(this.mPresenter.contactInfoBefore.personalRingtone);
    this.isExpandMore = this.updataShow && (emailIsNull || websiteIsNull || aimIsNull || housesIsNull ||
      eventsIsNull || relationshipsIsNull || !ringtoneIsNull);
  }

  closeKeyBoard() {
    let inputMethodController = inputMethod.getController();
    try {
      inputMethodController.stopInputSession((error, result) => {
        if (error !== undefined) {
          HiLog.e(TAG, 'Failed to stopInputSession: ' + error?.message + ', stack: ' + error?.stack);
          return;
        }
        if (result) {
          HiLog.i(TAG, 'Succeeded in stopping inputSession.');
        } else {
          HiLog.e(TAG, 'Failed to stopInputSession.');
        }
      });
    } catch (error) {
      HiLog.e(TAG, 'Failed to stopInputSession: ' + error?.message + ', stack: ' + error?.stack);
    }
  }

  @Builder
  sheetComponentBuilder() {
    UIExtensionComponent(
      {
        bundleName: 'com.ohos.contactsdataability',
        abilityName: 'PermissionExtAbility',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI'
        }
      }
    )
      .onReceive((data) => {
        this.inShowCalendar = false;
        sharedPreferencesUtils.saveToPreferences('showBirthdayBanners', false);
        emitter.emit(EmitterConstant.UPDATE_SHOW_BIRTHDAY_BANNERS_EMITTER_ID);
        if (Number(data['result']) === 1) {
          let conditionArgs = new dataSharePredicates.DataSharePredicates();
          ContactRepository.getInstance()
            .getDataAbilityHelper()
            .then((dataAbilityHelper: dataShare.DataShareHelper) => {
              dataAbilityHelper.query(Contacts.CONTACT_SYNC_CALENDER_URI, conditionArgs, ContactListItem.COLUMNS)
            })
        }
      })
      .width(0)
      .height(0)
  }

  @Builder
  ListItemInitially(placeholder: Resource | string, isShowDivider: boolean, itemKey: string, callBack: () => void) {
    Column() {
      Button(placeholder)
        .fontColor($r('app.color.skin_ohos_id_color_text_hint'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .width('100%')
        .fontSize($r('sys.float.Body_L'))
        .align(i18n.isRTL(i18n.System.getSystemLanguage()) ? Alignment.End : Alignment.Start)
        .stateEffect(false)
        .padding({
          start: LengthMetrics.resource($r('sys.float.padding_level6')),
          end: LengthMetrics.resource($r('sys.float.padding_level6'))
        })
        .backgroundColor(Color.Transparent)
        .focusable(true)
        .key(itemKey)
        .onClick(() => {
          callBack();
        })

      if (isShowDivider) {
        Divider()
          .color($r('app.color.skin_ohos_id_color_list_separator'))
          .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
      }
    }
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
    .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level2') })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  AddItem(placeholder: Resource | string, isShowDivider: boolean, itemKey: string, callBack: () => void) {
    Column() {
      Button() {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text(placeholder)
            .fontColor($r('app.color.skin_ohos_id_color_text_hint'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .flexGrow(1)
            .fontSize($r('sys.float.Body_L'))

          SymbolGlyph($r('sys.symbol.plus_circle_fill'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_ohos_id_color_connected')])
            .margin({
              end: LengthMetrics.resource(EnvironmentProp.isPC() ? $r('app.float.id_card_margin_xl') :
                this.curBp === 'lg' ? $r('app.float.id_card_margin_max') : $r('app.float.id_card_margin_xl'))
            })
        }
        .width('100%')
        .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
      }
      .key(itemKey)
      .align(Alignment.Center)
      .stateEffect(false)
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .backgroundColor(Color.Transparent)
      .focusable(true)
      .alignSelf(ItemAlign.Stretch)
      .margin({ start: LengthMetrics.resource($r('sys.float.padding_level6')) })
      .onClick(() => {
        callBack();
      })

      if (isShowDivider) {
        Divider()
          .color($r('app.color.skin_ohos_id_color_list_separator'))
          .padding({ left: $r('sys.float.padding_level6'), right: $r('app.float.id_card_margin_xl') })
      }
    }
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
    .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level2') })
  }


  build() {
    Flex({ direction: FlexDirection.Column }) {
      List({ scroller: this.listScroller }) {
        // 头像
        ListItem() {
          RelativeContainer() {
            Image(!this.mPresenter.photoPixelMap ? $r('app.media.ic_user_portrait') :
              this.photoPixelMap ? this.photoPixelMap : this.mPresenter.photoPixelMap)
              .height($r('app.float.id_item_height_large'))
              .width($r('app.float.id_item_height_large'))
              .objectFit(ImageFit.Auto)
              .draggable(false)
              .clip(true)
              .borderRadius('28vp')
              .onError((err) => {
                HiLog.e(TAG, `avatar load err: ${err.message}`);
                this.mPresenter?.photoPixelMap?.release();
              })
              .onComplete(() => {
                HiLog.w(TAG, `avatar load complete!`);
              })
              .alignRules({
                top: { anchor: '__container__', align: VerticalAlign.Top },
                start: { anchor: '__container__', align: HorizontalAlign.Start }
              })

            SymbolGlyph($r('sys.symbol.square_and_pencil_fill'))
              .fontSize($r('app.float.id_card_margin_10'))
              .fontColor([$r('app.color.skin_icon_on_primary')])
              .padding({
                top: 3,
                right: 3,
                bottom: 3,
                left: 3
              })
              .backgroundColor('#C0C2C4')
              .borderRadius(9.5)
              .borderWidth(1.5)
              .borderColor($r('app.color.color_bind_sheet_background'))
              .offset((i18n.isRTL(i18n.System.getSystemLanguage()) ? ({x: 13.5, y: -17.5 }) :
                ({x: -13.5, y: -17.5 })))
              .alignRules({
                top: { anchor: '__container__', align: VerticalAlign.Bottom },
                start: { anchor: '__container__', align: HorizontalAlign.End }
              })
          }
          .height($r('app.float.id_item_height_large'))
          .width($r('app.float.id_item_height_large'))
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_edit_avatar')))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .height($r('app.float.id_item_height_large'))
          .width($r('app.float.id_item_height_large'))
          .margin({ top: $r('app.float.id_card_margin_large') })
          .bindMenu(this.mSystemModeController.getIsEnableEditAvatar() ? this.doClickAvatar : undefined, {
            placement: Placement.Bottom,
            backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
            backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined
          })
          .onClick(() => {
            this.enableKeyboardOnFocus = false;
            if (!this.mSystemModeController.getIsEnableEditAvatar()) {
              showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
            }
          })
          .onFocus(() => {
            this.listScroller.scrollEdge(Edge.Top)
          })
          .id('avatar')
        }
        .width('100%')
        .align(Alignment.Center)

        // 保存至
        ListItem() {
          Column() {
            Text(this.accountName == '' ? EnvironmentProp.isDeviceTypeTablet() ? $r('app.string.save_to_tablet') : this.isPC ?
              $r('app.string.save_to_pc') : $r('app.string.save_to_phone') : $r('app.string.save_to_account', this.accountName))
              .constraintSize({
                minHeight: $r('app.float.id_groupList_lineHeight_xxl')
              })
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({
                top: $r('app.float.id_card_item_margin_bottom'),
              })
          }
        }
        .width('100%')
        .align(Alignment.Center)

        // 姓名单位备注
        ListItemGroup() {
          ListItem() {
            Column() {
              Row() {
                TextInput({
                  placeholder: $r('app.string.name'),
                  text: this.mPresenter.contactInfoBefore.display_name
                })
                  .maxLength(256)
                  .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
                  .fontColor(this.params?.displayNameHighlight ? $r('app.color.skin_font_emphasize') :
                  $r('app.color.skin_font_primary'))
                  .defaultFocus(!this.updataShow && !this.isEditMyCard) // 编辑页不显示光标
                  .enableKeyboardOnFocus(this.getIsEnableKeyboardOnFocus())
                  .width('calc(100% - 36vp)')
                  .placeholderColor(this.isThemeActive ? $r('app.color.skin_font_secondary') : undefined)
                  .constraintSize({
                    minHeight: $r('app.float.id_item_height_mid')
                  })
                  .backgroundColor(Color.Transparent)
                  .focusable(true)
                  .padding({
                    left: $r('app.float.id_card_margin_xl'),
                    right: $r('app.float.id_card_margin_xl')
                  })
                  .onFocus(() => {
                    this.nameTextInputFocus = true;
                  })
                  .onBlur(() => {
                    this.nameTextInputFocus = false;
                  })
                  .onChange((value) => {
                    this.mPresenter.contactInfoAfter.display_name = value;
                    this.mPresenter.textChange();
                  })
                this.expandMore()
              }

              if (this.isExpand) {
                Divider()
                  .strokeWidth(this.nameTextInputFocus ? '2px' : '1px')
                  .color(this.isExpand ?
                    (this.nameTextInputFocus ? $r('app.color.skin_ohos_id_color_primary', '60%') :
                    $r('app.color.skin_ohos_id_color_list_separator')) :
                  $r('app.color.skin_comp_background_primary'))
                  .margin({
                    left: $r('app.float.id_card_margin_xl'),
                    right: $r('app.float.id_card_margin_xl')
                  })
                  .accessibilityLevel('no')
              }
            }
          }
          .padding({
            top: $r('app.float.id_card_margin_mid'),
            bottom: $r('app.float.id_card_margin_mid')
          })

          if (this.isExpand) {
            ListItem() {
              TextInput({
                placeholder: $r('app.string.email_type_work'),
                text: this.mPresenter.contactInfoBefore.company
              })
                .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
                .fontColor(this.isThemeActive ? $r('app.color.skin_font_primary') : undefined)
                .underlineColor(this.isThemeActive ? {
                  normal: $r('app.color.skin_ohos_id_color_list_separator'),
                  typing: $r('app.color.skin_ohos_id_color_primary', 0.6)
                } : undefined)
                .placeholderColor(this.isThemeActive ? $r('app.color.skin_font_secondary') : undefined)
                .maxLength(256)
                .enableKeyboardOnFocus(false)
                .showUnderline(true)
                .padding({
                  left: $r('app.float.id_card_margin_xl'),
                  right: $r('app.float.id_card_margin_xl')
                })
                .backgroundColor(Color.Transparent)
                .onChange((arg) => {
                  this.mPresenter.contactInfoAfter.company = arg.valueOf();
                  this.mPresenter.textChange();
                })
                .key('workItemInitially')
            }
            .constraintSize({
              minHeight: $r('app.float.id_item_height_large')
            })
            .padding({
              top: $r('app.float.id_card_margin_mid'),
              bottom: $r('app.float.id_card_margin_mid')
            })

            ListItem() {
              TextInput({
                placeholder: $r('app.string.position'),
                text: this.mPresenter.contactInfoBefore.position
              })
                .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
                .fontColor(this.isThemeActive ? $r('app.color.skin_font_primary') : undefined)
                .underlineColor(this.isThemeActive ? {
                  normal: $r('app.color.skin_ohos_id_color_list_separator'),
                  typing: $r('app.color.skin_ohos_id_color_primary', 0.6)
                } : undefined)
                .placeholderColor(this.isThemeActive ? $r('app.color.skin_font_secondary') : undefined)
                .maxLength(256)
                .enableKeyboardOnFocus(false)
                .showUnderline(true)
                .padding({
                  left: $r('app.float.id_card_margin_xl'),
                  right: $r('app.float.id_card_margin_xl')
                })
                .backgroundColor(Color.Transparent)
                .onChange((arg) => {
                  this.mPresenter.contactInfoAfter.position = arg.valueOf();
                  this.mPresenter.textChange();
                })
            }
            .constraintSize({
              minHeight: $r('app.float.id_item_height_large')
            })
            .padding({
              top: $r('app.float.id_card_margin_mid'),
              bottom: $r('app.float.id_card_margin_mid')
            })

            ListItem() {
              TextArea({
                placeholder: $r('app.string.remarks'),
                text: this.mPresenter.contactInfoBefore.remarks
              })
                .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
                .fontColor(this.isThemeActive ? $r('app.color.skin_font_primary') : undefined)
                .padding({
                  left: $r('app.float.id_card_margin_xl'),
                  right: $r('app.float.id_card_margin_xl')
                })
                .placeholderColor(this.isThemeActive ? $r('app.color.skin_font_secondary') : undefined)
                .enableKeyboardOnFocus(false)
                .maxLength(1024)
                .backgroundColor(Color.Transparent)
                .onChange((arg) => {
                  this.mPresenter.contactInfoAfter.remarks = arg.valueOf();
                  this.mPresenter.textChange();
                })
            }
            .constraintSize({
              minHeight: $r('app.float.id_item_height_large')
            })
            .padding({
              top: $r('app.float.id_card_margin_mid'),
              bottom: $r('app.float.id_card_margin_mid')
            })
          }
        }
        .width('100%')
        .align(Alignment.Center)
        .backgroundColor($r('app.color.skin_comp_background_list_card'))
        .margin({
          top: $r('app.float.id_card_margin_xxl')
        })
        .padding({
          top: $r('app.float.id_card_margin_mid'),
          bottom: $r('app.float.id_card_margin_mid'),
        })
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level8') : $r('sys.float.corner_radius_level10'))

        // 电话
        ListItemGroup() {
          if (this.mPresenter.getArray(this.mPresenter.contactInfoBefore.phones).length) {
            ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.phones)
              , (item: ContactInterface<PhoneNumBean>, index: number) => {
                ListItem() {
                  ItemList({
                    inputType: InputType.PhoneNumber,
                    mPresent: $mPresenter,
                    index: item?.i,
                    typeName: 'phone',
                    placeholder: $r('app.string.phone_number'),
                    isShowAdd: $isShowAddPhoneNumber,
                    isEnableKeyboardOnFocus: $enableKeyboardOnFocus
                  })
                }
                .width('100%')
                .margin({ bottom: this.fontSizeScale === 6 ? '5vp' : undefined })
              }, (item: ContactInterface<PhoneNumBean>): string => item?.i.toString())

            if (this.isShowAddPhoneNumber) {
              ListItem() {
                this.AddItem($r('app.string.add_number'), false, 'phoneAddItem', () => {
                  this.mPresenter.addMore('phone');
                  setTimeout(() => {
                    let index = this.mPresenter.contactInfoBefore.phones.length;
                    context.eventHub.emit('focus');
                    AccessibilityUtil.getInstance()
                      .sendAccessibilityEvent(this.isOpenAccessibility, `phone${index}`, 10);
                  }, 30)
                })
              }
            }
          } else {
            ListItem() {
              this.ListItemInitially($r('app.string.phone_number'), false, 'phoneItemInitially', () => {
                this.mPresenter.addMore('phone');
                this.isShowAddPhoneNumber = false;
                setTimeout(() => {
                  context.eventHub.emit('focus');
                  AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'phone1', 10);
                }, 30)
              })
            }
          }
        }
        .width('100%')
        .align(Alignment.Center)
        .backgroundColor($r('app.color.skin_comp_background_list_card'))
        .margin({
          top: $r('app.float.id_card_margin_xl')
        })
        .padding({
          top: $r('app.float.id_card_margin_mid'),
          bottom: $r('app.float.id_card_margin_mid'),
        })
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level8') : $r('sys.float.corner_radius_level10'))

        if (this.isShowMore || this.isExpandMore) {
          ListItemGroup() {
            // 邮件
            if (this.mPresenter.getArray(this.mPresenter.contactInfoBefore.emails).length) {
              ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.emails)
                , (item: ContactInterface<EmailBean>, index: number) => {
                  ListItem() {
                    ItemList({
                      inputType: InputType.Email,
                      mPresent: $mPresenter,
                      index: item?.i,
                      typeName: 'email',
                      placeholder: $r('app.string.emails'),
                      isShowAdd: $isShowAddEmail,
                      isEnableKeyboardOnFocus: $enableKeyboardOnFocus
                    })
                  }
                  .width('100%')
                }, (item: ContactInterface<EmailBean>): string => item?.i.toString())

              if (this.isShowAddEmail) {
                ListItem() {
                  this.AddItem($r('app.string.add_email'), true, 'emailAddItem', () => {
                    this.mPresenter.addMore('email');
                    setTimeout(() => {
                      let index = this.mPresenter.contactInfoBefore.emails.length;
                      context.eventHub.emit('focus');
                      AccessibilityUtil.getInstance()
                        .sendAccessibilityEvent(this.isOpenAccessibility, `email${index}`, 10);
                    }, 30)
                  })
                }
              }
            } else {
              ListItem() {
                this.ListItemInitially($r('app.string.emails'), true, 'emailItemInitially', () => {
                  this.mPresenter.addMore('email');
                  this.isShowAddEmail = false;
                  setTimeout(() => {
                    context.eventHub.emit('focus');
                    AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'email1', 10);
                  }, 30)
                })
              }
            }

            // 网站
            if (this.mPresenter.getArrayCommon(this.mPresenter.contactInfoBefore.websites).length) {
              ForEach(this.mPresenter.getArrayCommon(this.mPresenter.contactInfoBefore.websites)
                , (item: ContactInterface<string>, index: number) => {
                  ListItem() {
                    ItemList({
                      mPresent: $mPresenter,
                      inputType: InputType.URL,
                      index: item?.i,
                      typeName: 'website',
                      placeholder: $r('app.string.website'),
                      isShowAdd: $isShowAddWebsite,
                      isEnableKeyboardOnFocus: $enableKeyboardOnFocus
                    })
                  }
                  .width('100%')
                  .constraintSize({
                    minHeight: $r('app.float.id_item_height_large')
                  })
                }, (item: ContactInterface<string>): string => item?.i?.toString())

              if (this.isShowAddWebsite) {
                ListItem() {
                  this.AddItem($r('app.string.add_website'), true, 'websiteAddItem', () => {
                    this.mPresenter.addMore('website');
                    setTimeout(() => {
                      let index = this.mPresenter.contactInfoBefore.websites.length;
                      context.eventHub.emit('focus');
                      AccessibilityUtil.getInstance()
                        .sendAccessibilityEvent(this.isOpenAccessibility, `website${index}`, 10);
                    }, 30)
                  })
                }
              }
            } else {
              ListItem() {
                this.ListItemInitially($r('app.string.website'), true, 'websiteItemInitially', () => {
                  this.mPresenter.addMore('website');
                  this.isShowAddWebsite = false;
                  setTimeout(() => {
                    context.eventHub.emit('focus');
                    AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'website1', 10);
                  }, 30)
                })
              }
            }

            // 即时信息
            if (this.mPresenter.getArray(this.mPresenter.contactInfoBefore.aims).length) {
              ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.aims)
                , (item: ContactInterface<AIMBean>, index: number) => {
                  ListItem() {
                    ItemList({
                      mPresent: $mPresenter,
                      index: item?.i,
                      typeName: 'AIM',
                      placeholder: $r('app.string.instant_messaging'),
                      isShowAdd: $isShowAddMessaging,
                      isEnableKeyboardOnFocus: $enableKeyboardOnFocus
                    })
                  }
                  .width('100%')
                }, (item: ContactInterface<AIMBean>): string => item?.i.toString())

              if (this.isShowAddMessaging) {
                ListItem() {
                  this.AddItem($r('app.string.add_message'), false, 'AIMAddItem', () => {
                    this.mPresenter.addMore('AIM');
                    setTimeout(() => {
                      let index = this.mPresenter.contactInfoBefore.aims.length;
                      context.eventHub.emit('focus');
                      AccessibilityUtil.getInstance()
                        .sendAccessibilityEvent(this.isOpenAccessibility, `AIM${index}`, 10);
                    }, 30)
                  })
                }
              }
            } else {
              ListItem() {
                this.ListItemInitially($r('app.string.instant_messaging'), false, 'AIMItemInitially', () => {
                  this.mPresenter.addMore('AIM');
                  this.isShowAddMessaging = false;
                  setTimeout(() => {
                    context.eventHub.emit('focus');
                    AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'AIM1', 10);
                  }, 30)
                })
              }
            }
          }
          .width('100%')
          .align(Alignment.Center)
          .backgroundColor($r('app.color.skin_comp_background_list_card'))
          .margin({
            top: $r('app.float.id_card_margin_xl')
          })
          .padding({
            top: $r('app.float.id_card_margin_mid'),
            bottom: $r('app.float.id_card_margin_mid'),
          })
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level8') : $r('sys.float.corner_radius_level10'))

          ListItemGroup() {
            // 地址
            if (this.mPresenter.getArray(this.mPresenter.contactInfoBefore.houses).length) {
              ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.houses)
                , (item: ContactInterface<HouseBean>, index: number) => {
                  ListItem() {
                    ItemList({
                      mPresent: $mPresenter,
                      index: item?.i,
                      typeName: 'house',
                      placeholder: $r('app.string.address_add'),
                      isShowAdd: $isShowAddAddress,
                      isEnableKeyboardOnFocus: $enableKeyboardOnFocus
                    })
                  }
                  .width('100%')
                }, (item: ContactInterface<HouseBean>): string => item?.i.toString())

              if (this.isShowAddAddress) {
                ListItem() {
                  this.AddItem($r('app.string.add_Address'), true, 'houseAddItem', () => {
                    this.mPresenter.addMore('house');
                    setTimeout(() => {
                      let index = this.mPresenter.contactInfoBefore.houses.length;
                      context.eventHub.emit('focus');
                      AccessibilityUtil.getInstance()
                        .sendAccessibilityEvent(this.isOpenAccessibility, `house${index}`, 10);
                    }, 30)
                  })
                }
              }
            } else {
              ListItem() {
                this.ListItemInitially($r('app.string.address_add'), true, 'houseItemInitially', () => {
                  this.mPresenter.addMore('house');
                  this.isShowAddAddress = false;
                  setTimeout(() => {
                    context.eventHub.emit('focus');
                    AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'house1', 10);
                  }, 30)
                })
              }
            }

            // 生日
            if (this.mPresenter.getArray(this.mPresenter.contactInfoBefore.events).length) {
              ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.events)
                , (item: ContactInterface<EventBean>, index: number) => {
                  ListItem() {
                    ItemEvent({
                      mPresent: $mPresenter,
                      index: item?.i,
                      typeName: 'events',
                      length: this.mPresenter.getArray(this.mPresenter.contactInfoBefore.events).length,
                      isShowAdd: $isShowAddBirthday
                    })
                  }
                  .width('100%')
                }, (item: ContactInterface<EventBean>): string => item?.i.toString())

              if (!StringUtil.isEmpty(this.mPresenter.getTextDisplay('events',
                this.mPresenter.getData('events', 0)))) {
                ListItem() {
                  this.AddItem($r('app.string.other_important_dates'), true, 'eventsAddItem', () => {
                    this.mPresenter.addMore('events');
                    setTimeout(() => {
                      let index = this.mPresenter.contactInfoBefore.events.length;
                      focusControl.requestFocus(`events${index}`);
                      AccessibilityUtil.getInstance()
                        .sendAccessibilityEvent(this.isOpenAccessibility, `events${index}`, 10);
                    }, 30)
                  })
                }
              }
            } else {
              ListItem() {
                this.ListItemInitially($r('app.string.birthday_type_grebirthday'), true, 'eventsItemInitially', () => {
                  this.mPresenter.addMore('events');
                  this.isShowAddBirthday = false;
                  this.inShowCalendar = true;
                  setTimeout(() => {
                    focusControl.requestFocus('events1');
                    AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'events1', 10);
                  }, 30)
                })
              }
            }

            // 关联人
            if (this.mPresenter.getArray(this.mPresenter.contactInfoBefore.relationships).length) {
              ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.relationships)
                , (item: ContactInterface<AssociatedPersonBean>, index: number) => {
                  ListItem() {
                    ItemList({
                      mPresent: $mPresenter,
                      index: item?.i,
                      typeName: 'relationships',
                      placeholder: $r('app.string.relation'),
                      isShowAdd: $isShowAddAssociation,
                      isEnableKeyboardOnFocus: $enableKeyboardOnFocus
                    })
                  }
                  .width('100%')
                }, (item: ContactInterface<AssociatedPersonBean>): string => item?.i.toString())

              if (this.isShowAddAssociation) {
                ListItem() {
                  this.AddItem($r('app.string.add_relation'), false, 'relationshipsAddItem', () => {
                    this.mPresenter.addMore('relationships');
                    setTimeout(() => {
                      let index = this.mPresenter.contactInfoBefore.relationships.length;
                      context.eventHub.emit('focus');
                      AccessibilityUtil.getInstance()
                        .sendAccessibilityEvent(this.isOpenAccessibility, `relationships${index}`, 10);
                    }, 30)
                  })
                }
              }
            } else {
              ListItem() {
                this.ListItemInitially($r('app.string.relation'), false, 'relationshipsItemInitially', () => {
                  this.mPresenter.addMore('relationships');
                  this.isShowAddAssociation = false;
                  setTimeout(() => {
                    context.eventHub.emit('focus');
                    AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility, 'relationships1', 10);
                  }, 30)
                })
              }
            }
          }
          .width('100%')
          .align(Alignment.Center)
          .backgroundColor($r('app.color.skin_comp_background_list_card'))
          .margin({
            top: $r('app.float.id_card_margin_xl')
          })
          .padding({
            top: $r('app.float.id_card_margin_mid'),
            bottom: $r('app.float.id_card_margin_mid'),
          })
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level8') : $r('sys.float.corner_radius_level10'))

          // 铃声
          if (call.hasVoiceCapability() && !this.mPresenter.isMyCard) {
            ListItem() {
              Flex({
                direction: this.fontSizeScale >= 4 ? FlexDirection.Column : FlexDirection.Row,
                justifyContent: FlexAlign.SpaceBetween,
                alignItems: ItemAlign.Start
              }) {
                Column() {
                  Text($r('app.string.phone_ringtone'))
                    .fontWeight(FontWeight.Medium)
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)
                .constraintSize({
                  minWidth: $r('app.float.account_ItemList_menu_select_and_ic_spinner_width'),
                  minHeight: $r('app.float.id_item_height_large')
                })

                Row() {
                  Text(!StringUtil.isEmpty(this.ringtoneInfo.ringtoneName)
                    ? (this.ringtoneInfo.ringtoneName == 'N' ? $r('app.string.ringtones_mute') :
                    this.ringtoneInfo.ringtoneName.replace(/(.*).mp4/, '$1')) : $r('app.string.default_value'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontWeight(FontWeight.Regular)
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                    .flexShrink(1)

                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize($r('app.float.id_card_image_small'))
                    .fontColor([$r('app.color.skin_icon_fourth')])
                    .flexShrink(0)
                    .margin({ start:LengthMetrics.resource($r('sys.float.padding_level2')) })
                }
                .alignSelf(ItemAlign.Stretch)
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)
                .constraintSize({
                  minHeight: $r('app.float.id_item_height_large')
                })
              }
              .width('100%')
              .constraintSize({
                minHeight: $r('app.float.id_item_height_large')
              })
              .padding({
                top: FontScaleState.fetchSeniorListSpace(),
                bottom: FontScaleState.fetchSeniorListSpace(),
                left: $r('sys.float.padding_level4'),
                right: $r('sys.float.padding_level4'),
              })
              .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
              })
              .borderRadius($r('sys.float.corner_radius_level8'))
            }
            .onClick(() => {
              this.isAccountRingToneShow = true;
            })
            .width('100%')
            .backgroundColor($r('app.color.skin_comp_background_list_card'))
            .margin({ top: $r('app.float.id_card_margin_xl') })
            .padding($r('sys.float.padding_level2'))
            .borderRadius($r('sys.float.corner_radius_level10'))
          }
        } else {
          ListItem() {
            Button() {
              Row() {
                Text($r('app.string.mores'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Regular)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))

                SymbolGlyph($r('sys.symbol.chevron_down'))
                  .fontSize($r('app.float.id_card_image_small'))
                  .fontColor([$r('app.color.skin_ohos_id_color_tertiary')])
                  .flexShrink(0)
                  .margin({
                    start: LengthMetrics.resource($r('app.float.id_card_margin_sm'))
                  })
              }
              .constraintSize({
                minHeight: $r('app.float.id_card_image_small')
              })
              .alignItems(VerticalAlign.Center)
            }
            .margin({ top: $r('app.float.id_card_margin_large') })
            .padding(this.isPC ? { top: 4, bottom: 4, left: 11, right: 5 } : undefined)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .stateEffect(false)
            .onClick(() => {
              // 新建或编辑联系人点击更多
              DotUtil.getInstance().contactDot(this.customizedParams, CLICK_ADD_MORE_EVENT);
              this.isShowMore = true;
              if (!this.isExpand) {
                this.isExpand = true;
                AccessibilityUtil.getInstance()
                  .sendAccessibilityEvent(this.isOpenAccessibility, 'workItemInitially', 30);
              } else {
                AccessibilityUtil.getInstance()
                  .sendAccessibilityEvent(this.isOpenAccessibility, 'emailItemInitially', 30);
              }
              setTimeout(() => {
                this.closeKeyBoard();
              }, 50)
            })
          }
          .width('100%')
          .align(Alignment.Center)
        }
      }
      .width('100%')
      .height('100%')
      .contentEndOffset(CONTENT_END_OFFSET)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .id('call_no_bnt')
      .onScrollStart(() => {
        if (this.isScrollStop) {
          this.isScrollStop = false;
          this.closeKeyBoard();
        }
      })
      .onScrollStop(() => {
        this.isScrollStop = true;
      })
      .bindSheet(this.isAccountRingToneShow, this.ShowRingtoneSelectionView(), {
        dragBar: true,
        showClose: false,
        preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
        backgroundColor: this.isThemeActive ? $r('app.color.skin_background_secondary') : undefined,
        shouldDismiss: (sheetDismiss: SheetDismiss) => {
          ResourceAudioManager.releaseRing();
          emitter.emit({
            eventId: EmitterConstant.EVENT_LIST_RING_TONE_PLAY,
            priority: emitter.EventPriority.HIGH
          })
          this.isAccountRingToneShow = !this.isAccountRingToneShow;
        },
        onWillSpringBackWhenDismiss: () => {
          // 如果注册该回调函数，则不会回弹，由开发者控制下滑关闭时是否回弹。
          // 在回调函数中可以通过调用springBack来实现回弹效果。
        },
      })

      Column() {
        if (this.inShowCalendar) {
          Row() {
            this.sheetComponentBuilder();
          }
          .width(0)
          .height(0)
        }
      }
    }
    .padding({
      left: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
      right: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8')
    })
    .width('100%')
    .height('100%')
    .bindContentCover($$this.isShow, this.CutoutAvatar(), {
      modalTransition: ModalTransition.NONE,
      onAppear: () => {
        this.mPresenter.isLoadedPhoto = true;
        this.mPresenter.saveClickEnable();
      }
    })
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
  }

  @Styles
  normalStyles() {
    .backgroundColor('app.color.skin_ohos_id_color_list_card_bg')
  }

  @Builder
  ShowRingtoneSelectionView() {
    Column() {
      RingtoneSelection({
        ringtoneInfo: this.ringtoneInfo,
        isRingToneShow: this.isAccountRingToneShow
      })
    }.width('100%').height('100%')
  }
}

//标题需要的变量类
export class AccountantTitleClass {
  // 是否启动主题
  public isThemeActive: boolean = false;
  // 是否启动无障碍
  public isOpenAccessibility: boolean = false;
  public fontSizeScale: number = 0;
  public pageTitle: Resource = $r('app.string.create_contact')
  public isSave: boolean = false;
  //取消按钮操作
  public cancelOnClick = () => {
  }
  //保存按钮操作
  public savelOnClick = () => {
  }
}

const isPC: boolean = EnvironmentProp.isPC();

@Builder
export function NavDestinationHeaderView($$: AccountantTitleClass) {
  Row() {
    Row() {
      WithTheme($$.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
        Button() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize($r('app.float.id_card_margin_max'))
            .fontColor([$r('app.color.skin_ohos_id_color_primary')])
        }
        .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
        .buttonStyles()
        .id('cancel_btn')
        .onClick(() => {
          $$.cancelOnClick();
        })
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText($$.isOpenAccessibility, $r('app.string.accessibility_cancel')))
	    .type(isPC ? ButtonType.Normal : ButtonType.Circle)
        .borderRadius(isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
      }

      Text(ResourceUtil.getStringByResource($$.pageTitle))
        .fontSize(FontScaleState.isStandardGeer($$.fontSizeScale) ?
        $r('sys.float.Title_S') : $r('app.float.id_card_image_s'))
        .fontColor($r('app.color.skin_font_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({
          start: EnvironmentProp.isPC() ? LengthMetrics.resource($r('sys.float.padding_level8')) :
          LengthMetrics.resource($r('sys.float.padding_level4'))
        })
    }

    WithTheme($$.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
      Button() {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize($r('app.float.id_card_margin_max'))
          .fontColor([$r('app.color.skin_ohos_id_color_primary')])
      }
      .id('save_click_btn')
      .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })
      .buttonStyles()
      .onClick(() => {
        $$.savelOnClick();
      })
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText($$.isOpenAccessibility, $r('app.string.accessibility_done')))
      .enabled($$.isSave)
      .type(isPC ? ButtonType.Normal : ButtonType.Circle)
      .borderRadius(isPC ? $r('sys.float.corner_radius_level2') : 0)
      .width($r('app.float.id_card_image_mid'))
      .height($r('app.float.id_card_image_mid'))
    }
  }
  .justifyContent(FlexAlign.SpaceBetween)
  .alignItems(VerticalAlign.Center)
  .constraintSize({
    minHeight: $r('app.float.id_item_height_large')
  })
  .flexShrink(0)
  .width('100%')
}
