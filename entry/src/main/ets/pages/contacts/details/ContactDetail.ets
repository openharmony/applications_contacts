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
import IndexPresenter from '../../../presenter/IndexPresenter';
import DetailPresenter from '../../../presenter/contact/detail/DetailPresenter';
import StringFormatUtil from '../../../util/StringFormatUtil';
import CallLogListItem from '../../../component/contactdetail/DetailCalllog';
import DetailInfoListView from '../../../component/contactdetail/DetailInfoListView';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { SelectSimIdDialog, SelectDialogBuilder } from "../../../component/mutisim/SelectSimIdDialog";

const TAG = "ContactDetail";
let storage = LocalStorage.GetShared()

/**
 * Contact details page
 */
@Entry(storage)
@Component
struct ContactDetail {
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
  @State isShow: number = 0;
  @State builder: SelectDialogBuilder = {
    title: "",
    multiSimCardItems: [{
                          name: "",
                          img: $r("app.media.ic_public_phone1"),
                        }, {
                          name: "",
                          img: $r("app.media.ic_public_phone2"),
                        }],
  };
  mSelectSlotIdDialog: CustomDialogController = new CustomDialogController({
    builder: SelectSimIdDialog({ builder: $builder }),
    customStyle: false,
    autoCancel: true,
    alignment: DialogAlignment.Bottom
  })

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear:');
    AppStorage.SetOrCreate("sysTime", parseInt(StringFormatUtil.judgeSysTime()));
    setTimeout(() => {
      this.isShow++;
    }, 100);
    let obj: any = router.getParams();
    this.mPresenter.sourceHasId = obj.sourceHasId;
    this.mPresenter.contactId = obj.contactId;
    this.mPresenter.sourceHasPhone = obj.sourceHasPhone;
    this.mPresenter.phoneNumberShow = obj.phoneNumberShow;
    this.mPresenter.aboutToAppear();
    this.mMoreMenu = this.mPresenter.getSettingsMenus();
    let that = this;
    this.builder.controller = {
      open() {
        that.mSelectSlotIdDialog.open();
      },
      close() {
        that.mSelectSlotIdDialog.close();
      }
    }
  }

  aboutToDisappear() {
    this.mPresenter.aboutToDisappear();
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow');
    IndexPresenter.getInstance().getNewWant();
    if (parseInt(StringFormatUtil.judgeSysTime()) !== AppStorage.Get("sysTime")) {
      HiLog.i(TAG, 'DO refresh detailCallLog');
      this.mPresenter.refresh();
      AppStorage.SetOrCreate("sysTime", parseInt(StringFormatUtil.judgeSysTime()));
    }
  }

  @Builder MenuBuilder() {
    Column() {
      this.MenuView($r("app.string.delete_contact"), MenuType.deleteContact)
    }
    .width($r('app.float.account_MenuBuilder_width'))
    .alignItems(HorizontalAlign.Start)
    .height($r("app.float.id_item_height_mid"))
  }

  @Builder MenuView(menuName, itemType) {
    Row() {
      Text(menuName)
        .fontSize($r("app.float.id_corner_radius_card_mid"))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({ left: $r("app.float.id_card_margin_xxl") })
        .lineHeight(19)
        .height(21)
        .textAlign(TextAlign.Start)
    }
    .width("100%")
    .height($r("app.float.id_item_height_mid"))
    .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
    .onClick(() => {
      switch (itemType) {
        case MenuType.deleteContact:
          this.mPresenter.deleteContact();
          break;
      }
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      TopBar({ mPresenter: $mPresenter, moreMenu: $mMoreMenu });

      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 12, md: 12, lg: 24 }, y: 0 } }) {
        GridCol({ span: { sm: 4, md: 8, lg: 8 }, offset: { sm: 0, md: 0, lg: 2 } }) {
          if (this.isShow > 0) {
            Content({ mPresenter: $mPresenter, selectSimBuilder: $builder })
          }
        }
      }
      .width('100%')
      .margin({ bottom: 50 })

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
              .fontSize($r("sys.float.ohos_id_text_size_caption"))
              .fontWeight(FontWeight.Medium)
              .fontColor($r("sys.color.ohos_id_color_toolbar_text"))
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
              .fontSize($r("sys.float.ohos_id_text_size_caption"))
              .fontWeight(FontWeight.Medium)
              .fontColor($r("sys.color.ohos_id_color_toolbar_text"))
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
    .backgroundColor(this.mPresenter.isNewDetail ? this.mPresenter.newNumberBgColor : this.mPresenter.detailsColor)
  }
}

