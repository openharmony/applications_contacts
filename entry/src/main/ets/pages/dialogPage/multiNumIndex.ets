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
import { ArrayUtil, HiLog } from '../../../../../../feature/call/oh_modules/common';
import { MultiNumCardItems, SelectMultiNumDialog, SelectNumDialogBuilder } from '../dialog/SelectMultiNumDialog';
import { PhoneNumber } from '../../../../../../feature/phonenumber';
import { Phone } from '../../../../../../feature/contact';
import { FormCardController } from '../../card/common/FormCardController';
import { SelectDialogBuilder, SelectSimIdDialog } from '../dialog/SelectSimIdDialog';
import WorkFactory, { WorkerType } from '../../workers/WorkFactory';
import { BusinessError } from '@ohos.base';
import { CallLog } from '../../../../../../feature/call';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import sim from '@ohos.telephony.sim';
import { DSDS_MODE_V2 } from '../../component/mutisim/DsdaConstants';
import { getDialDirectlyAccountId } from '../../model/CallStateModel';
import { CustomizedParams } from '../../model/type';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import DotUtil from '../../util/DotUtil';
import call from '@ohos.telephony.call';
import { RoamingManager } from '../../feature/roaming/RoamingManager';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
// import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from '@kit.UIDesignKit'

const TAG = 'MultiNumPage';
const FAVORITE_NUMBER_GUIDE_EVENT = 'FAVORITE_NUMBER_GUIDE_EVENT';
const CALL_DIALOG_EVENT = 'CALL_DIALOG_EVENT';

