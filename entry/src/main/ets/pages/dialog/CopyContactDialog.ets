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

/**
 * The copy dialog box is displayed at the bottom.
 */
@Component
export default struct CopyContactDialog {
  itemList: string[] | Resource[] = [];
  onItemClick: (item: string | Resource, index: number | undefined) => void = () => {};

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level7'))
    .width('100%')
    .constraintSize({ minHeight: 64 })
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  build() {
    Column() {
      List() {
        ForEach(this.itemList, (item: string | Resource, index: number | undefined) => {
          ListItem() {
            Stack({ alignContent: Alignment.BottomEnd }) {
              Column() {
                Text(item === 'phone' ? $r('app.string.phone') : item)
                  .layoutWeight(1)
                  .fontColor($r('app.color.skin_font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .lineHeight('22vp')
                  .fontSize($r('sys.float.Subtitle_M'))
                  .width('100%')
              }
              .layoutWeight(1)
              .height('64vp')
              .alignItems(HorizontalAlign.Start)
              .stateStyles({
                pressed: this.pressedStyles,
                normal: this.normalStyles
              })
              .width('100%')
              .onClick(() => {
                this.onItemClick(item, index);
              })

              if (index !== this.itemList.length - 1) {
                Divider()
                  .backgroundColor($r('app.color.skin_comp_divider'))
                  .width('100%')
              }
            }
          }
          .layoutWeight(1)
        }, (item: string | Resource) => { return item.toString() });
      }
      .width('100%')
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .constraintSize({ maxHeight: this.itemList.length <= 1 ? 184 : 248 })
  }
}