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

import ContactEmptyPage from '../../component/contact/ContactEmptyPage';
import ContactListItemView from '../../component/contact/ContactListItemView';
import {ContactVo} from '../../model/bean/ContactVo';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import HiLog from '../../util/HiLog';
import resourceManager from '@ohos.resourceManager';
import Constants, {DeviceType} from '../../model/common/Constants';

const TAG = 'ContactList  ';

/**
 * 联系人列表界面
 */
@Entry
@Component
export default struct ContactListPage {
  @State mContactPresenter: ContactListPresenter = ContactListPresenter.getInstance();
  @State private mIsSearched: boolean = false;
  @State private mContactMenu: any = [{
                                        value: "",
                                        action: () => {
                                        }
                                      }];
  @State mSizeType: SizeType = Constants.deviceType == DeviceType.WGR ? SizeType.LG : SizeType.SM;
  @State mColumns: number = Constants.deviceType == DeviceType.WGR ? 12 : 4;
  @State mGutter: number = Constants.deviceType == DeviceType.WGR ? 12 : 24;
  @State mMargin: number = Constants.deviceType == DeviceType.WGR ? 12 : 0;
  @State mBackgroudColor: string = (Constants.deviceType == DeviceType.WGR) ? '#F1F3F5' : '#FFF';

  aboutToAppear() {
    HiLog.i(TAG, 'Contact aboutToAppear!');
    this.mContactPresenter.aboutToAppear();
    this.getSettingsMenus();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Contact aboutToDisappear!');
    this.mContactPresenter.aboutToDisappear();
  }

  /**
     * 当此页面显示时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
     */
  onPageShow() {
    HiLog.i(TAG, 'onPageShow')
    this.mContactPresenter.onPageShow()
  }

  /**
   * 当此页面消失时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageHide() {
    HiLog.i(TAG, 'onPageHide')
    this.mContactPresenter.onPageHide()
  }

  /**
     *联系人右上角菜单初始化
     */
  getSettingsMenus() {
    let tmpPhoneMenu = [];
    this.mContactPresenter.settingsMenu.forEach(element => {
      tmpPhoneMenu.push({});
    });
    this.mContactMenu = tmpPhoneMenu;
    resourceManager.getResourceManager().then(result => {
      this.mContactPresenter.settingsMenu.forEach((element, i) => {
        result.getString(element.id, (err, typeName) => {
          HiLog.i(TAG, typeName);
          this.mContactMenu[i] = {
            value: typeName,
            action: () => {
            }
          };
        });
      });
    });
  }

  build() {
    Stack() {
      GridContainer({ columns: this.mColumns, sizeType: this.mSizeType, gutter: this.mGutter, margin: this.mMargin }) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
          TitleGuide({ presenter: this.mContactPresenter, contactMenu: this.mContactMenu })

          if (this.mContactPresenter.contactList.length > 0) {
            ContactContent({
              presenter: $mContactPresenter,
              isSearched: $mIsSearched
            })
          } else {
            ContactEmptyPage({ presenter: this.mContactPresenter })
          }
        }
        .height('100%')
        .useSizeType({
          xs: { span: 8, offset: 2 },
          sm: { span: 4, offset: 0 },
          md: { span: 8, offset: 2 },
          lg: { span: 8, offset: 2 }
        })
      }
    }
    .backgroundColor(this.mBackgroudColor)
    .width('100%')
    .height('100%')
  }
}

@Component
struct TitleGuide {
  private presenter: ContactListPresenter;
  private contactMenu: any;

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
      Image($r("app.media.ic_public_add"))
        .width($r("app.float.contact_samll_image_width_height"))
        .height($r("app.float.contact_samll_image_width_height"))
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          HiLog.i(TAG, 'add contact')
          this.presenter.createContact();
        })

      Image($r("app.media.ic_public_more"))
        .width($r("app.float.contact_samll_image_width_height"))
        .height($r("app.float.contact_samll_image_width_height"))
        .objectFit(ImageFit.Contain)
        .margin({ left: $r("app.float.common_margin"), right: $r("app.float.common_margin") })
      //        .bindMenu(this.contactMenu)
    }
    .height($r("app.float.contact_titleguide_height"))
    .width('100%')
  }
}

@Component
struct ContactContent {
  @Link private presenter: ContactListPresenter;
  @Link private isSearched: boolean;

  @Builder
  GroupsView(imageRes: Resource, title: string | Resource, showArrow: boolean) {
    Row() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
        Image(imageRes)
          .width(40)
          .height(40)
          .objectFit(ImageFit.Contain)
          .margin({ left: $r("app.float.common_margin"), right: 16 })

        Text(title)
          .fontSize($r("app.float.contact_text_size_body1"))
          .fontWeight(FontWeight.Medium)
            //                      .fontColor($r("app.color.textColorPrimary"))
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        Image($r("app.media.ic_contacts_arrow_up"))
          .width(12)
          .height(24)
          .objectFit(ImageFit.Contain)
          .margin({ right: $r("app.float.common_margin") })

      }
    }
    .width('100%')
    .height($r("app.float.contact_listitem_height"))
    .backgroundColor(Color.White)
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
        Text($r("app.string.contact"))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
            //          .fontColor($r("app.color.textColorPrimary"))
          .fontColor('#182431')
          .margin({ left: $r("app.float.common_margin"), right: $r("app.float.common_margin"), bottom: 2 })
          .height($r("app.float.contact_title_height"))

        Text($r("app.string.contact_num", this.presenter.contactList.length))
          .fontSize($r("app.float.contact_text_size_body2"))
          .fontWeight(FontWeight.Regular)
            //          .fontColor($r("app.color.textColorTertiary"))
          .fontColor("#66182431")
          .margin({ left: $r("app.float.common_margin"), right: $r("app.float.common_margin") })
          .height(19)
      }
      .height(82)

      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.presenter.contactList, (item, index) => {

          // 判断当前item是否为第一个 或与上一个item的namePrefix不同，则插入字母前缀
          if (index == 0 || !(item.namePrefix == this.presenter.contactList[index-1].namePrefix)) {
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
            ContactListItemView({ item: item, index: index })
          }

          // 判断item前缀是否与下一个item前缀相同 相同则插入divider
          if (index < this.presenter.contactList.length - 1 && item.namePrefix == this.presenter.contactList[index+1].namePrefix) {
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
        }, (item: ContactVo) => item.contactId.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}