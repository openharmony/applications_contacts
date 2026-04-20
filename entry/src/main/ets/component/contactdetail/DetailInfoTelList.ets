/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { StringUtil, HiLog } from '../../../../../../common';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import call from '@ohos.telephony.call';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { DataItemType } from '../../../../../../feature/contact/src/main/ets/contract/DataType';
import IndexPresenter from '../../presenter/IndexPresenter';
import { SelectDialogBuilder } from '../../pages/dialog/SelectSimIdDialog';
import VibrationUtils from '../../util/VibrationUtils';
import DetailPresenter from '../../presenter/contact/detail/DetailPresenter';
import { ContactStrInterface, CustomizedParams } from '../../model/type';
import { ContackPhoneSubInfoModel } from '../../model/type/ContactParams';
import connection from '@ohos.net.connection';

import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { ResourceUtil } from '../../util/ResourceUtil';
import { VibrationEffect } from '../../model/type/EnumUtil';
import GetNumberLocation from '../../util/GetNumberLocation';
import { getDialDirectlyAccountId } from '../../model/CallStateModel';
import DotUtil from '../../util/DotUtil';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../feature/sim/SimCardState';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { CallLogSearchBo } from '../../model/bean/CallLogSearchBo';
import LooseObject from '../../model/type/LooseObject';
import { RoamingManager } from '../../feature/roaming/RoamingManager';
import { FontScaleState } from '../../util/fontScaleState';
import { i18n } from '@kit.LocalizationKit';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import deviceInfo from '@ohos.deviceInfo';
import { LengthMetrics } from '@kit.ArkUI';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';

const TAG = 'DetailInfoTelList';
const MESSAGE_SENDING_EVENT = 'MESSAGE_SENDING_EVENT';
const CALL_EVENT = 'CALL_EVENT';
const DETAILS_PRESS_NUM_EVENT = 'DETAILS_PRESS_NUM_EVENT';
const DETAILS_PRESS_CHOOSE_EVENT = 'DETAILS_PRESS_CHOOSE_EVENT';
const CLICK_DETAIL_NUM_EVENT = 'CLICK_DETAIL_NUM_EVENT';


enum MenuType {
  Copy, EditBeforeCall, setPrimary
}

@Component
export default struct DetailInfoTelList {
  @Link mPresenter: DetailPresenter;
  // selectSimBuilder
  @Link selectSimBuilder: SelectDialogBuilder;
  // 最大化
  @Link maximum: number;
  @Prop telephoneTotal: number;
  @Prop otherTotal: number;
  @Prop meettingTotal: number;
  @Link moreOptionsFlag: boolean;

  build() {
    Column() {
      //Phone List
      TelList({
        mPresenter: $mPresenter,
        selectSimBuilder: $selectSimBuilder,
        maximum: $maximum,
        moreOptionsFlag: $moreOptionsFlag,
        telephoneTotal: this.telephoneTotal,
        meettingTotal: this.meettingTotal,
        otherTotal: this.otherTotal,
      });
    }
  }
}

/**
 * Phone List
 */
@Component
struct TelList {
  @Link @Watch('mPresenterChange') private mPresenter: DetailPresenter;
  @Link selectSimBuilder: SelectDialogBuilder;
  @Link maximum: number;
  @Link moreOptionsFlag: boolean;
  @State otherFlag: boolean = false;
  @State isPressedIndex: number = -1;
  @Prop telephoneTotal: number;
  @Prop meettingTotal: number;
  // other total
  @Prop otherTotal: number;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  customParams: CustomizedParams = {};

  mPresenterChange() {
    if (this.meettingTotal > 0 || this.otherTotal > 0
    ) {
      this.otherFlag = true
    }
  }

  // 处理展开更多与未展开更多情况下分割线的显示
  isDividerShow(totalCount: number, index: number): Visibility {
    let dividerShow: Visibility = Visibility.None;
    if (!this.moreOptionsFlag && totalCount > this.maximum) {
      if (index === this.maximum - 1) {
        dividerShow = Visibility.None
      } else {
        dividerShow = Visibility.Visible
      }
    } else {
      if (index === totalCount - 1) {
        dividerShow = Visibility.None
      } else {
        dividerShow = Visibility.Visible
      }
    }
    return dividerShow
  }


