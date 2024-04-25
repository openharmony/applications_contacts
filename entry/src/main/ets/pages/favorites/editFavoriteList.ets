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

import EditFavoriteListPresenter from '../../presenter/favorite/EditFavoriteListPresenter';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import router from '@ohos.router';
import { FavoriteBean } from '../../model/bean/FavoriteBean';

const TAG = 'EditFavoriteList';

@Entry
@Component
export default struct EditFavoriteList {
  @State mFavoriteListPresenter: EditFavoriteListPresenter = EditFavoriteListPresenter.getInstance();
  @State isEdit: boolean = true
  @State favoriteList: FavoriteBean[] = [];
  @State selectNumbers: number = 0;
  @State favoriteNumbers: number = 0;
  @State usuallyNumbers: number = 0;

  aboutToAppear() {
    HiLog.i(TAG, 'EditFavoriteList aboutToAppear!');
    let obj: any = router.getParams();
    this.mFavoriteListPresenter.favoriteList = obj.favoriteList;
    this.mFavoriteListPresenter.isEditSelect = obj.isEditSelectList;
    this.selectNumbers = obj.selectNumber;
    this.favoriteNumbers = obj.favoriteNumber;
    this.usuallyNumbers = obj.usuallyNumber;
    this.mFavoriteListPresenter.selectFavoriteBean = obj.selectFavoriteBean;
    this.mFavoriteListPresenter.aboutToAppear();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'EditFavoriteList aboutToDisappear!');
    this.mFavoriteListPresenter.aboutToDisappear();
  }

  onPageShow() {
    HiLog.i(TAG, 'EditFavoriteList onPageShow')
    this.mFavoriteListPresenter.onPageShow()
  }

  onPageHide() {
    HiLog.i(TAG, 'EditFavoriteList onPageHide')
    this.mFavoriteListPresenter.onPageHide()
  }

  build() {
    Column() {
      if (this.mFavoriteListPresenter.favoriteList.length > 0) {
        FavoriteContent({
          presenter: $mFavoriteListPresenter,
          selectNumbers: $selectNumbers,
          favoriteNumber: $favoriteNumbers,
          usuallyNumber: $usuallyNumbers
        })
      } else {
        FavoriteEmptyPage({ presenter: $mFavoriteListPresenter, isEdit: $isEdit })
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct FavoriteContent {
  @Link presenter: EditFavoriteListPresenter;
  isUsuallyShow: boolean = false;
  @Link selectNumbers: number;
  @Link favoriteNumber: number;
  @Link usuallyNumber: number;
  @State selectNumber: number = this.selectNumbers;
  @State selectFavoriteIdList: string[] = [];
  @State isEditSelectList: string[] = null != this.presenter.isEditSelect &&
                                      this.presenter.isEditSelect.length > 0 ? this.presenter.isEditSelect : [];
  @State favoriteListPresenter: EditFavoriteListPresenter = this.presenter;
  @State isSelectAll: boolean = false;
  @State isSelectAllStatus: boolean = false;
  item: any = {};
  @State text: string = '';
  @State isEditDrag: boolean = false;
  @State select: number = 0;
  @State currentIndex: number = 0;
  @State isDragShow: boolean = false;
  @State offsetY: number = 50;
  @State positionYDown: number = 0;
  @State positionYUp: number = 0;

  @Builder pixelMapBuilder() {
    Column() {
      FavoriteListItem({
        item: this.item,
        isEditSelectList: $isEditSelectList,
        presenter: $favoriteListPresenter,
        selectNumber: $selectNumber,
        isSelectAll: $isSelectAll,
        usuallyNumber: $usuallyNumber,
        favoriteNumber: $favoriteNumber,
        isEditDrag: this.isEditDrag
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          Row() {
            Text(this.selectNumber > 0 ? $r('app.string.select_num', this.selectNumber) : $r('app.string.no_select'))
              .maxFontSize(22)
              .minFontSize(18)
              .maxLines(1)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Black)
              .margin({ top: $r('app.float.id_card_margin_large'), bottom: $r('app.float.id_card_margin_large') })
          }
          .margin({ left: this.offsetY < 0 ? 0 : $r('app.float.id_item_height_mid') })
          .height(this.offsetY > 0 ? 56 : 138)
          .animation({
            duration: 200,
            iterations: 1,
          })

          TitleGuide({
            isDragShow: $isDragShow,
            isEditSelectList: $isEditSelectList,
            presenter: $favoriteListPresenter,
            selectNumber: $selectNumber,
            offsetY: $offsetY
          })
        }

        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
            List({ space: 0, initialIndex: 0 }) {
              LazyForEach(this.presenter.favoriteDataSource, (item, index: number) => {
                ListItem() {
                  FavoriteListItem({
                    item: item,
                    isEditSelectList: $isEditSelectList,
                    presenter: $favoriteListPresenter,
                    selectNumber: $selectNumber,
                    isSelectAll: $isSelectAll,
                    usuallyNumber: $usuallyNumber,
                    favoriteNumber: $favoriteNumber,
                    isEditDrag: false
                  })
                }
                .onDragStart((event: DragEvent, extraParams: string) => {
                  console.log('ListItem onDragStarts, ' + extraParams)
                  var jsonString = JSON.parse(extraParams)
                  if (jsonString.selectedIndex >= this.favoriteNumber) {
                    console.log('List onDragStarts , return ')
                    return;
                  }
                  this.isEditDrag = true;
                  this.select = jsonString.selectedIndex;
                  this.item = item;
                  return this.pixelMapBuilder();
                })
              }, (item) => JSON.stringify(item))
            }
            .editMode(true)
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Off)
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.Spring)
            .onDrop((event: DragEvent, extraParams: string) => {
              let jsonString = JSON.parse(extraParams);
              if (jsonString.insertIndex >= this.favoriteNumber) {
                return;
              }
              if (this.isEditDrag) {
                this.isDragShow = true;
                let index = this.presenter.favoriteDataSource.getFavoriteList().indexOf(this.item.favorite);
                this.presenter.favoriteDataSource.getFavoriteList().splice(index, 1);
                this.presenter.favoriteDataSource.getFavoriteList()
                  .splice(jsonString.insertIndex, 0, this.item.favorite);
                this.presenter.favoriteDataSource.refresh(this.presenter.favoriteDataSource.getFavoriteList());
                this.isEditDrag = false;
              }
            })
            .onScroll((scrollOffset, scrollState) => {
              this.offsetY = this.positionYDown - this.positionYUp;
              if (this.offsetY > 0) {
                animateTo({ duration: 1000 }, () => {
                });
              } else {
                animateTo({ duration: 1000 }, () => {
                });
              }
            })
            .onTouch((event) => {
              switch (event.type) {
                case TouchType.Down:
                  this.positionYDown = Math.abs(event.touches[0].y);
                  break;
                case TouchType.Move:
                  this.positionYUp = Math.abs(event.touches[0].y);
                case TouchType.Up:
                  this.positionYUp = Math.abs(event.touches[0].y);
                  break;
              }
            })
          }
        }
        .height('100%')
        .flexShrink(1)

        Row() {
          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
            Column() {
              Image(this.selectNumber > 0 ? $r('app.media.ic_public_close') : $r('app.media.ic_public_close_gray'))
                .objectFit(ImageFit.Contain)
                .height($r('app.float.id_card_image_small'))
                .width($r('app.float.id_card_image_small'))
                .margin({ bottom: 3 })
              Text($r('app.string.favorite_remove'))
                .fontColor(this.selectNumber > 0 ? $r('sys.color.ohos_id_color_toolbar_text') : Color.Gray)
                .fontSize($r('sys.float.ohos_id_text_size_caption'))
                .fontWeight(FontWeight.Medium)
                .margin({ top: $r('app.float.id_card_margin_large') })
            }
            .onClick(() => {
              if (this.isEditSelectList.length > 0) {
                this.presenter.deleteFavoriteInfo(this.isEditSelectList);
                this.isEditSelectList = [];
                this.selectNumber = this.isEditSelectList.length;
                router.back();
              }
            })
            .width('40%')
            .height('100%')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)

            Column() {
              Image(this.presenter.favoriteList.length === this.selectNumber ? $r('app.media.ic_public_select_all_filled') : $r('app.media.ic_public_select_all'))
                .objectFit(ImageFit.Contain)
                .height($r('app.float.id_card_image_small'))
                .width($r('app.float.id_card_image_small'))
                .margin({ bottom: 3 })
                .fillColor($r('sys.color.ohos_id_color_primary'))
              Text(this.presenter.favoriteList.length === this.selectNumber ? $r('app.string.unselect_all') : $r('app.string.select_all'))
                .fontColor(this.presenter.favoriteList.length === this.selectNumber ? $r('sys.color.ohos_id_color_toolbar_text') : Color.Gray)
                .fontSize($r('sys.float.ohos_id_text_size_caption'))
                .fontWeight(FontWeight.Medium)
                .margin({ top: $r('app.float.id_card_margin_large') })

            }
            .onClick(() => {
              this.isSelectAll = this.presenter.favoriteList.length === this.selectNumber;
              if (this.isSelectAll) {
                this.isEditSelectList = this.presenter.cancelAllFavoriteSelectInfo(this.presenter.favoriteList, this.isEditSelectList);
              } else {
                this.isEditSelectList = this.presenter.addAllFavoriteSelectInfo(this.presenter.favoriteList);
              }
              this.selectNumber = this.isEditSelectList.length;
              this.presenter.favoriteDataSource.refresh(this.presenter.favoriteList);
            })
            .width('40%')
            .height('100%')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
          }
        }
        .padding({ left: 24, right: 24 })
        .backgroundColor(Color.White)
        .width('100%')
        .height($r('app.float.id_item_height_max'))
      }
      .padding({ left: 24, right: 24 })
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}

