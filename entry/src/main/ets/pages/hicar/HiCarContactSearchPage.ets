/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import HiCarUtil from '../../util/HiCarUtil';
import { HiLog } from '../../../../../../common';
import { sharedPreferencesUtils } from '../../../../../../feature/call/oh_modules/common';
import { HiCarConstants, ImageType } from '../../data/HiCarConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../../data/Constants';
import { router, SymbolGlyphModifier } from '@kit.ArkUI';
import { BlankPage } from './HiCarCommonComponent';
import LooseObject from '../../model/type/LooseObject';
import { simId_DEFAULT } from '../../feature/sim/SimCardState';
import NameDisposal from '../../feature/NameDisposal';
import DotUtil from '../../util/DotUtil';
import { CustomizedParams } from '../../model/type';
import emitter from '@ohos.events.emitter';
import EmitterConstant from '../../data/EmitterConstant';
import { ResourceUtil } from '../../util/ResourceUtil';

const TAG = 'HiCarContactSearchPage';
const HICAR_SEARCH_GUIDE_KNOW_EVENT = 'HICAR_SEARCH_GUIDE_KNOW_EVENT';

/**
 * HiCarContactSearchPage
 */
@Entry
@Component
export default struct HiCarContactSearchPage {
  private static SPACE_8 = 8;
  private static MAX_WIDTH = 448;
  private static EMITTER_ID = 102;
  private contactSearchBoxWidth: number = 0;
  private count: number = 0;
  private guideButtonParams: CustomizedParams = {};
  @State isShowGuide: boolean = true;
  @State inputKeyword: string = '';
  @LocalStorageProp(Constants.KEY_WINDOW_AVOID_AREA_HEIGHT_PX) windowAvoidAreaHeightPx: number = 0;
  @LocalStorageProp(Constants.KEY_WINDOW_AVOID_AREA_WIDTH_PX) windowAvoidAreaWidthPx: number = 0;
  @StorageLink(Constants.KEY_CONTACT_SEARCH_NUMBER) contactSearchNumber: number = 0;

  private getWidth(): number {
    return Math.min(HiCarContactSearchPage.MAX_WIDTH, this.contactSearchBoxWidth);
  }

  private clearSearchResult(): void {
    ContactListPresenter.getInstance().inputKeyword = '';
    // ContactListPresenter.getInstance().getSearchContactResult(ContactListPresenter.getInstance().inputKeyword);
    ContactListPresenter.getInstance().getSearchContactResultFromDb(ContactListPresenter.getInstance().inputKeyword);
  }

