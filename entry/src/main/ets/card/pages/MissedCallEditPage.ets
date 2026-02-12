/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import formBindingData from '@ohos.app.form.formBindingData';
import { sharedPreferencesUtils } from '../../../../../../feature/call/oh_modules/common';
import { HiLog } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
import missedCallEditCommon from '../common/MissedCallEditCommon';
import { missedCallRadioData } from '../data/commonData';
import { RadioDataType, UpdateToCardType } from '../type/missedCall';
import { SubHeader } from '@kit.ArkUI';
import { LengthMetrics } from '@ohos.arkui.node';
import { TextModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import IndexPresenter from '../../presenter/IndexPresenter';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';

const TAG = 'MissedCallEditPage';
let storage = LocalStorage.getShared();

@Entry(storage)
@Component
export struct MissedCallEditPage {
  @LocalStorageLink('missedCallData') @Watch('radioValueChange') missedCallData: string = '';
  radioList: RadioDataType[] = missedCallRadioData;
  @Provide('pathInfo') pathInfo: NavPathStack = new NavPathStack();
  @LocalStorageLink('formId') formId: string = '';
  @State common: missedCallEditCommon = new missedCallEditCommon();
  // v小折叠外屏需要限制
  private maxFontScale: number = 2;
  private context: Context = getContext(this);
  private uiExtensionSession?: UIExtensionContentSession = ContactsGlobalThisHelper.GetGlobalThis()
    .getUIExtensionContentSession();
  @StorageProp('isVerde') isVde: boolean = false;

  aboutToAppear() {
    this.formId = AppStorage.get('cardFormId') as string
    sharedPreferencesUtils.init(this.context);
    HiLog.w(TAG + '[formId]', this.formId);
  }

  radioValueChange() {
    sharedPreferencesUtils.saveToPreferences('card_missed_call_provision_' +
    this.formId, JSON.stringify(this.missedCallData));
    let obj: UpdateToCardType = {
      title: 'update',
      formId: this.formId,
      settings: this.missedCallData
    };
    this.common.updateToCard(this.formId.toString(), formBindingData.createFormBindingData(obj));
  }

  build() {
    Column() {
      GridRow({ columns: { xs: 4, sm: 4, md: 8, lg: 12 }, gutter: { x: { xs: 0, sm: 0, md: 12, lg: 16 }, y: 0 } }) {
        GridCol({ span: { xs: 0, sm: 0, md: 1, lg: 2 } })
        GridCol({ span: { xs: 4, sm: 4, md: 6, lg: 8 } }) {
          Column() {
            // subheader深色模式
            SubHeader({
              secondaryTitle: $r('app.string.card_missedCall_msg'),
              contentMargin: { start: LengthMetrics.vp(0), end: LengthMetrics.vp(0) },
              secondaryTitleModifier: IndexPresenter.isThemeActiveCard ?
              new TextModifier().fontColor($r('app.color.skin_font_secondary')).maxFontScale(this.maxFontScale) :
              new TextModifier().maxFontScale(this.maxFontScale)
            })
            List() {
              ForEach(this.radioList, (item: RadioDataType, index: number) => {
                ListItem() {
                  Column() {
                    Flex({
                      direction: FlexDirection.Row,
                      wrap: FlexWrap.NoWrap,
                      justifyContent: FlexAlign.SpaceBetween,
                      alignItems: ItemAlign.Center
                    }) {
                      Text(item.title)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('app.color.skin_font_primary'))
                        .fontSize($r('sys.float.Subtitle_M'))
                        .maxFontScale(this.maxFontScale)

                      WithTheme(IndexPresenter.isThemeActiveCard ? { theme: defaultCustomTheme } : undefined) {
                        Toggle({
                          type: ToggleType.Checkbox,
                          isOn: item.value === this.missedCallData ? true : false
                        })
                          .size({ width: 20, height: 20 })
                          .margin($r('sys.float.padding_level1'))
                          .flexShrink(0)
                          .enabled(true)
                          .hitTestBehavior(HitTestMode.None)
                          .selectedColor($r('app.color.skin_comp_background_emphasize'))
                          .visibility(item.value === this.missedCallData ? Visibility.Visible : Visibility.None)
                      }
                    }
                    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
                    .onClick(() => {
                      this.missedCallData = item.value
                      HiLog.w(TAG, '[missedCallData]')
                    })
                    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })

                    Divider()
                      .height('1px')
                      .width('100%')
                      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
                      .color($r('app.color.skin_ohos_id_color_list_separator'))
                      .visibility(index === this.radioList.length - 1 ? Visibility.None : Visibility.Visible)
                  }
                }
                .backgroundColor(Color.Transparent)
                .width('100%')
              })
            }
            .borderRadius($r('sys.float.corner_radius_level10'))
            .backgroundColor($r('sys.color.comp_background_list_card'))
          }
        }

        GridCol({ span: { sm: 0, md: 1, lg: 2 } })
      }
    }
    .onAppear(this.isVde ? () => {
      let resultData: Record<string, Object> = {
        'uecHeight': 202,
      };
      HiLog.i(TAG, `MissedCallEditPage onAppear, uecHeight: ${resultData.uecHeight}`);
      this.uiExtensionSession?.sendData(resultData);
    } : undefined)
  }
}