@Component
export struct FavoriteListItem {
  @Link presenter: EditFavoriteListPresenter;
  @State item: { [key: string]: any } = {};
  @Link isEditSelectList: string[];
  @Link selectNumber: number;
  @Link isSelectAll: boolean;
  @Link usuallyNumber: number;
  @Link favoriteNumber: number;
  isEditDrag: boolean = false;

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        if (1 === this.item.favorite.isCommonUseType) {
          Text($r('app.string.common_use_num', this.usuallyNumber))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Regular)
            .fontColor('#666666')
            .lineHeight(19)
            .textAlign(TextAlign.Center)
            .margin({ top: $r('app.float.id_card_margin_xxl'), bottom: $r('app.float.id_card_margin_xxl') })
            .borderRadius($r('app.float.id_card_image_mid'))
            .visibility(this.item.favorite.isUsuallyShow ? Visibility.Visible : Visibility.None)
        } else if (0 === this.item.favorite.isCommonUseType && this.item.index === 0) {
          Text($r('app.string.favorite_num', this.favoriteNumber))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Regular)
            .fontColor('#666666')
            .lineHeight(19)
            .textAlign(TextAlign.Center)
            .margin({ top: $r('app.float.id_card_margin_xxl'), bottom: $r('app.float.id_card_margin_xxl') })
            .borderRadius($r('app.float.id_card_image_mid'))
            .visibility(this.isEditDrag ? Visibility.None : Visibility.Visible)
        }

        Row() {
          Flex({
            direction: FlexDirection.Row,
            justifyContent: FlexAlign.SpaceBetween,
            alignItems: ItemAlign.Stretch
          }) {
            Row() {
              if (0 === this.item.favorite.isCommonUseType) {
                Image($r('app.media.ic_public_drag_handle'))
                  .width($r('app.float.id_card_image_small'))
                  .height($r('app.float.id_card_image_small'))
                  .objectFit(ImageFit.Contain)
                  .borderRadius($r('app.float.id_card_image_mid'))
                  .margin({ right: $r('app.float.id_card_image_xs') })
                  .width('10%')
              }
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
                  .height('100%')
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

            Column() {
              Checkbox({ name: this.item.favorite.contactId })
                .width($r('app.float.id_card_image_mid'))
                .height($r('app.float.id_card_image_mid'))
                .selectedColor('#007DFF')
                .padding($r('app.float.id_card_margin_mid'))
                .select(this.item.favorite.isEditSelect ? true : false)
                .onChange((value: boolean) => {
                  this.isSelectAll = false;
                  this.item.favorite.isEditSelect = value;
                  if (value) {
                    this.isEditSelectList = this.presenter.addSingleFavoriteSelectInfo(this.isEditSelectList, this.item.favorite);
                  } else {
                    this.isEditSelectList = this.presenter.cancelSingleFavoriteSelectInfo(this.isEditSelectList, this.item.favorite);
                  }
                  this.selectNumber = this.isEditSelectList.length;
                  this.presenter.favoriteDataSource.refresh(this.presenter.favoriteList);
                })
                .width('100%')
            }
            .width('9%')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
        }
        .alignItems(VerticalAlign.Center)
        .direction(Direction.Ltr)
        .justifyContent(FlexAlign.Start)
        .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
        .height($r('app.float.id_item_height_large'))
        .width('100%')
      }.alignItems(HorizontalAlign.Start)

      if (this.item.showDivider || this.item.index >= 0 && this.favoriteNumber > 1 && this.favoriteNumber - 1
      != this.item.index && this.presenter.favoriteList.length - 1 != this.item.index) {
        Divider()
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ left: $r('app.float.id_item_height_large') })
      }
    }
  }
}

