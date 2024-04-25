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

import ContactListItemView from '../../component/contact/ContactListItemView';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import { HiLog, ArrayUtil } from '../../../../../../common';
import emitter from '@ohos.events.emitter';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import Constants from '../../../../../../common/src/main/ets/Constants';
import { ContactSearch } from './search/ContactSearch';
import { AlphabetIndexerPage } from './alphabetindex/AlphabetIndexerPage';
import AlphabetIndexerPresenter from '../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';

const TAG = 'ContactList  ';
const EMITTER_SEARCH_ID: number = 105;
let storage = LocalStorage.GetShared();

/**
 * Contact list page
 */
@Entry(storage)
@Component
export default struct ContactListPage {
  @State mContactPresenter: ContactListPresenter = ContactListPresenter.getInstance();
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  @State contactListListLen: number = 0;
  emitterId: number = 2;

  refresh() {
    let contactListLen = this.mContactPresenter.contactListDataSource.totalCount();
    if (this.contactListListLen != contactListLen) {
      this.contactListListLen = contactListLen;
      this.mContactPresenter = globalThis.presenterManager.contactListPresenter;
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'Contact aboutToAppear!');
    this.mContactPresenter.aboutToAppear();
    this.mContactPresenter.bindUI(() => {
      this.refresh()
    })
    this.refresh();
    let innerEventSearch = {
      eventId: EMITTER_SEARCH_ID,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEventSearch, (data) => {
      this.mContactPresenter.isSearchPage = data.data['isSearchPage'];
    })
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'Contact aboutToDisappear!');
    this.mContactPresenter.aboutToDisappear();
  }

  build() {
    if (this.contactListListLen == 0) {
      ContactEmptyPage({ presenter: $mContactPresenter })
        .backgroundColor(this.curBp === 'lg' ? $r('sys.color.ohos_id_color_sub_background') : Color.White)
    } else {
      ContactContent({ presenter: $mContactPresenter, contactListListLen: $contactListListLen })
        .backgroundColor(this.curBp === 'lg' ? $r('sys.color.ohos_id_color_sub_background') : Color.White)
    }
  }
}

@Component
struct TitleGuide {
  presenter: ContactListPresenter = ContactListPresenter.getInstance();

  build() {
    Row() {
      Image($r('app.media.ic_public_add'))
        .width($r('app.float.id_card_image_small'))
        .height($r('app.float.id_card_image_small'))
        .objectFit(ImageFit.Contain)
        .margin({ right: $r('app.float.id_card_margin_xl') })
        .onClick(() => {
          this.presenter.createContact();
        })

      Image($r('app.media.ic_public_more'))
        .width($r('app.float.id_card_image_small'))
        .height($r('app.float.id_card_image_small'))
        .objectFit(ImageFit.Contain)
        .opacity(0.4)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .height($r('app.float.id_item_height_large'))
    .width('100%')
  }
}

@Component
struct ContactContent {
  @Link private presenter: ContactListPresenter;
  @Link private contactListListLen: number;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  private scroller: Scroller = new Scroller();
  @State alphabetSelected: number = 0;
  @State isAlphabetClicked: boolean = false;
  @State dragList: boolean = true;
  @State alphabetIndexPresenter: AlphabetIndexerPresenter = this.presenter.alphabetIndexPresenter;
  @State type: number = 0;

