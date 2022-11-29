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

import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { CallLogService } from '../../../../../../feature/call/src/main/ets/CallLogService';
import { CallLogRepository } from '../../../../../../feature/call/src/main/ets/repo/CallLogRepository';

const TAG = 'CallLogModel';

export default {
  /**
     * Obtains and caches all 2000 call records.
     *
     * @param {string} DAHelper Database path
     * @param {string} mergeRule  Call Record Type
     * @param {Object} callBack Call log data
     */
  getAllCalls: async function (actionData, callBack) {
    CallLogRepository.getInstance().findAll(actionData).then(result => {
      let resultData = {
        callLogList: [], missedList: []
      };
      if (ArrayUtil.isEmpty(result)) {
        HiLog.i(TAG, 'getAllCalls logMessage callLog resultSet is empty!');
        callBack(resultData);
        return;
      }
      resultData.callLogList = CallLogService.getInstance().mergeCallLogs(result);
      resultData.missedList = CallLogService.getInstance().mergeMissedCalls(result);
      callBack(resultData);
    });
  },
}