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

import contactDetailModel from '../../model/contactDetailModel';
import HiLog from '../../util/HiLog';
import Utils from '../../util/Utils';
import DetailInfoListItemView from './DetailInfoListItemView';
import DialUtil from '../../util/DialUtil';

const TAG = "ContactDetail-detailInfoList"

@Component
export default struct DetailInfoListView {
  @Link mDetailModel: any;

  build() {
    Column() {
      // 电话列表
      TelList({ mDetailModel: $mDetailModel });

      if (!this.mDetailModel.contactForm.isNewNumber) {
        // 邮箱列表
        EmailList({ mDetailModel: $mDetailModel });

        // AIM列表
        AIMList({ mDetailModel: $mDetailModel });

        // 昵称
        NickName({ mDetailModel: $mDetailModel });

        // 网站列表
        WebSiteList({ mDetailModel: $mDetailModel });

        // 住址列表
        HouseList({ mDetailModel: $mDetailModel });

        // 生日和纪念日
        RemembranceDay({ mDetailModel: $mDetailModel });

        // 群组
        Group({ mDetailModel: $mDetailModel });

        // 姓名拼音
        PinyinName({ mDetailModel: $mDetailModel });

        // 关联人
        Relationships({ mDetailModel: $mDetailModel });

        // 备注
        Remarks({ mDetailModel: $mDetailModel });

        // 更多选项
        MoreOptions({ mDetailModel: $mDetailModel });
      }
    }
  }
}

/**
 * 电话列表
 */
@Component
struct TelList {
  @Link private mDetailModel: any;
  @Builder ListDivider() {
    Divider()
      .vertical(false)
      .strokeWidth('1vp')
      .color(Color.Gray)
      .opacity(0.6)
  }

  build() {
    List() {
      ForEach(this.mDetailModel.contactForm.phones, (item, index) => {
        ListItem() {
          TelListItem({ message: JSON.stringify(item), mDetailModel: $mDetailModel });
        }
        if (index < this.mDetailModel.contactForm.phones.length - 1) {
          ListItem() {
            this.ListDivider()
          }
        }
      }, item => (item.id).toString())
    }
    .visibility(Utils.isEmptyList(this.mDetailModel.contactForm.phones) ? Visibility.None : Visibility.Visible)
    .backgroundColor($r('app.color.white'))
  }
}

/**
 * 电话item
 */
@Component
struct TelListItem {
  private message: string
  private title: string
  @Link private mDetailModel: any;

  aboutToAppear() {
    this.title = this.mDetailModel.newNumberContactDetail.callTag;
  }

  build() {
    Row() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
        Text(JSON.parse(this.message).num)
          .fontSize('16fp')
        Row() {
          Text(JSON.parse(this.message)
          .labelName)
            .fontSize('14fp')
            .fontColor($r('app.color.textColorPrimary'))
            .visibility(Utils.isEmpty(JSON.parse(this.message)
            .labelName) ? Visibility.None : Visibility.Visible)
          Text(" - ")
            .fontSize('14fp')
            .fontColor($r('app.color.textColorPrimary'))
            .visibility(Utils.isEmpty(JSON.parse(this.message)
            .labelName) ? Visibility.None : Visibility.Visible)
          Text(JSON.parse(this.message).phoneAddress)
            .fontSize('14fp')
            .fontColor($r('app.color.textColorPrimary'))
        }
      }

      Blank();

      Image($r("app.media.ic_public_phone_filled"))
        .objectFit(ImageFit.Contain)
        .height("24vp")
        .width("24vp")
        .margin({ right: '24vp' })
        .onClick(() => {
          DialUtil.getInstance().dial(Utils.removeSpace(JSON.parse(this.message).num), (data, err, value) => {
            HiLog.i(TAG, 'dial isEmergencyPhoneNumber : ' + data + ' err : ' + err + ' value : ' + value);
          });
        })

