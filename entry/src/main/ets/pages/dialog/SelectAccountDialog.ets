/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import ArrayList from '@ohos.util.ArrayList';
import { VisionGlassConstants } from '../../data/VisionGlassConstants';
import { AccountVo } from '../../model/bean/AccountVo';
import { FontScaleState } from '../../util/fontScaleState';

/**
 *  The Select Vcard dialog box is displayed at the bottom.
 */
@Component
export default struct SelectAccountDialog {
  @Link accountItems: AccountVo[];
  @Link accountIds: ArrayList<string>
  @StorageLink('breakpoint') curBp: string = 'sm';
  private scroller: Scroller = new Scroller();
  @State private selectItems: boolean[] = []
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否显示在VisionGlass
  @StorageProp(VisionGlassConstants.KEY_IS_IN_VISION_GLASS) isInVisionGlass: boolean = false;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('app.color.skin_interactive_click'))
  }

  aboutToAppear() {
    for (let i = 0; i < this.accountItems.length; ++i) {
      this.selectItems[i] = false;
    }
  }

  build() {
    Column() {
      List({ initialIndex: 0, scroller: this.scroller }) {
        ForEach(this.accountItems, (item: AccountVo, index: number) => {
          ListItem() {
            Row() {
              Column() {
                Text((this.curBp === 'lg' && !this.isInVisionGlass) ? $r('app.string.tablet') : $r('app.string.phone'))
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .fontSize($r('sys.float.Subtitle_M'))
                  .fontColor($r('app.color.skin_font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                if (item.dataInfo) {
                  Text(item.dataInfo)
                    .width('100%')
                    .textAlign(TextAlign.Start)
                    .fontSize($r('sys.float.Subtitle_S'))
                    .fontColor($r('app.color.skin_font_secondary'))
                    .fontWeight(FontWeight.Regular)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: $r('sys.float.padding_level1') })
                }
              }
              .margin({
                top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                  0, $r('app.float.id_card_item_margin_top')),
                bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                  0, $r('app.float.id_card_item_margin_top')),
              })
              .flexShrink(1)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .constraintSize({
                minHeight: FontScaleState.isStandardGeer(this.fontSizeScale) ? '48vp' : 0
              })

              Column() {
                Checkbox({ name: 'checkbox' + index, group: 'vcfCheckbox' })
                  .select(this.selectItems[index])
                  .width('24vp')
                  .height('24vp')
                  .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') :
                    undefined)
                  .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
                  .margin($r('sys.float.padding_level0'))
                  .padding($r('sys.float.padding_level1'))
                  .selectedColor($r('app.color.skin_comp_background_emphasize'))
                  .onChange((value: boolean) => {
                    if (value) {
                      this.accountIds.add(item.accountId)
                    } else {
                      this.accountIds.remove(item.accountId)
                    }
                  })
              }
              .padding({ left: $r('sys.float.padding_level4') })
              .hitTestBehavior(HitTestMode.None)
              .flexShrink(0)
            }
            .width('100%')
            .constraintSize({ minHeight: '48vp' })
            .justifyContent(FlexAlign.Center)
          }
          .padding({ left: 12, right: 12 })
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
          })
          .onClick(() => {
            this.selectItems[index] = !this.selectItems[index];
          })
        })
      }
      .scrollBar(BarState.Off)
      .margin({ left: -12, right: -12 })
      .divider({
        strokeWidth: 1,
      })
    }
    .constraintSize({ maxHeight: this.accountItems.length <= 1 ? 184 : 248 })
  }
}