  @Builder
  GroupsView(imageRes: Resource, title: string | Resource, showArrow: boolean) {
    Row() {
      Row() {
        Image(imageRes)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Contain)
          .margin({ left: $r('app.float.id_card_margin_max'), right: $r('app.float.id_card_margin_xxl') })

        Text(title)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        Image($r('app.media.ic_arrow_right_grey'))
          .width(12)
          .height($r('app.float.id_card_image_small'))
          .objectFit(ImageFit.Contain)
          .margin({ right: $r('app.float.id_card_margin_max') })

      }
    }
    .width('100%')
    .height($r('app.float.id_item_height_max'))
    .backgroundColor(Color.White)
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Stack({ alignContent: Alignment.Top }) {
          GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
            GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
              TitleGuide()
            }
            GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 2, lg: 4 } }) {
              Column() {
                Text($r('app.string.contact'))
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .margin({ bottom: $r('app.float.id_card_margin_sm') })
                  .lineHeight(42)
                  .margin({ top: 8, bottom: 2 })
                Text($r('app.string.contact_num', this.contactListListLen))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  .lineHeight(19)
                Stack({ alignContent: Alignment.Bottom }) {
                  TextInput({ placeholder: $r('app.string.contact_list_search') })
                    .placeholderColor(Color.Grey)
                    .placeholderFont({
                      size: $r('sys.float.ohos_id_text_size_headline9'),
                      weight: FontWeight.Normal,
                      style: FontStyle.Normal
                    })
                    .type(InputType.Normal)
                    .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
                    .enterKeyType(EnterKeyType.Search)
                    .padding({ left: $r('app.float.id_card_margin_xxxxl') })
                    .height($r('app.float.id_item_height_mid'))
                    .enabled(false)
                    .border({
                      color: $r('sys.color.ohos_id_color_fourth'),
                      radius: $r('app.float.id_card_margin_max')
                    })
                  Column(){
                    Image($r('app.media.ic_public_search'))
                      .width($r('app.float.id_card_margin_xxxl'))
                      .height($r('app.float.id_card_margin_xxxl'))
                      .objectFit(ImageFit.Contain)
                      .margin({ left: $r('app.float.id_card_margin_large') })
                  }
                  .width('100%')
                  .margin({ bottom: $r('app.float.id_corner_radius_card_mid') })
                  .alignItems(HorizontalAlign.Start)
                }
                .onClick(() => {
                  this.presenter.isSearchPage = true;
                  this.presenter.sendEmitter(this.presenter.isSearchPage);
                  this.presenter.inputKeyword = '';
                })
                .margin({ top: $r('app.float.dialer_common_very_small_margin2') })
                .width('100%')
              }
              .justifyContent(FlexAlign.Start)
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          }
        }
        .visibility(this.presenter.isSearchPage ? Visibility.None : Visibility.Visible)
        .padding({ bottom: $r('app.float.id_card_margin_large') })
        // .height(180)
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
            List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
              LazyForEach(this.presenter.contactListDataSource, (item, index: number) => {
                ListItem() {
                  Stack({ alignContent: Alignment.BottomEnd }) {
                    Column() {
                      if (item.showIndex && !StringUtil.isEmpty(item.contact.namePrefix)) {
                        Row() {
                          Text(item.contact.namePrefix)
                            .fontColor($r('sys.color.ohos_fa_text_secondary'))
                            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                            .fontWeight(FontWeight.Medium)
                            .textAlign(TextAlign.Start)
                        }
                        .alignItems(VerticalAlign.Bottom)
                        .direction(Direction.Ltr)
                        .padding({ left: this.curBp === 'lg' ? $r('app.float.id_card_margin_max') : 0,
                          bottom: $r('app.float.id_card_margin_large') })
                        .height($r('app.float.id_item_height_mid'))
                      }
                      ContactListItemView({
                        item: item.contact,
                        index: index,
                        showIndex: item.showIndex,
                        showDivifer: item.showDivifer
                      })
                    }
                    .alignItems(HorizontalAlign.Start)
                    if (item.showDivifer) {
                      Divider()
                        .color($r('sys.color.ohos_id_color_list_separator'))
                        .margin({ right: this.curBp === 'lg' ? 24 : 0,
                          left: this.curBp === 'lg' ? 76 : 52
                        })
                    }
                  }
                }
              }, (item) => JSON.stringify(item))
            }
            .width('100%')
            .height('100%')
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.None)
            .scrollBar(BarState.Off).onScrollIndex((firstIndex: number, lastIndex: number) => {if (!this.isAlphabetClicked) {
              this.alphabetSelected = this.alphabetIndexPresenter.getAlphabetSelected(firstIndex);
            }}).onScrollStart(() => {this.dragList = true;}).onScrollStop(() => {this.isAlphabetClicked = false;})
          }
        }
        .height('100%')
        .flexShrink(1)
      }
      .padding({ left: 24, right: 24 })
      .height('100%')
      .width('100%')
      ContactSearch({ presenter: $presenter, type: $type })
        .visibility(this.presenter.isSearchPage ? Visibility.Visible : Visibility.None)
	AlphabetIndexerPage({scroller: this.scroller, presenter: $alphabetIndexPresenter, selected: this.alphabetSelected,
        isClicked: $isAlphabetClicked, drag: $dragList})
        .margin({top: '30%', bottom: '10%'})
      }
      .width('100%')
      .height('100%')
  }
}

