/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { SelectDialogBuilder } from '../../component/mutisim/SelectSimIdDialog';
import { SelectMultiNumDialog } from '../dialog/SelectMultiNumDialog';
import { SelectNumDialogBuilder } from '../dialog/SelectMultiNumDialog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog, sharedPreferencesUtils } from '../../../../../../common';
import FavoriteListPresenter from '../../presenter/favorite/FavoriteListPresenter';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import ContactAbilityModel from '../../model/ContactAbilityModel';
import emitter from '@ohos.events.emitter';
import { Phone } from '../../../../../../feature/contact/src/main/ets/contract/Phone';
import prompt from '@ohos.prompt';

const TAG = 'FavoriteList';

@Entry
@Component
export default struct FavoriteList {
  @State mFavoriteListPresenter: FavoriteListPresenter = FavoriteListPresenter.getInstance();
  @State isEdit: boolean = false;
  @State favoriteListListLen: number = 0;
  emitterId: number = 100;

  aboutToAppear() {
    HiLog.i(TAG, 'Favorite aboutToAppear!');
    this.mFavoriteListPresenter.aboutToAppear();
    let innerEvent = {
      eventId: this.emitterId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEvent, (data) => {
      this.favoriteListListLen = data.data['favoriteListListLen'];
    })
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Favorite aboutToDisappear!');
    this.mFavoriteListPresenter.aboutToDisappear();
  }

  onPageShow() {
    HiLog.i(TAG, 'Favorite onPageShow');
    this.mFavoriteListPresenter.onPageShow();
  }

  onPageHide() {
    HiLog.i(TAG, 'Favorite onPageHide');
    this.mFavoriteListPresenter.onPageHide();
  }

  build() {
    if (this.favoriteListListLen === 0) {
      FavoriteEmptyPage({ presenter: $mFavoriteListPresenter, isEdit: $isEdit });
    } else {
      FavoriteContent({ presenter: $mFavoriteListPresenter });
    }
  }
}

@Component
struct FavoriteContent {
  @Link presenter: FavoriteListPresenter;
  @State mPresenter: FavoriteListPresenter = this.presenter;
  isUsuallyShow: boolean = false;

  build() {
     Column() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
          TitleGuide({ mPresenter: $mPresenter });
        }
        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 2, lg: 4 } }) {
          Column() {
            Text($r('app.string.favorite'))
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .margin({ bottom: $r('app.float.id_card_margin_sm') })
              .lineHeight(42)
              .margin({ top: 8, bottom: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .height(82)
        }
      }
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
          List({ space: 0, initialIndex: 0 }) {
            LazyForEach(this.presenter.favoriteDataSource, (item, index: number) => {
              ListItem() {
                FavoriteListItem({ presenter: $mPresenter, item: item, mPresenter: $presenter });
              }
            }, (item) => JSON.stringify(item))
          }
          .scrollBar(BarState.Off)
          .editMode(true)
          .width('100%')
          .height('100%')
          .listDirection(Axis.Vertical)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .height('100%')
      .flexShrink(1)
    }
    .padding({ left: 24, right: 24 })
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White)

  }
}

@Component
export struct FavoriteListItem {
  @Link presenter: FavoriteListPresenter;
  @Link private mPresenter: { [key: string]: any };
  @State selectSimBuilder: SelectDialogBuilder = {
    title: 'test title',
    multiSimCardItems: [],
  };
  @State item: { [key: string]: any } = {};;
  @State builder: SelectNumDialogBuilder = {
    title: $r('app.string.contacts_call'),
    multiNumCardItems: [],
    contactId: ''
  };
  mSelectSlotIdDialog: CustomDialogController = new CustomDialogController({
    builder: SelectMultiNumDialog({
      builder: $builder
    }),
    customStyle: false,
    autoCancel: true,
    alignment: DialogAlignment.Bottom
  })
  @State isEmergencyNum: boolean = false;
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;

