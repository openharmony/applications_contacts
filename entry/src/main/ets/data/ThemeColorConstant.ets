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
import { CustomColors, CustomTheme } from '@ohos.arkui.theme';

class SysColors implements CustomColors {

}
class DefaultColors implements CustomColors {
  public fontPrimary = $r('app.color.skin_font_primary')
  public iconPrimary = $r('app.color.skin_icon_primary')
  public iconEmphasize = $r('app.color.skin_icon_emphasize')
  public warning = $r('app.color.skin_warning')
  public fontEmphasize = $r('app.color.skin_font_emphasize')
  public iconOnPrimary = $r('app.color.skin_icon_on_primary')
  public compDivider = $r('app.color.skin_comp_divider')
  public iconFourth = $r('app.color.skin_icon_fourth')
  public compBackgroundEmphasize = $r('app.color.skin_comp_background_emphasize')
  public compBackgroundTertiary = $r('app.color.skin_comp_background_tertiary')
  public brand = $r('app.color.skin_font_emphasize')
  public fontOnPrimary = $r('app.color.skin_font_on_primary')
  public backgroundEmphasize = $r('app.color.skin_icon_emphasize')
}

class ButtonColors implements CustomColors {
  public compBackgroundTertiary = $r('app.color.skin_ohos_id_color_button_normal')
}

class PageCustomTheme implements CustomTheme {
  colors?: CustomColors;

  constructor(colors: CustomColors) {
    this.colors = colors;
  }
}
// 系统色主题
export const sysTheme: CustomTheme = new PageCustomTheme(new SysColors());
// 默认主题，当前主题所有组件共用，暂未定制单独的组件专用主题
export const defaultCustomTheme: CustomTheme = new PageCustomTheme(new DefaultColors());
export const buttonCustomTheme: CustomTheme = new PageCustomTheme(new ButtonColors());