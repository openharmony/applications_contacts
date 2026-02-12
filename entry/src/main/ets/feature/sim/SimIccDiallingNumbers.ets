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
import telephonySim from '@ohos.telephony.sim';
import { BusinessError } from '@ohos.base';
import sim from '@ohos.telephony.sim';
import { ContactInfo } from '../../model/bean/ContactInfo';
import { HiLog, sharedPreferencesUtils } from '../../../../../../common';
import emitter from '@ohos.events.emitter';
import { PhoneNumBean } from '../../model/bean/PhoneNumBean';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import EmitterConstant from '../../data/EmitterConstant';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { promptAction } from '@kit.ArkUI';
import { ResourceUtil } from '../../util/ResourceUtil';

const TAG = 'SimIccDiallingNumbers';
const simCONTACT = 'simContact';
const promptSimIccIds = 'promptSimIccIds';

class SimIccDiallingNumbers {
  public simIccIds: Array<string> = [];
  public contactData: Array<sim.DiallingNumbersInfo> = [];
  public refreshContactsEmitterId: number = 108;
  public cancelImport: boolean = false;
  public currentSimIccIds: Array<string> = [];
  public simSlots: Array<number> = [];
  public exportEmitterId: number = EmitterConstant.EXPORT_EMITTER_ID;
  public preSlotId: number = -1;

  public confirmExport(type?: boolean) {
    HiLog.w(TAG, 'confirmExport start!')
    if (type) {
      if (this.contactData.length > 0) {
        let exportEvent: emitter.InnerEvent = {
          eventId: EmitterConstant.SETTING_EXPORT_EMITTER_ID,
          priority: emitter.EventPriority.HIGH
        };
        let exportData: emitter.EventData = {
          data: {
            'percent': 0,
          }
        }
        emitter.emit(exportEvent, exportData);
        HiLog.w(TAG, 'addIccDiallingNumbersToContact start and data length is :' + this.contactData.length)

        this.addIccDiallingNumbersToContact(this.contactData, 0, true);
        this.saveSimContactMark();
      } else {
        const msg: Resource = $r('app.string.no_contact_sim_card');
        promptAction.showToast({
          message: msg,
          duration: 2000
        });
      }
    } else {
      let exportEvent: emitter.InnerEvent = {
        eventId: EmitterConstant.EXPORT_EMITTER_ID,
        priority: emitter.EventPriority.HIGH
      };
      let exportData: emitter.EventData = {
        data: {
          'percent': 0,
        }
      }
      emitter.emit(exportEvent, exportData);
      HiLog.w(TAG, 'addIccDiallingNumbersToContact start and data length is :' + this.contactData.length)

      this.addIccDiallingNumbersToContact(this.contactData, 0);
      this.saveSimContactMark();
    }

  }

  public saveSimContactMark() {
    sharedPreferencesUtils.saveToPreferences(simCONTACT,
      Array.from(new Set(this.currentSimIccIds.concat(this.simIccIds))));
  }

  public async savePromptSimIccIds() {
    const currentPromptSimIccIds = (await sharedPreferencesUtils
      .getFromPreferences(promptSimIccIds, [])) as Array<string>;
    sharedPreferencesUtils.saveToPreferences(promptSimIccIds, currentPromptSimIccIds.concat(this.simIccIds));
  }

  public async dealPromptSimIccIds(slotId: number) {
    let index: number = this.simSlots.findIndex((value: number) => value === slotId);
    HiLog.w(TAG, `dealPromptSimIccIds index:${index},this.simSlots=${this.simSlots?.length},${slotId}`);
    if (index !== -1) {
      const currentPromptSimIccIds = (await sharedPreferencesUtils
        .getFromPreferences(promptSimIccIds, [])) as Array<string>;
      HiLog.w(TAG,
        `dealPromptSimIccIds ,currentPromptSimIccIds=${currentPromptSimIccIds?.length},${(this.simSlots[index])}`);
      if (currentPromptSimIccIds.includes(this.simIccIds[index])) {
        HiLog.w(TAG, `dealPromptSimIccIds ,currentPromptSimIccIds include=${this.currentSimIccIds?.length},${this.simIccIds?.length},${this.simIccIds[index].slice(-1)}`);
        this.currentSimIccIds = this.currentSimIccIds.filter((value: string) => value !== this.simIccIds[index]);
        sharedPreferencesUtils.saveToPreferences(simCONTACT, this.currentSimIccIds);
        const newPromptSimIccIds: Array<string> = currentPromptSimIccIds
          .filter((value: string) => value !== this.simIccIds[index]);
        sharedPreferencesUtils.saveToPreferences(promptSimIccIds, newPromptSimIccIds);
        HiLog.w(TAG, `dealPromptSimIccIds ,currentPromptSimIccIds filter end=${newPromptSimIccIds?.length}`);
      }
    }
    this.simSlots = [];
    this.simIccIds = [];
  }