@Component
export struct ContactEmptyPage {
  @Link presenter: ContactListPresenter;
  @LocalStorageProp('breakpoint') curBp: string = 'sm'

  build() {
    Column() {
      GridRow({columns: {sm: 4, md: 8, lg: 12}, gutter: {x: 12, y: 0}}) {
        GridCol({span: {sm: 4, md:6, lg: 8}, offset: {sm: 0, md: 1, lg: 2}}) {
          TitleGuide()
        }
        GridCol({span: {sm: 4, md:6, lg: 8}, offset: {sm: 0, md: 2, lg: 4}}) {
          Text($r('app.string.contact'))
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

        Text($r('app.string.no_contacts'))
          .width($r('app.float.id_card_image_large'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .textAlign(TextAlign.Center)
      }

      Column() {
        //This component is temporarily shielded because there is no requirement currently.
//        Button($r('app.string.contact_login_in'), { type: ButtonType.Capsule, stateEffect: true })
//          .fontColor($r('sys.color.ohos_id_color_connected'))
//          .fontWeight(FontWeight.Medium)
//          .fontSize($r('sys.float.ohos_id_text_size_body1'))
//          .width('100%')
//          .height($r('app.float.id_item_height_sm'))
//          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
//          .onClick(() => {
//            this.presenter.loginAccount();
//          })

//        Button($r('app.string.contact_import_contacts'), { type: ButtonType.Capsule, stateEffect: true })
//          .fontColor($r('sys.color.ohos_id_color_connected'))
//          .fontWeight(FontWeight.Medium)
//          .fontSize($r('sys.float.ohos_id_text_size_body1'))
//          .margin({ top: $r('app.float.id_card_margin_xxl') })
//          .width('100%')
//          .height($r('app.float.id_item_height_sm'))
//          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
//          .onClick(() => {
//            this.presenter.importContact();
//          })

        Button($r('app.string.create_contact'), { type: ButtonType.Capsule, stateEffect: true })
          .fontColor($r('sys.color.ohos_id_color_connected'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .margin({ top: $r('app.float.id_card_margin_xxl') })
          .width('100%')
          .height($r('app.float.id_item_height_sm'))
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .onClick(() => {
            this.presenter.createContact();
          })

        //This component is temporarily shielded because there is no requirement currently.
//        Button($r('app.string.contact_scan_card'), { type: ButtonType.Capsule, stateEffect: true })
//          .fontColor($r('sys.color.ohos_id_color_connected'))
//          .fontWeight(FontWeight.Medium)
//          .fontSize($r('sys.float.ohos_id_text_size_body1'))
//          .margin({ top: $r('app.float.id_card_margin_xxl') })
//          .width('100%')
//          .height($r('app.float.id_item_height_sm'))
//          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
//          .onClick(() => {
//            this.presenter.scanCard();
//          })
      }
      .margin({bottom: 192})
      .width(this.curBp === 'lg' ? '37%' : '50%')
    }
    .padding({left:24, right:24})
    .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
    .width('100%')
  }
}