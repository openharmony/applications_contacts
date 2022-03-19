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
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import {ContactVo} from '../bean/ContactVo';
import HiLog from '../../util/HiLog';
import common from '../../model/common';
import ContactAbilityModel from '../../model/ContactAbilityModel';
import Constants from '../../model/common/Constants';
import utils from '../../util/Utils';
import ContactRepository from '../../contact/repo/ContactRepository';

const TAG = "ContactListDataSource";

export default class ContactListDataSource extends BasicDataSource {
    private contactList: ContactVo[] = [];
    private contactsCount: number = 0;

    public totalCount(): number {
        HiLog.i(TAG, "totalCount is %s", this.contactList.length);
        return this.contactList.length;
    }

    public getData(index: number): any {
        HiLog.i(TAG, "getData index is %s", index);
        if (utils.isEmptyList(this.contactList) || index >= this.contactList.length) {
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
            HiLog.i(TAG, "getData contactlist showIndex is " + showIndex + " , showDivifer is " + showDivifer);
            return {
                showIndex: showIndex,
                showDivifer: showDivifer,
                contact: contact
            };
        }
    }

    public refresh(contactList: ContactVo[]) {
        HiLog.i(TAG, ' refresh!');
        this.contactList = contactList;
        this.notifyDataReload();
    }
}