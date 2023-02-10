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

import BasicDataSource from './BasicDataSource';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';

const TAG = "DetailCallLogDataSource";

export default class DetailCallLogDataSource extends BasicDataSource {
    private detailCallLogList: object[] = [];

    public totalCount(): number {
        return this.detailCallLogList.length;
    }

    public getData(index: number): any {
        HiLog.i(TAG, "getData index is %s" + index);
        if (ArrayUtil.isEmpty(this.detailCallLogList) || index >= this.detailCallLogList.length) {
            HiLog.i(TAG, "getData detailCallLogList is empty");
            return null;
        } else {
            let callLog = this.detailCallLogList[index];
            let showTitle = false;
            if (index == 0) {
                showTitle = true;
            }
            let item = {
                callLog: callLog,
                showTitle: showTitle
            }
            return item;
        }
    }

    public refresh(callLog) {
        HiLog.i(TAG, ' refresh!');
        this.detailCallLogList = callLog;
        this.notifyDataReload();
    }
}