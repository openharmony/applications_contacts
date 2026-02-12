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

import { AlphabetIndexObj, CharIndex, ContactVo, ContactVoNamePrefix } from '../../..//model/bean/ContactVo';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { FavoriteBean } from '../../../model/bean/FavoriteBean';
import { ObjectUtil } from '../../../../../../../feature/call/oh_modules/common';
import { ContactPickerListItem } from '../../../model/type/ContactParams';
import EnvironmentProp from '../../../feature/EnvironmentProp';

const TAG = 'AlphabetIndexerPresenter';
const CHINESE_CHAR_CODE = 255;
const FAVORITE_SYMBOL = '☆';
const SEARCH_NUMBER_OF_LIST_OFFSETS = 0;
const NO_SEARCH_NUMBER_OF_LIST_OFFSETS = 1;

export default class AlphabetIndexerPresenter {
  private static sInstance: AlphabetIndexerPresenter | null;
  public alphabetIndexList: string[] = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
  public existAlphabetIndexList: string[] = [];
  public alphabetIndexMap: Map<string, number> = new Map();
  public alphabetIndex: Record<string, AlphabetIndexObj> = {};
  public contactAlphabetIndex: Record<string, AlphabetIndexObj> = {};
  public favoriteAlphabetIndex: Record<string, AlphabetIndexObj> = {};
  public contactList: ContactVoNamePrefix[] = [];
  public favoriteData: ContactVoNamePrefix[] = [];
  public selectedAlphabetIndex: number = 0;
  public swipeSelectedAlphabetIndex: number = 0;
  public refreshUICallbacks: ((alphabetIndexList: string[]) => void)[] = [];

  public static getInstance(): AlphabetIndexerPresenter {
    if (AlphabetIndexerPresenter.sInstance == null) {
      HiLog.w(TAG, 'alphabetIndexer getInstance!');
      AlphabetIndexerPresenter.sInstance = new AlphabetIndexerPresenter();
    }
    return AlphabetIndexerPresenter.sInstance;
  }

  // A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  // A . . D . . G . . J . . M . . P . . S . . V . . . Z
  initExistAlphabetIndexList(hasFavorite: boolean) {
    let defaultAlphabetIndexList = ['D', 'G', 'J', 'M', 'P', 'S', 'V'];
    if (hasFavorite) {
      this.existAlphabetIndexList = [FAVORITE_SYMBOL];
    } else {
      this.existAlphabetIndexList = [];
    }
    this.alphabetIndexList.forEach((char) => {
      this.alphabetIndexMap.set(char, 0);
    })
    // 计算字母是否有对应的联系人
    this.contactList.forEach((item: ContactVoNamePrefix) => {
      this.alphabetIndexMap.set(item.namePrefix, (this.alphabetIndexMap.get(item.namePrefix) ?? 0) + 1);
    })
    // 计算A~Z之间的字母数量，如果小于 7 个，需要补满7个
    let AZAlphabetSet: Set<string> = new Set();
    this.alphabetIndexList.forEach((char) => {
      if (char === '#' || char === 'A' || char === 'Z') {
        return;
      }
      let count = this.alphabetIndexMap.get(char) ?? 0;
      if (count > 0) {
        AZAlphabetSet.add(char);
      }
    })
    for (let char of defaultAlphabetIndexList) {
      if (AZAlphabetSet.size >= 7) {
        break;
      }
      AZAlphabetSet.add(char);
    }
    this.alphabetIndexMap.forEach((count, char) => {
      if (char === '#' || char === 'A' || char === 'Z' || count > 0 || AZAlphabetSet.has(char)) {
        this.existAlphabetIndexList.push(char);
      }
    })
    this.refreshUICallbacks.forEach((refreshUI) => {
      refreshUI(this.existAlphabetIndexList);
    })
  }