  aboutToDisappear() {
    this.mSelectSlotIdDialog = null;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        if (1 === this.item.favorite.isCommonUseType) {
          Text($r('app.string.common_use'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Regular)
            .fontColor('#666666')
            .margin({ top: $r('app.float.id_card_margin_xxl') })
            .textAlign(TextAlign.Center)
            .borderRadius($r('app.float.id_card_image_mid'))
            .visibility(this.item.favorite.isUsuallyShow ? Visibility.Visible : Visibility.None)
        }
        Row() {
          Flex({
            direction: FlexDirection.Row,
            justifyContent: FlexAlign.SpaceBetween,
            alignItems: ItemAlign.Stretch
          }) {
            Row() {
              Row() {
                if (StringUtil.isEmpty(this.item.favorite.nameSuffix)) {
                  Image(StringUtil.isEmpty(this.item.favorite.portraitPath) ? $r('app.media.ic_user_portrait') : this.item.favorite.portraitPath)
                    .width($r('app.float.id_card_image_mid'))
                    .height($r('app.float.id_card_image_mid'))
                    .objectFit(ImageFit.Contain)
                    .borderRadius($r('app.float.id_card_image_mid'))
                    .backgroundColor(this.item.favorite.portraitColor)
                } else {
                  Text(this.item.favorite.namePrefix.toUpperCase())
                    .fontSize(30)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                    .backgroundColor(this.item.favorite.portraitColor)
                    .height($r('app.float.id_card_image_mid'))
                    .width($r('app.float.id_card_image_mid'))
                    .textAlign(TextAlign.Center)
                    .borderRadius($r('app.float.id_card_image_mid'))
                }
              }
              .height($r('app.float.id_card_image_mid'))
              .width($r('app.float.id_card_image_mid'))
              if (0 === this.item.favorite.isCommonUseType) {
                Text(this.item.favorite.displayName)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.Black)
                  .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                  .margin({ left: $r('app.float.dialer_common_small_margin') })
                  .textAlign(TextAlign.Start)
                  .width('83%')
              } else {
                Column() {
                  Text(this.item.favorite.displayName)
                    .maxLines(1)
                    .fontWeight(FontWeight.Bold)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontColor(Color.Black)
                    .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                    .margin({ bottom: 5 })
                    .textAlign(TextAlign.Start)

                  Text($r('app.string.phone_type_mobile_expansion', this.item.favorite.phoneNum))
                    .fontColor($r('sys.color.ohos_fa_text_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                    .textAlign(TextAlign.Start)
                }
                .width('83%')
                .padding({ left: $r('app.float.id_card_margin_xxl'), right: $r('app.float.id_card_margin_large') })
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)
              }
            }

            Image($r('app.media.ic_public_detail'))
              .height($r('app.float.id_card_margin_xxl'))
              .objectFit(ImageFit.Contain)
              .borderRadius($r('app.float.id_card_margin_xl'))
              .onClick(() => {
                this.presenter.goContactDetail(this.item.favorite.contactId);
              })
              .width('7%')
          }
          .width('100%')
        }
        .alignItems(VerticalAlign.Center)
        .direction(Direction.Ltr)
        .justifyContent(FlexAlign.Start)
        .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
        .height($r('app.float.id_item_height_large'))
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      if (this.item.showDivider) {
        Divider()
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ left: $r('app.float.id_item_height_large') })
      }
    }
    .onClick(() => {
      ContactAbilityModel.getContactById(this.item.favorite.contactId, result => {
        if (result.data.hasOwnProperty('phones')) {
          if (result.data.phones.length > 1) {
            new Promise<number>(async () => {
              let defaultNumber: String = <String> await sharedPreferencesUtils.getFromPreferences(
                this.item.favorite.contactId + '', '-1');
              this.builder.multiNumCardItems = []
              this.builder.contactId = result.data.id
              var hasDefault = false
              result.data.phones.forEach((element) => {
                let formatNum = PhoneNumber.fromString(element.num).getNumber().replace(/\s+/g, '')
                if (defaultNumber != '-1' && defaultNumber == formatNum) {
                  this.dealCallNumber(formatNum)
                  hasDefault = true;
                  return;
                }
                this.builder.multiNumCardItems.push({ number: element.num, img: $r('app.media.ic_public_phone_dialog'),
                  numType: Phone.getTypeLabelResource(parseInt(element.numType, 10)) })
              });
              this.builder.callback = (item) => {
                this.dealCallNumber(item.number)
              }
              if (!hasDefault)
                this.mSelectSlotIdDialog.open()
            });
          } else if (result.data.phones.length > 0) {
            this.dealCallNumber(result.data.phones[0].num)
          }
        } else {
          prompt.showToast({ message: '联系人无可用号码!'})
          HiLog.e(TAG, ' popupSelectNumber phones null');
        }
      }, globalThis.getContext())
    })
    .gesture(
    LongPressGesture({ repeat: false })
      .onAction((event: GestureEvent) => {
        for (let i = 0; i < this.presenter.favoriteList.length; i++) {
          if (this.item.favorite.contactId === this.presenter.favoriteList[i].contactId) {
            this.presenter.favoriteList[i].isEditSelect = true;
          } else {
            this.presenter.favoriteList[i].isEditSelect = false;
          }
        }
        this.presenter.isEditSelectList.pop();
        this.presenter.isEditSelectList.push(this.item.favorite.contactId + '');
        this.presenter.longItemEditFavorite(this.presenter.favoriteList, this.presenter.isEditSelectList, this.item.favorite);
      })
    )
  }

  dealCallNumber(phoneNum) {
    if (!this.haveSimCard) {
      HiLog.i(TAG, 'No SIM card!');
      PhoneNumber.fromString(phoneNum).isDialEmergencyNum().then((res) => {
        this.isEmergencyNum = res;
      })
      if (!this.isEmergencyNum) {
        HiLog.i(TAG, 'Is not Emergency Phone Number!');
        return;
      } else {
        HiLog.i(TAG, 'No SIM card, but is Emergency Phone Number');
        PhoneNumber.fromString(phoneNum).dial();
      }
    } else if (this.haveMultiSimCard) {
      this.selectSimBuilder.title = $r('app.string.contacts_call_number', phoneNum);
      this.selectSimBuilder.callback = (value) => {
        PhoneNumber.fromString(phoneNum).dial({
          accountId: value,
        });
      }
      this.selectSimBuilder.lastSimId = this.mPresenter.lastUsedSlotId;
      let spnList = AppStorage.Get<Array<string | Resource>>('spnList');
      for (var index = 0; index < spnList.length; index++) {
        this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
      }
      this.selectSimBuilder.controller?.open();
    } else {
      PhoneNumber.fromString(phoneNum).dial();
    }
  }
}

