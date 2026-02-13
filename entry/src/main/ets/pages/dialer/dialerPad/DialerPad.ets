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

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import DialerPresenter, {
  QUERY_LOCATION_PHONE_NUMBER_MAX_LEN,
  QUERY_LOCATION_PHONE_NUMBER_MIN_LEN
} from '../../../presenter/dialer/DialerPresenter';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import VibrationUtils from '../../../util/VibrationUtils';
import { VibrationEffect } from '../../../model/type/EnumUtil';
import { simId_DEFAULT, simId_ONE } from '../../../feature/sim/SimCardState';
import { MutiDialerButtonView } from '../../../component/mutisim/MutiDialerButtonView';
import { CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import GetNumberLocation from '../../../util/GetNumberLocation';
import { DiaPadTablet } from '../../../component/dialer/DiaPadTablet';
import DialerConstant from '../../../data/DialerConstant';
import UDC from '@ohos.data.unifiedDataChannel';
import UTD from '@ohos.data.uniformTypeDescriptor';
import { DialBindSheetBuilder } from '../../../component/dialer/DialBindSheetBuilder';
import { FontScaleState } from '../../../util/fontScaleState';
import { display } from '@kit.ArkUI';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import { deviceInfo } from '@kit.BasicServicesKit';
import { i18n } from '@kit.LocalizationKit';
import { DialPad } from '../../../component/dialer/DialPad';
import { VisionGlassConstants } from '../../../data/VisionGlassConstants';
import { ResourceUtil } from '../../../util/ResourceUtil';
import dotCommon, { customParams } from '../../../util/DotCommon';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';

const TAG = 'DialerPad';
const DELETE_NUM_EVENT = 'DELETE_NUM_EVENT';
const SECRET_CODE_MMI_IMEI_DISPLAY: string = '*#06#';
const regex = /^[0-9*#+,;]+$/;
const DOUBLE_INPUT_INTERVAL_TIME = 50; // 两次键盘输入需间隔50ms
const CALL_BUTTON_OPACITY: number = 1;
const noCareModeMaxFOnt: number = 1.45;

interface callmenuFn {
  value: string,
  action: () => void
}

@Component
export default struct CallTablet {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State mPresenter: DialerPresenter = DialerPresenter.getInstance();
  @State callRecordPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  readonly NUM_TEXT_MAX_LENGTH = 20;
  readonly NUM_TEXT_MAXSIZE_LENGTH = 14;
  readonly NUM_TEXT_MAXSIZE_LENGTH_13 = 13;
  readonly NUM_TEXT_FONT_SIZE_MAX = 38;
  readonly NUM_TEXT_FONT_SIZE_MIN = 24;
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) @Watch('telNumberChange') telNumberWithSpace: string =
    '';
  @State telNumSize: number = this.NUM_TEXT_FONT_SIZE_MAX;
  @StorageLink('isPasteShowCursor') isPasteShowCursor: boolean = false;
  @StorageLink('isDialerShowImeiPanel') isShowImeiPanel: boolean = false;
  private timerId: number = -1;
  menuRes: Resource[] = [$r('app.string.call_setting_type_paste'),
    $r('app.string.call_setting_type_batch_delete'),
    $r('app.string.commotion_intercept'),
    $r('app.string.call_setting_type_setting')];
  @State callmenu: Array<callmenuFn> = [{
    value: '', action: () => {
    }
  }];
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  isCutFlag: boolean = false;
  textInputController: TextInputController = new TextInputController();
  @State textInputFocusable: boolean = false;
  @StorageLink('breakpoint')@Watch('onBpChange') curBp: string = 'sm';
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  @StorageLink('defaultSlot') defaultSlot: number = simId_ONE;
  @StorageLink('isAirplaneMode') isAirplaneMode: boolean = false;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('showTelNumber') showTelNumber: boolean = true;
  @State numberLocation: string = '';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageLink(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  customizedParams: CustomizedParams = {};
  @StorageProp('windowHeightPx') windowHeightPx: number = 0;
  deviceDisplayInfo: display.Display = display.getDefaultDisplaySync();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('pasteData') pasteData: string = '';
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  @StorageLink('isHasDate') isHasPateDate: boolean = false;
  @StorageLink('activeCallId') activeCallId: number = -1;
  private isPC: boolean = EnvironmentProp.isPC();
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;
  @StorageLink('isMaximumZoom') isMaximumZoom: boolean = false;
  private lastInputTime: number = -1; // 用来减少键盘快速输入问题
  @StorageLink('isWindowPcMode') windowPcMode: boolean = false;
  @StorageLink('isAppear') isAppear: boolean = false;
  @StorageLink('settingFontScale') settingFontScale: string = '0';
  @StorageLink('missedCallId') missedCallId: number = -1;
  @State dialButtonHeight: number = 60;
  @State dialPadHeight: number = 240;
  // 卫星状态
  @StorageLink('isSatelliteMode') isSatelliteMode: boolean = false;
  @StorageLink('isHyacinthMode') isHyacinthMode: boolean = false;
  @StorageLink('isSmallPad') isSmallPad: boolean = false;
  @StorageLink('isNavigationModeSplit') isNavigationModeSplit: boolean = false;
  @State dialPadBottomPadding: Length = 0;
  @State callButtonBottomMargin: Length = 0;

  telNumberChange() {
    HiLog.w(TAG, 'telNumberChange');
    let numLength: number = this.telNumberWithSpace.length;
    let newTelNumSize = this.NUM_TEXT_FONT_SIZE_MAX;
    let maxTelNumberLength =
      EnvironmentProp.isPhone() && this.curBp === 'md' ? this.NUM_TEXT_MAXSIZE_LENGTH_13 : this.NUM_TEXT_MAXSIZE_LENGTH;
    if (numLength > maxTelNumberLength) {
      newTelNumSize = this.NUM_TEXT_FONT_SIZE_MAX * maxTelNumberLength / numLength;
      if (newTelNumSize < this.NUM_TEXT_FONT_SIZE_MIN) {
        newTelNumSize = this.NUM_TEXT_FONT_SIZE_MIN;
      }
    }
    if (this.telNumSize != newTelNumSize) {
      this.telNumSize = newTelNumSize;
    }
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear DialerPad ');
    this.getMenu();
    this.mPresenter.aboutToAppear();
    this.isShowImeiPanel = false;
    if (this.missedCallId !== -1) {
      HiLog.i(TAG, `before set activeCallId: ${this.activeCallId}, missedCallId: ${this.missedCallId}`);
      this.activeCallId = this.missedCallId;
      this.missedCallId = -1;
    } else {
      this.activeCallId = -1;
    }
    this.dialPadBottomPadding = this.getDialerPadBottomPadding();
    this.callButtonBottomMargin = this.getCallButtonBottomMargin();
    this.telNumberChange();
  }

  aboutToDisappear() {
    this.mPresenter.onDestroy();
    clearInterval(this.timerId);
  }

  getMenu() {
    this.menuRes.forEach((element, i) => {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getString(element.id, (err: Error, typeName: string) => {
          HiLog.i(TAG, typeName);
          this.callmenu.push({
            value: typeName,
            action: () => {
            }
          })
        })
    })
  }
  // CustomKeyboardBuilder
  @Builder
  CustomKeyboardBuilder() {
    Column() {
    }
  }

  getLocation(number: string) {
    let newNumber = number.replace(new RegExp('\\s+', 'g'), '');
    // 号码长度小于2，不需要查询归属地
    // 超过最大长度，不需要查询归属地，+8618515009431  len=14，有归属地；
    // 再加一位：15，需要查询归属地，刷新归属地信息为空；长度大于15，不需要查询归属地了
    if (newNumber.length <= QUERY_LOCATION_PHONE_NUMBER_MIN_LEN ||
      newNumber.length > QUERY_LOCATION_PHONE_NUMBER_MAX_LEN) {
      // 没有归属地信息，将归属地信息置空
      HiLog.w(TAG, 'getLocation no location');
      this.numberLocation = '';
      return;
    }
    GetNumberLocation.getNumberLocation(newNumber, (location: string) => {
      this.numberLocation = location;
    }, false)
  }

  getBindSheetHeight() {
    let bindSheetHeight = 0;
    bindSheetHeight = JSON.parse(this.mPresenter.sizeValue).height + 56;
    if (bindSheetHeight < 320) {
      bindSheetHeight = 320;
    } else if (bindSheetHeight > 540) {
      bindSheetHeight = 540;
    }
    return bindSheetHeight;
  }

  private isSplitTable(splitStatus: SplitStatus): boolean {
    let result: boolean = false;
    if ((DisplaySplitUtil.isFoldStatus()) && (DisplaySplitUtil.isHorizonSplit(this.splitStatus))) {
      result = true;
    }
    if ( (deviceInfo.deviceType == 'tablet' && DisplaySplitUtil.isVerticalSplit(this.splitStatus))) {
      result = true;
    }
    if ( (deviceInfo.deviceType == 'tablet' && DisplaySplitUtil.isHorizonSplit(this.splitStatus))) {
      result = true;
    }
    return result;
  }

  private isSplitFlex(splitStatus: SplitStatus): boolean {
    let result: boolean = false;
    if ((deviceInfo.deviceType == 'tablet') && (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) {
      result = true;
    }
    if ((deviceInfo.deviceType == 'tablet') && (this.splitStatus === SplitStatus.HALF_SPLIT)) {
      result = true;
    }
    return result;
  }

  private getCallButtonOpacity() {
    if (!EnvironmentProp.isTablet() || this.haveSimCard ||
      (EnvironmentProp.isPhone() && AppStorage.get('breakpoint') === 'lg')) {
      return CALL_BUTTON_OPACITY;
    } else if ((AppStorage.get('isDistributedCallPhoneSharing') &&
      AppStorage.get('isDistributedModemState') &&
      AppStorage.get('isDistributedCallSourcePhone'))) {
      return CALL_BUTTON_OPACITY;
    } else {
      return $r('sys.float.alpha_tertiary');
    }
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.color_paste_press_background'))
    .borderRadius($r('sys.float.corner_radius_level4'))
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('app.color.color_paste_background'))
    .borderRadius($r('sys.float.corner_radius_level4'))
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Flex({
            direction: FlexDirection.Column,
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
              Flex({
                direction: FlexDirection.Row,
                alignItems: ItemAlign.Center,
                justifyContent: FlexAlign.Center
              }) {
                if (this.showTelNumber) {
                  TextInput({
                    text: this.telNumberWithSpace,
                    controller: this.mPresenter.textController
                  })
                    .width('auto')
                    .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
                    .direction(Direction.Ltr)
                    .type(InputType.PhoneNumber)
                    .padding(this.isSplitFlex(this.splitStatus) ||
                      DisplaySplitUtil.isFoldStatus() && DisplaySplitUtil.isHorizonSplit(this.splitStatus) ? 0 : null)
                    .fontSize(DisplaySplitUtil.isHorizonSplit(this.splitStatus) ||
                      DisplaySplitUtil.isVerticalSplit(this.splitStatus) ? '38vp' : `${this.telNumSize}vp`)
                    .key('telNumberInput')
                    .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
                    .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                    .fontWeight(600)
                    .textAlign(TextAlign.Center)
                    .maxLines(1)
                    .backgroundColor(this.isThemeActive ? Color.Transparent : $r('app.color.skin_background_primary'))
                    .enableKeyboardOnFocus(false)
                    .copyOption(CopyOptions.LocalDevice)
                    .customKeyboard(this.CustomKeyboardBuilder())
                    .defaultFocus(this.isPC)
                    .enablePreviewText(false)
                    .focusable(true)
                    .onTextSelectionChange((selectStart: number, selectEnd: number) => {
                      HiLog.w(TAG,
                        `selectStart: ${selectStart}, selectEnd: ${selectEnd}, telNumberWithSpace length: ${this.telNumberWithSpace?.length}`)
                      this.mPresenter.setTextSelectStatus(selectStart, selectEnd);
                    })
                    .onChange((value: string) => {
                      HiLog.w(TAG, `dialer_contacts_telNumberInput_textInput onchange value length: ${value.length}`);
                      // Sets the position of the cursor.
                      focusControl.requestFocus('telNumberInput');
                      this.mPresenter.handleInputChange(value.replaceAll('-',''));
                      if (value === SECRET_CODE_MMI_IMEI_DISPLAY) {
                        clearInterval(this.timerId);
                        this.timerId = setInterval(() => {
                          if (DialerPresenter.getInstance().isShowImeiPanel) {
                            this.isShowImeiPanel = true;
                            clearInterval(this.timerId);
                          }
                        }, 50)
                      }
                      let initIndex = this.mPresenter.computeFormatIndex(this.telNumberWithSpace,
                        this.mPresenter.afterActionCaret[0]);
                      HiLog.w(TAG, `initIndex: ${initIndex}, telNumberWithSpace: ${this.telNumberWithSpace?.length}`);
                      if (initIndex === this.telNumberWithSpace.length) {
                        HiLog.w(TAG, `isShowCursor: ${this.isPasteShowCursor}`);
                        if (!this.isPasteShowCursor) {
                          this.textInputController.stopEditing();
                          this.textInputFocusable = false;
                        }
                        this.mPresenter.setTextSelectStatus(this.telNumberWithSpace.length,
                          this.telNumberWithSpace.length);
                      }

                      this.getLocation(this.telNumberWithSpace);
                    })
                    .onTouch(() => {
                      this.textInputFocusable = true;
                    })
                    .onDrop((dragEvent?: DragEvent) => {
                      if (dragEvent) {
                        let records: UDC.UnifiedRecord[] = dragEvent.getData().getRecords();
                        HiLog.w(TAG, `onDrop records length: ${records?.length}`);
                        // record 获取统一数据即所有数据
                        let str: string = '';
                        for (let i = 0; i < records.length; i++) {
                          let record = records[i];
                          HiLog.w(TAG, `type: ${record.getType()}`);
                          if (record.getType() == UTD.UniformDataType.PLAIN_TEXT) {
                            let plainText = record as UDC.PlainText;
                            let value: string = plainText.textContent;
                            if (!StringUtil.isEmpty(value)) {
                              str += value;
                            }
                          } else if (record.getType() == UTD.UniformDataType.TEXT) {
                            let text = record as UDC.Text;
                            let value: string | undefined = text.details?.content;
                            if (!StringUtil.isEmpty(value)) {
                              str += value;
                            }
                          }
                        }
                        HiLog.w(TAG, `str length is: ${str?.length} `);
                        let data: UDC.PlainText = new UDC.PlainText();
                        // Replace illegal symbols
                        const filterResult = str.replace(new RegExp('[^0-9*#＊＃+\\-,;]', 'g'), '')
                          .replace(new RegExp('[＊]', 'g'), '*')
                          .replace(new RegExp('[＃]', 'g'), '#');
                        this.mPresenter.replaceSelectedStr(this.telNumberWithSpace, filterResult); //设置光标
                        data.textContent = filterResult;
                        dragEvent.setData(new UDC.UnifiedData(data));
                      }
                      focusControl.requestFocus('telNumberInput');
                    })
                    .onCut((value: string) => {
                      // 点击剪切板剪切按钮，触发该回调
                      HiLog.w(TAG, `onCut!`);
                      /** 避免使用mpresenter.isDialerInputCut的形式赋值,会使TextInput绑定的controler state数据有变更,
                      导致TextInput刷新,这样会使剪切之后的数据被覆盖 **/
                      AppStorage.SetOrCreate('isDialerInputCut', true);
                    })
                    .onPaste((value: string, event?: PasteEvent) => {
                      // 先判断粘贴过来的数据合法性
                      HiLog.w(TAG, `paste value length: ${value?.length}`);
                      if (StringUtil.isEmpty(value)) {
                        return;
                      }
                      // Replace illegal symbols
                      const filterResult = value.replace(new RegExp('[^0-9*#＊＃+\\-,;]', 'g'), '')
                        .replace(new RegExp('[＊]', 'g'), '*')
                        .replace(new RegExp('[＃]', 'g'), '#');
                      if (StringUtil.isEmpty(filterResult)) {
                        if (event != undefined && event.preventDefault) {
                          HiLog.w(TAG, 'paste filter result is null,Prevent System Default Paste');
                          // 阻止系统默认粘贴
                          event.preventDefault();
                        }
                        return;
                      }
                      // Replace the selected content in the text box.
                      let result: string = this.mPresenter.replaceSelectedStr(this.telNumberWithSpace, filterResult);
                      // 用于格式化显示
                      AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, result);
                      // Paste function cursor keeps appearing
                      AppStorage.SetOrCreate('isPasteShowCursor', true);
                    })
                    .onWillInsert((value: InsertValue) => {
                      let curTime: number = new Date().getTime();
                      if (curTime - this.lastInputTime <= DOUBLE_INPUT_INTERVAL_TIME) {
                        HiLog.e(TAG, `onWillInsert double input: ${value.insertValue}`);
                        return false;
                      }
                      this.lastInputTime = curTime;
                      if (regex.test(value.insertValue)) {
                        this.mPresenter.isKeyboardInput = true;
                        const newVal = this.mPresenter.getInsertStr(this.telNumberWithSpace, value.insertValue);
                        this.mPresenter.textSelectStart++;
                        this.mPresenter.textSelectEnd++;
                        //不带空格 用于搜索通话记录 1.先去除空格 再存入tele_number中
                        AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, newVal);
                      }
                      return false;
                    })
                    .onWillDelete((value: DeleteValue) => {
                      let number: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
                        AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
                      number = this.mPresenter.deleteStr(number); //删除之后的号码
                      AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, number);
                      return false;
                    })
                }
              }
              .width('100%')
              .constraintSize({
                minHeight: DisplaySplitUtil.isFoldStatus() && DisplaySplitUtil.isHorizonSplit(this.splitStatus) ?
                  '40vp' : (deviceInfo.deviceType == 'tablet' && this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
                    (deviceInfo.deviceType === 'tablet' && this.splitStatus === SplitStatus.HALF_SPLIT) ? 'auto' :
                    FontScaleState.isSmallerSixGeer(this.fontSizeScale) ?
                      this.isMaximumZoom ? '52vp' : $r('app.float.dialer_telephone_number_height') :
                    $r('app.float.dialer_senior_telephone_number_height')
              })
              .bindSheet(this.isShowImeiPanel, DialBindSheetBuilder({ mPresenter: this.mPresenter }), {
                height: this.getBindSheetHeight(),
                width: 480,
                title: { title: $r('app.string.device_info') },
                preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
                onWillAppear: () => {
                  HiLog.w(TAG, `dialerPad ImeiPanel appear`);
                  this.mPresenter.resetTelNumber();
                  if (this.textInputFocusable) {
                    HiLog.w(TAG, `cursor hide`);
                    this.textInputFocusable = false;
                  }
                },
                shouldDismiss: (sheetDismiss: SheetDismiss) => {
                  HiLog.w(TAG, `dialerPad shouldDismiss, isShowImeiPanel: ${this.isShowImeiPanel}`);
                  this.isShowImeiPanel = !this.isShowImeiPanel;
                  DialerPresenter.getInstance().isShowImeiPanel = false;
                },
                onWillSpringBackWhenDismiss: ((springBackAction: SpringBackAction) => {
                })
              })
              .margin({
                bottom: DisplaySplitUtil.isFoldStatus() && DisplaySplitUtil.isHorizonSplit(this.splitStatus) ? 8 : 0
              })

            Text(this.numberLocation)
              .fontSize(this.splitStatus === SplitStatus.DEFAULT ? $r('sys.float.Body_M') : '14vp')
              .fontColor($r('app.color.skin_font_primary'))
              .fontWeight(FontWeight.Regular)
              .opacity($r('sys.float.alpha_secondary'))
              .offset({
                x: 0,
                y: this.isMaximumZoom ? 0 :
                  (deviceInfo.deviceType === 'tablet') && (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
                    (deviceInfo.deviceType === 'tablet') && (this.splitStatus === SplitStatus.HALF_SPLIT) ? 0 :
                    FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? -25 :
                      (FontScaleState.isSmallerSixGeer(this.fontSizeScale) ? -15 : 8)
              })
              .margin({
                top: (deviceInfo.deviceType === 'tablet' && this.splitStatus === SplitStatus.ONE_THREE_SPLIT) ||
                  (deviceInfo.deviceType === 'tablet' && this.splitStatus === SplitStatus.HALF_SPLIT) ? 2 : 0
              })
              .visibility(DisplaySplitUtil.isFoldStatus() && DisplaySplitUtil.isHorizonSplit(this.splitStatus) ?
                Visibility.None : this.showTelNumber && (this.telNumberWithSpace.length > 0) ? Visibility.Visible :
                Visibility.Hidden)

            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
              GridRow({ columns: { sm: 4, md: 4, lg: 8 }, gutter: { x: 12, y: 0 } }) {
                GridCol({
                  span: { sm: 4, md: 4, lg: this.isPC ? 8 : this.isTabletLandscape ? 6 : 8 },
                  offset: { sm: 4, md: 0, lg: this.isPC ? 0 : this.isTabletLandscape ? 1 : 0 }
                }) {
                  Column() {
                    Flex({
                      direction: FlexDirection.Column,
                      alignItems: ItemAlign.Center,
                      justifyContent: (DisplaySplitUtil.isFoldStatus()) &&
                        DisplaySplitUtil.isHorizonSplit(this.splitStatus) ? FlexAlign.Start : FlexAlign.End
                    }) {
                      if (this.isHasPateDate && this.pasteStatus && !StringUtil.isEmpty(this.pasteData)) {
                        Column() {
                          Column() {
                            Text($r('app.string.click_to_paste'))
                              .lineHeight(FontScaleState.isStandardGeer(this.fontSizeScale) ? '19vp' : 0)
                              .fontSize(14)
                              .fontWeight(FontWeight.Regular)
                              .fontFamily('HarmonyHeiTi')
                              .fontColor($r('app.color.skin_font_emphasize'))
                            Text(this.pasteData)
                              .lineHeight(FontScaleState.isStandardGeer(this.fontSizeScale) ? '19vp' : 0)
                              .fontSize(14)
                              .fontWeight(FontWeight.Regular)
                              .fontFamily('HarmonyHeiTi')
                              .fontColor($r('app.color.skin_font_emphasize'))
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                              .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
                              .direction(Direction.Ltr)
                          }
                          .stateStyles({
                            normal: this.normalStyles,
                            pressed: this.pressedStyles
                          })
                          .alignItems(HorizontalAlign.Center)
                          .padding({
                            top: $r('app.float.item_margin_width_4'),
                            right: $r('app.float.dialer_keypad_margin1'),
                            bottom: $r('app.float.item_margin_width_4'),
                            left: $r('app.float.dialer_keypad_margin1')
                          })
                        }
                        .id('paste_data')
                        .onAppear(() => {
                          HiLog.w(TAG, 'DialerPad pasteDialog appear');
                          this.isAppear = true;
                          // 场景1.判断当前弹窗出现的时候刚好在电话页面
                          if (this.isOpenAccessibility) {
                            HiLog.w(TAG, `pasteDialog appear and callIndex`);
                            AccessibilityUtil.getInstance()
                              .sendAccessibilityEvent(this.isOpenAccessibility, 'paste_data');
                          }
                          // 联系人打点-粘贴弹窗打点
                          DotUtil.getInstance()
                            .contactDot(customParams, dotCommon.eventName.STICKER_BOARD_APPEAR_EVENT);
                        })
                        .onDisAppear(() => {
                          HiLog.w(TAG, 'DialerPad pasteDialog disAppear');
                          this.isAppear = false;
                        })
                        .margin({
                          bottom: this.isInVisionGlass ? '0vp' : '8vp',
                        })
                        .width('100%')
                        .borderRadius($r('sys.float.corner_radius_level4'))
                        .backgroundColor($r('app.color.skin_background_primary'))
                        .onClick(() => {
                          // 号码清空上屏，并且粘贴弹窗消失
                          this.mPresenter.pasteFunc();
                          this.pasteStatus = false;
                          // 联系人打点-点击粘贴号码
                          DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.CLICK_STICKER_BOARD_EVENT);
                        })
                      }
                      if (this.isInVisionGlass || this.isMaximumZoom ||
                        (Number(this.settingFontScale) === noCareModeMaxFOnt)) {
                        DialPad()
                      } else {
                        DiaPadTablet({
                          dialPadHeight: this.dialPadHeight,
                          dialButtonHeight: this.dialButtonHeight
                        })
                      }
                      Row() {
                      Flex({
                        direction: FlexDirection.Row,
                        alignItems: ItemAlign.Center,
                        justifyContent: FlexAlign.SpaceAround
                      }) {
                        //TODO 双卡拨号按钮
                        Button({ type: ButtonType.Circle })
                          .backgroundColor(this.isThemeActive ? Color.Transparent :
                          $r('app.color.skin_background_primary'))
                          .width((deviceInfo.deviceType == 'tablet' &&
                            (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ||
                            (DisplaySplitUtil.isFoldStatus()) &&
                              (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 52 :
                            this.curBp === 'lg' ? $r('app.float.id_item_height_max') :
                            $r('app.float.id_item_height_large'))
                          .height((deviceInfo.deviceType == 'tablet' &&
                            (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ||
                            (DisplaySplitUtil.isFoldStatus()) &&
                              (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 52 :
                            this.curBp === 'lg' ? $r('app.float.id_item_height_max') :
                            $r('app.float.id_item_height_large'))
                          .enabled(false)
                          .flexShrink(0)


                        //飞行模式不管单双卡都需要走无卡的按钮样式
                        if (this.isAirplaneMode) {
                          Button({ type: ButtonType.Circle }) {
                            SymbolGlyph($r('sys.symbol.phone_fill'))
                              .fontSize(
                                deviceInfo.deviceType == 'tablet' && (this.splitStatus === SplitStatus.HALF_SPLIT) ?
                                  '37vp' : (deviceInfo.deviceType == 'tablet' &&
                                  (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? '32vp' :
                                  (DisplaySplitUtil.isFoldStatus()) &&
                                    (this.splitStatus === SplitStatus.HALF_SPLIT) ||
                                  DisplaySplitUtil.isSmLeft(this.splitStatus) ?
                                    '24vp' : this.curBp === 'lg' ? '37vp' : $r('app.float.id_card_margin_xxxxl'))
                              .fontColor([$r('app.color.skin_white')])
                          }
                          .width(
                            (deviceInfo.deviceType == 'tablet' &&
                              (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ||
                              (DisplaySplitUtil.isFoldStatus()) &&
                                (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 52 :
                              this.curBp === 'lg' ? $r('app.float.id_item_height_max') :
                              $r('app.float.id_item_height_large'))
                          .height((deviceInfo.deviceType == 'tablet' &&
                            (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ||
                            (DisplaySplitUtil.isFoldStatus()) &&
                              (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 52 :
                            this.curBp === 'lg' ? $r('app.float.id_item_height_max') :
                            $r('app.float.id_item_height_large'))
                          .backgroundColor($r('app.color.skin_confirm'))
                          .opacity(!EnvironmentProp.isTablet() || this.haveSimCard
                            ? 1 : $r('sys.float.alpha_tertiary'))
                          .onClick(() => {
                            HiLog.w(TAG, `airplaneMode: ${this.isAirplaneMode}, Clicking the button...`);
                            this.mPresenter.dialClick(this.getUIContext());
                          })
                          .accessibilityText(AccessibilityUtil.getInstance()
                            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_call')))
                        } else if (!this.haveMultiSimCard) {
                          Button({ type: ButtonType.Circle }) { //两折叠和三折叠卫星通话拨号键
                            if (this.isHyacinthMode) { //风信子拨号按钮
                              if (deviceInfo.deviceType == 'tablet' && this.splitStatus === SplitStatus.HALF_SPLIT) {
                                Image(($r('app.media.hyacinth_call_button')))
                                  .fillColor($r('app.color.skin_white'))
                                  .size({ width: 37, height: 37 });
                              } else if (deviceInfo.deviceType == 'tablet' &&
                                this.splitStatus === SplitStatus.ONE_THREE_SPLIT) {
                                Image(($r('app.media.hyacinth_call_button')))
                                  .fillColor($r('app.color.skin_white'))
                                  .size({ width: 32, height: 32 });
                              } else if (
                                (DisplaySplitUtil.isFoldStatus() && this.splitStatus === SplitStatus.HALF_SPLIT) ||
                                  DisplaySplitUtil.isSmLeft(this.splitStatus)
                              ) {
                                Image(($r('app.media.hyacinth_call_button')))
                                  .fillColor($r('app.color.skin_white'))
                                  .size({ width: 24, height: 24 });
                              } else if (this.curBp === 'lg') {
                                Image(($r('app.media.hyacinth_call_button')))
                                  .fillColor($r('app.color.skin_white'))
                                  .size({ width: 37, height: 37 });
                              } else {
                                Image(($r('app.media.hyacinth_call_button')))
                                  .fillColor($r('app.color.skin_white'))
                                  .size({
                                    width: $r('app.float.id_card_margin_xxxxl'),
                                    height: $r('app.float.id_card_margin_xxxxl')
                                  });
                              }
                            } else if (this.isSatelliteMode) { //天通拨号按钮
                              SymbolGlyph($r('sys.symbol.phone_badge_satellite_fill'))
                                .fontSize(
                                  deviceInfo.deviceType == 'tablet' && (this.splitStatus === SplitStatus.HALF_SPLIT) ||
                                    deviceInfo.deviceType == 'tablet' &&
                                      (this.splitStatus === SplitStatus.HALF_SPLIT) ?
                                    '37vp' : (deviceInfo.deviceType == 'tablet' &&
                                    (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? '32vp' :
                                    (DisplaySplitUtil.isFoldStatus()) &&
                                      (this.splitStatus === SplitStatus.HALF_SPLIT) ||
                                    DisplaySplitUtil.isSmLeft(this.splitStatus) ?
                                      '24vp' : this.curBp === 'lg' ? '37vp' : $r('app.float.id_card_margin_xxxxl'))
                                .fontColor([$r('app.color.skin_white')])
                            } else {
                            SymbolGlyph($r('sys.symbol.phone_fill'))
                              .fontSize(
                                deviceInfo.deviceType == 'tablet' && (this.splitStatus === SplitStatus.HALF_SPLIT) ||
                                  deviceInfo.deviceType == 'tablet' &&
                                    (this.splitStatus === SplitStatus.HALF_SPLIT) ?
                                  '37vp' : (deviceInfo.deviceType == 'tablet' &&
                                  (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? '32vp' :
                                  (DisplaySplitUtil.isFoldStatus()) &&
                                    (this.splitStatus === SplitStatus.HALF_SPLIT) ||
                                  DisplaySplitUtil.isSmLeft(this.splitStatus) ?
                                    '24vp' : this.curBp === 'lg' ? '37vp' : $r('app.float.id_card_margin_xxxxl'))
                              .fontColor([$r('app.color.skin_white')])
                            }
                          }
                          .width((deviceInfo.deviceType == 'tablet' &&
                            (this.splitStatus === SplitStatus.VERTICAL_SPLIT)) ? 64 :
                            (deviceInfo.deviceType == 'tablet' &&
                              (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 56 :
                              (DisplaySplitUtil.isFoldStatus()) &&
                                (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 44 :
                                this.curBp === 'lg' ? $r('app.float.id_item_height_max') :
                                $r('app.float.id_item_height_large'))
                          .height((deviceInfo.deviceType == 'tablet' &&
                            (this.splitStatus === SplitStatus.VERTICAL_SPLIT)) ? 64 :
                            (deviceInfo.deviceType == 'tablet' &&
                              (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 56 :
                              (DisplaySplitUtil.isFoldStatus()) &&
                                (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 44 :
                                this.curBp === 'lg' ? $r('app.float.id_item_height_max') :
                                $r('app.float.id_item_height_large'))
                          .margin({
                            top: (DisplaySplitUtil.isFoldStatus()) &&
                              (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 6 :
                              (deviceInfo.deviceType == 'tablet' &&
                                (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 2 : 0,
                            bottom: (DisplaySplitUtil.isFoldStatus()) &&
                              (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 2 :
                              (deviceInfo.deviceType == 'tablet' &&
                                (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 2 : 0
                          })
                          .backgroundColor($r('app.color.skin_confirm'))
                          // Currently, it is not possible to tell whether the device has dial capability.
                          // 1. The dial button in phone is enable.
                          // 2. The dial button in tablet is enable only when sim card is inserted.
                          .opacity(this.getCallButtonOpacity())
                          .onClick(() => {
                            HiLog.w(TAG, `multiSimCard: ${this.haveMultiSimCard}, Clicking the button...`);
                            this.mPresenter.dialClick(this.getUIContext());
                            if (this.isPC || (EnvironmentProp.isDeviceTypeTablet() && this.windowPcMode)) {
                              this.mPresenter.resetTelNumber();
                            }
                          })
                          .accessibilityText(AccessibilityUtil.getInstance()
                            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_call')))
                        } else {
                          MutiDialerButtonView({
                            //三折叠双卡拨号按钮
                            mPresenter: $mPresenter,
                          })
                            .layoutWeight(!(this.defaultSlot === simId_DEFAULT || this.defaultSlot === undefined) ?
                              undefined : 1)
                        }
                        Row() {
                          Button({ type: ButtonType.Circle }) {
                            SymbolGlyph($r('sys.symbol.delete_left_fill'))
                              .fontSize($r('app.float.id_card_image_small'))
                              .fontColor([$r('app.color.skin_icon_primary')])
                              .margin({
                                top: (deviceInfo.deviceType === 'tablet' &&
                                  (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 2 : 0,
                                bottom: (deviceInfo.deviceType === 'tablet' &&
                                  (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 2 : 0
                              })
                          }
                          .padding({ right: this.isTabletLandscape ? '3vp' : 0 })
                          .flexShrink(0)
                          .margin({
                            left: this.haveMultiSimCard && !this.isAirplaneMode ?
                              !(this.defaultSlot === simId_DEFAULT || this.defaultSlot === undefined) ? '-8.5vp' :
                              $r('sys.float.padding_level2') : $r('sys.float.padding_level0'),
                            right: this.haveMultiSimCard && !this.isAirplaneMode ? $r('sys.float.padding_level6') :
                            $r('sys.float.padding_level0')
                          })
                          .backgroundColor($r('app.color.skin_background_primary'))
                          .width((DisplaySplitUtil.isFoldStatus()) &&
                            (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 44 : $r('app.float.id_height_56'))
                          .height((DisplaySplitUtil.isFoldStatus()) &&
                            (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 44 : $r('app.float.id_height_56'))
                          .type(ButtonType.Circle)
                          .opacity(this.telNumberWithSpace.length > 0 ? 1 : 0)
                          .enabled(this.telNumberWithSpace.length > 0 ? true : false)
                          .gesture(
                            LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
                              .onAction((event: GestureEvent) => {
                                AppStorage.setOrCreate('tele_number_pasteType', '');
                                this.mPresenter.resetTelNumber();
                                //TODO 代码含义是啥
                                this.mPresenter.editPhoneNumber('');
                                VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
                                if (this.pasteStatus) {
                                  HiLog.w(TAG, `dialerPad longPressDeleteButton pasteStatus disappear`);
                                  this.pasteStatus = false;
                                }
                                // 无障碍播报号码已清空
                                AccessibilityUtil.getInstance()
                                  .sendAccessibilityEventInfo(ResourceUtil.getStringByResource($r('app.string.accessibility_Text_cleared')));
                              })
                          )
                          .onClick(() => {
                            // 联系人打点--拨号盘删除号码
                            DotUtil.getInstance().contactDot(this.customizedParams, DELETE_NUM_EVENT);
                            let number: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
                              AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
                            number = this.mPresenter.deleteStr(number); //删除之后的号码
                            AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, number)
                            if (this.pasteStatus) {
                              HiLog.w(TAG, `dialerPad deleteButton pasteStatus disappear`);
                              this.pasteStatus = false;
                            }
                          })
                          .accessibilityText(AccessibilityUtil.getInstance()
                            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_delete')))
                        }
                        .padding({
                          top: (DisplaySplitUtil.isFoldStatus()) &&
                            (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 6 : 0,
                          bottom: (DisplaySplitUtil.isFoldStatus()) &&
                            (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 2 : 0
                        })
                        .width(
                          (DisplaySplitUtil.isFoldStatus()) &&
                            (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 52 :
                            (deviceInfo.deviceType === 'tablet' &&
                              (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 56 :
                              this.curBp === 'lg' ? $r('app.float.id_item_height_max') :
                              $r('app.float.id_item_height_large'))
                        .height(
                          (DisplaySplitUtil.isFoldStatus()) &&
                            (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 52 :
                            (deviceInfo.deviceType === 'tablet' &&
                              (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 56 :
                              this.curBp === 'lg' ? $r('app.float.id_item_height_max') :
                              $r('app.float.id_item_height_large'))
                        .justifyContent(this.isTabletLandscape ? FlexAlign.End : FlexAlign.Center)
                      }
                    }
                      .width('100%')
                      .height((DisplaySplitUtil.isFoldStatus()) &&
                        (DisplaySplitUtil.isHorizonSplit(this.splitStatus)) ? 52 :
                        (deviceInfo.deviceType === 'tablet' && (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ?
                          '60vp' : '96vp')
                      .margin({
                        bottom: this.callButtonBottomMargin
                      })
                    }
                    .width('100%')
                    .height('100%')
                    .onAreaChange((oldValue: Area, newValue: Area) => {
                      let containerHeight: number =
                        Math.ceil(Number(newValue.height.toString().replace(/[^0-9.-]/g, ''))) - 142;
                      this.dialPadHeight = containerHeight < 240 ? 240 : containerHeight > 384 ? 384 : containerHeight;
                      this.dialButtonHeight = this.dialPadHeight / 4;
                    })
                  }
                  .height('100%')
                  .width('100%')
                }.width('100%').height('100%')
              }
            }
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
      }
      .padding({
        top: this.isPC ? $r('app.float.id_item_height_large') : this.isSplitTable(this.splitStatus) ? 32 :
        $r('app.float.id_speedDial_margin'),
        left: this.spaceLR,
        right: this.spaceLR,
        bottom: this.dialPadBottomPadding
      })
      .width('100%')
      .height('100%')
    }
    .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
    .backgroundImage(this.isThemeActive ? $r('app.media.contact_list_bg') : undefined)
    .backgroundImageSize(this.isThemeActive ? { width: '100%', height: '100%' } : undefined)
    .hideTitleBar(true)
  }

  private getDialerPadBottomPadding(): Length {
    if (this.isSmallPad && this.curBp === 'lg') {
      return '28vp';
    }
    if (((EnvironmentProp.isDeviceTypeTablet() || EnvironmentProp.isPhone() && this.curBp === 'lg') &&
    this.windowPcMode) || this.isPC) {
      return $r('app.float.id_item_height_sm');
    }
    if (((DisplaySplitUtil.isFoldStatus() && this.splitStatus === SplitStatus.HALF_SPLIT) ||
      (deviceInfo.deviceType == 'tablet' && this.splitStatus !== SplitStatus.DEFAULT))) {
      return 0;
    }
    return this.curBp !== 'lg' ? $r('app.float.SpeedDial_Suffix_height') :
      $r('app.float.id_records_divider_margin_left');
  }

  private getCallButtonBottomMargin(): Length {
    if (this.isInVisionGlass) {
      return '16vp';
    }
    if (this.isPC || this.isMaximumZoom) {
      return 0;
    }
    if (deviceInfo.deviceType !== 'tablet') {
      return this.curBp === 'lg' && !this.isTabletLandscape ? '52vp' : 0;
    }
    if (this.isSmallPad) {
      return this.curBp === 'lg' ? 0 : 52;
    }
    if ((EnvironmentProp.isDeviceTypeTablet() || EnvironmentProp.isPhone() && this.curBp === 'lg') &&
    this.windowPcMode) {
      return 22;
    }
    if (this.splitStatus === SplitStatus.DEFAULT) {
      return 52;
    }
    return this.splitStatus === SplitStatus.ONE_THREE_SPLIT ? 96 : 104;
  }

  private onBpChange(): void {
    this.dialPadBottomPadding = this.getDialerPadBottomPadding();
    this.callButtonBottomMargin = this.getCallButtonBottomMargin();
  }
}