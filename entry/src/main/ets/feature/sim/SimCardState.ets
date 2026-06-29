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
import observer from '@ohos.telephony.observer';
import telephonySim from '@ohos.telephony.sim';
import { HiLog } from '../../../../../../common';
import simIccDiallingNumbers from './SimIccDiallingNumbers';
import telephony from '@ohos.telephony.data';
import DotUtil from '../../util/DotUtil';
import dotCommon, { faultContactParams } from '../../util/DotCommon';
import { BusinessError } from '@ohos.base';
import { CountryIdUtil } from '../../../../../../common/src/main/ets/util/CountryIdUtil';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../data/EmitterConstant';
import { SimCardType } from '../../data/Constants';
import sim from '@ohos.telephony.sim';

export const simId_DEFAULT: number = -1;

export const simId_ONE: number = 0;

export const simId_TWO: number = 1;

const TAG = 'SimCardState';

class SimCardState {
  public mListener: () => void = () => {
  };
  public mSimStateArray: Array<boolean> = [false, false];
  public simCardTypes: Array<SimCardType> = [SimCardType.PSIM, SimCardType.PSIM];
  public mSimIndexArray: Array<number> = [-1, -1];
  public haveSimCard: boolean = false;
  public haveMultiSimCard: boolean = false;
  public cardSlotsNumber: number = 2;
  private processedCount: number = 0;  // 已处理sim数量
  private isEmit: boolean = false;  // 是否发送sim卡导入弹窗通知
  private timeoutID: number = -1;

  /**
   * isSimActive
   *
   * @param slotId the sim slot id number
   * @return boolean the sim is ready or not
   */
  public isSimActive(slotId: number): boolean {
    return this.mSimStateArray[slotId];
  }

  /*
   * Initialization is required only when callback is required. Callback is required to ensure data accuracy
   * and timeliness.
   */
  public init(addSimStateListener: boolean = true) {
    try {
      HiLog.w(TAG, `SimCardState, init. time: ${(new Date()).valueOf()}, addSimStateListener: ${addSimStateListener}`);
      if (addSimStateListener) {
        this.addSimChangeListener();
      }
      this.getSimCardState();
      AppStorage.setOrCreate('simCardStates', this.mSimStateArray);
      AppStorage.setOrCreate('simCardTypes', this.simCardTypes);
      AppStorage.setOrCreate('simCardIndexes', this.mSimIndexArray);
      let countryId = CountryIdUtil.getCountryId();
      AppStorage.setOrCreate('country', countryId);
    } catch (error) {
      HiLog.w(TAG, 'SimCardState, get sim state error.')
    }
  }

  public unInit() {
    HiLog.i(TAG, 'unInit...');
    this.mSimStateArray = [false, false];
    this.simCardTypes = [SimCardType.PSIM, SimCardType.PSIM];
    this.mSimIndexArray = [-1, -1];
    this.haveSimCard = false;
    this.haveMultiSimCard = false;
    this.cardSlotsNumber = 2;
    this.removeSimChangeListener();
  }
  public removeSimChangeListener() {
    HiLog.i(TAG, 'removeSimChangeListener ! ');
    try {
      observer.off('simStateChange');
      observer.off('iccAccountInfoChange');
    } catch (error) {
      HiLog.w(TAG, `removeSimChangeListener error:${error?.code},${error?.message}`)
    }
  }

  public setListener(listener: () => void) {
    this.mListener = listener;
  }

