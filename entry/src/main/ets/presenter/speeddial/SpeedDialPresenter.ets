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

import { BusinessError } from '@ohos.base';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { SpeedDialItem, VoiceMailItem } from '../../model/type/index';
import { queryAirPlaneStatus } from '../../model/AirplaneModel';
import { StringUtil } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/StringUtil';
import VoicemailManager from '../../feature/sim/VoicemailManager';
import prompt from '@ohos.promptAction';
import { ErrorStringUtil } from '../../util/ErrorStringUtil';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import common from '@ohos.app.ability.common';
import { EnterSingleSelectedMode } from '../../model/type/EnumUtil';
import { ResourceUtil } from '../../util/ResourceUtil';
import LooseObject from '../../model/type/LooseObject';
import { sharedPreferencesUtils } from '../../../../../../feature/call/oh_modules/common';
import { getHeadChar } from '../../util/UserPhoto';
import contact from '@ohos.contact';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { ContactsConstants } from '../../../../../../common/src/main/ets/ContactsConstants';

const TAG = 'SpeedDialPresenter  ';

export default class SpeedDialPresenter {
  private static instance: SpeedDialPresenter;
  public voicemailManager: VoicemailManager = new VoicemailManager();
  public pathInfos?: NavPathStack;
  public numbers: Array<number> = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  public slotId: number = 0;
  public noSimCardDialogController?: CustomDialogController
  public airplaneVoiceAlertDialogController?: CustomDialogController
  public sheetParams: Record<string, number | string> | undefined = undefined;

  public static getInstance(): SpeedDialPresenter {
    if (!SpeedDialPresenter.instance) {
      SpeedDialPresenter.instance = new SpeedDialPresenter();
    }
    return SpeedDialPresenter.instance;
  }

