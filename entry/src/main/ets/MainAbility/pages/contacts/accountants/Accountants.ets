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
import ArrayUtil from "../../../util/ArrayUtil";
import ObjectUtil from "../../../util/ObjectUtil";
import StringUtil from "../../../util/StringUtil";
import EnvironmentProp from "../../../feature/EnvironmentProp";
import HiLog from '../../../util/Hilog';
import { EventBean } from "../../../model/bean/EventBean";
import { PhoneNumBean } from "../../../model/bean/PhoneNumBean";
import AccountantsPresenter from '../../../presenter/contact/accountants/AccountantsPresenter';

const TAG = 'AddContact  ';

/**
 * Add Contact
 */
@Extend(ListItem) function listItemFancy (topMargin = $r("app.float.id_card_image_xs")) {
  .borderRadius($r("app.float.id_corner_radius_card"))
  .width("100%")
  .margin({ top: topMargin })
  .padding({
    top: $r("app.float.id_card_margin_mid"),
    bottom: $r("app.float.id_card_margin_mid")
  })
  .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
}

@Entry
@Component
struct Accountants {
  @State  mPresenter: AccountantsPresenter = AccountantsPresenter.getInstance();
  @State  eventItemId: number = 0;
  private updataShow = false;
  private pageTitle: Resource = $r("app.string.create_contact");
  dialogController: CustomDialogController = new CustomDialogController({
    builder: showDayTime({ mPresent: $mPresenter,
      cancel: this.onCancel,
      confirm: this.onAccept,
      itemIndex: this.eventItemId }),
    cancel: this.existApp,
    autoCancel: true
  })

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
    this.mPresenter.init();
    if (!ObjectUtil.isEmpty(router.getParams())) {
      let obj: any = router.getParams();
      if (obj.hasOwnProperty("updataShow")) {
        this.updataShow = obj.updataShow;
      }
      if (obj.hasOwnProperty("phoneNumbers") && !ArrayUtil.isEmpty(obj.phoneNumbers)) {
        let phoTemp = [new PhoneNumBean("1", obj.phoneNumbers[0].phoneNumber, "1", "", "")];
        this.mPresenter.contactInfoAfter.setPhones(phoTemp)
      }
    }
    if (this.updataShow == true) {
      this.pageTitle = $r("app.string.edit_contact");
      let obj: any = router.getParams().contactForm;
      this.mPresenter.contactId = obj.id;
      this.mPresenter.updateShow = true;
      this.mPresenter.updatesInit();
    }
    HiLog.i(TAG, "the Page aboutToAppear End");
  }

  onPageShow() {
    this.mPresenter.refresh();
  }

  @State mSizeType: SizeType = EnvironmentProp.isTablet() ? SizeType.LG : SizeType.SM;
  @State mColumns: number = EnvironmentProp.isTablet() ? 12 : 4;
  @State mGutter: number = EnvironmentProp.isTablet() ? 12 : 12;
  @State mMargin: number = EnvironmentProp.isTablet() ? 12 : 12;

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      GridContainer({
        columns: this.mColumns,
        sizeType: this.mSizeType,
        gutter: this.mGutter,
        margin: this.mMargin
      }) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
          Flex() {
            Navigator({ target: 'pages/contacts/details/ContactDetail', type: NavigationType.Replace }) {
            }
            .active(this.mPresenter.routerAvtiveFlag)
            .params({
              sourceHasId: true,
              contactId: this.mPresenter.contactId
            })
          }.visibility(Visibility.None)
          .useSizeType({
            xs: { span: 4, offset: 0 },
            sm: { span: 4, offset: 0 },
            md: { span: 4, offset: 0 },
            lg: { span: 12, offset: 0 }
          })

          Row() {
            Column() {
              Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                Image($r("app.media.ic_public_cancel"))
                  .height($r("app.float.id_card_image_small"))
                  .width($r("app.float.id_card_image_small"))
                  .margin({ top: $r("app.float.id_card_margin_xxl"),
                    bottom: $r("app.float.id_card_margin_xxl"),
                    right: $r("app.float.id_card_margin_xxl"),
                    left: $r("app.float.id_card_margin_max") })
                  .fillColor($r("sys.color.ohos_id_color_primary"))
                  .onClick(() => {
                    router.back()
                  })
                Text(this.pageTitle)
                  .margin({ top: "13vp",
                    bottom: "15vp" })
                  .lineHeight("28vp")
                  .fontSize("20fp")
                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
                  .fontWeight(FontWeight.Bold)
              }
            }
            .height($r("app.float.id_item_height_large"))
            .width("50%")

            Column() {
              Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
                Image($r("app.media.ic_public_ok"))
                  .width($r("app.float.id_card_image_small"))
                  .padding({ top: $r("app.float.id_card_margin_xxl"),
                    bottom: $r("app.float.id_card_margin_xxl") })
                  .margin({ right: $r("app.float.id_card_margin_max") })
                  .fillColor(this.mPresenter.getAddState()
                    ? $r("sys.color.ohos_id_color_primary")
                    : $r("sys.color.ohos_id_color_tertiary"))
                  .onClick(() => {
                    this.mPresenter.saveContact();
                  })
              }
            }
            .height($r("app.float.id_item_height_large"))
            .width("50%")
          }
          .flexShrink(0)
          .useSizeType({
            xs: { span: 4, offset: 0 },
            sm: { span: 4, offset: 0 },
            md: { span: 4, offset: 0 },
            lg: { span: 8, offset: 2 }
          })

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
                      this.mPresenter.addState = true;
                      this.mPresenter.contactInfoAfter.display_name = value;
                    })
                }
              }
            }
            .listItemFancy($r("app.float.id_card_margin_xxl"))

            ListItem() {
              Column() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start }) {
                  ImageItemLeft({ mImage: $r("app.media.ic_contacts_company") })

                  Column() {
                    TextInput({
                      placeholder: $r("app.string.house_type_position"),
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
                      .onChange((arg) => {
                        this.mPresenter.addState = true;
                        this.mPresenter.contactInfoAfter.company = arg.valueOf();
                        if (!StringUtil.isEmpty(arg.valueOf())) {
                          this.mPresenter.isShowPosition = true;
                        }
                      })
                  }
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
                        this.mPresenter.addState = true;
                        this.mPresenter.contactInfoAfter.position = arg.valueOf();
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
                  ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.phones)
                    , (item) => {
                      ItemList({
                        mPresent: $mPresenter,
                        data: item,
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
                  ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.emails)
                    , (item) => {
                      ItemList({
                        mPresent: $mPresenter,
                        data: item,
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
                      this.mPresenter.addState = true;
                      this.mPresenter.contactInfoAfter.remarks = arg.valueOf();
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
                          data: item,
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
                          data: item,
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
                        this.mPresenter.addState = true;
                        this.mPresenter.contactInfoAfter.nickname = arg.valueOf();
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
                        this.mPresenter.addState = true;
                        this.mPresenter.contactInfoBefore.websites = [arg.valueOf()];
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
                          data: item,
                          itemIndex: $eventItemId,
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
                          data: item,
                          typeName: "relationships",
                          placeholder: $r("app.string.relationship_type_assistant")
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
          .scrollBar(BarState.On)
          .width("100%")
          .flexShrink(1)
          .alignSelf(ItemAlign.Start)
          .useSizeType({
            xs: { span: 4, offset: 0 },
            sm: { span: 4, offset: 0 },
            md: { span: 4, offset: 0 },
            lg: { span: 8, offset: 2 }
          })
        }
        .height('100%')
      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}

/**
 * Add Date Pop-up
 */
@CustomDialog
struct showDayTime {
  private date = new Date(2000, 0, 1);
  @Link mPresent: any;
  @Prop itemIndex: number;
  @State
  private showTime: string = this.date.getUTCFullYear() + "年" + (this.date.getMonth() + 1) + "月" + this.date.getDate() + "日";
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  build() {
    Column() {
      Text(this.showTime)
        .height("50vp")
        .width('70%')
        .fontSize(20)
        .margin({ top: 10, bottom: 10 })
        .textAlign(TextAlign.Center)

      DatePicker({ selected: this.date })
        .width("85%")
        .height("200vp")
        .onChange((arg) => {
          this.date = new Date(arg.year, arg.month, arg.day);
          this.showTime = arg.year + "年" + (arg.month + 1) + "月" + arg.day + "日";
        })

      Row() {
        Button($r("app.string.dialog_cancel"))
          .width("50%")
          .onClick(() => {
            this.controller.close()
            this.cancel()
          })
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
        Button($r("app.string.save"))
          .width("50%")
          .onClick(() => {
            this.mPresent.addState = true;
            if (StringUtil.isEmpty(this.mPresent.contactInfoAfter.events[this.itemIndex].eventType)) {
              this.mPresent.contactInfoAfter.events[this.itemIndex] = new EventBean("", "", "1", "");
            }
            this.mPresent.contactInfoAfter.events[this.itemIndex].data = this.showTime;
            this.mPresent.refresh();
            this.controller.close();
            this.confirm();
          })
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
      }
      .height("50vp")
      .width('70%')
    }.height("350vp")
  }
}

@Component
struct ItemList {
  @Link mPresent: any;
  private data: any;
  private typeName: any;
  private placeholder: Resource;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Column() {
        Row() {
          Text(this.mPresent.menuSelect(
            this.typeName,
            this.data
          ))
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .fontWeight(FontWeight.Medium)
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .maxLines(1)
            .constraintSize({ minWidth: $r("app.float.account_ItemList_text_width") })
            .bindMenu(this.MenuBuilder)

          Image($r("app.media.ic_public_spinner"))
            .objectFit(ImageFit.Contain)
            .height($r("app.float.id_card_image_small"))
            .width($r("app.float.id_card_image_xs"))
        }
        .height($r("app.float.id_item_height_sm"))
        .constraintSize({ minWidth: $r("app.float.account_listItem_text_common_width") })
      }
      .flexShrink(0)

      Column() {
        Row() {
          Column() {
            TextInput({
              placeholder: this.placeholder,
              text: this.mPresent.getTextDisplay(this.typeName, this.data)
            })
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .caretColor($r("sys.color.ohos_id_color_connected"))
              .type((this.typeName === "phone") ? InputType.Number : InputType.Normal)
              .maxLength(256)
              .height("98%")
              .backgroundColor($r("sys.color.ohos_id_color_list_card_bg"))
              .onChange((arg) => {
                this.mPresent.addState = true;
                this.mPresent.listItemChange(this.typeName, this.data, arg.toString())
              })
          }
          .alignItems(HorizontalAlign.Start)
          .flexShrink(1)

          Column() {
            Image($r("app.media.ic_public_close_filled"))
              .objectFit(ImageFit.Contain)
              .height($r("app.float.id_card_image_small"))
              .width($r("app.float.id_card_image_small"))
              .fillColor($r("sys.color.ohos_id_color_tertiary"))
              .onClick(() => {
                this.mPresent.deleteItem(this.typeName, this.data.i - 1);
              })
          }
          .flexShrink(0)
        }

        Divider()
          .padding({ left: $r("app.float.id_card_margin_xxl") })
          .height($r("app.float.account_Divider_height"))
          .width("100%")
          .color($r("sys.color.ohos_id_color_list_separator"))
      }
      .alignItems(HorizontalAlign.Start)
      .height($r("app.float.id_item_height_large"))
    }
    .margin({ left: $r("app.float.id_card_margin_xxl"),
      right: $r("app.float.id_card_margin_max") })
  }

  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      ForEach(this.mPresent.getMenuList(this.typeName),
        (item) => {
          Text(item.labelRes)
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .width($r("app.float.account_MenuBuilder_width"))
            .height($r("app.float.id_item_height_mid"))
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .textAlign(TextAlign.Start)
            .margin({ left: $r("app.float.id_card_margin_xxl") })
            .onClick(() => {
              this.mPresent.menuChange(this.typeName, this.data, item);
            })

          Divider()
            .height($r("app.float.account_Divider_height"))
            .width($r("app.float.account_Divider_width"))
            .color($r("sys.color.ohos_id_color_list_separator"))
        },
        (item) => item.rawValue.toString())
    }
    .width($r("app.float.account_MenuBuilder_width"))
    .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
  }
}

@Component
struct ItemEvent {
  @Link mPresent: any;
  @Link itemIndex: number;
  private controller: any;
  private data: any;
  private typeName: any;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Column() {
        Row() {
          Text(this.mPresent.menuSelect(
            this.typeName,
            this.data
          ))
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .fontWeight(FontWeight.Medium)
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .textOverflow({ overflow: TextOverflow.None })
            .maxLines(1)
            .constraintSize({ minWidth: $r("app.float.account_ItemList_text_width") })
            .bindMenu(this.MenuBuilder)

          Image($r("app.media.ic_public_spinner"))
            .objectFit(ImageFit.Contain)
            .height($r("app.float.id_card_image_small"))
            .width($r("app.float.id_card_image_xs"))
        }
        .height($r("app.float.id_item_height_sm"))
        .constraintSize({ minWidth: $r("app.float.account_listItem_text_common_width") })
      }

      Column() {
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
          Column() {
            Text(
              StringUtil.isEmpty(this.mPresent.getTextDisplay(this.typeName, this.data))
                ? $r("app.string.birthday_type_grebirthday")
                : this.mPresent.getTextDisplay(this.typeName, this.data)
            )
              .margin({ left: $r("app.float.id_card_margin_xxl") })
              .height($r("app.float.id_item_height_large"))
              .fontSize($r("sys.float.ohos_id_text_size_body1"))
              .fontColor(
                StringUtil.isEmpty(this.mPresent.getTextDisplay(this.typeName, this.data))
                  ? $r("sys.color.ohos_id_color_text_secondary")
                  : $r("sys.color.ohos_id_color_text_primary")
              )
          }
          .alignItems(HorizontalAlign.Start)
          .flexGrow(1)
          .onClick(() => {
            this.itemIndex = this.data.i - 1;
            this.controller.open()
          })

          Column() {
            Image($r("app.media.ic_public_close_filled"))
              .objectFit(ImageFit.Contain)
              .height($r("app.float.id_card_image_small"))
              .width($r("app.float.id_card_image_small"))
              .fillColor($r("sys.color.ohos_id_color_tertiary"))
              .onClick(() => {
                this.mPresent.deleteItem(this.typeName, this.data.i - 1);
              })
          }
        }

        Divider()
          .padding({ left: $r("app.float.id_card_margin_xxl") })
          .height($r("app.float.account_Divider_height"))
          .width("100%")
          .color($r("sys.color.ohos_id_color_list_separator"))
      }
      .alignItems(HorizontalAlign.Start)
      .height($r("app.float.id_item_height_large"))
    }
    .margin({ left: $r("app.float.id_card_margin_xxl"),
      right: $r("app.float.id_card_margin_max") })
  }

  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      ForEach(this.mPresent.getMenuList(this.typeName),
        (item) => {
          Text(item.labelRes)
            .fontSize($r("sys.float.ohos_id_text_size_body1"))
            .width("156vp")
            .height($r("app.float.id_item_height_mid"))
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .textAlign(TextAlign.Start)
            .margin({ left: $r("app.float.id_card_margin_xxl") })
            .onClick(() => {
              this.mPresent.menuChange(this.typeName, this.data, item);
            })

          Divider()
            .height($r("app.float.account_Divider_height"))
            .width($r("app.float.account_Divider_width"))
            .color($r("sys.color.ohos_id_color_list_separator"))
        },
        (item) => item.rawValue.toString())
    }
    .width($r("app.float.account_MenuBuilder_width"))
    .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
  }
}

