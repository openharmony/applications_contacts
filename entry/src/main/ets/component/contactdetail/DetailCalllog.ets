/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CallType, FeaturesType, FeaturesUtil } from '../../../../../../feature/call/src/main/ets/entity/CallLog';
import VibrationUtils from '../../util/VibrationUtils';
import { VibrationEffect } from '../../model/type/EnumUtil';
import call from '@ohos.telephony.call';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { CustomizedParams, dialogDataStruct, RecorderLog } from '../../model/type';
import { HiLog } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import { showVideoChangeToVoiceToast } from '../../pages/dialer/callRecord/AllRecord';
import DotUtil from '../../util/DotUtil';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '../../util/ResourceUtil';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import LooseObject from '../../model/type/LooseObject';
import { SelectDialogBuilder } from '../../pages/dialog/SelectSimIdDialog';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../feature/sim/SimCardState';
import { RoamingManager } from '../../feature/roaming/RoamingManager';
import { FontScaleState } from '../../util/fontScaleState';
import dotCommon, {
  abstractParams,
  abstractRestart,
  abstractClick,
  autoUpdateDataParams,
  abstractFail,
  customParams,
  deleteLogDialogParams,
  videoCallParams } from '../../util/DotCommon';
import DetailPresenter from '../../presenter/contact/detail/DetailPresenter';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil'
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber'
import { CALL_TYPE_CELIA, isVoiceAppEnabled, startCallAssistantRecord } from '../../util/CallAssistantUtil'
import { application, common } from '@kit.AbilityKit';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { display, LengthMetrics, window } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { CallLog } from '../../../../../../feature/call';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { DISABLED_OPACITY_STRING, showToast, SystemModeController } from '../../util/SystemModeController';
import { BusinessError } from '@kit.BasicServicesKit';
import { sim } from '@kit.TelephonyKit';
import { uiEffect } from '@kit.ArkGraphics2D';
// import {
//   HdsVisualComponent,
//   HdsSceneController,
//   HdsSceneType,
//   HdsVisualComponentAttribute,
//   hdsEffect
// } from '@kit.UIDesignKit';
import { intelligentAbstractSwitch } from '../../MainAbility/MainAbility';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { hiSysEvent } from '@kit.PerformanceAnalysisKit';
import { MILLS_PER_SECOND } from '../../../../../../common/src/main/ets/util/DateUtil'
import { ObjectUtil } from '../../../../../../common/src/main/ets/util/ObjectUtil'
import CallRecordPresenter from '../../presenter/dialer/callRecord/CallRecordPresenter';

const TAG = 'ContactDetail-calllog';
const CALL_EVENT = 'CALL_EVENT';
export const CALL_LOG_DATA='datashare:///com.ohos.calllogability';
export const CALL_LOG_URI='datashare:///com.ohos.calllogability/calls/calllog';
const RESTART_SUMMARY_EVENT = 'INTELLIGENT_RESTART_SUMMARY';
const SHOW_SUMMARY_EVENT = 'INTELLIGENT_SHOW_SUMMARY_CARD';
const NFC_PHONENUMBER = '166575543172';

// Call log
@Reusable
@Component
export default struct CallLogListItem {
  @State message: Record<string, number | string | Resource | RecorderLog[]> = {};
  @State isEmergencyNum: boolean = false;
  // device type
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  @StorageLink('voLteRegStates') voLteRegStates: boolean[] = [false, false];
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('isRouterBack') isRouterBack: boolean = false;
  // 字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @Link selectSimBuilder: SelectDialogBuilder;
  @StorageProp('VoiceAppEnabled') isVoiceAppEnabled: boolean = true;
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  @StorageProp('isInDetailLongPress') isInDetailLongPress: boolean = false;
  mPresenter: DialerPresenter = DialerPresenter.getInstance();
  @State recorderLogList: RecorderLog[] = [];
  @State dialogData: dialogDataStruct = {
    objectUse: '',
    confirm: (data?: string) => {
    }
  };
  @Link detailPresenter: DetailPresenter;
  @Prop item: LooseObject;
  // index
  @Prop index: number;
  @State formatNumber: string = '';
  @Link callLogTotal: number;
  @State isSlideState: SwipeActionState = SwipeActionState.COLLAPSED;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  @State isMenuShown: boolean = false;
  @State imgAccessibilityDesc: Resource = $r('app.string.accessibility_dialed_phone');
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @State symbolResource: Resource = $r('sys.symbol.phone_arrow_down_left_fill');
  @State isPressedIndex: number = -1;
  @Prop isSwipe: boolean = false;
  @State isHovered: boolean = false; // 悬停状态
  @State isPressed: boolean = false; // 按压态
  @State isFocused: boolean = false;
  @State backGroundWidth: string = '';
  @State backGroundHeight: string = '40vp';
  // @State sceneController: HdsSceneController = new HdsSceneController();
  @State topAndBottomPadding: number | Resource = 0;
  @Prop generateFailCode: string = '-1'; // 摘要生成失败状态码为-1
  @Prop absGenerateSuccess: string = 'SUCCESS';
  @Prop absGenerateFail: string = 'FAIL';
  @Prop absGenerating: string = 'GENERATING';
  @State absGeneratingFlag: boolean = false; // 摘要生成失败标记
  @State notesStatus: string = '-1'; //备忘录不存在笔记条目时
  @StorageProp(intelligentAbstractSwitch) intelligentAbstractSwitch: boolean = true;
  @StorageProp('isDarkMode') isDarkMode: boolean = true;
  @StorageProp('currentSystemRegion') currentSystemRegion: string | undefined = '';
  @State absStatus: string = ''; // 不使用摘要时摘要状态为空
  @State currentTime:number = 0; // 摘要重新生成时获取当前时间
  @State intervalTime: number = 0; // 摘要重新生成时间间隔
  @State regenerateAbsTime: number = 0; // 重新生成摘要时间
  @State largeSizePadding: number | Resource = 0;
  private absTimeOut: string = 'TimeOut'; // 摘要生成超时状态
  private startTime: number = 0; // 小艺通话并未进行摘要场景
  private defaultTime: number = 90; // 重新生成时间基线90s
  private supportRegion: string = 'CN'; // 支持的地区
  private absCode: string = '-1'; // 未使用通话摘要时状态码为-1
  private absGeneratingCode: string = '1'; // 摘要生成中状态码
  private abserror: string = '-2'; // 摘要异常状态码
  private lastClickTime: number = 0; // 上次重新摘要的点击时间
  @Consume('isNewCallingShow') isNewCallingShow: boolean = true;
  @StorageProp('NotePadAppEnabled') isNotePadAppEnabledFlag: boolean = true;
  @StorageProp('notePadJump') notePadJump: boolean = false;
  @StorageProp('notePadId') notePadId: string = '';
  @StorageProp('isNfcJump') isNfcJump: boolean = false;

