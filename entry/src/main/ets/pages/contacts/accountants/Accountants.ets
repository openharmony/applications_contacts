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
import IndexPresenter from '../../../presenter/IndexPresenter';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { ObjectUtil } from '../../../../../../../common/src/main/ets/util/ObjectUtil';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import EnvironmentProp from "../../../feature/EnvironmentProp";
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { PhoneNumBean } from "../../../model/bean/PhoneNumBean";
import AccountantsPresenter from '../../../presenter/contact/accountants/AccountantsPresenter';
import DeleteDialogEx from '../../dialog/DeleteDialogEx';
import { ShowDayTime } from "../../../component/contact/accountants/ShowDayTime"
import { ItemList } from "../../../component/contact/accountants/ItemList"
import { ItemEvent } from "../../../component/contact/accountants/ItemEvent"
import { AddItem } from "../../../component/contact/accountants/AddItem"
import { ImageItemLeft } from "../../../component/contact/accountants/ImageItemLeft"

const TAG = 'AddContact  ';
let storage = LocalStorage.GetShared();

/**
 * Add Contact
 */
@Extend(ListItem) function listItemFancy (topMargin = $r("app.float.id_card_image_xs")) {
  .borderRadius($r("app.float.id_corner_radius_card"))
  .width("100%")
  .margin({ top: topMargin })
  .padding(EnvironmentProp.isTablet() ? {
                                          top: $r("app.float.id_card_margin_mid"),
                                          bottom: $r("app.float.id_card_margin_mid")
                                        } : {})
  .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
}

