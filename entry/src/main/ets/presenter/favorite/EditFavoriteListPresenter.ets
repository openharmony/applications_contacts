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

import router from '@ohos.router';
import { HiLog, sharedPreferencesUtils } from '../../../../../../common';
import { FavoriteBean } from '../../model/bean/FavoriteBean';
import FavoriteDataSource from '../../model/bean/FavoriteDataSource';

const TAG = 'EditFavoriteListPresenter ';

/**
 * Favorite List Logical Interface Model
 */
export default class EditFavoriteListPresenter {
  private static sInstance: EditFavoriteListPresenter;
  favoriteList: FavoriteBean[] = [];
  usuallySelectList: string[] = [];
  tempUsuallySelectList: string[] = [];
  favoriteCount: number = 0;
  favoriteDataSource: FavoriteDataSource = new FavoriteDataSource();
  isShow: boolean = false;
  usuallyList: FavoriteBean[] = [] ;
  isEdit: boolean = false;
  isEditSelect: string[] = [];
  selectFavoriteBean: FavoriteBean;

  private constructor() {
  }

  public static getInstance(): EditFavoriteListPresenter {
    if (EditFavoriteListPresenter.sInstance == null) {
      HiLog.i(TAG, 'EditFavoriteListPresenter getInstance!');
      EditFavoriteListPresenter.sInstance = new EditFavoriteListPresenter();
    }
    return EditFavoriteListPresenter.sInstance;
  }

  /**
   * Remove selected data
   * @param selectFavoriteIdList
   */
  deleteFavoriteInfo(selectFavoriteIdList: string[]) {
    HiLog.i(TAG, 'deleteFavoriteInfo start.');
    let usuallyLength = this.usuallySelectList.length;
    if (usuallyLength > 0) {
      sharedPreferencesUtils.saveToPreferences('usuallySelectDisplayNameList', JSON.stringify(this.usuallySelectList));
    }
    let favoriteLength = selectFavoriteIdList.length;
    if (favoriteLength - usuallyLength > 0) {
      AppStorage.SetOrCreate<Array<string>>('deleteFavoriteContactData', selectFavoriteIdList);
    }
    HiLog.i(TAG, 'deleteFavoriteInfo end.');
  }

  /**
   * Add Selection Single Data
   * @param isEditSelectList
   * @param favoriteId
   */
  addSingleFavoriteSelectInfo(isEditSelectList: string[], favoriteBean: FavoriteBean): string[] {
    HiLog.i(TAG, 'addSingleFavoriteSelectInfo start.');
    isEditSelectList.push(favoriteBean.contactId);
    if (1 === favoriteBean.isCommonUseType && !(this.usuallySelectList.indexOf(favoriteBean.displayName) >= 0)) {
      this.usuallySelectList.push(favoriteBean.displayName);
    }
    return isEditSelectList;
  }

  /**
   * Deselect Single Data
   * @param isEditSelectList
   * @param favoriteId
   */
  cancelSingleFavoriteSelectInfo(isEditSelectList: string[], favoriteBean: FavoriteBean): string[] {
    HiLog.i(TAG, 'cancelSingleFavoriteSelectInfo start.');
    let index = isEditSelectList.indexOf(favoriteBean.contactId);
    if (index >= 0) {
      isEditSelectList.splice(index, 1);
      if (1 === favoriteBean.isCommonUseType) {
        let indexBean = this.usuallySelectList.indexOf(favoriteBean.displayName);
        if (indexBean >= 0) {
          this.usuallySelectList.splice(indexBean, 1);
        }
      }
    }
    return isEditSelectList;
  }

  /**
   * Add Select All Data
   * @param favoriteId
   */
  addAllFavoriteSelectInfo(favoriteList: FavoriteBean[]): string[] {
    HiLog.i(TAG, 'addAllFavoriteSelectInfo start.');
    let isEditList: string[] = [];
    for (let i = 0;i < favoriteList.length; i++) {
      favoriteList[i].isEditSelect = true;
      isEditList.push(favoriteList[i].contactId);
      if (1 === favoriteList[i].isCommonUseType && !(this.usuallySelectList.indexOf(favoriteList[i].displayName) >= 0)) {
        this.usuallySelectList.push(favoriteList[i].displayName);
      }
    }
    this.favoriteDataSource.refresh(favoriteList);
    return isEditList;
  }

  /**
   * Deselect all data
   * @param favoriteId
   */
  cancelAllFavoriteSelectInfo(favoriteList: FavoriteBean[], isEditSelectList: string[]): string[] {
    HiLog.i(TAG, 'cancelAllFavoriteSelectInfo start.');
    for (let i = 0; i < favoriteList.length; i++) {
      this.favoriteList[i].isEditSelect = false;
      favoriteList[i].isEditSelect = false;
      isEditSelectList.splice(i, 1);
      if (1 === favoriteList[i].isCommonUseType) {
        let indexBean = this.usuallySelectList.indexOf(favoriteList[i].displayName);
        this.usuallySelectList.splice(indexBean, 1);
      }
    }
    if (isEditSelectList.length > 0) {
      isEditSelectList = [];
    }
    return isEditSelectList;
  }

  /**
   * Favorite Move Sort
   * @param favoriteList
   */
  moveSortFavorite(favoriteList: FavoriteBean[]) {
    HiLog.i(TAG, 'moveSortFavorite start.');
    let favoriteLength: number = favoriteList.length;
    for (let i = 0; i < favoriteLength; i++) {
      let favoriteForm: any = {}
      favoriteForm.id = favoriteList[i].contactId;
      favoriteForm.favoriteOrder = i + 1;
      globalThis.DataWorker.sendRequest('moveSortFavorite', {
        context: globalThis.context,
        favoriteForm: JSON.stringify(favoriteForm)
      }, (result) => {
        if (favoriteLength === (i + 1)) {
          AppStorage.SetOrCreate<number>('editFavoriteDrag', 1);
          router.back();
        }
      })
    }
    HiLog.i(TAG, 'moveSortFavorite end.');
  }

  /**
   * Cancel Editing
   */
  cancelEditFavorite() {
    AppStorage.SetOrCreate<number>('cancelEditFavorite', 2);
    router.back();
  }

  aboutToAppear() {
    HiLog.i(TAG, 'EditFavoriteListPresenter aboutToAppear!');
    this.isShow = true;
    this.favoriteDataSource.refresh(this.favoriteList);
    if (undefined !== this.selectFavoriteBean && 1 === this.selectFavoriteBean.isCommonUseType) {
      this.usuallySelectList.push(this.selectFavoriteBean.displayName);
    }
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'EditFavoriteListPresenter aboutToDisappear!');
    this.tempUsuallySelectList = this.usuallySelectList;
    this.isShow = false;
  }

  onPageShow() {
    HiLog.i(TAG, 'EditFavoriteListPresenter onPageShow!');
    this.isShow = true;
  }

  onPageHide() {
    HiLog.i(TAG, 'EditFavoriteListPresenter onPageHide!');
    this.isShow = false;
  }
}