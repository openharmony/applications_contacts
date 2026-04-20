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
import { sharedPreferencesUtils } from '../../../../../../../feature/call/oh_modules/common';
import SettingsPresenter from '../../../presenter/contact/settings/SettingsPresenter';
import { DynamicLoader } from '../../../../../../../common/src/main/ets/util/DynamicLoader';
import { AccountVo } from '../../../model/bean/AccountVo';
import ArrangeContactsPresenter from '../../../presenter/contact/settings/ArrangeContactsPresenter';
import CopyContactDialog from '../../dialog/CopyContactDialog';
import { CustomizedParams } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import dotCommon, { contactParams, searchIndexParams } from '../../../util/DotCommon';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '../../../util/ResourceUtil';
import LooseObject from '../../../model/type/LooseObject';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { FontScaleState } from '../../../util/fontScaleState';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { mergeDuplicateContactsByUrl, rebuildContactSearchIndex } from '../../../task/TaskService';
import { SymbolGlyphModifier, LengthMetrics, TextModifier } from '@kit.ArkUI';
import { AlertDialog, LoadingDialog } from '@ohos.arkui.advanced.Dialog';
import { promptAction } from '@kit.ArkUI';
import { RestoreResultType } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository'
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import prompt from '@ohos.promptAction'
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../../data/EmitterConstant';

// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit'
// import { HdsNavDestinationTitleMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';

const TAG = 'ArrangeContacts  ';
const CLICK_ORGANIZE_AUTOMERGE_EVENT = 'CLICK_ORGANIZE_AUTOMERGE_EVENT';
const CLICK_ORGANIZE_MERGE_EVENT = 'CLICK_ORGANIZE_MERGE_EVENT';
const CLICK_ORGANIZE_COPY_EVENT = 'CLICK_ORGANIZE_COPY_EVENT';
const CLICK_ORGANIZE_BAT_DEL_EVENT = 'CLICK_ORGANIZE_BAT_DEL_EVENT';
const ORGANIZE_AUTOMERGE_DIALOG_EVENT = 'ORGANIZE_AUTOMERGE_DIALOG_EVENT';
// 自动合并重复联系人的状态
const TOGGLE_OPEN = 1;
const TOGGLE_CLOSE = 0;
// 隐藏复制联系人入口
const COPY_CONTACT = 99
class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function arrangeContactsLoader($$: Params): void {
  ArrangeContacts();
}

@Extend(Text)
function titleGeneraStyle() {
  .textAlign(TextAlign.Start)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('app.color.skin_font_primary'))
  .fontWeight(FontWeight.Medium)
}


