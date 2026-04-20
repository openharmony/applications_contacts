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
import { ArrayUtil, HiLog, sharedPreferencesUtils } from '../../../../../../../common';
import { AccountVo } from '../../../model/bean/AccountVo';
import { CustomizedParams } from '../../../model/type';
import ArrangeContactsPresenter from '../../../presenter/contact/settings/ArrangeContactsPresenter';
import DotUtil from '../../../util/DotUtil';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader';
import { Params } from '../../../../../../../common/src/main/ets/Constants';
import { TextModifier } from '@ohos.arkui.modifier';
import { BusinessError } from '@ohos.base';
import { LengthMetrics } from '@kit.ArkUI';
import EnvironmentProp from '../../../feature/EnvironmentProp';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// import { HdsNavDestinationTitleMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';

const TAG = 'AccountList';
const SETTINGS_SHOW_CHOOSE_EVENT = 'SETTINGS_SHOW_CHOOSE_EVENT';
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function AccountListLoader($$: Params): void {
  AccountList();
}

@Component
export default struct AccountList {
  @Consume('contactsSettingsNavStack') contactsSettingsNavStack: NavPathStack;
  @State aPresenter: ArrangeContactsPresenter = ArrangeContactsPresenter.getInstance();
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  private scroller: Scroller = new Scroller();
  @State accountId: number = 0;
  @State repeatNum: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  showContactChooseParams: CustomizedParams = {
    ITEM: 0
  }

