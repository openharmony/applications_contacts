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

import router from '@system.router';
import utils from '../../../util/Utils';
import detailModel from '../../../model/contactDetailModel';
import HiLog from '../../../util/HiLog';
import resourceManager from '@ohos.resourceManager';
import DetailCalllog from '../../../component/contactdetail/DetailCalllog'
import DetailInfoListView from '../../../component/contactdetail/DetailInfoListView'
import Constants, {DeviceType} from '../../../model/common/Constants'

const TAG = 'ContactDetail  ';

/**
 * 联系人详情 页面
 */
@Entry
@Component
struct ContactDetail {
  @State mDetailModel: typeof detailModel = detailModel;
  @State private mMoreMenu: any = [{
                                     value: "",
                                     action: () => {
                                     }
                                   }];
  @State hasFavorited: boolean = false;
  @State mSizeType: SizeType = Constants.deviceType == DeviceType.WGR ? SizeType.LG : SizeType.SM;
  @State mColumns: SizeType = Constants.deviceType == DeviceType.WGR ? 12 : 4;
  @State mGutter: SizeType = Constants.deviceType == DeviceType.WGR ? 12 : 24;
  @State mMargin: SizeType = Constants.deviceType == DeviceType.WGR ? 12 : 0;

  aboutToAppear() {
    // 根据不同情况初始化联系人详情数据 1.已有联系人(群组，收藏，联系人列表)：根据联系人ID从数据库获取详情数据
    //                            2.新增编辑联系人 :contacts已经传入只加载通话记录
    //                            3.未知联系人:未添加联系人且来自于通话记录跳转
    //                            (1)根据电话号码查询联系人id
    //                            (2)如果不存在联系人，则按照新号码处理，如果存在联系人，则根据第一个联系人id展示详情
    HiLog.i(TAG, 'aboutToAppear:');
    this.mDetailModel.isNewSource = router.getParams().isNewSource;
    this.mDetailModel.contactId = router.getParams().contactId;
    this.mDetailModel.sourceFromCallRecord = router.getParams().sourceFromCallRecord;
    this.mDetailModel.isNewNumber = router.getParams().isNewNumber;
    this.mDetailModel.phoneNumberShow = router.getParams().phoneNumberShow;
    this.mDetailModel.newNumberContactDetail = router.getParams().newNumberContactDetail;

    this.mDetailModel.onShow(() => {
      HiLog.i(TAG, 'aboutToAppear:callback')
      this.mDetailModel.flash++
    });
    this.getSettingsMenus();
  }

  onShow() {
  }

  /**
     *联系人右上角菜单初始化
     */
  getSettingsMenus() {
    let tmpMoreMenu = [];
    this.mDetailModel.moreMenuOptions.forEach(element => {
      tmpMoreMenu.push({});
    });
    this.mMoreMenu = tmpMoreMenu;
    resourceManager.getResourceManager().then(result => {
      this.mDetailModel.moreMenuOptions.forEach((element, i) => {
        result.getString(element.id, (err, typeName) => {
          HiLog.i(TAG, 'mDetailModel.moreMenuOptions')

          this.mMoreMenu[i] = {
            value: typeName,
            action: () => {
              switch (i) {
                case 0:
                  HiLog.i(TAG, 'deleteContact')
                  this.mDetailModel.deleteContact();
                  break;
              }
            }
          };
        });
      });
    });

  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      TopBar({ mDetailModel: $mDetailModel, moreMenu: $mMoreMenu });

      GridContainer({ columns: this.mColumns, sizeType: this.mSizeType, gutter: this.mGutter, margin: this.mMargin }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Content({ mDetailModel: $mDetailModel })
        }
        .useSizeType({
          xs: { span: 4, offset: 0 },
          sm: { span: 4, offset: 0 },
          md: { span: 8, offset: 0 },
          lg: { span: 8, offset: 2 },
        })
      }
      .width('100%')
      .margin({bottom: Constants.deviceType == DeviceType.PHONE ? '56vp' : 0})

