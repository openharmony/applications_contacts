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
import { StringUtil } from '../../../../../../feature/call/oh_modules/common';
import EnvironmentProp from '../../feature/EnvironmentProp';
import CustomButtons from './CustomButtons';

/**
 * The copy dialog box is displayed at the bottom.
 */
@Component
export default struct CustomTextInputContent {
  @State inputValue: string = '';
  @State confirmButtonEnabled: boolean = false;
  @State customTextInputFocus: boolean = false;
  isErrorConfirmButton: boolean = false;
  isFromPhoneNumberMarkAs: boolean = false;
  cancelButtonText: ResourceStr = '';
  confirmButtonText: ResourceStr = '';
  onCancel: () => void = () => {};
  onConfirm: (value: string) => void = (value: string) => {};
  controller: TextInputController = new TextInputController();
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  build() {
    Scroll() {
      Column() {
        Column() {
          Row() {
            TextInput({ controller: this.controller, text: this.inputValue })
              .width('100%')
              .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
              .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
              .fontColor($r('app.color.skin_font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .backgroundColor(Color.Transparent)
              .caretColor($r('app.color.skin_font_emphasize'))
              .fontWeight(FontWeight.Regular)
              .draggable(false)
              .focusable(true)
              .maxLength(this.isFromPhoneNumberMarkAs ? 10 : null)
              .padding({ left: $r('sys.float.padding_level0'), right: $r('sys.float.padding_level0') })
              .borderRadius(0)
              .defaultFocus(true)
              .onFocus(() => {
                this.customTextInputFocus = true;
              })
              .onBlur(() => {
                this.customTextInputFocus = false;
              })
              .onChange((value) => {
                this.inputValue = value;
                if (!StringUtil.isEmpty(this.inputValue)) {
                  this.confirmButtonEnabled = true;
                } else {
                  this.confirmButtonEnabled = false;
                }
              })
              .showUnderline(true)
          }
          .width('100%')
          .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
          .padding({
            top: $r('sys.float.padding_level2'),
            bottom: $r('sys.float.padding_level2')
          })
        }
        .width('100%')
        .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
        .justifyContent(FlexAlign.Center)
        .padding({
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
        })
        .margin({ bottom: EnvironmentProp.isPC() ? '16vp' : '8vp' })

        CustomButtons({
          confirmButtonEnabled: this.confirmButtonEnabled,
          isErrorConfirmButton: this.isErrorConfirmButton,
          cancelButtonText: this.cancelButtonText,
          confirmButtonText: this.confirmButtonText,
          onCancel: () => {
            this.onCancel();
            this.controller.stopEditing();
          },
          onConfirm: () => {
            this.onConfirm(this.inputValue);
            this.controller.stopEditing();
          }
        })
      }
    }
  }
}