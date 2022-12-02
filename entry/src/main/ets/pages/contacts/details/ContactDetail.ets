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

import router from '@ohos.router';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import DetailPresenter from '../../../presenter/contact/detail/DetailPresenter';
import DetailCalllog from '../../../component/contactdetail/DetailCalllog';
import DetailInfoListView from '../../../component/contactdetail/DetailInfoListView';
import { SimCardState } from '../../../../../../../feature/phonenumber/src/main/ets/SimUtil';

const TAG = "ContactDetail";
let storage = LocalStorage.GetShared()

/**
 * Contact details page
 */
@Entry(storage)
@Component
struct ContactDetail {
  @State @Watch("onSimChanged") mSimCardState: SimCardState = SimCardState.getInstance();
  @State mPresenter: DetailPresenter = DetailPresenter.getInstance();
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  @State private mMoreMenu: Array<{
    value: string,
    action: () => void
  }> = [{
          value: "",
          action: () => {
          }
        }];
  @State hasFavorited: boolean = false;
  @State haveSimCard: boolean = this.mSimCardState.haveSimCard;
  @State isShow: number = 0;

  onSimChanged(): void {
    HiLog.i(TAG, "haveSimCard change:" + JSON.stringify(this.mSimCardState.haveSimCard));
    this.haveSimCard = this.mSimCardState.haveSimCard;
  }

  aboutToAppear() {
    setTimeout(() => {
      this.isShow++;
    }, 100);

    HiLog.i(TAG, 'aboutToAppear:');
    let obj: any = router.getParams();
    this.mSimCardState.getSimCardState();
    this.mSimCardState.addSimChangeListener();
    HiLog.i(TAG, 'ContactDetail addSimChangeListener:' + this.haveSimCard);
    this.mPresenter.sourceHasId = obj.sourceHasId;
    this.mPresenter.contactId = obj.contactId;
    this.mPresenter.sourceHasPhone = obj.sourceHasPhone;
    this.mPresenter.phoneNumberShow = obj.phoneNumberShow;
    this.mPresenter.aboutToAppear();
    this.mMoreMenu = this.mPresenter.getSettingsMenus();
  }

  aboutToDisappear() {
    this.mPresenter.aboutToDisappear();
  }

  @Builder MenuBuilder() {
    Column() {
      Text($r("app.string.delete_contact"))
        .fontSize($r("app.float.id_corner_radius_card_mid"))
        .textAlign(TextAlign.Start)
        .fontColor($r("sys.color.ohos_id_color_text_primary"))
        .lineHeight(19)
        .width($r("app.float.account_Divider_width"))
        .height(21)
        .onClick(() => {
          this.mPresenter.deleteContact();
        })
    }
    .width($r('app.float.account_MenuBuilder_width'))
    .justifyContent(FlexAlign.Center)
    .height($r("app.float.id_item_height_mid"))
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      TopBar({ mPresenter: $mPresenter, moreMenu: $mMoreMenu });

      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 8, lg: 8 }, offset: { sm: 0, md: 0, lg: 2 } }) {
          if (this.isShow > 0) {
            Content({ mPresenter: $mPresenter, haveSimCard: $haveSimCard })
          }
        }
      }
      .width('100%')
      .margin({ bottom: this.curBp === 'lg' ? 0 : $r("app.float.id_item_height_large") })

      if (this.curBp !== 'lg') {
        Row() {
          Column() {
            Image(this.mPresenter.contactId != undefined
              ? $r("app.media.ic_public_edit")
              : $r("app.media.ic_public_add"))
              .objectFit(ImageFit.Contain)
              .height($r("app.float.id_card_image_small"))
              .width($r("app.float.id_card_image_small"))
              .margin({ bottom: 3 })
            Text(this.mPresenter.contactId != undefined
              ? $r('app.string.edit')
              : $r("app.string.new_contact"))
          }
          .onClick(() => {
            this.mPresenter.updateContact();
          })
          .width(this.mPresenter.contactId != undefined ? '50%' : '100%')

          Column() {
            Image($r("app.media.ic_public_more"))
              .objectFit(ImageFit.Contain)
              .height($r("app.float.id_card_image_small"))
              .width($r("app.float.id_card_image_small"))
              .margin({ bottom: 3 })
              .bindMenu(this.MenuBuilder)
            Text($r('app.string.More'))
          }
          .visibility(this.mPresenter.contactId != undefined ? Visibility.Visible : Visibility.None)
          .width('50%')
        }
        .alignItems(VerticalAlign.Center)
        .height($r("app.float.id_item_height_large"))
        .width('100%')
        .backgroundColor(Color.White)
        .zIndex(3)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.mPresenter.contactForm.detailsBgColor)
  }
}

@Component
struct Content {
  @Link private mPresenter: { [key: string]: any };
  @Link haveSimCard: boolean;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';

