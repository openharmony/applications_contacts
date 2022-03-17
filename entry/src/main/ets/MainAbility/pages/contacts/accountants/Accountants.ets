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

import resourceManager from '@ohos.resourceManager';
import router from '@system.router';
import util from "../../../util/Utils";
import HiLog from '../../../util/Hilog';
import {EmailBean} from "../../../model/bean/EmailBean";
import {ContactInfo} from "../../../model/bean/ContactInfo";
import {PhoneNumBean} from "../../../model/bean/PhoneNumBean";
import {GroupBean} from "../../../model/bean/GroupBean";
import {HouseBean} from "../../../model/bean/HouseBean";
import {EventBean} from "../../../model/bean/EventBean";
import {RelationBean} from "../../../model/bean/RelationBean";
import {AIMBean} from "../../../model/bean/AIMBean";
import {AssociatedPersonBean} from "../../../model/bean/AssociatedPersonBean";
import ContactAbility from '../../../model/ContactAbilityModel';
import AccountantsPresenter from '../../../presenter/contact/accountants/AccountantsPresenter';
import Constants, {DeviceType} from '../../../model/common/Constants';

const TAG = 'AddContact  ';

/**
 * 添加联系人外层容器
 */
@Entry
@Component
struct Accountants {
  /**
     * 联系人Id
     */
  private contactId = "";
  @State  private routerAvtiveFlag: boolean = false;
  @State  mPresenter: AccountantsPresenter = AccountantsPresenter.getInstance();

  /**
   * 是否展示职位
   */
  @State private isShowPosition: boolean = false;
  /**
   * 是否展示更多
   */
  @State private showMore: boolean = false;
  private updataShow = false;
  private pageTitle: Resource = $r("app.string.create_contact");