  aboutToAppear() {
    HiLog.i(TAG, 'the Page AccountList aboutToAppear Begin !!');
    this.aPresenter.initNavPaths(this.contactsSettingsNavStack);
    this.aPresenter.total = 0;
    this.aPresenter.getAllAccountAndContactSize();
    sharedPreferencesUtils.getFromPreferences('accountType', -1).then(value => {
      this.accountId = value as number;
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'getFromPreferences error: ', error.message);
    });
    this.aPresenter.initContactList((ids: [][][]) => {
      HiLog.i(TAG, 'autoMerge ids size:' + ids?.length)
      if (ids && ids.length > 0) {
        ids.forEach(value => {
          value.forEach(list => {
            this.repeatNum += (list.length - 1);
          })
        })
      }
    })
  }

  destinationPageShow() {
    HiLog.i(TAG, 'onPageShow')
  }

  destinationPageHide() {
    HiLog.i(TAG, 'onPageCover')
  }

  destinationBackPress() {
    HiLog.i(TAG, 'onBackPress')
    this.aPresenter.repeatList = [];
    this.contactsSettingsNavStack.pop();
    return true;
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear')
    this.aPresenter.repeatList = [];
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .constraintSize({ minHeight: 64 })
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          SubHeader({
            secondaryTitle: $r('app.string.accounts_to_display'),
            secondaryTitleModifier: this.isThemeActive ?
            new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined
          })
            .margin({ left: this.curBp === 'lg' ? $r('app.float.id_card_margin_large') : 0 })
          ListItemGroup({ style: ListItemGroupStyle.CARD }) {
            ListItem() {
              Row() {
                Column() {
                  Text($r('app.string.all_contacts'))
                    .height('22vp')
                    .textAlign(TextAlign.Start)
                    .fontSize($r('sys.float.Body_L'))
                    .fontColor($r('app.color.skin_font_primary'))
                    .fontWeight(FontWeight.Medium)

                  Text(this.accountId === -1 ?
                  $r('app.string.contact', this.aPresenter.total, this.aPresenter.total - this.repeatNum)
                    : $r('app.string.account_contact_count_all', this.aPresenter.total))
                    .height('19vp')
                    .textAlign(TextAlign.Start)
                    .fontSize($r('sys.float.Body_M'))
                    .margin({ top: $r('sys.float.padding_level1') })
                    .fontColor($r('app.color.skin_font_secondary'))
                    .fontWeight(FontWeight.Regular)

                }
                .height('100%')
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)

                Checkbox()
                  .id('account_list_all_contact_checkbox')
                  .select(this.accountId === -1 ? true : false)
                  .selectedColor($r('app.color.skin_comp_background_emphasize'))
                  .shape(CheckBoxShape.CIRCLE)
                  .height(20)
                  .width(20)
                  .hitTestBehavior(HitTestMode.None)
                  .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') :
                    undefined)
                  .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
              .width('100%')
              .height('100%')
              .flexShrink(0)
              .padding({
                left: $r('app.float.dialer_common_very_small_margin2'),
                right: $r('app.float.dialer_common_very_small_margin2')
              })
            }
            .height(64)
            .id('account_list_all_contact_row')
            .margin({ left: $r('app.float.id_card_margin_sm'), right: $r('app.float.id_card_margin_sm') })
            .stateStyles({
              pressed: this.pressedStyles,
              normal: this.normalStyles
            })
            .onClick(() => {
              // 联系人打点--显示联系人选项点击所有联系人
              this.showContactChooseParams.ITEM = 0;
              DotUtil.getInstance().contactDot(this.showContactChooseParams, SETTINGS_SHOW_CHOOSE_EVENT);
              sharedPreferencesUtils.saveToPreferences('accountType', -1)
              this.aPresenter.pathInfos?.pop();
            })

            ForEach(this.aPresenter.accountList, (accountVo: AccountVo, index) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(index == 0 ? (this.curBp === 'lg'
                      ? $r('app.string.tablet') : $r('app.string.contact'))
                      : accountVo.accountName)
                      .width('90%')
                      .textAlign(TextAlign.Start)
                      .fontSize($r('sys.float.Body_L'))
                      .margin({ top: 10 })
                      .maxLines(2)
                      .fontColor($r('app.color.skin_font_primary'))
                      .fontWeight(FontWeight.Medium)

                    Text(this.accountId === -1 ?
                    $r('app.string.account_contact_count_all', this.aPresenter.accountSizeMap.get(accountVo.accountId))
                      : (this.accountId == new Number(accountVo.accountId).valueOf() ?
                      $r('app.string.contact', this.aPresenter.accountSizeMap.get(accountVo.accountId),
                        this.aPresenter.accountSizeMap.get(accountVo.accountId) - this.repeatNum) :
                      $r('app.string.account_contact_count_all',
                        this.aPresenter.accountSizeMap.get(accountVo.accountId))))
                      .height('19vp')
                      .textAlign(TextAlign.Start)
                      .fontSize($r('sys.float.Body_M'))
                      .margin({ top: $r('sys.float.padding_level1'), bottom: 10 })
                      .fontColor($r('app.color.skin_font_secondary'))
                      .fontWeight(FontWeight.Regular)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.SpaceAround)

                  Checkbox()
                    .id('account_list_only_phone_checkbox')
                    .select((this.accountId !== -1 && this.accountId == Number(accountVo.accountId)
                      .valueOf() ? true : false))
                    .selectedColor($r('app.color.skin_comp_background_emphasize'))
                    .shape(CheckBoxShape.CIRCLE)
                    .height(20)
                    .width(20)
                    .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') :
                      undefined)
                    .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
                    .hitTestBehavior(HitTestMode.None)

                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)
                .width('100%')
                .padding({
                  left: $r('app.float.dialer_common_very_small_margin2'),
                  right: $r('app.float.dialer_common_very_small_margin2')
                })
              }
              .height(82)
              .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
              .id('account_list_only_phone_row')
              .margin({ left: $r('app.float.id_card_margin_sm'), right: $r('app.float.id_card_margin_sm') })
              .stateStyles({
                pressed: this.pressedStyles,
                normal: this.normalStyles
              })
              .onClick(() => {
                HiLog.i(TAG, 'account:' + accountVo.accountId);
                // 联系人打点--显示联系人选项点击手机/云账户
                this.showContactChooseParams.ITEM = 1;
                DotUtil.getInstance().contactDot(this.showContactChooseParams, SETTINGS_SHOW_CHOOSE_EVENT);
                sharedPreferencesUtils.saveToPreferences('accountType', new Number(accountVo.accountId).valueOf())
                this.aPresenter.pathInfos?.pop();
              })
            })
          }
          .borderRadius($r('sys.float.corner_radius_level10'))
          .backgroundColor($r('app.color.skin_comp_background_primary'))
          .margin({ left: this.spaceLR, right: this.spaceLR })
          .divider({
            strokeWidth: '1px',
            color: $r('app.color.skin_ohos_id_color_list_separator'),
            startMargin: $r('app.float.id_card_margin_large'),
            endMargin: $r('app.float.id_card_margin_large')
          })
        }
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .clipContent(ContentClipMode.SAFE_AREA)
        .safeAreaPadding({ top: $r('app.float.id_item_height_max') })
        .height('100%')
        .width('100%')
      }
      .height('100%')
      .width('100%')
      .flexShrink(1)
    }
    // .titleMode(HdsNavDestinationTitleMode.MODAL)
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), TitleBarUtil.getBindSheetCloseButton(), () => {
    //   this.onBack();
    // }))
    .title(ResourceUtil.getStringByResource($r('app.string.show_contacts')),
      {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart:EnvironmentProp.isPC() ? LengthMetrics.vp(16) : LengthMetrics.resource($r('sys.float.margin_left'))
      })
    .onBackPressed(() => {
      this.destinationBackPress();
      return true;
    })
    .backgroundColor($r('app.color.color_bind_sheet_background'))
    .onShown(() => {
      this.destinationPageShow();
    })
    .onHidden(() => {
      this.destinationPageHide();
    })
    .padding({
      bottom: this.curBp !== 'sm' ? $r('sys.float.padding_level0') : px2vp(this.fullScreenPadding.bottom as number)
    })
  }

  private onBack() {
    this.destinationBackPress();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: EnvironmentProp.isPC() ? {
  //       scrollEffectOpts: {
  //         enableScrollEffect: false
  //       },
  //       originalStyle: {
  //         backgroundStyle: {
  //           backgroundColor: $r('app.color.color_bind_sheet_background')
  //         }
  //       }
  //     } : undefined,
  //     avoidLayoutSafeArea: false,
  //     padding: { start: EnvironmentProp.isPC() ? LengthMetrics.vp(16) :
  //       LengthMetrics.resource($r('sys.float.margin_left')) },
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.show_contacts')) },
  //     backIcon: { backIcon: true }
  //   };
  // }
}