@Component
struct AddItem {
  @Link mPresent: any;
  private labelName: Resource;
  private typeName: string;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Column() {
        Text(this.labelName)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .fontColor($r("sys.color.ohos_id_color_text_secondary"))
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)

      Column() {
        Image($r("app.media.ic_public_add_norm_filled"))
          .objectFit(ImageFit.Contain)
          .height($r("app.float.id_card_image_small"))
          .width($r("app.float.id_card_image_small"))
          .fillColor($r("sys.color.ohos_id_color_tertiary"))
          .onClick(() => {
            this.mPresent.addMore(this.typeName);
          })
      }
      .margin({ right: $r("app.float.id_card_margin_max") })
      .alignItems(HorizontalAlign.End)
    }
    .margin({ left: $r("app.float.id_card_margin_xxl") })
    .height($r("app.float.id_item_height_large"))
  }
}

@Component
struct ImageItemLeft {
  private mImage: Resource;
  private moreFlag?: Boolean = false;

  build() {
    Column() {
      Image(this.mImage)
        .objectFit(ImageFit.Contain)
        .height($r("app.float.id_card_image_small"))
        .width($r("app.float.id_card_image_small"))
        .margin({ left: $r("app.float.id_card_margin_max") })
        .fillColor(this.moreFlag
          ? $r("sys.color.ohos_id_color_connected")
          : $r("sys.color.ohos_id_color_secondary"))
    }
    .height($r("app.float.id_item_height_large"))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }
}