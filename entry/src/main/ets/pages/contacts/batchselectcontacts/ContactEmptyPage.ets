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

@Component
export struct ContactEmptyPage {
  // @Link presenter: ContactListPresenter;
  @LocalStorageProp('breakpoint') curBp: string = 'sm'

  build() {
    Column() {
      // GridRow({columns: {sm: 4, md: 8, lg: 12}, gutter: {x: 12, y: 0}}) {
      //   GridCol({span: {sm: 4, md:6, lg: 8}, offset: {sm: 0, md: 1, lg: 2}}) {
      //     // TitleGuide()
      //   }
      //   GridCol({span: {sm: 4, md:6, lg: 8}, offset: {sm: 0, md: 2, lg: 4}}) {
      //     Text($r('app.string.contact'))
      //       .fontSize(30)
      //       .fontWeight(FontWeight.Bold)
      //       .fontColor($r('sys.color.ohos_id_color_text_primary'))
      //       .height($r('app.float.id_item_height_large'))
      //       .textAlign(TextAlign.Start)
      //       .width('100%')
      //   }
      // }

      Column() {
        Image($r('app.media.ic_empty_page_no_contacts'))
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
      .margin({
        top: 200,
        bottom:50
      })

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

        // Button($r('app.string.create_contact'), { type: ButtonType.Capsule, stateEffect: true })
        //   .fontColor($r('sys.color.ohos_id_color_connected'))
        //   .fontWeight(FontWeight.Medium)
        //   .fontSize($r('sys.float.ohos_id_text_size_body1'))
        //   .margin({ top: $r('app.float.id_card_margin_xxl') })
        //   .width('100%')
        //   .height($r('app.float.id_item_height_sm'))
        //   .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        //   .onClick(() => {
        //     // this.presenter.createContact();
        //   })

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
    // .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
    .width('100%')
  }
}