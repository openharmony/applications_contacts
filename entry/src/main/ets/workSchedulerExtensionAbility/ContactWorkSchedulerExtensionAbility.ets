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
import { WorkSchedulerExtensionAbility, workScheduler } from '@kit.BackgroundTasksKit';
import dotCommon from '../util/DotCommon';
import DotUtil from '../util/DotUtil';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { CustomizedParams } from '../model/type';
import { ContactWorkSchedulerUtil } from '../util/ContactWorkSchedulerUtil';
import { hiSysEvent } from '@kit.PerformanceAnalysisKit';

const TAG = 'ContactWorkSchedulerExtensionAbility';


export default class ContactWorkSchedulerExtensionAbility extends WorkSchedulerExtensionAbility {
  // 延迟任务开始回调
  onWorkStart(workInfo: workScheduler.WorkInfo) {
    HiLog.w(TAG, `onWorkStart, workInfo = {bundleName: ${workInfo?.bundleName}, abilityName: ${workInfo?.abilityName},
     workId: ${workInfo?.workId}}`);
    // sim卡的个数
    ContactWorkSchedulerUtil.getInstance().simUsedCount().then((value: CustomizedParams) => {
      DotUtil.getInstance().contactDot(value, dotCommon.statusEventName.SIM_NUM_EVENT, hiSysEvent.EventType.STATISTIC);
    })
  }

  // 延迟任务结束回调
  onWorkStop(workInfo: workScheduler.WorkInfo) {
    HiLog.w(TAG, `onWorkStop, workInfo = {bundleName: ${workInfo?.bundleName}, abilityName: ${workInfo?.abilityName},
     workId: ${workInfo?.workId}}`);
  }
}