  build() {
    if (!ArrayUtil.isEmpty<ContackPhoneSubInfoModel>(this.mPresenter.contactForm.phones)) {
      List() {
        LazyForEach(this.mPresenter.phoneDataSources, (item: ContactStrInterface, index: number) => {
          if (JSON.parse(item.data).data && this.itemVisible(index)) {
            ListItem() {
              Column() {
                TelListItem({
                  message: item.data,
                  mPresenter: $mPresenter,
                  selectSimBuilder: $selectSimBuilder,
                  index: item.index,
                  telephoneTotal: this.telephoneTotal
                })
                Divider()
                  .color($r('app.color.skin_comp_divider'))
                  .strokeWidth('1px')
                  .width('100%')
                  .visibility(this.isDividerShow(this.mPresenter.phoneDataSources.totalCount(), index))
                  .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
              }
            }
            .height('undefined')
          }
        }, (item: ContactStrInterface, index: number) => JSON.stringify(item) + JSON.stringify(index))
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .enableScrollInteraction(false)
    }
  }

  itemVisible(index: number): boolean {
    return this.moreOptionsFlag ? (index < this.mPresenter.phoneDataSources.totalCount()) : (index < this.maximum);
  }
}

/**
 * Phone Item
 */
@Reusable
@Component
struct TelListItem {
  @Prop private message: string;
  @Prop private index: number;
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  @State isEmergencyNum: boolean = false;
  @State aphoneAdress: string = '';
  @StorageLink('haveSimCard') haveSimCard: boolean = false;
  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @Link private mPresenter: DetailPresenter;
  @Link selectSimBuilder: SelectDialogBuilder;
  // 号码归属地
  @State numberLocation: string = '';
  @State formatNumber: string = '';
  @State contactId: number = 0;
  @StorageLink('isAirplaneMode') isAirplaneMode: boolean = false;
  @StorageLink('voLteRegStates') voLteRegStates: boolean[] = [false, false];
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  @StorageLink('isContactSearch') isContactSearch: boolean = false;
  @StorageLink('isDistributedModemState') isDistributedModemState: boolean = false;
  @StorageLink('isDistributedCallPhoneSharing') isDistributedCallPhoneSharing: boolean = false;
  @StorageLink('isDistributedCallSourcePhone') isDistributedCallSourcePhone: boolean = false;
  @State isShowPhoneRecordPopup: boolean = false;
  @Prop telephoneTotal: number;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @State isMenuShown: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @State isPressedIndex: number = -1;
  @StorageProp('isInDetailLongPress') isInDetailLongPress: boolean = false;
  customParams: CustomizedParams = {};
  sendMsgParams: CustomizedParams = {
    ENC: 1,
    ISKNOW: 0
  };
  callParams: CustomizedParams = {
    ENC: 1,
    SLOT: 0,
    ISMULTISIMCARD: 0
  };
  detailPressChooseParams: CustomizedParams = {
    ISSELECT: 0,
    ITEM: -1
  };
  customizedParams: CustomizedParams = {};

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.copy') })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .onClick(() => {
          this.detailPressChooseParams.ISSELECT = 1;
          this.detailPressChooseParams.ITEM = 0;
          this.mIndexPresenter.getCopy(JSON.parse(this.message).data);
        })
      if (!this.isFromMeetime && (call.hasVoiceCapability() ||
        this.isDistributedCallPhoneSharing && this.isDistributedModemState && this.isDistributedCallSourcePhone)) {
        this.MenuDivider()
        MenuItem({ content: $r('app.string.contacts_call') })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .onClick(() => {
            this.detailPressChooseParams.ISSELECT = 1;
            this.detailPressChooseParams.ITEM = 1;
            AppStorage.SetOrCreate('isRouterBack', true);
            DialerPresenter.getInstance().editPhoneNumber(JSON.parse(this.message).data);
            AppStorage.SetOrCreate<boolean>('showDialBtn', true);
            if (this.isContactSearch) {
              this.isContactSearch = false;
            }
          })
      }
      if (this.getDefaultValue() && !this.mPresenter.isYellowPage) {
        this.MenuDivider()
        MenuItem({
          content: JSON.parse(this.message)
            .primary == true ? $r('app.string.clear_default_values') : $r('app.string.set_default_values')
        })
          .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .onClick(() => {
            this.detailPressChooseParams.ISSELECT = 1;
            this.detailPressChooseParams.ITEM = 2;
            this.mPresenter.setPhonePrimary(this.index, JSON.parse(this.message).primary != true)
          })
      }
    }
    .onDisAppear(() => {
      DotUtil.getInstance().contactDot(this.detailPressChooseParams, DETAILS_PRESS_CHOOSE_EVENT);
    })
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }

  getDefaultValue(): boolean {
    let number: number = 1;
    HiLog.i(TAG, 'phoneCount: ' + this.mPresenter.phoneDataSources.totalCount());
    if (this.mPresenter.phoneDataSources.totalCount() > number) {
      return true
    }
    return false;
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_ohos_id_color_list_separator'))
      .strokeWidth('1px')
      .width('100%')
      .alignSelf(ItemAlign.Stretch)
      .visibility(Visibility.Visible)
      .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
  }

  @Builder
  MenuPreviewBuilder(formatNumber: string, getText: string) {
    Scroll() {
      Column() {
        Column() {
          if (FontScaleState.isSmallerThirdGeer(this.fontSizeScale)) {
            this.normalLayout()
          } else {
            Scroll() {
              this.normalLayout()
            }
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.None)
          }
        }
      }
      .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid')
    })
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
    .width(DisplaySplitUtil.isHorizonSplit(this.splitStatus) && deviceInfo.deviceType == 'tablet' ? '45%' : '87%')
    .borderRadius($r('app.float.rounded_corners_width_20'))
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
  }

  aboutToReuse(params: LooseObject) {
    this.numberLocation = params.numberLocation;
    this.formatNumber = params.formatNumber;
    if (undefined == this.numberLocation) {
      let phoneNumInfo: ContackPhoneSubInfoModel = JSON.parse(this.message)
      this.contactId = this.mPresenter.contactId
      let number = phoneNumInfo.data;
      if (number) {
        GetNumberLocation.getNumberLocation(number, (location: string) => {
          this.numberLocation = location;
        })
      }
    }
  }

  aboutToAppear() {
    let phoneNumInfo: ContackPhoneSubInfoModel = JSON.parse(this.message)
    this.contactId = this.mPresenter.contactId
    let number = phoneNumInfo.data;
    if (number) {
      GetNumberLocation.getNumberLocation(number, (location: string) => {
        this.numberLocation = location;
      })
    }
  }

  getText() {
    let phoneNumInfo: ContackPhoneSubInfoModel = JSON.parse(this.message)
    let labelStr = ''

    //黄页只显示电话类型
    if (this.mPresenter.isYellowPage) {
      if (typeof phoneNumInfo.labelName === 'string') {
        labelStr += phoneNumInfo.labelName;
        return labelStr;
      } else if (typeof phoneNumInfo.labelName === 'object') {
        labelStr = ResourceUtil.getStringByResourceId((phoneNumInfo.labelName as Resource).id);
        return labelStr;
      } else {
        return labelStr;
      }
    }

    // 陌生人进入详情页--不显示电话类型前缀
    if (this.contactId > 0 && phoneNumInfo.labelName != undefined) {
      if (Number.parseInt(phoneNumInfo.type as string) == PhoneAccountType.TYPE_ID_CUSTOM) {
        labelStr += phoneNumInfo.labelName
      } else {
        labelStr += ResourceUtil.getStringByResourceId((phoneNumInfo.labelName as Resource).id)
      }
    }

    if (phoneNumInfo.phoneAddress != undefined) {
      if (!StringUtil.isEmpty(labelStr)) {
        labelStr += ' - '
      }
      if (phoneNumInfo.phoneAddress instanceof String) {
        labelStr += phoneNumInfo.phoneAddress
      } else {
        // phoneAddress 为Resource
        labelStr += this.numberLocation ? this.numberLocation :
        ResourceUtil.getStringByResourceId((phoneNumInfo.phoneAddress as Resource).id);
      }
    }

    if (this.telephoneTotal > 1 && phoneNumInfo.primary == true) {
      labelStr += ' ' + ResourceUtil.getStringByResourceId($r('app.string.default_value').id)
    }

    return labelStr
  }

  SIMCardSelection(phoneNum: string) {
    this.selectSimBuilder.title = $r('app.string.contacts_call_number', phoneNum);
    this.selectSimBuilder.callback = (value) => {
      const optionsObj: call.DialOptions = {
        accountId: value,
        videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
      }
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, optionsObj);
    }
    this.selectSimBuilder.lastSimId = this.mPresenter.lastUsedSlotId;
    let spnList = AppStorage.get<Array<string | Resource>>('spnList');
    if (spnList && this.selectSimBuilder.multiSimCardItems) {
      for (let index = 0; index < spnList.length; index++) {
        this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
      }
    }
    this.selectSimBuilder.controller?.open();
  }

  videoCalling() {
    let phoneNum: string = JSON.parse(this.message)?.num;
    const isAllRegvoLteStates = this.voLteRegStates[0] && this.voLteRegStates[1];
    if (this.haveMultiSimCard) {
      if (!isAllRegvoLteStates) {
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
          accountId: this.voLteRegStates[0] ? 0 : 1,
          videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
        });
        return;
      }
      this.SIMCardSelection(phoneNum);
    } else {
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
        accountId: AppStorage.Get<number>('defaultSlot'),
        videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
      });
    }
  }

  detailSendMsg() {
    // 联系人打点-联系人详情页点击发送短信
    if (this.mPresenter.contactId != undefined) {
      this.sendMsgParams.ISKNOW = 1;
    } else {
      this.sendMsgParams.ISKNOW = 0;
    }
    DotUtil.getInstance().contactDot(this.sendMsgParams, MESSAGE_SENDING_EVENT);
  }

  multiNoDefaultDot() {
    // 联系人打点--双卡状态下并且未设置默认卡点击号码时打点
    if (this.haveMultiSimCard && this.defaultSlot === simId_DEFAULT) {
      DotUtil.getInstance().contactDot(this.customizedParams, CLICK_DETAIL_NUM_EVENT);
    }
  }

  detailMultiSelectDot(value: number) {
    //联系人打点--联系人详情处点击呼叫-如果是双卡弹窗选择卡号之后拨打电话
    this.callParams.SLOT = value;
    this.callParams.ISMULTISIMCARD = 1;
    DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
  }

  noMultiCallDot() {
    //联系人打点--不是双卡拨打电话点击号码直接拨出
    this.callParams.SLOT = AppStorage.Get<number>('defaultSlot');
    this.callParams.ISMULTISIMCARD = 0;
    DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
  }

  @Builder
  normalLayout() {
    Row() {
      Column() {
        Row() {
          Text(this.formatNumber)
            .fontSize('16fp')
            .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
            .direction(Direction.Ltr)
            .onAppear(async () => {
              let phoneString = PhoneNumber.fromString(JSON.parse(this.message).data).number;
              let commaIndex = phoneString.indexOf(',');
              let semicolonIndex = phoneString.indexOf(';');
              if (commaIndex === -1 && semicolonIndex === -1) {
                this.formatNumber = await PhoneNumber.fromString(JSON.parse(this.message).data).phoneAddSpace();
              } else {
                this.formatNumber = phoneString;
              }
            })
            .width('100%')
        }
        .constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xxl') })
        .width('100%')

        Row() {
          Text(this.getText())
            .fontSize('14fp')
            .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xl') })
        .width('100%')
        .margin({ top: $r('app.float.id_card_margin_sm') })
      }
      .constraintSize({
        minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
      })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
    .constraintSize({ minHeight: this.isPC ? $r('app.float.id_item_height_large') :
    $r('app.float.id_item_height_max')})
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

  build() {
    Column() {
      this.normalLayout()

    }
    .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO)})
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .constraintSize({
      minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
    })
    .backgroundColor(this.isPressedIndex === this.index ? $r('app.color.skin_interactive_click') :
    $r('app.color.skin_ohos_id_color_list_card_bg'))
    .borderRadius(this.isPressedIndex === this.index ? $r('sys.float.ohos_id_corner_radius_card') :
    $r('sys.float.padding_level8'))
    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    .onClick(async () => {
      HiLog.i(TAG, `TelListItem ${this.index} onClick`);
      this.multiNoDefaultDot();
      let phoneNum: string = JSON.parse(this.message).num;
      if (call.hasVoiceCapability() ||
        this.isDistributedCallPhoneSharing && this.isDistributedModemState && this.isDistributedCallSourcePhone) {
        CallLogSearchBo.getInstance().refreshCallChangeFlag();
        if (this.haveMultiSimCard) {
          // 双卡下设置默认卡号直接拨打电话
          if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
            HiLog.i(TAG, 'defaultSlot: ' + this.defaultSlot);
            RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, { accountId: this.defaultSlot });
            return;
          } else {
            HiLog.w(TAG, 'TelListItem onClick no defaultSlot');
          }
          const directAccountId = getDialDirectlyAccountId(this.mPresenter.dsdsMode)
          if (directAccountId !== undefined) {
            // 3.0 case!
            HiLog.i(TAG, 'Call directly through sim ' + directAccountId);
            RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, { accountId: directAccountId });
            return;
          }
          this.selectSimBuilder.title = $r('app.string.contacts_call_number', phoneNum);
          this.selectSimBuilder.callback = (value) => {
            const accountIdObj: call.DialOptions = {
              accountId: value,
            }
            RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, accountIdObj);
            this.detailMultiSelectDot(value);
          }
          this.selectSimBuilder.gotoDialer = () => {
            AppStorage.SetOrCreate('isRouterBack', true);
            DialerPresenter.getInstance().editPhoneNumber(phoneNum);
            AppStorage.SetOrCreate<boolean>('showDialBtn', true);
          }
          this.selectSimBuilder.lastSimId = this.mPresenter.lastUsedSlotId;
          let spnList = AppStorage.get<Array<string | Resource>>('spnList');
          if (spnList && this.selectSimBuilder.multiSimCardItems) {
            for (let index = 0; index < spnList.length; index++) {
              this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
            }
          }
          this.selectSimBuilder.controller?.open();
        } else {
          RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum);
          this.noMultiCallDot();
        }
      } else {
        HiLog.w(TAG, `TelListItem ${this.index} onClick no VoiceCapability`);
      }
    })
    .onTouch((event: TouchEvent) => {
      switch (event.type) {
        case TouchType.Down:
          this.isPressedIndex = this.index;
          break;
        case TouchType.Up:
        case TouchType.Cancel:
          this.isPressedIndex = -1;
          break;
      }
    })
    .onHover((isHover: boolean) => {
      if (isHover) {
        this.isPressedIndex = this.index;
      } else {
        this.isPressedIndex = -1;
      }
    })
    .bindContextMenu(this.isMenuShown, this.MenuBuilder, {
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: { scale: [1.0, 1.0] },
      placement: Placement.BottomLeft,
      offset: { x: 0, y: $r('sys.float.padding_level4') },
      backgroundColor: this.isThemeActive ? ($r('app.color.skin_ohos_id_color_list_card_bg')) : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
      onAppear: () => {
        this.isInDetailLongPress = true;
      },
      onDisappear: () => {
        this.isInDetailLongPress = false;
      },
      aboutToDisappear: () => {
        this.isMenuShown = false;
      }
    })
    .gesture(GestureGroup(GestureMode.Exclusive,
      LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
        .onAction((event: GestureEvent) => {
          this.isMenuShown = true
          this.isPressedIndex = -1;
        })
    ))
    .onMouse((event: MouseEvent) => {
      if (event.button === MouseButton.Right && event.action === MouseAction.Release) {
        this.isMenuShown = true
      }
    })
    .parallelGesture(LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
      .onAction((event: GestureEvent) => {
        VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
        // 联系人打点-联系人详情长按号码
        DotUtil.getInstance().contactDot(this.customParams, DETAILS_PRESS_NUM_EVENT);
      })
    )
    .width('100%')
  }
}