enum MenuType {
  //TODO Refine more options
  deleteContact
}

@Component
struct Content {
  @Link private mPresenter: { [key: string]: any };
  @Link selectSimBuilder: SelectDialogBuilder;
  @LocalStorageProp('breakpoint') curBp: string = 'sm';
  @State colunmHeight: string = "60%";
  @StorageLink('isRouterBack') @Watch('onBackIndex')  isRouterBack: boolean = false;

  onBackIndex() {
    if (this.isRouterBack) {
      router.back();
      AppStorage.SetOrCreate("indexTabs", 0);
    }
    this.isRouterBack = false;
  }

  @Builder callLogTitle() {
    Row() {
      Text($r('app.string.dialer_calllog'))
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
        .margin({ left: $r("app.float.id_card_margin_max") })

      Blank();

      Text($r('app.string.clear'))
        .fontSize($r("sys.float.ohos_id_text_size_body1"))
        .fontColor($r("sys.color.ohos_id_color_connected"))
        .margin({ right: $r("app.float.id_card_margin_max") })
        .onClick(() => {
          AlertDialog.show({
            message: $r('app.string.clear_calllog_sure'),
            alignment: EnvironmentProp.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom,
            autoCancel: true,
            primaryButton: {
              value: $r('app.string.dialog_cancel'),
              action: () => {
              }
            },
            secondaryButton: {
              value: $r('app.string.dialog_delete'),
              fontColor: $r("sys.color.ohos_id_color_handup"),
              action: () => {
                this.mPresenter.clearAllCallLog();
              }
            },
            offset: {
              dx: 0, dy: -15
            },
            gridCount: 4
          })
        })
    }
    .width('100%')
    .height($r("app.float.id_item_height_sm"))
  }

  toPoint(percent) {
    var str = percent.replace("%", "");
    str = str / 100;
    return str;
  }

  toPercent(point) {
    var percent = Number(point * 100).toFixed(4);
    percent += "%";
    return percent;
  }

  build() {
    List() {
      ListItem() {
        Column() {
          Stack({ alignContent: Alignment.Bottom }) {
            Stack()
              .backgroundColor(Color.White)
              .width("100%")
              .height("51vp")
              .borderRadius({ topLeft: 24, topRight: 24 })

            if (this.mPresenter.isNewNumber || this.mPresenter.contactForm.photoFirstName == '-1') {
              Image($r("app.media.ic_user_portrait_morandi"))
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
                  .maxLines(StringUtil.isEmpty(this.mPresenter.contactForm.position) ? 2 : 1)
              }
              if (!StringUtil.isEmpty(this.mPresenter.contactForm.position)) {
                Text(this.mPresenter.contactForm.position)
                  .fontSize($r("sys.float.ohos_id_text_size_body2"))
                  .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
              }
            }

            DetailInfoListView({ mPresenter: $mPresenter, selectSimBuilder: $selectSimBuilder });
          }
          .width('100%')
          .backgroundColor(Color.White)
          .padding({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_max") })

        }
      }
      .onAreaChange((oldArea: Area, newArea: Area) => {
        this.mPresenter.changeTopBarBackgroundColor(newArea.globalPosition.y <= -260)
      })

      ListItemGroup() {
        LazyForEach(this.mPresenter.detailCallLogDataSource, (item, index) => {
          ListItem() {
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
              if (item.showTitle) {
                Divider()
                  .strokeWidth(8)
                  .color($r("sys.color.ohos_id_color_subheading_separator"))
                this.callLogTitle()
              }

              CallLogListItem({ message: item.callLog, mPresenter: $mPresenter });
            }
          }
          .width("100%")
        }, item => JSON.stringify(item))
      }
      .backgroundColor(Color.White)
      .onAreaChange((oldArea: Area, newArea: Area) => {
        var itemHeight = AppStorage.Get("windowHeight") == undefined ? 0 : (Number(newArea.height) - Number(oldArea.height)) / Number(AppStorage.Get("windowHeight"))
        var itemPoint = this.toPoint(this.colunmHeight) - itemHeight;
        this.colunmHeight = itemPoint < 0 ? "0%" : this.toPercent(itemPoint)
      })
      .width("100%")

      ListItem() {
        Column() {
        }
        .height(this.colunmHeight)
        .width("100%")
      }
      .backgroundColor(Color.White)
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
          HiLog.i(TAG, "BackTo-ContactList");
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
    .backgroundColor(this.mPresenter.getTopBarBackgroundColor())
  }
}