  initContactList(contactList: ContactVo[] | ContactPickerListItem[], hasFavorite: boolean = false) {
    HiLog.w(TAG, `initContactList contactList size: ${contactList.length}, hasFavorite: ${hasFavorite}`);
    this.contactList = [];
    this.favoriteData = [];
    if (hasFavorite) {
      // 索引条增加 ☆ 图标
      if (this.alphabetIndexList.indexOf(FAVORITE_SYMBOL) === -1) {
        this.alphabetIndexList.splice(0, 0, FAVORITE_SYMBOL);
      }
    }
    for (let contact of contactList) {
      const element: ContactVoNamePrefix = {
        namePrefix: contact.namePrefix
      };
      if (hasFavorite && ((contact as ContactVo).favorite === '1' || (contact as ContactPickerListItem).isFavorite)) {
        this.favoriteData.push(element);
      }
      this.contactList.push(element);
    }
    this.contactList = [...this.favoriteData, ...this.contactList];
    this.initExistAlphabetIndexList(hasFavorite);
  }

  initAlphabetIndex(alphabetIndex: Record<string, AlphabetIndexObj>) {
    this.contactAlphabetIndex = alphabetIndex;
    this.reloadAlphabetIndex();
  }

  initFavoriteAlphabetIndex(alphabetIndex: Record<string, AlphabetIndexObj>) {
    let mAlphabetIndex: Record<string, AlphabetIndexObj> = {};
    if (Object.keys(alphabetIndex).length > 0) {
      let enPrefix: CharIndex = new CharIndex();
      let zhPrefix: CharIndex[] = [];
      Object.entries(alphabetIndex).forEach(item => {
        if (enPrefix.char === '') {
          enPrefix = item[1].enPrefix;
          enPrefix.start = 0;
          enPrefix.end = -1;
        }
        enPrefix.end = enPrefix.end + 1;
        if (item[1].zhPrefix.length) {
          zhPrefix.push(...item[1].zhPrefix);
        }
      });
      let alphabetIndexObj: AlphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.enPrefix = enPrefix;
      alphabetIndexObj.zhPrefix = zhPrefix;
      let favoriteStr = this.favoriteString();
      if (favoriteStr) {
        mAlphabetIndex[this.favoriteString()] = alphabetIndexObj;
      }
    }
    this.favoriteAlphabetIndex = mAlphabetIndex;
    this.reloadAlphabetIndex();
  }

  reloadAlphabetIndex() {
    this.alphabetIndex = ObjectUtil.assign(JSON.parse(JSON.stringify(this.favoriteAlphabetIndex)),
      JSON.parse(JSON.stringify(this.contactAlphabetIndex)));
  }

  relpceFavoriteIndexString(str: string): string {
    if (str === FAVORITE_SYMBOL) {
      str = this.favoriteString();
    }
    return str;
  }

  favoriteString() {
    return getContext(this)?.resourceManager.getStringSync($r('app.string.favorite').id);
  }

  getAlphabetPopData(index: number): string[] {
    let isUseExistAlphabetIndexList = AppStorage.get<boolean>('isVerde') ?? false;
    HiLog.w(TAG, `getAlphabetPopData index: ${index}, isUseExistAlphabetIndexList: ${isUseExistAlphabetIndexList}`)
    let popData: string[] = [];
    if ((!isUseExistAlphabetIndexList && this.alphabetIndexList.length <= index ) ||
      (isUseExistAlphabetIndexList && this.existAlphabetIndexList.length <= index)) {
      return popData;
    }

    // Get Index Popup Data
    let selected = this.alphabetIndexList[index];
    if (isUseExistAlphabetIndexList) {
      selected = this.existAlphabetIndexList[index];
    }
    selected = this.relpceFavoriteIndexString(selected);
    HiLog.w(TAG, `getAlphabetPopData selected: ${selected}`)
    if (this.alphabetIndex[selected]) {
      let list = this.alphabetIndex[selected].zhPrefix;
      list?.forEach(value => {
        popData.push(value.char)
      })
    }
    return popData;
  }

