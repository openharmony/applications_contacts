/**
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

import { HiLog, sharedPreferencesUtils } from '../../../../../../common';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { DataItemType } from '../../../../../../feature/contact';
import MockResource from '../../model/bean/MockResource';
import { CustomizedParams, SetPrimaryParam } from '../../model/type';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import router from '@ohos.router';
import DotUtil from '../../util/DotUtil';
import { FontScaleState } from '../../util/fontScaleState';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { display, LengthMetrics } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import { i18n } from '@kit.LocalizationKit';

const TAG = 'SelectMultiNumDialog';
const FAVORITE_NUMBER_GUIDE_EVENT = 'FAVORITE_NUMBER_GUIDE_EVENT';

@Component
export struct SelectMultiNumDialog {
  @Link builder: SelectNumDialogBuilder;
  @Link favoriteGuideParams: CustomizedParams;
  private controller?: CustomDialogController;
  private selectDefault: Boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;

  aboutToAppear() {
    HiLog.i(TAG, '[aboutToAppear] SelectMultiNumDialog');
    sharedPreferencesUtils.init(getContext(this));
    this.favoriteGuideParams = {
      ISCLICK: 0,
      ISDEFAULT: 0,
      ISCANCEL: 0
    };
  }

  build() {
    Scroll() {
      Column() {
        List() {
          ForEach(this.builder.multiNumCardItems, (item: MultiNumCardItems, index) => {
            ListItem() {
              Row() {
                Column() {
                  SymbolGlyph(item.img)
                    .fontSize('24vp')
                    .fontColor([$r('app.color.skin_icon_secondary')])
                }
                .padding({ right: $r('sys.float.padding_level8') })

                Column() {
                  Row() {
                    Text(item.number)
                      .fontSize($r('sys.float.Body_L'))
                      .fontColor($r('app.color.skin_font_primary'))
                      .fontWeight(FontWeight.Medium)
                      .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 1 : 5)
                      .width('100%')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .padding({
                        right: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level8') : 0
                      })
                  }
                  .margin({
                    top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.id_card_margin_10')),
                  })

                  Row() {
                    Text(item.numType)
                      .fontColor($r('app.color.skin_font_secondary'))
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Regular)
                      .width('100%')
                      .padding({
                        right: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level8') : 0
                      })
                  }
                  .margin({
                    top: $r('sys.float.padding_level1'),
                    bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                      0, $r('app.float.id_card_margin_10')),
                  })
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)
                .flexShrink(1)
              }
              .width('100%')
              .constraintSize({ minHeight: '64vp' })
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)
            }
            .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
            .onClick(() => {
              // 联系人打点--收藏页面多号码联系人弹窗引导是否点击号码
              this.favoriteGuideParams.ISCLICK = 1;
              DotUtil.getInstance().contactDot(this.favoriteGuideParams, FAVORITE_NUMBER_GUIDE_EVENT);
              this.confirm(item, this.builder.contactId);
            })
          })
        }
        .divider({
          strokeWidth: 0.5,
          startMargin: '40vp',
          endMargin: $r('sys.float.padding_level12'),
          color: $r('app.color.skin_comp_divider')
        })
        .layoutWeight(FontScaleState.isStandardGeer(this.fontSizeScale) ? 0 : 1)

        Row() {
          Column() {
            Checkbox({ name: 'checkbox2', group: 'checkboxGroup' })
              .height('24vp')
              .width('24vp')
              .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') : undefined)
              .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
              .margin($r('sys.float.padding_level0'))
              .padding($r('sys.float.padding_level1'))
              .select(false)
              .selectedColor($r('app.color.skin_comp_background_emphasize'))
              .onChange((value: boolean) => {
                // 联系人打点--收藏页面多号码弹窗引导是否勾选默认值
                if (value) {
                  this.favoriteGuideParams.ISDEFAULT = 1;
                } else {
                  this.favoriteGuideParams.ISDEFAULT = 0;
                }
                this.selectDefault = value
              })
          }
          .padding({ right: $r('sys.float.padding_level6') })

          Column() {
            Text($r('app.string.set_card_select_contact'))
              .constraintSize({ minHeight: 19 })
              .fontColor($r('app.color.skin_font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .padding({
                right: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level8') : 0
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .flexShrink(1)
        }
        .width('100%')
        .constraintSize({ minHeight: '48vp' })
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .visibility(this.builder.isRoaming ?? false ? Visibility.None : Visibility.Visible)
      }
    }
  }

  confirm(item: MultiNumCardItems, contactId: string) {
    this.controller?.close()
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    if (this.selectDefault) {
      const setPrimaryParam: SetPrimaryParam = {
        contactId: contactId,
        dataType: DataItemType.PHONE,
        dataId: item.dataId,
        primary: true
      }
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('setPrimary', setPrimaryParam)
    }
    if (this.builder.callback) {
      this.builder.callback(item);
    } else {
      router.back();
    }
  }
}

export class MultiNumCardItems {
  public number: string = '';
  public numType: Resource = new MockResource();
  public img: Resource = new MockResource();
  public dataId?: number = -1;
}

export class SelectNumDialogBuilder {
  public title: string | Resource = '';
  public contactId: string = '';
  public multiNumCardItems: Array<MultiNumCardItems> = [];
  public callback?: (item: MultiNumCardItems) => void;
  public isRoaming?: boolean;
}