      if(Constants.deviceType == DeviceType.PHONE) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
          Flex({ direction: FlexDirection.Row,wrap: FlexWrap.NoWrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
            Flex ({direction: FlexDirection.Column, alignItems: ItemAlign.Center}) {
              Image($r("app.media.ic_public_edit"))
                .objectFit(ImageFit.Contain)
                .height('24vp')
                .width('24vp')
              Text($r('app.string.edit'))
            }.width('50%')
            .onClick(() => {
              this.mDetailModel.updateContact();
            })
            if (!utils.isEmpty(this.mDetailModel.contactId)) {
              Flex({direction: FlexDirection.Column, alignItems: ItemAlign.Center}) {
                Image($r("app.media.ic_public_more"))
                  .objectFit(ImageFit.Contain)
                  .height('24vp')
                  .width('24vp')
                Text($r('app.string.More'))
              }.width('50%').bindMenu(this.mMoreMenu)

            } else {
              Flex({direction: FlexDirection.Column, alignItems: ItemAlign.Center}) {
                Image($r("app.media.ic_public_more"))
                  .objectFit(ImageFit.Contain)
                  .height('24vp')
                  .width('24vp')
                Text($r('app.string.More'))
              }.width('50%')

            }
          }.height('56vp')
          .width('100%')
        }
        .zIndex(3)

      }


    }
    .width('100%')
    .height('100%')
    .padding({ left: '12vp', right: '12vp' })
    //    .backgroundColor('#46B1E3')
    .backgroundColor(this.mDetailModel.contacts.detailsBgColor)
  }
}

@Component
struct Content {
  scroller: Scroller = new Scroller();
  @Link private mDetailModel: any;

  build() {
    Scroll(this.scroller) {
      Column() {
        // 上部背景和圆
        Stack({ alignContent: Alignment.Bottom }) {
          // 圆的圆心以下 的 白色背景
          Stack()
            .backgroundColor($r('app.color.white'))
            .width("100%")
            .height("51vp")

          //中部 圆 头像
          if (this.mDetailModel.contactForm.isNewNumber) {
            //            || this.mDetailModel.contactForm.namePrefix == '0'
            Image($r('app.media.defalut_user_light'))
              .backgroundColor($r('app.color.gray'))
              .height('100vp')
              .width('100vp')
              .clip(new Circle({ width: '100vp', height: '100vp' }))
              .border({ width: '4vp', color: Color.White, radius: '100vp' })
              .backgroundColor(this.mDetailModel.contacts.portraitColor)
          } else {
            Text(this.mDetailModel.contactForm.namePrefix)
              .fontSize('30vp')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.white'))
              .backgroundColor($r('app.color.gray'))
              .height('100vp')
              .width('100vp')
              .textAlign(TextAlign.Center)
              .clip(new Circle({ width: '100vp', height: '100vp' }))
              .border({ width: '4vp', color: Color.White, radius: '100vp' })
              .backgroundColor(this.mDetailModel.contacts.portraitColor)
          }
        }
        .width("100%")
        .height("267vp")

        Column() {
          // 名字
          Text((this.mDetailModel.showNameLast && this.mDetailModel.showNameLast.length > 0)
            ? this.mDetailModel.showNameLast : $r('app.string.noName'))
            .fontSize('24fp')
            .fontWeight(FontWeight.Bold)
            .margin({ top: '14vp', bottom: '4vp' })
            .width('100%')
            .textAlign(TextAlign.Center)

          if (!this.mDetailModel.contactForm.isNewNumber) {
            // 公司
            Row() {
              Text(this.mDetailModel.contactForm.company)
                .fontSize('14fp')
                .fontColor($r('app.color.gray'))
                .margin({ bottom: '4vp' })
                .visibility(utils.isEmpty(this.mDetailModel.contactForm.company) ? Visibility.None : Visibility.Visible)
              // 职务
              Text(this.mDetailModel.contactForm.position)
                .fontSize('14fp')
                .fontColor($r('app.color.gray'))
                .margin({ bottom: '4vp' })
                .visibility(utils.isEmpty(this.mDetailModel.contactForm.position) ? Visibility.None : Visibility.Visible)
            }
          }
          // 详细信息列表
          DetailInfoListView({ mDetailModel: $mDetailModel });
        }
        .width('100%')
        .backgroundColor($r('app.color.white'))
        .padding({ left: '24vp', right: '24vp' })

        // 通话记录
        DetailCalllog({ mDetailModel: $mDetailModel })
      }
      .width('100%')
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width("100%")
  }
}

/**
 * 底部栏
 */
@Component
struct BottomBar {
  @Link private mDetailModel: any;
  @Link private moreMenu: any;