      Image($r("app.media.ic_public_message_filled"))
        .objectFit(ImageFit.Contain)
        .height("24vp")
        .width("24vp")
        .onClick(() => {
          this.mDetailModel.sendMessage(JSON.parse(this.message)
          .num, this.mDetailModel.showNameLast);
        })
    }
    .width('100%')
    .height("60vp")
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
        this.mDetailModel.listItemOnLongPressNumber(JSON.parse(this.message)
        .id);
      })
      .onActionEnd(() => {

      })
    )
  }
}

/**
 * 邮件列表
 */
@Component
struct EmailList {
  @Link private mDetailModel: any;
  @Builder ListDivider() {
    Divider()
      .vertical(false)
      .strokeWidth('1vp')
      .color(Color.Gray)
      .opacity(0.6)
  }

  build() {
    Column() {
      this.ListDivider()
      List() {
        ForEach(this.mDetailModel.contactForm.emails, (item, index) => {
          ListItem() {
            EmailListItem({ message: JSON.stringify(item) });
          }
          if (index < this.mDetailModel.contactForm.emails.length - 1) {
            ListItem() {
              this.ListDivider()
            }
          }
        }, item => item.id.toString())
      }
    }
    .width("100%")
    .visibility(Utils.isEmptyList(this.mDetailModel.contactForm.emails) ? Visibility.None : Visibility.Visible)
  }
}

/**
 * 邮件item
 */
@Component
struct EmailListItem {
  @Prop message: string;

