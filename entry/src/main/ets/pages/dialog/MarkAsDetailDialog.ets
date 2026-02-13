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
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import NumberMarkUtil from '../../util/NumberMarkUtil';
import { HiLog, NumberAddressUtil } from '../../../../../../common'
import call from '@ohos.telephony.call';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import CallRecordPresenter from '../../presenter/dialer/callRecord/CallRecordPresenter';
import CustomTextInputContent from './CustomTextInputContent';
import { FontScaleState } from '../../util/fontScaleState';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import DotUtil from '../../util/DotUtil';
import dotCommon, { customParams, markTypeParams } from '../../util/DotCommon';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';

const TAG = 'MarkAsDetailDialog';
const harassmentItemArr: string[] = [NumberMarkUtil.PRE_CRANK_PHONE_DESC, NumberMarkUtil.PRE_FRAUD_PHONE_DESC];
const markAsItemArr: string[] = [NumberMarkUtil.PRE_EXPRESS_PHONE_DESC, NumberMarkUtil.PRE_PROMOTE_SALES_PHONE_DESC,
  NumberMarkUtil.PRE_HOUSE_AGENT_PHONE_DESC, NumberMarkUtil.PRE_INSURANCE_PHONE_DESC,
  NumberMarkUtil.PRE_TAXI_PHONE_DESC, NumberMarkUtil.PRE_CUSTOM_PHONE_DESC];

/**
 * The Mark As Dialog When Click CallLog.
 */
@Component
export default struct MarkAsDetailDialog {
  @Link isInBlock: boolean;
  phoneNumber: string = '';
  @Link isMarked: boolean;
  @Link markType: string;
  @Link markCustom: string;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  markAsDialogController: CustomDialogController = new CustomDialogController({ builder: '' });
  private maxFontScale: number = 2;

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  build() {
    Column() {
      List() {
        ListItemGroup() {
          if (this.isMarked || (this.markType == NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC)){
            ListItem() {
              Column() {
                Row() {
                  Text((this.markType == NumberMarkUtil.IDENTIFY_PAGE_PHONE_DESC) ? $r('app.string.number_smart_mark_remove') :
                  $r('app.string.number_mark_remove'))
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .maxFontScale(this.maxFontScale)
                    .fontWeight(FontWeight.Medium)
                    .constraintSize({minHeight: '32vp'})
                    .width('100%')
                    .fontColor($r('app.color.skin_font_primary'))
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                    .textAlign(TextAlign.Start);
                }
                .constraintSize({minHeight: '32vp'})
                .padding({
                  left: '12vp',
                  right: '12vp',
                  top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, '8vp', '8vp'),
                  bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, '8vp', '8vp')
                })
                .stateStyles({
                  pressed: this.pressedStyles,
                  normal: this.normalStyles
                })
                .onClick(() => {
                  HiLog.i(TAG, 'number_mark_remove: ' + MarkType.none);
                  try {
                    NumberAddressUtil.setNumberMarkInfo(ContactsGlobalThisHelper.GetGlobalThis()
                      .getDefaultUIContext() as Context,
                      this.phoneNumber, call.MarkType.MARK_TYPE_NONE);
                    CallRecordPresenter.getInstance().cancelBlockList([this.phoneNumber as string],
                      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                        HiLog.i(TAG, 'cancelBlockList result:' + result);
                      });
                    this.isInBlock = false;
                    this.isMarked = false;
                    this.markType = NumberMarkUtil.PRE_NONE_PHONE_DESC;
                    this.markAsDialogController?.close();
                    DialogControllerManager.getInstance().dialogControllerSet.clear();
                  } catch (e) {
                    HiLog.w(TAG, 'number mark remove error!');
                  }

                })
              }
            }
          }
          ForEach(harassmentItemArr, (item: string, index: number) => {
            ListItem() {
              HarassmentItem({
                phoneNumber: this.phoneNumber,
                item: item,
                isInBlock: this.isInBlock,
                isMarked: this.isMarked,
                markType: this.markType,
                itemType: index + 1,
                controller: this.markAsDialogController as CustomDialogController
              })
            }
          }, (item: string, index: number) => JSON.stringify(item) + index)
          ForEach(markAsItemArr, (item: string, index: number) => {
            ListItem() {
              MarkAsItem({
                phoneNumber: this.phoneNumber,
                item: item,
                index: index,
                isInBlock: this.isInBlock,
                isMarked: this.isMarked,
                markType: this.markType,
                markCustom: this.markCustom,
                itemType: index + 3,
                controller: this.markAsDialogController as CustomDialogController
              })
            }
          }, (item: string, index: number) => JSON.stringify(item) + index)
        }
        .divider({
          strokeWidth: '1px',
          startMargin: $r('app.float.id_card_margin_xl'),
          endMargin: $r('app.float.id_card_margin_xl'),
          color: $r('app.color.skin_ohos_id_color_list_separator')
        })
      }
      .width('100%')
      .flexShrink(1)
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}

