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
import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
import { StringUtil } from '../../../../../../../common/';
import emitter from '@ohos.events.emitter';
import BatchSelectContactsPresenter from '../../../presenter/contact/batchselectcontacts/BatchSelectContactsPresenter';
import router from '@ohos.router';

const TAG = 'ContactSearch ';

@Component
export struct ContactSearch {
  @State batchSelectContactsPresenter: BatchSelectContactsPresenter = BatchSelectContactsPresenter.getInstance();
  @Link presenter: ContactListPresenter;
  @Link type: number;
  @State contactSearchNumber: number = 0;
  emitterId: number = 102;
  @State placeholder: string = '';
  @State cancelIsTouch: boolean = false;

  aboutToAppear() {
    let innerEvent = {
      eventId: this.emitterId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEvent, (data) => {
      this.contactSearchNumber = data.data['contactSearchList'];
    })
  }

  build() {
    Column() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
          Column() {
            Row() {
              Image($r('app.media.ic_public_back'))
                .fillColor($r('sys.color.ohos_id_color_primary'))
                .objectFit(ImageFit.Contain)
                .height($r('app.float.id_card_image_small'))
                .width($r('app.float.id_card_image_small'))
                .onClick(() => {
                  this.presenter.isSearchPage = false;
                  this.presenter.sendEmitter(this.presenter.isSearchPage);
                  this.presenter.inputKeyword = '';
                })

              Stack({ alignContent: Alignment.Center }) {
                TextInput({ text: this.presenter.inputKeyword, placeholder: $r('app.string.contact_list_search') })
                  .placeholderColor(Color.Grey)
                  .placeholderFont({
                    size: $r('sys.float.ohos_id_text_size_headline9'),
                    weight: FontWeight.Normal,
                    style: FontStyle.Normal
                  })
                  .type(InputType.Normal)
                  .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
                  .enterKeyType(EnterKeyType.Search)
                  .margin({ left: $r('app.float.id_card_image_small'), right: $r('app.float.id_card_image_small') })
                  .padding({ left: $r('app.float.id_card_margin_xxxxl') })
                  .height($r('app.float.id_item_height_mid'))
                  .border({
                    color: $r('sys.color.ohos_id_color_fourth'),
                    radius: $r('app.float.id_card_margin_max')
                  })
                  .onChange((value: string) => {
                    this.presenter.inputKeyword = value
                    this.presenter.getSearchContact(this.presenter.inputKeyword);
                  })

                Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                  Image($r('app.media.ic_public_search'))
                    .width($r('app.float.id_card_margin_xxxl'))
                    .height($r('app.float.id_card_margin_xxxl'))
                    .margin({ left: $r('app.float.id_card_margin_xxxxl') })
                    .objectFit(ImageFit.Contain)

                  if (this.presenter.inputKeyword != '') {
                    Image($r('app.media.ic_public_cancel'))
                      .width($r('app.float.id_card_margin_max'))
                      .height($r('app.float.id_card_margin_max'))
                      .objectFit(ImageFit.Contain)
                      .fillColor($r('sys.color.ohos_id_color_primary'))
                      .opacity(0.6)
                      .margin({ right: $r('app.float.id_card_margin_xxxxl') })
                      .align(Alignment.End)
                      .onClick(() => {
                        this.presenter.inputKeyword = '';
                      })
                  }
                }
                .hitTestBehavior(HitTestMode.Transparent)
              }
              .align(Alignment.Center)
            }
            .padding({ top: $r('app.float.id_card_image_xs'), bottom: $r('app.float.id_card_image_xs') })
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .align(Alignment.Start)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .padding({ left: $r('app.float.id_card_image_small'), right: $r('app.float.id_card_image_small') })
        }
      }
      .visibility(this.type === 1 || this.type === 2 ? Visibility.None : Visibility.Visible)

      Column() {
        Text($r('app.string.found_contacts', this.contactSearchNumber))
          .fontColor(Color.Gray)
          .margin({ top: $r('app.float.id_card_margin_xxl'), bottom: $r('app.float.id_card_margin_xxl') })
          .width('100%')
          .visibility(this.contactSearchNumber > 0 ? Visibility.Visible : Visibility.None)

        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
          GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
            List({ space: 0, initialIndex: 0 }) {
              LazyForEach(this.presenter.searchContactsSource, (item, index: number) => {
                ListItem() {
                  Stack({ alignContent: Alignment.BottomEnd }) {
                    Row() {
                      Row() {
                        if (StringUtil.isEmpty(item?.contact?.photoFirstName)) {
                          Image(StringUtil.isEmpty(item?.contact?.portraitPath) ? $r('app.media.ic_user_portrait') : item?.contact?.portraitPath)
                            .width($r('app.float.id_card_image_mid'))
                            .height($r('app.float.id_card_image_mid'))
                            .objectFit(ImageFit.Contain)
                            .borderRadius($r('app.float.id_card_image_mid'))
                            .backgroundColor(item?.contact?.portraitColor)

                        } else {
                          Text(item?.contact?.photoFirstName.toUpperCase())
                            .fontSize(30)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(Color.White)
                            .backgroundColor(item?.contact?.portraitColor)
                            .height($r('app.float.id_card_image_mid'))
                            .width($r('app.float.id_card_image_mid'))
                            .textAlign(TextAlign.Center)
                            .borderRadius($r('app.float.id_card_image_mid'))
                        }
                      }
                      .height($r('app.float.id_card_image_mid'))
                      .width($r('app.float.id_card_image_mid'))

                      Column() {
                        Row() {
                          ForEach(item?.contact?.displayName.split(this.presenter.inputKeyword), (itemData1, idx: number) => {
                            Row() {
                              Text(itemData1.toString())
                                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                                .fontWeight(FontWeight.Medium)
                                .margin({ bottom: $r('app.float.id_card_margin_sm') })
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                .maxLines(2)
                              if (idx === 0) {
                                if (item?.contact?.displayName.indexOf(this.presenter.inputKeyword) !== -1) {
                                  Text(this.presenter.inputKeyword.toString())
                                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                    .fontColor(Color.Blue)
                                    .fontWeight(FontWeight.Medium)
                                    .margin({ bottom: $r('app.float.id_card_margin_sm') })
                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                    .maxLines(2)
                                }
                              } else if (item?.contact?.displayName.split(this.presenter.inputKeyword)
                                .length - 1 !== idx) {
                                Text(this.presenter.inputKeyword.toString())
                                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                                  .fontWeight(FontWeight.Medium)
                                  .margin({ bottom: $r('app.float.id_card_margin_sm') })
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                                  .maxLines(2)
                              }
                            }
                          })
                        }

                        Row() {
                          if (!StringUtil.isEmpty(item?.contact?.detailInfo) && '0' !== item?.contact?.hasPhoneNumber) {
                            ForEach(item?.contact?.detailInfo?.split(this.presenter.inputKeyword), (itemData, idx: number) => {
                              Row() {
                                Text(itemData.toString())
                                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                                  .fontWeight(FontWeight.Medium)
                                  .margin({ bottom: $r('app.float.id_card_margin_sm') })
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                                  .maxLines(2)
                                if (idx === 0) {
                                  if (item?.contact?.detailInfo.indexOf(this.presenter.inputKeyword) !== -1) {
                                    Text(this.presenter.inputKeyword.toString())
                                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                      .fontColor(Color.Blue)
                                      .fontWeight(FontWeight.Medium)
                                      .margin({ bottom: $r('app.float.id_card_margin_sm') })
                                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                                      .maxLines(2)
                                  }
                                } else if (item?.contact?.detailInfo.split(this.presenter.inputKeyword)
                                  .length - 1 !== idx) {
                                  Text(this.presenter.inputKeyword.toString())
                                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                    .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                                    .fontWeight(FontWeight.Medium)
                                    .margin({ bottom: $r('app.float.id_card_margin_sm') })
                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                    .maxLines(2)
                                }
                              }
                            })
                          }
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .padding({
                        top: $r('app.float.id_card_margin_mid'),
                        bottom: $r('app.float.id_card_margin_mid'),
                      })
                      .margin({ left: $r('app.float.id_card_margin_xl') })
                    }
                    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
                    .width('100%')
                    .height($r('app.float.id_item_height_large'))

                    Divider()
                      .color($r('sys.color.ohos_id_color_list_separator'))
                      .visibility(this.contactSearchNumber > 1 && this.contactSearchNumber - item.index > 1 ? Visibility.Visible : Visibility.None)
                      .margin({
                        left: $r('app.float.id_item_height_large'),
                        right: $r('app.float.id_card_image_small')
                      })
                  }
                }
                .onClick(() => {
                  if (this.type === 0) {
                    router.pushUrl(
                      {
                        url: 'pages/contacts/details/ContactDetail',
                        params: {
                          sourceHasId: true,
                          contactId: item.contact.contactId
                        }
                      }
                    );
                  } else if (this.type === 1) {
                    this.batchSelectContactsPresenter.onSingleContactItemClick(0, item.contact.displayName, item.contact.contactId);
                  } else if (this.type === 2) {
                  }
                })
              }, item => JSON.stringify(item))
            }
            .height('90%')
            .width('100%')
            .listDirection(Axis.Vertical)
          }
        }
        .height('100%')
        .flexShrink(1)
      }
      .height('100%')
      .width('100%')
      .padding({ left: this.type === 0 && this.contactSearchNumber > 0 ? $r('app.float.id_card_image_small') : 0 })
      .visibility(this.contactSearchNumber > 0 && !this.presenter.isSearchBackgroundColor ? Visibility.Visible : Visibility.None)

      ContactSearchEmptyPage({ contactSearchNumber: $contactSearchNumber, presenter: $presenter, type: $type });
    }
    .padding({ bottom: $r('app.float.dialer_calllog_item_height') })
    .height('100%')
    .width('100%')
    .backgroundColor(this.type === 1 || this.type === 2 ? $r('sys.color.ohos_id_color_sub_background') : this.type === 0 && this.contactSearchNumber > 0 ? Color.White : '#450a0a0a')
  }
}

@Component
export struct ContactSearchEmptyPage {
  @Link contactSearchNumber: number;
  @Link presenter: ContactListPresenter;
  @Link type: number;

  build() {
    Column() {
      Image($r('app.media.no_contacts_illustration'))
        .objectFit(ImageFit.Contain)
        .width($r('app.float.id_card_image_large'))
        .height($r('app.float.id_card_image_large'))
        .margin({ bottom: $r('app.float.id_card_margin_large') })

      Text($r('app.string.contact_list_search_empty'))
        .width($r('app.float.id_card_image_large'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: $r('app.float.dialer_calllog_item_height') })

    }
    .padding({
      left: $r('app.float.id_card_image_small'),
      right: $r('app.float.id_card_image_small'),
      bottom: $r('app.float.account_listItem_text_common_width')
    })
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .backgroundColor(this.type === 1 ? $r('sys.color.ohos_id_color_sub_background') : Color.White)
    .visibility(this.contactSearchNumber > 0 ? (!this.presenter.isSearchBackgroundColor ? Visibility.Visible : Visibility.None) :
      (this.presenter.isSearchBackgroundColor ? Visibility.None : Visibility.Visible))
  }
}