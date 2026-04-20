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

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import { router, SymbolGlyphModifier } from '@kit.ArkUI';
import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { HiCarContactListItemView, HiCarFavoriteItemView } from '../../component/contact/HiCarContactListItemView';
import ContactListShowInfo from '../../model/bean/ContactListShowInfo';
import { BlankPage, HiCarContactSubHeader } from './HiCarCommonComponent';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { Favorite } from '../../data/Constants';
import { ImageType } from '../../data/HiCarConstants';
import HiCarUtil from '../../util/HiCarUtil';
// import SearchClient from '../../search/search';
import HiCarContactListShowInfo from '../../model/bean/HiCarContactListShowInfo';
import { FavoriteListBean } from '../../model/bean/FavoriteListBean';

const TAG = 'HiCarContactPage';
const CLICK_SEARCH_BAR_EVENT = 'CLICK_SEARCH_BAR_EVENT';

@Component
export default struct HiCarContactPage {
  aboutToAppear(): void {
    HiLog.i(TAG, 'HiCarContactPage aboutToAppear.');
    HiCarUtil.getInstance().initContactList();
  }

  build() {
    Column() {
      if (HiCarUtil.getInstance().getHiCarContactListDataSource().totalCount() > 0) {
        HiCarContactContent()
      } else {
        BlankPage({ headline: $r('app.string.no_contacts'), imageType: ImageType.NO_CONTACTS })
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct HiCarContactContent {
  private scroller: Scroller = new Scroller();
  private searchParams: CustomizedParams = {};

  private createSearchService(): void {
    if (ContactListPresenter.getInstance().searchSerInitStatus != 0) {
      let task = new taskpool.Task(initFusionSearchService);
      taskpool.execute(task).then((res: Object) => {
        HiLog.i(TAG, `init fusionSearchService res: ${res}`)
        ContactListPresenter.getInstance().searchSerInitStatus = Number(res.toString());
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `Failed to execute the task,err: ${err.message}`);
      });
    }
  }

  private onSearchClicked(): void {
    HiLog.i(TAG, 'onSearchClicked.');
    router.pushUrl({
      url: 'pages/hicar/HiCarContactSearchPage'
    }, router.RouterMode.Single).then(() => {
      HiLog.i(TAG, 'jumpToDevice success');
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `jumpToDevice error ${err.code}`);
    });
    this.createSearchService();
  }

  /**
   * 搜索框
   */
  @Builder
  searchBox() {
    Search({ placeholder: $r('app.string.contact_list_search') })
      .width(HiCarUtil.getInstance().getTabContentWidth())
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
      .focusable(false)
      .id('hicar_contactList_contacts_searchClick_search')
      .onClick(() => {
        //打点
        DotUtil.getInstance().contactDot(this.searchParams, CLICK_SEARCH_BAR_EVENT);
        //跳转
        this.onSearchClicked();
      })
  }

  build() {
    Column() {
      this.searchBox()

      List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
        // 收藏联系人列表
        if (HiCarUtil.getInstance().getFavoriteDataSource().totalCount() > 0) {
          ListItem() {
            HiCarContactSubHeader({ subHeaderName: $r('app.string.favorite') })
          }

          LazyForEach(HiCarUtil.getInstance().getFavoriteDataSource(), (item: FavoriteListBean, index: number) => {
            ListItem() {
              HiCarFavoriteItemView({ item: item })
            }
          }, (item: FavoriteListBean) => JSON.stringify(item))
        }
        // 联系人列表
        LazyForEach(HiCarUtil.getInstance()
          .getHiCarContactListDataSource(), (item: HiCarContactListShowInfo, index: number) => {
          ListItem() {
            HiCarContactListItemView({
              item: item,
              favorite: Favorite.FALSE,
              isShowDivider: item.isShowContactDivifer
            })
          }
        }, (item: ContactListShowInfo, index: number) => JSON.stringify(item) + index)
      }
      .cachedCount(3)
      .width('100%')
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Auto)
      .id('hicar_contactList_contacts_touch_list')
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: HiCarUtil.getInstance().getTabContentPadding() })
    .width('100%')
    .height('100%')
  }
}

@Concurrent
async function initFusionSearchService(): Promise<number> {
  // let searchSession: SearchClient.SearchSession = await SearchClient.beginSearch([]);
  return 0;
}