// Selectable Marker Types
export enum MarkType {
  none, crank, fraud, express, promote_sales, house_agent, insurance, taxi, customize, others
}

@Component
struct HarassmentItem {
  phoneNumber: string = '';
  @State item: string = '';
  @Link markType: string;
  @State itemType: number = 0;
  @Link isInBlock: boolean;
  @Link isMarked: boolean;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  controller: CustomDialogController = new CustomDialogController({ builder: '' });
  private maxFontScale: number = 2;

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  build() {
    Column() {
      Row() {
        Text(NumberMarkUtil.getNumberMarkInfo(this.item))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .maxFontScale(this.maxFontScale)
          .fontWeight(FontWeight.Medium)
          .fontColor((this.isMarked && this.item === this.markType) ?
            $r('app.color.skin_ohos_id_color_text_primary_activated') : $r('app.color.skin_font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .flexShrink(1)
          .constraintSize({ minHeight: '22vp' })
          .textAlign(TextAlign.Start);
      }
      .margin({ top: '10vp' })
      .constraintSize({ minHeight: '22vp' })

      Row() {
        Text($r('app.string.number_mark_add_to_blocklist_and_block'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .maxFontScale(this.maxFontScale)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_font_secondary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 1 : 2)
          .flexShrink(1)
          .constraintSize({ minHeight: '19vp' })
      }
      .margin({ bottom: '11vp', top: '2vp' })
      .constraintSize({ minHeight: '19vp' })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: '12vp', right: '12vp' })
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .onClick(() => {
      try {
        switch (this.itemType) {
          case MarkType.crank:
            // 骚扰电话
            markTypeParams.MARKTYPE = dotCommon.eventParam.MARK_TYPE_CRANK;
            //  联系人打点-号码标记类型-骚扰电话
            DotUtil.getInstance().contactDot(markTypeParams, dotCommon.eventName.NUMBER_TAG_TYPE_EVENT);
            NumberAddressUtil.setNumberMarkInfo(
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
              this.phoneNumber, call.MarkType.MARK_TYPE_CRANK);
            CallRecordPresenter.getInstance().addToBlockList([this.phoneNumber], '', (result: boolean) => {
              HiLog.i(TAG, 'numberMarkInfo addToBlockList result:' + result);
            });
            this.isMarked = true;
            this.markType = NumberMarkUtil.PRE_CRANK_PHONE_DESC;
            this.isInBlock = true;
            this.controller?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            break;
          case MarkType.fraud:
            // 诈骗电话
            markTypeParams.MARKTYPE = dotCommon.eventParam.MARK_TYPE_FRAUD;
            //  联系人打点-号码标记类型-诈骗电话
            DotUtil.getInstance().contactDot(markTypeParams, dotCommon.eventName.NUMBER_TAG_TYPE_EVENT);
            NumberAddressUtil.setNumberMarkInfo(
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
              this.phoneNumber, call.MarkType.MARK_TYPE_FRAUD);
            CallRecordPresenter.getInstance().addToBlockList([this.phoneNumber], '', (result: boolean) => {
              HiLog.i(TAG, 'numberMarkInfo addToBlockList result:' + result);
            });
            this.isMarked = true;
            this.markType = NumberMarkUtil.PRE_FRAUD_PHONE_DESC;
            this.isInBlock = true;
            this.controller?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            break;
          default:
            HiLog.e(TAG, 'menuView click error itemType : ')
        }
        // 联系人打点-成功标记陌生号码
        DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.MARK_UNKNOWN_NUM_EVENT);
      } catch (error) {
        HiLog.e(TAG, `onClick event failed:${error?.message}`);
      }
    })
  }
}

@Component
struct MarkAsItem {
  phoneNumber: string = '';
  @Link isInBlock: boolean;
  @State item: string = '';
  @State index: number = 0;
  @Link markType: string;
  @Link markCustom: string;
  @Link isMarked: boolean;
  @State itemType: number = 0;
  @State customContent: string = '';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  controller: CustomDialogController = new CustomDialogController({ builder: '' });
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  private maxFontScale: number = 2;

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  markDot(markType: number) {
    markTypeParams.MARKTYPE = markType;
    // 联系人打点-号码标记类型
    DotUtil.getInstance().contactDot(markTypeParams, dotCommon.eventName.NUMBER_TAG_TYPE_EVENT);
    // 联系人打点-成功标记陌生号码
    DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.MARK_UNKNOWN_NUM_EVENT);
  }

