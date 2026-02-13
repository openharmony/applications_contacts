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
import { CustomizedParams } from '../../model/type';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import VibrationUtils from '../../util/VibrationUtils';
import { EnterSingleSelectedMode, VibrationEffect } from '../../model/type/EnumUtil';
import { DynamicLoader } from '../../../../../../common';
import DotUtil from '../../util/DotUtil';
import DialerConstant from '../../data/DialerConstant';
import ContactsPickerPage from '../../pages/contacts/batchselectcontacts/ContactsPickerPage';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import dotCommon, { setContactParams } from '../../util/DotCommon';
import AccessibilityUtil from '../../util/AccessibilityUtil'
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { contact } from '@kit.ContactsKit';
import SpeedDialPresenter from '../../presenter/speeddial/SpeedDialPresenter';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { ContactsConstants } from '../../../../../../common/src/main/ets/ContactsConstants';
import I18n from '@ohos.i18n';

const TAG = 'DialButton';
const SPEED_DIAL_DIALOG_EVENT: string = 'SPEED_DIAL_DIALOG_EVENT';
const MINIMUN_INTERVAL_BETWEEN_TWO_ONTOUCH = 16;

@Component
export struct DialButton {
  @Consume('pathInfos') pathInfos: NavPathStack;
  buttonNumber: string = ''
  @StorageProp('languageConfig') @Watch('languageChange') private language: string = '';
  // 带字母的
  @State buttonImageOne: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_1':'app.media.dialer_1';
  @State buttonImageTwo: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_2':'app.media.dialer_2';
  @State buttonImageThree: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_3':'app.media.dialer_3';
  @State buttonImageFour: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_4':'app.media.dialer_4';
  @State buttonImageFive: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_5':'app.media.dialer_5';
  @State buttonImageSix: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_6':'app.media.dialer_6';
  @State buttonImageSev: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_7':'app.media.dialer_7';
  @State buttonImageEight: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_8':'app.media.dialer_8';
  @State buttonImageNine: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_9':'app.media.dialer_9';
  @State buttonImageStar: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_star':'app.media.dialer_star_key';
  @State buttonImagePound: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_pound':'app.media.dialer_pound_key';
  @State buttonImageZero: string = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_0':'app.media.dialer_0';
  // 无字母的
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
  @State isShowSheet: boolean = false;
  @State sheetParams: Record<string, number | string> | undefined = undefined;
  speedDialPresenter: SpeedDialPresenter = SpeedDialPresenter.getInstance();
  @StorageLink('breakpoint') curBp: string = 'sm';
  @State isLongPress: boolean = false; //是否长按
  private transparent: number = 0.101960784;
  @StorageLink('dialpadTouchToneType') dialpadTouchToneType: string = '1';
  @StorageProp('isDarkMode') isDarkMode: boolean = false
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) telNumberWithSpace: string = '';
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  mPresenter: DialerPresenter = DialerPresenter.getInstance();
  customizedParams: CustomizedParams = {};
  public speedDialDialog: CustomizedParams = {
    ISSET: 0
  }
  @StorageLink('lastPressButtonTime') lastPressButtonTime: number = -1;

  aboutToAppear() {
    this.mPresenter.noSimCardDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        theme: this.isThemeActive ? defaultCustomTheme : undefined,
        primaryTitle: $r('app.string.voicemail'),
        contentBuilder: () => {
          this.NoSimCardDialogBuilder();
        },
        buttons: [
          {
            value: $r('app.string.confirm'),
            fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
            action: () => {
              DialogControllerManager.getInstance().dialogControllerSet.clear();
              HiLog.i(TAG, 'voicemail alert confirm btn click');
            }
          }
        ]
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
              }, (error, data) => {
                if (error) {
                  HiLog.e(TAG, `selectContacts error: ${error?.message}`);
                }
                this.speedDialPresenter.parseContactForResult(data, ContactsConstants.SPEED_DIAL).then(() => {
                }).catch((error: Error) => {
                  HiLog.e(TAG, `Error parsing contact for result: ${error?.message}`);
                });
              })
            }).catch((error: Error) => {
              HiLog.e(TAG, `Error parsing contact for result: ${error?.message}`);
            });
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
            HiLog.i(TAG, 'voicemail alert confirm btn click!!!');
            //  联系人打点--长按1出现设置语音信箱(sm)
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
    this.mPresenter.noSimCardDialogController = null;
    this.mPresenter.airplaneVoiceAlertDialogController = null;
    this.mPresenter.airplaneSpeedAlertDialogController = null;
    this.mPresenter.notSetSpeedDialDialogController = null;
    this.mPresenter.notSetVoicemailDialogController = null;
  }

  setNumber(number: string) {
    AppStorage.SetOrCreate('isPasteShowCursor', false);
    AppStorage.SetOrCreate('showTelNumber', true)
    this.mPresenter.isKeyboardInput = false;
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
  isShowLetter(): boolean {
    if (this.splitStatus === SplitStatus.DEFAULT) {
      return true
    }
    if (DisplaySplitUtil.isFoldStatus() && this.splitStatus === SplitStatus.VERTICAL_SPLIT) {
      return true
    }
    if ((deviceInfo.deviceType == 'phone' || display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED)) {
      if (this.splitStatus === SplitStatus.TWO_THREE_SPLIT) {
        return true
      }
    }
    return false
  }

  languageChange() {
    this.buttonImageOne = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_1':'app.media.dialer_1';
    this.buttonImageTwo = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_2':'app.media.dialer_2';
    this.buttonImageThree = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_3':'app.media.dialer_3';
    this.buttonImageFour = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_4':'app.media.dialer_4';
    this.buttonImageFive = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_5':'app.media.dialer_5';
    this.buttonImageSix = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_6':'app.media.dialer_6';
    this.buttonImageSev = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_7':'app.media.dialer_7';
    this.buttonImageEight = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_8':'app.media.dialer_8';
    this.buttonImageNine = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_9':'app.media.dialer_9';
    this.buttonImageStar = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_star':'app.media.dialer_star_key';
    this.buttonImagePound = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_pound':'app.media.dialer_pound_key';
    this.buttonImageZero = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_0':'app.media.dialer_0';
  }

  build() {
    Column() {
      if (this.buttonNumber == '1') {
        Image(this.isShowLetter() ? $r(this.buttonImageOne) : $r(this.noLettersImageOne))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageOne src = ' + this.isShowLetter() ? this.buttonImageOne : this.noLettersImageOne +
              ' imageOne error:' + error?.message);
          })
      } else if (this.buttonNumber == '2') {
        Image(this.isShowLetter() ? $r(this.buttonImageTwo) : $r(this.noLettersImageTwo))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageTwo src = ' +
            this.isShowLetter() ? this.buttonImageTwo : this.noLettersImageTwo +
              ' imageTwo error:' + error?.message);
          })
      } else if (this.buttonNumber == '3') {
        Image(this.isShowLetter() ? $r(this.buttonImageThree) : $r(this.noLettersImageThree))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageThree src = ' +
            this.isShowLetter() ? this.buttonImageThree : this.noLettersImageThree +
              'imageThree error:' + error?.message);
          })
      } else if (this.buttonNumber == '4') {
        Image(this.isShowLetter() ? $r(this.buttonImageFour) : $r(this.noLettersImageFour))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageFour src = ' +
            this.isShowLetter() ? this.buttonImageFour : this.noLettersImageFour +
              ' imageFour error:' + error?.message);
          })
      } else if (this.buttonNumber == '5') {
        Image(this.isShowLetter() ? $r(this.buttonImageFive) : $r(this.noLettersImageFive))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageFive src = ' +
            this.isShowLetter() ? this.buttonImageFive : this.noLettersImageFive +
              ' imageFive error:' + error?.message);
          })
      } else if (this.buttonNumber == '6') {
        Image(this.isShowLetter() ? $r(this.buttonImageSix) : $r(this.noLettersImageSix))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageSix src = ' +
            this.isShowLetter() ? this.buttonImageSix : this.noLettersImageSix +
              ' imageSix error:' + error?.message);
          })
      } else if (this.buttonNumber == '7') {
        Image(this.isShowLetter() ? $r(this.buttonImageSev) : $r(this.noLettersImageSev))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageSev src = ' +
            this.isShowLetter() ? this.buttonImageSev : this.noLettersImageSev +
              ' imageSev error:' + error?.message);
          })
      } else if (this.buttonNumber == '8') {
        Image(this.isShowLetter() ? $r(this.buttonImageEight) : $r(this.noLettersImageEight))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageEight src = ' +
            this.isShowLetter() ? this.buttonImageEight : this.noLettersImageEight +
              ' imageEight error:' + error?.message);
          })
      } else if (this.buttonNumber == '9') {
        Image(this.isShowLetter() ? $r(this.buttonImageNine) : $r(this.noLettersImageNine))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageNine src = ' +
            this.isShowLetter() ? this.buttonImageNine : this.noLettersImageNine +
              ' imageNine error:' + error?.message);
          })
      } else if (this.buttonNumber == '0') {
        Image(this.isShowLetter() ? $r(this.buttonImageZero) : $r(this.noLettersImageZero))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageZero src = ' +
            this.isShowLetter() ? this.buttonImageZero : this.noLettersImageZero +
              ' imageZero error:' + error?.message);
          })
      } else if (this.buttonNumber == '*') {
        Image(this.isShowLetter() ? $r(this.buttonImageStar) : $r(this.noLettersImageStar))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imageStar src = ' +
            this.isShowLetter() ? this.buttonImageStar : this.noLettersImagePound +
              ' imageStar error:' + error?.message);
          })
      } else {
        Image(this.isShowLetter() ? $r(this.buttonImagePound) : $r(this.noLettersImagePound))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.w(TAG, 'imagePound src = ' +
            this.isShowLetter() ? this.buttonImagePound : this.noLettersImageStar +
              ' imagePound error:' + error?.message);
          })
      }
    }
    .id('dialer_bnt')
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        HiLog.i(TAG, `onTouch event.type: ${event?.type}`);
        this.isLongPress = true
        if (this.buttonNumber == '1') {
          this.buttonImageOne = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_1':'app.media.dialer_press_1';
          this.noLettersImageOne = 'app.media.dialer_no_letters_press_1'
        } else if (this.buttonNumber == '2') {
          this.buttonImageTwo = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_2':'app.media.dialer_press_2';
          this.noLettersImageTwo = 'app.media.dialer_no_letters_press_2'
        } else if (this.buttonNumber == '3') {
          this.buttonImageThree = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_3':'app.media.dialer_press_3';
          this.noLettersImageThree = 'app.media.dialer_no_letters_press_3'
        } else if (this.buttonNumber == '4') {
          this.buttonImageFour = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_4':'app.media.dialer_press_4';
          this.noLettersImageFour = 'app.media.dialer_no_letters_press_4'
        } else if (this.buttonNumber == '5') {
          this.buttonImageFive = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_5':'app.media.dialer_press_5';
          this.noLettersImageFive = 'app.media.dialer_no_letters_press_5'
        } else if (this.buttonNumber == '6') {
          this.buttonImageSix = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_6':'app.media.dialer_press_6';
          this.noLettersImageSix = 'app.media.dialer_no_letters_press_6'
        } else if (this.buttonNumber == '7') {
          this.buttonImageSev = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_7':'app.media.dialer_press_7';
          this.noLettersImageSev = 'app.media.dialer_no_letters_press_7'
        } else if (this.buttonNumber == '8') {
          this.buttonImageEight = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_8':'app.media.dialer_press_8';
          this.noLettersImageEight = 'app.media.dialer_no_letters_press_8'
        } else if (this.buttonNumber == '9') {
          this.buttonImageNine = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_9':'app.media.dialer_press_9';
          this.noLettersImageNine = 'app.media.dialer_no_letters_press_9'
        } else if (this.buttonNumber == '0') {
          this.buttonImageZero = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_0':'app.media.dialer_press_0';
          this.noLettersImageZero = 'app.media.dialer_no_letters_press_0'
        } else if (this.buttonNumber == '*') {
          this.buttonImageStar = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_star':'app.media.dialer_press_star';
          this.noLettersImageStar = 'app.media.dialer_no_letters_press_star_key'
        } else {
          this.buttonImagePound = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_pound':'app.media.dialer_press_pound';
          this.noLettersImagePound = 'app.media.dialer_no_letters_press_pound_key'
        }
        // 无障碍模式下，不触发ontouch事件上屏操作
        if (!this.isOpenAccessibility) {
          // 针对16ms内触发多个down事件的情况做丢弃处理，本次down事件距上次时间间隔小于16ms就不上屏
          if (!StringUtil.isEmpty(this.telNumberWithSpace)) {
            let nowTime = new Date().getTime();
            if ((Math.abs(nowTime - this.lastPressButtonTime)) > MINIMUN_INTERVAL_BETWEEN_TWO_ONTOUCH) {
              HiLog.w(TAG, `nowTime: ${nowTime}, lastPressButtonTime: ${this.lastPressButtonTime}`);
              this.lastPressButtonTime = nowTime;
              this.setNumber(this.buttonNumber)
              this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType)
              if (this.pasteStatus) {
                HiLog.w(TAG, 'setNumber pasteStatus disappear');
                this.pasteStatus = false;
              }
            } else {
              HiLog.e(TAG, `nowTime: ${nowTime}, lastPressButtonTime: ${this.lastPressButtonTime}, discard this input`);
            }
          }
        }
      }
      if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        HiLog.i(TAG, `onTouch event.type: ${event?.type}`);
        this.isLongPress = false
        if (this.buttonNumber == '1') {
          this.buttonImageOne = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_1':'app.media.dialer_1';
          this.noLettersImageOne = 'app.media.dialer_no_letters_1'
        } else if (this.buttonNumber == '2') {
          this.buttonImageTwo = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_2':'app.media.dialer_2';
          this.noLettersImageTwo = 'app.media.dialer_no_letters_2'
        } else if (this.buttonNumber == '3') {
          this.buttonImageThree = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_3':'app.media.dialer_3';
          this.noLettersImageThree = 'app.media.dialer_no_letters_3'
        } else if (this.buttonNumber == '4') {
          this.buttonImageFour = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_4':'app.media.dialer_4';
          this.noLettersImageFour = 'app.media.dialer_no_letters_4'
        } else if (this.buttonNumber == '5') {
          this.buttonImageFive = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_5':'app.media.dialer_5';
          this.noLettersImageFive = 'app.media.dialer_no_letters_5'
        } else if (this.buttonNumber == '6') {
          this.buttonImageSix = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_6':'app.media.dialer_6';
          this.noLettersImageSix = 'app.media.dialer_no_letters_6'
        } else if (this.buttonNumber == '7') {
          this.buttonImageSev = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_7':'app.media.dialer_7';
          this.noLettersImageSev = 'app.media.dialer_no_letters_7'
        } else if (this.buttonNumber == '8') {
          this.buttonImageEight = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_8':'app.media.dialer_8';
          this.noLettersImageEight = 'app.media.dialer_no_letters_8'
        } else if (this.buttonNumber == '9') {
          this.buttonImageNine = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_9':'app.media.dialer_9';
          this.noLettersImageNine = 'app.media.dialer_no_letters_9'
        } else if (this.buttonNumber == '0') {
          this.buttonImageZero = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_0':'app.media.dialer_0';
          this.noLettersImageZero = 'app.media.dialer_no_letters_0'
        } else if (this.buttonNumber == '*') {
          this.buttonImageStar = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_star':'app.media.dialer_star_key';
          this.noLettersImageStar = 'app.media.dialer_no_letters_star_key'
        } else {
          this.buttonImagePound = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_pound':'app.media.dialer_pound_key';
          this.noLettersImagePound = 'app.media.dialer_no_letters_pound_key'
        }
      }
    })
    .onHover((isHover: boolean) => {
      if (isHover) {
        this.isLongPress = true
        if (this.buttonNumber == '1') {
          this.buttonImageOne = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_1':'app.media.dialer_press_1';
          this.noLettersImageOne = 'app.media.dialer_no_letters_press_1'
        } else if (this.buttonNumber == '2') {
          this.buttonImageTwo = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_2':'app.media.dialer_press_2';
          this.noLettersImageTwo = 'app.media.dialer_no_letters_press_2'
        } else if (this.buttonNumber == '3') {
          this.buttonImageThree = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_3':'app.media.dialer_press_3';
          this.noLettersImageThree = 'app.media.dialer_no_letters_press_3'
        } else if (this.buttonNumber == '4') {
          this.buttonImageFour = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_4':'app.media.dialer_press_4';
          this.noLettersImageFour = 'app.media.dialer_no_letters_press_4'
        } else if (this.buttonNumber == '5') {
          this.buttonImageFive = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_5':'app.media.dialer_press_5';
          this.noLettersImageFive = 'app.media.dialer_no_letters_press_5'
        } else if (this.buttonNumber == '6') {
          this.buttonImageSix = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_6':'app.media.dialer_press_6';
          this.noLettersImageSix = 'app.media.dialer_no_letters_press_6'
        } else if (this.buttonNumber == '7') {
          this.buttonImageSev = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_7':'app.media.dialer_press_7';
          this.noLettersImageSev = 'app.media.dialer_no_letters_press_7'
        } else if (this.buttonNumber == '8') {
          this.buttonImageEight = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_8':'app.media.dialer_press_8';
          this.noLettersImageEight = 'app.media.dialer_no_letters_press_8'
        } else if (this.buttonNumber == '9') {
          this.buttonImageNine = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_9':'app.media.dialer_press_9';
          this.noLettersImageNine = 'app.media.dialer_no_letters_press_9'
        } else if (this.buttonNumber == '0') {
          this.buttonImageZero = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_0':'app.media.dialer_press_0';
          this.noLettersImageZero = 'app.media.dialer_no_letters_press_0'
        } else if (this.buttonNumber == '*') {
          this.buttonImageStar = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_star':'app.media.dialer_press_star';
          this.noLettersImageStar = 'app.media.dialer_no_letters_press_star_key'
        } else {
          this.buttonImagePound = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_press_ar_pound':'app.media.dialer_press_pound';
          this.noLettersImagePound = 'app.media.dialer_no_letters_press_pound_key'
        }
      } else {
        this.isLongPress = false
        if (this.buttonNumber == '1') {
          this.buttonImageOne = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_1':'app.media.dialer_1';
          this.noLettersImageOne = 'app.media.dialer_no_letters_1'
        } else if (this.buttonNumber == '2') {
          this.buttonImageTwo = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_2':'app.media.dialer_2';
          this.noLettersImageTwo = 'app.media.dialer_no_letters_2'
        } else if (this.buttonNumber == '3') {
          this.buttonImageThree = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_3':'app.media.dialer_3';
          this.noLettersImageThree = 'app.media.dialer_no_letters_3'
        } else if (this.buttonNumber == '4') {
          this.buttonImageFour = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_4':'app.media.dialer_4';
          this.noLettersImageFour = 'app.media.dialer_no_letters_4'
        } else if (this.buttonNumber == '5') {
          this.buttonImageFive = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_5':'app.media.dialer_5';
          this.noLettersImageFive = 'app.media.dialer_no_letters_5'
        } else if (this.buttonNumber == '6') {
          this.buttonImageSix = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_6':'app.media.dialer_6';
          this.noLettersImageSix = 'app.media.dialer_no_letters_6'
        } else if (this.buttonNumber == '7') {
          this.buttonImageSev = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_7':'app.media.dialer_7';
          this.noLettersImageSev = 'app.media.dialer_no_letters_7'
        } else if (this.buttonNumber == '8') {
          this.buttonImageEight = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_8':'app.media.dialer_8';
          this.noLettersImageEight = 'app.media.dialer_no_letters_8'
        } else if (this.buttonNumber == '9') {
          this.buttonImageNine = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_9':'app.media.dialer_9';
          this.noLettersImageNine = 'app.media.dialer_no_letters_9'
        } else if (this.buttonNumber == '0') {
          this.buttonImageZero = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_0':'app.media.dialer_0';
          this.noLettersImageZero = 'app.media.dialer_no_letters_0'
        } else if (this.buttonNumber == '*') {
          this.buttonImageStar = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_star':'app.media.dialer_star_key';
          this.noLettersImageStar = 'app.media.dialer_no_letters_star_key'
        } else {
          this.buttonImagePound = I18n.System.getSystemLanguage() === 'ar'? 'app.media.dialer_ar_pound':'app.media.dialer_pound_key';
          this.noLettersImagePound = 'app.media.dialer_no_letters_pound_key'
        }
      }
    })
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
    .height('100%')
    .onClick((event: ClickEvent) => {
      // 开启无障碍模式,onclick自动识别成单指双击操作
      if (this.isOpenAccessibility) {
        HiLog.w(TAG, `accessibility is on`);
        this.setNumber(this.buttonNumber)
        this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType)
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(this.buttonNumber);
        if (this.pasteStatus) {
          HiLog.w(TAG, 'setNumber pasteStatus disappear');
          this.pasteStatus = false;
        }
      } else {
        // 非无障碍模式下，首次点击触发上屏
        if (StringUtil.isEmpty(this.telNumberWithSpace)) {
          this.lastPressButtonTime = new Date().getTime();
          HiLog.w(TAG, `lastPressButtonTime: ${this.lastPressButtonTime},column onClick!!!`);
          this.setNumber(this.buttonNumber)
          this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType)
          if (this.pasteStatus) {
            HiLog.w(TAG, 'setNumber pasteStatus disappear');
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
    .gesture(
      GestureGroup(GestureMode.Exclusive, LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
        .onAction((event: GestureEvent | undefined) => {
          VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
          // 规格变更：如果号码大于0的情况下，变成在原有数字上改变
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
              this.mPresenter.longPressNumberChange(number);
            } else {
              this.setNumber(this.buttonNumber);
            }
            this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
          }
          if (this.mPresenter.all_number.length === 0 &&
            (this.buttonNumber === '*' || this.buttonNumber === '#' || this.buttonNumber === '0')) {
              let number = '';
              if (this.buttonNumber === '*') {
                number = '*';
              } else if (this.buttonNumber === '#') {
                number = '#';
              } else if (this.buttonNumber === '0') {
                number = '+';
              }
              this.setNumber(number);
              this.mPresenter.playAudio(this.buttonNumber, this.dialpadTouchToneType);
          } else {
            // Initiate speed dial when no character is entered.
            if (!this.maintenanceMode) {
              this.mPresenter.speedDialAction(this.getUIContext(), this.buttonNumber);
            }
          }
          if (this.pasteStatus) {
            HiLog.w(TAG, 'DialerButton pasteStatus disappear');
            this.pasteStatus = false;
          }
        })
      ))
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
