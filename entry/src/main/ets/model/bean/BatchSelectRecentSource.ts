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

const TAG = "BatchSelectRecentSource";

export default class BatchSelectRecentSource extends BasicDataSource {
    private callLogs: { [key: string]: any }[] = [];

    public totalCount(): number {
        return this.callLogs.length;
    }

    public getData(index: number): any {
        HiLog.i(TAG, "getData index is " + JSON.stringify(index));
        if (ArrayUtil.isEmpty(this.callLogs) || index >= this.callLogs.length) {
            HiLog.i(TAG, "getData calllog is empty");
            return null;
        } else {
            let showDivifer: boolean = !ArrayUtil.isEmpty(this.callLogs) && (index != (this.callLogs.length - 1));

            return {
                showDivifer: showDivifer,
                index: index,
                calllog: this.callLogs[index]
            };
        }
    }

    public refresh(callLogTemp: any[]) {
        HiLog.i(TAG, ' refresh!');
        this.callLogs = callLogTemp;
        this.notifyDataReload();
    }

    public refreshSpecificOne(index: number, checked: boolean) {
        this.callLogs[index].checked = checked;
        this.notifyDataChange(index);
    }
}