  build() {
    List() {
      ListItem() {
        Column() {
          Stack({ alignContent: Alignment.Bottom }) {
            Stack()
              .backgroundColor(Color.White)
              .width("100%")
              .height("51vp")
              .clip(new Rect({ width: '100%', height: '51vp', radius: [[24, 24], [24, 24], [0, 0], [0, 0]] }))

            if (this.mPresenter.isNewNumber || this.mPresenter.contactForm.photoFirstName == '-1') {
              Image($r("app.media.ic_user_portrait"))
                .height('108vp')
                .width('108vp')
                .clip(new Circle({ width: '108vp', height: '108vp' }))
                .border({ width: '4vp', color: Color.White, radius: '100vp' })
                .backgroundColor(this.mPresenter.contactForm.portraitColor)
            } else {
              Text(this.mPresenter.contactForm.photoFirstName)
                .fontSize('40vp')
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .height('108vp')
                .width('108vp')
                .textAlign(TextAlign.Center)
                .clip(new Circle({ width: '108vp', height: '108vp' }))
                .border({ width: '4vp', color: Color.White, radius: '100vp' })
                .backgroundColor(this.mPresenter.contactForm.portraitColor)
            }
          }
          .width("100%")
          .height(this.curBp === 'lg' ? "267vp" : "260.5vp")

          Column() {
            Text(this.mPresenter.contactForm.display_name)
              .fontSize('24fp')
              .fontWeight(FontWeight.Medium)
              .margin({ top: '18vp', bottom: '4vp' })
              .width('100%')
              .textAlign(TextAlign.Center)

            Column() {
              if (!StringUtil.isEmpty(this.mPresenter.contactForm.company)) {
                Text(this.mPresenter.contactForm.company)
                  .fontSize($r("sys.float.ohos_id_text_size_body2"))
                  .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              if (!StringUtil.isEmpty(this.mPresenter.contactForm.position)) {
                Text(this.mPresenter.contactForm.position)
                  .fontSize($r("sys.float.ohos_id_text_size_body2"))
                  .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
            }

            DetailInfoListView({ mPresenter: $mPresenter, haveSimCard: $haveSimCard });
          }
          .width('100%')
          .backgroundColor(Color.White)
          .padding({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })

          DetailCalllog({ mPresenter: $mPresenter })
        }
      }
      .padding({ bottom: $r("app.float.id_card_margin_xxxxl") })
      .width("100%")
    }
  }
}

/**
 * top bar
 */
@Component
struct TopBar {
  @State hasFavorited: boolean = false;
  @Link private mPresenter: { [key: string]: any };
  @Link private moreMenu: { [key: string]: any };
  @LocalStorageProp('breakpoint') curBp: string = 'sm'

  @Builder MenuBuilder() {
    Column() {
      Text($r("app.string.delete_contact"))
        .fontSize($r("app.float.id_corner_radius_card_mid"))
        .textAlign(TextAlign.Start)
        .fontColor($r("sys.color.ohos_id_color_text_primary"))
        .lineHeight(19)
        .width($r("app.float.account_Divider_width"))
        .height(21)
        .onClick(() => {
          this.mPresenter.deleteContact();
        })
    }
    .width($r('app.float.account_MenuBuilder_width'))
    .justifyContent(FlexAlign.Center)
    .height($r("app.float.id_item_height_mid"))
  }

  build() {
    Row() {
      Image($r("app.media.ic_public_back"))
        .objectFit(ImageFit.Contain)
        .height($r("app.float.id_card_image_small"))
        .width($r("app.float.id_card_image_small"))
        .margin({ left: $r("app.float.id_card_margin_max") })
        .onClick(() => {
          HiLog.i(TAG, "点击返回");
          router.back();
        })

      Blank()

      if (this.curBp === 'lg') {
        Image(this.mPresenter.contactId != undefined
          ? $r("app.media.ic_public_edit")
          : $r("app.media.ic_public_add"))
          .objectFit(ImageFit.Contain)
          .height($r("app.float.id_card_image_small"))
          .width($r("app.float.id_card_image_small"))
          .margin({ right: $r("app.float.id_card_margin_max") })
          .onClick(() => {
            this.mPresenter.updateContact();
          })

        if (this.mPresenter.contactId != undefined) {
          Image($r("app.media.ic_public_more"))
            .objectFit(ImageFit.Contain)
            .height($r("app.float.id_card_image_small"))
            .width($r("app.float.id_card_image_small"))
            .margin({ right: $r("app.float.id_card_margin_max") })
            .bindMenu(this.MenuBuilder())
        } else {
          Image($r("app.media.ic_public_more"))
            .objectFit(ImageFit.Contain)
            .height($r("app.float.id_card_image_small"))
            .width($r("app.float.id_card_image_small"))
            .margin({ right: $r("app.float.id_card_margin_max") })
            .visibility(Visibility.None)
        }
      }
    }
    .height($r("app.float.id_item_height_large"))
    .width("100%")
    .position({ x: 0, y: 0 })
    .zIndex(3)
  }
}