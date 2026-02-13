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
import EnvironmentProp from '../../feature/EnvironmentProp';
import { DialButtonTablet } from './DialButtonTablet';

@Component
export struct DiaPadTablet {
  @StorageLink('breakpoint') curBp: string = 'sm';
  numberList: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#']
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageLink('isWindowPcMode') windowPcMode: boolean = false;
  @Prop dialPadHeight: number;
  @Prop dialButtonHeight: number;

  build() {
    GridRow({ columns: 3, gutter: { x: EnvironmentProp.isPC() ? 0 : this.isTabletLandscape ? 12 : 0, y: 0 } }) {
      ForEach(this.numberList, (item: string) => {
        GridCol({ span: 1 }) {
          DialButtonTablet({
            buttonNumber: item,
            dialButtonHeight: this.dialButtonHeight
          })
        }
      })
    }
    .direction(Direction.Ltr)
    .width('100%')
    .height(((EnvironmentProp.isDeviceTypeTablet() || EnvironmentProp.isPhone() && this.curBp === 'lg') &&
    this.windowPcMode) ? this.dialPadHeight : undefined)
    .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
  }
}