@Component
export struct FavoriteEmptyPage {
  @Link presenter: EditFavoriteListPresenter;
  @Link isEdit: boolean ;

  build() {
    Column() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {

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
        Image($r('app.media.no_contacts_illustration'))
          .objectFit(ImageFit.Contain)
          .width($r('app.float.id_card_image_large'))
          .height($r('app.float.id_card_image_large'))
          .margin({ bottom: $r('app.float.id_card_margin_large') })

        Text($r('app.string.cancel_favorite'))
          .width($r('app.float.id_card_image_large'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .textAlign(TextAlign.Center)
      }
      .margin({ bottom: 192 })
    }
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
    .width('100%')
  }
}

@Component
struct TitleGuide {
  @Link presenter: EditFavoriteListPresenter;
  @Link isEditSelectList: string[];
  @Link isDragShow: boolean;
  @Link selectNumber: number;
  @Link offsetY: number;

  build() {
    Row() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
        Image(this.offsetY > 0 ? $r('app.media.ic_public_back') : $r('app.media.ic_public_cancel'))
          .width($r('app.float.id_card_image_large'))
          .height($r('app.float.id_item_height_large'))
          .padding({
            top: $r('app.float.id_card_margin_xxl'),
            right: $r('app.float.dialer_keypad_button_height'),
            bottom: $r('app.float.id_card_margin_xxl'),
          })
          .onClick(() => {
            this.presenter.cancelEditFavorite();
          })

        Image($r('app.media.ic_public_ok'))
          .width($r('app.float.id_item_height_large'))
          .height($r('app.float.id_item_height_large'))
          .padding({
            top: $r('app.float.id_card_margin_xxl'),
            left: $r('app.float.id_card_margin_max'),
            bottom: $r('app.float.id_card_margin_xxl')
          })
          .visibility(this.isDragShow ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.presenter.moveSortFavorite(this.presenter.favoriteDataSource.getFavoriteList());
          })
      }
      .width('100%')
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .height($r('app.float.id_item_height_large'))
    .width('100%')
  }

  onBackPress() {
    this.presenter.cancelEditFavorite();
  }
}
