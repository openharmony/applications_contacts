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

// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { FontScaleState } from '../../../util/fontScaleState';
import { SplitStatus } from '../../../util/DisplaySplitUtil';
import { SystemModeController } from '../../../util/SystemModeController';

@Component
export struct ContactEmptyPage {
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @StorageLink('displaySyncCard') displaySyncCard: Visibility = Visibility.None;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  private scroller: Scroller = new Scroller();
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageLink('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;

  aboutToAppear(): void {
    this.hideIndexTitleTabBar = false;
  }

  private getBackgroundColor(): Resource | Color {
    let backgroundColor: Resource | Color = $r('app.color.skin_background_primary');
    if (this.isFromMeetime) {
      backgroundColor = $r('app.color.skin_background_secondary');
    } else if (this.isThemeActive) {
      backgroundColor = Color.Transparent;
    }
    return backgroundColor;
  }

  build() {
    if (FontScaleState.isSmallerThirdGeer(this.fontSizeScale) || (this.displaySyncCard === Visibility.None)) {
      if ((this.isVerde || (this.splitStatus !== SplitStatus.DEFAULT) || this.isShowSmartWindow) &&
        this.displaySyncCard !== Visibility.None) {
        this.seniorLayout()
      } else {
        this.normalLayout()
      }
    } else {
      this.seniorLayout()
    }
  }

  @Builder
  normalLayout() {
    Stack({ alignContent: Alignment.Top }) {
      // PafEmptyPage({
      //   icon: $r('app.media.ic_empty_page_no_contacts'),
      //   emptyDescription: $r('app.string.no_contacts'),
      //   descriptionFontColor: this.isThemeActive ? $r('app.color.skin_font_tertiary') : undefined,
      //   customBackgroundColor: this.getBackgroundColor(),
      //   fullPage: true,
      //   buttonBackgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_button_normal') : $r('sys.color.comp_background_tertiary')
      // })
      //   .zIndex(0)
    }
    .padding({ bottom: this.curBp === 'lg' ? px2vp(this.fullScreenPadding.bottom as number) : 0 })
    .height('100%')
    .width('100%')
  }

  @Builder
  seniorLayout() {
    List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
      ListItem() {
        // PafEmptyPage({
        //   icon: $r('app.media.ic_empty_page_no_contacts'),
        //   emptyDescription: $r('app.string.no_contacts'),
        //   descriptionFontColor: this.isThemeActive ? $r('app.color.skin_font_tertiary') : undefined,
        //   customBackgroundColor: this.getBackgroundColor(),
        //   fullPage: false,
        //   buttonBackgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_button_normal') : $r('sys.color.comp_background_tertiary')
        // })
        //   .zIndex(0)
      }
    }
    .padding({ bottom: this.curBp === 'lg' ? px2vp(this.fullScreenPadding.bottom as number) : 0 })
    .height('100%')
    .width('100%')
  }
}