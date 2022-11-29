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
import BasicDataSource from '../bean/BasicDataSource';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';

const TAG = "CallRecordListDataSource";

export default class CallRecordListDataSource extends BasicDataSource {
    private callLogData: [] = [];

    public totalCount(): number {
        HiLog.i(TAG, "totalCount is %s" + JSON.stringify(this.callLogData.length));
        return this.callLogData.length;
    }

    public getData(index: number): any {
        if (ArrayUtil.isEmpty(this.callLogData) || index >= this.callLogData.length) {
            HiLog.w(TAG, "getData callLogData is empty");
            return null;
        } else {
            return this.callLogData[index];
        }
    }

    public refresh(callLogData) {
        HiLog.i(TAG, ' refresh!');
        this.callLogData = callLogData;
        this.notifyDataReload();
    }
}