  private addSimChangeListener() {
    try {
      const maxSimCount = telephonySim.getMaxSimCount();
      HiLog.e(TAG, `maxSimCount ${maxSimCount}`);
      for (let i = 0; i < maxSimCount; i++) {
        observer.on('simStateChange', {
          slotId: i
        }, value => {
          let simState = value?.state;
          HiLog.w(TAG, `simState is ${simState}`);
          if (simState === telephonySim.SimState.SIM_STATE_NOT_PRESENT) {
            // 拔卡还原状态
            if (this.timeoutID > -1) {
              clearTimeout(this.timeoutID);
              this.timeoutID = -1;
            }
            this.processedCount = 0;
            this.isEmit = false;
          }
          if (simState === telephonySim.SimState.SIM_STATE_READY) {
            // 插卡遍历双卡槽
            if (this.timeoutID > -1) {
              HiLog.w(TAG, 'observer simStateChange has been triggered');
              return;
            }
            this.timeoutID = setTimeout(() => {
              for (let j = 0; j < maxSimCount; j++) {
                telephonySim.isSimActive(j, (err, value) => {
                  if (err) {
                    HiLog.e(TAG, `isSimActive simStateChange, ${j} error: ${err?.code},${err?.message}`);
                    this.processedCount++;
                    if (this.processedCount === maxSimCount && this.isEmit) {
                      this.emitAndReset();
                    }
                  } else {
                    HiLog.i(TAG, `isSimActive simStateChange, ${j} value: ${value}`);
                    this.setSimInfo2SlotId(j);
                    if (value) {
                      simIccDiallingNumbers.getNumbersBySlotId(j, 1, (isHasNumbers) => {
                        this.processedCount++;
                        if (isHasNumbers) {
                          this.isEmit = true;
                        }
                        if (this.processedCount === maxSimCount && this.isEmit) {
                          // 所有SIM卡数据处理完毕，触发通知
                          HiLog.i(TAG, 'getNumbers onComplete emitter');
                          this.emitAndReset();
                        }
                      });
                    } else {
                      this.processedCount++;
                      if (this.processedCount === maxSimCount && this.isEmit) {
                        this.emitAndReset();
                      }
                    }
                  }
                });
              }
            }, 2000);
          } else {
            simIccDiallingNumbers.dealPromptSimIccIds(i)
          }
          AppStorage.setOrCreate('simStateUpdated', new Date().valueOf());
          // sim卡状态变化获取国家码
          let countryId = CountryIdUtil.getCountryId();
          AppStorage.setOrCreate('country', countryId);
        });
      }
    } catch (error) {
      // 联系人故障打点-SIM卡状态变化异常
      faultContactParams.FAULT_INFO = error?.message;
      DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.SIM_STATE_ERROR);
      HiLog.e(TAG, `addSimChangeListener err: ${error?.message}`);
    }
    observer.on('iccAccountInfoChange', () => {
      HiLog.w(TAG, 'iccAccountInfo change');
      this.getSimCardState();
    });
  }

  private emitAndReset() {
    let exportEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EXPORT_EMITTER_ID,
      priority: emitter.EventPriority.HIGH
    };
    emitter.emit(exportEvent);
    if (this.timeoutID > -1) {
      clearTimeout(this.timeoutID);
      this.timeoutID = -1;
    }
    this.processedCount = 0;
    this.isEmit = false;
  }

  public getSimCardState() {
    this.cardSlotsNumber = telephonySim.getMaxSimCount();
    for (let slotIndex = 0; slotIndex < telephonySim.getMaxSimCount(); slotIndex++) {
      telephonySim.isSimActive(slotIndex, (err, value) => {
        if (err) {
          HiLog.e(TAG, `getSimCardState, ${slotIndex} error: ${err?.code},${err?.message}`);
        } else {
          HiLog.w(TAG, `isSimActive getSimCardState, ${slotIndex} value: ${value}`);
          this.setSimInfo2SlotId(slotIndex);
          this.parseSimCardStateForSlot(slotIndex, value);
        }
      });
    }
  }

  private parseSimCardStateForSlot(slotId: number, value: boolean) {
    HiLog.w(TAG, `current sim card status: ${this.mSimStateArray[slotId]}`);
    let changed: boolean = (value != this.mSimStateArray[slotId]);
    if (!changed) {
      // Set the default card number at the last time of obtaining the SIM card cycle.
      HiLog.w(TAG, `cardSlotsNumber: ${this.cardSlotsNumber}`);
      this.cardSlotsNumber--;
      if (this.cardSlotsNumber === 0) {
        this.setDefaultSlot();
      }
      return;
    }
    this.mSimStateArray[slotId] = value;
    this.haveSimCard = this.isSimActive(simId_ONE) || this.isSimActive(simId_TWO);
    this.haveMultiSimCard = this.isSimActive(simId_ONE) && this.isSimActive(simId_TWO);
    AppStorage.SetOrCreate<boolean>('haveMultiSimCard', this.haveMultiSimCard);
    AppStorage.SetOrCreate<boolean>('haveSimCard', this.haveSimCard);
    HiLog.w(TAG, `parseSimCardStateForSlot sim ${slotId}} state ${value}}, haveSimCard: ` + this.haveSimCard +
      ', haveMultiSimCard: ' + this.haveMultiSimCard);
    // Set the default card number at the last time of obtaining the SIM card cycle.
    this.cardSlotsNumber--;
    if (this.cardSlotsNumber === 0) {
      this.setDefaultSlot();
    }
    if (this.mListener) {
      this.mListener();
    }
  }

  private getDefaultCellularDataSlotId() {
    // Obtaining the Mobile Data Card Number When No Card Is Available
    telephony.getDefaultCellularDataSlotId((err, slot: number) => {
      if (err) {
        HiLog.e(TAG, `getDefaultCellularDataSlotId, ${slot} error: ${err?.code},${err?.message}`);
        AppStorage.SetOrCreate<number>('defaultSlot', simId_DEFAULT);
      } else {
        HiLog.w(TAG, `getDefaultCellularDataSlotId,  ${slot} `);
        AppStorage.SetOrCreate<number>('defaultSlot', slot);
      }
    })
  }

  public setDefaultSlot() {
    // 设置默认卡号
    if (this.haveSimCard) {
      if (!this.haveMultiSimCard) {
        if (this.isSimActive(simId_ONE)) {
          HiLog.w(TAG, `isSimActive simId_ONE, ${simId_ONE}`);
          AppStorage.SetOrCreate<number>('defaultSlot', simId_ONE);
        } else {
          HiLog.w(TAG, `isSimActive simId_TWO, ${simId_TWO}`);
          AppStorage.SetOrCreate<number>('defaultSlot', simId_TWO);
        }
      } else {
        // 双卡情况下 飞行模式需要获取当前默认移动蜂窝数据卡作为默认卡
        // 非飞行模式下 如果设置默认卡号就用默认卡号 未设置默认卡号传-1  后续用户自己选择卡号
        let isAirPlaneMode: boolean | undefined = AppStorage.get<boolean>('isAirplaneMode');
        if (isAirPlaneMode) {
          HiLog.w(TAG, `get mobile card in airplaneMode`);
          this.getDefaultCellularDataSlotId();
        } else {
          telephonySim.getDefaultVoiceSlotId((err, slot: number) => {
            if (err) {
              HiLog.e(TAG, `getDefaultVoiceSlotId, ${slot} error: ${err?.code},${err?.message}`);
              AppStorage.SetOrCreate<number>('defaultSlot', simId_DEFAULT);
            } else {
              HiLog.w(TAG, `getDefaultVoiceSlotId,  ${slot} `);
              AppStorage.SetOrCreate<number>('defaultSlot', slot);
            }
          })
        }
      }
    } else {
      this.getDefaultCellularDataSlotId();
    }
  }

  async getSimLabelSync(slotId: number): Promise<sim.SimLabel | null> {
    try {
      return await sim.getSimLabelSync(slotId);
    } catch (err) {
      HiLog.e(TAG, `getSimLabelSync failed, slotId: ${slotId}, errCode: ${err?.code}, errMsg: ${err?.message}`);
      return null;
    }
  }

  private setSimInfo2SlotId(slotId: number): void {
    this.getSimLabelSync(slotId).then((simLabel) => {
      if (simLabel) {
        this.simCardTypes[slotId] = simLabel.simType === sim.SimType.ESIM ? SimCardType.ESIM : SimCardType.PSIM;
        this.mSimIndexArray[slotId] = simLabel.index;
        HiLog.i(TAG, `setSimInfoBySlotId: ${slotId}, simType: ${this.simCardTypes[slotId]}, index: ${simLabel.index}`);
      } else {
        this.mSimStateArray[slotId] = false;
        this.simCardTypes[slotId] = SimCardType.PSIM;
        this.mSimIndexArray[slotId] = -1;
        HiLog.e(TAG, `getSimLabelSync EMPTY, reset sim info.`);
      }
    }).catch((err: BusinessError) => {
      this.mSimStateArray[slotId] = false;
      this.simCardTypes[slotId] = SimCardType.PSIM;
      this.mSimIndexArray[slotId] = -1;
      HiLog.e(TAG, `getSimLabelSync failed, slotId: ${slotId}, errCode: ${err?.code}, errMsg: ${err?.message}`);
    });
  }
}

export default new SimCardState();