  private isPC: boolean = EnvironmentProp.isPC();
  callParams: CustomizedParams = {
    ENC: 4,
    SLOT: 0,
    ISMULTISIMCARD: 0
  };
  mSystemModeController = SystemModeController.getInstance();
  confirmDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.select_call_recorder'),
      contentBuilder: () => {
        this.ConfirmDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.confirmDialog.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  jumpToNotePad() {
    HiLog.i(TAG, `jumpToNotePad begin `);
    AppStorage.setOrCreate<boolean>('notePadJump', true);
    AppStorage.setOrCreate<string>('notePadId', String(this.message.notesId));
    DotUtil.getInstance()
      .contacToNotetDot(abstractClick, 'INTELLIGENT_FOLDED_CLICK_SUMMARY', hiSysEvent.EventType.BEHAVIOR);
  }

  private async jumpToNotePadNew() {
    HiLog.i(TAG, `jumpToNotePadNew begin `);
    let context = getContext(this) as common.UIAbilityContext;
    let dataShareHelper: dataShare.DataShareHelper = await dataShare.createDataShareHelper(context, CALL_LOG_DATA);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('phone_number', NFC_PHONENUMBER);
    let resultColumns = ['notes_id'];
    let notesId: string = '';
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      resultSet = await dataShareHelper.query(CALL_LOG_URI, conditionArgs, resultColumns);
      if (resultSet.goToFirstRow()) {
        do {
          notesId = resultSet.getString(resultSet.getColumnIndex('notes_id'));
          if (notesId !== null && notesId !== '') {
            HiLog.i(TAG, `notes_id is: ${notesId}`);
            AppStorage.setOrCreate<boolean>('notePadJump', true);
            AppStorage.setOrCreate<string>('notePadId', notesId);
            break;
          }
        } while (resultSet.goToNextRow());
      }
    } catch (err) {
      HiLog.e(TAG, `query notesId err: ${err?.code}`);
    } finally {
      ObjectUtil.closeResultSet(resultSet);
      if (dataShareHelper) {
        await dataShareHelper.close();
      }
    }
  }

  // 根据字体缩放更新边距
  getBottomPadding() {
    let bottomPadding: number | Resource = 0;
    if(FontScaleState.isBigerThirdGeer(this.fontSizeScale) === true) {
      bottomPadding = FontScaleState.fetchSeniorListSpace()
      this.topAndBottomPadding = $r('app.float.id_margin_12_hicar');
    } else {
      bottomPadding = $r('app.float.id_margin_12_hicar');
      this.topAndBottomPadding = $r('app.float.id_margin_8_hicar');
    }
    return bottomPadding
  }

  // 大字体场景获取通话记录页面电话图标和间距大小
  phoneIconSize() {
    let iconSize: number | Resource = 0;
    if(FontScaleState.isBigerThirdGeer(this.fontSizeScale) === true) {
      this.largeSizePadding = FontScaleState.fetchSeniorListSpace()
    } else {
      this.largeSizePadding = 0;
    }
    switch (this.fontSizeScale) {
      case 4: {
        iconSize = $r('app.float.large_size_small_icon');
        break;
      }
      case 5: {
        iconSize = $r('app.float.id_card_image_small');
        break;
      }
      case 6: {
        iconSize = $r('app.float.large_size_large_icon');
        break;
      }
      default: {
        iconSize = $r('app.float.id_card_image_xs');
        break;
      }
    }
    return iconSize;
  }

  // 重新生成一句话摘要
  reGenerateAbstract() {
    let now = Date.now();
    if (now - this.lastClickTime < 1000) {
      HiLog.i(TAG, 'click reGenerateAbstract time less 1000 ');
      return;
    }
    this.lastClickTime = now;
    let context = getContext(this) as common.UIAbilityContext
    try{
      let want: Want = {
        bundleName: 'com.ohos.vassistant',
        abilityName: 'RegenerateSummaryService',
        parameters: {
          'params':{
            'beginTime':this.message.beginTime as number,
          }
        }
      }
      HiLog.i(TAG, `abstract regenerate summary begintime is: ${this.message.beginTime}`);
      context.startServiceExtensionAbility(want);
      HiLog.i(TAG, `abstract regenerate start serviceExtensionAbility success.`);
    } catch (err){
      HiLog.e(TAG, `err:${err?.code}`)
    }
  }

  // 更新通话记录数据库
  async updateCallLogAbsStatus(context:common.Context, beginTime:string, phoneNumber:string, notesStatus: string){
    //查询条件dataPredicates
    let dataShareHelper:dataShare.DataShareHelper=
      await dataShare.createDataShareHelper(context, CALL_LOG_DATA)
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('begin_time', beginTime);
    conditionArgs.equalTo('phone_number', phoneNumber);
    //更新字段
    let updateValues: Record<string,string|number>={
      'abs_status':'TimeOut'
    };
    try{
      await dataShareHelper.update(CALL_LOG_URI, conditionArgs, updateValues);
      HiLog.i(TAG,`update calllog success`)
    }catch(err){
      HiLog.e(TAG,`err:${err?.code}`)
    }
  }