@Component
export default struct ArrangeContacts {
  @Consume('contactsSettingsNavStack') contactsSettingsNavStack: NavPathStack;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  presenter: ArrangeContactsPresenter = ArrangeContactsPresenter.getInstance();
  @State @Watch('isClickDot') private isAutoMerge: boolean = false;
  @State accountNum: number = 0;
  @State isCopyContact: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('rawContactCount') @Watch('contactCountChange') rawContactCount: number = 0
  @StorageLink('contactCount') @Watch('contactCountChange') contactCount: number = 0
  organizeAutoContactsParams: CustomizedParams = {
    ISOPEN: 0
  };
  customizedParams: CustomizedParams = {};
  organizeAutoDialogParams: CustomizedParams = {
    ISKNOW: 0
  };
  isClickToggle = false;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  // 恢复联系人数量
  @State recoveredContactCount: number = 0;
  private transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.TITLE;
  private scroller: Scroller = new Scroller();
  copyDialogControler: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.copy_contact_from'),
      contentBuilder: () => {
        this.CopyContactBuilder();
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.w(TAG, 'onShareDialogCancel !!! ');
          }
        }
      ]
    }),
    autoCancel: false,
    gridCount: 4,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  exportDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.auto_merge_duplicate_contacts_rule'),
      contentBuilder: () => {
        this.AutoMergeDuplicateContactsRuleBuilder();
      },
      buttons: [
        {
          value: $r('app.string.got_it'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            // 联系人打点--整理联系人自动合并重复联系人i弹窗点击知道了
            this.organizeAutoDialogParams.ISKNOW = 1;
            DotUtil.getInstance().contactDot(this.organizeAutoDialogParams, ORGANIZE_AUTOMERGE_DIALOG_EVENT);
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  restoreConfirmDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.restore_contacts_confirm_title'),
      contentBuilder: () => {
        this.restoreConfirmDialogContent()
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.restoreConfirmDialogController?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        },
        {
          value: $r('app.string.contacts_restore'),
          action: () => {
            HiLog.w(TAG, 'restore clicked');
            this.restoreConfirmDialogController?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            // 恢复联系人
            this.presenter.restoreContacts((success: boolean) => {
              // 处理成功回调
              if (success) {
                this.restoreContactDialogController?.open();
                DialogControllerManager.getInstance().addDialogController(this.restoreContactDialogController);
              } else {
                this.restoreContactDialogController?.close();
                DialogControllerManager.getInstance().dialogControllerSet.clear();
                promptAction.showToast({
                  message: $r('app.string.no_restorable_contact')
                });
              }
            }, (success: boolean, message: string | Resource) => {
              // 处理失败回调
              this.restoreContactDialogController?.close();
              DialogControllerManager.getInstance().dialogControllerSet.clear();
              promptAction.showToast({
                message: message
              });
            })
          },
          role: ButtonRole.ERROR
        }
      ]
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  restoreContactDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.contacts_restoring')
    }),
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      // The dialog cannot be closed by user's action
    },
  });
  rebuildContactDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.recreating_index_data'),
      content: $r('app.string.contact_index_dialog'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          DotUtil.getInstance().contactDot(searchIndexParams, dotCommon.eventName.REBUILD_INDEX_EVENT);
        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          this.rebuildContactLoadingDialogController.open();
          DialogControllerManager.getInstance().addDialogController(this.rebuildContactLoadingDialogController);
          rebuildContactSearchIndex(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result) => {
            this.rebuildContactLoadingDialogController.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            searchIndexParams.SEARCH_INDEX = result;
            DotUtil.getInstance().contactDot(searchIndexParams, dotCommon.eventName.REBUILD_INDEX_EVENT);
          });
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  rebuildContactLoadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.rebuilding_wait')
    }),
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    autoCancel: false,
  });

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .width('100%')
    .constraintSize({ minHeight: 48 })
    .opacity(1)
  }

  @Styles
  imgPressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level2'))
    .width(48)
    .constraintSize({ minHeight: 48 })
    .opacity(1)
    .offset({ x: -18 })
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  isClickDot() {
    // 联系人打点--整理联系人点击自动合并重复联系人
    if (this.isClickToggle) {
      if (this.isAutoMerge) {
        this.organizeAutoContactsParams.ISOPEN = TOGGLE_OPEN;
      } else {
        this.organizeAutoContactsParams.ISOPEN = TOGGLE_CLOSE;
      }
      DotUtil.getInstance()
        .contactDot(this.organizeAutoContactsParams, CLICK_ORGANIZE_AUTOMERGE_EVENT);
    }
    this.isClickToggle = false;
  }

  async aboutToAppear() {
    HiLog.w(TAG, 'the Page ArrangeContacts aboutToAppear Begin !!')
    await sharedPreferencesUtils.removePreferencesFromCache('isAutoMerge');
    HiLog.w(TAG, 'the Page ArrangeContacts remove cache ');
    this.presenter.initNavPaths(this.contactsSettingsNavStack);
    this.contactCountChange()

    // Check whether there is a SIM card.
    let haveSimCard: boolean = AppStorage.get('haveSimCard') as boolean;
    if (haveSimCard) {
      this.isCopyContact = true;
    }

  }

  async contactCountChange() {
    const getAllRawContactSizeAsync = await this.presenter.getAllRawContactSizeAsync();
    sharedPreferencesUtils.getFromPreferences('isAutoMerge', false).then(value => {
      HiLog.w(TAG, 'getFromPreferences isAutoMerge:' + value)
      this.isAutoMerge = value as boolean;
    });
    HiLog.w(TAG, 'the Page ArrangeContacts aboutToAppear End');
    this.presenter.getAllAccountAndContactSize((data: number) => {
      this.accountNum = data;
    });

    // 智能合并显示数据联系人数量
    if (AppStorage.get('rawContactCount') && getAllRawContactSizeAsync) {
      HiLog.w(TAG, 'Initialize the intelligent combination quantity update !!')
      this.rawContactCount = AppStorage.get('rawContactCount') as number;
      this.contactCount = AppStorage.get('contactCount') as number;
    } else {
      this.rawContactCount = 0;
      this.contactCount = 0;
    }
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'the Page ArrangeContacts aboutToDisappear Begin !!')
    this.accountNum = 0;
    this.isCopyContact = false;
    HiLog.w(TAG, 'the Page ArrangeContacts aboutToDisappear End !!')
  }

  private itemGroupArrays: LooseObject[] = [
    {
      title: $r('app.string.auto_merge_duplicate_contacts'),
    },
    {
      title: $r('app.string.manually_merge_duplicate_contacts'),
    },
    {
      title: $r('app.string.batch_delete'),
    },
  ]

  build() {
    NavDestination() {
      Column() {
        List({ scroller: this.scroller }) {
          ListItemGroup({ style: ListItemGroupStyle.CARD }) {
            ForEach(this.itemGroupArrays, (cardItem: LooseObject, index: number) => {
              if (!this.isPC || (this.isPC && index !== 2)) {
                ListItem() {
                  if (index !== COPY_CONTACT) {
                    if (index == 0) {
                      this.AutoMergeDuplicateContactsStyleBuilder(cardItem, index);
                    } else {
                      this.NormalArrangeContactsStyleBuilder(cardItem, index);
                    }
                  }
                }.align(Alignment.Bottom)
              }
            })
          }
          .borderRadius($r('app.float.id_card_image_s'))
          .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
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
      .margin({ top: $r('app.float.id_card_margin_large') })
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.color_bind_sheet_background'))
      .flexShrink(1)

      Row() {
        Text(ResourceUtil.getPluralStringByResource($r('app.plural.cloud_contacts'), this.rawContactCount) + ' | ' +
        ResourceUtil.getPluralStringByResource($r('app.plural.merge_contacts'), this.contactCount))
          .fontSize('12vp')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_font_secondary'))
          .flexShrink(1)
          .maxFontScale(this.isPC ? 1 : 1.3)
      }
      .margin({
        bottom: $r('app.float.id_card_margin_xxl')
      })
      .justifyContent(FlexAlign.Center)
    }
    // .titleMode(HdsNavDestinationTitleMode.MODAL)
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), TitleBarUtil.getBindSheetCloseButton(), () => {
    //   this.contactsSettingsNavStack?.pop();
    // }))
    .title( ResourceUtil.getStringByResource($r('app.string.organize_contacts')),
      {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource($r('sys.float.margin_left'))
      })
    .menus(this.TitleGuide())
    .onBackPressed(() => {
      // 联系人打点--手动合并重复联系人
      this.contactsSettingsNavStack?.pop();
      return true;
    })
    .bindToScrollable([this.scroller])
    .backgroundColor($r('app.color.color_bind_sheet_background'))
    .padding({
      bottom: this.curBp !== 'sm' ? $r('sys.float.padding_level0') : px2vp(this.fullScreenPadding.bottom as number)
    })
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
  //     padding: { start: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource($r('sys.float.margin_left')) },
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.organize_contacts')) },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
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
      .id('ArrangeContacts_close_btn')
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

  @Styles
  contactsStyle() {
    .id('arrange_contact_organizeAutoContactsParams_img')
    .padding({
      left: $r('app.float.id_card_margin_large'),
      right: $r('app.float.id_card_margin_large'),
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        0, $r('app.float.id_card_item_margin_top')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        0, $r('app.float.id_card_item_margin_top'))
    })
    .constraintSize({
      minHeight: this.isPC ? $r('app.float.id_item_height_sm') : $r('app.float.id_item_height_mid')
    })
    .width('100%')
  }

  @Builder
  ContactsTitleText(cardItem: LooseObject, index: number) {
    Column() {
      Text(cardItem.title)
        .constraintSize({ minHeight: '21vp' })
        .titleGeneraStyle()
        .opacity(index === COPY_CONTACT ? (this.accountNum > 1 ? 1 : $r('sys.float.ohos_id_alpha_disabled')) : 1)
        .width(FontScaleState.isStandardGeer(this.fontSizeScale) ? 'auto' :
          index == 0 ? `calc(100% - 64vp)` : `calc(100% - 20vp)`)
      if (cardItem.subTitle !== undefined) {
        Text(cardItem.subTitle)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('app.color.skin_font_secondary'))
          .fontWeight(FontWeight.Regular)
          .constraintSize({ minHeight: 19 })
          .margin({ top: $r('sys.float.padding_level1') })
      }
    }
    .width(`calc(100% - 20vp)`)
    .constraintSize({ minHeight: cardItem.subTitle ? 64 : 48})
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  AutoMergeDuplicateContactsStyleBuilder(cardItem: LooseObject, index: number) {
    Row() {
      Text(cardItem.title)
        .constraintSize({ minHeight: '21vp', maxWidth: `calc(100% - 64vp)` })
        .titleGeneraStyle()
        .opacity(index === COPY_CONTACT ? (this.accountNum > 1 ? 1 : $r('sys.float.ohos_id_alpha_disabled')) : 1)
        .width(FontScaleState.isStandardGeer(this.fontSizeScale) ? `auto` : `calc(100% - 64vp)`)
      Button() {
        SymbolGlyph($r('sys.symbol.info_circle'))
          .fontSize($r('app.float.id_width_16'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .margin({ left: $r('app.float.id_card_margin_mid') })
      .accessibilityLevel('yes')
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_detail')))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .stateEffect(false)
      .hitTestBehavior(HitTestMode.Block)
      .onClick(() => {
        this.exportDialogController.open();
        DialogControllerManager.getInstance().addDialogController(this.exportDialogController);
      })
      Blank()
      Toggle({
        type: ToggleType.Switch,
        isOn: this.isAutoMerge
      })
        .accessibilityLevel('yes')
        .hoverEffect(HoverEffect.None)
        .selectedColor($r('app.color.skin_comp_background_emphasize'))
        .switchPointColor($r('app.color.skin_comp_background_primary_contrary'))
        .onChange((isOn: boolean) => {
          HiLog.w(TAG, 'auto merge contact power: ' + isOn);
          this.isAutoMerge = isOn;
          sharedPreferencesUtils.saveToPreferences('isAutoMerge', this.isAutoMerge);
          if (isOn) {
            HiLog.w(TAG, 'auto merge contact power start!');
            mergeDuplicateContactsByUrl(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
          }
        })
        .onClick(() => {
          this.isClickToggle = true;
        })
        .width(36)
        .height(20)
        .padding({ right: -2 })
        .align(Alignment.End)
        .margin({
          right: 0,
          left: FontScaleState.isStandardGeer(this.fontSizeScale) ? 0 : $r('app.float.id_card_margin_large')
        })
    }
    .accessibilityGroup(true)
    .justifyContent(FlexAlign.Start)
    .contactsStyle()
    .accessibilityText(`${AccessibilityUtil.getInstance()
      .setAccessibilityText(this.isOpenAccessibility,
        $r('app.string.auto_merge_duplicate_contacts'))} ${AccessibilityUtil.getInstance()
      .setAccessibilityText(this.isOpenAccessibility,
        this.isAutoMerge ? $r('app.string.accessibility_open') : $r('app.string.shut_down'))}`)
  }

  @Builder
  NormalArrangeContactsStyleBuilder(cardItem: LooseObject, index: number) {
    Row() {
      this.ContactsTitleText(cardItem, index);
      Blank()
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_fourth')])
          .flexShrink(0)
          .visibility(Visibility.Visible)
          .margin({
            left: $r('app.float.id_card_margin_large')
          })
    }
    .stateStyles({
      pressed: {
        // 条件渲染不同的按压态背景颜色
        .backgroundColor((index === COPY_CONTACT && this.accountNum < 2) ?
        $r('app.color.skin_comp_background_primary') : $r('app.color.skin_interactive_click'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .opacity(1)
      },
      normal: this.normalStyles
    })
    .onClick(async () => {
      if (index === 1) {
        // 联系人打点--整理联系人点击手动合并重复联系人
        DotUtil.getInstance().contactDot(this.customizedParams, CLICK_ORGANIZE_MERGE_EVENT);
        this.presenter.goSelect();
      } else if (index === COPY_CONTACT) {
        if (this.accountNum > 1) {
          // 联系人打点--整理联系人点击复制联系人
          HiLog.w(TAG, 'copy contacts');
          DotUtil.getInstance().contactDot(this.customizedParams, CLICK_ORGANIZE_COPY_EVENT);
          this.copyDialogControler?.open();
          DialogControllerManager.getInstance().addDialogController(this.copyDialogControler);
        }
      } else if (index == 2) {
        // 联系人打点--整理联系人点击批量删除
        DotUtil.getInstance().contactDot(this.customizedParams, CLICK_ORGANIZE_BAT_DEL_EVENT);
        DynamicLoader.getInstance().fire(DynamicLoader.BATCH_DELETE_CONTACTS, true).then(() => {
          AppStorage.setOrCreate('toBatchDeleteContactsNavStack', this.contactsSettingsNavStack);
          this.contactsSettingsNavStack.pushPathByName('BatchDeleteContacts', '')
        }).catch((error: Error) => {
          HiLog.e(TAG, `failed to fire DynamicLoader for batch delete contacts, error: ${error?.message}`);
        });
      }
    })
    .justifyContent(FlexAlign.Start)
    .contactsStyle()
  }

  @Builder
  restoreConfirmDialogContent() {
    Scroll(){
      Column() {
        Text(ResourceUtil.getPluralStringByResource($r('app.plural.recovering_contact_dialog'), this.recoveredContactCount))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .constraintSize({ minHeight: $r('app.float.id_height_56') })
      .width('100%')
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }
  @Builder
  AutoMergeDuplicateContactsRuleBuilder() {
    Scroll() {
      Text($r('app.string.automatically_merge_contacts'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .maxFontScale(2)
        .fontColor($r('app.color.skin_font_primary'))
        .textAlign(TextAlign.Start)
        .lineHeight(FontScaleState.isStandardGeer(this.fontSizeScale) ? '22vp' : 0)
        .width('100%')
        .wordBreak(WordBreak.BREAK_WORD)
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
  }

  @Builder
  CopyContactBuilder() {
    Column() {
      CopyContactDialog({
        itemList: this.presenter.getAccountNameList(),
        onItemClick: (item: string | Resource) => {
          let params: Record<string, string | AccountVo[]> = {
            'accountId': '',
            'accountList': this.presenter.accountList
          };
          this.presenter.accountList.forEach(accountVo => {
            if (accountVo.accountName === item as string) {
              params.accountId = accountVo.accountId;
            }
          })
          DynamicLoader.getInstance().fire(DynamicLoader.COPY_CONTACTS_PAGE).then(() => {
            this.contactsSettingsNavStack.pushPathByName('CopyContacts', params);
          });
          this.copyDialogControler?.close();
        }
      })
    }
    .width('100%')
  }
}