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
import { PhoneNumber } from '../../../../../../feature/phonenumber';
import { FormCardController } from '../../card/common/FormCardController';
import { SelectDialogBuilder, SelectSimIdDialog } from '../dialog/SelectSimIdDialog';
import WorkFactory, { WorkerType } from '../../workers/WorkFactory';
import { BusinessError } from '@ohos.base';
import {
  ContactsGlobalThisHelper
} from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import common from '@ohos.app.ability.common';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import { CallLog } from '../../../../../../feature/call';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import router from '@ohos.router';
import MainAbility from '../../MainAbility/MainAbility';
import Want from '@ohos.app.ability.Want';
import { infoString } from '../../card/data/cardData';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import IndexPresenter from '../../presenter/IndexPresenter';
import { RoamingManager } from '../../feature/roaming/RoamingManager';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
// import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from '@kit.UIDesignKit'

const TAG = 'MultiSimPage';
const CALL_DIALOG_EVENT = 'CALL_DIALOG_EVENT';

@Entry
@Component
struct Index {
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  isEmergencyNum: boolean = false;
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
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
  callDialogParams: CustomizedParams = {
    ITEM: 0,
    ISCANCEL: 1
  };
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
      this.terminateSelf()
    },
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

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

  async onPageShow() {
    let paramsData: ParamsDataItems | undefined = AppStorage.get('params');
    let phoneNumData: string | undefined = paramsData?.phoneNumberShow;
    this.selectSimBuilder.title = $r('app.string.contacts_call_number', phoneNumData);
    this.selectSimBuilder.gotoDialer = () => {
      DialerPresenter.getInstance().editPhoneNumber(phoneNumData!);
      AppStorage.SetOrCreate<boolean>('showDialBtn', true);
      AppStorage.SetOrCreate('mainTabsIndex', this.mIndexPresenter.callIndex);
      let context = ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.CardDialogContextName);
      let actionData: Record<string, string> = {
        'phoneNumber': phoneNumData as string
      };
      const want: Want = {
        bundleName: infoString.CONTACT_BUNDLE_NAME,
        abilityName: infoString.CONTACT_ABILITY_NAME,
        parameters: actionData,
        entities: [
          infoString.COMMON_ENTITIES
        ]
      };
      context?.startAbility(want).then(() => {
        HiLog.i(TAG, 'jumpToContact, startAbility Success');
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'jumpToContact, failed. Cause: ' + error?.message);
      });

    }
    this.selectSimBuilder.callback = (value) => {
      RoamingManager.getInstance().handleRoaming(this.getUIContext(), phoneNumData, {
        accountId: value
      }, (isSuccess: boolean) => {
        this.terminateSelf();
      });
      this.terminateSelf();
    };
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('findByNumberIn', {
      actionData: {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardDialogContext(),
        numbers: [phoneNumData]
      }
    }, (resultList: CallLog[]) => {
      if (!ArrayUtil.isEmpty(resultList)) {
        this.selectSimBuilder.lastSimId = resultList[0].simId;
      } else {
        this.selectSimBuilder.lastSimId = -1;
      }
      let spnList = AppStorage.Get<Array<string | Resource>>('spnList');
      if (spnList != undefined && this.selectSimBuilder.multiSimCardItems != undefined) {
        for (let index = 0; index < spnList.length; index++) {
          this.selectSimBuilder.multiSimCardItems[index].name =
            spnList[index] === '' ? $r('app.string.NoService') : spnList[index];
        }
      }
      this.mSelectSimIdDialog.open();
      DialogControllerManager.getInstance().addDialogController(this.mSelectSimIdDialog);
    });
  }

  onInitData(isVisible: boolean) {
    HiLog.i(TAG, `onInitData ${isVisible}`);
    if (!isVisible) {
      this.mSelectSimIdDialog.close();
      DialogControllerManager.getInstance().dialogControllerSet.clear();
    }
  }

  @Builder
  myRouter(name: string, params: Object) {
    if (name === 'Index') {
      Index();
    }
  }

  build() {
    Navigation(this.pathInfos) {
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
