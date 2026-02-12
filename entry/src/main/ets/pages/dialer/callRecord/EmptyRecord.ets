// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
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
 * Call Log Empty Call View
 */
import { HiLog } from '../../../../../../../common'
import { ResourceUtil } from '../../../util/ResourceUtil';
import { curves, performanceMonitor } from '@kit.ArkUI';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { FontScaleState } from '../../../util/fontScaleState';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import { i18n } from '@kit.LocalizationKit';

const TAG = 'EmptyRecord ';

@Component
export default struct EmptyRecord {
  recordType: number = 0;
  // v小折叠外屏需要限制
  @State maxFontScale: number = 2;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('isInitViewShow') isInitViewShow: boolean = true;
  @StorageLink('showDialBtn') showDialBtn: boolean = true;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  @StorageProp('fontSizeScale') @Watch('onSegmentDiaplayStatusChange') fontSizeScale: number = 0;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('dialerHideActionType') dialerHideActionType: performanceMonitor.ActionType =
    performanceMonitor.ActionType.LAST_UP;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageLink('isShowSegmentBtn') @Watch('onSegmentDiaplayStatusChange') isShowSegmentBtn: boolean = false;
  private scroller: Scroller = new Scroller();
  downY: number = 0;
  @State segmentButtonOffsetY: number = 0;
  @StorageProp('splitStatus') @Watch('updateMaxFontScale') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageProp('isVerde') isVerde: boolean = false;

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear,recordType:' + this.recordType)
    this.hideIndexTitleTabBar = false;
    // 大六档segmentButton的高度
    this.segmentButtonOffsetY =
      (FontScaleState.isSmallerSixGeer(this.fontSizeScale) || !this.isShowSegmentBtn) ? 0 :
        (20 + 16) * Math.min(FontScaleState.fontScale, 2) + 16 + 4;
    this.updateMaxFontScale();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear,recordType:' + this.recordType)
  }

  onSegmentDiaplayStatusChange() {
    animateTo({ curve: curves.responsiveSpringMotion() }, () => {
      // 大六档segmentButton的高度
      this.segmentButtonOffsetY =
        (FontScaleState.isSmallerSixGeer(this.fontSizeScale) || !this.isShowSegmentBtn) ? 0 :
          (20 + 16) * Math.min(FontScaleState.fontScale, 2) + 16 + 4;
    });
  }

  build() {
    Scroll(this.scroller) {
      // if (this.isInitViewShow) {
      //   Column({ space: '16vp' }) {
      //     Text($r('app.string.pinyin_search_supported'))
      //       .fontColor($r('app.color.skin_font_tertiary'))
      //       .fontSize($r('sys.float.Body_L'))
      //       .fontWeight(FontWeight.Medium)
      //       .textAlign(TextAlign.Center)
      //       .width('100%')
      //       .maxFontScale(this.maxFontScale)
      //
      //     Text() {
      //       ForEach(ResourceUtil.resourceToStringById($r('app.string.hua_xiao_fen')).split(''),
      //         (item: string, index: number) => {
      //         if (item === 'H' || item === 'X' || item === 'F') {
      //           Span(item)
      //             .fontColor($r('app.color.skin_font_emphasize'))
      //             .fontSize($r('sys.float.Body_M'))
      //             .fontWeight(FontWeight.Regular)
      //         } else {
      //           Span(item)
      //             .fontColor($r('app.color.skin_font_tertiary'))
      //             .fontSize($r('sys.float.Body_M'))
      //             .fontWeight(FontWeight.Regular)
      //         }
      //       })
      //     }
      //     .textAlign(TextAlign.Center)
      //     .width('100%')
      //     .maxFontScale(this.maxFontScale)
      //
      //     Column() {
      //       if (this.fontSizeScale > 3) {
      //         Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center }) {
      //           this.setupTipsUI()
      //         }
      //         .width('100%')
      //       } else {
      //         Row({space: '26vp' }) {this.setupTipsUI()}
      //       }
      //     }
      //   }
      //   .accessibilityText(`${AccessibilityUtil.getInstance()
      //     .setAccessibilityText(this.isOpenAccessibility, $r('app.string.pinyin_search_supported'))}` +
      //     ` ${AccessibilityUtil.getInstance()
      //       .setAccessibilityText(this.isOpenAccessibility, $r('app.string.hua_xiao_fen'))}4 9 3`)
      //   .accessibilityGroup(true)
      //   .height(this.isVerde ? `auto` : (DisplaySplitUtil.isHorizonSplit(this.splitStatus) ||
      //   DisplaySplitUtil.isVerticalSplit(this.splitStatus)) ? undefined : this.isVerde ? `calc(100% - 64vp)` : '100%')
      //   .justifyContent(this.isVerde ? FlexAlign.Start : FlexAlign.Center)
      // } else {
        Column() {
          Column(){
            Image($r('app.media.ic_empty_page_no_call_records'))
              .objectFit(ImageFit.Contain)
              .width($r('app.float.id_card_image_large'))
              .height($r('app.float.id_card_image_large'))
              .margin({ bottom: $r('app.float.id_card_margin_large') })

            Text(this.recordType === 0 ? $r('app.string.no_dialer_calllog') :
              $r('app.string.no_dialer_missed_calllog'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Regular)
              .fontColor(this.isThemeActive ? $r('app.color.skin_font_tertiary') : undefined)
              .textAlign(TextAlign.Center)
              .margin({ bottom: $r('app.float.dialer_calllog_item_height') })
          } .height(this.isVerde ? `auto` : '100%')
          .justifyContent(this.isVerde ? FlexAlign.Start : FlexAlign.Center)
          // PafEmptyPage({
          //   icon: $r('app.media.ic_empty_page_no_call_records'),
          //   emptyDescription: this.recordType === 0 ? $r('app.string.no_dialer_calllog') :
          //   $r('app.string.no_dialer_missed_calllog'),
          //   customBackgroundColor: this.isThemeActive ? Color.Transparent : $r('app.color.skin_background_primary'),
          //   fullPage: true,
          //   descriptionFontColor: this.isThemeActive ? $r('app.color.skin_font_tertiary') : undefined
          // })
          //   .height(this.isVerde ? `auto` : '100%')
        }
        .justifyContent(FlexAlign.Start)
        .padding({ bottom: this.curBp === 'lg' ? px2vp(this.fullScreenPadding.bottom as number) :
          (DisplaySplitUtil.isSmOneThreeSplit(this.splitStatus) || this.splitStatus === SplitStatus.HALF_SPLIT ||
          this.splitStatus === SplitStatus.VERTICAL_SPLIT) ? '38vp' : 0 })
        .width('100%')
        .height('100%')
      // }
    }
    .width('100%')
    .height(this.isVerde ? `calc(100% - 64vp)` : '100%')
    .scrollable(ScrollDirection.None)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .onTouch((event: TouchEvent) => {
      // 无通话记录时滑动隐藏拨号盘，触发打点时机为手指移动时
      this.dialerHideActionType = performanceMonitor.ActionType.FIRST_MOVE;
      this.showDialBtn = false;

      switch (event.type) {
        case TouchType.Down:
          this.downY = -1;
          break;

        case TouchType.Move:
          if (this.downY === -1) {
            this.downY = event.touches[0].y;
          }
          break;

        case TouchType.Up:
        case TouchType.Cancel:
          const upY: number = event.touches[0].y;
          if (this.downY != -1 && upY - this.downY > 50) {
            this.isShowSegmentBtn = true;
          }
          break;
      }
    })
  }

  @Builder
  setupTipsUI() {
    Column() {
      Text('4')
        .fontColor($r('app.color.skin_font_secondary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Regular)
        .maxFontScale(this.maxFontScale)


      Text() {
        ForEach('GHI'.split(''), (item: string, index: number) => {
          if (item === 'H') {
            Span(item)
              .fontColor($r('app.color.skin_font_emphasize'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
          } else {
            Span(item)
              .fontColor($r('app.color.skin_font_tertiary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
          }
        })
      }
      .maxFontScale(this.maxFontScale)
    }

    Text('+')
      .fontColor($r('app.color.skin_font_secondary'))
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Regular)
      .maxFontScale(this.maxFontScale)

    Column() {
      Text('9')
        .fontColor($r('app.color.skin_font_secondary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Regular)
        .maxFontScale(this.maxFontScale)

      Text() {
        ForEach('WXYZ'.split(''), (item: string, index: number) => {
          if (item === 'X') {
            Span(item)
              .fontColor($r('app.color.skin_font_emphasize'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
          } else {
            Span(item)
              .fontColor($r('app.color.skin_font_tertiary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
          }
        })
      }
      .maxFontScale(this.maxFontScale)
    }

    Text('+')
      .fontColor($r('app.color.skin_font_secondary'))
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Regular)
      .maxFontScale(this.maxFontScale)

    Column() {
      Text('3')
        .fontColor($r('app.color.skin_font_secondary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Regular)
        .maxFontScale(this.maxFontScale)

      Text() {
        ForEach('DEF'.split(''), (item: string, index: number) => {
          if (item === 'F') {
            Span(item)
              .fontColor($r('app.color.skin_font_emphasize'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
          } else {
            Span(item)
              .fontColor($r('app.color.skin_font_tertiary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
          }
        })
      }
      .maxFontScale(this.maxFontScale)
    }
  }

  private isSystemLanguage(lang: string): boolean {
    HiLog.i(TAG, `updateMaxFontScale, SystemLanguage: ${i18n.System.getSystemLanguage()}`);
    return i18n.System.getSystemLanguage() === lang;
  }

  private updateMaxFontScale() {
    if (this.isSystemLanguage('ar') || this.isSystemLanguage('es')) {
      if (this.splitStatus === SplitStatus.HALF_SPLIT) {
        this.maxFontScale = 1.45;
      } else if (this.splitStatus === SplitStatus.ONE_THREE_SPLIT) {
        this.maxFontScale = 1;
      } else {
        this.maxFontScale = 2;
      }
    } else {
      this.maxFontScale = 2;
    }
    HiLog.i(TAG, `updateMaxFontScale, splitStatus: ${this.splitStatus}, maxFontScale: ${this.maxFontScale}`);
  }
}