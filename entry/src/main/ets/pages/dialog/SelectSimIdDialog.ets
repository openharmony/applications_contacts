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

import { HiLog } from '../../../../../../common';
import MockResource from '../../model/bean/MockResource';
import router from '@ohos.router';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { FontScaleState } from '../../util/fontScaleState';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { i18n } from '@kit.LocalizationKit';
import { SimCardType } from '../../data/Constants';

const TAG = 'SelectSimIdDialog';
const CALL_DIALOG_EVENT = 'CALL_DIALOG_EVENT';

@Component
export struct SelectSimIdDialog {
  @Link builder: SelectDialogBuilder;
  private controller?: CustomDialogController;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('simCardStates') mSimStateArray: boolean[] = [false, false];
  @StorageLink('simCardTypes') simCardTypes: SimCardType[] = [SimCardType.PSIM, SimCardType.PSIM];
  @StorageLink('simCardIndexes') mSimIndexArray: Array<number> = [-1, -1];
  private dialImg = [$r('sys.symbol.phone_badge_1'), $r('sys.symbol.phone_badge_2')];
  private eSimDialImg = $r('app.media.ic_call_eSIM');
  callDialogParams: CustomizedParams = {
    ITEM: 0,
    ISCANCEL: 1
  };

  aboutToAppear() {
    HiLog.i(TAG, 'SelectSimIdDialog builder');
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.padding_level8'))
  }

  build() {
    Column() {
      List() {
        ForEach(this.builder.multiSimCardItems as MultiSimCardItems[], (item: MultiSimCardItems, index) => {
          ListItem() {
            Row() {
              if (this.simCardTypes[index] === SimCardType.ESIM) {
                Image(this.eSimDialImg)
                  .width('24vp')
                  .height('24vp')
                  .margin({ right: $r('sys.float.padding_level8') })
                  .flexShrink(0)
              } else {
                SymbolGlyph(this.mSimIndexArray[index] === index + 1 ? item.img :
                  this.dialImg[this.mSimIndexArray[index] >= 1 ? this.mSimIndexArray[index] - 1 : 0])
                  .fontSize($r('app.float.id_card_image_small'))
                  .fontColor([$r('app.color.skin_icon_secondary')])
                  .margin({ right: $r('sys.float.padding_level8') })
                  .flexShrink(0)
              }

              Column() {
                Text(item.name)
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor($r('app.color.skin_font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .padding({
                    right: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level8') : 0
                  })

                if (this.builder.lastSimId == index) {
                  Text($r('app.string.choose_sub_recommend'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('app.color.skin_font_secondary'))
                    .fontWeight(FontWeight.Regular)
                    .margin({ top: $r('sys.float.padding_level1') })
                }
              }
              .margin({
                top: FontScaleState.fetchSeniorTopAndBottomSpace(
                  this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
                bottom: FontScaleState.fetchSeniorTopAndBottomSpace(
                  this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
              })
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
              .flexShrink(1)
            }
            .width('100%')
            .constraintSize({
              minHeight: this.builder.lastSimId == index ? $r('app.float.id_item_height_max') : $r('app.float.id_item_height_large')
            })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
          }
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
          })
          .padding({
            left: $r('sys.float.padding_level6'),
            right: $r('sys.float.padding_level6'),
          })
          .onClick(() => {
            this.callDialogParams.ITEM = index;
            this.callDialogParams.ISCANCEL = 0;
            DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
            this.confirm(index as number);
          })
        })

        if (this.builder.gotoDialer) {
          ListItem() {
            Row() {
              SymbolGlyph($r('sys.symbol.square_and_pencil'))
                .fontSize($r('app.float.id_card_image_small'))
                .fontColor([$r('app.color.skin_icon_secondary')])
                .margin({ right: $r('sys.float.padding_level8') })

              Column() {
                Text($r('app.string.contacts_call'))
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor($r('app.color.skin_font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .padding({
                    right: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level8') : 0
                  })
              }
              .margin({
                top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                  0, $r('app.float.id_card_margin_10')),
                bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                  0, $r('app.float.id_card_margin_10'))
              })
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .flexShrink(1)
            }
            .width('100%')
            .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
          }
          .padding({
            left: $r('sys.float.padding_level6'),
            right: $r('sys.float.padding_level6'),
          })
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
          })
          .onClick(() => {
            this.callDialogParams.ITEM = 2;
            this.callDialogParams.ISCANCEL = 0;
            DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
            this.gotoDialer();
          })
        }
      }
      .divider({
        strokeWidth: '1px',
        startMargin: $r('app.float.id_records_divider_max'),
        endMargin: $r('sys.float.padding_level6'),
        color: $r('app.color.skin_comp_divider')
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
  }

  confirm(slotId: number) {
    HiLog.i(TAG, 'click to confirm');
    this.controller?.close();
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    if (this.builder.callback) {
      this.builder.callback(slotId);
    } else {
      // fallback to desktop
      router.back();
    }
  }

  gotoDialer() {
    this.controller?.close();
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    if (this.builder.gotoDialer) {
      this.builder.gotoDialer();
    }
  }
}


class MultiSimCardItems {
  public name: string | Resource = '';
  public img: Resource = new MockResource();
}

export class Controller {
  public close: () => void = () => {
  };
  public open: () => void = () => {
  };
}

export class SelectDialogBuilder {
  public title?: string | Resource;
  public multiSimCardItems?: Array<MultiSimCardItems>;
  public lastSimId?: number = -1;
  public callback?: (simId: number) => void;
  public controller?: Controller;
  public gotoDialer?: () => void;
}
