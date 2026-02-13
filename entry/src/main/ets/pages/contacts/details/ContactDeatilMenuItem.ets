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
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { ContackPhoneSubInfoModel } from '../../../model/type/ContactParams';
import { call } from '@kit.TelephonyKit';
import { CallLogSearchBo } from '../../../model/bean/CallLogSearchBo';
import { RoamingManager } from '../../../feature/roaming/RoamingManager';
import { getDialDirectlyAccountId } from '../../../model/CallStateModel';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import DetailPresenter from '../../../presenter/contact/detail/DetailPresenter';
import { simId_DEFAULT, simId_ONE, simId_TWO } from '../../../feature/sim/SimCardState';
import { CustomizedParams } from '../../../model/type';
import { SelectDialogBuilder } from '../../dialog/SelectSimIdDialog';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';

const TAG = 'CardTelList';

@Component
export struct ContactDetailMenuItem {
  //电话号码
  @Prop phone: string = '';
  //号码类型
  @Prop labelInfo: string = '';
  //类型 电话 视频 短信
  @Prop callType: string = '';
  //item 数据
  @Prop item: ContackPhoneSubInfoModel;

  @Link selectSimBuilder: SelectDialogBuilder;
  @Link private mPresenter: DetailPresenter;
  @StorageLink('isDistributedCallPhoneSharing') isDistributedCallPhoneSharing: boolean = false;
  @StorageLink('isDistributedCallSMSSharing') isDistributedCallSMSSharing: boolean = false;
  @StorageLink('isDistributedCallSourcePhone') isDistributedCallSourcePhone: boolean = false;

  @StorageLink('haveMultiSimCard') haveMultiSimCard: boolean = false;
  @StorageLink('isAirplaneMode') isAirplaneMode: boolean = false;
  @StorageLink('voLteRegStates') voLteRegStates: boolean[] = [false, false];
  @StorageLink('haveVoLteReg') haveVoLteReg: boolean = false;
  @StorageLink('defaultSlot') defaultSlot: number = simId_DEFAULT;
  sendMsgParams: CustomizedParams = {
    ENC: 1,
    ISKNOW: 0
  };
  async aboutToAppear(): Promise<void> {
    this.phone = await PhoneNumber.fromString(this.phone).phoneAddSpace();
  }
  voiceCalling() {
    let phoneNum: string = this.item.num!;
    if (call.hasVoiceCapability() ||
      (AppStorage.get('isDistributedCallPhoneSharing') && AppStorage.get('isDistributedModemState') &&
      AppStorage.get('isDistributedCallSourcePhone'))) {
      CallLogSearchBo.getInstance().refreshCallChangeFlag();
      if (this.haveMultiSimCard) {
        // 双卡下设置默认卡号直接拨打电话
        if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
          HiLog.i(TAG, 'defaultSlot: ' + this.defaultSlot);
          RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, { accountId: this.defaultSlot });
          return;
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
      }
    }
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
    let phoneNum: string = this.item.num!;
    const isAllRegvoLteStates = this.voLteRegStates[0] && this.voLteRegStates[1];
    if (this.haveMultiSimCard) {
      if (this.defaultSlot === simId_ONE || this.defaultSlot === simId_TWO) {
        HiLog.i(TAG, 'defaultSlot: ' + this.defaultSlot);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
          accountId: this.defaultSlot,
          videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
        });
        return;
      }

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
    this.mPresenter.sendMessage(
      this.item.num!,
      this.item.data!,
      this.mPresenter.contactForm.displayName.toString(),
      this.mPresenter.contactId
    );
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  @Builder
  customMenuItem() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text(this.phone)
              .fontSize('16fp')
              .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          .constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xxl') })
          .width('100%')

          Row() {
            Text(this.labelInfo)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xl') })
          .width('100%')
          .margin({ top: $r('app.float.id_card_margin_sm') })
        }
        .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
      }
      .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
  }

  build() {
    Column() {
      MenuItem(this.customMenuItem())
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .labelFontColor($r('app.color.skin_ohos_id_color_text_secondary'))
        .onClick(() => {
          if (this.callType === 'videoCalling') {
            this.videoCalling();
          } else if (this.callType === 'voiceCalling') {
            this.voiceCalling()
          } else if (this.callType === 'detailSendMsg') {
            this.detailSendMsg();
          }
        })
        .width('100%')
    }
    .width('100%')
  }
}