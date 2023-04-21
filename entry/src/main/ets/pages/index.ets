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
import callPage from './phone/dialer/Dialer';
import IndexPresenter from '../presenter/IndexPresenter';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { PermissionManager } from '../../../../../common/src/main/ets/permission/PermissionManager';
import DialerPresenter from '../presenter/dialer/DialerPresenter';
import call from '@ohos.telephony.call';
import ContactListPresenter from '../presenter/contact/ContactListPresenter';
import CallRecordPresenter from '../presenter/dialer/callRecord/CallRecordPresenter';
import device from '@system.device';

const TAG = 'Index ';

let storage = LocalStorage.GetShared()

@Entry(storage)
@Component
struct Index {
  private controller: TabsController = new TabsController();
  @State mPermissionManager: PermissionManager = PermissionManager.getInstance();
  @State @Watch("onIndexChanged") mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  mDialerPresenter: DialerPresenter = DialerPresenter.getInstance();
  @State bottomTabIndex: number = call.hasVoiceCapability() ? 0 : 1;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';

  onIndexChanged(): void {
    HiLog.i(TAG, "uriTabIndex change:" + JSON.stringify(this.mIndexPresenter.tabsIndex));
    this.controller.changeIndex(this.mIndexPresenter.tabsIndex);
    this.bottomTabIndex = this.mIndexPresenter.tabsIndex;
    this.mDialerPresenter.editPhoneNumber(this.mIndexPresenter.editPhoneNumber);
    if (this.mIndexPresenter.tabsIndex == 0) {
      ContactListPresenter.getInstance().setPageShow(false);
      CallRecordPresenter.getInstance().setPageShow(true);
    } else {
      CallRecordPresenter.getInstance().setPageShow(false);
      ContactListPresenter.getInstance().setPageShow(true);
    }
  }

  pageTransition() {
    PageTransitionEnter({ duration: 100 })
    PageTransitionExit({ duration: 100 })
  }

  onPageShow() {
    this.mIndexPresenter.onPageShow();
    if (this.bottomTabIndex == 0) {
      ContactListPresenter.getInstance().setPageShow(false);
      CallRecordPresenter.getInstance().setPageShow(true);
    } else {
      CallRecordPresenter.getInstance().setPageShow(false);
      ContactListPresenter.getInstance().setPageShow(true);
    }
  }

  onPageHide() {
    ContactListPresenter.getInstance().setPageShow(false);
    CallRecordPresenter.getInstance().setPageShow(false);
  }

  aboutToAppear() {
    this.mPermissionManager.initPermissions();
    this.mIndexPresenter.aboutToAppear();
    this.getInfo();
  }

  aboutToDisappear() {
    this.mIndexPresenter.aboutToDisappear();
  }

  getInfo() {
    device.getInfo({
      success: function (data) {
        AppStorage.SetOrCreate("windowHeight", data.windowHeight / data.screenDensity)
      },
      fail: function (data, code) {
        HiLog.i(TAG, 'Failed to obtain device information. Error code:' + code + '; Error information: ' + data);
      },
    });
  }

  build() {
    Column() {
      if (this.mPermissionManager.isAllPermissionsGranted()) {
        Flex({
          direction: this.curBp === 'lg' ? FlexDirection.Row : FlexDirection.Column,
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start
        }) {
          if (this.curBp === 'lg') {
            Column() {
              TabBars({ controller: this.controller, bottomTabIndex: $bottomTabIndex })
            }
            .height('100%')
            .zIndex(3)
          }
          Column() {
            Tabs({
              barPosition: this.curBp === 'lg' ? BarPosition.Start : BarPosition.End,
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
            }
            .width('100%')
            .vertical(false)
            .barMode(BarMode.Fixed)
            .barWidth(0)
            .barHeight(0)
            .scrollable(false)
            .animationDuration(0)
          }
          .layoutWeight(this.curBp === 'lg' ? 1 : 0)
          .flexShrink(this.curBp === 'lg' ? 0 : 1)
          .height(this.curBp === 'lg' ? '100%' : null)
          .width(this.curBp === 'lg' ? 0 : '100%')

          if (this.curBp !== 'lg') {
            Column() {
              TabBars({ controller: this.controller, bottomTabIndex: $bottomTabIndex })
            }
            .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
            .width('100%')
            .height($r("app.float.id_item_height_large"))
            .flexShrink(0)
          }
        }
        .backgroundColor($r("sys.color.ohos_fa_sub_background"))
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct TabBars {
  private tabSrc: number[] = [0, 1];
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
        if (!((!call.hasVoiceCapability()) && item === 0)) {
          Column() {
            Column() {
              Image(this.mIndexPresenter.getTabSrc(this.bottomTabIndex, item))
                .objectFit(ImageFit.Contain)
                .width($r("app.float.id_card_image_small"))
                .height($r("app.float.id_card_image_small"))
                .fillColor(this.mIndexPresenter.getTabTextColor(this.bottomTabIndex, item))
              Text(this.mIndexPresenter.getTabText(this.bottomTabIndex, item))
                .fontWeight(FontWeight.Medium)
                .margin(this.curBp === 'lg' ?
                  { top: $r("app.float.id_card_margin_mid") } : {})
                .fontSize($r("sys.float.ohos_id_text_size_caption"))
                .fontColor(this.mIndexPresenter.getTabTextColor(this.bottomTabIndex, item))
            }
            .onClick(() => {
              if (this.bottomTabIndex != item) {
                this.controller.changeIndex(item);
                this.bottomTabIndex = item;
                this.mIndexPresenter.tabsIndex = item;
                if (item == 0) {
                  ContactListPresenter.getInstance().setPageShow(false);
                  CallRecordPresenter.getInstance().setPageShow(true);
                } else if (item == 1) {
                  CallRecordPresenter.getInstance().setPageShow(false);
                  ContactListPresenter.getInstance().setPageShow(true);
                }
              }
            })
            .width($r("app.float.id_card_image_mid"))
            .height($r("app.float.id_card_image_mid"))
          }
          .justifyContent(FlexAlign.Center)
          .height(this.curBp === 'lg' ?
            '130vp' : $r("app.float.id_item_height_large"))
          .layoutWeight(this.curBp === 'lg' ? 0 : 1)
        }
      }, item => item.toString())
    }
    .width(this.curBp === 'lg' ?
      '96vp' : '100%')
    .height(this.curBp === 'lg' ?
      '100%' : $r("app.float.id_item_height_large"))
    .padding(this.curBp === 'lg' ?
      { left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") } : {})
  }
}