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
import { ContactVo } from '../bean/ContactVo';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';

const TAG = "ContactListDataSource";

export default class ContactListDataSource extends BasicDataSource {
    private contactList: ContactVo[] = [];
    private isShow: boolean;
    private isDataReload: boolean;

    public totalCount(): number {
        return this.contactList.length;
    }

    public getData(index: number): any {
        if (ArrayUtil.isEmpty(this.contactList) || index >= this.contactList.length) {
            HiLog.i(TAG, "getData contactlist is empty");
            return null;
        } else {
            let contact: ContactVo = this.contactList[index];
            let preContact: ContactVo = this.contactList[index - 1];
            let showIndex: boolean = (index == 0 || !(contact.namePrefix == preContact.namePrefix));
            let showDivifer: boolean = false;
            if (index < this.contactList.length - 1) {
                let nextContact: ContactVo = this.contactList[index + 1];
                showDivifer = (contact.namePrefix == nextContact.namePrefix);
            } else {
                showDivifer = false;
            }
            contact.title = (StringUtil.isEmpty(contact.showName) ? contact.phoneNum : contact.showName);
            let subtitleConcat: string = (!StringUtil.isEmpty(contact.company) &&
            !StringUtil.isEmpty(contact.position)) ? ' | ' : "";
            contact.subTitle = (StringUtil.isEmpty(contact.company) ? '' :
            contact.company).concat(subtitleConcat).concat(StringUtil.isEmpty(contact.position) ? '' : contact.position);
            return {
                showIndex: showIndex,
                showDivifer: showDivifer,
                contact: contact
            };
        }
    }

    public refreshAll(contactList: ContactVo[]) {
        HiLog.i(TAG, ' refreshAll!');
        this.contactList = contactList;
        this.setDataReload(true);
    }

    public setIsShow(isShow: boolean) {
        if (this.isShow == isShow) {
            return;
        }
        HiLog.i(TAG, ' setIsShow:' + isShow);
        this.isShow = isShow;
        this.setDataReload(this.isDataReload)
    }

    public refresh(start: number, count: number, contactList: ContactVo[]) {
        HiLog.i(TAG, ' refresh!');
        this.contactList.splice(start, count, ...contactList);
        this.notifyDataReload();
        this.setDataReload(true);
    }

    public remove(index: number, count?) {
        if (index < 0 || index >= this.totalCount()) {
            return;
        }
        HiLog.i(TAG, ' remove:' + index);
        this.contactList.splice(index, count ? count : 1);
        this.notifyDataDelete(index);
    }

    private setDataReload(isDataReload: boolean) {
        if (this.isShow) {
            if (isDataReload) {
                HiLog.i(TAG, 'notifyDataReload');
                this.notifyDataReload();
            }
            this.isDataReload = false;
        } else {
            this.isDataReload = isDataReload;
        }
    }
}