
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
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import LooseObject from '../../../model/type/LooseObject';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import { PhoneNumber } from '../../../../../../../feature/phonenumber';
import MergedCallLog from '../../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { CallLog } from '../../../../../../../feature/call';
import CallLogBuilder from '../../../../../../../feature/call/src/main/ets/entity/CallLogBuilder';
import { CustomContentDialog, AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { CustomizedParams } from '../../../model/type';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { SmsManager } from '../../../interception/sms/SmsManager';
import DotUtil from '../../../util/DotUtil';
import { call } from '@kit.TelephonyKit';
import { common } from '@kit.AbilityKit';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { FontScaleState } from '../../../util/fontScaleState';
import BlockListContact from '../../../../../../../feature/contact/src/main/ets/entity/BlockListContact'
import { IsBlockContact } from '../../../../../../../feature/contact/src/main/ets/entity/BlockListContact';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { LengthMetrics } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import StringFormatUtil from '../../../util/StringFormatUtil';

const TAG = 'InterceptionCallsRecord';
const CONTACT_BLOCK_CLICK_CALL_NUMBER = 'CLICK_CALL_NUMBER';
const CONTACT_BLOCK_CLICK_CALL_NUM_PAGE = 'CLICK_CALL_NUM_PAGE';
const CONTACT_BLOCK_CALL_ADD_TRUST_CONFIRM = 'CALL_ADD_TRUST_CONFIRM';
const CONTACT_BLOCK_CALL_DELETE_CONFIRM = 'CALL_DELETE_CONFIRM';
let storage = LocalStorage.GetShared();

@Component
export default struct InterceptionCallsRecord {
  @State message: string = 'UIExtensionAbility'
  @State mPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  @State totalCount: number = 0;

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear!');
    this.mPresenter.registerInterceptionCallsDataChangeObserver();
    this.mPresenter.bindUI(()=>{
      this.mPresenter = CallRecordPresenter.getInstance();
    })
    HiLog.i(TAG, 'interception calls requestItem ');
    CallRecordPresenter.getInstance().requestInterceptionCallsItem();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear!');
    this.mPresenter.unRegisterInterceptionCallsDataChangeObserver();
  }

  build() {
    Column() {
      InterceptionCalls({ mPresenter: $mPresenter })
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .height('100%')
  }
}

@Component
struct InterceptionCalls {
  @Link @Watch('onChanged') mPresenter: CallRecordPresenter;
  totalCount: number = -1;
  @State callLogListEmpty: boolean = true;
  @StorageLink('interceptionCallRecordChange') @Watch('onChanged') interceptionCallRecordChange: number = 0;

  onChanged() {
    HiLog.i(TAG, 'onChanged, callLogListEmpty: ' + this.callLogListEmpty + ' ' + this.interceptionCallRecordChange);
    if (this.mPresenter.interceptionCallRecordInit) {
      let callLogIsEmpty = this.mPresenter.mInterceptionCallRecordListDataSource.totalCount() <= 0;
      this.totalCount = this.mPresenter.mInterceptionCallRecordListDataSource.totalCount();
      if (this.callLogListEmpty != callLogIsEmpty) {
        this.callLogListEmpty = callLogIsEmpty
      }
      HiLog.i(TAG, 'InterceptionCalls onChanged totalCount: ' + this.totalCount +
        ' callLogListEmpty: ' + this.callLogListEmpty);
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'InterceptionCalls aboutToAppear')
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'InterceptionCalls aboutToDisappear')
  }

  build() {
    Stack() {
      if (!this.mPresenter.interceptionCallRecordInit) {

      } else if (this.callLogListEmpty) {
        EmptyView()
      } else {
        InterceptionCallView({ mPresenter: $mPresenter })
      }
    }
  }
}

@Component
struct EmptyView {
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  build() {
    Column() {
      // PafEmptyPage({
      //   icon: $r('app.media.ic_empty_page_no_call_records'),
      //   emptyDescription: $r('app.string.no_blocked_calls'),
      //   customBackgroundColor: $r('sys.color.background_secondary'),
      //   fullPage: true,
      // })
    }
    .padding({ bottom: $r('app.float.id_height_84') })
    .height('100%')
    .width('100%')
  }
}

@Component
struct InterceptionCallView {
  @Link private mPresenter: CallRecordPresenter;

