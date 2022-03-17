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

import BatchSelectContactsPresenter from '../../../presenter/contact/batchselectcontacts/BatchSelectContactsPresenter';
import HiLog from '../../../util/HiLog';
import Utils from '../../../util/Utils';
import BatchSelectRecentItemView from '../../../component/contact/batchselectcontacts/BatchSelectRecentItemView';
import BatchSelectContactItemView from '../../../component/contact/batchselectcontacts/BatchSelectContactItemView';
import BatchTabGuide from '../../../component/contact/batchselectcontacts/BatchTabGuide';
import util from '../../../util/Utils';
import {CallBean} from '../../../model/bean/CallBean';
import {ContactVo} from '../../../model/bean/ContactVo';
import Constants, {DeviceType} from '../../../model/common/Constants';

const TAG = 'BatchSelectContactsPage ';

/**
 * 短信选择联系人列表界面
 */
@Entry
@Component
export default struct BatchSelectContactsPage {
  @State mPresenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();
  @State mSizeType: SizeType = Constants.deviceType == DeviceType.WGR ? SizeType.LG : SizeType.SM;
  @State mColumns: number = Constants.deviceType == DeviceType.WGR ? 12 : 4;
  @State mGutter: number = Constants.deviceType == DeviceType.WGR ? 12 : 24;
  @State mMargin: number = Constants.deviceType == DeviceType.WGR ? 12 : 0;

  /**
   * 函数在创建自定义组件的新实例后，在执行其build函数之前执行。
   * 允许在aboutToAppear函数中改变状态变量，这些更改将在后续执行build函数中生效。
   */
  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear')
    this.mPresenter.aboutToAppear()
  }

  /**
   * 函数在自定义组件析构消耗之前执行。
   * 不允许在aboutToDisappear函数中改变状态变量，特别是@Link变量的修改可能会导致应用程序行为不稳定。
   */
  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear')
    this.mPresenter.aboutToDisappear()
  }

  /**
   * 当此页面显示时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageShow() {
    HiLog.i(TAG, 'onPageShow')
    this.mPresenter.onPageShow()
  }

  /**
   * 当此页面消失时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageHide() {
    HiLog.i(TAG, 'onPageHide')
    this.mPresenter.onPageHide()
  }

  /**
   * 当用户点击返回按钮时触发，，仅@Entry修饰的自定义组件生效。
   * 返回true表示页面自己处理返回逻辑, 不进行页面路由。
   * 返回false表示使用默认的返回逻辑。
   * 不返回值会作为false处理。
   */
  onBackPress() {
    return false;
  }

  build() {
    Column() {
      GridContainer({ columns: this.mColumns, sizeType: this.mSizeType, gutter: this.mGutter, margin: this.mMargin }) {
        Flex({ direction: FlexDirection.Column }) {
          Row() {
            Flex({ direction: FlexDirection.Row,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center }) {
              //cancel img
              Image($r("app.media.ic_public_cancel"))
                .height($r("app.float.contact_samll_image_width_height"))
                .width($r("app.float.contact_samll_image_width_height"))
                .margin({ left: $r("app.float.common_margin") })
                .onClick(() => {
                  this.mPresenter.cancel()
                })

              Text(this.mPresenter.selectCount == 0 ? $r('app.string.no_select') : $r('app.string.select_num', this.mPresenter.selectCount))
                .textAlign(TextAlign.Start)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                  //          .fontColor($r("app.color.textColorPrimary"))
                .fontColor('#182431')
                .margin({ left: $r("app.float.common_margin_16") })
                .height($r("app.float.contact_batchselect_title_height"))
                .layoutWeight(1)

              //comfirm img
              Image($r("app.media.ic_public_ok"))
                .height($r("app.float.contact_samll_image_width_height"))
                .width($r("app.float.contact_samll_image_width_height"))
                .margin({ right: $r("app.float.common_margin") })
                .onClick(() => {
                  this.mPresenter.comfirm()
                })

              if (Constants.deviceType == DeviceType.WGR) {
                Image($r("app.media.ic_public_select_all"))
                  .width($r("app.float.contact_samll_image_width_height"))
                  .height($r("app.float.contact_samll_image_width_height"))
                  .objectFit(ImageFit.Contain)
                  .margin({ right: $r("app.float.common_margin") })
                  .onClick((event: ClickEvent) => {
                    HiLog.i(TAG, 'clickSelectAll clicked!')
                    this.mPresenter.clickSelectAll();
                  })
              }
            }
            .width('100%')
            .height($r("app.float.contact_titleguide_height"))
          }
          .height($r("app.float.contact_titleguide_height"))
          .useSizeType({
            xs: { span: 12, offset: 0 },
            sm: { span: 4, offset: 0 },
            md: { span: 12, offset: 0 },
            lg: { span: 12, offset: 0 }
          })

          Column() {
            BatchTabGuide({ currentIndex: $currentIndex, controller: this.controller })

            Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
              TabContent() {
                if (util.isEmptyList(this.mPresenter.callLogTemp)) {
                  NoContactsEmptyView()
                } else {
                  RecentList({
                    presenter: $mPresenter
                  })
                }
              }

              TabContent() {
                if (util.isEmptyList(this.mPresenter.contactsList)) {
                  NoContactsEmptyView()
                } else {
                  ContactsList({
                    presenter: $mPresenter
                  })
                }
              }
            }
            .vertical(false)
            .scrollable(true)
            .barMode(BarMode.Fixed)
            .barWidth(0)
            .barHeight(0)
            .animationDuration(200)
            .onChange((index: number) => {
              HiLog.i(TAG, index.toString());
              this.currentIndex = index;
              this.mPresenter.onTabChange(index);
            })
            .margin({ top: 8 })
          }
          .flexGrow(1)
          .useSizeType({
            xs: { span: 8, offset: 2 },
            sm: { span: 4, offset: 0 },
            md: { span: 8, offset: 2 },
            lg: { span: 8, offset: 2 }
          })

          if (Constants.deviceType == DeviceType.PHONE) {
            Flex({
              direction: FlexDirection.Column,
              justifyContent: FlexAlign.Center,
              alignItems: ItemAlign.Center
            }) {
              Image($r("app.media.ic_public_select_all"))
                .width($r("app.float.contact_samll_image_width_height"))
                .height($r("app.float.contact_samll_image_width_height"))
                .objectFit(ImageFit.Contain)

              Text($r("app.string.select_all"))
                .height(14)
                .margin({ top: 3 })
                .fontSize(10)
                  //              .fontColor($r("app.color.textColorPrimary"))
                .fontColor("#182431")
                .fontWeight(FontWeight.Medium)
            }
            .height($r("app.float.contact_titleguide_height"))
            .useSizeType({
              xs: { span: 8, offset: 2 },
              sm: { span: 4, offset: 0 },
              md: { span: 8, offset: 2 },
              lg: { span: 8, offset: 2 }
            })
            .onClick((event: ClickEvent) => {
              HiLog.i(TAG, 'clickSelectAll clicked!')
              this.mPresenter.clickSelectAll();
            })
          }
        }
        .width("100%")
        .height("100%")
        .backgroundColor('#F1F3F5')
      }
      .width("100%")
      .height("100%")
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct RecentList {
  @Link presenter: BatchSelectContactsPresenter;

  build() {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.presenter.callLogTemp, (item, index) => {
          // 插入联系人item
          ListItem() {
            BatchSelectRecentItemView({
              item: item,
              index: index,
              onRecentItemClicked: (index) => this.presenter.onRecentItemClicked(index)
            })
          }

          if (!util.isEmptyList(this.presenter.callLogTemp) && index != this.presenter.callLogTemp.length - 1) {
            ListItem() {
              Row() {
                Divider()
                  .vertical(false)
                  .strokeWidth('0.5vp')
                  .color('#F1F3F5')
                  .margin({ left: 76, right: $r("app.float.common_margin") })
              }
              .width('100%')
              .height('0.5')
              .backgroundColor(Color.White)
            }
          }
        }, (item) => item.id.toString())
      }
      .width('100%')
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({ top: 4, bottom: 4 })
    .borderRadius($r("app.float.contact_list_groups_radius"))
  }
}

