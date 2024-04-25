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
import callTabletPage from './dialer/DialerTablet';
import contactPage from './contacts/ContactList';
import favoritePage from './favorites/favoriteList';
import callPage from './phone/dialer/Dialer';
import IndexPresenter from '../presenter/IndexPresenter';
import { HiLog, StringUtil } from '../../../../../common';
import { PermissionManager } from '../../../../../common/src/main/ets/permission/PermissionManager';
import DialerPresenter from '../presenter/dialer/DialerPresenter';
import call from '@ohos.telephony.call';
import ContactListPresenter from '../presenter/contact/ContactListPresenter';
import CallRecordPresenter from '../presenter/dialer/callRecord/CallRecordPresenter';
import FavoriteListPresenter from '../presenter/favorite/FavoriteListPresenter';
import device from '@system.device';
import emitter from '@ohos.events.emitter';

const TAG = 'Index ';

let storage = LocalStorage.GetShared()

@Entry(storage)
@Component
struct Index {
  private controller: TabsController = new TabsController();
  @State mPermissionManager: PermissionManager = PermissionManager.getInstance();
  mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @StorageLink('mainTabsIndex') @Watch('onIndexChanged') mainTabsIndex: number = 0;
  @StorageLink('teleNumber') @Watch('teleNumberChange') teleNumber: string = '';
  mDialerPresenter: DialerPresenter = DialerPresenter.getInstance();
  @State bottomTabIndex: number = call.hasVoiceCapability() ? 0 : 1;
  @StorageLink('targetPage') @Watch('targetPageChange') targetPage: {
    url?: string,
    pageIndex?: number,
    params?: any
  } = {};
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  @State isContactSearch: boolean = false;
  emitterId: number = 105;

  teleNumberChange() {
    if (!StringUtil.isEmpty(this.teleNumber)) {
      this.mDialerPresenter.editPhoneNumber(this.teleNumber);
      AppStorage.SetOrCreate('showDialBtn', true);
      this.teleNumber = '';
    }
  }

  targetPageChange() {
    if (this.targetPage && this.targetPage.url) {
      HiLog.i(TAG, 'targetPageChange in' + this.targetPage);
      this.mIndexPresenter.goToPage(this.targetPage.url, this.targetPage.pageIndex, this.targetPage.params)
      this.targetPage = {}
    }
  }

  onIndexChanged(): void {
    HiLog.i(TAG, 'uriTabIndex change:' + this.mainTabsIndex);
    if (this.mainTabsIndex != this.bottomTabIndex) {
      if (this.mainTabsIndex == 0 && !call.hasVoiceCapability()) {
        HiLog.i(TAG, 'not hasVoiceCapability');
        return;
      }
      this.bottomTabIndex = this.mainTabsIndex;
      this.controller.changeIndex(this.mainTabsIndex);
      CallRecordPresenter.getInstance().setPageShow(this.bottomTabIndex == 0);
      ContactListPresenter.getInstance().setPageShow(this.bottomTabIndex == 1);
      if (this.mainTabsIndex != 2) {
        FavoriteListPresenter.getInstance().onPageHide()
      } else {
        FavoriteListPresenter.getInstance().onPageShow()
      }
    }
  }

  pageTransition() {
    PageTransitionEnter({ duration: 100 })
    PageTransitionExit({ duration: 100 })
  }

  onPageShow() {
    this.mIndexPresenter.onPageShow();
    CallRecordPresenter.getInstance().setPageShow(this.bottomTabIndex == 0);
    ContactListPresenter.getInstance().setPageShow(this.bottomTabIndex == 1);
    if (this.bottomTabIndex == 2) {
      FavoriteListPresenter.getInstance().onPageShow();
    }
  }

  onPageHide() {
    ContactListPresenter.getInstance().setPageShow(false);
    CallRecordPresenter.getInstance().setPageShow(false);
    FavoriteListPresenter.getInstance().onPageHide();
  }

  aboutToAppear() {
    this.mPermissionManager.initPermissions();
    this.mIndexPresenter.aboutToAppear();
    this.getInfo();
    this.onIndexChanged();
    this.teleNumberChange()
    let innerEvent = {
      eventId: this.emitterId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEvent, (data) => {
      this.isContactSearch = data.data['isSearchPage'];
    })
  }

  aboutToDisappear() {
    this.mIndexPresenter.aboutToDisappear();
    emitter.off(this.emitterId);
  }

  onBackPress() {
    if (this.isContactSearch) {
      ContactListPresenter.getInstance().sendEmitter(false);
      return true;
    }
  }