  build() {
    if (this.mDetailModel.contactForm.showNewContact) {
      BottomBarB({ mDetailModel: $mDetailModel, moreMenu: $moreMenu });
    } else {
      BottomBarA({ mDetailModel: $mDetailModel, moreMenu: $moreMenu });
    }
  }
}

/**
 * 底部栏
 */
@Component
struct BottomBarA {
  @State hasFavorited: boolean = false;
  @Link private mDetailModel: any;
  @Link private moreMenu: any;

  build() {
    Flex({ alignItems: ItemAlign.Center }) {
      Column() {
        Image(this.hasFavorited ? $r('app.media.ic_contacts_favorite_filled_m') : $r('app.media.ic_contacts_favorite_filled_m_black'))
          .objectFit(ImageFit.Contain)
          .height(20)

        Text(this.hasFavorited ? $r('app.string.concal_favorite') : $r('app.string.favorite'))
          .fontSize(10)
          .fontColor(this.hasFavorited ? $r('app.color.font_hasFavorited') : $r('app.color.black'))
          .margin({ top: 5 })
      }
      .layoutWeight(1)
      .onClick(() => {
        //        this.mDetailModel.selectFavorite()
        this.hasFavorited = !this.hasFavorited;
      })

    }
    .height("60vp")
    .backgroundColor($r('app.color.white'))
    .onClick(() => {
      this.mDetailModel.showMoreMenuOperationSaveContacts();
    })
  }
}
/**
 * 底部栏 新号码（未保存）
 */
@Component
struct BottomBarB {
  @Link
  private mDetailModel: any;
  @Link private moreMenu: any;

  build() {
    Flex({ alignItems: ItemAlign.Center }) {
      Column() {
        Image($r('app.media.ic_public_add'))
          .objectFit(ImageFit.Contain)
          .height(20)

        Text($r('app.string.create_contact'))
          .fontSize(10)
          .margin({ top: 5 })
      }
      .layoutWeight(1)
      .onClick(() => {
        this.mDetailModel.addContacts();
      })

      Column() {
        Image($r('app.media.ic_contacts_name_m'))
          .objectFit(ImageFit.Contain)
          .height(20)

        Text($r('app.string.save_to_existing_contacts'))
          .fontSize(10)
          .margin({ top: 5 })
      }
      .layoutWeight(1)
      .onClick(() => {
        this.mDetailModel.sendNewContent();
      })
    }
    .height("60vp")
    .backgroundColor($r('app.color.white'))
    .onClick(() => {
      this.mDetailModel.showMoreMenuOperationNew();
    })
  }
}

/**
 * 头部栏
 */
@Component
struct TopBar {
  @State hasFavorited: boolean = false;
  @Link private mDetailModel: any;
  @Link private moreMenu: any;

  build() {
    Row() {
      Image($r("app.media.ic_public_back"))
        .objectFit(ImageFit.Contain)
        .height('24vp')
        .width('24vp')
        .margin({ left: '12vp' })
        .onClick(() => {
          router.back();
        })

      Text("name")
        .fontSize(18)
        .margin({ left: 10 })
        .visibility(Visibility.None)

      Blank()

      if(Constants.deviceType == DeviceType.WGR) {
        Image($r('app.media.ic_contacts_favorite_filled_m_black'))
          .objectFit(ImageFit.Contain)
          .height('24vp')
          .width('24vp')
          .margin({ left: '12vp', right: '12vp' })
          .onClick(() => {
            this.hasFavorited = !this.hasFavorited;
          })
        Image($r("app.media.ic_public_edit"))
          .objectFit(ImageFit.Contain)
          .height('24vp')
          .width('24vp')
          .margin({ left: '12vp', right: '12vp' })
          .onClick(() => {
            this.mDetailModel.updateContact();
          })

        if (!utils.isEmpty(this.mDetailModel.contactId)) {
          Image($r("app.media.ic_public_more"))
            .objectFit(ImageFit.Contain)
            .height('24vp')
            .width('24vp')
            .margin({ left: '12vp', right: '12vp' })
            .bindMenu(this.moreMenu)
        } else {
          Image($r("app.media.ic_public_more"))
            .objectFit(ImageFit.Contain)
            .height('24vp')
            .width('24vp')
            .margin({ left: '12vp', right: '12vp' })
        }
      }
    }
    .height("56vp")
    .width("100%")
    .position({ x: 0, y: 0 })
    .zIndex(3)
  }
}