@Entry
@Component
struct Index {
  mFormCardController: FormCardController = FormCardController.getInstance();
  isEmergencyNum: boolean = false;
  @Provide('pathInfo') pathInfo: NavPathStack = new NavPathStack();
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @State selectSimBuilder: SelectDialogBuilder = {
    title: '',
    multiSimCardItems: [{
      name: '',
      img: $r('sys.symbol.phone_badge_1'),
    }, {
      name: '',
      img: $r('sys.symbol.phone_badge_2'),
    }],
  };
  @State builder: SelectNumDialogBuilder = {
    title: $r('app.string.contacts_call'),
    multiNumCardItems: [],
    contactId: ''
  };
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @State favoriteGuideParams: CustomizedParams = {
    ISCLICK: 0,
    ISDEFAULT: 0,
    ISCANCEL: 0
  };
  callDialogParams: CustomizedParams = {
    ITEM: 0,
    ISCANCEL: 1
  };
  mSelectSlotIdDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: this.builder.title,
      contentBuilder: () => {
        this.SelectSlotIdDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            //联系人打点--收藏页面多号码联系人引导窗口--是否取消
            this.favoriteGuideParams.ISCANCEL = 1;
            DotUtil.getInstance().contactDot(this.favoriteGuideParams, FAVORITE_NUMBER_GUIDE_EVENT);
            this.mSelectSlotIdDialog.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            this.terminateSelf();
          },
        }
      ]
    }),
    cancel: () => {
      this.terminateSelf()
    },
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });
  mSelectSimIdDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: this.selectSimBuilder.title,
      contentBuilder: () => {
        this.SelectSimIdDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.callDialogParams.ITEM = -1;
            this.callDialogParams.ISCANCEL = 1;
            DotUtil.getInstance().contactDot(this.callDialogParams, CALL_DIALOG_EVENT);
            this.mSelectSimIdDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            this.terminateSelf();
          },
        }
      ]
    }),
    cancel: () => {
      this.terminateSelf();
    },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    autoCancel: true,
  });

  async onPageShow() {
    HiLog.i(TAG, 'multiPhoneDataList start');

    interface MultiPhoneDataItem {
      id: number
      phones: PhonesType[]
    }

    interface PhonesType {
      num: string
      primary: boolean
      dataId: string
      numType: string
    }

    let paramsData: ParamsDataItems | undefined = AppStorage.get('params');
    let multiPhoneDataItem: MultiPhoneDataItem = JSON.parse(paramsData?.phoneNumberShow as string);
    HiLog.i(TAG, 'multiPhoneDataList value');
    this.builder.multiNumCardItems = [];
    this.builder.contactId = multiPhoneDataItem.id.toString();
    let hasDefault: boolean = false;
    let PromiseList: Promise<string>[] = []
    multiPhoneDataItem.phones.forEach(async (element: PhonesType, index: number) => {
      PromiseList.push(new Promise(async (resolve) => {
        let formatNum = PhoneNumber.fromString(element.num).getNumber().replace(new RegExp('\\s+', 'g'), '');
        if (element.primary) {
          this.dealCallNumber(formatNum);
          hasDefault = true;
          return;
        }
        const phoneNumber: string = await new PhoneNumber(element.num).format();
        HiLog.i(TAG, '[builder forEach formatNum]' + formatNum);
        HiLog.i(TAG, '[builder forEach phoneNumber]');
        let phoneItem: MultiNumCardItems = {
          number: phoneNumber,
          img: $r('sys.symbol.phone'),
          numType: Phone.getTypeLabelResource(Number.parseInt(element.numType, 10)),
          dataId: Number(element.dataId)
        };
        HiLog.i(TAG, '[builder forEach phoneItem]');
        this.builder.multiNumCardItems.push(phoneItem);
        resolve('end')
      }))
    });
    Promise.all(PromiseList).then(() => {
      HiLog.i(TAG, '[builder.multiNumCardItems]');
      this.builder.callback = (item) => {
        this.dealCallNumber(item.number);
        this.mSelectSlotIdDialog.close();
        DialogControllerManager.getInstance().dialogControllerSet.clear();
      }
      if (!hasDefault) {
        HiLog.i(TAG, 'hasDefault is false');
        this.mSelectSlotIdDialog.open();
        DialogControllerManager.getInstance().addDialogController(this.mSelectSlotIdDialog);
      }
    }).catch((error: Error) => {
      HiLog.e(TAG, `Error in Promise.all: ${error?.message}`);
    });
  }

  terminateSelf() {
    let context = ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.CardDialogContextName);
    context?.terminateSelf()
      .then(() => {
        HiLog.i(TAG, 'terminateSelfWithResult Operation succeeded: ');
      })
      .catch((error: BusinessError) => {
        HiLog.e(TAG, 'Operation failed. Cause: %s', error?.message);
      });
  }

  async dealCallNumber(phoneNum: string) {
    HiLog.i(TAG, 'dealCallNumber start');
    let simStateOne = await sim.isSimActive(0) ?? false
    HiLog.i(TAG, `dealCallNumber simStateOne:${simStateOne}`)
    let simStateTwo = await sim.isSimActive(1) ?? false
    HiLog.i(TAG, `dealCallNumber simStateTwo:${simStateTwo}`)
    let defaultVoiceSlotId: number
    try {
      defaultVoiceSlotId = await sim.getDefaultVoiceSlotId()
    } catch (e) {
      HiLog.i(TAG, `defaultVoiceSlotId getDefaultVoiceSlotId error`);
      defaultVoiceSlotId = -1
    }
    HiLog.i(TAG, `dealCallNumber defaultVoiceSlotId:${defaultVoiceSlotId}`)
    let haveMultiSimCard = simStateOne && simStateTwo;
    let haveSimCard = simStateOne || simStateTwo;
    HiLog.i(TAG, `dealCallNumber haveMultiSimCard:${haveMultiSimCard} haveSimCard:${haveSimCard} `);
    if (!haveSimCard) {
      HiLog.i(TAG, 'No SIM card!');
      this.mFormCardController.notHaveSimCard(phoneNum, simStateOne ? 0 : 1);
      router.back();
    } else if (defaultVoiceSlotId !== -1) {
      let options: call.DialOptions = {
        accountId: defaultVoiceSlotId
      };
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, options, (isSuccess: boolean) => {
        HiLog.i(TAG, `dial in multiNumIndex isSuccess ${isSuccess} with default sim`);
      });
      router.back();
    } else if (haveMultiSimCard) {
      this.dialWithMultiSim(phoneNum);
    } else {
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
        accountId: simStateOne ? 0 : 1
      }, (isSuccess: boolean) => {
        HiLog.i(TAG, `dial in multiNumIndex isSuccess ${isSuccess} with single sim`);
      });
      router.back();
    }
  }

  private dialWithMultiSim(phoneNum: string) {
    this.selectSimBuilder.title = $r('app.string.contacts_call_number', phoneNum);
    this.selectSimBuilder.callback = (value) => {
      const directAccountId = getDialDirectlyAccountId(DSDS_MODE_V2);
      if (directAccountId !== undefined) {
        // 3.0 case!
        HiLog.w(TAG, 'Call directly through sim ' + directAccountId);
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
          accountId: directAccountId
        }, (isSuccess: boolean) => {
          HiLog.i(TAG, `dial in multiNumIndex isSuccess ${isSuccess} with has direct sim`);
        });
      } else {
        RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNum, {
          accountId: value
        }, (isSuccess: boolean) => {
          HiLog.i(TAG, `dial in multiNumIndex isSuccess ${isSuccess} with multi sim`);
        });
      }
      this.terminateSelf();
    };
    HiLog.i(TAG, 'contactsPhoneObj10---');
    HiLog.i(TAG, 'findByNumberIn');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('findByNumberIn', {
      actionData: {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardDialogContext(),
        numbers: [phoneNum],
      }
    }, (resultList: CallLog[]) => {
      HiLog.i(TAG, `contactsPhoneObj11--- size: ${resultList?.length}`);
      if (!ArrayUtil.isEmpty(resultList)) {
        this.selectSimBuilder.lastSimId = resultList[0].simId;
      } else {
        this.selectSimBuilder.lastSimId = -1;
      }
      let spnList = AppStorage.Get<Array<string | Resource>>('spnList');
      HiLog.i(TAG, `contactsPhoneObj12---, ${spnList}`);
      if (spnList != undefined && this.selectSimBuilder.multiSimCardItems != undefined) {
        for (let index = 0; index < spnList.length; index++) {
          this.selectSimBuilder.multiSimCardItems[index].name = spnList[index];
        }
      }
      HiLog.i(TAG, 'contactsPhoneObj13---');
      this.mSelectSimIdDialog?.open();
      DialogControllerManager.getInstance().addDialogController(this.mSelectSimIdDialog);
    });
  }

  onInitData(isVisible: boolean) {
    HiLog.i(TAG, `onInitData ${isVisible}`);
    if (!isVisible) {
      this.mSelectSlotIdDialog.close();
      this.mSelectSimIdDialog.close();
      DialogControllerManager.getInstance().dialogControllerSet.clear();
    }
  }

  @Builder
  myRouter(name: string, params: Object) {

  }

  build() {
   Navigation(this.pathInfo) {
      Column() {
        Text('')
      }
      .width('100%').height('100%')
      .backgroundColor('rgba(0,0,0,0)')
    }
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean) => {
      this.onInitData(isVisible)
    })
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .navDestination(this.myRouter)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }

  @Builder
  SelectSlotIdDialogBuilder() {
    Column() {
      SelectMultiNumDialog({
        builder: this.builder,
        controller: this.mSelectSlotIdDialog,
        favoriteGuideParams: this.favoriteGuideParams
      })
    }
    .width('100%')
  }

  @Builder
  SelectSimIdDialogBuilder() {
    Column() {
      SelectSimIdDialog({
        builder: this.selectSimBuilder,
        controller: this.mSelectSimIdDialog
      })
    }
    .width('100%')
  }
}

class ParamsDataItems {
  public sourceHasPhone: Boolean = false;
  public phoneNumberShow: string = '';
}