  getInfo() {
    device.getInfo({
      success: function (data) {
        AppStorage.SetOrCreate('windowHeight', data.windowHeight / data.screenDensity)
      },
      fail: function (data, code) {
        HiLog.i(TAG, 'Failed to obtain device information. Error code:' + code + '; Error information: ' + data);
      },
    });
  }

  build() {
    if (this.mPermissionManager.isAllPermissionsGranted()) {
        Flex({
          direction: this.curBp === 'lg' ? FlexDirection.Row : FlexDirection.Column,
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start
        }) {
          if (this.curBp === 'lg') {
            TabBars({ controller: this.controller, bottomTabIndex: $bottomTabIndex })
              .visibility(this.isContactSearch ? Visibility.None : Visibility.Visible)
          }
          Tabs({
            barPosition: BarPosition.End,
            index: this.bottomTabIndex,
            controller: this.controller
          }) {
            if (this.curBp !== 'lg') {
              TabContent() {
                callPage()
              }
            } else {
              TabContent() {
                callTabletPage()
              }
            }
            TabContent() {
              contactPage()
            }
            TabContent() {
              favoritePage()
            }
          }
          .width(this.curBp === 'lg' ? null : '100%')
          .height(this.curBp === 'lg' ? '100%' : null)
          .vertical(false)
          .barMode(BarMode.Fixed)
          .barWidth(0)
          .barHeight(0)
          .scrollable(false)
          .animationDuration(0)
          .layoutWeight(1)

          if (this.curBp !== 'lg') {
            TabBars({ controller: this.controller, bottomTabIndex: $bottomTabIndex })
              .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
              .visibility(this.isContactSearch ? Visibility.None : Visibility.Visible)
          }
        }
        .backgroundColor($r('sys.color.ohos_fa_sub_background'))
        .width('100%')
        .height('100%')
      } else {
        Column()
          .width('100%')
          .height('100%')
    }
  }
}

@Component
struct TabBars {
  private tabSrc: number[] = call.hasVoiceCapability() ? [0, 1, 2] : [1];
  private controller: TabsController;
  @Link bottomTabIndex: number;
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance()
  @LocalStorageProp('breakpoint') curBp: string = 'sm'

  build() {
    Flex({
      direction: this.curBp === 'lg' ? FlexDirection.Column : FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      ForEach(this.tabSrc, item => {
        Column() {
          Column() {
            Image(this.mIndexPresenter.getTabSrc(this.bottomTabIndex, item))
              .objectFit(ImageFit.Contain)
              .width($r('app.float.id_card_image_small'))
              .height($r('app.float.id_card_image_small'))
              .fillColor(this.mIndexPresenter.getTabTextColor(this.bottomTabIndex, item))
            Text(this.mIndexPresenter.getTabText(this.bottomTabIndex, item))
              .fontWeight(FontWeight.Medium)
              .margin(this.curBp === 'lg' ?
                { top: $r('app.float.id_card_margin_mid') } : {})
              .fontSize($r('sys.float.ohos_id_text_size_caption'))
              .fontColor(this.mIndexPresenter.getTabTextColor(this.bottomTabIndex, item))
          }
          .onClick(() => {
            if (this.bottomTabIndex != item) {
              this.controller.changeIndex(item);
              this.bottomTabIndex = item;
              AppStorage.SetOrCreate('mainTabsIndex', item);
              if (item == 0) {
                ContactListPresenter.getInstance().setPageShow(false);
                CallRecordPresenter.getInstance().setPageShow(true);
                FavoriteListPresenter.getInstance().onPageHide();
              } else if (item == 1) {
                CallRecordPresenter.getInstance().setPageShow(false);
                ContactListPresenter.getInstance().setPageShow(true);
                FavoriteListPresenter.getInstance().onPageHide();
              } else if (item == 2) {
                CallRecordPresenter.getInstance().setPageShow(false);
                ContactListPresenter.getInstance().setPageShow(false);
                FavoriteListPresenter.getInstance().onPageShow();
              }
            }
          })
          .height($r('app.float.id_card_image_mid'))
        }
        .justifyContent(FlexAlign.Center)
        .height(this.curBp === 'lg' ?
          '130vp' : $r('app.float.id_item_height_large'))
        .layoutWeight(this.curBp === 'lg' ? 0 : 1)
      }, item => item.toString())
    }
    .width(this.curBp === 'lg' ?
      '96vp' : '100%')
    .height(this.curBp === 'lg' ?
      '100%' : $r('app.float.id_item_height_large'))
    .padding(this.curBp === 'lg' ?
      { left: $r('app.float.id_card_margin_max'), right: $r('app.float.id_card_margin_max') } : {})
  }
}