  build() {
    Column() {
      Row() {
        Text(NumberMarkUtil.getNumberMarkInfo(this.item))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontWeight(FontWeight.Medium)
          .constraintSize({ minHeight: '32vp' })
          .maxFontScale(this.maxFontScale)
          .width('100%')
          .fontColor((this.isMarked && this.item === this.markType) ?
          $r('app.color.skin_ohos_id_color_text_primary_activated') : $r('app.color.skin_font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .textAlign(TextAlign.Start);
      }
      .constraintSize({ minHeight: '32vp' })
      .padding({
        left: '12vp',
        right: '12vp',
        top: '8vp',
        bottom: '8vp'
      })
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
      .onClick(() => {
        switch (this.itemType) {
          case MarkType.promote_sales:
          // 广告推销
          // 联系人打点-号码标记类型-广告推销
            this.markDot(dotCommon.eventParam.MARK_TYPE_PROMOTE_SALES);
            NumberAddressUtil.setNumberMarkInfo(
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
              this.phoneNumber, call.MarkType.MARK_TYPE_PROMOTE_SALES);
            CallRecordPresenter.getInstance().cancelBlockList([this.phoneNumber as string],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                HiLog.i(TAG, 'cancelBlockList result:' + result);
              });
            this.markType = NumberMarkUtil.PRE_PROMOTE_SALES_PHONE_DESC;
            this.isInBlock = false;
            this.isMarked = true;
            this.controller?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            break;
          case MarkType.house_agent:
          // 房产中介
          // 联系人打点-号码标记类型-房产中介
            this.markDot(dotCommon.eventParam.MARK_TYPE_HOUSE_AGENT);
            NumberAddressUtil.setNumberMarkInfo(
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
              this.phoneNumber, call.MarkType.MARK_TYPE_HOUSE_AGENT);
            CallRecordPresenter.getInstance().cancelBlockList([this.phoneNumber as string],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                HiLog.i(TAG, 'cancelBlockList result:' + result);
              });
            this.markType = NumberMarkUtil.PRE_HOUSE_AGENT_PHONE_DESC;
            this.isInBlock = false;
            this.isMarked = true;
            this.controller?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            break;
          case MarkType.express:
          // 快递送餐
          // 联系人打点-号码标记类型-快递送餐
            this.markDot(dotCommon.eventParam.MARK_TYPE_EXPRESS);
            NumberAddressUtil.setNumberMarkInfo(
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
              this.phoneNumber, call.MarkType.MARK_TYPE_EXPRESS);
            CallRecordPresenter.getInstance().cancelBlockList([this.phoneNumber as string],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                HiLog.i(TAG, 'cancelBlockList result:' + result);
              });
            this.markType = NumberMarkUtil.PRE_EXPRESS_PHONE_DESC;
            this.isInBlock = false;
            this.isMarked = true;
            this.controller?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            break;
          case MarkType.insurance:
          // 保险理财
          // 联系人打点-号码标记类型-保险理财
            this.markDot(dotCommon.eventParam.MARK_TYPE_INSURANCE);
            NumberAddressUtil.setNumberMarkInfo(
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
              this.phoneNumber, call.MarkType.MARK_TYPE_INSURANCE);
            CallRecordPresenter.getInstance().cancelBlockList([this.phoneNumber as string],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                HiLog.i(TAG, 'cancelBlockList result:' + result);
              });
            this.markType = NumberMarkUtil.PRE_INSURANCE_PHONE_DESC;
            this.isInBlock = false;
            this.isMarked = true;
            this.controller?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            break;
          case MarkType.taxi:
          // 出租车
          // 联系人打点-号码标记类型-出租车
            this.markDot(dotCommon.eventParam.MARK_TYPE_TAXI);
            NumberAddressUtil.setNumberMarkInfo(
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
              this.phoneNumber, call.MarkType.MARK_TYPE_TAXI);
            CallRecordPresenter.getInstance().cancelBlockList([this.phoneNumber as string],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                HiLog.i(TAG, 'cancelBlockList result:' + result);
              });
            this.markType = NumberMarkUtil.PRE_TAXI_PHONE_DESC;
            this.isInBlock = false;
            this.isMarked = true;
            this.controller?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            break;
          case MarkType.customize:
          // 自定义
            markTypeParams.MARKTYPE = dotCommon.eventParam.MARK_TYPE_CUSTOMIZE;
            //  联系人打点-号码标记类型-自定义
            DotUtil.getInstance().contactDot(markTypeParams, dotCommon.eventName.NUMBER_TAG_TYPE_EVENT);
            this.controller?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            this.markAsCustomizeDialogController?.open();
            DialogControllerManager.getInstance().addDialogController(this.markAsCustomizeDialogController);
            break;
          default:
            HiLog.w(TAG, 'menuView click error itemType : ')
        }
      })
    }
  }

  markAsCustomizeDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.number_mark_customize'),
      contentBuilder: () => {
        this.markAsCustomizeDialog();
      },
      contentAreaPadding: ({left: '0vp', right: '0vp'}),
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    alignment: DialogAlignment.Center,
    closeAnimation: { duration: 100 },
  });

  @Builder
  markAsCustomizeDialog() {
    Column() {
      CustomTextInputContent({
        inputValue: '',
        isFromPhoneNumberMarkAs: true,
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.confirm'),
        onCancel: () => {
          this.markAsCustomizeDialogController?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        onConfirm: (value: string) => {
          this.customContent = value;
          if (this.customContent != '') {
            NumberAddressUtil.setNumberMarkInfo(
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
              this.phoneNumber, call.MarkType.MARK_TYPE_CUSTOM, this.customContent);
            CallRecordPresenter.getInstance().cancelBlockList([this.phoneNumber as string],
              ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), (result: boolean) => {
                HiLog.i(TAG, 'cancelBlockList result:' + result);
              });
            this.markType = NumberMarkUtil.PRE_CUSTOM_PHONE_DESC;
            this.markCustom = this.customContent;
            this.isInBlock = false;
            this.isMarked = true;
          }
          // 联系人打点-成功标记陌生号码
          DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.MARK_UNKNOWN_NUM_EVENT);
          this.markAsCustomizeDialogController?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      })
    }
    .width('100%')
  }
}