  /**
     * 弹窗添加日期
     */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: showDayTime({ mPresent: $mPresenter, cancel: this.onCancel, confirm: this.onAccept }),
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
    if (!util.isEmptyObject(router.getParams())) {
      let obj = router.getParams();
      if (obj.hasOwnProperty("updataShow")) {
        this.updataShow = obj.updataShow;
      }
      if (obj.hasOwnProperty("phoneNumbers") && !util.isEmptyList(obj.phoneNumbers)) {
        let phoTemp = [new PhoneNumBean("1", obj.phoneNumbers[0].phoneNumber, "1", "", "")];
        this.mPresenter.contactInfoBefore.setPhones(phoTemp)
      }
    }
    if (this.updataShow == true) {
      this.pageTitle = $r("app.string.edit_contact");
      let obj = router.getParams().contactForm;
      this.mPresenter.contactId = obj.id;
      this.mPresenter.updateShow = true;
      this.mPresenter.updatesInit();
    }
    HiLog.i(TAG, "the Page aboutToAppear End");
  }

  onPageShow() {
    this.mPresenter.refresh();
  }

  @State mSizeType: SizeType = Constants.deviceType == DeviceType.WGR ? SizeType.LG : SizeType.SM;
  @State mColumns: number = Constants.deviceType == DeviceType.WGR ? 12 : 4;
  @State mGutter: number = Constants.deviceType == DeviceType.WGR ? 12 : 12;
  @State mMargin: number = Constants.deviceType == DeviceType.WGR ? 12 : 12;

  build() {

    //container
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      GridContainer({
        columns: this.mColumns,
        sizeType: this.mSizeType,
        gutter: this.mGutter,
        margin: this.mMargin
      }) {
        //container
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
          // 路由跳转管理
          Flex() {
            Navigator({ target: 'pages/contacts/details/ContactDetail', type: NavigationType.Replace }) {
            }
            .active(this.routerAvtiveFlag)
            .params({
              contactId: this.contactId,
              phoneNumber: util.isEmptyList(this.mPresenter.contactInfoAfter.phones) ? "" : this.mPresenter.contactInfoAfter.phones[0].num,
              homeLocation: "",
              carries: "",
              isNewSource: true
            })
          }.visibility(Visibility.None)
          //头部提交
          //title
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            //cancel img
            Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
              Image($r("app.media.ic_public_cancel"))
                .height('24vp')
                .width('24vp')
                .margin({ top: "16vp", bottom: "16vp", right: "16vp", left: "24vp" })
                .onClick(() => {
                  router.back()
                })
              Text(this.pageTitle)
                .margin({ top: "13vp", bottom: "15vp" })
                .lineHeight("28vp")
                .fontSize("20fp")
                .fontColor($r("app.color.colorPrimary"))
                .fontWeight("Bold")
            }
            .height("56vp")
            .width("50%")

            //comfirm img 保存按钮
            Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
              Image($r("app.media.ic_public_ok"))
                .height("24vp")
                .width("24vp")
                .margin({ right: "24vp" })
                .onClick(() => {
                  var tempInfo = this.mPresenter.contactInfoAfter;
                  if (this.mPresenter.isEmptyInfo(tempInfo)) {
                    if (this.updataShow == false) {
                      ContactAbility.addContact(tempInfo, null, (arg) => {
                        this.contactId = arg.toString();
                        this.routerAvtiveFlag = true;
                      })
                    }
                    else {
                      tempInfo.id = this.mPresenter.contactId;
                      ContactAbility.updateContact(null, tempInfo, (arg) => {
                        this.contactId = arg.toString();
                        this.routerAvtiveFlag = true;
                      })
                    }
                  }
                })
            }
            .height("56vp")
            .width("50%")
          }
          .width('100%')
          .height("56vp")
          .useSizeType({
            xs: { span: 4, offset: 0 },
            sm: { span: 4, offset: 0 },
            md: { span: 4, offset: 0 },
            lg: { span: 12, offset: 0 }
          })

          /**
         * 添加联系人输入
         */
          List() {
            // 头像
            ListItem() {
              Flex({
                direction: FlexDirection.Column,
                alignItems: ItemAlign.Center,
                justifyContent: FlexAlign.Center
              }) {
                Image($r("app.media.ic_user_portrait"))
                  .height("56vp")
                  .width("56vp")
                  .objectFit(ImageFit.Contain)

                Text($r("app.string.save_to_phone"))
                  .lineHeight("21vp")
                  .fontSize("16fp")
                  .fontColor($r("app.color.colorPrimary"))
                  .fontWeight("Medium")
                  .margin({ top: "18vp" })

              }
              .height("144vp")
            }

            //姓名
            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                Image($r("app.media.ic_public_contacts"))
                  .margin({ left: "24vp", top: "19vp", bottom: "21vp" })
                  .height("24vp")
                  .width("24vp")
                  .objectFit(ImageFit.Contain);
                TextInput({
                  placeholder: $r("app.string.name_hock"),
                  text: this.mPresenter.contactInfoBefore.display_name
                })
                  .margin({ left: "16" })
                  .fontSize("16fp")
                  .caretColor($r("app.color.colorConnected"))
                  .type(InputType.Normal)
                  .maxLength(256)
                  .height("56vp")
                  .flexGrow(1)
                  .onChange((value) => {
                    this.mPresenter.contactInfoAfter.display_name = value;
                  })
              }
            }
            .borderRadius("24vp")
            .height("64vp")
            .width("100%")
            .margin({ top: "16vp" })
            .backgroundColor("#FFFFFF");

            //公司
            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                Image($r("app.media.ic_contacts_company"))
                  .margin({ left: "24vp", top: "19vp", bottom: "21vp" })
                  .height("24vp")
                  .width("24vp")
                  .objectFit(ImageFit.Contain)
                TextInput({
                  placeholder: $r("app.string.house_type_position_hock"),
                  text: this.mPresenter.contactInfoBefore.company
                })
                  .margin({ left: "16" })
                  .fontSize("16fp")
                  .caretColor($r("app.color.colorConnected"))
                  .type(InputType.Normal)
                  .maxLength(256)
                  .height("56vp")
                  .flexGrow(1)
                  .onChange((arg) => {
                    this.mPresenter.contactInfoAfter.company = arg.valueOf();
                    if (!util.isEmpty(arg.valueOf())) {
                      this.isShowPosition = true;
                    }
                  });
              }
            }
            .borderRadius("24vp")
            .height("64vp")
            .width("100%")
            .margin({ top: "12vp" })
            .backgroundColor("#FFFFFF")

            if (this.isShowPosition) {
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                  TextInput({
                    placeholder: $r("app.string.position_hock"),
                    text: this.mPresenter.contactInfoBefore.position
                  })
                    .fontSize("16fp")
                    .caretColor($r("app.color.colorConnected"))
                    .type(InputType.Normal)
                    .maxLength(256)
                    .height("56vp")
                    .flexGrow(1)
                    .onChange((arg) => {
                      this.mPresenter.contactInfoAfter.position = arg.valueOf();
                    })
                    .margin({ left: "64vp" })
                }
              }
              .margin({ top: "12vp" })
              .borderRadius("24vp")
              .height("64vp")
              .width("100%")
              .backgroundColor("#FFFFFF")
            }
            //手机
            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                Column() {
                  Image($r("app.media.ic_public_phone"))
                    .objectFit(ImageFit.Contain)
                    .height("24vp")
                    .width("24vp")
                    .margin({ left: "24vp", top: "19vp", bottom: "21vp", right: "0vp" })
                }
                .alignItems(HorizontalAlign.Start)
                .alignSelf(ItemAlign.Start)

                Column() {
                  ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.phones)
                    , (item) => {
                      ItemList({
                        mPresent: $mPresenter,
                        data: item,
                        typeName: "phone",
                        placeholder: $r("app.string.phone_number_hock")
                      })
                    }, item => item.i.toString())

                  AddItem({ mPresent: $mPresenter,
                    labelName: $r("app.string.add_more"),
                    typeName: "phone" });

                }.alignItems(HorizontalAlign.Start)
              }
            }
            .borderRadius("24vp")
            .width("100%")
            .margin({ top: "12vp" })
            .backgroundColor("#FFFFFF")
            //邮件
            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                Column() {
                  Image($r("app.media.ic_public_email"))
                    .objectFit(ImageFit.Contain)
                    .height("24vp")
                    .width("24vp")
                    .margin({ left: "24vp", top: "19vp", bottom: "21vp", right: "0vp" })
                }
                .alignItems(HorizontalAlign.Start)
                .alignSelf(ItemAlign.Start)

                Column() {
                  ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.emails)
                    , (item) => {
                      ItemList({
                        mPresent: $mPresenter,
                        data: item,
                        typeName: "email",
                        placeholder: $r("app.string.email_hock")
                      })
                    }, item => item.i.toString())

                  AddItem({ mPresent: $mPresenter,
                    labelName: $r("app.string.add_more"),
                    typeName: "email" });

                }.alignItems(HorizontalAlign.Start)
              }
            }
            .borderRadius("24vp")
            .width("100%")
            .margin({ top: "12vp" })
            .backgroundColor("#FFFFFF")
            //备注
            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                Image($r("app.media.ic_public_drawer"))
                  .objectFit(ImageFit.Contain)
                  .margin({ left: "24vp", top: "19vp", bottom: "21vp" })
                  .height("24vp")
                  .width("24vp")

                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                  Text($r("app.string.remarks"))
                    .fontSize("16fp")
                    .lineHeight("22vp")
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r("app.color.colorPrimary"))
                }
                .margin({ left: "12vp" })
                .height("22vp")
                .width("72vp")

                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                  TextInput({
                    placeholder: $r("app.string.remarks_hock"),
                    text: util.isEmpty(this.mPresenter.contactInfoBefore.remarks)
                      ? ""
                      : this.mPresenter.contactInfoBefore.remarks
                  })
                    .fontSize("16fp")
                    .caretColor($r("app.color.colorConnected"))
                    .type(InputType.Normal)
                    .maxLength(256)
                    .height("56vp")
                    .onChange((arg) => {
                      this.mPresenter.contactInfoAfter.remarks = arg.valueOf();
                    })
                    .flexGrow(1)
                }
              }
            }
            .borderRadius("24vp")
            .height("64vp")
            .width("832vp")
            .margin({ top: "12vp" })
            .backgroundColor("#FFFFFF")

            if (!this.showMore) {
              //添加更多项
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                  Image($r("app.media.ic_public_add_norm"))
                    .objectFit(ImageFit.Contain)
                    .margin({ left: "24vp", top: "19vp", bottom: "21vp" })
                    .height("24vp")
                    .width("24vp")
                    .fillColor($r("app.color.colorConnected"))

                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    Text($r("app.string.addmore"))
                      .fontSize("16fp")
                      .lineHeight("22vp")
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r("app.color.colorConnected"))
                      .onClick(() => {
                        this.showMore = true;
                      })
                  }
                  .width("652vp")
                  .margin({ left: "12vp" })
                }
              }
              .borderRadius("24vp")
              .height("64vp")
              .width("832vp")
              .margin({ top: "16vp" })
              .backgroundColor("#FFFFFF");
            }
            if (this.showMore) {
              //即时消息
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                  Column() {
                    Image($r("app.media.ic_public_message"))
                      .objectFit(ImageFit.Contain)
                      .height("24vp")
                      .width("24vp")
                      .margin({ left: "24vp", top: "19vp", bottom: "21vp", right: "0vp" })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .alignSelf(ItemAlign.Start)

                  Column() {
                    ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.aims)
                      , (item) => {
                        ItemList({
                          mPresent: $mPresenter,
                          data: item,
                          typeName: "AIM",
                          placeholder: $r("app.string.instant_messaging_hock")
                        })
                      }, item => item.i.toString())

                    AddItem({ mPresent: $mPresenter,
                      labelName: $r("app.string.add_more"),
                      typeName: "AIM" });

                  }.alignItems(HorizontalAlign.Start)
                }
              }
              .borderRadius("24vp")
              .width("100%")
              .margin({ top: "12vp" })
              .backgroundColor("#FFFFFF")
              //住宅
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                  Column() {
                    Image($r("app.media.ic_public_home"))
                      .objectFit(ImageFit.Contain)
                      .height("24vp")
                      .width("24vp")
                      .margin({ left: "24vp", top: "19vp", bottom: "21vp", right: "0vp" })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .alignSelf(ItemAlign.Start)

                  Column() {
                    ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.houses)
                      , (item) => {
                        ItemList({
                          mPresent: $mPresenter,
                          data: item,
                          typeName: "house",
                          placeholder: $r("app.string.address_add_hock")
                        })
                      }, item => item.i.toString())

                    AddItem({ mPresent: $mPresenter,
                      labelName: $r("app.string.add_more"),
                      typeName: "house" });

                  }.alignItems(HorizontalAlign.Start)
                }
              }
              .borderRadius("24vp")
              .width("100%")
              .margin({ top: "12vp" })
              .backgroundColor("#FFFFFF")
              //昵称
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                  Image($r("app.media.ic_contacts_nickname"))
                    .objectFit(ImageFit.Contain)
                    .margin({ left: "24vp", top: "19vp", bottom: "21vp" })
                    .height("24vp")
                    .width("24vp")

                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    Text($r("app.string.nickname"))
                      .fontSize("16fp")
                      .lineHeight("22vp")
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r("app.color.colorPrimary"))
                  }
                  .margin({ left: "12vp" })
                  .height("22vp")
                  .width("72vp")

                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    TextInput({
                      placeholder: $r("app.string.nickname_hock"),
                      text: util.isEmpty(this.mPresenter.contactInfoBefore.nickname)
                        ? ""
                        : this.mPresenter.contactInfoBefore.nickname
                    })
                      .fontSize("16fp")
                      .caretColor($r("app.color.colorConnected"))
                      .type(InputType.Normal)
                      .maxLength(256)
                      .height("56vp")
                      .onChange((arg) => {
                        this.mPresenter.contactInfoAfter.nickname = arg.valueOf();
                      })
                      .flexGrow(1)
                  }

                }
              }
              .borderRadius("24vp")
              .height("64vp")
              .width("832vp")
              .margin({ top: "12vp" })
              .backgroundColor("#FFFFFF")
              //网站
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                  Image($r("app.media.ic_public_worldclock"))
                    .objectFit(ImageFit.Contain)
                    .margin({ left: "24vp", top: "19vp", bottom: "21vp" })
                    .height("24vp")
                    .width("24vp")
                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    Text($r("app.string.website"))
                      .fontSize("16fp")
                      .lineHeight("22vp")
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r("app.color.colorPrimary"))
                  }
                  .margin({ left: "12vp" })
                  .height("22vp")
                  .width("72vp")

                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    TextInput({
                      placeholder: $r("app.string.website_hock"),
                      text: util.isEmptyList(this.mPresenter.contactInfoBefore.websites)
                        ? ""
                        : this.mPresenter.contactInfoAfter.websites[0]
                    })
                      .fontSize("16fp")
                      .caretColor($r("app.color.colorConnected"))
                      .type(InputType.Normal)
                      .maxLength(256)
                      .height("56vp")
                      .onChange((arg) => {
                        this.mPresenter.contactInfoBefore.websites = [arg.valueOf()];
                      })
                      .flexGrow(1)
                  }
                }
              }
              .borderRadius("24vp")
              .height("64vp")
              .width("832vp")
              .margin({ top: "12vp" })
              .backgroundColor("#FFFFFF")
              //生日
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                  Image($r("app.media.ic_contacts_birthday"))
                    .objectFit(ImageFit.Contain)
                    .margin({ left: "24vp", top: "19vp", bottom: "21vp" })
                    .height("24vp")
                    .width("24vp")

                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    Text(this.mPresenter.birthDaySelect)
                      .fontSize("16fp")
                      .margin({ bottom: "9vp", top: "9vp" })
                      .lineHeight("22vp")
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r("app.color.colorPrimary"))
                      .height("22vp")
                      .width("38vp")
                      .bindMenu(this.mPresenter.birthdayMenu)

                    Image($r("app.media.ic_public_spinner"))
                      .objectFit(ImageFit.Contain)
                      .height("24vp")
                      .width("12vp")
                  }
                  .margin({ left: "12vp" })
                  .height("40vp")
                  .width("72vp")

                  Flex({
                    direction: FlexDirection.Column,
                    alignItems: ItemAlign.Center,
                    justifyContent: FlexAlign.End
                  }) {
                    Text(util.isEmptyList(this.mPresenter.contactInfoBefore.events)
                      ? $r("app.string.birth_hock")
                      : this.mPresenter.contactInfoBefore.events[0].data)
                      .margin({ left: px2vp(10) })
                      .height("55vp")
                      .fontSize("15vp")
                      .fontColor(Color.Gray)
                  }.onClick(() => {
                    this.dialogController.open()
                  })
                }
              }
              .borderRadius("24vp")
              .height("64vp")
              .width("832vp")
              .margin({ top: "12vp" })
              .backgroundColor("#FFFFFF")
              //助理
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                  Column() {
                    Image($r("app.media.ic_contacts_assistant"))
                      .objectFit(ImageFit.Contain)
                      .height("24vp")
                      .width("24vp")
                      .margin({ left: "24vp", top: "19vp", bottom: "21vp", right: "0vp" })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .alignSelf(ItemAlign.Start)

                  Column() {
                    ForEach(this.mPresenter.getArray(this.mPresenter.contactInfoBefore.relationships)
                      , (item) => {
                        ItemList({
                          mPresent: $mPresenter,
                          data: item,
                          typeName: "relationships",
                          placeholder: $r("app.string.assistant_hock")
                        })
                      }, item => item.i.toString())

                    AddItem({ mPresent: $mPresenter,
                      labelName: $r("app.string.add_more"),
                      typeName: "relationships" });

                  }.alignItems(HorizontalAlign.Start)
                }
              }
              .borderRadius("24vp")
              .width("100%")
              .margin({ top: "12vp" })
              .backgroundColor("#FFFFFF")
            }

            if (this.updataShow) {
              ListItem() {
                Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
                  Text($r("app.string.from_the_accounts"))
                    .width('312vp')
                    .fontFamily('HarmonyHeiTi')
                    .fontSize('14fp')
                    .height('19vp')
                    .fontColor($r("app.color.colorPrimary"))
                    .fontWeight(FontWeight.Regular)
                    .lineHeight('19vp')
                  Text($r("app.string.phone"))
                    .width('312vp')
                    .fontFamily('HarmonyHeiTi')
                    .fontSize('14fp')
                    .height('19vp')
                    .fontColor($r("app.color.colorPrimary"))
                    .fontWeight(FontWeight.Regular)
                    .lineHeight('19vp')
                    .margin({ top: '8vp' })
                }
              }
              .width("100%")
              .margin({ top: "12vp" })
            }

          }
          .scrollBar(BarState.On)
          .width("100%")
          .height("100%")
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
    .backgroundColor("#D8D8D8")
  }
}