  // 进入通话记录详情页面检查摘要生成状态和生成时间
  async checkAbsGenerateTime() {
    let context = getContext(this)as common.UIAbilityContext;
    if (this.message.absCode === this.absGeneratingCode) {
      this.currentTime = Math.floor(Date.now() / 1000);
      this.regenerateAbsTime = this.message.startTime as number;
      HiLog.i(TAG, `abstract regenerate cur time: ${this.currentTime}, startTime ${this.regenerateAbsTime}`);
      this.intervalTime = this.currentTime - this.regenerateAbsTime;
      HiLog.i(TAG, `abstract regenerate time interval: ${this.intervalTime}`);
      if (this.message.absCode === this.absGeneratingCode && this.intervalTime >= this.defaultTime) {
        if (this.message.absStatus !== this.absTimeOut) {
          await this.updateCallLogAbsStatus(context, this.message.beginTime as string,
            this.message.phoneNumber as string, this.notesStatus);
          DotUtil.getInstance().reportFaultSummaryEvent(abstractFail, 'INTELLIGENT_SUMMARY_ENABLE_FAIL');
        }
        HiLog.i(TAG, `abstract regenerate fail`)
      } else {
        HiLog.i(TAG, `abstract regenerate ${this.message.absStatus}`)
      }
    }
  }

