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
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { PhoneNumberInterface } from '../../../model/type';
import { ContactVo } from '../../../model/bean/ContactVo';
import MockResource from '../../../model/bean/MockResource';
import { getPixelMapFromFile } from '../../../util/UserPhoto'
import { FontScaleState } from '../../../util/fontScaleState';

/**
 * Select the contact item component, which is responsible for displaying a single contact.
 */

@Extend(Text) function contentGeneraStyle() {
  .fontColor($r('app.color.skin_font_primary'))
  .fontSize($r('sys.float.Subtitle_M'))
  .fontWeight(FontWeight.Medium)
  .margin({
    left: $r('app.float.id_card_margin_xxl'),
    bottom: $r('sys.float.padding_level5'),
    top: $r('sys.float.padding_level5')
  })
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Component
export default struct BatchSelectSetItemView {
  @State private single: boolean = false;
  @State item: ContactVo = new ContactVo('', '', '', '', '', '', new MockResource(), false, '', '', '');
  private onContactItemClicked: (index: number, indexChild: number) => void = () => {
  };
  private onSingleContactItemClick: Function = () => {
  };
  private index: number = -1;
  @State showPressedStyles: boolean = false;
  @State photoPixelMap: PixelMap | null = null;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  aboutToAppear() {
    getPixelMapFromFile(this.item.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res
    })
  }

  build() {
    Row() {
      Row() {
        Row() {
          if (this.photoPixelMap) {
            Image(this.photoPixelMap)
              .width($r('app.float.id_card_image_mid'))
              .height($r('app.float.id_card_image_mid'))
              .objectFit(ImageFit.Contain)
              .borderRadius($r('app.float.id_card_image_mid'))
              .draggable(false)
              .onError(() => {
                this.photoPixelMap = null
              })
          } else if (StringUtil.isEmpty(this.item.headChar)) {
            Image(StringUtil.isEmpty(this.item.portraitPath) ? $r('app.media.ic_user_portrait') : this.item.portraitPath)
              .width($r('app.float.id_card_image_mid'))
              .height($r('app.float.id_card_image_mid'))
              .objectFit(ImageFit.Contain)
              .borderRadius($r('app.float.id_card_image_mid'))
              .backgroundColor(this.item.portraitColor)
              .draggable(false)
          } else {
            Text(this.item.headChar)
              .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '16vp')
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor(this.item.portraitColor)
              .height($r('app.float.id_card_image_mid'))
              .width($r('app.float.id_card_image_mid'))
              .textAlign(TextAlign.Center)
              .borderRadius($r('app.float.id_card_image_mid'))
          }
        }
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .flexShrink(0)

        Column() {
          if (FontScaleState.isStandardGeer(this.fontSizeScale)) {
            Text(StringUtil.isEmpty(this.item.showName) ? this.item.phoneNum : this.item.showName)
              .contentGeneraStyle()
              .lineHeight('21vp')
              .maxLines(2)
          } else {
            Text(StringUtil.isEmpty(this.item.showName) ? this.item.phoneNum : this.item.showName)
              .contentGeneraStyle()
          }
        }
        .padding({
          top: FontScaleState.isStandardGeer(this.fontSizeScale) ? 0 : 10,
        })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)
        .flexShrink(1)
        .constraintSize({ minHeight: $r('app.float.id_item_height_max') })

        Toggle({
          type: ToggleType.Checkbox,
          isOn: (this.item.phoneNumbers[0].checked == undefined) ? false : this.item.phoneNumbers[0].checked
        })
          .size({ width: 20, height: 20 })
          .margin($r('sys.float.padding_level1'))
          .flexShrink(0)
          .enabled(true)
          .hitTestBehavior(HitTestMode.None)
          .selectedColor($r('app.color.skin_comp_background_emphasize'))
          .visibility(!this.single ? Visibility.Visible : Visibility.None)
      }
      .margin({
        left: this.showPressedStyles ? $r('sys.float.padding_level6') : $r('sys.float.padding_level0'),
        right: this.showPressedStyles ? $r('sys.float.padding_level6') : $r('sys.float.padding_level0')
      })
      .layoutWeight(1)
      .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
    .id(`BatchSelectSetItemView_${this.index}_chick_Row`)
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .onClick(() => {
      if (!this.single) {
        this.onContactItemClicked(this.index, 0);
      } else {
        this.onSingleContactItemClick(this.item.phoneNumbers[0].phoneNumber, this.item.showName);
      }
    })
  }
}