/**
 * 添加日期弹窗
 */
@CustomDialog
struct showDayTime {
  private date = new Date(2000, 0, 1);
  @Link  mPresent: any;
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

      DatePicker({ type: DatePickerType.Date, selected: this.date })
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
          }).backgroundColor("#D8D8D8").fontColor($r("app.color.colorPrimary"))
        Button($r("app.string.save"))
          .width("50%")
          .onClick(() => {
            let tempEvent = new EventBean("", this.showTime, "1", "");
            this.mPresent.contactInfoAfter.setEvents([tempEvent]);
            this.mPresent.refresh();
            this.controller.close()
            this.confirm()
          }).backgroundColor("#D8D8D8").fontColor($r("app.color.colorPrimary"))
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
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
        Text(this.mPresent.menuSelect(
          this.typeName,
          this.data
        ))
          .fontSize("16fp")
          .margin({ bottom: "9vp", top: "9vp" })
          .lineHeight("22vp")
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.colorPrimary"))
          .height("22vp")
          .width("38vp")
          .bindMenu(this.MenuBuilder)

        Image($r("app.media.ic_public_spinner"))
          .objectFit(ImageFit.Contain)
          .height("24vp")
          .width("12vp")
      }
      .margin({ left: "12vp" })
      .height("40vp")
      .width("72vp")

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
        TextInput({
          placeholder: this.placeholder,
          text: this.mPresent.getTextDisplay(this.typeName, this.data)
        })
          .fontSize("16fp")
          .caretColor($r("app.color.colorConnected"))
          .type(InputType.Normal)
          .maxLength(256)
          .height("56vp")
          .onChange((arg) => {
            this.mPresent.listItemChange(this.typeName, this.data, arg.toString())
          })
      }
      .flexGrow(1)

      Row() {
        Image($r("app.media.ic_public_close_filled"))
          .objectFit(ImageFit.Contain)
          .height("24vp")
          .width("24vp")
          .margin({ top: "16vp", right: "28vp", bottom: "16vp" })
          .onClick(() => {
            this.mPresent.deleteItem(this.typeName, this.data.i - 1);
          })
      }
    }
    .height("64vp")
  }

  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      ForEach(this.mPresent.getMenuList(this.typeName),
        (item) => {
          Text(item.labelRes)
            .fontSize("16fp")
            .width("156vp")
            .height("48vp")
            .fontColor($r("app.color.colorPrimary"))
            .textAlign(TextAlign.Start)
            .margin({ left: "16vp" })
            .onClick(() => {
              this.mPresent.menuChange(this.typeName, this.data, item);
            })

          Divider().height("1vp").width("124vp").color("#33000000")
        },
        (item) => item.rawValue.toString())
    }
    .width("156vp")
    .borderRadius("16vp")
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
          .fontSize("16fp")
          .margin({ bottom: "9vp", top: "9vp", left: "12vp" })
          .lineHeight("22vp")
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.colorPrimary"))
          .height("22vp")
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)

      Column() {
        Image($r("app.media.ic_public_add_norm_filled"))
          .objectFit(ImageFit.Contain)
          .height("24vp")
          .width("24vp")
          .margin({ top: "16vp", right: "12vp", bottom: "16vp" })
          .onClick(() => {
            this.mPresent.addMore(this.typeName);
          })
      }
      .alignItems(HorizontalAlign.End)
    }
    .height("64vp")
  }
}