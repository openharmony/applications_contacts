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
import { BusinessError } from '@ohos.base';
import { ComponentContent } from '@ohos.arkui.node';
import { HiLog } from '../../../../../../common';
import { FontScaleState } from '../../util/fontScaleState';

const TAG: string = 'RoamingSelectNumDialog';
export class RoamingSelectNumDialog {
  public static showDialog(context: UIContext, message: RoamingNumItem[], roamingCallback: Function) {
    let promptAction = context.getPromptAction();
    let dialogCallback = (roamingNumItem?: RoamingNumItem) => {
      roamingCallback(roamingNumItem);
      promptAction.closeCustomDialog(contentNode);
    }
    let builder: DialogParams = {
      param: message,
      callback: dialogCallback
    };
    let contentNode = new ComponentContent(context, wrapBuilder(buildText), builder);
    try {
      promptAction.openCustomDialog(contentNode);
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`OpenCustomDialog args error code is ${code}, message is ${message}`);
    }
  }
}

class DialogParams {
  public param: RoamingNumItem[] = [];
  public callback?: Function;
}

export class RoamingNumItem {
  public number: string = '';
  public numType?: string | Resource;
  public img?: Resource;
  public location?: string | Resource;
}

@Builder
function buildText(params: DialogParams) {
  GridRow({columns: {sm: 4, md: 8, lg: 12}, gutter: {x: {sm: 12, md: 12, lg: 24}, y: 0}}) {
    GridCol({span: {sm: 4, md: 4, lg: 6}, offset: { sm: 0, md: 2, lg: 3 }}) {
      Column() {
        Text($r('app.string.roaming_dial_title'))
          .fontSize($r('sys.float.Title_S'))
          .maxFontScale(2)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .alignSelf(ItemAlign.Center)
          .width('100%')
          .constraintSize({ minHeight: '56vp' })
          .backgroundColor(Color.Transparent)
          .margin({
            left: $r('app.float.id_dialog_title_margin'),
            right: $r('app.float.id_dialog_title_margin'),
            top: $r('app.float.id_list_primary_margin_top'),
            bottom: $r('app.float.id_list_primary_margin_top')
          })
          .padding({
            left: $r('app.float.id_card_margin_max'),
            right: $r('app.float.id_card_margin_max')
          })

        List() {
          ForEach(params.param, (item: RoamingNumItem, index) => {
            ListItem() {
              RelativeContainer() {
                Text(item.number)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({
                    top: FontScaleState.fetchSeniorListSpace(),
                    left: $r('sys.float.padding_level8')
                  })
                  .constraintSize({ minHeight: $r('app.float.id_list_primary_line_height') })
                  .id('call_number')
                Text(item.numType)
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .constraintSize({ minHeight: $r('app.float.id_list_summary_line_height') })
                  .fontWeight(FontWeight.Regular)
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical'),
                    bottom: FontScaleState.fetchSeniorListSpace()
                  })
                  .alignRules({
                    top: { anchor: 'call_number', align: VerticalAlign.Bottom },
                    left: { anchor: 'call_number', align: HorizontalAlign.Start }
                  })
                  .id('numType')
                Text(' - ')
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .constraintSize({ minHeight: $r('app.float.id_list_summary_line_height') })
                  .fontWeight(FontWeight.Regular)
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical'),
                    bottom: FontScaleState.fetchSeniorListSpace()
                  })
                  .alignRules({
                    top: { anchor: 'call_number', align: VerticalAlign.Bottom },
                    left: { anchor: 'numType', align: HorizontalAlign.End }
                  })
                  .id('dash');
                Text(item.location)
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .constraintSize({ minHeight: $r('app.float.id_list_summary_line_height') })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontWeight(FontWeight.Regular)
                  .margin({
                    top: $r('sys.float.ohos_id_text_margin_vertical'),
                    bottom: FontScaleState.fetchSeniorListSpace()
                  })
                  .alignRules({
                    top: { anchor: 'call_number', align: VerticalAlign.Bottom },
                    left: { anchor: 'dash', align: HorizontalAlign.End },
                    right: { anchor: 'call_number', align: HorizontalAlign.End }
                  })
                  .id('numLocation');
                SymbolGlyph($r('sys.symbol.phone'))
                  .fontSize($r('app.float.id_card_image_small'))
                  .fontColor([$r('app.color.skin_ohos_id_color_secondary')])
                  .alignRules({
                    center: { anchor: 'call_number', align: VerticalAlign.Bottom },
                    right: { anchor: 'call_number', align: HorizontalAlign.Start }
                  })
                  .margin({ right: $r('sys.float.padding_level8') })
                  .id('call_icon')
              }
              .height('auto')
              .padding({
                left: '24vp',
                right: '16vp'
              })
            }
            .width('100%')
            .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
            .padding({
              left: $r('sys.float.alert_content_default_padding'),
              right: $r('sys.float.alert_content_default_padding')
            })
            .onClick(() => {
              if (params.callback) {
                params.callback(item);
              }
            })
          })
        }
        .backgroundColor(Color.Transparent)
        .divider({
          strokeWidth: 0.5,
          startMargin: '64vp',
          endMargin: $r('sys.float.ohos_id_max_padding_end'),
          color: $r('app.color.skin_ohos_id_color_list_separator')
        })

        Button($r('app.string.cancel'))
          .onClick(() => {
            if (params.callback) {
              params.callback(undefined);
            }
          })
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.skin_font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .width('100%')
          .margin({
            left: $r('app.float.id_card_margin_xxl_minus'),
            right: $r('app.float.id_card_margin_xxl_minus'),
            top: $r('app.float.id_card_margin_large')
          })
          .padding({
            left: $r('app.float.id_card_margin_xxl'),
            right: $r('app.float.id_card_margin_xxl'),
            top: $r('app.float.id_card_margin_large'),
            bottom: $r('app.float.id_card_margin_large')
          })
      }
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .borderRadius($r('app.float.id_corner_radius_dialog'))
      .alignItems(HorizontalAlign.Center)
      .padding({
        bottom: $r('app.float.id_dialog_button_bottom_margin')
      })
      .margin({
        left: $r('app.float.id_dialog_button_horizontal_margin'),
        right: $r('app.float.id_dialog_button_horizontal_margin'),
      })
    }
  }
}