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
import ImportContactsPresenter from '../../presenter/contact/importcontacts/ImportContactsPresenter';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

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
  @State contactListTouchable: boolean = true;

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
        .backgroundColor(this.curBp === 'lg' ? $r("sys.color.ohos_id_color_sub_background") : Color.White)
    } else {
      ContactContent({
        presenter: $mContactPresenter,
        contactListListLen: $contactListListLen,
        contactListTouchable: $contactListTouchable
      })
        .backgroundColor(this.curBp === 'lg' ? $r("sys.color.ohos_id_color_sub_background") : Color.White)
        .hitTestBehavior(this.contactListTouchable ? HitTestMode.Default : HitTestMode.Block)
    }
  }
}

@Component
struct TitleGuide {
  presenter: ContactListPresenter = ContactListPresenter.getInstance();
  @State importContactsPresenter: ImportContactsPresenter = ImportContactsPresenter.getInstance();

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
    }),
    cancel: this.exitApp,
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
    backgroundColor: 0xd9ffffff,
    cornerRadius: 10,
  })

  aboutToDisappear() {
    this.dialogController = null
  }

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  exitApp() {
    console.info('Click the callback in the blank area')
  }

  aboutToAppear() {
    this.importContactsPresenter.aboutToAppear();
  }

  @Builder
  MoreMenu() {
    Menu() {
      MenuItem({ content: '从内部存储导入联系人文件' })
        .onChange((selected) => {
          if (selected) {
            this.importContactsPresenter.dialogController = this.dialogController;
            this.importContactsPresenter.importFile();
          }
        })
    }
  }

  build() {
    Row() {
      Image($r("app.media.ic_public_add"))
        .width($r("app.float.id_card_image_small"))
        .height($r("app.float.id_card_image_small"))
        .objectFit(ImageFit.Contain)
        .margin({ right: $r("app.float.id_card_margin_xl") })
        .onClick(() => {
          this.presenter.createContact();
        })

      Image($r("app.media.ic_public_more"))
        .width($r("app.float.id_card_image_small"))
        .height($r("app.float.id_card_image_small"))
        .objectFit(ImageFit.Contain)
        .opacity(0.4)
        .bindMenu(this.MoreMenu)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .height($r("app.float.id_item_height_large"))
    .width('100%')
  }
}

@CustomDialog
struct CustomDialogExample {
  importContactsPresenter: ImportContactsPresenter = ImportContactsPresenter.getInstance();
  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  JumpFileUpload() {
    let context = getContext(this) as common.UIAbilityContext;
    let want: Want = {
      deviceId: '',
      bundleName: 'com.pengju.minihttpserver',
      abilityName: 'EntryAbility',
    };
    context.startAbility(want, (err: BusinessError) => {
      if (err.code) {
        console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      }
    });
  }