  getTitleString(title: Resource): string | undefined {
    HiLog.i(TAG, 'getTitleString');
    let context = ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.SpeedDialContextName);
    let titleString = ResourceUtil.resourceToString(title, context);
    return titleString;
  }

  initSpeedList(speedDials: string): Array<SpeedDialItem> {
    HiLog.i(TAG, 'initSpeedList');
    let speedDialObj: Record<string, SpeedDialItem> | null = null;
    if (speedDials && !StringUtil.isEmpty(speedDials)) {
      speedDialObj = JSON.parse(speedDials);
    }
    let speedDialList: Array<SpeedDialItem> = [];
    this.numbers.forEach((num: number) => {
      let obj: SpeedDialItem = {
        number: num,
        contactName: '',
        contactTelephone: ''
      };
      if (speedDialObj && speedDialObj[String(num)]) {
        obj = speedDialObj[String(num)];
        obj.number = num;
      }
      speedDialList.push(obj);
    });
    return speedDialList;
  }

  async initVoiceMailList(callback: Function) {
    HiLog.i(TAG, 'initVoiceMailList slotId: ' + this.slotId);
    let arr: Array<VoiceMailItem> = [];
    let serviceProvider: VoiceMailItem = {
      voiceMailItemName: $r('app.string.service_provider'),
      voiceMailItemValue: '',
      placeholder: $r('app.string.my_carrier')
    }
    let voicemailNum: VoiceMailItem = {
      voiceMailItemName: $r('app.string.voicemail_number'),
      voiceMailItemValue: '',
      placeholder: $r('app.string.not_set')
    }
    let number: string = await this.voicemailManager.getVoicemailNumber(this.slotId);
    voicemailNum.voiceMailItemValue = number;
    arr.push(serviceProvider, voicemailNum);
    callback(arr);
  }

  speedDialToContact(index: number, isFromDailBtn?: boolean) {
    HiLog.i(TAG, 'speedDialToContact' + index.toString(),);
    let params: Record<string, number | string> = {}
      if (isFromDailBtn) {
        params = {
          'fromSpeedDial': EnterSingleSelectedMode.SpeedDial, 'selectedNumber': String(index)
        };
      } else {
        params = {
          'fromSpeedDial': EnterSingleSelectedMode.SpeedDial, 'selectedNumber': String(index + 1)
        };
      }
    this.sheetParams = params;
  }

  clickVoiceMailEvent() {
    HiLog.i(TAG, 'clickVoiceMailEvent');
    let haveSimCard: boolean = AppStorage.get('haveSimCard') as boolean;
    if (!haveSimCard) {
      HiLog.i(TAG, 'have no sim card');
      this.noSimCardDialogController?.open();
      DialogControllerManager.getInstance().addDialogController(this.noSimCardDialogController);
      return;
    }
    let context = ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.SpeedDialContextName);
    queryAirPlaneStatus(context, (airplaneOn: boolean) => {
      if (airplaneOn) {
        HiLog.i(TAG, 'airplane on');
        this.airplaneVoiceAlertDialogController?.open();
        DialogControllerManager.getInstance().addDialogController(this.airplaneVoiceAlertDialogController);
      } else {
        this.setVoiceMail();
      }
    });
  }

  async setVoiceMail() {
    HiLog.i(TAG, 'setVoiceMail');
    let haveMultiSimCard = AppStorage.get('haveMultiSimCard') as boolean;
    if (haveMultiSimCard) {
      let number1: string = await this.voicemailManager.getVoicemailNumber(0);
      let number2: string = await this.voicemailManager.getVoicemailNumber(1);
      if (StringUtil.isEmpty(number1) && StringUtil.isEmpty(number2)) {
        HiLog.i(TAG, 'no sim card has voicemail set up');
        let context = ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.SpeedDialContextName);
        context?.terminateSelf()
          .then(() => {
            HiLog.i(TAG, 'terminateSelf Operation succeeded: ');
          })
          .catch((error: BusinessError) => {
            HiLog.e(TAG, 'Operation failed. Cause: %s', error?.message);
          });
      } else {
        HiLog.i(TAG, '1 card has voicemail set up');
        if (!StringUtil.isEmpty(number1)) {
          this.pushToVoicemail(0);
        } else {
          this.pushToVoicemail(1);
        }
      }
    } else {
      let defaultSlot: number = AppStorage.get('defaultSlot') as number;
      HiLog.i(TAG, 'default slot: ' + defaultSlot);
      this.pushToVoicemail(defaultSlot);
    }
  }

  pushToVoicemail(slotId: number) {
    HiLog.i(TAG, 'pushToVoicemail slotId: ' + slotId);
    let param: Record<string, number> = {
      'slotId': slotId
    };
    AppStorage.setOrCreate('toVoicemailFromSetting', false);
    this.pathInfos?.pushPathByName('VoiceMail', param);
  }

  confirmVoiceMail(value: string, callback: (value: boolean) => void) {
    HiLog.i(TAG, 'confirmVoiceMail slotId: ' + this.slotId);
    let name: string = 'myCarrier';
    this.voicemailManager.setVoicemailInfo(this.slotId, name, value, (data: number) => {
      if (data === 0) {
        HiLog.i(TAG, 'setVoicemailInfo success');
        callback(true);
      } else {
        HiLog.i(TAG, 'setVoicemailInfo error code: ' + data);
        let errorCode: string = String(data);
        HiLog.i(TAG, 'setVoicemailInfo error errorCode: ' + errorCode);
        try {
          prompt.showToast({
            message: ErrorStringUtil.getErrorMsg(errorCode),
            duration: 2000
          })
        } catch (err) {
          HiLog.e(TAG, 'confirmVoiceMail, prompt.showToast err: ' + err?.message + ', stack: ' + err?.stack);
        }
        callback(false);
      }
    });
  }

  public async parseContactForResult(data: contact.Contact[], type: string): Promise<void> {
    if (!data || data.length === 0) {
      return;
    } else {
      let item = data[0];
      let number = '';
      if (item.phoneNumbers) {
        number = item.phoneNumbers[0].phoneNumber;
      }
      let obj: SpeedDialItem = {
        nameSuffix: getHeadChar(item.name?.fullName),
        namePrefix: '',
        portraitColor: '',
        contactTelephone: number,
        contactName: item.name?.fullName,
        portraitPath: '',
        contactId: item.key,
        number: Number(this.sheetParams?.selectedNumber)
      }
      if (type === ContactsConstants.VOICE_MAIL) {
        AppStorage.setOrCreate('voicemailNumberString', String(obj.contactTelephone));
      } else {
        AppStorage.setOrCreate('speedDialFromContact', obj);
      }
      let speedString: string = await sharedPreferencesUtils.getFromPreferences('speedDialObjString', '') as string;
      let speedObj: Record<string, SpeedDialItem> = {};
      if (!speedString || StringUtil.isEmpty(speedString)) {
        if (this.sheetParams?.selectedNumber) {
          speedObj[this.sheetParams?.selectedNumber] = obj;
        }
      } else {
        try {
          speedObj = JSON.parse(speedString) as Record<string, SpeedDialItem>;
          if (this.sheetParams?.selectedNumber) {
            speedObj[this.sheetParams?.selectedNumber] = obj;
          }
        } catch (error) {
          HiLog.e(TAG, (error as BusinessError)?.message);
        }
      }
      sharedPreferencesUtils.saveToPreferences('speedDialObjString', JSON.stringify(speedObj));
    }
  }
}