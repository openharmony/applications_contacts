/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import SpeedDialPresenter from '../../presenter/speeddial/SpeedDialPresenter';
import { CustomizedParams, VoiceMailItem } from '../../model/type/index';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import DotUtil from '../../util/DotUtil';
import { CustomContentDialog, SelectDialog } from '@ohos.arkui.advanced.Dialog';
import CantactColumnUtils from '../../util/CantactColumnUtils';
import { FontScaleState } from '../../util/fontScaleState';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { LengthMetrics, Router, TextModifier } from '@kit.ArkUI';
import contact from '@ohos.contact';
import { BusinessError } from '@ohos.base';
import dotCommon from '../../util/DotCommon';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { ContactsConstants } from '../../../../../../common/src/main/ets/ContactsConstants';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
import { ResourceUtil } from '../../util/ResourceUtil';
import EnvironmentProp from '../../feature/EnvironmentProp';

const TAG = 'VoiceMail ';
const CLICK_VOICEMAIL_EVENT = 'CLICK_VOICEMAIL_EVENT';
const SER_PROVIDER_DIALOG_EVENT = 'SER_PROVIDER_DIALOG_EVENT';
const VOICEMAIL_NUM_DIALOG_EVENT = 'VOICEMAIL_NUM_DIALOG_EVENT';
const VOICEMAIL_TO_CONTACT_EVENT = 'VOICEMAIL_TO_CONTACT_EVENT';

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Component
export default struct VoiceMail {
  // 路径信息
  @Consume('pathInfos') pathInfos: NavPathStack;
  speedDialPresenter: SpeedDialPresenter = SpeedDialPresenter.getInstance();
  navTitle?: string = '';
  @State voiceMails: Array<VoiceMailItem> = [];
  @State dialogInput: string = '';
  @State inputValue: string = '';
  @StorageLink('voicemailNumberString') @Watch('voicemailNumberChanged') voicemailNumberString: string = '';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageLink('breakpoint') curBp: string = 'sm';
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  // 字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State isShowSheet: boolean = false;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  private isPC: boolean = EnvironmentProp.isPC();
  @StorageLink('fullScreenPadding')  fullScreenPadding: Padding = {};
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  voiceChooseParams: CustomizedParams = {
    ITEM: 0
  };
  serPreviderDialogParams: CustomizedParams = {
    ISCANCEL: 1
  };
  voiceNumDialogParams: CustomizedParams = {
    ISIUPUT: 0,
    ISOK: 0
  };
  customizedParams: CustomizedParams = {};
  voiceMailDialog: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.voicemail_number'),
      contentBuilder: () => {
        this.VoiceMailDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            // 联系人打点--语音信箱号码弹窗点击取消
            this.voiceNumDialogParams.ISIUPUT = this.inputValue ? 1 : 0;
            this.voiceNumDialogParams.ISOK = 0;
            DotUtil.getInstance().contactDot(this.voiceNumDialogParams, VOICEMAIL_NUM_DIALOG_EVENT);
            this.voiceMailDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        },
        {
          value: $r('app.string.confirm'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            // 联系人打点--语音信箱号码弹窗点击确认
            this.voiceNumDialogParams.ISIUPUT = this.inputValue ? 1 : 0;
            this.voiceNumDialogParams.ISOK = 1;
            DotUtil.getInstance().contactDot(this.voiceNumDialogParams, VOICEMAIL_NUM_DIALOG_EVENT);
            this.inputValue = this.inputValue.replace(new RegExp('-', 'ig'), '');
            this.voicemailDialogConfirmEvent(this.inputValue);
            this.voiceMailDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') :
    $r('app.color.skin_comp_background_primary'),
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  serviceProviderDialog: CustomDialogController | null = new CustomDialogController({
    builder: SelectDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      title: $r('app.string.service_provider'),
      selectedIndex: 0,
      confirm: {
        value: $r('app.string.cancel'),
        action: () => {
          // 联系人打点--点击取消弹窗
          DotUtil.getInstance().contactDot(this.serPreviderDialogParams, SER_PROVIDER_DIALOG_EVENT);
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      radioContent: [
        {
          title: $r('app.string.my_carrier'),
          action: () => {
            // 联系人打点--点击取消弹窗
            DotUtil.getInstance().contactDot(this.serPreviderDialogParams, SER_PROVIDER_DIALOG_EVENT);
            this.serviceProviderDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  voicemailNumberChanged() {
    HiLog.w(TAG, 'voicemailNumberChanged from selected contact');
    if (this.voicemailNumberString && !StringUtil.isEmpty(this.voicemailNumberString)) {
      this.dialogInput = this.voicemailNumberString;
      this.inputValue = this.dialogInput;
      this.voiceMailDialog?.open();
      DialogControllerManager.getInstance().addDialogController(this.voiceMailDialog);
      AppStorage.setOrCreate('voicemailNumberString', '');
    }
  }

  voicemailDialogConfirmEvent(value: string) {
    HiLog.w(TAG, 'voicemailDialogConfirmEvent');
    this.speedDialPresenter.confirmVoiceMail(value, (res: boolean) => {
      if (res) {
        this.dialogInput = value;
        let item = this.voiceMails[1];
        item.voiceMailItemValue = value;
        this.voiceMails.splice(1, 1, item);
      }
    });
  }

  async setBackGround() { //api10
    let windowClass: window.Window = await window.getLastWindow(this.context) //Obtains window instances.
    await windowClass?.setWindowBackgroundColor('#f2f3f5') //Setting the background color of the window
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear');
    let obj: Record<string, number> =
      this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as Record<string, number>;
    this.speedDialPresenter.slotId = obj?.slotId;
    this.speedDialPresenter.initVoiceMailList((data: Array<VoiceMailItem>) => {
      this.voiceMails = data;
    });
    this.setBackGround()
  }

  aboutToDisappear() {
    this.voiceMailDialog = null;
    this.serviceProviderDialog = null;
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.id_hds_title_margin'))
      }
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: { sm: 0, md: 12, lg: 16 }, y: 0 } }) {
        GridCol({ span: { sm: 0, md: 1, lg: 2 } })
        GridCol({ span: { sm: 4, md: 6, lg: 8 } }) {
          Column() {
            List() {
              ForEach(this.voiceMails, (item: VoiceMailItem, index?: number) => {
                ListItem() {
                  Column() {
                    if (FontScaleState.isStandardGeer(this.fontSizeScale)) {
                      this.normalLayout(item, index)
                    } else {
                      this.seniorLayout(item, index)
                    }
                  }
                  .width('100%')
                  .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
                  .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
                  .onClick(() => {
                    if (index === 1) {
                      // 联系人打点--点击语音信箱号码
                      this.voiceChooseParams.ITEM = dotCommon.eventParam.CLICK_VOICEMAIL_NUMBER;
                      DotUtil.getInstance().contactDot(this.voiceChooseParams, CLICK_VOICEMAIL_EVENT);
                      this.dialogInput = item.voiceMailItemValue;
                      this.inputValue = this.dialogInput;
                      this.voiceMailDialog?.open();
                      DialogControllerManager.getInstance().addDialogController(this.voiceMailDialog);
                    } else {
                      // 联系人打点--点击服务提供商
                      this.voiceChooseParams.ITEM = dotCommon.eventParam.CLICK_SERVICE_PROVIDER;
                      DotUtil.getInstance().contactDot(this.voiceChooseParams, CLICK_VOICEMAIL_EVENT);
                      this.serviceProviderDialog?.open();
                      DialogControllerManager.getInstance().addDialogController(this.serviceProviderDialog);
                    }
                  })
                  .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
                }
                .stateStyles({
                  normal: this.normalStyles,
                  pressed: this.pressedStyles,
                })
                .width('100%')
                .borderRadius($r('sys.float.corner_radius_level8'))
                .margin({
                  top: (index === 0) ? $r('sys.float.padding_level2') : 0,
                  bottom: (index === 1) ? $r('sys.float.padding_level2') : 0,
                })
              }, (item: VoiceMailItem) => JSON.stringify(item))
            }
            .padding({
              left: $r('sys.float.padding_level2'),
              right: $r('sys.float.padding_level2'),
            })
            .borderRadius($r('sys.float.corner_radius_level10'))
            .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor($r('app.color.skin_comp_background_gray'))
          .padding({ top: $r('app.float.id_card_margin_large') })
        }
      }.margin({
        right: CantactColumnUtils.getInstance().getPaddingSpace(this.curBp),
        left: CantactColumnUtils.getInstance().getPaddingSpace(this.curBp),
      })
    }

    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
    //   HiLog.i(TAG, 'On title bar back pressed!!');
    //   this.voicemailBackPressed();
    // }))
    .title(ResourceUtil.getStringByResource($r('app.string.voicemail')))
    .padding({
      top: this.isPC ?  0:px2vp(this.fullScreenPadding.top as number) ,
      bottom: px2vp(this.fullScreenPadding.bottom as number),
    })
    .onBackPressed(() => {
      HiLog.i(TAG, 'On back pressed.')
      this.voicemailBackPressed();
      return true;
    })
    .backgroundColor($r('app.color.skin_comp_background_gray'))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private voicemailBackPressed(): void {
    let toVoicemailFromSetting = AppStorage.get('toVoicemailFromSetting') as boolean;
    HiLog.i(TAG, `voicemailBackPressed toVoicemail: ${toVoicemailFromSetting}`);
    if (toVoicemailFromSetting) {
      let router: Router = this.getUIContext().getRouter();
      router.back();
    } else {
      this.pathInfos?.pop();
    }
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.voicemail')) },
  //   };
  // }

  @Builder
  normalLayout(item: VoiceMailItem, index?: number) {
    Row() {
      Row() {
        Text(item.voiceMailItemName)
          .fontColor($r('app.color.skin_font_primary'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
      }
      .flexGrow(1)
      .flexShrink(1)
      .width(197)

      Row() {
        Text(StringUtil.isEmpty(item.voiceMailItemValue) ? item.placeholder : item.voiceMailItemValue)
          .fontColor($r('app.color.skin_font_secondary'))
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Regular)
          .margin({ right: $r('sys.float.padding_level2') })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(`calc(100% - 20vp)`)
          .textAlign(TextAlign.End)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_fourth')])
          .flexShrink(0)
      }
      .flexGrow(1)
      .flexShrink(0)
      .width(115)
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .constraintSize({ minHeight: '48vp' })
    .layoutWeight(1)

    if (this.voiceMails.length > 0 && (index) !== (this.voiceMails.length - 1)) {
      Divider()
        .strokeWidth('1px')
        .width('100%')
        .color($r('app.color.skin_ohos_id_color_list_separator'))
    }
  }

  @Builder
  seniorLayout(item: VoiceMailItem, index?: number) {
    Column() {
      Row() {
        Text(item.voiceMailItemName)
          .fontColor($r('app.color.skin_font_primary'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({ right: $r('app.float.id_card_image_s') })
      .margin({ bottom: $r('sys.float.padding_level1') })

      Row() {
        Text(StringUtil.isEmpty(item.voiceMailItemValue) ? item.placeholder : item.voiceMailItemValue)
          .fontColor($r('app.color.skin_font_secondary'))
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Regular)
          .margin({ right: $r('sys.float.padding_level2') })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(`calc(100% - 20vp)`)
          .textAlign(TextAlign.Start)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_fourth')])
          .flexShrink(0)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, 0, $r('app.float.id_card_margin_10'))
    })

    if (this.voiceMails.length > 0 && (index) !== (this.voiceMails.length - 1)) {
      Divider()
        .strokeWidth('1px')
        .width('100%')
        .color($r('app.color.skin_ohos_id_color_list_separator'))
    }
  }

  @Builder
  VoiceMailDialogBuilder() {
    Column() {
      Row() {
        Column() {
          TextInput({ text: this.inputValue })
            .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
            .fontColor($r('app.color.skin_font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .constraintSize({ minHeight: 24 })
            .padding($r('sys.float.padding_level0'))
            .borderRadius(0)
            .backgroundColor(Color.Transparent)
            .type(InputType.PhoneNumber)
            .fontWeight(FontWeight.Regular)
            .inputFilter('^[0-9*#+,;()./-]*$', (value) => {
              if (!StringUtil.isEmpty(value)) {
                const filterResult = value.replace(new RegExp('[^0-9*#+,;()./-]', 'g'), '');
                if (!StringUtil.isEmpty(filterResult)) {
                  this.inputValue = this.inputValue + filterResult;
                }
              }
            })
            .onChange((value: string) => {
              HiLog.w(TAG, ' onChange value');
              this.inputValue = value;
            })
        }
        .flexShrink(1)

        Column() {
          Button() {
            SymbolGlyph($r('sys.symbol.person'))
              .fontSize($r('app.float.id_card_image_small'))
              .fontColor([$r('app.color.skin_icon_secondary')])
              .flexShrink(0)
          }
          .onClick(() => {
            // 联系人打点--语音信箱号码弹窗点击选择联系人按钮
            DotUtil.getInstance().contactDot(this.customizedParams, VOICEMAIL_TO_CONTACT_EVENT);
            contact.selectContacts({
              isMultiSelect: false
            }, (err: BusinessError, data) => {
              this.speedDialPresenter.parseContactForResult(data, ContactsConstants.VOICE_MAIL).then(() => {
              })
            })
            this.voiceMailDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          })
          .backgroundColor(Color.Transparent)
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.select_contact')))
        }
      }
      .height(48)
      .width('100%')

      Divider()
        .height('1px')
        .width('100%')
        .backgroundColor($r('app.color.skin_icon_primary'))
        .opacity($r('sys.float.alpha_secondary'))
    }
    .width('100%')
  }
}