@Component
export struct FavoriteEmptyPage {
  @Link presenter: FavoriteListPresenter;
  @Link isEdit: boolean ;

  build() {
    Column() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
          TitleGuide({ mPresenter: $presenter });
        }

        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 2, lg: 4 } }) {
          Text($r('app.string.favorite'))
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .height($r('app.float.id_item_height_large'))
            .textAlign(TextAlign.Start)
            .width('100%')
        }
      }

      Column() {
        Image($r('app.media.ic_no_favorites'))
          .objectFit(ImageFit.Contain)
          .width($r('app.float.id_card_image_large'))
          .height($r('app.float.id_card_image_large'))
          .margin({ bottom: $r('app.float.id_card_margin_large') })

        Text($r('app.string.no_favorite'))
          .width($r('app.float.id_card_image_large'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .textAlign(TextAlign.Center)
      }
      .height('100%')
      .width('100%')
      .margin({ top: $r('app.float.account_listItem_text_common_width') })
    }
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .height('100%')
    .width('100%')
  }
}

@Component
struct TitleGuide {
  @Link mPresenter: FavoriteListPresenter;

  @Builder MenuBuilder() {
    Column() {
      Text($r('app.string.edit'))
        .fontSize($r('app.float.id_corner_radius_card_mid'))
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .lineHeight(19)
        .width($r('app.float.account_Divider_width'))
        .height(21)
    }
    .width($r('app.float.account_MenuBuilder_width'))
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.id_item_height_mid'))
    .onClick(() => {
      this.mPresenter.editFavorite();
    })
  }

  build() {
    Row() {
      Image($r('app.media.ic_public_add'))
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .padding($r('app.float.id_card_margin_large'))
        .onClick(() => {
          this.mPresenter.addFavorite();
        });

      Image(this.mPresenter.favoriteList.length > 0 ? $r('app.media.ic_public_more') : $r('app.media.ic_public_more_gray'))
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .objectFit(ImageFit.Contain)
        .padding($r('app.float.id_card_margin_large'))
        .enabled(this.mPresenter.favoriteList.length > 0 ? true : false)
        .bindMenu(this.MenuBuilder)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .height($r('app.float.id_item_height_large'))
    .width('100%')
  }
}