@Entry(storage)
@Component
struct Accountants {
  @State mPresenter: AccountantsPresenter = AccountantsPresenter.getInstance();
  @State eventItemId: number = 0;
  @State eventType: number = 1;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  @State updataShow: boolean = false;
  private pageTitle: Resource = $r("app.string.create_contact");
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ShowDayTime({ mPresent: $mPresenter,
      cancel: this.onCancel,
      confirm: this.onAccept,
      itemIndex: this.eventItemId,
      itemType: this.eventType}),
    cancel: this.existApp,
    autoCancel: true,
    alignment: (EnvironmentProp.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom),
    gridCount: 4
  })
  refreshPresenter = (presenter: AccountantsPresenter) => {
    HiLog.i(TAG, 'refreshPresenter')
    this.mPresenter = presenter;
  }
  deleteDialogControler: CustomDialogController = new CustomDialogController({
    //Components shared by the TIP for creating or updating a contact by mistake and the TIP for deleting a contact
    builder: DeleteDialogEx({
      cancel: () => {
        router.back();
      },
      confirm: () => {
        this.mPresenter.saveContact();
      },
      title: $r("app.string.save_dialog_title"),
      cancalText: $r("app.string.dialog_not_save"),
      confrimText: $r("app.string.save")
    }),
    autoCancel: true,
    alignment: (EnvironmentProp.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom),
    offset: { dx: 0, dy: -16 },
    gridCount: 4
  });

  pageTransition() {
    PageTransitionEnter({ duration: 100 })
    PageTransitionExit({ duration: 100 })
  }

  onCancel() {
    HiLog.i(TAG, 'Callback when the first button is clicked');
  }

  onAccept() {
    HiLog.i(TAG, 'Callback when the second button is clicked');
  }

  existApp() {
    HiLog.i(TAG, 'Click the callback in the blank area');
  }

  aboutToAppear() {
    HiLog.i(TAG, "the Page aboutToAppear Begin !!")
    this.mPresenter.init(this.refreshPresenter);
    if (!ObjectUtil.isEmpty(router.getParams())) {
      let obj: any = router.getParams();
      if (obj.hasOwnProperty("updataShow")) {
        this.updataShow = obj.updataShow;
      }
      if (obj.hasOwnProperty("phoneNumbers") && (!ArrayUtil.isEmpty(obj.phoneNumbers))
      && this.updataShow === false) {
        let phoTemp = [new PhoneNumBean("1", obj.phoneNumbers[0].phoneNumber, "1", "", "")];
        this.mPresenter.contactInfoAfter.setPhones(phoTemp);
        this.mPresenter.addState = true;
      }
      if (obj.hasOwnProperty("disPlayName") && (!StringUtil.isEmpty(obj.disPlayName))
      && this.updataShow === false) {
        this.mPresenter.contactInfoAfter.setDisplayName(obj.disPlayName);
        this.mPresenter.addState = true;
      }
      if (this.updataShow === true) {
        this.pageTitle = $r("app.string.edit_contact");
        let obj: any = router.getParams();
        this.mPresenter.contactId = obj.contactId;
        this.mPresenter.updateShow = true;
        this.mPresenter.updatesInit();
      }
    }
    HiLog.i(TAG, "the Page aboutToAppear End");
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow');
    this.mPresenter.refresh();
    IndexPresenter.getInstance().getNewWant();
  }

  onBackPress() {
    HiLog.i(TAG, "onBackPress");
    if (this.mPresenter.getAddState()) {
      this.deleteDialogControler.open();
    } else {
      router.back();
    }
    return true;
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Flex() {
        Navigator({ target: 'pages/contacts/details/ContactDetail', type: NavigationType.Replace }) {
        }
        .active(this.mPresenter.routerAvtiveFlag)
        .params({
          sourceHasId: true,
          contactId: this.mPresenter.contactId
        })
      }.visibility(Visibility.None)

      // title
      Row() {
        Image($r("app.media.ic_public_cancel"))
          .height($r("app.float.id_card_image_small"))
          .width($r("app.float.id_card_image_small"))
          .margin({ top: $r("app.float.id_card_margin_xxl"),
            bottom: $r("app.float.id_card_margin_xxl"),
            right: $r("app.float.id_card_margin_xxl"),
            left: $r("app.float.id_card_margin_max") })
          .fillColor($r("sys.color.ohos_id_color_primary"))
          .onClick(() => {
            if (this.mPresenter.getAddState()) {
              this.deleteDialogControler.open();
            } else {
              router.back()
            }
          })

        Text(this.pageTitle)
          .margin({ top: "13vp",
            bottom: "15vp" })
          .lineHeight("28vp")
          .fontSize("20fp")
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .fontWeight(FontWeight.Bold)

        Blank()

        Image($r("app.media.ic_public_ok"))
          .width($r("app.float.id_card_image_small"))
          .height($r("app.float.id_card_image_small"))
          .margin({ top: $r("app.float.id_card_margin_xxl"),
            bottom: $r("app.float.id_card_margin_xxl"), right: $r("app.float.id_card_margin_max") })
          .fillColor(this.mPresenter.getAddState()
            ? $r("sys.color.ohos_id_color_primary")
            : $r("sys.color.ohos_id_color_tertiary"))
          .onClick(() => {
            this.mPresenter.saveContact();
          })
      }
      .alignItems(VerticalAlign.Center)
      .height($r("app.float.id_item_height_large"))
      .width('100%')
      .flexShrink(0)

      // contact information
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
          List() {
            ListItem() {
              Flex({
                direction: FlexDirection.Column,
                alignItems: ItemAlign.Center,
                justifyContent: FlexAlign.Center
              }) {
                Image($r("app.media.ic_user_portrait"))
                  .height($r("app.float.id_item_height_large"))
                  .width($r("app.float.id_item_height_large"))
                  .objectFit(ImageFit.Contain)
                  .margin({ top: $r("app.float.id_card_margin_xxl") })

                Text($r("app.string.save_to_phone"))
                  .lineHeight("21vp")
                  .fontSize($r("sys.float.ohos_id_text_size_body1"))
                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: "18vp" })
              }
              .height("144vp")
            }

            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start }) {
                ImageItemLeft({ mImage: $r("app.media.ic_public_contacts") })

                Column() {
                  TextInput({
                    placeholder: $r("app.string.name"),
                    text: this.mPresenter.contactInfoBefore.display_name
                  })
                    .margin({ right: $r("app.float.id_card_margin_max") })
                    .fontSize($r("sys.float.ohos_id_text_size_body1"))
                    .caretColor($r("sys.color.ohos_id_color_connected"))
                    .type(InputType.Normal)
                    .maxLength(256)
                    .height($r("app.float.id_item_height_large"))
                    .flexGrow(1)
                    .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
                    .onChange((value) => {
                      this.mPresenter.contactInfoAfter.display_name = value;
                      this.mPresenter.textChange(value);
                    })
                }
                .margin(this.curBp === 'lg' ? {} : { left: $r("app.float.id_card_margin_mid") })
              }
            }
            .listItemFancy($r("app.float.id_card_margin_xxl"))

            ListItem() {
              Column() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_contacts_company") })

                  Column() {
                    TextInput({
                      placeholder: $r("app.string.company"),
                      text: this.mPresenter.contactInfoBefore.company
                    })
                      .margin({ right: $r("app.float.id_card_margin_max") })
                      .fontSize($r("sys.float.ohos_id_text_size_body1"))
                      .caretColor($r("sys.color.ohos_id_color_connected"))
                      .type(InputType.Normal)
                      .maxLength(256)
                      .height($r("app.float.id_item_height_large"))
                      .flexGrow(1)
                      .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
                      .onClick(() => {
                        this.mPresenter.isShowPosition = true;
                      })
                      .onChange((arg) => {
                        this.mPresenter.contactInfoAfter.company = arg.valueOf();
                        this.mPresenter.textChange(arg);
                      })
                  }
                  .margin(this.curBp === 'lg' ? {} : { left: $r("app.float.id_card_margin_mid") })
                }

                if (this.mPresenter.isShowPosition) {
                  Divider()
                    .padding({ left: "64vp", right: $r("app.float.id_card_margin_max") })
                    .height($r("app.float.account_Divider_height"))
                    .width("100%")
                    .color($r("sys.color.ohos_id_color_list_separator"))

                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    TextInput({
                      placeholder: $r("app.string.position"),
                      text: this.mPresenter.contactInfoBefore.position
                    })
                      .fontSize($r("sys.float.ohos_id_text_size_body1"))
                      .caretColor($r("sys.color.ohos_id_color_connected"))
                      .type(InputType.Normal)
                      .maxLength(256)
                      .height($r("app.float.id_item_height_large"))
                      .flexGrow(1)
                      .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
                      .onChange((arg) => {
                        this.mPresenter.contactInfoAfter.position = arg.valueOf();
                        this.mPresenter.textChange(arg);
                      })
                      .margin({ left: "48vp",
                        right: $r("app.float.id_card_margin_max") })
                  }
                }
              }
            }
            .listItemFancy()

            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                ImageItemLeft({ mImage: $r("app.media.ic_public_phone") })

                Column() {
                  ForEach(this.updataShow ? this.mPresenter.getPhones
                                          : this.mPresenter.getArray(this.mPresenter.contactInfoBefore.phones)
                    , (item) => {
                      ItemList({
                        mPresent: $mPresenter,
                        index: item?.i,
                        typeName: "phone",
                        placeholder: $r("app.string.phone_number")
                      })
                    }, item => item.i.toString())

                  AddItem({ mPresent: $mPresenter,
                    labelName: $r("app.string.add_more"),
                    typeName: "phone" });

                }.alignItems(HorizontalAlign.Start)
              }
            }
            .listItemFancy()

            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                ImageItemLeft({ mImage: $r("app.media.ic_public_email") })

                Column() {
                  ForEach(this.updataShow ? this.mPresenter.getEmails
                                          : this.mPresenter.getArray(this.mPresenter.contactInfoBefore.emails)
                    , (item) => {
                      ItemList({
                        mPresent: $mPresenter,
                        index: item?.i,
                        typeName: "email",
                        placeholder: $r("app.string.email")
                      })
                    }, item => item.i.toString())

                  AddItem({ mPresent: $mPresenter,
                    labelName: $r("app.string.add_more"),
                    typeName: "email" });

                }
                .alignItems(HorizontalAlign.Start)
              }
            }
            .listItemFancy()

            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start }) {
                ImageItemLeft({ mImage: $r("app.media.ic_public_dwonload") })

                Column() {
                  Text($r("app.string.remarks"))
                    .fontSize($r("sys.float.ohos_id_text_size_body1"))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                    .height($r("app.float.id_item_height_large"))
                    .padding({ left: $r("app.float.id_card_margin_mid") })
                    .margin({ left: $r("app.float.id_card_margin_xxl") })
                }
                .flexShrink(0)
                .alignItems(HorizontalAlign.Start)
                .width($r("app.float.account_listItem_text_common_width"))

                Column() {
                  TextInput({
                    placeholder: $r("app.string.remarks"),
                    text: StringUtil.isEmpty(this.mPresenter.contactInfoBefore.remarks)
                      ? ""
                      : this.mPresenter.contactInfoBefore.remarks
                  })
                    .margin({ left: $r("app.float.id_card_margin_xxl"),
                      right: $r("app.float.id_card_margin_max") })
                    .fontSize($r("sys.float.ohos_id_text_size_body1"))
                    .caretColor($r("sys.color.ohos_id_color_connected"))
                    .type(InputType.Normal)
                    .maxLength(256)
                    .height($r("app.float.id_item_height_large"))
                    .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
                    .onChange((arg) => {
                      this.mPresenter.contactInfoAfter.remarks = arg.valueOf();
                      this.mPresenter.textChange(arg);
                    })
                }
                .flexShrink(1)
              }
            }
            .listItemFancy()

            if (!this.mPresenter.showMore) {
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_public_add_norm"), moreFlag: true })

                  Column() {
                    Text($r("app.string.addmore"))
                      .fontSize($r("sys.float.ohos_id_text_size_body1"))
                      .height($r("app.float.id_item_height_large"))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r("sys.color.ohos_id_color_connected"))
                      .margin({ left: $r("app.float.id_card_margin_xxl") })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .flexGrow(1)
                }
              }
              .onClick(() => {
                this.mPresenter.showMore = true;
              })
              .listItemFancy()
            }
            if (this.mPresenter.showMore) {
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_public_message") })

                  Column() {
                    ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.aims)
                      , (item) => {
                        ItemList({
                          mPresent: $mPresenter,
                          index: item.i,
                          typeName: "AIM",
                          placeholder: $r("app.string.instant_messaging")
                        })
                      }, item => item.i.toString())

                    AddItem({ mPresent: $mPresenter,
                      labelName: $r("app.string.add_more"),
                      typeName: "AIM" });

                  }.alignItems(HorizontalAlign.Start)
                }
              }
              .listItemFancy()

              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_public_home") })

                  Column() {
                    ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.houses)
                      , (item) => {
                        ItemList({
                          mPresent: $mPresenter,
                          index: item.i,
                          typeName: "house",
                          placeholder: $r("app.string.address_add")
                        })
                      }, item => item.i.toString())

                    AddItem({ mPresent: $mPresenter,
                      labelName: $r("app.string.add_more"),
                      typeName: "house" });

                  }.alignItems(HorizontalAlign.Start)
                }
              }
              .listItemFancy()

              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_contacts_nickname") })

                  Column() {
                    Text($r("app.string.nickname"))
                      .fontSize($r("sys.float.ohos_id_text_size_body1"))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r("sys.color.ohos_id_color_text_primary"))
                      .height($r("app.float.id_item_height_large"))
                      .padding({ left: $r("app.float.id_card_margin_mid") })
                      .margin({ left: $r("app.float.id_card_margin_xxl") })
                  }
                  .flexShrink(0)
                  .alignItems(HorizontalAlign.Start)
                  .width($r("app.float.account_listItem_text_common_width"))

                  Column() {
                    TextInput({
                      placeholder: $r("app.string.nickname"),
                      text: StringUtil.isEmpty(this.mPresenter.contactInfoBefore.nickname)
                        ? ""
                        : this.mPresenter.contactInfoBefore.nickname
                    })
                      .margin({ left: $r("app.float.id_card_margin_xxl"),
                        right: $r("app.float.id_card_margin_max") })
                      .fontSize($r("sys.float.ohos_id_text_size_body1"))
                      .caretColor($r("sys.color.ohos_id_color_connected"))
                      .type(InputType.Normal)
                      .maxLength(256)
                      .height($r("app.float.id_item_height_large"))
                      .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
                      .onChange((arg) => {
                        this.mPresenter.contactInfoAfter.nickname = arg.valueOf();
                        this.mPresenter.textChange(arg);
                      })
                  }
                  .flexShrink(1)
                }
              }
              .listItemFancy()

              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_public_worldclock") })

                  Column() {
                    Text($r("app.string.website"))
                      .fontSize($r("sys.float.ohos_id_text_size_body1"))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r("sys.color.ohos_id_color_text_primary"))
                      .height($r("app.float.id_item_height_large"))
                      .padding({ left: $r("app.float.id_card_margin_mid") })
                      .margin({ left: $r("app.float.id_card_margin_xxl") })
                  }
                  .flexShrink(0)
                  .alignItems(HorizontalAlign.Start)
                  .width($r("app.float.account_listItem_text_common_width"))

                  Column() {
                    TextInput({
                      placeholder: $r("app.string.website"),
                      text: ArrayUtil.isEmpty(this.mPresenter.contactInfoBefore.websites)
                        ? ""
                        : this.mPresenter.contactInfoAfter.websites[0]
                    })
                      .margin({ left: $r("app.float.id_card_margin_xxl"),
                        right: $r("app.float.id_card_margin_max") })
                      .fontSize($r("sys.float.ohos_id_text_size_body1"))
                      .caretColor($r("sys.color.ohos_id_color_connected"))
                      .type(InputType.Normal)
                      .maxLength(256)
                      .height($r("app.float.id_item_height_large"))
                      .flexGrow(1)
                      .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
                      .onChange((arg) => {
                        this.mPresenter.contactInfoBefore.websites = [arg.valueOf()];
                        this.mPresenter.textChange(arg);
                      })
                  }
                  .flexShrink(1)
                }
              }
              .listItemFancy()

              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_contacts_birthday") })

                  Column() {
                    ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.events)
                      , (item) => {
                        ItemEvent({
                          mPresent: $mPresenter,
                          controller: this.dialogController,
                          index: item.i,
                          itemIndex: $eventItemId,
                          eventType: $eventType,
                          typeName: "events"
                        });
                      }, item => item.i.toString())

                    AddItem({ mPresent: $mPresenter,
                      labelName: $r("app.string.add_more"),
                      typeName: "events" });

                  }.alignItems(HorizontalAlign.Start)
                }
              }
              .listItemFancy()

              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_contacts_assistant") })

                  Column() {
                    ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.relationships)
                      , (item) => {
                        ItemList({
                          mPresent: $mPresenter,
                          index: item.i,
                          typeName: "relationships",
                          placeholder: $r("app.string.relation")
                        })
                      }, item => item.i.toString())

                    AddItem({ mPresent: $mPresenter,
                      labelName: $r("app.string.add_more"),
                      typeName: "relationships" });

                  }.alignItems(HorizontalAlign.Start)
                }
              }
              .listItemFancy()
            }

            if (this.updataShow) {
              ListItem() {
                Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
                  Text($r("app.string.from_the_accounts"))
                    .fontSize($r("sys.float.ohos_id_text_size_body2"))
                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                    .fontWeight(FontWeight.Regular)
                    .margin({
                      top: $r("app.float.id_card_margin_max"),
                      left: $r("app.float.id_card_margin_max")
                    })
                    .opacity(0.6)

                  Text($r("app.string.phone"))
                    .fontSize($r("sys.float.ohos_id_text_size_body2"))
                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                    .fontWeight(FontWeight.Regular)
                    .margin({
                      top: "8vp",
                      left: $r("app.float.id_card_margin_max"),
                      bottom: $r("app.float.id_card_margin_max")
                    })
                }
              }
              .width("100%")
            }
          }
          .scrollBar(BarState.Off)
          .width("100%")
          .alignListItem(ListItemAlign.Center)
        }
      }
      .height('100%')
      .flexShrink(1)
    }
    .onTouch(() => {
      this.mPresenter.hideKeyboard();
    })
    .padding({ left: 12, right: 12 })
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}