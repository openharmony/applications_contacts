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
import { HiLog } from '../../../../../../../feature/call/oh_modules/common';
import { VibrationEffect } from '../../../model/type/EnumUtil';
import AlphabetIndexerPresenter from '../../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';
import VibrationUtils from '../../../util/VibrationUtils';
import emitter from '@ohos.events.emitter';
import { CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import { sharedPreferencesUtils } from '../../../../../../../common';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import EmitterConstant from '../../../data/EmitterConstant';

const TAG = 'AlphabetIndexerPage';

const LOCATION_BAR_EVENT = 'LOCATION_BAR_EVENT';

@Component
export struct AlphabetIndexerPage {
  scroller: Scroller = new Scroller();
  presenter: AlphabetIndexerPresenter = AlphabetIndexerPresenter.getInstance();
  @State alphabetIndexList: string[] = [];
  hasFavorite: boolean = false;
  private selectedAlphabetIndex: number = 0;
  private popDataSource: string[] = [];
  // 选中的二级索引
  @Prop selected: number = 0;
  // 设置是否使用自适应折叠模式,默认不使用
  @Prop isAutoCollapse: boolean = false;
  @Prop useSources: string = '';
  @Link isClicked: boolean;
  @State isPop: boolean = false;
  @Prop needPop: boolean = true;
  favoriteIndexerPresenter: AlphabetIndexerPresenter | undefined = undefined;
  @Link preIndexNum: number;
  customizedParams: CustomizedParams = {};
  // 是否展示生日横幅
  showBanners: boolean = false;
  scrollIndexOffset: boolean = true;
  @StorageLink('isContactSearch') isContactSearch: boolean = true;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageProp('isShowBanners') @Watch('updateShowBanners') isShowBanners: boolean = true;
  // 是否由畅连拉起
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  static contactContentEvent: emitter.InnerEvent = {
    eventId: EmitterConstant.CONTACT_CONTENT_ALPHABET_INDEXER_EMITTER_ID,
    priority: emitter.EventPriority.HIGH
  };
  static innerEvent: emitter.InnerEvent = {
    eventId: EmitterConstant.OTHER_ALPHABET_INDEXER_EMITTER_ID,
    priority: emitter.EventPriority.HIGH
  };
  private refreshUICallback: (alphabetIndexList: string[]) => void = () => {};

  async aboutToAppear() {
    if (this.favoriteIndexerPresenter !== undefined) {
      this.presenter = this.favoriteIndexerPresenter;
    }
    setTimeout(() => {
      this.isPop = true;
    }, 100)
    emitter.on(AlphabetIndexerPage.contactContentEvent, (data: emitter.EventData) => {
      if (data.data) {
        HiLog.i(TAG, 'this.isPop true');
        this.isPop = true;
      } else {
        if (this.isPop) {
          HiLog.i(TAG, 'this.isPop false');
          this.isPop = false;
        }
      }
    })
    if (!this.useSources) {
      emitter.on(AlphabetIndexerPage.innerEvent, (data: emitter.EventData) => {
        if (data.data) {
          HiLog.i(TAG, 'this.isPop true emitter true');
          this.isPop = true;
        } else {
          if (this.isPop) {
            HiLog.i(TAG, 'this.isPop true emitter false');
            this.isPop = false;
          }
        }
      })
    }
    let showBanners =
      await sharedPreferencesUtils.getFromPreferences('showBirthdayBanners', true) as boolean;
    HiLog.w(TAG, 'showBanners' + showBanners);
    if (showBanners) {
      this.showBanners = true;
    } else {
      this.showBanners = false;
    }
    this.refreshUICallback = (alphabetIndexList: string[]) => {
      this.alphabetIndexList = alphabetIndexList;
    }
    this.presenter.refreshUICallbacks.push(this.refreshUICallback);
    this.presenter.initExistAlphabetIndexList(this.hasFavorite);
  }

  aboutToDisappear() {
    if (this.useSources) {
      emitter.off(EmitterConstant.CONTACT_CONTENT_ALPHABET_INDEXER_EMITTER_ID);
    } else {
      emitter.off(EmitterConstant.OTHER_ALPHABET_INDEXER_EMITTER_ID);
    }
    const refreshUIIndex = this.presenter.refreshUICallbacks.indexOf(this.refreshUICallback);
    if (refreshUIIndex !== -1) {
      this.presenter.refreshUICallbacks.splice(refreshUIIndex, 1);
    }
  }

  updateShowBanners() {
    this.showBanners = false;
  }

  build() {
    Column() {
      AlphabetIndexer({
        arrayValue: this.isVerde ? this.alphabetIndexList : this.presenter.alphabetIndexList,
        selected: $$this.selected
      })
        .font({
          size: $r('sys.float.ohos_id_text_size_caption'),
          weight: FontWeight.Medium
        })
        .autoCollapse(this.isAutoCollapse)
        .selectedColor(this.isFromMeetime ? $r('app.color.color_meetime_text_light_green_default') : $r('app.color.skin_font_emphasize'))
        .popupColor(this.isFromMeetime ? $r('app.color.color_meetime_text_light_green_default') : $r('app.color.skin_font_emphasize'))
        .selectedBackgroundColor(this.isFromMeetime ? $r('app.color.color_meetime_selected_background') : $r('app.color.skin_comp_emphasize_tertiary'))
        .usingPopup(this.needPop && this.isPop)
        .selectedFont({ size: '10vp', weight: FontWeight.Medium })
        .popupFont({ size: '24vp' })
        .popupPosition(this.isVerde ? { x: 48, y: 0 } : { x: $r('app.float.dialer_calllog_item_height') })
        .alignStyle(IndexerAlign.END, 48)
        .popupSelectedColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
        .popupUnselectedColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined)
        .color(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_secondary') : undefined)
        .popupBackgroundBlurStyle(this.isThemeActive ? BlurStyle.NONE : undefined)
        .onSelect((index: number) => {
          // 选中了二级索引的字母
          HiLog.w(TAG, `AlphabetIndexer onSelect is ${index},${this.needPop},${this.isPop}`);
          this.isClicked = true;
          this.selectedAlphabetIndex = index;
          let scrollIndex = this.presenter.getListScrollIndex(this.isContactSearch, this.selectedAlphabetIndex,
            undefined, undefined, this.scrollIndexOffset);
          if (scrollIndex >= 0) {
            this.scroller.scrollToIndex(scrollIndex === 0 ? 0 : scrollIndex + this.preIndexNum);
          }
          VibrationUtils.onceVibration(VibrationEffect.Light);
        })
        .onRequestPopupData((index: number) => {
          // 选中了二级索引的字母后，弹出字母对应的二级索引汉字提示
          HiLog.w(TAG, 'AlphabetIndexer onRequestPopupData is ' + index);
          this.selectedAlphabetIndex = index;
          this.popDataSource = this.presenter.getAlphabetPopData(index).slice();
          return this.popDataSource;
        })
        .onPopupSelect((index: number) => {
          // 选中了二级索引汉字的回调
          HiLog.w(TAG, 'AlphabetIndexer onPopupSelect is ' + index);
          let scrollIndex =
            this.presenter.getListScrollIndex(this.isContactSearch, this.selectedAlphabetIndex, this.popDataSource,
              index, this.scrollIndexOffset);
          if (scrollIndex >= 0) {
            this.scroller.scrollToIndex(scrollIndex === 0 ? 0 : scrollIndex + this.preIndexNum);
          }
        })
        .itemSize(16)
        .itemBorderRadius(8)
    }
    .margin({ right: EnvironmentProp.isPC() ? undefined : $r('sys.float.padding_level2') })
    .height('100%')
    .width('24vp')
    .onTouch((event) => {
      if (event?.type === TouchType.Down) {
        HiLog.w(TAG, 'AlphabetIndexer onTouch down');
        // 按下二级索引时，使用弹出式索引提示
        this.isPop = true;
        // 联系人打点--定位栏滑动定位
        DotUtil.getInstance().contactDot(this.customizedParams, LOCATION_BAR_EVENT);
      }
    })
  }
}