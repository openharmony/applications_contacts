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
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
// 导入动态加载页面模块
import { DynamicLoader, StringUtil } from '../../../../../../../common';
import SettingsPresenter from '../../../presenter/contact/settings/SettingsPresenter';
import connection from '@ohos.net.connection';
import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import DotUtil from '../../../util/DotUtil';
import { SymbolGlyphModifier, TextModifier } from '@ohos.arkui.modifier';
import { PrivacyStatementContentTag } from '../../../presenter/contact/settings/PrivacyStatementPresenter';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader';
import LooseObject from '../../../model/type/LooseObject';
import dotCommon, { customParams } from '../../../util/DotCommon';
import { FontScaleState } from '../../../util/fontScaleState';
import Curves from '@ohos.curves'
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import emitter from '@ohos.events.emitter';
import EmitterConstant from '../../../data/EmitterConstant';
import { LengthMetrics } from '@kit.ArkUI';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { PCSubTitle } from '../../../component/contact/SubHeader';
import { i18n } from '@kit.LocalizationKit';
import { showToast, SystemModeController, DISABLED_OPACITY_STRING } from '../../../util/SystemModeController';
// import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit';
// import { HdsNavigationTitleMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';

const TAG = 'Settings  ';
// 屏蔽显示联系人入口
const SHOW_CONTATC = 0
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

PersistentStorage.persistProp('allowPrivacyStatementNetwork', false);

interface SettingItem {
  title: Resource;
  subTitle?: Resource;
  index: number;
  enabled?: boolean;
}

interface SettingItemGroup {
  headerTitle: Resource;
  items: SettingItem[];
}

