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
import telephonySim from '@ohos.telephony.sim';
import { HiLog } from '../../../../../../common';
import radio from '@ohos.telephony.radio';
import observer from '@ohos.telephony.observer';
import sim from '@ohos.telephony.sim';
import { StringUtil } from '../../../../../../feature/call/oh_modules/common/src/main/ets/util/StringUtil';
import { BusinessError } from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import { CommonEventUtil } from '../../../../../../common/src/main/ets/util/CommonEventUtil';
import { CommonEventConstants } from '../../../../../../common/src/main/ets/CommonEventConstants';
import simCardState from './SimCardState';
import OperaNameStruct from './operaNameStruct';
import CardInfoStruct from './operaNameStruct';

// 定义订阅者，用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
let subscriber: commonEventManager.CommonEventSubscriber;
const TAG = 'SimOpName'
// 订阅者信息
let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: ['usual.event.SPN_INFO_CHANGED0', 'usual.event.SPN_INFO_CHANGED1']
};

class SimOpName {
  public spnList: Array<string | Resource> = [];
  public subscriber: commonEventManager.CommonEventSubscriber | null = null;
  public preRegState: number[] = [-1, -1];
  public operatorRes_0: OperaNameStruct = new OperaNameStruct();
  public operatorRes_1: OperaNameStruct = new OperaNameStruct();

  constructor() {
    for (let index = 0; index < telephonySim.getMaxSimCount(); index++) {
      this.spnList[index] = '';
    }
  }

  /**
   * recycle
   */
  public unsubscribeSpnObserver() {
    try {
      observer.off('iccAccountInfoChange');
      observer.off('networkStateChange');
    } catch (err) {
      HiLog.e(TAG, 'unsubscribeSpnObserver, failed: ' + err?.message + ', stack: ' + err?.stack);
    }
    if (this.subscriber !== null)
    CommonEventUtil.unsubscribe(this.subscriber);
  }