  /**
   * 选中二级索引后，获得对应的联系人信息的下标
   * @param selectedAlphabetIndex 选中的二级索引（ABCDE。。）的下标
   * @param popDataSource selectedAlphabetIndex对应的字母对应的汉字集合（如M字母下的【吗 马 们 蒙】）
   * @param popIndex 选择的popDataSource数组的下标
   * @returns
   */
  getListScrollIndex(showSearch: boolean, selectedAlphabetIndex: number, popDataSource?: string[],
    popIndex?: number, scrollIndexOffset: boolean = true): number {
    // get list scroll index
    AppStorage.setOrCreate('calibrationAlphabetIndex', 2);
    let isUseExistAlphabetIndexList = AppStorage.get<boolean>('isVerde') ?? false;
    let selected = this.alphabetIndexList[selectedAlphabetIndex];
    if (isUseExistAlphabetIndexList) {
      selected = this.existAlphabetIndexList[selectedAlphabetIndex];
    }
    this.selectedAlphabetIndex = selectedAlphabetIndex;
    let indexOffset = (selected === FAVORITE_SYMBOL ? 0 : this.favoriteData.length);
    selected = this.relpceFavoriteIndexString(selected);
    HiLog.w(TAG, 'getListScrollIndex selected alphabet is ' + selected);

    // 二级索引字母对应的AlphabetIndexObj对象
    let alphabetIndexObj = this.alphabetIndex[selected];
    if (!alphabetIndexObj) {
      return -1;
    }

    // 选择了二级索引字母，获取对应的联系人的起始下标
    let scrollIndex: number = alphabetIndexObj.enPrefix?.start as number + indexOffset;
    HiLog.w(TAG, 'getListScrollIndex scrollIndex is ' + scrollIndex);
    if (scrollIndex >= this.contactList.length) {
      return this.contactList.length - 1;
    }

    // 选择了二级索引字母对应的汉字
    if (popIndex !== undefined && popIndex >= 0) {
      let zh = alphabetIndexObj.zhPrefix![popIndex];
      if (zh && popDataSource !== undefined && popDataSource[popIndex] == zh.char) {
        scrollIndex = zh.start as number + indexOffset;
      }
    }

    if (!scrollIndexOffset) {
      return scrollIndex;
    }

    HiLog.w(TAG, 'showSearch ' + showSearch)
    if (AppStorage.get('isVerde')) {
      return scrollIndex + SEARCH_NUMBER_OF_LIST_OFFSETS;
    } else {
      return scrollIndex + NO_SEARCH_NUMBER_OF_LIST_OFFSETS;
    }
  }

  /**
   * 根据滑动后，首个联系人index，找到联系人，根据联系人sortFirstLetter，找到二级索引对应的字母
   * @param scrollIndex
   * @returns
   */
  getAlphabetSelected(scrollIndex: number): number {
    let selected = 0;
    let isUseExistAlphabetIndexList = AppStorage.get<boolean>('isVerde') ?? false;
    if (scrollIndex < this.favoriteData.length) {
      let namePrefix = FAVORITE_SYMBOL;
      if (isUseExistAlphabetIndexList) {
        selected = this.existAlphabetIndexList.indexOf(namePrefix);
      } else {
        selected = this.alphabetIndexList.indexOf(namePrefix);
      }
    } else if (scrollIndex < this.contactList.length) {
      let obj = this.contactList[scrollIndex];
      let namePrefix = obj.namePrefix;
      if (isUseExistAlphabetIndexList) {
        selected = this.existAlphabetIndexList.indexOf(namePrefix);
      } else {
        selected = this.alphabetIndexList.indexOf(namePrefix);
      }
      HiLog.w(TAG, 'swipeSelectedAlphabetIndex ' + this.swipeSelectedAlphabetIndex + ' selectedAlphabetIndex ' +
      this.selectedAlphabetIndex);
      if (this.swipeSelectedAlphabetIndex !== this.selectedAlphabetIndex) {
        this.swipeSelectedAlphabetIndex = this.selectedAlphabetIndex;
        selected = this.selectedAlphabetIndex;
      }
    }
    return selected;
  }

  /**
   * 清理索引条单例的缓存
   */
  public clearCache(): void {
    HiLog.w(TAG, 'clearCache...');
    this.alphabetIndex = {};
    this.contactAlphabetIndex = {};
    this.alphabetIndexMap.clear();
    this.favoriteAlphabetIndex = {};
    this.existAlphabetIndexList = [];
    this.contactList = [];
    this.favoriteData = [];
  }

  public static unInstance(): void {
    HiLog.w(TAG, 'unInstance...');
    AlphabetIndexerPresenter.sInstance = null;
  }
}