  build() {
    Column() {
      DetailInfoListItemView({ title: JSON.parse(this.message).address,
        content: JSON.parse(this.message).labelName, hasRow: true })
    }
    .onClick(() => {
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}

/**
 * AIM列表
 */
@Component
struct AIMList {
  @Link private mDetailModel: any;
  @Builder ListDivider() {
    Divider()
      .vertical(false)
      .strokeWidth('1vp')
      .color(Color.Gray)
      .opacity(0.6)
  }

  build() {
    Column() {
      List() {
        ListItem() {
          this.ListDivider()
        }
        ForEach(this.mDetailModel.contactForm.aims, (item, index) => {
          ListItem() {
            AIMListItem({ message: JSON.stringify(item)});
          }
          if (index < this.mDetailModel.contactForm.aims.length - 1) {
            ListItem() {
              this.ListDivider()
            }
          }
        })
      }
    }
    .width("100%")
    .visibility(Utils.isEmptyList(this.mDetailModel.contactForm.aims) ? Visibility.None : Visibility.Visible)
  }
}

/**
 * AIMlListItem
 */
@Component
struct AIMListItem {
  @Prop message: string;

  build() {
    Column() {
      DetailInfoListItemView({ title: JSON.parse(this.message).aimName,
        content: JSON.parse(this.message).aimType, hasRow: true })
    }
    .onClick(() => {
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}

/**
 * 昵称
 */
@Component
struct NickName {
  @Link private mDetailModel: any;
  private hasRow:Boolean = false;

  build() {
    Column() {
      Divider()
        .vertical(false)
        .strokeWidth('1vp')
        .color(Color.Gray)
        .opacity(0.6)
      Row() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
          Text(this.mDetailModel.contactForm.nickname)
            .fontSize(16)
          Text($r('app.string.nickname'))
            .fontSize(14)
            .fontColor($r('app.color.gray'))
        }

        Blank();

        Image($r('app.media.ic_contacts_arrow_up'))
          .align(Alignment.Center)
          .width("20vp")
          .height("20vp")
          .visibility(this.hasRow ? Visibility.Visible : Visibility.None)
          .opacity(0.2)
      }
      .width('100%')
      .height("60vp")
      .padding({ top: 5, bottom: 5 })
    }
    .visibility(Utils.isEmpty(this.mDetailModel.contactForm.nickname) ? Visibility.None : Visibility.Visible)
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {

      })
      .onActionEnd(() => {

      })
    )
  }
}

/**
 * 网站列表
 */
@Component
struct WebSiteList {
  @Link private mDetailModel: any;
  @Builder ListDivider() {
    Divider()
      .vertical(false)
      .strokeWidth('1vp')
      .color(Color.Gray)
      .opacity(0.6)
  }

  build() {
    Column() {
      List() {
        ListItem() {
          this.ListDivider()
        }
        ForEach(this.mDetailModel.contactForm.websites, (item, index) => {
          ListItem() {
            WebSiteListItem({ message: item });
          }
          if (index < this.mDetailModel.contactForm.websites.length - 1) {
            ListItem() {
              this.ListDivider()
            }
          }
        })
      }
    }
    .width("100%")
    .visibility(Utils.isEmptyList(this.mDetailModel.contactForm.websites) ? Visibility.None : Visibility.Visible)
  }
}

/**
 * 网站item
 */
@Component
struct WebSiteListItem {
  @Prop message: string;

  build() {
    Column() {
      DetailInfoListItemView({ title: this.message, content: $r('app.string.website'), hasRow: true })
    }
    .onClick(() => {
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}

/**
 * 地址列表
 */
@Component
struct HouseList {
  @Link private mDetailModel: any;
  @Builder ListDivider() {
    Divider()
      .vertical(false)
      .strokeWidth('1vp')
      .color(Color.Gray)
      .opacity(0.6)
  }

  build() {
    Column() {
      List() {
        ListItem() {
          this.ListDivider()
        }
        ForEach(this.mDetailModel.contactForm.houses, (item, index) => {
          ListItem() {
            HouseListItem({ message: JSON.stringify(item) });
          }
          if (index < this.mDetailModel.contactForm.houses.length - 1) {
            ListItem() {
              this.ListDivider()
            }
          }
        })
      }
    }
    .width("100%")
    .visibility(Utils.isEmptyList(this.mDetailModel.contactForm.houses) ? Visibility.None : Visibility.Visible)
  }
}

/**
 * 住址item
 */
@Component
struct HouseListItem {
  @Prop message: string;

  build() {
    Column() {
      DetailInfoListItemView({ title: JSON.parse(this.message).houseName,
        content: JSON.parse(this.message).houseType, hasRow: true })
    }
    .onClick(() => {
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}

/**
 * 纪念日
 */
@Component
struct RemembranceDay {
  @Link private mDetailModel: any;
  @Builder ListDivider() {
    Divider()
      .vertical(false)
      .strokeWidth('1vp')
      .color(Color.Gray)
      .opacity(0.6)
  }

  build() {
    Column() {
      List() {
        ListItem() {
          this.ListDivider()
        }
        ForEach(this.mDetailModel.contactForm.events, (item, index) => {
          ListItem() {
            RemembranceDayItem({ message: JSON.stringify(item) });
          }

          if (index < this.mDetailModel.contactForm.events.length - 1) {
            ListItem() {
              this.ListDivider()
            }
          }
        }, item => item.id.toString())
      }
    }
    .width("100%")
    .visibility(Utils.isEmptyList(this.mDetailModel.contactForm.events) ? Visibility.None : Visibility.Visible)
  }
}

/**
 * 纪念日item
 */
@Component
struct RemembranceDayItem {
  @Prop message: string;

  build() {
    Column() {
      DetailInfoListItemView({ title: JSON.parse(this.message).data,
        content: JSON.parse(this.message).eventName, hasRow: true })
    }
    .onClick(() => {
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}

/**
 * 群组
 */
@Component
struct Group {
  @Link private mDetailModel: any;
  private hasRow:Boolean = false;

  build() {
    Column() {
      Divider()
        .vertical(false)
        .strokeWidth('1vp')
        .color(Color.Gray)
        .opacity(0.6)
      Row() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
          Text(this.mDetailModel.contactForm.showGroupsString)
            .fontSize(16)
          Text($r('app.string.group'))
            .fontSize(14)
            .fontColor($r('app.color.gray'))
        }

        Blank();

        Image($r('app.media.ic_contacts_arrow_up'))
          .align(Alignment.Center)
          .width("20vp")
          .height("20vp")
          .visibility(this.hasRow ? Visibility.Visible : Visibility.None)
          .opacity(0.2)
      }
      .width('100%')
      .height("60vp")
      .padding({ top: 5, bottom: 5 })
    }
    .visibility(Utils.isEmpty(this.mDetailModel.contactForm.showGroupsString) ? Visibility.None : Visibility.Visible)
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}

/**
 * 姓名拼音
 */
@Component
struct PinyinName {
  @Link private mDetailModel: any;
  private hasRow:Boolean = false;

  build() {
    Column() {
      Divider()
        .vertical(false)
        .strokeWidth('1vp')
        .color(Color.Gray)
        .opacity(0.6)
      Row() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
          Text(this.mDetailModel.contactForm.pinYinName)
            .fontSize(16)
          Text($r('app.string.name_pinyin'))
            .fontSize(14)
            .fontColor($r('app.color.gray'))
        }

        Blank();

        Image($r('app.media.ic_contacts_arrow_up'))
          .align(Alignment.Center)
          .width("20vp")
          .height("20vp")
          .visibility(this.hasRow ? Visibility.Visible : Visibility.None)
          .opacity(0.2)
      }
      .width('100%')
      .height("60vp")
      .padding({ top: 5, bottom: 5 })
    }
    .visibility(Utils.isEmpty(this.mDetailModel.contactForm.pinYinName) ? Visibility.None : Visibility.Visible)
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {

      })
      .onActionEnd(() => {

      })
    )
  }
}

/**
 * 关联人
 */
@Component
struct Relationships {
  @Link private mDetailModel: any;
  @Builder ListDivider() {
    Divider()
      .vertical(false)
      .strokeWidth('1vp')
      .color(Color.Gray)
      .opacity(0.6)
  }

  build() {
    Column() {
      List() {
        ListItem() {
          this.ListDivider()
        }
        ForEach(this.mDetailModel.contactForm.relationships, (item, index) => {
          ListItem() {
            RelationshipsItem({ message: JSON.stringify(item) });
          }
          if (index < this.mDetailModel.contactForm.relationships.length - 1) {
            ListItem() {
              this.ListDivider()
            }
          }
        }, item => item.id.toString())
      }
    }
    .width("100%")
    .visibility(Utils.isEmptyList(this.mDetailModel.contactForm.relationships) ? Visibility.None : Visibility.Visible)
  }
}

/**
 * 关联人item
 */
@Component
struct RelationshipsItem {
  @Prop message: string;

  build() {
    Column() {
      DetailInfoListItemView({ title: JSON.parse(this.message).name,
        content: JSON.parse(this.message).associatedType, hasRow: true })
    }
    .onClick(() => {
    })
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}

/**
 * 备注
 */
@Component
struct Remarks {
  @Link private mDetailModel: any;
  private hasRow:Boolean = false;

  build() {
    Column() {
      Divider()
        .vertical(false)
        .strokeWidth('1vp')
        .color(Color.Gray)
        .opacity(0.6)
      Row() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
          Text(this.mDetailModel.contactForm.remarks)
            .fontSize(16)
          Text($r('app.string.remarks'))
            .fontSize(14)
            .fontColor($r('app.color.gray'))
        }

        Blank();

        Image($r('app.media.ic_contacts_arrow_up'))
          .align(Alignment.Center)
          .width("20vp")
          .height("20vp")
          .visibility(this.hasRow ? Visibility.Visible : Visibility.None)
          .opacity(0.2)
      }
      .width('100%')
      .height("60vp")
      .padding({ top: 5, bottom: 5 })
    }
    .visibility(Utils.isEmpty(this.mDetailModel.contactForm.remarks) ? Visibility.None : Visibility.Visible)
    .gesture(LongPressGesture({ fingers: 1, repeat: false, duration: 500 })
      .onAction((event: GestureEvent) => {
      }))
  }
}

/**
 * 更多选项
 */
@Component
struct MoreOptions {
  @Link private mDetailModel: any;

  build() {
    Row() {
      Text($r('app.string.more'))
        .fontSize(15)
        .margin({ right: 5 })
        .fontColor($r('app.color.font_color_more'))

      Image($r('app.media.ic_contacts_details_arrow_down'))
        .objectFit(ImageFit.Contain)
        .height(16)
        .width(16)
    }
    .height('40vp')
    .visibility(this.mDetailModel.contactForm.showMoreButton ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      this.mDetailModel.getMore();
    })
  }
}