  build() {
    List({ space: 0, initialIndex: 0 }) {
      LazyForEach(this.mPresenter.mInterceptionCallRecordListDataSource, (item: LooseObject, index: number) => {
        ListItem() {
          InterceptionCallItem({ mPresenter: $mPresenter,
            item: item.callLogData,
            index: index,
            showIndex: item.showIndex,
            showDivider: item.showDivider })
        }
      }, (item: LooseObject, index: number) => JSON.stringify(item) + index)
      ListItem() {
      }
      .height('84vp')
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .flexShrink(1)
    .listDirection(Axis.Vertical)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({bottom: $r('sys.float.padding_level8') })
  }
}

@Component
struct InterceptionCallItem {
  @Link mPresenter: CallRecordPresenter
  @State item: MergedCallLog = new MergedCallLog(new CallLog(new CallLogBuilder(-1, '')));
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @State private index: number = 0;
  @State formatNumber: string = '';
  @State title: string = '';
  @State showIndex: boolean = false;
  @State showDivider: boolean = false;
  @State isInWhiteList: boolean = false;
  @State private checkState: boolean = false;
  @State isInBlockList: boolean = false;
  @State inBlockListPhonenumber: string = '';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  contactBlockedCallParams: CustomizedParams = {
  };

  contactBlockedCallDialogCallParams: CustomizedParams = {
    OPTION: 1,
  };

  contactBlockedCallDialogAddIntoWhitelistParams: CustomizedParams = {
    OPTION: 2,
  };

  contactBlockedCallDialogDeleteParams: CustomizedParams = {
    OPTION: 3,
  };

  contactBlockedCallDialogCancelParams: CustomizedParams = {
    OPTION: 4,
  };

  addIntoWhitelistCancelParams: CustomizedParams = {
    CONFIRM: 1,
  };

  addIntoWhitelistConfirmParams: CustomizedParams = {
    CONFIRM: 0,
  };

  addIntoWhitelistRestoreParams: CustomizedParams = {
    RECOVER: 0,
  };

  addIntoWhitelistUnRestoreParams: CustomizedParams = {
    RECOVER: 1,
  };

  deleteInterceptionCallCancelParams: CustomizedParams = {
    CONFIRM: 1,
  };

  deleteInterceptionCallConfirmParams: CustomizedParams = {
    CONFIRM: 0,
  };

