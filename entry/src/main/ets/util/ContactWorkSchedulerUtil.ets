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
import { workScheduler } from '@kit.BackgroundTasksKit';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { BusinessError } from '@kit.BasicServicesKit';
import { CustomizedParams } from '../model/type';
import sim from '@ohos.telephony.sim';
import dotCommon, { addContactNumberParams } from './DotCommon';
import { backupAllLogs } from '../task/TaskService';
import { taskpool } from '@kit.ArkTS';


const TAG = 'ContactWorkSchedulerUtil';

const TIME_SECOND_IN_MILLIS: number = 1000;
const BACKUP_LOG_WORKER_ID = 2;


export class ContactWorkSchedulerUtil {
  public static instance: ContactWorkSchedulerUtil;

  public static getInstance(): ContactWorkSchedulerUtil {
    if (!ContactWorkSchedulerUtil.instance) {
      ContactWorkSchedulerUtil.instance = new ContactWorkSchedulerUtil();
    }
    return ContactWorkSchedulerUtil.instance;
  }

  public tryStartStatusReportWorker(): void {
    workScheduler.obtainAllWorks().then((workList) => {
      if (workList.length) {
        HiLog.w(TAG, `statusReportWorker already exist`);
        return;
      }

      const workInfo: workScheduler.WorkInfo = {
        workId: 1,
        bundleName: 'com.ohos.contacts',
        abilityName: 'ContactWorkSchedulerExtensionAbility',
        isRepeat: true,
        isPersisted: true,
        repeatCycleTime: TIME_SECOND_IN_MILLIS * 60 * 60 * 24 * 7, // one week
      }

      try {
        workScheduler.startWork(workInfo);
        HiLog.w(TAG, `startStatusReportWorker success`);
      } catch (error) {
        HiLog.e(TAG,
          `startStatusReportWorker failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
      }
    })
  }

  public getMaxSimCount(): number {
    return sim.getMaxSimCount();
  }

  public async tryBackupLogWorker(context: Context): Promise<void> {
    const workInfo: workScheduler.WorkInfo = {
      workId: BACKUP_LOG_WORKER_ID,
      bundleName: 'com.ohos.contacts',
      abilityName: 'BackupLogWorkSchedulerExtensionAbility',
      isRepeat: true,
      isPersisted: true,
      repeatCycleTime: TIME_SECOND_IN_MILLIS * 60 * 60 * 24 * 30 * 3, // 3 months
      networkType: workScheduler.NetworkType.NETWORK_TYPE_ANY,
      chargerType: workScheduler.ChargingType.CHARGING_PLUGGED_ANY,
      batteryStatus: workScheduler.BatteryStatus.BATTERY_STATUS_LOW_OR_OKAY,
      storageRequest: workScheduler.StorageRequest.STORAGE_LEVEL_LOW_OR_OKAY
    }
    const workInfos = await workScheduler.obtainAllWorks();
    if (workInfos.find((worker) => worker.workId === BACKUP_LOG_WORKER_ID) === undefined) {
      let backupLogTask = new taskpool.Task(backupAllLogs, context);
      taskpool.execute(backupLogTask);
    }
    try {
      workScheduler.startWork(workInfo);
      HiLog.i(TAG, `BackupLogWorker success`);
    } catch (error) {
      HiLog.e(TAG,
        `BackupLogWorker failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
    }

  }


  // sim 卡的使用情况
  async simUsedCount(): Promise<CustomizedParams> {
    let simCount: number = this.getMaxSimCount();
    let simStateOne: boolean = false;
    let simStateTwo: boolean = false;
    switch (simCount) {
      case 1:
        simStateOne = await sim.isSimActive(0) ?? false;
        break;
      case 2:
        simStateOne = await sim.isSimActive(0) ?? false;
        simStateTwo = await sim.isSimActive(1) ?? false;
        break;
    }
    HiLog.w(TAG, `simUsedConut simState ${simStateOne},${simStateTwo}  simCount ${simCount}`);
    if (simStateOne && simStateTwo) {
      addContactNumberParams.NUM = dotCommon.eventParam.TWO_CARD;
    } else if (simStateOne || simStateTwo) {
      addContactNumberParams.NUM = dotCommon.eventParam.ONE_CARD;
    } else {
      addContactNumberParams.NUM = dotCommon.eventParam.NO_CARD;
    }
    return addContactNumberParams
  }
}