  public clearContactData() {
    this.contactData = [];
    this.preSlotId = -1;
  }

  public sureCancelImport() {
    this.cancelImport = true;
  }

  private async attempt
  (resolve: (value: telephonySim.IccAccountInfo | PromiseLike<telephonySim.IccAccountInfo>) => void,
    reject: (err: BusinessError) => void, times: number, slotId: number) {
    try {
      const res: telephonySim.IccAccountInfo = await sim.getSimAccountInfo(slotId)
      resolve(res);
    } catch (err) {
      if (times === 0) {
        reject(err);
      } else {
        times--;
        setTimeout(() => {
          this.attempt(resolve, reject, times, slotId);
        }, 1000)
      }
    }

  }

  private getSimAccountInfoMultipleTimes(slotId: number, times: number): Promise<telephonySim.IccAccountInfo> {
    return new Promise((
      resolve: (value: telephonySim.IccAccountInfo | PromiseLike<telephonySim.IccAccountInfo>) => void,
      reject: (err: BusinessError) => void) => {
      this.attempt(resolve, reject, times, slotId);
    })
  }

  private querySimNumbersBySlotId(slotId: number, onComplete?: (isHasNumbers: boolean) => void) {
    sim.queryIccDiallingNumbers(slotId, sim.ContactType.GENERAL_CONTACT)
      .then((data: Array<sim.DiallingNumbersInfo>) => {
        HiLog.w(TAG, `queryIccDiallingNumbers success, slotId->${slotId}length->${data.length}
              this.contactData.length ${this.contactData.length}`);
        if (data.length > 0) {
          this.contactData = this.preSlotId === slotId ? data : this.contactData.concat(data);
          this.preSlotId = slotId;
          HiLog.w(TAG, `this.contactData.length->${this.contactData.length}
                this.contactData[0].alphaTag-> ${StringUtil.maskSensitiveInfo(this.contactData[0]?.alphaTag)}
                this.contactData[1].alphaTag->${StringUtil.maskSensitiveInfo(this.contactData[1]?.alphaTag)}`);
          if (onComplete !== undefined) {
            HiLog.i(TAG, 'queryIccDiallingNumbers success onComplete');
            onComplete(true);
          }
        } else if (onComplete !== undefined) {
          onComplete(false);
        }
      })
      .catch((err: BusinessError) => {
        HiLog.e(TAG, `queryIccDiallingNumbers failed, promise: err->${err?.code},${err?.message}`);
        if (onComplete !== undefined) {
          HiLog.e(TAG, 'queryIccDiallingNumbers failed onComplete');
          onComplete(false); // 即使失败，也调用回调函数
        }
      });
  }

  public getNumbersBySlotId(slotId: number, type?: number | undefined,
    onComplete?: (isHasNumbers: boolean) => void): void {
    HiLog.w(TAG, `slotId:${slotId}`);
    const retryTimes: number = 5;
    this.getSimAccountInfoMultipleTimes(slotId, retryTimes)
      .then(async (data: telephonySim.IccAccountInfo) => {
        this.currentSimIccIds = (await sharedPreferencesUtils.getFromPreferences(simCONTACT, [])) as Array<string>;
        this.simIccIds.push(data.iccId);
        this.simSlots.push(slotId);
        if (type == 0) {
          HiLog.w(TAG, 'setting the SIM card entry');
          this.querySimNumbersBySlotId(slotId, onComplete);
        } else {
          HiLog.w(TAG, `application the SIM card entry ${this.currentSimIccIds.length},${data.iccId?.slice(-1)}`);
          if (!this.currentSimIccIds.includes(data.iccId)) {
            HiLog.w(TAG, `application the SIM card entry need import.`);
            this.querySimNumbersBySlotId(slotId, onComplete);
          } else if (onComplete !== undefined) {
            onComplete(false);
          }
        }
      })
  }

  public getcontactDataLength(slotId: number, callback: Function): void {
    const retryTimes: number = 5;
    this.getSimAccountInfoMultipleTimes(slotId, retryTimes)
      .then(async (data: telephonySim.IccAccountInfo) => {
        this.currentSimIccIds = (await sharedPreferencesUtils.getFromPreferences(simCONTACT, [])) as Array<string>;
        this.simIccIds.push(data.iccId);
        this.simSlots.push(slotId);
        sim.queryIccDiallingNumbers(slotId, sim.ContactType.GENERAL_CONTACT)
          .then((data: Array<sim.DiallingNumbersInfo>) => {
            HiLog.w(TAG, `getcontactDataLength success, slotId->${slotId}length->${data.length}`);
            if (data.length > 0) {
              callback(0);
            } else {
              callback(1);
            }
          })
          .catch((err: BusinessError) => {
            HiLog.e(TAG, `getcontactDataLength failed, promise: err->${err?.code},${err?.message}`);
            callback(1);
          });
      })
      .catch(
        (err: BusinessError) => {
          HiLog.w(TAG, `getcontactDataLength catch promise: err->${err?.code},${err?.message}`);
          callback(1);
        })
  }

