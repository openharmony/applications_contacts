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
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { EnterSingleSelectedMode, VibrationEffect } from '../../model/type/EnumUtil';
import { DynamicLoader } from '../../../../../../common';
import VibrationUtils from '../../util/VibrationUtils';
import DialerConstant from '../../data/DialerConstant';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import dotCommon, { setContactParams } from '../../util/DotCommon';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { deviceInfo } from '@kit.BasicServicesKit';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { contact } from '@kit.ContactsKit';
import SpeedDialPresenter from '../../presenter/speeddial/SpeedDialPresenter';
import EnvironmentProp from '../../feature/EnvironmentProp';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { ContactsConstants } from '../../../../../../common/src/main/ets/ContactsConstants';

const TAG = 'DialButtonTablet';
const SPEED_DIAL_DIALOG_EVENT: string = 'SPEED_DIAL_DIALOG_EVENT';
const MINIMUN_INTERVAL_BETWEEN_TWO_ONTOUCH = 16;

@Component
export struct DialButtonTablet {
  @Consume('pathInfos') pathInfos: NavPathStack;
  buttonNumber: string = '';
  mPresenter: DialerPresenter = DialerPresenter.getInstance();
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  //有字母
  @State buttonImageOne: string = 'app.media.dialer_1';
  @State buttonImageTwo: string = 'app.media.dialer_2';
  @State buttonImageThree: string = 'app.media.dialer_3';
  @State buttonImageFour: string = 'app.media.dialer_4';
  @State buttonImageFive: string = 'app.media.dialer_5';
  @State buttonImageSix: string = 'app.media.dialer_6';
  @State buttonImageSev: string = 'app.media.dialer_7';
  @State buttonImageEight: string = 'app.media.dialer_8';
  @State buttonImageNine: string = 'app.media.dialer_9';
  @State buttonImageStar: string = 'app.media.dialer_star_key';
  @State buttonImagePound: string = 'app.media.dialer_pound_key';
  @State buttonImageZero: string = 'app.media.dialer_0';
  // 无字母
  @State noLettersImageOne: string = 'app.media.dialer_no_letters_1';
  @State noLettersImageTwo: string = 'app.media.dialer_no_letters_2';
  @State noLettersImageThree: string = 'app.media.dialer_no_letters_3';
  @State noLettersImageFour: string = 'app.media.dialer_no_letters_4';
  @State noLettersImageFive: string = 'app.media.dialer_no_letters_5';
  @State noLettersImageSix: string = 'app.media.dialer_no_letters_6';
  @State noLettersImageSev: string = 'app.media.dialer_no_letters_7';
  @State noLettersImageEight: string = 'app.media.dialer_no_letters_8';
  @State noLettersImageNine: string = 'app.media.dialer_no_letters_9';
  @State noLettersImageStar: string = 'app.media.dialer_no_letters_star_key';
  @State noLettersImagePound: string = 'app.media.dialer_no_letters_pound_key';
  @State noLettersImageZero: string = 'app.media.dialer_no_letters_0';
  @State isLongPress: boolean = false
  speedDialPresenter: SpeedDialPresenter = SpeedDialPresenter.getInstance();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageProp('isDarkMode') isDarkMode: boolean = false
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('dialpadTouchToneType') dialpadTouchToneType: string = '1';
  @State buttonColor: Resource = $r('app.color.skin_background_primary');
  @State isShowSheet: boolean = false;
  @StorageProp('windowHeightPx') windowHeightPx: number = 0;
  @State sheetParams: Record<string, number | string> | undefined = undefined;
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) telNumberWithSpace: string = '';
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  public speedDialDialog: CustomizedParams = {
    ISSET: 0
  }
  @StorageLink('lastPressButtonTime') lastPressButtonTime: number = -1;
  @StorageLink('isWindowPcMode') windowPcMode: boolean = false;
  @Prop dialButtonHeight: number;

  aboutToAppear() {
    this.mPresenter.noSimCardDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        primaryTitle: $r('app.string.voicemail'),
        contentBuilder: () => {
          this.NoSimCardDialogBuilder();
        },
        buttons: [{
          value: $r('app.string.confirm'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.i(TAG, 'voicemail alert confirm btn click')
          }
        }]
      }),
      autoCancel: false,
      gridCount: 5,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    });

    this.mPresenter.airplaneVoiceAlertDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        primaryTitle: $r('app.string.voicemail'),
        contentBuilder: () => {
          this.AirplaneVoiceAlertDialogBuilder();
        },
        buttons: [{
          value: $r('app.string.confirm'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.i(TAG, 'alert confirm btn click')
          }
        }]
      }),
      autoCancel: false,
      gridCount: 5,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    });

    this.mPresenter.airplaneSpeedAlertDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        primaryTitle: $r('app.string.speed_dial_setting'),
        contentBuilder: () => {
          this.AirplaneSpeedAlertDialogBuilder();
        },
        buttons: [{
          value: $r('app.string.confirm'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.i(TAG, 'alert confirm btn click')
          }
        }]
      }),
      autoCancel: false,
      gridCount: 5,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    });

    this.mPresenter.notSetSpeedDialDialogController = new CustomDialogController({
      builder: AlertDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        content: $r('app.string.not_set_speed_dial'),
        primaryButton: {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.i(TAG, 'click cancel');
            // 联系人打点--长按号码出现设置快速拨号弹窗-取消
            this.speedDialDialog.ISSET = 0;
            DotUtil.getInstance().contactDot(this.speedDialDialog, SPEED_DIAL_DIALOG_EVENT);
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        },
        secondaryButton: {
          value: $r('app.string.setting'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.i(TAG, 'click setting');
            // 联系人打点--长按号码出现设置快速拨号弹窗-取消
            this.speedDialDialog.ISSET = 1;
            DotUtil.getInstance().contactDot(this.speedDialDialog, SPEED_DIAL_DIALOG_EVENT);
            // 1, The navigation bar is implemented in different ways.
            let params: Record<string, number | string> =
              {
                'fromSpeedDial': EnterSingleSelectedMode.ContactSpeedDial,
                'selectedNumber': String(this.mPresenter.setSpeedNumber)
              };
            this.sheetParams = params;
            DynamicLoader.getInstance().fire(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE).then(() => {
              this.speedDialPresenter.speedDialToContact(Number(this.mPresenter.setSpeedNumber), true);
              contact.selectContacts({
                isMultiSelect: false
              }, (err, data) => {
                if (err) {
                  HiLog.e(TAG, `selectContacts error: ${err?.message}`);
                }
                this.speedDialPresenter.parseContactForResult(data, ContactsConstants.SPEED_DIAL).then(() => {
                }).catch((error: Error) => {
                  HiLog.e(TAG, `Error parsing contact for result: ${error?.message}`);
                })
              })
            });
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      }),
      autoCancel: false,
      gridCount: 5,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    });

    this.mPresenter.notSetVoicemailDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        primaryTitle: $r('app.string.not_set_voicemail'),
        contentBuilder: () => {
          this.NotSetVoicemailDialogBuilder();
        },
        buttons: [{
          value: $r('app.string.confirm'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.i(TAG, 'voicemail alert confirm btn click');
            //  联系人打点--长按1出现设置语音信箱(lg md)
            setContactParams.ISSET = dotCommon.eventParam.SET_VOICE_MAIL;
            DotUtil.getInstance().contactDot(setContactParams, dotCommon.eventName.SET_VOICE_NUM_DIALOG_EVENT);
            this.mPresenter.jumpToCallSetting();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }]
      }),
      autoCancel: true,
      gridCount: 5,
      backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
      cancel: () => {
        // 联系人打点--弹窗关闭
        setContactParams.ISSET = dotCommon.eventParam.CANCEL_SET;
        DotUtil.getInstance().contactDot(setContactParams, dotCommon.eventName.SET_VOICE_NUM_DIALOG_EVENT);
      }
    });
  }

  aboutToDisappear() {
    this.mPresenter.onDestroy();
  }

  setNumber(number: string) {
    AppStorage.SetOrCreate('isPasteShowCursor', false);
    AppStorage.SetOrCreate('showTelNumber', true)
    // numberWithSpace带空格 用于展示
    let numberWithSpace: string = AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string;
    const newVal = this.mPresenter.getInsertStr(numberWithSpace, number);
    //不带空格 用于搜索通话记录 1.先去除空格 再存入tele_number中
    AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, newVal);
    this.mPresenter.all_number = newVal;
  }

  /**
   * 图标下是否显示字母
   * @returns
   */
  isShowLetter() {
    if (this.splitStatus === SplitStatus.DEFAULT) {
      return true
    }
    if (DisplaySplitUtil.isFoldStatus() && this.splitStatus === SplitStatus.VERTICAL_SPLIT) {
      return true
    }
    if ((deviceInfo.deviceType == 'tablet' && this.splitStatus !== SplitStatus.ONE_THREE_SPLIT)) {
      return true
    }
    return false
  }

  private getDialButtonHeight(): string | number {
    let dialHeight: string | number = '';
    if ((EnvironmentProp.isDeviceTypeTablet() || EnvironmentProp.isPhone() && this.curBp === 'lg') &&
    this.windowPcMode) {
      dialHeight = this.dialButtonHeight;
    } else if (deviceInfo.deviceType == 'tablet' && (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) {
      dialHeight = '44vp'
    } else if ((DisplaySplitUtil.isFoldStatus()) && (DisplaySplitUtil.isHorizonSplit(this.splitStatus))) {
      dialHeight = (px2vp(this.windowHeightPx) - 228) / 4;
    } else if ((deviceInfo.deviceType == 'tablet' && (this.splitStatus === SplitStatus.VERTICAL_SPLIT))) {
      dialHeight = '96vp'
    } else if (this.curBp === 'lg' && !EnvironmentProp.isPC()) {
      dialHeight = '96vp';
    } else {
      dialHeight = '60vp';
    }
    return dialHeight;
  }

  @Builder
  backColor() {
    if (!this.isShowLetter()) {
      Row()
        .height('100%')
        .width(44)
        .backgroundColor(this.isDarkMode ? '#FFFFFF' : '#000000')
        .opacity(this.isDarkMode ? 0.149019608 : 0.101960784)
        .borderRadius((deviceInfo.deviceType == 'tablet' && (this.splitStatus === SplitStatus.ONE_THREE_SPLIT)) ? 22 :
          8)
        .visibility(this.isLongPress ? Visibility.Visible : Visibility.None)
    }
  }

  @Styles
  ButtonStyle() {
    .constraintSize({ maxHeight: '72vp' })
  }

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Center
      }) {
        if (this.buttonNumber == '1') {
          Image(this.isShowLetter() ? $r(this.buttonImageOne) : $r(this.noLettersImageOne))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageOne src = ' +
              this.isShowLetter() ? this.buttonImageOne : this.noLettersImageOne +
                ' imageOne error:' + error?.message);
            })
        } else if (this.buttonNumber == '2') {
          Image(this.isShowLetter() ? $r(this.buttonImageTwo) : $r(this.noLettersImageTwo))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageTwo src = ' +
              this.isShowLetter() ? this.buttonImageTwo : this.noLettersImageTwo +
                ' imageTwo error:' + error?.message);
            })
        } else if (this.buttonNumber == '3') {
          Image(this.isShowLetter() ? $r(this.buttonImageThree) : $r(this.noLettersImageThree))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageThree src = ' +
              this.isShowLetter() ? this.buttonImageThree : this.noLettersImageThree +
                'imageThree error:' + error?.message);
            })
        } else if (this.buttonNumber == '4') {
          Image(this.isShowLetter() ? $r(this.buttonImageFour) : $r(this.noLettersImageFour))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageFour src = ' +
              this.isShowLetter() ? this.buttonImageFour : this.noLettersImageFour +
                ' imageFour error:' + error?.message);
            })
        } else if (this.buttonNumber == '5') {
          Image(this.isShowLetter() ? $r(this.buttonImageFive) : $r(this.noLettersImageFive))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageFive src = ' +
              this.isShowLetter() ? this.buttonImageFive : this.noLettersImageFive +
                ' imageFive error:' + error?.message);
            })
        } else if (this.buttonNumber == '6') {
          Image(this.isShowLetter() ? $r(this.buttonImageSix) : $r(this.noLettersImageSix))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageSix src = ' +
              this.isShowLetter() ? this.buttonImageSix : this.noLettersImageSix +
                ' imageSix error:' + error?.message);
            })
        } else if (this.buttonNumber == '7') {
          Image(this.isShowLetter() ? $r(this.buttonImageSev) : $r(this.noLettersImageSev))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageSev src = ' +
              this.isShowLetter() ? this.buttonImageSev : this.noLettersImageSev +
                ' imageSev error:' + error?.message);
            })
        } else if (this.buttonNumber == '8') {
          Image(this.isShowLetter() ? $r(this.buttonImageEight) : $r(this.noLettersImageEight))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageEight src = ' +
              this.isShowLetter() ? this.buttonImageEight : this.noLettersImageEight +
                ' imageEight error:' + error?.message);
            })
        } else if (this.buttonNumber == '9') {
          Image(this.isShowLetter() ? $r(this.buttonImageNine) : $r(this.noLettersImageNine))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageNine src = ' +
              this.isShowLetter() ? this.buttonImageNine : this.noLettersImageNine +
                ' imageNine error:' + error?.message);
            })
        } else if (this.buttonNumber == '0') {
          Image(this.isShowLetter() ? $r(this.buttonImageZero) : $r(this.noLettersImageZero))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageZero src = ' +
              this.isShowLetter() ? this.buttonImageZero : this.noLettersImageZero +
                ' imageZero error:' + error?.message);
            })
        } else if (this.buttonNumber == '*') {
          Image(this.isShowLetter() ? $r(this.buttonImageStar) : $r(this.noLettersImageStar))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imageStar src = ' +
              this.isShowLetter() ? this.buttonImageStar : this.noLettersImagePound +
                ' imageStar error:' + error?.message);
            })
        } else {
          Image(this.isShowLetter() ? $r(this.buttonImagePound) : $r(this.noLettersImagePound))
            .ButtonStyle()
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .onError((error: ImageError) => {
              HiLog.i(TAG, 'imagePound src = ' +
              this.isShowLetter() ? this.buttonImagePound : this.noLettersImageStar +
                ' imagePound error:' + error?.message);
            })
        }
      }
    }
    .height(this.getDialButtonHeight())
    .flexGrow(1)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .onClick((event: ClickEvent) => {
      // 开启无障碍,onclick自动识别单指双击操作,ontouch不执行
      if (this.isOpenAccessibility) {
        HiLog.w(TAG, `accessibility is on`);
        this.setNumber(this.buttonNumber);
        this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.buttonNumber);
        if (this.pasteStatus) {
          HiLog.w(TAG, `dialerPad setNumber pasteStatus disappear`);
          this.pasteStatus = false;
        }
      } else {
        // 非无障碍模式下，首次点击触发上屏
        if (StringUtil.isEmpty(this.telNumberWithSpace)) {
          this.lastPressButtonTime = new Date().getTime();
          HiLog.w(TAG, `lastPressButtonTime: ${this.lastPressButtonTime},column onClick!!!`);
          this.setNumber(this.buttonNumber);
          this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
          if (this.pasteStatus) {
            HiLog.w(TAG, `dialerPad setNumber pasteStatus disappear`);
            this.pasteStatus = false;
          }
        }
      }
    })
    .accessibilityGroup(true)
    .accessibilityText(this.buttonNumber)
    .onAccessibilityHover((isHover: boolean, event: AccessibilityHoverEvent) => {
      if (!isHover && event.type === AccessibilityHoverType.HOVER_EXIT) {
        this.setNumber(this.buttonNumber)
        this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType)
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.buttonNumber);
      }
    })
    .onMouse((event: MouseEvent) => {
      if (event.button == MouseButton.Right && event.action == MouseAction.Release) {
        if (this.mPresenter.all_number.length >= 1) {
          // Input length greater than 1
          // press '*' to convert to ',' and press '#' to ';', press other characters to append
          if (this.buttonNumber === '*' || this.buttonNumber === '#' || this.buttonNumber === '0') {
            let number = '';
            if (this.buttonNumber === '*') {
              number = ',';
            } else if (this.buttonNumber === '#') {
              number = ';';
            } else if (this.buttonNumber === '0') {
              number = '+';
            }
            this.setNumber(number);
          } else {
            this.setNumber(this.buttonNumber);
          }
          this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
        }
        if (this.mPresenter.all_number.length === 0 && this.buttonNumber === '0') {
          let number = '+';
          this.setNumber(number);
          this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
        } else {
          // Initiate speed dial when no character is entered.
          if (!this.maintenanceMode) {
            this.mPresenter.speedDialAction(this.getUIContext(), this.buttonNumber);
          }
        }
      }
    })
    .gesture(
      GestureGroup(GestureMode.Exclusive, LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
          .onAction((event: GestureEvent | undefined) => {
            VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
            if (this.mPresenter.all_number.length >= 1) {
              // Input length greater than 1
              // press '*' to convert to ',' and press '#' to ';', press other characters to append
              if (this.buttonNumber === '*' || this.buttonNumber === '#' || this.buttonNumber === '0') {
                let number = '';
                if (this.buttonNumber === '*') {
                  number = ',';
                } else if (this.buttonNumber === '#') {
                  number = ';';
                } else if (this.buttonNumber === '0') {
                  number = '+';
                }
                this.setNumber(number);
              } else {
                this.setNumber(this.buttonNumber);
              }
              this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
            }
            if (this.mPresenter.all_number.length === 0 && this.buttonNumber === '0') {
              let number = '+';
              this.setNumber(number);
              this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
            } else {
              // Initiate speed dial when no character is entered.
              if (!this.maintenanceMode) {
                this.mPresenter.speedDialAction(this.getUIContext(), this.buttonNumber);
              }
            }
            if (this.pasteStatus) {
              HiLog.w(TAG, 'dialerPadButtonLongPress pasteStatus disappear');
              this.pasteStatus = false;
            }
          })
      ))

    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isLongPress = true
        if (this.buttonNumber == '1') {
          this.buttonImageOne = 'app.media.dialer_press_1'
          this.noLettersImageOne = 'app.media.dialer_no_letters_press_1'
        } else if (this.buttonNumber == '2') {
          this.buttonImageTwo = 'app.media.dialer_press_2'
          this.noLettersImageTwo = 'app.media.dialer_no_letters_press_2'
        } else if (this.buttonNumber == '3') {
          this.buttonImageThree = 'app.media.dialer_press_3'
          this.noLettersImageThree = 'app.media.dialer_no_letters_press_3'
        } else if (this.buttonNumber == '4') {
          this.buttonImageFour = 'app.media.dialer_press_4'
          this.noLettersImageFour = 'app.media.dialer_no_letters_press_4'
        } else if (this.buttonNumber == '5') {
          this.buttonImageFive = 'app.media.dialer_press_5'
          this.noLettersImageFive = 'app.media.dialer_no_letters_press_5'
        } else if (this.buttonNumber == '6') {
          this.buttonImageSix = 'app.media.dialer_press_6'
          this.noLettersImageSix = 'app.media.dialer_no_letters_press_6'
        } else if (this.buttonNumber == '7') {
          this.buttonImageSev = 'app.media.dialer_press_7'
          this.noLettersImageSev = 'app.media.dialer_no_letters_press_7'
        } else if (this.buttonNumber == '8') {
          this.buttonImageEight = 'app.media.dialer_press_8'
          this.noLettersImageEight = 'app.media.dialer_no_letters_press_8'
        } else if (this.buttonNumber == '9') {
          this.buttonImageNine = 'app.media.dialer_press_9'
          this.noLettersImageNine = 'app.media.dialer_no_letters_press_9'
        } else if (this.buttonNumber == '0') {
          this.buttonImageZero = 'app.media.dialer_press_0'
          this.noLettersImageZero = 'app.media.dialer_no_letters_press_0'
        } else if (this.buttonNumber == '*') {
          this.buttonImageStar = 'app.media.dialer_press_star'
          this.noLettersImageStar = 'app.media.dialer_no_letters_press_star_key'
        } else {
          this.buttonImagePound = 'app.media.dialer_press_pound'
          this.noLettersImagePound = 'app.media.dialer_no_letters_press_pound_key'
        }
        // 无障碍模式下 不触发ontouch
        if (!this.isOpenAccessibility) {
          // 针对16ms内触发多个down事件的情况做丢弃处理，本次down事件距上次时间间隔小于16ms就不上屏
          if (!StringUtil.isEmpty(this.telNumberWithSpace)) {
            let nowTime = new Date().getTime();
            if ((Math.abs(nowTime - this.lastPressButtonTime)) > MINIMUN_INTERVAL_BETWEEN_TWO_ONTOUCH) {
              HiLog.w(TAG, `nowTime: ${nowTime}, lastPressButtonTime: ${this.lastPressButtonTime}`);
              this.lastPressButtonTime = nowTime;
              this.setNumber(this.buttonNumber);
              this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
              if (this.pasteStatus) {
                HiLog.w(TAG, `dialerPad setNumber pasteStatus disappear`);
                this.pasteStatus = false;
              }
            } else {
              HiLog.e(TAG, `nowTime: ${nowTime}, lastPressButtonTime: ${this.lastPressButtonTime}, discard this input`);
            }
          }
        }
      }
      if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isLongPress = false
        if (this.buttonNumber == '1') {
          this.buttonImageOne = 'app.media.dialer_1'
          this.noLettersImageOne = 'app.media.dialer_no_letters_1'
        } else if (this.buttonNumber == '2') {
          this.buttonImageTwo = 'app.media.dialer_2'
          this.noLettersImageTwo = 'app.media.dialer_no_letters_2'
        } else if (this.buttonNumber == '3') {
          this.buttonImageThree = 'app.media.dialer_3'
          this.noLettersImageThree = 'app.media.dialer_no_letters_3'
        } else if (this.buttonNumber == '4') {
          this.buttonImageFour = 'app.media.dialer_4'
          this.noLettersImageFour = 'app.media.dialer_no_letters_4'
        } else if (this.buttonNumber == '5') {
          this.buttonImageFive = 'app.media.dialer_5'
          this.noLettersImageFive = 'app.media.dialer_no_letters_5'
        } else if (this.buttonNumber == '6') {
          this.buttonImageSix = 'app.media.dialer_6'
          this.noLettersImageSix = 'app.media.dialer_no_letters_6'
        } else if (this.buttonNumber == '7') {
          this.buttonImageSev = 'app.media.dialer_7'
          this.noLettersImageSev = 'app.media.dialer_no_letters_7'
        } else if (this.buttonNumber == '8') {
          this.buttonImageEight = 'app.media.dialer_8'
          this.noLettersImageEight = 'app.media.dialer_no_letters_8'
        } else if (this.buttonNumber == '9') {
          this.buttonImageNine = 'app.media.dialer_9'
          this.noLettersImageNine = 'app.media.dialer_no_letters_9'
        } else if (this.buttonNumber == '0') {
          this.buttonImageZero = 'app.media.dialer_0'
          this.noLettersImageZero = 'app.media.dialer_no_letters_0'
        } else if (this.buttonNumber == '*') {
          this.buttonImageStar = 'app.media.dialer_star_key'
          this.noLettersImageStar = 'app.media.dialer_no_letters_star_key'
        } else {
          this.buttonImagePound = 'app.media.dialer_pound_key'
          this.noLettersImagePound = 'app.media.dialer_no_letters_pound_key'
        }
      }
    })
    .onHover((isHover: boolean) => {
      if (isHover) {
        this.isLongPress = true
        if (this.buttonNumber == '1') {
          this.buttonImageOne = 'app.media.dialer_press_1'
          this.noLettersImageOne = 'app.media.dialer_no_letters_press_1'
        } else if (this.buttonNumber == '2') {
          this.buttonImageTwo = 'app.media.dialer_press_2'
          this.noLettersImageTwo = 'app.media.dialer_no_letters_press_2'
        } else if (this.buttonNumber == '3') {
          this.buttonImageThree = 'app.media.dialer_press_3'
          this.noLettersImageThree = 'app.media.dialer_no_letters_press_3'
        } else if (this.buttonNumber == '4') {
          this.buttonImageFour = 'app.media.dialer_press_4'
          this.noLettersImageFour = 'app.media.dialer_no_letters_press_4'
        } else if (this.buttonNumber == '5') {
          this.buttonImageFive = 'app.media.dialer_press_5'
          this.noLettersImageFive = 'app.media.dialer_no_letters_press_5'
        } else if (this.buttonNumber == '6') {
          this.buttonImageSix = 'app.media.dialer_press_6'
          this.noLettersImageSix = 'app.media.dialer_no_letters_press_6'
        } else if (this.buttonNumber == '7') {
          this.buttonImageSev = 'app.media.dialer_press_7'
          this.noLettersImageSev = 'app.media.dialer_no_letters_press_7'
        } else if (this.buttonNumber == '8') {
          this.buttonImageEight = 'app.media.dialer_press_8'
          this.noLettersImageEight = 'app.media.dialer_no_letters_press_8'
        } else if (this.buttonNumber == '9') {
          this.buttonImageNine = 'app.media.dialer_press_9'
          this.noLettersImageNine = 'app.media.dialer_no_letters_press_9'
        } else if (this.buttonNumber == '0') {
          this.buttonImageZero = 'app.media.dialer_press_0'
          this.noLettersImageZero = 'app.media.dialer_no_letters_press_0'
        } else if (this.buttonNumber == '*') {
          this.buttonImageStar = 'app.media.dialer_press_star'
          this.noLettersImageStar = 'app.media.dialer_no_letters_press_star_key'
        } else {
          this.buttonImagePound = 'app.media.dialer_press_pound'
          this.noLettersImagePound = 'app.media.dialer_no_letters_press_pound_key'
        }
      } else {
        this.isLongPress = false
        if (this.buttonNumber == '1') {
          this.buttonImageOne = 'app.media.dialer_1'
          this.noLettersImageOne = 'app.media.dialer_no_letters_1'
        } else if (this.buttonNumber == '2') {
          this.buttonImageTwo = 'app.media.dialer_2'
          this.noLettersImageTwo = 'app.media.dialer_no_letters_2'
        } else if (this.buttonNumber == '3') {
          this.buttonImageThree = 'app.media.dialer_3'
          this.noLettersImageThree = 'app.media.dialer_no_letters_3'
        } else if (this.buttonNumber == '4') {
          this.buttonImageFour = 'app.media.dialer_4'
          this.noLettersImageFour = 'app.media.dialer_no_letters_4'
        } else if (this.buttonNumber == '5') {
          this.buttonImageFive = 'app.media.dialer_5'
          this.noLettersImageFive = 'app.media.dialer_no_letters_5'
        } else if (this.buttonNumber == '6') {
          this.buttonImageSix = 'app.media.dialer_6'
          this.noLettersImageSix = 'app.media.dialer_no_letters_6'
        } else if (this.buttonNumber == '7') {
          this.buttonImageSev = 'app.media.dialer_7'
          this.noLettersImageSev = 'app.media.dialer_no_letters_7'
        } else if (this.buttonNumber == '8') {
          this.buttonImageEight = 'app.media.dialer_8'
          this.noLettersImageEight = 'app.media.dialer_no_letters_8'
        } else if (this.buttonNumber == '9') {
          this.buttonImageNine = 'app.media.dialer_9'
          this.noLettersImageNine = 'app.media.dialer_no_letters_9'
        } else if (this.buttonNumber == '0') {
          this.buttonImageZero = 'app.media.dialer_0'
          this.noLettersImageZero = 'app.media.dialer_no_letters_0'
        } else if (this.buttonNumber == '*') {
          this.buttonImageStar = 'app.media.dialer_star_key'
          this.noLettersImageStar = 'app.media.dialer_no_letters_star_key'
        } else {
          this.buttonImagePound = 'app.media.dialer_pound_key'
          this.noLettersImagePound = 'app.media.dialer_no_letters_pound_key'
        }
      }
    })
  }

  @Builder
  NoSimCardDialogBuilder() {
    Column() {
      Text($r('app.string.not_found_sim_card'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_primary'))
        .textAlign(EnvironmentProp.isPC() ? TextAlign.Center : TextAlign.Start)
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  AirplaneVoiceAlertDialogBuilder() {
    Column() {
      Text($r('app.string.turn_off_airplane_mode'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_primary'))
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  AirplaneSpeedAlertDialogBuilder() {
    Column() {
      Text($r('app.string.speed_dial_turn_off_airplane_mode'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_primary'))
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  NotSetVoicemailDialogBuilder() {
    Column() {
      Text($r('app.string.set_voicemial_info'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_primary'))
        .width('100%')
    }
    .width('100%')
  }
}