  // 非中国区不支持重新生成弹框内容
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.not_support_regenerate'),
      content: $r('app.string.not_support_detail'),
      primaryButton: {
        value: $r('app.string.got_it'),
      },
    }),
    autoCancel: false,
  })

  aboutToReuse(params: LooseObject) {
    this.message = params.message;
    this.dealFormatNumber();
  }

  aboutToAppear() {
    this.dealFormatNumber();
    this.checkAbsGenerateTime();
    if (this.message.absCode !== this.absCode) {
      abstractParams.STATUS = this.message.absCode as number;
      DotUtil.getInstance().contactDot(abstractParams, SHOW_SUMMARY_EVENT, hiSysEvent.EventType.STATISTIC);
    }
    if (this.isNfcJump) {
      this.jumpToNotePadNew();
    }
  }

  isCeliaCallIconValid(): boolean {
    return this.message.celiaCallType === CALL_TYPE_CELIA && this.isVoiceAppEnabled;
  }

  callStatusResConverts() {
    let callStatusRes: Resource = $r('sys.symbol.phone_arrow_down_left_fill');
    if (this.isCeliaCallIconValid()) {
      callStatusRes = $r('sys.symbol.AI_phone_fill')
      this.imgAccessibilityDesc = $r('app.string.call_assistant_setting_title');
    } else if (this.message.callTypeEnum === CallType.IN) {
      callStatusRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.message.features as number) ?
      $r('sys.symbol.arrow_down_left_video_fill') : $r('sys.symbol.phone_arrow_down_left_fill')
      this.imgAccessibilityDesc = $r('app.string.accessibility_answered_phone');
    } else if (this.message.callTypeEnum === CallType.OUT) {
      callStatusRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.message.features as number) ?
      $r('sys.symbol.arrow_up_right_video_fill') : $r('sys.symbol.phone_arrow_up_right_fill')
      this.imgAccessibilityDesc = $r('app.string.accessibility_dialed_phone');
    } else if (this.message.callTypeEnum === CallType.MISSED) {
      callStatusRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.message.features as number) ?
      $r('sys.symbol.video_missed') : $r('sys.symbol.phone_missed')
      this.imgAccessibilityDesc = $r('app.string.accessibility_missed_call');
    } else if (this.message.callTypeEnum === CallType.REJECTED) {
      callStatusRes = FeaturesUtil.isType(FeaturesType.VIDEO, this.message.features as number) ?
      $r('sys.symbol.xmark_video') : $r('sys.symbol.phone_below_xmark')
      this.imgAccessibilityDesc = $r('app.string.accessibility_rejected_phone');
    }
    this.symbolResource = callStatusRes;
  }

  async dealFormatNumber() {
    if (!StringUtil.isEmpty(this.message.formatNumber as string)) {
      let formatNumber: string = this.message.formatNumber as string;
      // The phone contains, and; The call record obtained from the database is ext.
      let index = formatNumber.indexOf('ext');
      if (index > -1) {
        formatNumber = formatNumber.substring(0, index);
      }
      this.formatNumber = formatNumber;
    } else {
      const ret = await PhoneNumber.fromString(this.message.phone.toString()).phoneAddSpace();
      this.formatNumber = ret;
    }
    this.callStatusResConverts();
  }

  noMultiCardDetailDot() {
    // 联系人打点-不是双卡下联系人详情处通话记录点击呼叫
    this.callParams.SLOT = AppStorage.Get<number>('defaultSlot');
    this.callParams.ISMULTISIMCARD = 0;
    DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
  }

  @Builder
  seniorLayout(isMenuPreview: boolean) {
    Column() {
      Column() {
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
          if (this.message.dateDetail) {
            Text(this.message.dateDetail as string)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor(
                (this.message.callTypeEnum == CallType.REJECTED || this.message.callTypeEnum == CallType.MISSED) ?
                $r('app.color.skin_warning') : $r('app.color.skin_ohos_id_color_text_primary')
              )
            Blank()
              .width(4)
          }
          Text(this.message.timeDetail as string)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor(
              (this.message.callTypeEnum == CallType.REJECTED || this.message.callTypeEnum == CallType.MISSED) ?
              $r('app.color.skin_warning') : $r('app.color.skin_ohos_id_color_text_primary')
            )
        }
        .width('100%')
        .constraintSize({ minHeight: '22vp' })

        Row() {
          SymbolGlyph(this.symbolResource)
            .fontSize(this.phoneIconSize())
            .fontColor([$r('app.color.skin_icon_tertiary')])
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, this.imgAccessibilityDesc))
          if (this.haveMultiSimCard) {
            SymbolGlyph(this.message.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
              .fontSize($r('app.float.id_card_image_xs'))
              .fontColor([$r('app.color.skin_icon_tertiary')])
              .opacity($r('sys.float.alpha_tertiary'))
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
              })
          }
          if (this.message.isSatellite === 1) { //通话记录图标
            SymbolGlyph($r('sys.symbol.satellite'))
              .fontSize(10)
              .maxFontScale(1)  //不放大
              .fontColor([$r('app.color.skin_white')])
              .padding({
                left: 2,
                top: 1,
                right: 1,
                bottom: 2
              })
              .backgroundImage($r('app.media.satellite_backgroud_img'))
              .backgroundColor($r('sys.color.ohos_id_color_alert'))
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
              })
              .flexShrink(0)
              .borderRadius($r('sys.float.Body_S'))
          }
          if (this.message.isSatellite === 2) { //风信子图标
            Image($r('app.media.hyacinth_call_log'))
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
              })
              .size({ width: 12, height: 12 })
              .backgroundImage($r('app.media.satellite_backgroud_img'))
              .backgroundImageSize({ width: 12, height: 12 })
              .backgroundColor($r('sys.color.ohos_id_color_alert'))
              .borderRadius($r('sys.float.Body_S'))
          }
          if (this.message?.recordLogList) {
            SymbolGlyph($r('sys.symbol.recordingtape_rectangle_fill'))
              .fontSize(this.phoneIconSize())
              .fontColor([$r('app.color.skin_icon_tertiary')])
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_mid') )
              })
          }
          Text(this.formatNumber)
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Regular)
            .fontColor(
              this.message.callTypeEnum == CallType.MISSED || this.message.callTypeEnum == CallType.REJECTED ?
              $r('app.color.skin_ohos_id_color_text_secondary') : $r('app.color.skin_ohos_id_color_text_secondary')
            )
            .margin({
              start: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
            })
            .maxLines(isMenuPreview ? 1 : 10)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({
              maxWidth: `calc(100% - 12vp - ${this.haveMultiSimCard ? '16vp' : '0vp'} - ${this.message.isSatellite ===
                1 ? '16vp' : '0vp'}- ${this.message?.recordLogList ? '16vp' : '0vp'} - 4vp)`
            })
            .layoutWeight(1)
        }
        .constraintSize({ minHeight: '19vp' })
        .margin({ top: $r('app.float.id_card_margin_sm') })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .margin({ top: this.largeSizePadding, bottom: 12 })

      Column() {
        Row() {
          if (this.isCeliaCallIconValid()) {
            Stack() {
              Row() {
                Image($r('app.media.call_record_entrance'))
                  .width($r('app.float.id_card_image_small'))
                  .height($r('app.float.id_card_image_small'))
                  .draggable(false)
                  .backgroundColor(Color.Transparent)
              }

              Column()
                .width(48)
                .height(48)
                .hitTestBehavior(HitTestMode.Block)
                .onClick(() => {
                  let context = getContext(this) as common.UIAbilityContext;
                  startCallAssistantRecord(context, this.message.beginTime as number);
                })
            }
            .width(24)
            .height(24)
            .margin((this.message.newCalling === 1 || this.message.recordLogList) ? { right: 12 } : null)
            .constraintSize({ minHeight: '22vp' })
          }

          if (this.message.recordLogList) {
            Stack() {
              Row() {
                SymbolGlyph($r('sys.symbol.play_circle'))
                  .fontSize($r('app.float.id_card_image_small'))
                  .fontColor([$r('app.color.skin_icon_primary')])
              }

              Column()
                .width(48)
                .height(48)
                .hitTestBehavior(HitTestMode.Block)
                .onClick(() => {
                  if (this.isCeliaCallIconValid()) {
                    let context = getContext(this) as common.UIAbilityContext;
                    startCallAssistantRecord(context, this.message.beginTime as number);
                  } else if (this.message.recordLogList) {
                    let recorderLogList = this.message.recordLogList as RecorderLog[];
                    if (recorderLogList.length === 1) {
                      this.mPresenter.jumpToRecordListByPhone(recorderLogList[0]);
                    } else {
                      this.recorderLogList = recorderLogList;
                      this.confirmDialog.open();
                      DialogControllerManager.getInstance().addDialogController(this.confirmDialog);
                    }
                  }
                })
            }
            .width(24)
            .height(24)
            .margin((this.isCeliaCallIconValid() || this.message.newCalling === 1) ?
              (i18n.isRTL(i18n.System.getSystemLanguage()) ? { right: 12 } : { left: 12 }) : null)
          }

          if (this.message.newCalling === 1) {
            Stack() {
              Row() {
                Image($r('app.media.new_call_box_light'))
                  .width($r('app.float.id_card_image_small'))
                  .height($r('app.float.id_card_image_small'))
                  .fillColor($r('app.color.skin_icon_primary'))
              }

              Column()
                .width(48)
                .height(48)
                .hitTestBehavior(HitTestMode.Block)
                .onClick(() => {
                  HiLog.i(TAG, 'NewCalling message box clicked');
                  this.onNewCallingMessageBoxClicked();
                });
            }
            .width(24)
            .height(24)
            .margin(this.isCeliaCallIconValid() ? { left: 12, right: this.message.recordLogList ? 12 : null } :
              this.message.recordLogList ? { right: 12 } : null)
          }

        }
        Row() {
          if (this.message.callTypeEnum == CallType.MISSED) {
            Text($r('app.plural.contacts_ring_times', this.message.ringTime, this.message.ringTime ))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              .enabled(false)
              .accessibilityLevel('no')
          } else {
            Text(this.message.talkTime as string)
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              .enabled(false)
              .accessibilityLevel('no')
              .margin({ bottom: this.largeSizePadding })
          }

        }
        .constraintSize({ minHeight: '19vp' })
      }
      .constraintSize({ minWidth: '40vp' })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .constraintSize({
      minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
    })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  @Styles
  private disabledStyles() {
    .opacity($r(DISABLED_OPACITY_STRING))
  }

  @Builder
  normalLayout() {
    Row() {
      Column() {
        Row() {
          Text(this.message.dateDetail as string)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor((this.message.callTypeEnum == CallType.REJECTED || this.message.callTypeEnum ==
            CallType.MISSED) ? $r('app.color.skin_warning') : $r('app.color.skin_ohos_id_color_text_primary'))
            .margin({
              end: this.message.dateDetail ? LengthMetrics.resource($r('app.float.id_card_margin_mid')) :
                LengthMetrics.vp(0)
            })
          Text(this.message.timeDetail as string)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor((this.message.callTypeEnum == CallType.REJECTED || this.message.callTypeEnum ==
            CallType.MISSED) ? $r('app.color.skin_warning') : $r('app.color.skin_ohos_id_color_text_primary'))
        }
        .constraintSize({ minHeight: '22vp' })

        Row() {
          SymbolGlyph(this.symbolResource)
            .fontSize($r('app.float.id_card_image_xs'))
            .fontColor([$r('app.color.skin_icon_tertiary')])
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, this.imgAccessibilityDesc))

          if (this.haveMultiSimCard) {
            SymbolGlyph(this.message.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
              .fontSize($r('app.float.id_card_image_xs'))
              .fontColor([$r('app.color.skin_icon_tertiary')])
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
              })
          }
          if (this.message.isSatellite === 1) { //联系人详情中的天通图标
            SymbolGlyph($r('sys.symbol.satellite'))
              .fontSize(10)
              .maxFontScale(1)  //不放大
              .fontColor([$r('app.color.skin_white')])
              .padding({
                left: 2,
                top: 1,
                right: 1,
                bottom: 2
              })
              .backgroundImage($r('app.media.satellite_backgroud_img'))
              .backgroundColor($r('sys.color.ohos_id_color_alert'))
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
              })
              .flexShrink(0)
              .borderRadius($r('sys.float.Body_S'))
          }
          if (this.message.isSatellite === 2) { //联系人详情中加载风信子图标
            Image($r('app.media.hyacinth_call_log'))
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_mid'))
              })
              .size({ width: 12, height: 12 })
              .backgroundImage($r('app.media.satellite_backgroud_img'))
              .backgroundImageSize({ width: 12, height: 12 })
              .backgroundColor($r('sys.color.ohos_id_color_alert'))
              .borderRadius($r('sys.float.Body_S'))
          }
          if (this.message?.recordLogList) {
            SymbolGlyph($r('sys.symbol.recordingtape_rectangle_fill'))
              .fontSize($r('app.float.id_card_image_xs'))
              .fontColor([$r('app.color.skin_icon_tertiary')])
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_mid') )
              })
          }
          Text(this.formatNumber)
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Regular)
            .fontColor(this.message.callTypeEnum == CallType.MISSED ||
              this.message.callTypeEnum == CallType.REJECTED ?
            $r('app.color.skin_ohos_id_color_text_secondary') : $r('app.color.skin_ohos_id_color_text_secondary'))
            .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.Start : TextAlign.End)
            .direction(Direction.Ltr)
            .margin({
              start: LengthMetrics.resource($r('app.float.id_card_margin_mid') )
            })
        }
        .constraintSize({ minHeight: '19vp' })
        .margin({ top: $r('app.float.id_card_margin_sm') })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      Blank();

      Column() {
        Row() {
          if (this.isCeliaCallIconValid()) {
            Stack({ alignContent: Alignment.End }) {
              Image($r('app.media.call_record_entrance'))
                .width($r('app.float.id_card_image_small'))
                .height($r('app.float.id_card_image_small'))
                .draggable(false)
                .backgroundColor(Color.Transparent)
                .enabled(this.mSystemModeController.getIsEnableCeliaCall())
                .stateStyles({
                  disabled: this.disabledStyles
                })
              Column()
                .width(48)
                .height(48)
                .margin({ right: -12 })
                .accessibilityRole(AccessibilityRoleType.BUTTON)
                .accessibilityText($r('app.string.call_assistant_setting_title'))
                .constraintSize({ minHeight: '22vp' })
                .onClick(() => {
                  if (!this.mSystemModeController.getIsEnableCeliaCall()) {
                    HiLog.i(TAG, 'Celia Call is disabled in this mode');
                    showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
                    return;
                  }
                  let context = getContext(this) as common.UIAbilityContext;
                  startCallAssistantRecord(context, this.message.beginTime as number);
                  DotUtil.getInstance().contactDot(abstractClick, 'CONTACTS_CELIA_CALL', hiSysEvent.EventType.BEHAVIOR);
                })
            }
            .width(24)
            .height(24)
            .margin((this.message.recordLogList || this.message.newCalling === 1) ? { right: 12 } : null)
          }
          if (this.message.newCalling === 1) {
            Stack({ alignContent: Alignment.End }) {
              Image($r('app.media.new_call_box_light'))
                .width($r('app.float.id_card_image_small'))
                .height($r('app.float.id_card_image_small'))
                .fillColor($r('app.color.skin_icon_primary'))
              Column()
                .width(48)
                .height(48)
                .margin({ right: -12 })
                .accessibilityText($r('app.string.smart_box_display_name'))
                .constraintSize({ minHeight: '22vp' })
                .onClick(() => {
                    HiLog.i(TAG, 'NewCalling message box clicked');
                    this.onNewCallingMessageBoxClicked();
                });
            }
            .width(24)
            .height(24)
            .margin(this.isCeliaCallIconValid() ? { left: 12, right: this.message.recordLogList ? 12 : null } :
              this.message.recordLogList ? { right: 12 } : null)
          }

          if (this.message.recordLogList) {
            Stack({ alignContent: Alignment.End }) {
              SymbolGlyph($r('sys.symbol.play_circle'))
                .fontSize($r('app.float.id_card_image_small'))
                .fontColor([$r('app.color.skin_icon_primary')])
                .enabled(this.mSystemModeController.getIsEnableCallRecordEntry())
                .stateStyles({
                  disabled: this.disabledStyles
                })
              Column()
                .width(48)
                .height(48)
                .margin({ right: -12 })
                .hitTestBehavior(HitTestMode.Block)
                .constraintSize({ minHeight: '22vp' })
                .accessibilityRole(AccessibilityRoleType.BUTTON)
                .accessibilityText($r('app.string.call_recorder_list'))
                .onClick(() => {
                  if (!this.mSystemModeController.getIsEnableCallRecordEntry()) {
                    HiLog.i(TAG, 'Call Record is disabled in this mode');
                    showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
                    return;
                  }

                  let recorderLogList = this.message.recordLogList as RecorderLog[];
                  if (recorderLogList.length === 1) {
                    this.mPresenter.jumpToRecordListByPhone(recorderLogList[0]);
                  } else {
                    this.recorderLogList = recorderLogList;
                    this.confirmDialog.open();
                    DialogControllerManager.getInstance().addDialogController(this.confirmDialog);
                  }
                })
            }
            .width(24)
            .height(24)
            .margin((this.isCeliaCallIconValid() || this.message.newCalling === 1) ? { left: 12 } : null)
          }
        }
        if (this.message.callTypeEnum == CallType.MISSED) {
          Row() {
            Text($r('app.plural.contacts_ring_times', this.message.ringTime, this.message.ringTime))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
          }
          .enabled(false)
          .accessibilityLevel('no')
          .constraintSize({ minHeight: '19vp' })
        } else {
          Row() {
            Text(this.message.talkTime as string)
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
          }
          .enabled(false)
          .accessibilityLevel('no')
          .constraintSize({ minHeight: '19vp' })
          .margin({ top: $r('app.float.id_card_margin_sm') })
        }
      }
      .alignItems(HorizontalAlign.End)
      .justifyContent(FlexAlign.Center)
      .constraintSize({ minWidth: '40vp' })
    }
    .clip(false)
    .width('100%')
    .constraintSize({
      minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
    })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

  aboutToDisappear() {
    this.deleteDialogController = null;
    this.mPresenter.onDestroy();
  }

  private onNewCallingMessageBoxClicked(): void {
    if (!this.isNewCallingShow) {
      HiLog.i(TAG, 'isNewCallingShow false');
      showToast(this.getUIContext(), $r('app.string.new_calling_can_only_use_in_full_screen'));
      return;
    }
    const context: common.UIAbilityContext =
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    sim.getShowNumber(this.message.simId as number).then((simShowNumber: string) => {
      const wantInfo: Want = {
        bundleName: 'com.ohos.newcallingdcsdk',
        abilityName: 'UIExtAbility',
        action: 'messageBox',
        parameters: {
          bundleName: 'com.ohos.contacts',
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          localNumber: simShowNumber,
          remoteNumber: this.message.formatNumber,
          timestamp: (this.message.callTime) as number * MILLS_PER_SECOND,
        },
      };
      context.requestModalUIExtension(wantInfo).then(() => {
        HiLog.i(TAG, `startSmcServiceExtAbility success.`);
        //进入消息盒子打点
        this.callParams.SLOT = this.message.simId as number
        DotUtil.getInstance().contactDot(this.callParams, 'ENTER_MESSAGE_BOX')
      }).catch((error: BusinessError) => {
        HiLog.e(TAG,
          `startSmcServiceExtAbility failed, code: ${error?.code}, message: ${error?.message}`);
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `getShowNumber error: code: ${error?.code}, message: ${error?.message}`);
    });
  }

  deleteDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.deleteCallLog_dialog_title'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          // 联系人打点-删除通话记录弹窗-取消
          deleteLogDialogParams.ISDELETE = dotCommon.eventParam.CLICK_CANCEL;
          DotUtil.getInstance().contactDot(deleteLogDialogParams, dotCommon.eventName.DELETE_LOG_DIALOG_EVENT);
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        action: () => {
          ContactsGlobalThisHelper.GetGlobalThis()
            .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
            .sendRequest('deleteCallLogsById', {
              context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
              ids: [this.message.id]
            }, () => {
              HiLog.i(TAG, 'deleteCallLog Success');
              deleteLogDialogParams.ISDELETE = dotCommon.eventParam.CLICK_DELETE;
              DotUtil.getInstance().contactDot(deleteLogDialogParams, dotCommon.eventName.DELETE_LOG_DIALOG_EVENT);
              DialogControllerManager.getInstance().dialogControllerSet.clear();
              // 刷新详情页通话记录列表
              this.detailPresenter.refresh();
              // 刷新电话页面的全部通话列表
              CallRecordPresenter.getInstance().onCallsChange();
            });
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  dialerVideoCall(slot: number, isMultiSIMCard: number, hasDefaultSIMCard: number, registeredVoLTECard: number) {
    videoCallParams.ENC = 2;
    videoCallParams.SLOT = slot;
    videoCallParams.ISMULTISIMCARD = isMultiSIMCard;
    videoCallParams.HAS_DEFAULT_SIM_CARD = hasDefaultSIMCard;
    videoCallParams.REGISTERED_VOLTE_CARD = registeredVoLTECard;
    DotUtil.getInstance().contactDot(videoCallParams, dotCommon.eventName.VIDEO_CALLING_EVENT);
  }

  build() {
    Column() {
      Column() {
      if (FontScaleState.isSmallerThirdGeer(this.fontSizeScale)) {
        this.normalLayout()
      } else {
        this.seniorLayout(false)
      }

      if (this.index + 1 < this.callLogTotal && this.message.absCode === '-1') {
        Divider()
          .color($r('app.color.skin_ohos_id_color_list_separator'))
          .strokeWidth('1px')
          .width('100%')
      }
    }
    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .borderRadius($r('sys.float.padding_level8'))
    .backgroundColor(this.isPressedIndex === this.index && !this.isSwipe ? $r('app.color.skin_interactive_click') :
      this.isMenuShown ? $r('app.color.skin_ohos_id_color_list_card_bg') : Color.Transparent)
    .onTouch((event: TouchEvent) => {
      switch (event.type) {
        case TouchType.Down:
          this.isPressedIndex = this.index;
          break;
        case TouchType.Up:
        case TouchType.Cancel:
          if (this.isPressedIndex !== -1) {
            this.isPressedIndex = -1;
          }
          break;
      }
    })
    .bindContextMenu(this.isMenuShown, this.MenuBuilder, {
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: { scale: [1, 1] },
      placement: Placement.BottomLeft,
      offset: { x: 0, y: $r('sys.float.padding_level4') },
      backgroundColor: this.isThemeActive ? ($r('app.color.skin_ohos_id_color_list_card_bg')) : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
      onAppear: () => {
        this.isInDetailLongPress = true;
        // 联系人打点-联系人详情页长按某通话记录
        DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.PRESS_VIEW_LOG_EVENT);
      },
      onDisappear: () => {
        this.isInDetailLongPress = false;
        this.isMenuShown = false;
      },
    })
    .gesture(GestureGroup(GestureMode.Exclusive, LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
      .onAction((event: GestureEvent) => {
        this.isPressedIndex = -1;
        this.isMenuShown = true;
        VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
      })
    ))
    .onClick(() => {
      // click to make a call
      HiLog.i(TAG, 'DetailCallLog ListItem onClick');
      if (this.haveMultiSimCard) {
        let optionsObj: call.DialOptions = {};
        if (this.mSystemModeController.getIsEnableVideoCall() &&
        FeaturesUtil.isType(FeaturesType.VIDEO, this.message.features as number) &&
        this.voLteRegStates[this.message.simId as number]) {
          let accountId: number = this.message.simId as number;
          // 联系人打点-视频呼叫-联系人详情页通话记录-双卡时拨打视频通话(默认使用上次卡号呼出)
          this.dialerVideoCall(accountId, dotCommon.eventParam.SELECT_TRUE, dotCommon.eventParam.SELECT_FALSE,
            dotCommon.eventParam.CARD_NUMBER_ONE);
          optionsObj = {
            accountId: accountId,
            videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
          }
          RoamingManager.getInstance().handleRoaming(this.getUIContext(), this.message.phone as string, optionsObj);
        } else {
          if (FeaturesUtil.isType(FeaturesType.VIDEO, this.message.features as number)) {
            showVideoChangeToVoiceToast();
          }
          // 双卡下设置默认卡号直接拨打电话
          if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
            HiLog.i(TAG, 'defaultSlot: ' + this.defaultSlot);
            RoamingManager.getInstance().handleRoaming(this.getUIContext(), this.message.phone as string, {
              accountId: this.defaultSlot
            });
            return;
          }
          this.selectSimBuilder.title = $r('app.string.contacts_call_number', this.message.phone as string);
          this.selectSimBuilder.callback = (value) => {
            optionsObj = {
              accountId: value,
            }
            RoamingManager.getInstance().handleRoaming(this.getUIContext(), this.message.phone as string, optionsObj);
          }
          this.selectSimBuilder.gotoDialer = () => {
            this.isRouterBack = true;
            DialerPresenter.getInstance().editPhoneNumber(this.message.phone as string);
            AppStorage.SetOrCreate<boolean>('showDialBtn', true);
          }
          // 根据号码查询第一个也就是最新的一次通话记录
          ContactsGlobalThisHelper.GetGlobalThis()
            .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
            .sendRequest('findByNumberIn', {
              actionData: {
                context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
                numbers: [(this.message.phone as string)],
                limit: 1,
                page: 1
              }
            }, (resultList: CallLog[]) => {
              if (!ArrayUtil.isEmpty(resultList)) {
                this.selectSimBuilder.lastSimId = resultList[0].simId;
              } else {
                this.selectSimBuilder.lastSimId = -1;
              }
            });
          let spnList = AppStorage.get<Array<string | Resource>>('spnList');
          if (spnList && this.selectSimBuilder.multiSimCardItems) {
            for (let index = 0; index < spnList.length; index++) {
              this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
            }
          }
          this.selectSimBuilder.controller?.open();
          // 联系人打点-双卡下联系人详情处通话记录点击呼叫(默认使用上次卡号呼出)
          this.callParams.SLOT = optionsObj.accountId;
          this.callParams.ISMULTISIMCARD = 1;
          DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
        }
      } else {
        if (FeaturesUtil.isType(FeaturesType.VIDEO, this.message.features as number) && this.haveSimCard) {
          if (this.mSystemModeController.getIsEnableVideoCall() && this.haveVoLteReg) {
            let accountId = AppStorage.Get<number>('defaultSlot') as number;
            // 联系人打点-视频呼叫-联系人详情页通话记录-单卡拨打视频通话(默认使用上次卡号呼出)
            this.dialerVideoCall(accountId, dotCommon.eventParam.SELECT_FALSE, dotCommon.eventParam.SELECT_FALSE,
              dotCommon.eventParam.CARD_NUMBER_ONE);
            RoamingManager.getInstance().handleRoaming(this.getUIContext(), this.message.phone as string, {
              accountId: AppStorage.Get<number>('defaultSlot'),
              videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
            });
            return;
          }
          showVideoChangeToVoiceToast();
        }
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), this.message.phone as string);
        this.noMultiCardDetailDot();
      }
    })
      if (this.message.absCode !== this.absCode) {
        if (this.intelligentAbstractSwitch) {
          if (this.message.notesStatus !== this.notesStatus && this.message.startTime !== this.startTime) {
            if (!this.isVoiceAppEnabled && (this.message.absStatus === this.absGenerateFail ||
              this.message.absStatus === this.absTimeOut) || (!this.isNotePadAppEnabledFlag &&
              this.message.absStatus !== this.absGenerateSuccess)) {
            } else {
              this.displayAnAbstract();
            }
          }
        }
        if (this.index + 1 < this.callLogTotal){
          Divider()
            .color($r('app.color.skin_ohos_id_color_list_separator'))
            .strokeWidth('1px')
            .width('100%')
            .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
        }
      }
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
      .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.contacts_call') })
        .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
        .borderRadius($r('sys.float.corner_radius_level8'))
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .id('ContactListView_Contacts_share_MenuItem')
        .onClick(() => {
          // 联系人打点-联系人详情长按通话记录-点击呼叫
          autoUpdateDataParams.ITEM = dotCommon.eventParam.CLICK_CALL;
          DotUtil.getInstance().contactDot(autoUpdateDataParams, dotCommon.eventName.PRESS_LOG_CHOOSE_EVENT);
          this.isRouterBack = true;
          DialerPresenter.getInstance().editPhoneNumber(this.message.phone as string);
          AppStorage.SetOrCreate<boolean>('showDialBtn', true);
        })
      this.MenuDivider()
      MenuItem({ content: $r('app.string.delete_call_logs') })
        .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
        .borderRadius($r('sys.float.corner_radius_level8'))
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .id('ContactListView_Contacts_share_MenuItem')
        .onClick(() => {
          setTimeout(() => {
            // 联系人打点-联系人详情长按通话记录-点击删除通话记录
            autoUpdateDataParams.ITEM = dotCommon.eventParam.CLICK_DELETE_LOG;
            DotUtil.getInstance().contactDot(autoUpdateDataParams, dotCommon.eventName.PRESS_LOG_CHOOSE_EVENT);
            this.deleteDialogController?.open();
            DialogControllerManager.getInstance().addDialogController(this.deleteDialogController);
          }, 300)
        })
    }
    .radius($r('sys.float.corner_radius_level10'))
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .padding({
      left: $r('app.float.id_card_margin_mid'),
      right: $r('app.float.id_card_margin_mid'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid')
    })
    .font({
      family: 'HarmonyHeiTi',
      size: $r('sys.float.ohos_id_text_size_body1'),
      weight: FontWeight.Medium
    })
    .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }

  @Builder
  abstractContent() {
      Column({ space: 2 }) {
        Text(this.message.absStatus === 'TimeOut' || this.message.absCode === this.abserror ?
          $r('app.string.regenerate_fail_info') : this.message.abstractProfile?.toString())
          .width('100%')
          .fontSize($r('sys.float.Body_S')) // Body_s字号
          .fontColor(this.isDarkMode?$r('app.color.dark_color'):$r('app.color.light_color'))
          // .advancedBlendMode(uiEffect.createBrightnessBlender(hdsEffect.getBrightnessParam({
          //   scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
          //   level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_2,
          //   fraction: 0,
          // })))
          .maxLines(this.message.absStatus===this.absGenerateSuccess?2:null)
          .textOverflow({ overflow: this.message.absStatus===this.absGenerateSuccess?TextOverflow.Ellipsis:null })
          .padding({ bottom: this.message.absStatus !== this.absGenerateSuccess?this.topAndBottomPadding:'0vp', top: this.topAndBottomPadding })
          .focusable(true)
        if(this.message.absStatus === this.absGenerateSuccess) {
          Text($r('app.string.abstract_ai_content'))
            .width('100%')
            .fontSize($r('sys.float.Caption_M')) // Caption_M字号
            .fontColor(this.isDarkMode?$r('app.color.dark_color'):$r('app.color.light_color'))
            // .advancedBlendMode(uiEffect.createBrightnessBlender(hdsEffect.getBrightnessParam({
            //   scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
            //   level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_3,
            //   fraction: 0,
            // })))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({
              bottom: this.topAndBottomPadding
            })
            .focusable(true)
        }
      }
      .tabStop(true)
      .focusable(true)
      .width('100%')
      .padding({
        left: $r('app.float.id_margin_12_hicar'),
        right: $r('app.float.id_margin_12_hicar')
      })
      .onAreaChange((oldValue, newValue) => {
        this.backGroundWidth = String(newValue.width)
        this.backGroundHeight = String(newValue.height)
      })
      .borderRadius($r('sys.float.corner_radius_level6')) // 设置圆角
  }

  // @Builder
  // showDarkOrLight() {
  //   if (this.isDarkMode) {
  //     EdgeFlowLightVisualComponentDark()
  //       .width(this.backGroundWidth)
  //       .height(this.backGroundHeight)
  //       .clip(true)
  //       .borderRadius($r('sys.float.corner_radius_level6')) // 设置圆角
  //   } else {
  //     EdgeFlowLightVisualComponentLight()
  //       .width(this.backGroundWidth)
  //       .height(this.backGroundHeight)
  //       .clip(true)
  //       .borderRadius($r('sys.float.corner_radius_level6')) // 设置圆角
  //   }
  //
  // }

  @Builder
  displayAnAbstract() {
    Stack() {
      // this.showDarkOrLight()
      this.abstractContent()
    }
    .borderRadius($r('sys.float.corner_radius_level6')) // 设置圆角
    .margin({
      bottom: this.getBottomPadding(),
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4')
    })
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up) {
        this.isPressed = false
      }
    })
    .onClick(() => {
      if (this.message.absStatus === this.absGenerateSuccess){
        this.jumpToNotePad()
        DotUtil.getInstance()
          .contacToNotetDot(abstractClick, 'INTELLIGENT_FOLDED_CLICK_SUMMARY', hiSysEvent.EventType.BEHAVIOR);
      } else if (this.message.absStatus === this.absTimeOut || this.message.absStatus === this.absGenerateFail ||
        this.message.absCode === this.abserror) {
        if (this.currentSystemRegion !== this.supportRegion) {
          this.dialogController?.open();
        } else {
          DotUtil.getInstance().contactDot(abstractRestart, RESTART_SUMMARY_EVENT);
          this.reGenerateAbstract();
        }
      }
    })
    .onFocus(() => {
      this.isFocused = true
    })
    .onBlur(() => {
      this.isFocused = false
    })
    .hoverEffect(HoverEffect.Scale)
    .onHover((isHover?: boolean) => {
      this.isHovered = isHover as boolean
    })
  }

  @Builder
  MenuPreviewBuilder() {
    Scroll() {
      Column() {
        Column() {
          if (FontScaleState.isSmallerThirdGeer(this.fontSizeScale)) {
            this.normalLayout()
          } else {
            Scroll() {
              this.seniorLayout(true)
            }
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.None)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
      }
    }
    .width('100%')
    .borderRadius($r('app.float.rounded_corners_width_20'))
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid')
    })
  }

  @Builder
  ConfirmDialogBuilder() {
    List() {
      ForEach(this.recorderLogList, (item: RecorderLog) => {
        ListItem() {
          Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start}) {
            Text((ResourceUtil.resourceToStringById($r('app.string.recorder')) + ' ' + item.displayName))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi')
              .textAlign(TextAlign.Start)
              .lineHeight(19)
          }
          .width('100%')
          .constraintSize({ minHeight: '44vp' })
          .padding({ top: $r('sys.float.padding_level1'), bottom: $r('sys.float.padding_level1') })
          .onClick(() => {
            this.confirmDialog.close();
            this.mPresenter.jumpToRecordListByPhone(item);
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          })
        }
      }, (item: RecorderLog) => JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .height('auto')
    .width('100%')
    .divider({
      strokeWidth: 1,
      color: $r('app.color.skin_comp_divider'),
    })
  }
}

// @ComponentV2
// struct EdgeFlowLightVisualComponentLight {
//   @Local sceneController: HdsSceneController = new HdsSceneController()
//     .setSceneParams(new Map<string, Object>([
//       ['autoPlay', false]  // 设置默认进入不开启动效，如不需要则不用设置
//     ]));
//
//   build() {
//       HdsVisualComponent()
//         .scene(HdsSceneType.UV_FLOWLIGHT_CARD_LIGHT,
//           this.sceneController, () => {
//           })
//     }
// }
//
// @ComponentV2
// struct EdgeFlowLightVisualComponentDark {
//   @Local sceneController: HdsSceneController = new HdsSceneController()
//     .setSceneParams(new Map<string, Object>([
//       ['autoPlay', false]  // 设置默认进入不开启动效，如不需要则不用设置
//     ]));
//
//   build() {
//       HdsVisualComponent()
//         .scene(HdsSceneType.UV_FLOWLIGHT_CARD_DARK,
//           this.sceneController, () => {
//           })
//   }
// }