@Component
struct ContactsList {
  @Link presenter: BatchSelectContactsPresenter;

  build() {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.presenter.contactsList, (item, index) => {
          // 判断当前item是否为第一个 或与上一个item的namePrefix不同，则插入字母前缀
          if (index == 0 || !(item.namePrefix == this.presenter.contactsList[index-1].namePrefix)) {
            ListItem() {
              Text(item.namePrefix)
                .fontColor(Color.Black)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .height($r("app.float.contact_listitem_index_height"))
                .textAlign(TextAlign.End)
                .padding({ top: 5 })
            }.margin({ left: $r("app.float.common_margin") })
          }

          // 插入联系人item
          ListItem() {
            BatchSelectContactItemView({
              item: item,
              index: index,
              onContactItemClicked: (index, indexChild) => this.presenter.onContactItemClicked(index, indexChild)
            })
          }

          if (!util.isEmptyList(this.presenter.contactsList) && index != this.presenter.contactsList.length - 1) {
            ListItem() {
              Row() {
                Divider()
                  .vertical(false)
                  .strokeWidth('0.5vp')
                  .color('#F1F3F5')
                  .margin({ left: 76, right: $r("app.float.common_margin") })
              }
              .width('100%')
              .height('0.5')
              .backgroundColor(Color.White)
            }
          }
        }, (item) => item.contactId.toString())
      }
      .width('100%')
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
  }
}

@Component
struct GroupsList {
  @State presenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();

  build() {

  }
}

@Component
struct NoContactsEmptyView {
  @State presenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();

  build() {
    Flex({ direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center }) {
      Image($r("app.media.no_contacts_illustration"))
        .width($r("app.float.contact_emptyview_image_width_height"))
        .height($r("app.float.contact_emptyview_image_width_height"))
        .objectFit(ImageFit.Contain)
        .margin({ bottom: 8 })

      Text(this.presenter.getEmptyText())
        .fontSize($r("app.float.contact_text_size_body2"))
        .fontWeight(FontWeight.Regular)
          //          .fontColor($r("app.color.textColorTertiary"))
        .fontColor('#66182431')
        .height(19)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}