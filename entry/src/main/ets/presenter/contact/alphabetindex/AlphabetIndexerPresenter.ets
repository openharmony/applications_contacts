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

import {ContactVo, NameVo } from '../../..//model/bean/ContactVo';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';

const TAG = 'AlphabetIndexerPresenter';
const CHINESE_CHAR_CODE = 255;

export default class AlphabetIndexerPresenter {
  private static sInstance: AlphabetIndexerPresenter;
  alphabetIndexList: string[] = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
  private alphabetObj: {[key: string] : NameVo[]} = {};
  private alphabetIndexObj: {[key: string] : number} = {};
  private contactList: ContactVo[] = [];

  public static getInstance(): AlphabetIndexerPresenter {
    if (AlphabetIndexerPresenter.sInstance == null) {
      HiLog.i(TAG, 'alphabetIndexer getInstance!');
      AlphabetIndexerPresenter.sInstance = new AlphabetIndexerPresenter();
    }
    return AlphabetIndexerPresenter.sInstance;
  }

  initContactList(list: ContactVo[]) {
    this.contactList = list.slice();
    this.getAlphabetIndexData();
  }

  getAlphabetIndexData() {
    if (ArrayUtil.isEmpty(this.contactList)) {
      return null;
    }
    // Get the position of the index in the list
    // Get index data
    this.contactList.forEach((item, index) => {
      let preContact: ContactVo = null;
      if (index > 0) {
        preContact = this.contactList[index - 1];
      }
      if (index == 0 || !(item.namePrefix == preContact.namePrefix)) {
        this.alphabetObj[item.namePrefix] = [];
        this.alphabetIndexObj[item.namePrefix] = this.contactList.indexOf(item);
      }
      let nameVo = new NameVo(item.emptyNameData, item.namePrefix, item.nameSuffix);
      this.alphabetObj[item.namePrefix].push(nameVo);
    })
  }

  getAlphabetPopData(index: number): string[] {
    let popData: string[] = [];
    if (this.alphabetIndexList.length <= index) {
      return popData;
    }

    // Get Index Popup Data
    let selected = this.alphabetIndexList[index];
    let list = this.alphabetObj[selected];
    if (list && list.length !== 0) {
      list.forEach(item => {
        if(item.nameSuffix.charCodeAt(0) > CHINESE_CHAR_CODE) {
          if (popData.length === 0) {
            popData.push(item.nameSuffix);
          } else {
            let hasIndex = popData.indexOf(item.nameSuffix);
            if (hasIndex === -1) {
              popData.push(item.nameSuffix);
            }
          }
        }
      });
    }
    return popData;
  }

  getListScrollIndex(selectedAlphabetIndex: number, popDataSource?: string[],  popIndex?: number): number {
    // get list scroll index
    let selected = this.alphabetIndexList[selectedAlphabetIndex];
    let alphabetIndex = this.alphabetIndexObj[selected];
    let scrollIndex: number = alphabetIndex;
    if (popIndex >= 0) {
      let alphabetContacts = this.alphabetObj[selected];
      if (alphabetContacts) {
        let popData = popDataSource[popIndex];
        for (let index = 0; index < alphabetContacts.length; index++) {
          const element = alphabetContacts[index];
          if (element.nameSuffix === popData) {
            scrollIndex = scrollIndex + index;
            break;
          }
        }
      }
    }
    return scrollIndex;
  }

  getAlphabetSelected(scrollIndex: number): number {
    let selected = 0;
    if (this.contactList.length > scrollIndex) {
      let obj = this.contactList[scrollIndex];
      let namePrefix = obj.namePrefix;
      selected = this.alphabetIndexList.indexOf(namePrefix);
    }
    return selected;
  }
}