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
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import VibrationUtils from '../../../util/VibrationUtils';
import { VibrationEffect } from '../../../model/type/EnumUtil';
import DialerConstant from '../../../data/DialerConstant';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../../feature/sim/SimCardState';
import { DialerButtonView } from '../../../component/dialer/DialerButtonView';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { ResourceUtil } from '../../../util/ResourceUtil';

const TAG = 'VDialPad';
const MINIMUN_INTERVAL_BETWEEN_TWO_ONTOUCH = 16;

@Component
export default struct VDialPad {
  numberList: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#']
  private dialerButtonHeight = 40;
  @State mPresenter: DialerPresenter = DialerPresenter.getInstance();
  @StorageProp('currentColorMode') @Watch('colorModeChange') currentColorMode: number = 1;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @State buttonImageOne: string = 'app.media.verde_dialer_1';
  @State buttonImageTwo: string = 'app.media.verde_dialer_2';
  @State buttonImageThree: string = 'app.media.verde_dialer_3';
  @State buttonImageFour: string = 'app.media.verde_dialer_4';
  @State buttonImageFive: string = 'app.media.verde_dialer_5';
  @State buttonImageSix: string = 'app.media.verde_dialer_6';
  @State buttonImageSev: string = 'app.media.verde_dialer_7';
  @State buttonImageEight: string = 'app.media.verde_dialer_8';
  @State buttonImageNine: string = 'app.media.verde_dialer_9';
  @State buttonImageStar: string = 'app.media.verde_dialer_star';
  @State buttonImagePound: string = 'app.media.verde_dialer_pound';
  @State buttonImageZero: string = 'app.media.verde_dialer_0';
  @State numberLocation: string = '';
  @StorageLink('dialpadTouchToneType') dialpadTouchToneType: string = '1';
  @StorageLink('showTelNumber') showTelNumber: boolean = true;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('isAirplaneMode') isAirplaneMode: boolean = false;
  @StorageLink('defaultSlot') @Watch('onSimChanged') defaultSlot: number = simId_DEFAULT;
  @StorageLink('showDialBtn') showDialBtn: boolean = true;
  //仅限于用于展示号码 带格式化
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) telNumberWithSpace: string = '';
  @StorageLink('maintenanceMode') maintenanceMode: boolean = false;
  @StorageLink('lastPressButtonTime') lastPressButtonTime: number = -1;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;

  aboutToAppear(): void {
    HiLog.w(TAG, 'aboutToAppear');
    this.colorModeChange();
  }

  // sim change
  onSimChanged() {
    HiLog.w(TAG, 'haveMultiSimCard change:' + this.haveMultiSimCard);
    this.mPresenter.dialerButtonWidth = this.haveMultiSimCard && !this.isAirplaneMode ?
      ((this.hasDefaultSlot()) ? '192vp' : (px2vp(this.mPresenter.dialerButtonWidthInMulti) + 16) + 'vp') : '60vp';
  }

  hasDefaultSlot() {
    return this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO
  }

  isSingleDialButton(): boolean {
    return !this.haveMultiSimCard || this.isAirplaneMode || (this.haveMultiSimCard && this.hasDefaultSlot())
  }



  build() {
    Column({ space: 4 }) {
      GridRow({ columns: 3, gutter: { x: 0, y: 2 } }) {
        ForEach(this.numberList, (item: string) => {
          GridCol({ span: 1 }) {
            this.dialNumberButton(item)
          }
        })
      }
      .direction(Direction.Ltr)
      .width('100%')

      // 拨号按钮
      if (this.isSingleDialButton()) {
        GridRow({ columns: 3, gutter: { x: 0, y: 0 } }) {
          GridCol({ span: 1 }) {
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              this.dialButton()
            }
            .height(this.dialerButtonHeight)
            .width('100%')
          }
          GridCol({ span: 1 }) {
            // 电话图标
            DialerButtonView({
              mPresenter: $mPresenter,
            })
          }
          GridCol({ span: 1 }) {
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              this.deleteButton()
            }
            .height(this.dialerButtonHeight)
            .width('100%')
          }
        }
        .width('100%')
        .alignItems(ItemAlign.Center)
      } else {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {

          this.dialButton()

          DialerButtonView({
            mPresenter: $mPresenter,
          })
            .margin({ left: 4, right: 4 })

          this.deleteButton()
        }
      }
    }
    .width('100%')
    .clipShape(new Rect({
      width: '100%',
      height: '232',
      radius: [[DialerPresenter.RADIUS_SIZE, DialerPresenter.RADIUS_SIZE],
        [DialerPresenter.RADIUS_SIZE, DialerPresenter.RADIUS_SIZE], [0, 0], [0, 0]]
    }))
    .shadow({
      radius: 30,
      color: 'rgba(0,0,0,0.12)',
      offsetX: 0,
      offsetY: -2
    })
    .height(232)
    .padding({
      top: $r('sys.float.padding_level5'),
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level6'),
    })
    .backgroundColor(this.isThemeActive ? Color.Transparent : $r('app.color.skin_comp_background_primary'))
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

  colorModeChange() {
    HiLog.w(TAG, `colorModeChange, currentColorMode: ${this.currentColorMode}`);
    this.updateDialerButtonImage('1', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('2', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('3', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('4', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('5', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('6', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('7', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('8', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('9', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('0', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('*', this.currentColorMode !== 1, false);
    this.updateDialerButtonImage('#', this.currentColorMode !== 1, false);
  }

  updateDialerButtonImage(buttonNumber: string, isDark: boolean, isPress: boolean) {
    let dialerButtonImage = 'app.media.verde_dialer_';
    if (isDark) {
      dialerButtonImage += 'dark_';
    }
    if (isPress) {
      dialerButtonImage += 'press_';
    }

    switch (buttonNumber) {
      case '1':
        dialerButtonImage += buttonNumber;
        this.buttonImageOne = dialerButtonImage;
        break;
      case '2':
        dialerButtonImage += buttonNumber;
        this.buttonImageTwo = dialerButtonImage;
        break;
      case '3':
        dialerButtonImage += buttonNumber;
        this.buttonImageThree = dialerButtonImage;
        break;
      case '4':
        dialerButtonImage += buttonNumber;
        this.buttonImageFour = dialerButtonImage;
        break;
      case '5':
        dialerButtonImage += buttonNumber;
        this.buttonImageFive = dialerButtonImage;
        break;
      case '6':
        dialerButtonImage += buttonNumber;
        this.buttonImageSix = dialerButtonImage;
        break;
      case '7':
        dialerButtonImage += buttonNumber;
        this.buttonImageSev = dialerButtonImage;
        break;
      case '8':
        dialerButtonImage += buttonNumber;
        this.buttonImageEight = dialerButtonImage;
        break;
      case '9':
        dialerButtonImage += buttonNumber;
        this.buttonImageNine = dialerButtonImage;
        break;
      case '0':
        dialerButtonImage += buttonNumber;
        this.buttonImageZero = dialerButtonImage;
        break;
      case '*':
        dialerButtonImage += 'star';
        this.buttonImageStar = dialerButtonImage;
        break;
      case '#':
        dialerButtonImage += 'pound';
        this.buttonImagePound = dialerButtonImage;
        break;
      default:
        break;
    }
  }

  @Builder
  dialNumberButton(buttonNumber: string) {
    Row() {
      if (buttonNumber == '1') {
        Image($r(this.buttonImageOne))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageOne src = ' + this.buttonImageOne + ' imageOne error:' + error?.message);
          })
      } else if (buttonNumber == '2') {
        Image($r(this.buttonImageTwo))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageTwo src = ' + this.buttonImageTwo + ' imageTwo error:' + error?.message);
          })
      } else if (buttonNumber == '3') {
        Image($r(this.buttonImageThree))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageThree src = ' + this.buttonImageThree + 'imageThree error:' + error?.message);
          })
      } else if (buttonNumber == '4') {
        Image($r(this.buttonImageFour))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageFour src = ' + this.buttonImageFour + ' imageFour error:' + error?.message);
          })
      } else if (buttonNumber == '5') {
        Image($r(this.buttonImageFive))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageFive src = ' + this.buttonImageFive + ' imageFive error:' + error?.message);
          })
      } else if (buttonNumber == '6') {
        Image($r(this.buttonImageSix))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageSix src = ' + this.buttonImageSix + ' imageSix error:' + error?.message);
          })
      } else if (buttonNumber == '7') {
        Image($r(this.buttonImageSev))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageSev src = ' + this.buttonImageSev + ' imageSev error:' + error?.message);
          })
      } else if (buttonNumber == '8') {
        Image($r(this.buttonImageEight))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageEight src = ' + this.buttonImageEight + ' imageEight error:' + error?.message);
          })
      } else if (buttonNumber == '9') {
        Image($r(this.buttonImageNine))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageNine src = ' + this.buttonImageNine + ' imageNine error:' + error?.message);
          })
      } else if (buttonNumber == '0') {
        Image($r(this.buttonImageZero))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageZero src = ' + this.buttonImageZero + ' imageZero error:' + error?.message);
          })
      } else if (buttonNumber == '*') {
        Image($r(this.buttonImageStar))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imageStar src = ' + this.buttonImageStar + ' imageStar error:' + error?.message);
          })
      } else {
        Image($r(this.buttonImagePound))
          .height(this.dialerButtonHeight)
          .flexGrow(1)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .onError((error: ImageError) => {
            HiLog.e(TAG, 'imagePound src = ' + this.buttonImagePound + ' imagePound error:' + error?.message);
          })
      }
    }
    .flexGrow(1)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .onClick((event: ClickEvent) => {
      // 开启无障碍,onclick自动识别单指双击操作,ontouch不执行
      if (this.isOpenAccessibility) {
        HiLog.w(TAG, `accessibility is on`);
        this.setNumber(buttonNumber);
        this.mPresenter.playAudio(buttonNumber, this.dialpadTouchToneType);
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(buttonNumber);
      } else {
        // 非无障碍模式下，首次点击触发上屏
        if (StringUtil.isEmpty(this.telNumberWithSpace)) {
          this.lastPressButtonTime = new Date().getTime();
          HiLog.w(TAG, `lastPressButtonTime: ${this.lastPressButtonTime}, row onClick!!!`);
          this.setNumber(buttonNumber);
          this.mPresenter.playAudio(buttonNumber, this.dialpadTouchToneType);
        }
      }
    })
    .accessibilityGroup(true)
    .accessibilityText(buttonNumber)
    .onAccessibilityHover((isHover: boolean, event: AccessibilityHoverEvent) => {
      if (!isHover && event.type === AccessibilityHoverType.HOVER_EXIT) {
        this.setNumber(buttonNumber)
        this.mPresenter.playAudio(buttonNumber, this.dialpadTouchToneType)
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(buttonNumber);
      }
    })
    .gesture(
      GestureGroup(GestureMode.Exclusive, LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
        .onAction((event: GestureEvent | undefined) => {
          VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
          if (this.mPresenter.all_number.length >= 1) {
            // Input length greater than 1
            // press '*' to convert to ',' and press '#' to ';', press other characters to append
            if (buttonNumber === '*' || buttonNumber === '#' || buttonNumber === '0') {
              let number = '';
              if (buttonNumber === '*') {
                number = ',';
              } else if (buttonNumber === '#') {
                number = ';';
              } else if (buttonNumber === '0') {
                number = '+';
              }
              this.setNumber(number);
            } else {
              this.setNumber(buttonNumber);
            }
            this.mPresenter.playAudio(buttonNumber, this.dialpadTouchToneType);
          }
          if (this.mPresenter.all_number.length === 0 && buttonNumber === '0') {
            let number = '+';
            this.setNumber(number);
            this.mPresenter.playAudio(buttonNumber, this.dialpadTouchToneType);
          } else {
            // Initiate speed dial when no character is entered.
            if (!this.maintenanceMode) {
              this.mPresenter.speedDialAction(this.getUIContext(), buttonNumber);
            }
          }
        })
      ))
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.updateDialerButtonImage(buttonNumber, this.currentColorMode !== 1, true)
        // 无障碍模式下 不触发ontouch
        if (!this.isOpenAccessibility) {
          // 针对16ms内触发多个down事件的情况做丢弃处理，本次down事件距上次时间间隔小于16ms就不上屏
          if (!StringUtil.isEmpty(this.telNumberWithSpace)) {
            let nowTime = new Date().getTime();
            if ((Math.abs(nowTime - this.lastPressButtonTime)) > MINIMUN_INTERVAL_BETWEEN_TWO_ONTOUCH) {
              HiLog.w(TAG, `nowTime: ${nowTime}, lastPressButtonTime: ${this.lastPressButtonTime}`);
              this.lastPressButtonTime = nowTime;
              this.setNumber(buttonNumber);
              this.mPresenter.playAudio(buttonNumber, this.dialpadTouchToneType);
            } else {
              HiLog.e(TAG, `nowTime: ${nowTime}, lastPressButtonTime: ${this.lastPressButtonTime}, discard this input`);
            }
          }
        }
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.updateDialerButtonImage(buttonNumber, this.currentColorMode !== 1, false)
      }
    })
  }

  @Builder
  dialButton() {
    Button() {
      SymbolGlyph($r('sys.symbol.dial'))
        .fontSize($r('app.float.id_card_image_small'))
        .fontColor([$r('app.color.skin_icon_primary')])
    }
    .flexShrink(0)
    .type(ButtonType.Normal)
    .buttonStyle(ButtonStyleMode.TEXTUAL)
    .height(this.dialerButtonHeight)
    .width(this.dialerButtonHeight)
    .borderRadius($r('app.float.id_card_image_height'))
    .onClick(() => {
      this.showDialBtn = false;
      AccessibilityUtil.getInstance()
        .sendAccessibilityEvent(this.isOpenAccessibility, 'dialer_contacts_sm_dial_btn');
    })
    .id('dialer_contacts_sm_dialer_btn_single')
    .accessibilityText(AccessibilityUtil.getInstance()
      .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_fold_dialer')))
  }

  @Builder
  deleteButton() {
    Button() {
      SymbolGlyph($r('sys.symbol.delete_left_fill'))
        .fontSize($r('app.float.id_card_image_small'))
        .fontColor([$r('app.color.skin_icon_primary')])
    }
    .flexShrink(0)
    .type(ButtonType.Normal)
    .buttonStyle(ButtonStyleMode.TEXTUAL)
    .height(this.dialerButtonHeight)
    .width(this.dialerButtonHeight)
    .borderRadius($r('app.float.id_card_image_height'))
    .enabled(this.telNumberWithSpace.length > 0 ? true : false)
    .gesture(
      LongPressGesture({ repeat: false, fingers: 1, duration: 700 })
        .onAction((event: GestureEvent | undefined) => {
          this.mPresenter.resetTelNumber();
          this.mPresenter.editPhoneNumber('');
          VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
          // 无障碍播报号码已清空
          AccessibilityUtil.getInstance()
            .sendAccessibilityEventInfo(ResourceUtil.getStringByResource($r('app.string.accessibility_Text_cleared')));
        })
    )
    .onClick(() => {
      let number: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
        AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
      number = this.mPresenter.deleteStr(number); //删除之后的号码
      AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, number)
    })
    .id('dialer_contacts_sm_delete_btn')
    .accessibilityText(AccessibilityUtil.getInstance()
      .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_delete')))
  }
}