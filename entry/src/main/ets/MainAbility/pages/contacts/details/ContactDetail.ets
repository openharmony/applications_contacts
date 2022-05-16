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
import StringUtil from '../../../util/StringUtil';
import ArrayUtil from '../../../util/ArrayUtil';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import detailModel from '../../../model/contactDetailModel';
import HiLog from '../../../util/HiLog';
import resourceManager from '@ohos.resourceManager';
import DetailCalllog from '../../../component/contactdetail/DetailCalllog';
import DetailInfoListView from '../../../component/contactdetail/DetailInfoListView';
import { DetailMenu } from '../../../component/contactdetail/DetailMenu';

const TAG = "ContactDetail";

/**
 * Contact details page
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
  @State mSizeType: SizeType = EnvironmentProp.isTablet() ? SizeType.LG : SizeType.SM;
  @State mColumns: SizeType = EnvironmentProp.isTablet() ? 12 : 4;
  @State mGutter: SizeType = EnvironmentProp.isTablet() ? 12 : 24;
  @State mMargin: SizeType = EnvironmentProp.isTablet() ? 0 : 0;

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear:');
    let obj: any = router.getParams();
    this.mDetailModel.sourceHasId = obj.sourceHasId;
    this.mDetailModel.contactId = obj.contactId;
    this.mDetailModel.sourceHasPhone = obj.sourceHasPhone;
    this.mDetailModel.phoneNumberShow = obj.phoneNumberShow;
    this.mDetailModel.onShow(() => {
      HiLog.i(TAG, 'aboutToAppear:callback')
    });
    this.getSettingsMenus();
  }

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
          Content({ mDetailModel: $mDetailModel})
        }
        .useSizeType({
          xs: { span: 4, offset: 0 },
          sm: { span: 4, offset: 0 },
          md: { span: 8, offset: 0 },
          lg: { span: 8, offset: 2 },
        })
      }
      .width('100%')
      .margin({ bottom: !EnvironmentProp.isTablet() ? $r("app.float.id_item_height_large") : 0 })

      if (!EnvironmentProp.isTablet()) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
          Flex({
            direction: FlexDirection.Row,
            wrap: FlexWrap.NoWrap,
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.Center
          }) {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
              Image($r("app.media.ic_public_edit"))
                .objectFit(ImageFit.Contain)
                .height($r("app.float.id_card_image_small"))
                .width($r("app.float.id_card_image_small"))
              Text($r('app.string.edit'))
            }.width('50%')
            .onClick(() => {
              this.mDetailModel.updateContact();
            })
            if (!StringUtil.isEmpty(this.mDetailModel.contactId)) {
              Flex({direction: FlexDirection.Column, alignItems: ItemAlign.Center}) {
                Image($r("app.media.ic_public_more"))
                  .objectFit(ImageFit.Contain)
                  .height($r("app.float.id_card_image_small"))
                  .width($r("app.float.id_card_image_small"))
                Text($r('app.string.More'))
              }.width('50%').bindMenu(this.mMoreMenu)

            } else {
              Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
                Image($r("app.media.ic_public_more"))
                  .objectFit(ImageFit.Contain)
                  .height($r("app.float.id_card_image_small"))
                  .width($r("app.float.id_card_image_small"))
                Text($r('app.string.More'))
              }.width('50%')

            }
          }.height($r("app.float.id_item_height_large"))
          .width('100%')
        }
        .zIndex(3)
      }
    }
    .width('100%')
    .height('100%')
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
        Stack({ alignContent: Alignment.Bottom }) {
          Stack()
            .backgroundColor(Color.White)
            .width("100%")
            .height("51vp")

          if (this.mDetailModel.isNewNumber || this.mDetailModel.contactForm.photoFirstName == '-1') {
            Image($r('app.media.ic_user_portrait'))
              .height('108vp')
              .width('108vp')
              .clip(new Circle({ width: '108vp', height: '108vp' }))
              .border({ width: '4vp', color: Color.White, radius: '100vp' })
              .backgroundColor(this.mDetailModel.contacts.portraitColor)
          } else {
            Text(this.mDetailModel.contactForm.photoFirstName)
              .fontSize('30vp')
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .height('108vp')
              .width('108vp')
              .textAlign(TextAlign.Center)
              .clip(new Circle({ width: '108vp', height: '108vp' }))
              .border({ width: '4vp', color: Color.White, radius: '100vp' })
              .backgroundColor(this.mDetailModel.contacts.portraitColor)
          }
        }
        .width("100%")
        .height("267vp")

        Column() {
          Text(this.mDetailModel.contactForm.display_name)
            .fontSize('24fp')
            .fontWeight(FontWeight.Bold)
            .margin({ top: '14vp', bottom: '4vp' })
            .width('100%')
            .textAlign(TextAlign.Center)

          if (!this.mDetailModel.isNewNumber) {
            Column() {
              if (!StringUtil.isEmpty(this.mDetailModel.contactForm.company)) {
                Text(this.mDetailModel.contactForm.company)
                  .fontSize($r("sys.float.ohos_id_text_size_body2"))
                  .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
              }
              if (!StringUtil.isEmpty(this.mDetailModel.contactForm.position)) {
                Text(this.mDetailModel.contactForm.position)
                  .fontSize($r("sys.float.ohos_id_text_size_body2"))
                  .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
              }
            }
          }
          DetailInfoListView({ mDetailModel: $mDetailModel });
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })

        if (!ArrayUtil.isEmpty(this.mDetailModel.contactForm.numRecords) && !this.mDetailModel.isCallLogClean) {
          DetailCalllog({ mDetailModel: $mDetailModel })
        }
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .padding({ bottom: $r("app.float.id_card_margin_xxxxl") })
    .width("100%")
  }
}

/**
 * top bar
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
        .height($r("app.float.id_card_image_small"))
        .width($r("app.float.id_card_image_small"))
        .margin({ left: $r("app.float.id_card_margin_max") })
        .onClick(() => {
          router.back();
        })

      Blank()

      if (EnvironmentProp.isTablet()) {
        Image($r('app.media.ic_contacts_favorite_filled_m_black'))
          .objectFit(ImageFit.Contain)
          .height($r("app.float.id_card_image_small"))
          .width($r("app.float.id_card_image_small"))
          .margin({ right: $r("app.float.id_card_margin_max") })
          .onClick(() => {
            this.hasFavorited = !this.hasFavorited;
          })
        Image($r("app.media.ic_public_edit"))
          .objectFit(ImageFit.Contain)
          .height($r("app.float.id_card_image_small"))
          .width($r("app.float.id_card_image_small"))
          .margin({ right: $r("app.float.id_card_margin_max") })
          .onClick(() => {
            this.mDetailModel.updateContact();
          })

        if (!StringUtil.isEmpty(this.mDetailModel.contactId)) {
          DetailMenu({menuItems: this.moreMenu,mDetailModel:$mDetailModel })
        } else {
          Image($r("app.media.ic_public_more"))
            .objectFit(ImageFit.Contain)
            .height($r("app.float.id_card_image_small"))
            .width($r("app.float.id_card_image_small"))
            .margin({ right: $r("app.float.id_card_margin_max") })
        }
      }
    }
    .height($r("app.float.id_item_height_large"))
    .width("100%")
    .position({ x: 0, y: 0 })
    .zIndex(3)
  }
}