  aboutToAppear(): void {
    HiLog.i(TAG, 'HiCarContactSearchPage aboutToAppear.');
    this.clearSearchResult();
    this.contactSearchBoxWidth = HiCarUtil.getInstance().getContactSearchBoxWidth();
    //订阅用户输入为空格时，赋值contactSearchNumber为0
    let innerEvent: emitter.InnerEvent = {
      eventId: HiCarContactSearchPage.EMITTER_ID,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEvent, (data) => {
      this.contactSearchNumber = data?.data?.['contactSearchCount'];
    });
    //订阅应用当前是不是在手机,当前应用在手机，则不显示当前页面
    const isPhoneEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_NOTICE_WHERE_APP_EVENT_ID,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(isPhoneEvent, (data) => {
      if (data && this.count < 1) {
        router.back();
        //系统的回调方法会被多次调用，back方法只执行一次
        this.count++;
      }
    });
    sharedPreferencesUtils.init(getContext());
    sharedPreferencesUtils.getFromPreferences(HiCarConstants.KEY_IS_SHOW_GUIDE, true)
      .then(value => {
        this.isShowGuide = value as boolean;
      })
      .catch((error: BusinessError) => {
        HiLog.e(TAG, `Failed to obtain isShowGuide.ERROR: ${error.message}`);
      });
    focusControl.requestFocus('hicar_contactList_contacts_valueChange_search');
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'HiCarContactSearchPage aboutToDisappear.');
    this.clearSearchResult();
    emitter.off(HiCarContactSearchPage.EMITTER_ID);
    emitter.off(EmitterConstant.EMITTER_NOTICE_WHERE_APP_EVENT_ID);
  }

  /**
   * 用户初次使用引导界面“我知道”按钮
   */
  @Builder
  okButton() {
    Button() {
      Text($r('app.string.got_it'))
        .fontColor($r('app.color.skin_ohos_id_color_text_primary_activated'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
    }
    .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
    .onClick(() => {
      this.isShowGuide = false;
      sharedPreferencesUtils.saveToPreferences(HiCarConstants.KEY_IS_SHOW_GUIDE, false);
      DotUtil.getInstance().contactDot(this.guideButtonParams, HICAR_SEARCH_GUIDE_KNOW_EVENT);
    })
    .height($r('app.float.id_button_height_hicar'))
    .width(this.getWidth())
    .margin({ bottom: $r('app.float.id_margin_16_hicar') })
  }

  /**
   * 导航的文字内容
   */
  @Builder
  guideText() {
    Text() {
      ForEach(ResourceUtil.resourceToStringById($r('app.string.hua_xiao_fen')).split(''),
        (item: string, index: number) => {
          if (item === 'H' || item === 'X' || item === 'F') {
            Span(item)
              .fontColor($r('app.color.skin_font_emphasize'))
              .fontSize($r('app.float.id_text_size_body1_hicar'))
              .fontWeight(FontWeight.Regular)
          } else {
            Span(item)
              .fontColor($r('app.color.skin_font_tertiary'))
              .fontSize($r('app.float.id_text_size_body1_hicar'))
              .fontWeight(FontWeight.Regular)
          }
        })
    }
    .textAlign(TextAlign.Center)
    .width('100%')
  }

  @Builder
  guideButton() {
    Row({ space: HiCarContactSearchPage.SPACE_8 }) {
      ForEach(['H', 'X', 'F'], (item: string, index: number) => {
        Button({ type: ButtonType.Circle }) {
          Text(item)
            .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .fontSize($r('app.float.id_text_size_headline7_hicar'))
            .fontWeight(FontWeight.Medium)
        }
        .width($r('app.float.id_width_48_hicar'))
        .height($r('app.float.id_width_48_hicar'))
        .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
      })
    }
    .justifyContent(FlexAlign.Center)
    .margin({ top: $r('app.float.id_margin_8_hicar'), bottom: $r('app.float.id_margin_8_hicar') })
  }

  /**
   * 用户初次使用引导界面
   */
  @Builder
  guideView() {
    Column() {
      Column() {
        Text($r('app.string.initial_and_pinyin_search_supported'))
          .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
          .fontSize($r('app.float.id_text_size_body1_hicar'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ bottom: $r('app.float.id_margin_2_hicar') })

        this.guideText()

        this.guideButton()
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      this.okButton()
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 搜索组件
   */
  @Builder
  searchBox() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_ohos_id_color_primary')])
      }
      .onClick(() => {
        router.back();
        this.clearSearchResult();
      })
      .width($r('app.float.id_button_height_hicar'))
      .height($r('app.float.id_button_height_hicar'))
      .margin({ right: $r('app.float.id_margin_8_hicar') })
      .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
      .id('hicar_contactList_contacts_back_arrowBack')

      Search({ value: ContactListPresenter.getInstance().inputKeyword, placeholder: $r('app.string.initial_query') })
        .enabled(!this.isShowGuide)
        .layoutWeight(1)
        .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass'))
          .fontColor([$r('app.color.skin_ohos_id_color_secondary')]))
        .cancelButton({ icon: new SymbolGlyphModifier($r('sys.symbol.xmark'))
          .fontColor([$r('app.color.skin_font_tertiary')]) })
        .placeholderColor($r('app.color.skin_font_secondary'))
        .placeholderFont({
          size: ($r('sys.float.Body_L')),
          weight: FontWeight.Regular
        })
        .textFont({ size: $r('sys.float.Body_L') })
        .id('hicar_contactList_contacts_valueChange_search')
        .onChange((value: string) => {
          ContactListPresenter.getInstance().inputKeyword = value;
          // ContactListPresenter.getInstance().getSearchContactResult(ContactListPresenter.getInstance().inputKeyword);
          ContactListPresenter.getInstance().getSearchContactResultFromDb(ContactListPresenter.getInstance().inputKeyword);
          this.inputKeyword = value;
        })
    }
    .height($r('app.float.id_button_height_hicar'))
    .width(this.contactSearchBoxWidth)
    .margin({ top: $r('app.float.id_margin_8_hicar') })
  }

  /**
   * 搜索结果
   */
  @Builder
  contactSearchResultsList() {
    List({ space: 0, initialIndex: 0 }) {
      LazyForEach(ContactListPresenter.getInstance().searchContactsSource, (item: LooseObject, index: number) => {
        ListItem() {
          Column() {
            ContactSearchItem({
              name: item.contact.name.split(new RegExp('<|>', 'gi')),
              contactId: item.contact.entityId
            })
              .width('100%')
              .layoutWeight(1)

            Divider()
              .color($r('app.color.skin_ohos_id_color_list_separator'))
              .strokeWidth('1px')
              .visibility(index === ContactListPresenter.getInstance().searchContactsSource
                .totalCount() - 1 ? Visibility.None : Visibility.Visible)
          }
          .justifyContent(FlexAlign.End)
          .height($r('app.float.id_height_48'))
          .width('100%')
        }
        .id(`HiCarContactSearch_SearchResultClick_ListItem_${index}`)
      }, (item: LooseObject) => JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
  }

  build() {
    Column() {
      this.searchBox()

      if (!this.isShowGuide) {
        if (this.contactSearchNumber > 0) {
          Column() {
            this.contactSearchResultsList()
          }
          .layoutWeight(1)
          .width(this.contactSearchBoxWidth)
          .margin({ top: $r('app.float.id_margin_8_hicar') })
        } else if (this.inputKeyword !== '') {
          Column() {
            BlankPage({ headline: $r('app.string.contact_search_result_empty'), imageType: ImageType.NO_RESULT })
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .layoutWeight(1)
        }
      } else {
        this.guideView()
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: px2vp(this.windowAvoidAreaWidthPx), bottom: px2vp(this.windowAvoidAreaHeightPx) })
  }
}

@Component
struct ContactSearchItem {
  private contactId: number = -1;
  @State name: string[] = [];
  @StorageLink(Constants.KEY_HAVE_MULTI_SIM_CARD) haveMultiSimCard: boolean = false;
  @StorageLink(Constants.KEY_DEFAULT_SLOT) defaultSlot: number = simId_DEFAULT;

  build() {
    Row() {
      Text() {
        ForEach(NameDisposal.charEscape(this.name), (items: string, index: number) => {
          if (!(items === 'em' || items === '/em')) {
            if (index != 0) {
              if (this.name[index - 1] === 'em') {
                Span(items)
                  .fontColor($r('app.color.skin_font_emphasize'))
              } else {
                Span(items)
                  .fontColor($r('app.color.skin_ohos_fa_text_primary'))
              }
            } else {
              Span(items)
                .fontColor($r('app.color.skin_ohos_fa_text_primary'))
            }
          }
        })
      }
      .fontSize($r('app.float.id_text_size_body1_hicar'))
      .fontWeight(FontWeight.Medium)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .onClick(() => {
      HiCarUtil.getInstance()
        .contactDialingByContactId(this.getUIContext(), String(this.contactId), this.haveMultiSimCard, this.defaultSlot,
          HiCarConstants.CONTACT_DOT_ENC_SEARCH);
    })
    .width('100%')
    .height('100%')
  }
}

