/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import EmitterConstant from '../../data/EmitterConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import ContactListShowInfo from '../../model/bean/ContactListShowInfo';
import AlphabetIndexerPresenter from '../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';
import IndexPresenter from '../../presenter/IndexPresenter';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import emitter from '@ohos.events.emitter';
import curves from '@ohos.curves';
import { AlphabetIndexerPage } from '../../pages/contacts/alphabetindex/AlphabetIndexerPage';
import { CustomizedParams } from '../../model/type';
import { HiLog, StringUtil } from '../../../../../../common';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import IntelligenceGroupContactListItem from './IntelligenceGroupContactListItem';
import IntelligenceGroupSingleGroupDetailPresenter
  from '../../presenter/intelligencegroup/IntelligenceGroupSingleGroupDetailPresenter';
import {
  IntelligenceGroupAlphabetIndexerPage
} from '../../pages/contacts/alphabetindex/IntelligenceGroupAlphabetIndexerPage';

const TAG = 'IntelligenceGroupSingeGroupContactList  ';
const TITLE_HEIGHT: number = 56;

/**
 * 联系人tab内容页面
 */
@Component
export struct IntelligenceGroupSingeGroupContactList {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State private showSubHeaderIndex: Number = 0;
  @State private presenter: ContactListPresenter = ContactListPresenter.getInstance();
  @Link singleGroupDetailPresenter: IntelligenceGroupSingleGroupDetailPresenter;
  @Link private contactListListLen: number;
  @State categoryGroupType: string = '';
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 刷新
  @StorageLink('refreshing') refreshing: boolean = false;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  // 监听搜索框是否显示
  @StorageLink('isShowSearch') isShowSearch: boolean = true;
  @Link private navigationMenusOpacity: number;
  @State isPull: boolean = false;
  private scroller: Scroller = new Scroller();
  @StorageLink('mainTabsIndex') mainTabsIndex: number = 0;
  // 滑动列表，页面首个联系人变化，选中的二级索引需要变化
  @State alphabetSelected: number = 0;
  // 是否点击了二级索引
  @State isAlphabetClicked: boolean = false;
  @State alphabetIndexPresenter: AlphabetIndexerPresenter = this.singleGroupDetailPresenter.alphabetIndexPresenter;
  private isPC: boolean = EnvironmentProp.isPC();
  downY: number = 0;
  lastMoveY: number = 0;
  isFirstListItem = true;
  @StorageLink('selectContactId') selectContactId: string = '';
  @StorageLink('contactsList_y') @Watch('contactsListyChange') contactsListY: number = 0;
  customParams: CustomizedParams = {};
  @State stages: number = 1;
  @State searchOffsetY: number = 0;
  prevSearchOffsetY: number = 0;
  scrollReachEnd: boolean = false;
  hasCard: boolean = false;
  @StorageProp('currentColorMode') currentColorMode: number = 1;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  // 畅连
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @StorageProp('isMeetimePC') isMeetimePC: boolean = false;
  @StorageLink('displaySyncCard') displaySyncCard: Visibility = Visibility.None;
  @State offSetY: number = 0;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @State dragList: boolean = false;

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear list')
    this.singleGroupDetailPresenter.onNewContactToIndex = (newContactId: string, newContactIndex: number) => {
      if (this.curBp != 'sm') {
        this.selectContactId = newContactId;
        this.scroller.scrollToIndex(newContactIndex, false, ScrollAlign.CENTER);
      }
    }
    if (this.mainTabsIndex === IndexPresenter.getInstance().contactIndex) {
      IndexPresenter.getInstance().emitDefaultSelectedContact();
    }
  }

  isNeedAutoCollapse() {
    if (this.isVerde) {
      return true;
    }
    if (this.splitStatus === SplitStatus.TWO_THREE_SPLIT) {
      return true;
    }
    if (this.isShowSmartWindow) {
      return true;
    }
    return false;
  }

  aboutToDisappear() {
    if (this.isPC) {
      this.presenter.inputKeyword = '';
      // this.presenter.getSearchContactResult(this.presenter.inputKeyword);
      this.presenter.getSearchContactResultFromDb(this.presenter.inputKeyword);
    }
    emitter.off(EmitterConstant.EMITTER_CONTACTS_DEFAULT_SELECTED_EVENT_ID);
    emitter.off(EmitterConstant.UPDATE_SHOW_BIRTHDAY_BANNERS_EMITTER_ID);
    emitter.off(EmitterConstant.CONTACT_LIST_CACHE_UPDATE);
  }

  contactsListyChange() {
    if (this.contactsListY === 0) {
      this.navigationAnimate();
    }
  }

  navigationAnimate() {
    this.navigationMenusOpacity = 0.1;
    animateTo({
      duration: this.isPull ? 150 : 400, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), onFinish: () => {
        this.navigationMenusOpacity = 1;
      }
    }, () => {
      this.navigationMenusOpacity = 0.9;
    })
  }

  onBackPress() {
    if (this.isVerde) {
      this.contactsListY = 0;
      let exportData: emitter.EventData = {
        data: {
          'isPop': true
        }
      }
      emitter.emit(AlphabetIndexerPage.innerEvent, exportData);
    } else {
      animateTo({
        curve: curves.interpolatingSpring(0, 1, 342, 38)
      }, () => {
        this.contactsListY = 0;
        let exportData: emitter.EventData = {
          data: {
            'isPop': true
          }
        }
        emitter.emit(AlphabetIndexerPage.innerEvent, exportData);
      });
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Stack({ alignContent: Alignment.Top }) {
        List({ space: 0, initialIndex: this.singleGroupDetailPresenter.initialIndex, scroller: this.scroller }) {
          // 联系人列表
          LazyForEach(this.singleGroupDetailPresenter.contactListDataSource,
            (item: ContactListShowInfo, index: number) => {
              ListItem() {
                IntelligenceGroupContactListItem({
                  showSubHeaderIndex: this.showSubHeaderIndex,
                  showInfo: item,
                  index: index
                })
              }
            }, (item: ContactListShowInfo, index: number) => item.getItemKey() + index)
        }
        .contentEndOffset(16)
        .cachedCount(3)
        .width('100%')
        .height('100%')
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .id('intelligenceGroup_contacts_touch_list')
        // 滑动过程中频繁触发
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          this.singleGroupDetailPresenter.resetInitialIndex(firstIndex);
          if (!this.isAlphabetClicked && this.dragList) {
            this.alphabetSelected = this.alphabetIndexPresenter.getAlphabetSelected(firstIndex);
          }
        })
        .onReachEnd(() => {
          this.scrollReachEnd = true;
        })
        // 滚动开始触发
        .onScrollStart(() => {
          emitter.emit(AlphabetIndexerPage.innerEvent);
          this.dragList = true;
          this.isAlphabetClicked = false;
        })
        // 滚动结束触发
        .onScrollStop(() => {
          this.isAlphabetClicked = true;
          this.dragList = false;
        })
        // 联动效果跳过refresh，使用上层父组件联动
        .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
        .friction(0.75)
        .accessibilityLevel('auto')
        .accessibilityGroup(false)
        .clipContent(ContentClipMode.SAFE_AREA)
        .safeAreaPadding({ top: this.isPC ? 0 : '94vp' })

      }
      .height('100%')
      .width('100%')
      if (DisplaySplitUtil.isShowIndex(this.splitStatus)) {
        IntelligenceGroupAlphabetIndexerPage({
          scroller: this.scroller,
          presenter: $alphabetIndexPresenter,
          selected: this.alphabetSelected,
          isClicked: $isAlphabetClicked,
          isAutoCollapse: this.isNeedAutoCollapse(),
          scrollIndexOffset: false
        })
          .id('IntelligenceGroup_ContactList_alphabetIndexer_alphabetIndexerPage')
          .margin({
            top: this.isPC ? '16vp' : '110vp',
            left: '4vp',
            right: this.isPC ? '4vp' : 0
          })
      }
    }
  }
}