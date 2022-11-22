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

const TAG = "BatchSelectContactSource";

export default class BatchSelectContactSource extends BasicDataSource {
    private contactList: any[] = [];
    private contactsCount: number = 0;

    public totalCount(): number {
        HiLog.i(TAG, "totalCount is %s", this.contactList.length);
        return this.contactList.length;
    }

    public getData(index: number): any {
        if (ArrayUtil.isEmpty(this.contactList) || index >= this.contactList.length) {
            HiLog.i(TAG, "getData contactlist is empty");
            return null;
        } else {
            let contact: any = this.contactList[index];
            let preContact: any = this.contactList[index - 1];
            let showIndex: boolean = (index == 0 || !(contact.namePrefix === preContact.namePrefix));
            let showDivifer: boolean = false;
            if (index < this.contactList.length - 1) {
                let nextContact: any = this.contactList[index + 1];
                showDivifer = (contact.namePrefix === nextContact.namePrefix);
            } else {
                showDivifer = false;
            }
            return {
                showIndex: showIndex,
                showDivifer: showDivifer,
                contact: contact,
                index: index
            };
        }
    }

    public refresh(contactList: any[]) {
        HiLog.i(TAG, ' refresh!');
        this.contactList = contactList;
        this.notifyDataReload();
    }
}