  private splitDiallingNumbers(number: string): string[] {
    const numbers = number.split(';').map(n => n.trim()).filter(n => n !== '');
    return numbers;
  }

  private addIccDiallingNumbersToContact(data: Array<sim.DiallingNumbersInfo>, index: number, type?: boolean) {
    HiLog.w(TAG, 'addIccDiallingNumbersToContact index is :' + index);
    if (data === null || index < 0 || index >= data.length || data[index] === null) {
      HiLog.e(TAG, 'addIccDiallingNumbersToContact invalid input parameter');
      return;
    }
    let numberArr = this.splitDiallingNumbers(data[index].number);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('isHasContactByPhoneNumAndDisplayName',
        {
          displayName: data[index].alphaTag,
          phoneNumber: numberArr,
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        }, (isHasContact: boolean) => {
          if (!isHasContact) {
            const temp: ContactInfo = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0);
            temp.display_name = data[index].alphaTag;
            numberArr.forEach(number => {
              if (number !== '') {
                let phoneNumBean: PhoneNumBean = new PhoneNumBean('', '', '', '', '');
                phoneNumBean.id = '';
                phoneNumBean.num = number;
                phoneNumBean.numType = '1';
                // SIM卡不支持存储联系人手机号类型信息，此处设为默认类型
                phoneNumBean.homeArea = '';
                phoneNumBean.carriers = '';
                temp.phones.push(phoneNumBean);
              }
            });
            ContactsGlobalThisHelper.GetGlobalThis()
              .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('addContact',
              {
                context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
                contactInfoAfter: JSON.stringify(temp),
                operationScenario: 'import From Sim'
              }
              , () => {
                HiLog.w(TAG, 'addContact');
                if (type) {
                  this.dealAddContactProcess(data, index, true);
                } else {
                  this.dealAddContactProcess(data, index);
                }
              })
          } else {
            if (type) {
              this.dealAddContactProcess(data, index, true);
            } else {
              this.dealAddContactProcess(data, index);
            }
          }
        })
  }

  private dealAddContactProcess(data: Array<sim.DiallingNumbersInfo>, index: number, type?: true) {
    HiLog.w(TAG, 'dealAddContactProcess start and index is :' + index + 'data length = ' + data.length)
    index++;
    if (type) {
      let exportEvent: emitter.InnerEvent = {
        eventId: EmitterConstant.SETTING_EXPORT_EMITTER_ID,
        priority: emitter.EventPriority.HIGH
      };
      let exportData: emitter.EventData = {
        data: {
          'percent': index / data.length * 100,
          'number': index,
          'cancelImport': this.cancelImport
        }
      }
      if (index === data.length - 1) {
        const msg: string =
          ResourceUtil.getPluralStringByResource($r('app.plural.import_sim_contact_toast'), data.length);
        promptAction.showToast({
          message: msg,
          duration: 2000
        });
      }
      emitter.emit(exportEvent, exportData);
    } else {
      let exportEvent: emitter.InnerEvent = {
        eventId: EmitterConstant.EXPORT_EMITTER_ID,
        priority: emitter.EventPriority.HIGH
      };
      let exportData: emitter.EventData = {
        data: {
          'percent': index / data.length * 100,
          'number': index,
          'cancelImport': this.cancelImport
        }
      }
      if (index === data.length - 1) {
        const msg: string =
          ResourceUtil.getPluralStringByResource($r('app.plural.import_sim_contact_toast'), data.length);
        promptAction.showToast({
          message: msg,
          duration: 2000
        });
      }
      emitter.emit(exportEvent, exportData);
    }
    AppStorage.setOrCreate('importingSimContacts', true);
    if (this.cancelImport) {
      HiLog.w(TAG, 'dealAddContactProcess is cancel :' + index)
      this.cancelImport = false;
      this.contactData = [];
      this.preSlotId = -1;
      AppStorage.setOrCreate('importingSimContacts', false);
      let refreshContactsEvent: emitter.InnerEvent = {
        eventId: this.refreshContactsEmitterId,
        priority: emitter.EventPriority.HIGH
      };
      emitter.emit(refreshContactsEvent);
      return
    }
    if (index !== data.length) {
      if (type) {
        this.addIccDiallingNumbersToContact(data, index, true);
      } else {
        this.addIccDiallingNumbersToContact(data, index);
      }
    } else {
      HiLog.w(TAG, 'dealAddContactProcess is end!')
      this.contactData = [];
      this.preSlotId = -1;
      AppStorage.setOrCreate('importingSimContacts', false);
      let refreshContactsEvent: emitter.InnerEvent = {
        eventId: this.refreshContactsEmitterId,
        priority: emitter.EventPriority.HIGH
      };
      emitter.emit(refreshContactsEvent);

    }

  }
}

export default new SimIccDiallingNumbers()