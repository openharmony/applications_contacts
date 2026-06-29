/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import DataShareResultSet from '@ohos.data.DataShareResultSet';
import BlockList from '../contract/BlockList';

export default class BlockListContact {
  public mark: number = -1;
  public name: string = '';
  public phoneNumber: string = '';
  public formatPhoneNumber: string = '';
  public interceptionCallCount: number = -1;
  public interceptionMsgCount: number = -1;

  static fromResultSet(resultSet: DataShareResultSet): BlockListContact {
    let blockListContact: BlockListContact = new BlockListContact();
    blockListContact.setPhoneNumber(resultSet.getString(resultSet.getColumnIndex(BlockList.PHONE_NUMBER)));
    blockListContact.setInterceptionCallCount(resultSet.getLong(resultSet.
    getColumnIndex(BlockList.INTERCEPTION_CALL_COUNT)));
    return blockListContact;
  }

  setPhoneNumber(phoneNumber: string) {
    this.phoneNumber = phoneNumber;
    return this;
  }

  setInterceptionCallCount(interceptionCallCount: number) {
    this.interceptionCallCount = interceptionCallCount;
    return this;
  }
}

export interface IsBlockContact {
  isInBlock: boolean,
  phoneNumber: string
}

