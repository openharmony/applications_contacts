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
import callTabletPage from './dialer/dialerTablet';
import contactPage from './contacts/ContactList';
import callPage from './phone/dialer/Dialer';
import {HorizontalTabs} from './navigation/Navigation';
import {VerticalTabs} from './navigation/Navigation';
import {IndexPresenter, PermissionsManage} from '../presenter/IndexPresenter';
import HiLog from '../util/HiLog';
import Constants from '../model/common/Constants';
import EnvironmentProp from './../feature/EnvironmentProp'
import DialerPresenter from '../presenter/dialer/DialerPresenter';

const TAG = 'Index ';

@Entry
@Component
struct Index {
  private controller: TabsController = new TabsController();
  @State mPermissionsManage: PermissionsManage = PermissionsManage.getInstance();
  @State @Watch("onIndexChanged") mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  mDialerPresenter: DialerPresenter = DialerPresenter.getInstance();
  @State bottomTabIndex: number = 0;

  onIndexChanged(): void {
    HiLog.i(TAG, "uriTabIndex change:" + JSON.stringify(this.mIndexPresenter.tabsIndex));
    this.controller.changeIndex(this.mIndexPresenter.tabsIndex)
    this.bottomTabIndex = this.mIndexPresenter.tabsIndex;
    this.mDialerPresenter.editPhoneNumber(this.mIndexPresenter.editPhoneNumber)
  }

  onPageShow() {
    this.mIndexPresenter.onPageShow();
  }

  aboutToAppear() {
    this.mPermissionsManage.initPermissions();
    this.mIndexPresenter.aboutToAppear();
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      if (this.mPermissionsManage.applyFlag) {
        if (!EnvironmentProp.isTablet()) {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
              Tabs({ barPosition: BarPosition.End, index: this.bottomTabIndex, controller: this.controller }) {

                TabContent() {
                  callPage()
                }

                TabContent() {
                  contactPage()
                }
              }
              .onChange((index: number) => {
                HiLog.i(TAG, 'onChange' + index)
                this.bottomTabIndex = index
              })
              .width('100%')
              .vertical(false)
              .barMode(BarMode.Fixed)
              .barWidth(0)
              .barHeight(0)
              .scrollable(false)
              .animationDuration(0)

            }
            .flexShrink(1)
            .width('100%')

            Column() {
              HorizontalTabs({ controller: this.controller, bottomTabIndex: $bottomTabIndex })
            }
            .width('100%')
            .height($r("app.float.id_item_height_large"))
            .flexShrink(0)
          }
          .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
          .width('100%')
          .height('100%')
        } else {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
            Column() {
              VerticalTabs({ controller: this.controller, bottomTabIndex: $bottomTabIndex })
            }
            .alignItems(HorizontalAlign.Start)
            .height('100%')
            .zIndex(3)

            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
              Tabs({ barPosition: BarPosition.Start, index: this.bottomTabIndex, controller: this.controller }) {

                TabContent() {
                  callTabletPage()
                }

                TabContent() {
                  contactPage()
                }
              }
              .onChange((index: number) => {
                HiLog.i(TAG, 'onChange' + index)
                this.bottomTabIndex = index
              })
              .width('100%')
              .vertical(true)
              .barMode(BarMode.Fixed)
              .barWidth(0)
              .barHeight(0)
              .scrollable(false)
              .animationDuration(0)
            }
            .layoutWeight(1)
            .height('100%')
          }
          .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
          .width('100%')
          .height('100%')
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}