@Component
export default struct Settings {
  // path parameter
  @Provide('contactsSettingsNavStack') contactsSettingsNavStack: NavPathStack = new NavPathStack();
  // 联系人数量
  total: number = 0;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  presenter: SettingsPresenter = SettingsPresenter.getInstance();
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('jumpToSettingSubpageParam') subpage: string = '';
  @StorageLink('isFromExternalApp') isFromExternalApp: boolean = false;
  @State privacyStatementContentTag: PrivacyStatementContentTag = PrivacyStatementContentTag.ErrorNetwork;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @State translateTitle: number | string = '50%'
  @State titleOpacity: number = 0
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  private isPC: boolean = EnvironmentProp.isPC();
  // 加载路由页面
  loaderMap: Map<String, ($$: Params) => void> = new Map<String, ($$: Params) => void>();
  @BuilderParam accountListLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam arrangeContactsLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam batchDeleteContactsLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam copyContactsLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam importAndExportLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam recentDeleteLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam selectRepeatContactLoader: ($$: Params) => void = dummyFunction;
  @BuilderParam settingAboutLoader: ($$: Params) => void = dummyFunction;
  private mSystemModeController: SystemModeController = SystemModeController.getInstance();
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    HiLog.i(TAG, 'the Page Settings aboutToAppear Begin !!')
    this.presenter.initNavPaths(this.contactsSettingsNavStack);
    // 联系人数量由父组件传递
    this.presenter.total = this.total;
    // 动态加载页面
    DynamicLoader.getInstance().registerSettings(async (str: string): Promise<boolean> => {
      return await this.dynamicLoadCallBack(str);
    });
    this.jumpToSettingSubpage();
    HiLog.i(TAG, 'the Page Settings aboutToAppear End');
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'the Page Settings aboutToDisappear Begin !!')
    this.presenter.total = 0;
    this.isFromExternalApp = false;
    HiLog.i(TAG, 'Progress total:' + this.presenter.total);
    HiLog.i(TAG, 'the Page Settings aboutToDisappear End !!')
  }

  // 注册路由页面
  async dynamicLoadCallBack(key: string): Promise<boolean> {
    if (key === 'AccountList') {
      let accountListLoader = await import('./AccountList');
      this.accountListLoader = accountListLoader.AccountListLoader;
      this.loaderMap.set('AccountList', this.accountListLoader)
    } else if (key === 'ArrangeContacts') {
      let arrangeContactsLoader = await import('./ArrangeContacts');
      this.arrangeContactsLoader = arrangeContactsLoader.arrangeContactsLoader;
      this.loaderMap.set('ArrangeContacts', this.arrangeContactsLoader)
    } else if (key === 'BatchDeleteContacts') {
      let batchDeleteContactsLoader = await import('./BatchDeleteContacts');
      this.batchDeleteContactsLoader = batchDeleteContactsLoader.batchDeleteContactsLoader;
      this.loaderMap.set('BatchDeleteContacts', this.batchDeleteContactsLoader)
    } else if (key === 'CopyContacts') {
      let copyContactsLoader = await import('./CopyContacts');
      this.copyContactsLoader = copyContactsLoader.copyContactsLoader;
      this.loaderMap.set('CopyContacts', this.copyContactsLoader)
    } else if (key === 'ImportAndExport') {
      let importAndExportLoader = await import('./ImportAndExport');
      this.importAndExportLoader = importAndExportLoader.ImportAndExportLoader;
      this.loaderMap.set('ImportAndExport', this.importAndExportLoader)
    } else if (key === 'RecentDelete') {
      let recentDeleteLoader = await import('./RecentDelete');
      this.recentDeleteLoader = recentDeleteLoader.RecentDeleteLoader;
      this.loaderMap.set('RecentDelete', this.recentDeleteLoader)
    } else if (key === 'SelectRepeatContact') {
      let selectRepeatContact = await import('./SelectRepeatContact');
      this.selectRepeatContactLoader = selectRepeatContact.selectRepeatContactLoader;
      this.loaderMap.set('SelectRepeatContact', this.selectRepeatContactLoader)
    }
    let pageLoader = (this.loaderMap.get(key) as ($$: Params) => void)
    HiLog.i(TAG, 'dymic load page: ' + key + '--' + (pageLoader === undefined))
    return pageLoader === undefined
  }

  private itemGroupArrays: SettingItemGroup[] = [
    {
      headerTitle: $r('app.string.contact_management'),
      items: [
        {
          title: $r('app.string.show_contacts'),
          index: 0
        },
        {
          title: $r('app.string.organize_contacts'),
          index: 1
        },
        {
          title: $r('app.string.Import_Export'),
          index: 2,
          enabled: this.mSystemModeController.getIsEnableImportOrExportContact()
        },
        {
          title: $r('app.string.contacts_recycle'),
          subTitle: $r('app.string.contacts_recycle_summary'),
          index: 5,
        }
      ]
    },
  ]
  private itemGroupIds: string[][] = [
    [
      'settings_show_contacts_list_item',
      'settings_organize_contacts_list_item',
      'settings_import_export_list_item'
    ],
  ]

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  @Styles
  private disabledStyles() {
    .opacity($r(DISABLED_OPACITY_STRING))
  }

  jumpToSettingSubpage() {
    if (!StringUtil.isEmpty(this.subpage)) {
      HiLog.i(TAG, 'jumpToSettingSubpage  Subpage:' + this.subpage);
      switch (this.subpage) {
        case 'recently_deleted':
          this.presenter.recentDelete();
          HiLog.i(TAG, 'onCreate is coming from detection tools end recently_deleted');
          break;
        case 'organize_contacts':
          this.presenter.arrangeContacts();
          HiLog.i(TAG, 'onCreate is coming from detection tools end organize_contacts');
          break;
        default:
          break;
      }
      this.subpage = '';
    } else {
      HiLog.i(TAG, 'subpage empty');
    }
  }

  private getItemHeight(cardItem: LooseObject): ResourceStr {
    if (this.isPC) {
      return cardItem.subTitle ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_sm');
    }
    return cardItem.subTitle ? $r('app.float.id_item_height_max') : $r('app.float.id_item_height_mid');
  }

  build() {
    // 改用Navigation路由
    Navigation(this.contactsSettingsNavStack) {
      Column() {
        List({ scroller: this.scroller }) {
          ForEach(this.itemGroupArrays, (group: SettingItemGroup, index: number) => {
            if (this.isPC) {
              PCSubTitle({
                subtitle: group.headerTitle,
                titleMargin: {
                  start: LengthMetrics.resource($r('app.float.id_width_36')),
                  end: LengthMetrics.resource($r('app.float.id_width_36'))
                }
              })
            } else {
              SubHeader({
                secondaryTitle: group.headerTitle,
                secondaryTitleModifier: this.isThemeActive ?
                new TextModifier().fontColor($r('app.color.skin_font_secondary')).maxFontScale(2.25) :
                new TextModifier().maxFontScale(2.25),
                contentMargin: { start: this.isTabletLandscape ? LengthMetrics.vp(16)
                  : LengthMetrics.resource($r('sys.float.margin_left')) }
              })
                .margin({ left: this.isTabletLandscape ? $r('app.float.id_card_margin_large') : 0 })
            }

            ListItemGroup({ style: ListItemGroupStyle.CARD }) {
              ForEach(group.items, (cardItem: SettingItem, idx: number) => {
                if (cardItem.index !== SHOW_CONTATC) {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(cardItem.title)
                          .constraintSize({ minHeight: '21vp' })
                          .textAlign(TextAlign.Start)
                          .fontSize($r('sys.float.Body_L'))
                          .fontColor($r('app.color.skin_font_primary'))
                          .fontWeight(FontWeight.Medium)
                        if (cardItem.subTitle !== undefined) {
                          Text(cardItem.subTitle)
                            .textAlign(TextAlign.Start)
                            .fontSize($r('sys.float.Body_M'))
                            .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                            .fontWeight(FontWeight.Regular)
                            .constraintSize({ minHeight: 19 })
                        }
                      }
                      .width(`calc(100% - 20vp)`)
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Start)

                      SymbolGlyph($r('sys.symbol.chevron_right'))
                        .fontSize($r('app.float.id_card_image_small'))
                        .fontColor([$r('app.color.skin_icon_fourth')])
                        .flexShrink(0)
                        .margin({
                          left: $r('app.float.id_card_margin_large')
                        })
                    }
                    .enabled(cardItem.enabled ?? true)
                    .stateStyles({
                      pressed: this.pressedStyles,
                      normal: this.normalStyles,
                      disabled: this.disabledStyles
                    })
                    .padding({
                      left: $r('app.float.id_card_margin_large'),
                      right: $r('app.float.id_card_margin_large'),
                      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                        0, $r('app.float.id_card_item_margin_top')),
                      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                        0, $r('app.float.id_card_item_margin_top'))
                    })
                    .constraintSize({
                      minHeight: this.getItemHeight(cardItem)
                    })
                    .justifyContent(FlexAlign.SpaceBetween)
                    .alignItems(VerticalAlign.Center)
                    .width('100%')
                  }
                  .id(this.itemGroupIds[index][idx])
                  .accessibilityGroup(true)
                  .onClick(() => {
                    HiLog.i(TAG, `Settings List onClick index:${cardItem.index}`);
                    if (cardItem.index === 0) {
                      // 联系人打点--联系人设置点击显示联系人
                      DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.SETTINGS_SHOW_CONTACT_EVENT);
                      this.presenter.accountList()
                    } else if (cardItem.index === 1) {
                      // 联系人打点--联系人设置点击整理联系人
                      DotUtil.getInstance().contactDot(customParams,
                        dotCommon.eventName.SETTINGS_ORGANIZE_CONTACT_EVENT);
                      this.presenter.arrangeContacts()
                    } else if (cardItem.index === 2) {
                      if (!this.mSystemModeController.getIsEnableImportOrExportContact()) {
                        showToast(this.getUIContext(), this.mSystemModeController.getDisabledFunctionTip());
                      } else {
                        // 联系人打点--联系人设置点击导入/导出
                        DotUtil.getInstance().contactDot(customParams,
                          dotCommon.eventName.SETTINGS_IMPORT_AND_EXPORT_EVENT);
                        this.presenter.importAndExport()
                      }
                    } else if (cardItem.index === 5) {
                      // 联系人打点--联系人设置点击最近删除
                      DotUtil.getInstance()
                        .contactDot(customParams, dotCommon.eventName.SETTINGS_RECENT_DELETE_EVENT);
                      this.presenter.recentDelete();
                    }
                  })
                }
              }, (item: LooseObject) => JSON.stringify(item))
            }
            .borderRadius(this.isPC ? $r('sys.float.corner_radius_level8') :
            $r('app.float.id_card_image_s'))
            .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
            .margin({ left: this.spaceLR, right: this.spaceLR })
            .divider({
              strokeWidth: '1px',
              color: $r('app.color.skin_ohos_id_color_list_separator'),
              startMargin: $r('app.float.id_card_margin_large'),
              endMargin: $r('app.float.id_card_margin_large')
            })
          })
        }
        .flexShrink(1)
        .width('100%')
        .height(this.curBp === 'sm' ? '100%' : 'calc(100% - 56vp)')
        .contentEndOffset(56)
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .clipContent(ContentClipMode.SAFE_AREA)
        .safeAreaPadding({ top: $r('app.float.id_item_height_max') })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.isThemeActive ? undefined : $r('app.color.color_bind_sheet_background'))
      .backgroundImage((!this.isThemeActive) ? undefined : $r('app.media.contact_list_bg'))
      .backgroundImageSize((!this.isThemeActive) ? undefined : { width: '100%', height: '100%' })
    }
    .navDestination(this.SettingsRouter)
    .titleMode(NavigationTitleMode.Mini)
    .title(ResourceUtil.getStringByResource($r('app.string.call_setting_type_setting')))
    .hideBackButton( true)
    .menus(this.TitleGuide())
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), TitleBarUtil.getBindSheetCloseButton(), () => {
    //   this.contactsSettingsNavStack?.pop();
    // }))
    // .bindToScrollable([this.scroller])
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: this.isPC ? {
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
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.call_setting_type_setting')) },
  //   };
  // }

  @Builder
  TitleGuide() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .type(ButtonType.Circle)
      .borderRadius(0)
      .width($r('app.float.id_card_image_mid'))
      .height($r('app.float.id_card_image_mid'))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .stateEffect(true)
      .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
      .id('Settings_close_btn')
      .onClick(() => {
        emitter.emit({
          eventId: EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID
        });
      })
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .height($r('app.float.id_item_height_large'))
    .padding({
      end: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource(this.spaceLR),
    })
    .margin({
      left: this.isPC ? '8vp' : ((this.curBp === 'lg') ? '24vp' : undefined)
    })
  }

  // Navigation路由表
  @Builder
  SettingsRouter(name: string, param?: Object) {
    if (name === 'AccountList') {
      this.accountListLoader(param as Params);
    } else if (name === 'ArrangeContacts') {
      this.arrangeContactsLoader(param as Params);
    } else if (name === 'BatchDeleteContacts') {
      this.batchDeleteContactsLoader(param as Params);
    } else if (name === 'CopyContacts') {
      this.copyContactsLoader(param as Params);
    } else if (name === 'ImportAndExport') {
      this.importAndExportLoader(param as Params);
    } else if (name === 'RecentDelete') {
      this.recentDeleteLoader(param as Params);
    } else if (name === 'SelectRepeatContact') {
      this.selectRepeatContactLoader(param as Params);
    }
  }

  @Builder
  NetworkBuilder() {
    Column() {
      Column() {
        SymbolGlyph($r('sys.symbol.worldclock_fill'))
          .fontSize($r('app.float.id_card_image_s'))
          .fontColor([$r('app.color.skin_icon_on_primary')])
      }
      .width($r('app.float.id_card_margin_xxxxl'))
      .height($r('app.float.id_card_margin_xxxxl'))
      .backgroundColor($r('app.color.skin_ohos_id_color_activated'))
      .justifyContent(FlexAlign.Center)
      .borderRadius($r('sys.float.corner_radius_level8'))

      Row() {
        Text($r('app.string.allow_contacts_to_connect_Internet'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontColor($r('app.color.skin_font_primary'))
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')
      }
      .height($r('app.float.id_item_height_large'))
      .align(Alignment.Center)

      Text($r('app.string.used_to_view_web_content_such_as_the_privacy_statement'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontColor($r('app.color.skin_font_tertiary'))
        .lineHeight(21)
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
    }
  }
}

// 定义dummyFunction
@Builder
function dummyFunction() {

}