  // AddIntoWhitelist Dialog
  checkDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.harassmentDialogTitleAddIntoWhitelist'),
      contentBuilder: () => {
        this.buildCustomDialogContent();
      },
      buttons: [
        {
          value: $r('app.string.harassment_restore_sms_record_move_in'),
          action: () => {
            // 恢复短信数据打点
            DotUtil.getInstance().blockedDot(this.addIntoWhitelistRestoreParams,
              CONTACT_BLOCK_CALL_ADD_TRUST_CONFIRM);
            this.mPresenter.updateToWhiteList(this.inBlockListPhonenumber as string, (res: boolean)=> {
              HiLog.i('TAG', 'AddWhiteListDialog addToAllowList: ' + res);
            });
            //恢复短信数据
            let phoneNumbers: string[] = [this.item.phoneNumber];
            let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
            let smsManager: SmsManager = new SmsManager();
            smsManager.restoreBlockedMessage(context, phoneNumbers);
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        },
        {
          value: $r('app.string.harassment_only_move_in'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.i(TAG, 'interceptionCallDialogController !!!');
            // 不恢复短信数据打点
            DotUtil.getInstance().blockedDot(this.addIntoWhitelistUnRestoreParams,
              CONTACT_BLOCK_CALL_ADD_TRUST_CONFIRM);
            // 点击添加到白名单dialog取消
            DotUtil.getInstance().blockedDot(this.addIntoWhitelistCancelParams, CONTACT_BLOCK_CALL_ADD_TRUST_CONFIRM);
            this.mPresenter.updateToWhiteList(this.inBlockListPhonenumber as string, (res: boolean)=> {
              HiLog.i('TAG', 'AddWhiteListDialog addToAllowList: ' + res);
            });
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        },
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            HiLog.i(TAG, 'interceptionCallDialogController !!!');
            // 点击通话防护dialog Cancel打点
            DotUtil.getInstance().blockedDot(this.contactBlockedCallDialogCancelParams,
              CONTACT_BLOCK_CLICK_CALL_NUM_PAGE);
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      ],
      contentAreaPadding: {
        left: 0,
        right: 0
      }
    }),
    onWillDismiss: () => {
      this.checkDialog.close();
      DialogControllerManager.getInstance().dialogControllerSet.clear();
    },
    showInSubWindow: true,
    autoCancel: false,
    alignment: DialogAlignment.Center,
    cornerRadius: $r('sys.float.corner_radius_level16'),
    backgroundColor: $r('app.color.skin_mask_fourth'),
  });

  clearInterceptionCallDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.harassmentInterceptionCallDeleteOrNot_new'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          // 点击清楚拦截记录dialog取消
          DotUtil.getInstance().blockedDot(this.deleteInterceptionCallCancelParams,
            CONTACT_BLOCK_CALL_DELETE_CONFIRM);
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          HiLog.i(TAG, 'interceptionCallDialogController !!!')
        }
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        action: () => {
          // 点击清楚拦截记录dialog确定
          DotUtil.getInstance().blockedDot(this.deleteInterceptionCallConfirmParams,
            CONTACT_BLOCK_CALL_DELETE_CONFIRM);
          HiLog.i(TAG, 'interceptionCallDialogController !!!');
          let ids: number[] = [this.item.id];
          HiLog.i(TAG, 'deleteInterceptionCallLog: this.index ' + this.index);
          this.mPresenter.deleteInterceptionCallLog(ids, this.index);
          HiLog.i(TAG, 'interceptionCallDialogController !!!');
          // 查询此号码是否在黑名单
          let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
          if (this.item.detectDetails) {
            // 查询此开头号码的拦截记录次数
            CallRecordPresenter.getInstance().getBlockedCallCountByDetectDetails(this.item.detectDetails as string,
              context, (blockListContact: BlockListContact | undefined) => {
                if (blockListContact != undefined) {
                  HiLog.i(TAG, 'sendBlockedCallNotify getBlockedCallCountByDetectDetails: ' +
                  blockListContact.interceptionCallCount);
                  CallRecordPresenter.getInstance().
                  updateBlockedCallCountByDetectDetails(context, blockListContact, false);
                }
              });
          } else {
            CallRecordPresenter.getInstance().isInBlockList(this.item.phoneNumber as string, (res: IsBlockContact)=> {
              HiLog.i(TAG, 'sendBlockedCallNotify isInBlockList: ' + res?.isInBlock);
              if (res?.isInBlock) {
                // 查询此号码的拦截记录次数
                CallRecordPresenter.getInstance().getBlockedCallCountByPhoneNumber(this.item.phoneNumber,
                  context, (blockListContact: BlockListContact | undefined)=> {
                    if (blockListContact != undefined) {
                      HiLog.i(TAG, 'sendBlockedCallNotify getBlockedCallCountByPhoneNumber: ' +
                      blockListContact.interceptionCallCount);
                      CallRecordPresenter.getInstance().
                      updateBlockedCallCountByPhoneNumber(context, blockListContact, false);
                    }
                  });
              }
            }, false);
          };
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        role: ButtonRole.ERROR
      }
    }),
    alignment: DialogAlignment.Center,
    showInSubWindow: true,
    autoCancel: true,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  aboutToAppear() {
    HiLog.i(TAG, 'ContactItem aboutToAppear');
    this.updateFormatNumber();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'ContactItem aboutToDisappear');
  }

  aboutToReuse(params: LooseObject) {
    HiLog.i(TAG, 'aboutToReuse');
    this.item = params.item;
    this.showIndex = params.showIndex;
    this.showDivider = params.showDivider;
    this.index = params.index;
    this.updateFormatNumber();
  }

  updateFormatNumber() {
    this.formatNumber = this.item.formattedNumber;
    PhoneNumber.fromString(this.item.phoneNumber as string).format().then((formatNumber: string) => {
      this.formatNumber = formatNumber;
    })
  }

  build() {
    Row() {
      Column() {
        if (this.showIndex as boolean) {
          Row() {
            Column() {
              // 长度大于1是具体日期内容
              if (this.item.createInterceptionTimeType.length > 1) {
                Text(this.item.createInterceptionTimeType)
                  .width('100%')
                  .constraintSize({ minHeight: '20vp' })
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.skin_font_secondary'))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .flexShrink(1)
              } else {
                // 需要转换为resource
                Text(this.item.createInterceptionTimeType === '0' ? $r('app.string.today') :
                  (this.item.createInterceptionTimeType === '1' ? $r('app.string.yesterday') :
                  $r('app.string.one_week_ago')))
                  .width('100%')
                  .constraintSize({ minHeight: '20vp' })
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.skin_font_secondary'))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .flexShrink(1)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(3)
            .padding({left: '12vp', right: '12vp', top: '28vp', bottom: '8vp'})
          }
          .width('100%')
          .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
        }

        if (FontScaleState.isStandardGeer(this.fontSizeScale)) {
          Row() {
            Column() {
              Row() {

              }
              .width('100%')
              .height('4vp')
              .visibility(this.showIndex ? Visibility.Visible : Visibility.None)

              Row() {
                Column() {
                  Row() {
                    Text(this.item.phoneNumber)
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.skin_font_primary'))
                      .textAlign(TextAlign.Start)
                  }
                  .margin({ top: '8vp' })

                  Row() {
                    Text(this.mPresenter.getBlockReasonResource(this.item))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('app.color.skin_font_secondary'))
                      .textAlign(TextAlign.Start)
                  }
                  .margin({ bottom: '8vp', top: '2vp' })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(3)
                .margin({
                  start: LengthMetrics.resource($r('app.float.id_card_margin_large'))
                })

                Column() {
                  Row() {
                    if (this.haveMultiSimCard) {
                      SymbolGlyph(this.item.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
                        .fontSize('14vp')
                        .fontColor([$r('app.color.skin_icon_tertiary')])
                        .opacity($r('app.float.alpha_tertiary'))
                    }

                    Text(this.item.createTime)
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('app.color.skin_font_secondary'))
                      .textAlign(TextAlign.Start)
                      .accessibilityText(
                        StringFormatUtil.getAccessibilityTextByTime(this.item.createTimeSource) as string)
                      .padding({
                        start: LengthMetrics.vp(8)
                      })
                  }
                  .margin({ top: '8vp' })

                  Row() {
                    Text((StringUtil.isEmpty(this.item.numberLocation) || this.item.numberLocation === 'N') ?
                      '' : this.item.numberLocation)
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('app.color.skin_font_secondary'))
                      .textAlign(TextAlign.Start)
                  }
                  .margin({ bottom: '8vp', top: '2vp' })
                }
                .alignItems(HorizontalAlign.End)
                .layoutWeight(2)
                .margin({
                  end: LengthMetrics.resource($r('app.float.id_card_margin_large'))
                })
              }
              .constraintSize({ minHeight: 64 })
              .justifyContent(FlexAlign.Center)
              .margin({ left: '4vp', right: '4vp' })
              .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
              })

              Row() {

              }
              .width('100%')
              .height('4vp')
              .visibility(!this.showDivider ? Visibility.Visible : Visibility.None)
            }
          }
          .width('100%')
          .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
          .borderRadius({
            topLeft: this.showIndex ? 20 : 0,
            topRight: this.showIndex ? 20 : 0,
            bottomRight: this.showDivider ? 0 : 20,
            bottomLeft: this.showDivider ? 0 : 20
          })
          .bindContextMenu(this.MenuBuilder, ResponseType.LongPress, {
            preview: this.MenuPreview,
            previewAnimationOptions: { scale: [1, 1] },
            placement: Placement.BottomLeft,
            offset: {
              x: $r('sys.float.padding_level2'),
              y: $r('sys.float.padding_level4')
            },
            backgroundColor: $r('app.color.skin_ohos_id_blur_style_component_ultra_thick_color'),
            backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
            aboutToAppear: () => {
              // 点击通话防护每条记录打点
              DotUtil.getInstance().blockedDot(this.contactBlockedCallParams, CONTACT_BLOCK_CLICK_CALL_NUMBER);
              HiLog.i(TAG, 'interceptionCallDialogController this.index: ' + this.index);
              //查询号码是否在白名单中，若在则不显示 添加到白名单 选项
              this.mPresenter.isInBlockList(this.item.phoneNumber as string, (res: IsBlockContact)=> {
                HiLog.i(TAG, 'interceptionCallDialogController isInAllowList: ' + res?.isInBlock);
                this.isInWhiteList = res?.isInBlock;
                HiLog.i(TAG, 'interceptionCallDialogController open');
                let phoneNumber = this.item.phoneNumber;
                let numberLocation = (this.item.numberLocation && this.item.numberLocation !== 'N') ? ' ' + this.item.numberLocation : '';
                this.title = phoneNumber + numberLocation;
              }, true);
            }
          })
        } else {
          this.seniorContentLayout()
        }

        if (this.showDivider) {
          Row() {
            Divider()
              .color($r('app.color.skin_comp_divider'))
              .alignSelf(ItemAlign.Stretch)
              .strokeWidth('1px')
              .height($r('app.float.account_Divider_height'))
              .margin({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
          }
          .width('100%')
          .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
          .height('1px')
        }
      }
    }
    .width('100%')
    .padding({ left: $r('app.float.id_card_margin_xxl'), right: $r('app.float.id_card_margin_xxl') })
  }

  @Builder
  MenuPreview() {
    Row() {
      Row() {
        Column() {
          Row() {
            Text(this.item.phoneNumber)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.skin_font_primary'))
              .textAlign(TextAlign.Start)
          }
          .margin({ top: '11vp' })

          Row() {
            Text(this.mPresenter.getBlockReasonResource(this.item))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.skin_font_secondary'))
              .textAlign(TextAlign.Start)
          }
          .margin({ bottom: '8vp', top: '2vp' })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(3)

        Column() {
          Row() {
            if (this.haveMultiSimCard) {
              SymbolGlyph(this.item.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
                .fontSize('14vp')
                .fontColor([$r('app.color.skin_icon_tertiary')])
                .opacity($r('app.float.alpha_tertiary'))
            }

            Text(this.item.createTime)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.skin_font_secondary'))
              .textAlign(TextAlign.Start)
              .accessibilityText(StringFormatUtil.getAccessibilityTextByTime(this.item.createTimeSource) as string)
              .padding({
                start: LengthMetrics.vp(8)
              })
          }
          .margin({ top: '8vp' })

          Row() {
            Text((StringUtil.isEmpty(this.item.numberLocation) || this.item.numberLocation === 'N') ?
              '' : this.item.numberLocation)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.skin_font_secondary'))
              .textAlign(TextAlign.Start)
          }
          .margin({ bottom: '8vp', top: '2vp' })
        }
        .alignItems(HorizontalAlign.End)
        .layoutWeight(2)
      }
      .constraintSize({ minHeight: 64 })
      .justifyContent(FlexAlign.Center)
    }
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid'),
    })
    .borderRadius($r('sys.float.ohos_id_corner_radius_menu'))
    .align(Alignment.Start)
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .width('100%')
    .height($r('app.float.id_item_height_max'))
    .margin({ left: '4vp', right: '4vp' })
  }

  @Styles
  MenuItemStyles() {
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
    })
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        start: LengthMetrics.resource($r('app.float.id_card_margin_xl')),
        end: LengthMetrics.resource($r('app.float.id_card_margin_xxl'))
      })
  }

  @Builder
  MenuBuilder() {
    Menu() {
      // 呼叫
      MenuItem({ content: $r('app.string.dialog_call') })
        .MenuItemStyles()
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .onClick(async () => {
          // 点击通话防护记录dialog呼叫
          DotUtil.getInstance().blockedDot(this.contactBlockedCallDialogCallParams, CONTACT_BLOCK_CLICK_CALL_NUM_PAGE);
          HiLog.i(TAG, 'interceptionCallDialogController !!!');
          // get context
          let context: common.UIAbilityContext = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
          call.makeCall(context, this.item.phoneNumber as string);
          AppStorage.SetOrCreate<boolean>('showDialBtn', true);
        })
      this.MenuDivider()
      // 添加到白名单
      if (!this.isInWhiteList) {
        MenuItem({ content: $r('app.string.harassmentAddIntoWhitelist') })
          .MenuItemStyles()
          .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .onClick(async () => {
            // 点击通话防护记录dialog添加到白名单打点
            DotUtil.getInstance().blockedDot(this.contactBlockedCallDialogAddIntoWhitelistParams,
              CONTACT_BLOCK_CLICK_CALL_NUM_PAGE);
            HiLog.i(TAG, 'interceptionCallDialogController !!!');
            //查询号码是否在黑名单中，若在就弹窗，否则直接加入白名单
            this.mPresenter.isInBlockList(this.item.phoneNumber as string, (res: IsBlockContact)=> {
              HiLog.i(TAG, 'interceptionCallDialog isInBlockList: ' + res?.isInBlock);
              this.isInBlockList = res?.isInBlock;
              if (!this.isInBlockList) {
                this.mPresenter.addToWhiteList(this.item.phoneNumber as string, (res: boolean)=> {
                  HiLog.i(TAG, 'interceptionCallDialog addToAllowList: ' + res);
                });
              } else {
                this.inBlockListPhonenumber = res?.phoneNumber;
                this.checkDialog?.open();
                DialogControllerManager.getInstance().addDialogController(this.checkDialog);
              }
            }, false);
          })
        this.MenuDivider()
      }
      // 删除
      MenuItem({ content: $r('app.string.delete') })
        .MenuItemStyles()
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .onClick(async () => {
          // 点击通话防护记录dialog删除打点
          DotUtil.getInstance().blockedDot(this.contactBlockedCallDialogDeleteParams,
            CONTACT_BLOCK_CLICK_CALL_NUM_PAGE);
          HiLog.i(TAG, 'interceptionCallDialogController !!!');
          this.clearInterceptionCallDialogController?.open();
          DialogControllerManager.getInstance().addDialogController(this.clearInterceptionCallDialogController);
        })
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }

  @Builder
  seniorContentLayout() {
    Column() {
      Column() {
        Row() {
          Text(this.item.phoneNumber)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.skin_font_primary'))
            .textAlign(TextAlign.Start)
            .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
        }

        Row() {
          if (this.haveMultiSimCard) {
            SymbolGlyph(this.item.simId == 0 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2'))
              .fontSize('14vp')
              .fontColor([$r('app.color.skin_icon_tertiary')])
              .opacity($r('app.float.alpha_tertiary'))
          }

          Text(this.item.createTime)
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.skin_font_secondary'))
            .textAlign(TextAlign.Start)
            .accessibilityText(StringFormatUtil.getAccessibilityTextByTime(this.item.createTimeSource) as string)
        }.margin({ top: '2vp' })

        Row() {
          Text(this.mPresenter.getBlockReasonResource(this.item))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.skin_font_secondary'))
            .textAlign(TextAlign.Start)
        }.margin({top: '2vp'})
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: $r('app.float.id_card_margin_large'),
        right: $r('app.float.id_card_margin_large'),
        top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale, $r('app.float.id_card_margin_large'),
          $r('app.float.id_card_margin_large')),
        bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
          $r('app.float.id_card_margin_large'), $r('app.float.id_card_margin_large'))
      })
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .borderRadius({
      topLeft: this.showIndex ? 20 : 0,
      topRight: this.showIndex ? 20 : 0,
      bottomRight: this.showDivider ? 0 : 20,
      bottomLeft: this.showDivider ? 0 : 20
    })
    .padding({
      left: $r('app.float.id_card_margin_mid'),
      right: $r('app.float.id_card_margin_mid'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid')
    })
    .bindContextMenu(this.MenuBuilder, ResponseType.LongPress, {
      preview: this.MenuPreview,
      previewAnimationOptions: { scale: [1, 1] },
      placement: Placement.BottomLeft,
      offset: {
        x: 0,
        y: $r('sys.float.padding_level4')
      },
      backgroundColor: $r('app.color.skin_ohos_id_blur_style_component_ultra_thick_color'),
      backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      aboutToAppear: () => {
        // 点击通话防护每条记录打点
        DotUtil.getInstance().blockedDot(this.contactBlockedCallParams, CONTACT_BLOCK_CLICK_CALL_NUMBER);
        HiLog.i(TAG, 'interceptionCallDialogController this.index: ' + this.index);
        //查询号码是否在白名单中，若在则不显示 添加到白名单 选项
        this.mPresenter.isInBlockList(this.item.phoneNumber as string, (res: IsBlockContact)=> {
          HiLog.i(TAG, 'interceptionCallDialogController isInAllowList: ' + res?.isInBlock);
          this.isInWhiteList = res?.isInBlock;
          HiLog.i(TAG, 'interceptionCallDialogController open');
          let phoneNumber = this.item.phoneNumber;
          let numberLocation = (this.item.numberLocation && this.item.numberLocation !== 'N') ? ' ' + this.item.numberLocation : '';
          this.title = phoneNumber + numberLocation;
        }, true);
      }
    })
  }

  @Builder
  buttonName(textName: Resource) {
    Text(textName)
      .width('100%')
      .textAlign(TextAlign.Start)
      .fontSize($r('sys.float.ohos_id_text_size_body1'))
      .fontColor($r('app.color.skin_font_primary'))
      .fontWeight(FontWeight.Medium)
      .padding({ top: '8vp',
        bottom: '8vp',
        left: '12vp',
        right: '12vp'
      })
      .id('blocked_list_details_button')
  }

  @Builder
  buildCustomDialogContent() {
    Scroll() {
      Text($r('app.string.harassment_join_trust_list_hint', this.item.phoneNumber))
        .width('100%')
    }
    .align(Alignment.Top)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .padding({
      left: '24vp',
      right: '24vp'
    })
    .nestedScroll({ scrollForward: NestedScrollMode.PARALLEL, scrollBackward: NestedScrollMode.PARALLEL })
  }
}