  public initSpnObserver() {
    try {
      for (let index = 0; index < telephonySim.getMaxSimCount(); index++) {
        observer.on('iccAccountInfoChange', () => {
          HiLog.w(TAG, 'iccAccountInfo change');
          this.querySimName(index)
        });
        observer.on('networkStateChange', { slotId: index }, data => {
          if (!data) {
            HiLog.e(TAG, 'there is something wrong with networkState');
            return
          } else {
            HiLog.w(TAG, 'observer ON data time:' + (new Date()).valueOf());
            if (data.regState !== this.preRegState[index]) {
              this.preRegState[index] = data.regState;
              this.querySimName(index)
            }
          }
        });
      }
      // 创建订阅者回调
      CommonEventUtil.registerSubscriber(CommonEventConstants.COMMON_EVENT_SPN_INFO_CHANGED).then((subscribeInfo:commonEventManager.CommonEventSubscriber) => {
        HiLog.e(TAG, 'creating subscriber end');
        this.subscriber = subscribeInfo;
        // 订阅公共事件回调
        if (this.subscriber !== null) {
          CommonEventUtil.subscribe(this.subscriber, CommonEventConstants.COMMON_EVENT_SPN_INFO_CHANGED, () => {
            for (let index = 0; index < telephonySim.getMaxSimCount(); index++) {
              HiLog.i(TAG, `Recevie SPN_INFO_CHANGED, update sim name of SIM[${index} Time:${(new Date()).valueOf()}`);
              this.querySimName(index);
            }
          })
        } else {
          HiLog.e(TAG, 'Need create subscriber');
        }
      })
      // 订阅默认拨号卡变更广播
      CommonEventUtil.registerSubscriber(CommonEventConstants.COMMON_EVENT_SIM_CARD_DEFAULT_VOICE_SUBSCRIPTION_CHANGED)
        .then((subscribeInfo: commonEventManager.CommonEventSubscriber) => {
          HiLog.e(TAG, 'creating subscriber end');
          this.subscriber = subscribeInfo;
          // 订阅公共事件回调
          if (this.subscriber !== null) {
            CommonEventUtil.subscribe(this.subscriber,
              CommonEventConstants.COMMON_EVENT_SIM_CARD_DEFAULT_VOICE_SUBSCRIPTION_CHANGED, () => {
                HiLog.i(TAG, 'default sim card change event received.')
                simCardState.getSimCardState();
              })
          } else {
            HiLog.e(TAG, 'Need create subscriber');
          }
        })
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, `Failed to initSpnObserver. Code: ${err?.code}, message:  ${err?.message}`);
    }
  }

  // 订阅公共事件回调
  private handleSpnChangedSubscribeCB: (err: BusinessError, data: commonEventManager.CommonEventData) => void =
    (err: BusinessError, data: commonEventManager.CommonEventData) => {
    HiLog.i(TAG, `commonEvent subscribe: event: ${data?.event}, bundleName: ${data?.bundleName}, code: ${data?.code}`);
    if (data) {
      if (typeof data.parameters !== 'undefined' && data.parameters !== null) {
        if (data.parameters?.CUR_SLOT_ID == 0) {
          this.operatorRes_0 = data.parameters as CardInfoStruct;
          this.querySimName(0)
        } else if (data.parameters?.CUR_SLOT_ID == 1) {
          this.operatorRes_1 = data.parameters as CardInfoStruct;
          this.querySimName(1)
        }
      }
    } else {
      HiLog.i(TAG, 'commonEvent subscribe err:' + err?.message + ', stack: ' + err?.stack);
    }
  }

  // 创建订阅者回调
  private createCB: (err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) => void =
    (err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
      if (!err) {
        HiLog.i(TAG, `Succeeded in creating subscriber.`);
        subscriber = commonEventSubscriber;
        // 订阅公共事件
        try {
          commonEventManager.subscribe(subscriber, this.handleSpnChangedSubscribeCB);
        } catch (error) {
          let err: BusinessError = error as BusinessError;
          HiLog.e(TAG, `Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
        }
      } else {
        HiLog.e(TAG, `Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
      }
  }

  /**
   * Registered subscribers
   */
  public async registerSubscriber() {
    // 创建订阅者
    try {
      commonEventManager.createSubscriber(subscribeInfo, this.createCB);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, `Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public unInitSpnObserver() {
    try {
      HiLog.w(TAG, `unInitSpnObserver`);
      observer.off('networkStateChange');
    } catch (err) {
      HiLog.e(TAG, `unInitSpnObserver err: ${err.message}`);
    }
  }

  // 取消订阅公共事件回调
  private unsubscribeCB(err: BusinessError) {
    if (err) {
      HiLog.e(TAG, `Failed to unsubscribe. Code is ${err.code}, message is ${err.message}`);
    } else {
      HiLog.i(TAG, `Succeeded in unsubscribing.`);
    }
  }

  /**
   * unsubscribe
   */
  public unsubscribe() {
    try {
      commonEventManager.unsubscribe(subscriber, this.unsubscribeCB);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, `Failed to unsubscribe. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public querySimName(simId: number) {
    sim.getShowName(simId, (err: BusinessError<void>, value: string) => {
      if (err) {
        HiLog.e(TAG, 'querySimName Sim ' + simId + ' error:' + err?.message + ' time:' + (new Date()).valueOf());
        this.dealOperatorName(simId);
      } else {
        HiLog.w(TAG, 'querySimName Sim ' + simId + ' data:' + value + ' time:' + (new Date()).valueOf());
        if (value === 'null' || StringUtil.isEmpty(value)) {
          this.dealOperatorName(simId);
        } else {
          this.notifySimName(simId, value);
        }
      }
    })
  }

  dealOperatorName(simId: number) {
    HiLog.i(TAG, 'dealOperatorName start');
    const slotId = simId;
    let operatorRes: OperaNameStruct = new OperaNameStruct();
    if (slotId == 0) {
      operatorRes = this.operatorRes_0;
    } else if (slotId == 1) {
      operatorRes = this.operatorRes_1;
    }
    if (slotId < 0 || slotId >= this.spnList.length) {
      HiLog.w(TAG, 'updateOperatorName slotId is invalid');
      return;
    }
    if (operatorRes.CUR_PLMN_SHOW && !StringUtil.isEmpty(operatorRes.CUR_PLMN)) {
      this.spnList[slotId] = operatorRes.CUR_PLMN;
    } else {
      this.spnList[slotId] = '';
    }
    if (operatorRes.CUR_SPN_SHOW && !StringUtil.isEmpty(operatorRes.CUR_SPN)) {
      if (StringUtil.isEmpty(this.spnList[slotId]?.toString())) {
        this.spnList[slotId] = operatorRes.CUR_SPN;
      } else {
        this.spnList[slotId] = this.spnList[slotId] + '|' + operatorRes.CUR_SPN;
      }
    }

    if (!this.spnList[simId]) {
      this.dealDefaultSimName(simId);
    } else {
      this.notifySimName(slotId, this.spnList[slotId]);
    }
    HiLog.i(TAG, 'updateOperatorName end');
  }

  public notifySimName(slot: number, spn: string | Resource) {
    HiLog.w(TAG, `notify Sim${slot} Name:${spn} Time:${(new Date()).valueOf()}`);
    this.spnList[slot] = spn;
    HiLog.w(TAG, `sim name is ${this.spnList}`)
    AppStorage.SetOrCreate<Array<string | Resource>>('spnList', this.spnList);
  }

  dealDefaultSimName(simId: number) {
    radio.getOperatorName(simId, (error, data) => {
      if (error) {
        HiLog.e(TAG, 'dealDefaultSimName Sim ' + simId + ' error: ' + error?.message + ', stack: ' + error?.stack);
        if (error === undefined) {
          // Error code undefined is returned, indicating that no service is available.
          this.notifySimName(simId, $r('app.string.NoService'));
        }
      } else {
        HiLog.w(TAG, 'dealDefaultSimName Sim ' + simId + ' time:' + (new Date()).valueOf());
        if (!data) {
          // When there is no network, the carrier name is empty and no service is displayed.
          this.notifySimName(simId, $r('app.string.NoService'));
        } else {
          this.notifySimName(simId, data);
        }
      }
    })
  }
}

export default new SimOpName();