  build() {
    Column() {
      Column() {
        Text('没有找到.vcf文件!').fontSize(20).margin({ top: 10, bottom: 10 })
        Text('可通过以下两种方式之一上传.vcf文件到指定目录：').fontSize(18).margin({ bottom: 10 })
        Text('1、使用文件传输助手:\n(1)打开文件传输助手\n(2)点击打开服务按钮\n(3)手机连接wifi后会显示http地址\n(4)另一台手机连上相同wifi并通过浏览器访问文件传输助手上的http地址\n(5)在进入的网页中选择需要上传到的开发者手机目录/app/el2/0/base/com.ohos.contacts/haps/entry/files/\n(6)点击选择文件，选取手机中存储的.vcf文件(一次选取一个.vcf文件上传)后点击Upload file').fontSize(16).margin({ bottom: 10 })
        Text('2、使用hdc file send推送.vcf文件到/data/app/el2/0/base/com.ohos.contacts/haps/entry/files/目录，例如：hdc file send D:/\demo.vcf  /data/app/el2/0/base/com.ohos.contacts/haps/entry/files/').fontSize(16).margin({ bottom: 10 })
      }
      .alignItems(HorizontalAlign.Start)
      .padding(20)

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('知道了')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              this.cancel()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Gray)
        Button('跳转到文件传输助手')
          .onClick(() => {
            if (this.controller != undefined) {
              this.JumpFileUpload()
              this.controller.close()
              this.confirm()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Blue)
      }.margin({ bottom: 10 })
    }.borderRadius(10)
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
  @Link contactListTouchable: boolean;

  @Builder
  GroupsView(imageRes: Resource, title: string | Resource, showArrow: boolean) {
    Row() {
      Row() {
        Image(imageRes)
          .width($r("app.float.id_card_image_mid"))
          .height($r("app.float.id_card_image_mid"))
          .objectFit(ImageFit.Contain)
          .margin({ left: $r("app.float.id_card_margin_max"), right: $r("app.float.id_card_margin_xxl") })

        Text(title)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .fontWeight(FontWeight.Medium)
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        Image($r("app.media.ic_arrow_right_grey"))
          .width(12)
          .height($r("app.float.id_card_image_small"))
          .objectFit(ImageFit.Contain)
          .margin({ right: $r("app.float.id_card_margin_max") })

      }
    }
    .width('100%')
    .height($r("app.float.id_item_height_max"))
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
                Text($r("app.string.contact"))
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
                  .margin({ bottom: $r("app.float.id_card_margin_sm") })
                  .lineHeight(42)
                  .margin({ top: 8, bottom: 2 })
                Text($r("app.string.contact_num", this.contactListListLen))
                  .fontSize($r("sys.float.ohos_id_text_size_body2"))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
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
                    .height($r("app.float.id_item_height_mid"))
                    .enabled(false)
                    .border({
                      color: $r("sys.color.ohos_id_color_fourth"),
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
                            .fontColor($r("sys.color.ohos_fa_text_secondary"))
                            .fontSize($r("sys.float.ohos_id_text_size_sub_title3"))
                            .fontWeight(FontWeight.Medium)
                            .textAlign(TextAlign.Start)
                        }
                        .alignItems(VerticalAlign.Bottom)
                        .direction(Direction.Ltr)
                        .padding({ left: this.curBp === 'lg' ? $r("app.float.id_card_margin_max") : 0,
                          bottom: $r("app.float.id_card_margin_large") })
                        .height($r("app.float.id_item_height_mid"))
                      }
                      ContactListItemView({
                        item: item.contact,
                        index: index,
                        showIndex: item.showIndex,
                        showDivifer: item.showDivifer,
                        contactListTouchable: $contactListTouchable
                      })
                    }
                    .alignItems(HorizontalAlign.Start)
                    if (item.showDivifer) {
                      Divider()
                        .color($r("sys.color.ohos_id_color_list_separator"))
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
      .height("100%")
      .width("100%")
      if (this.presenter.isSearchPage) {
        ContactSearch({ presenter: $presenter, type: $type })
      }
	AlphabetIndexerPage({scroller: this.scroller, presenter: $alphabetIndexPresenter, selected: this.alphabetSelected,
        isClicked: $isAlphabetClicked, drag: $dragList})
        .margin({top: '30%', bottom: '10%'})
      }
      .width("100%")
      .height("100%")
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
          Text($r("app.string.contact"))
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .height($r("app.float.id_item_height_large"))
            .textAlign(TextAlign.Start)
            .width('100%')
        }
      }

      Column() {
        Image($r('app.media.no_contacts_illustration'))
          .objectFit(ImageFit.Contain)
          .width($r("app.float.id_card_image_large"))
          .height($r("app.float.id_card_image_large"))
          .margin({ bottom: $r("app.float.id_card_margin_large") })

        Text($r("app.string.no_contacts"))
          .width($r("app.float.id_card_image_large"))
          .fontSize($r("sys.float.ohos_id_text_size_body2"))
          .fontWeight(FontWeight.Regular)
          .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
          .textAlign(TextAlign.Center)
      }

      Column() {
        //This component is temporarily shielded because there is no requirement currently.
//        Button($r("app.string.contact_login_in"), { type: ButtonType.Capsule, stateEffect: true })
//          .fontColor($r("sys.color.ohos_id_color_connected"))
//          .fontWeight(FontWeight.Medium)
//          .fontSize($r("sys.float.ohos_id_text_size_body1"))
//          .width('100%')
//          .height($r("app.float.id_item_height_sm"))
//          .backgroundColor($r("sys.color.ohos_id_color_button_normal"))
//          .onClick(() => {
//            this.presenter.loginAccount();
//          })

//        Button($r("app.string.contact_import_contacts"), { type: ButtonType.Capsule, stateEffect: true })
//          .fontColor($r("sys.color.ohos_id_color_connected"))
//          .fontWeight(FontWeight.Medium)
//          .fontSize($r("sys.float.ohos_id_text_size_body1"))
//          .margin({ top: $r("app.float.id_card_margin_xxl") })
//          .width('100%')
//          .height($r("app.float.id_item_height_sm"))
//          .backgroundColor($r("sys.color.ohos_id_color_button_normal"))
//          .onClick(() => {
//            this.presenter.importContact();
//          })

        Button($r("app.string.create_contact"), { type: ButtonType.Capsule, stateEffect: true })
          .fontColor($r("sys.color.ohos_id_color_connected"))
          .fontWeight(FontWeight.Medium)
          .fontSize($r("sys.float.ohos_id_text_size_body1"))
          .margin({ top: $r("app.float.id_card_margin_xxl") })
          .width('100%')
          .height($r("app.float.id_item_height_sm"))
          .backgroundColor($r("sys.color.ohos_id_color_button_normal"))
          .onClick(() => {
            this.presenter.createContact();
          })

        //This component is temporarily shielded because there is no requirement currently.
//        Button($r("app.string.contact_scan_card"), { type: ButtonType.Capsule, stateEffect: true })
//          .fontColor($r("sys.color.ohos_id_color_connected"))
//          .fontWeight(FontWeight.Medium)
//          .fontSize($r("sys.float.ohos_id_text_size_body1"))
//          .margin({ top: $r("app.float.id_card_margin_xxl") })
//          .width('100%')
//          .height($r("app.float.id_item_height_sm"))
//          .backgroundColor($r("sys.color.ohos_id_color_button_normal"))
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