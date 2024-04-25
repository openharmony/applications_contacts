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
import ArrayList from '@ohos.util.ArrayList';
import { HiLog, sharedPreferencesUtils } from '../../../../../../common';
import { FavoriteBean } from '../../model/bean/FavoriteBean';
import FavoriteDataSource from '../../model/bean/FavoriteDataSource';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import emitter from '@ohos.events.emitter';
import ContactAbilityModel from '../../model/ContactAbilityModel';

const TAG = 'FavoriteListPresenter  ';

/**
 * Favorite List Logical Interface Model
 */
export default class FavoriteListPresenter {
  private static sInstance: FavoriteListPresenter;
  favoriteList: FavoriteBean[] = [];
  usuallyList: FavoriteBean[] = [];
  favoriteCount: number = 0;
  isEmptyGroup: boolean = true;
  favoriteDataSource: FavoriteDataSource = new FavoriteDataSource();
  isShow: boolean = false;
  isEditSelectList: string[] = [];
  usuallySelectArray = new ArrayList();
  displayNameList: string[] = [];
  usuallyDisplayNameParameterList: string[] = [];
  usuallyPhoneParameterList: string[] = [];
  usuallyTotalCount: number = 0;
  onContactChange = () => {
    HiLog.i(TAG, 'onFavoriteChange refresh');
    this.requestItem();
  }

  private constructor() {
  }

  public static getInstance(): FavoriteListPresenter {
    if (FavoriteListPresenter.sInstance == null) {
      HiLog.i(TAG, 'FavoriteListPresenter getInstance!');
      FavoriteListPresenter.sInstance = new FavoriteListPresenter();
    }
    return FavoriteListPresenter.sInstance;
  }

  refreshFavorite() {
    HiLog.i(TAG, 'refreshFavorite start.');
    let actionData: any = {};
    actionData.favorite = 1
    globalThis.DataWorker.sendRequest('getAllFavorite', {
      actionData: actionData,
      context: globalThis.context
    }, (result) => {
      HiLog.i(TAG, 'refreshFavorite sc.');
      this.favoriteList = [];
      this.favoriteList = result;
      if (this.favoriteList.length > 0) {
        this.favoriteList[0].isUsuallyShow = true;
      }
      this.favoriteCount = result.length;
      this.refreshFavoriteList(this.favoriteList);
    })
    HiLog.i(TAG, 'refreshFavorite end.');
  }

  refreshUsually() {
    HiLog.i(TAG, 'refreshUsually start.');
    let actionData: any = {};
    actionData.favorite = 0;
    globalThis.DataWorker.sendRequest('getAllUsually', {
      actionData: actionData,
      context: globalThis.context
    }, (result) => {
      HiLog.i(TAG, 'refreshUsually sc.');
      let resultCount = result.length;
      if (resultCount > 0) {
        let usuallySelectDisplayNameListCount = this.usuallySelectArray.length;
        this.usuallyTotalCount = 0;
        let usuallyContainDisplayNameCount: number = 0;
        this.displayNameList = [];
        this.usuallyDisplayNameParameterList = [];
        for (let i = 0; i < resultCount; i++) {
          //The name cannot be empty or duplicate.
          if ('' !== result[i].displayName && this.displayNameList.indexOf(result[i].displayName) === -1) {
            this.displayNameList.push(result[i].displayName);
            if (this.usuallySelectArray.has(result[i].displayName)) {
              usuallyContainDisplayNameCount++;
            }
          }
        }
        if (usuallyContainDisplayNameCount === this.displayNameList.length && usuallyContainDisplayNameCount === usuallySelectDisplayNameListCount) {
          this.refreshFavoriteList(this.favoriteList);
          return;
        }
        for (let i = 0; i < resultCount; i++) {
          if ('' !== result[i].displayName) {
            if (this.usuallyTotalCount < 10) {
              if (usuallySelectDisplayNameListCount > 0) {
                if (!this.usuallySelectArray.has(result[i].displayName)) {
                  if ('' !== result[i].phoneNumber) {
                    this.usuallyTotalCount++;
                    this.usuallyPhoneParameterList.push(result[i].phoneNumber);
                    this.usuallyDisplayNameParameterList.push(result[i].displayName);
                  }
                }
              } else {
                if ('' !== result[i].phoneNumber) {
                  this.usuallyTotalCount++;
                  this.usuallyDisplayNameParameterList.push(result[i].displayName);
                  this.usuallyPhoneParameterList.push(result[i].phoneNumber);
                }
              }
            } else {
              //More than 10
              if (this.usuallyDisplayNameParameterList.length > 0) {
                this.getDisplayNamesFindUsually(this.usuallyDisplayNameParameterList, this.usuallyPhoneParameterList);
              } else {
                this.refreshFavoriteList(this.favoriteList);
              }
              return;
            }
          }
        }
        //No more than 10
        if (this.usuallyDisplayNameParameterList.length > 0) {
          this.getDisplayNamesFindUsually(this.usuallyDisplayNameParameterList, this.usuallyPhoneParameterList);
        } else {
          this.refreshFavoriteList(this.favoriteList);
        }
      } else {
        this.refreshFavoriteList(this.favoriteList);
      }
    })
    HiLog.i(TAG, 'refreshUsually end.');
  }

  getDisplayNamesFindUsually(displayNameList: string[], usuallyPhoneList: string[]) {
    HiLog.i(TAG, 'getDisplayNamesFindUsually start.');
    globalThis.DataWorker.sendRequest('getDisplayNamesFindUsually', {
      displayName: displayNameList,
      usuallyPhone: usuallyPhoneList,
      context: globalThis.context
    }, (result) => {
      let totalCount = result.length;
      HiLog.i(TAG, 'getDisplayNamesFindUsually sc');
      if (null != result && totalCount > 0) {
        this.favoriteList = this.favoriteList.concat(result);
        this.refreshFavoriteList(this.favoriteList);
      }  else {
        this.refreshFavoriteList(this.favoriteList);
      }
    })
    HiLog.i(TAG, 'getDisplayNamesFindUsually end.');
  }

  /**
   * Refresh Favorite List
   * @param favoriteList
   */
  refreshFavoriteList(favoriteList: FavoriteBean[]) {
    if (this.favoriteCount < this.favoriteList.length) {
      this.favoriteList[this.favoriteCount].isUsuallyShow = true;
    }
    this.favoriteDataSource.refresh(favoriteList);
    let innerEvent = {
      eventId: 100,
      priority: emitter.EventPriority.HIGH
    };
    emitter.emit(innerEvent, {
      data: {
        'favoriteListListLen': this.favoriteList.length
      }
    });
  }

  goContactDetail(contactId: string) {
    HiLog.i(TAG, 'goContactDetail start.');
    router.pushUrl(
      {
        url: 'pages/contacts/details/ContactDetail',
        params: {
          sourceHasId: true,
          contactId: contactId
        }
      }
    );
  }

  aboutToAppear() {
    HiLog.i(TAG, 'FavoriteListPresenter aboutToAppear!');
    this.isShow = true;
    ContactRepository.getInstance().registerDataChangeObserver(this.onContactChange);
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'FavoriteListPresenter aboutToDisappear!');
    this.isShow = false;
    ContactRepository.getInstance().unRegisterDataChangeObserver(this.onContactChange);
  }

  async onPageShow() {
    HiLog.i(TAG, 'onPageShow!');
    this.isShow = true;
    let editFavoriteDrag: number = AppStorage.Get<number>('editFavoriteDrag');
    let addFavoriteContactData: string[] = AppStorage.Get<Array<string>>('addFavoriteContactData');
    let deleteFavoriteContactData: string[] = AppStorage.Get<Array<string>>('deleteFavoriteContactData');
    let cancelEditFavorite: number = AppStorage.Get<number>('cancelEditFavorite');
    let that = this;
    let usuallySelectData: Promise<string> = new Promise(async (resolve) => {
      let usuallySelectDisplayNameList: string = <string> await sharedPreferencesUtils.getFromPreferences('usuallySelectDisplayNameList', '');
      if ('' !== usuallySelectDisplayNameList) {
        let usuallySelectDisplayList: string[] = JSON.parse(usuallySelectDisplayNameList);
        let count = usuallySelectDisplayList.length;
        that.usuallySelectArray.clear();
        for (let i = 0; i < count; i++) {
          that.usuallySelectArray.add(usuallySelectDisplayList[i]);
        }
      }
      if(0 !== that.usuallySelectArray.length){
        this.requestItem();
      }
      resolve(usuallySelectDisplayNameList)
    });
    if (editFavoriteDrag !== undefined && editFavoriteDrag === 1) {
      HiLog.i(TAG, 'onPageShow editFavoriteDrag!');
      this.requestItem();
      AppStorage.SetOrCreate<number>('editFavoriteDrag', 0);
    } else if (addFavoriteContactData !== undefined && addFavoriteContactData.length > 0) {
      HiLog.i(TAG, 'onPageShow addFavoriteContactData!');
      this.addFavoriteInfo(addFavoriteContactData);
      AppStorage.SetOrCreate<Array<string>>('addFavoriteContactData', []);
    } else if (cancelEditFavorite !== undefined && 2 === cancelEditFavorite) {
      HiLog.i(TAG, 'onPageShow cancelEditFavorite!');
      AppStorage.SetOrCreate<number>('cancelEditFavorite', 0);
    } else if (deleteFavoriteContactData !== undefined && deleteFavoriteContactData.length > 0) {
      HiLog.i(TAG, 'onPageShow deleteFavoriteContactData!');
      this.deleteFavorite(deleteFavoriteContactData);
      AppStorage.SetOrCreate<Array<string>>('deleteFavoriteContactData', []);
    } else {
      HiLog.i(TAG, 'onPageShow else!');
      await usuallySelectData.then(result => {
        if ('' === result) {
          this.requestItem();
        }
      })
    }
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageHide!');
    this.isShow = false;
  }

  requestItem() {
    HiLog.i(TAG, 'requestItem start.');
    this.refreshFavorite();
    this.refreshUsually();
  }

  async usuallySelectData(): Promise<string> {
    let that = this;
    //let usuallySelectData: Promise<string>
    return await new Promise(async (resolve) => {
      let usuallySelectDisplayNameList: string = <string> await sharedPreferencesUtils.getFromPreferences('usuallySelectDisplayNameList', '');
      if ('' !== usuallySelectDisplayNameList) {
        let usuallySelectDisplayList: string[] = JSON.parse(usuallySelectDisplayNameList);
        let count = usuallySelectDisplayList.length;
        that.usuallySelectArray.clear();
        for (let i = 0; i < count; i++) {
          that.usuallySelectArray.add(usuallySelectDisplayList[i]);
        }
      }
      if(0 !== that.usuallySelectArray.length){
        this.requestItem();
      }
      resolve(usuallySelectDisplayNameList)
    });
  }

  addFavorite() {
    router.pushUrl({
      url: 'pages/contacts/batchselectcontacts/BatchSelectContactsPage',
      params: {
        addFavorite: 0,
        selectType: 1
      }
    });
  }

  editFavorite() {
    router.pushUrl({
      url: 'pages/favorites/editFavoriteList',
      params: {
        isEdit: true,
        favoriteList: this.favoriteList,
        favoriteNumber: this.favoriteCount,
        usuallyNumber: this.favoriteList.length - this.favoriteCount,
      }
    })
  }

  addFavoriteInfo(selectFavoriteIdList: string[]) {
    HiLog.i(TAG, 'addFavoriteInfo start.');
    let selectLength: number = selectFavoriteIdList.length;
    for (let i = 0; i < selectLength; i++) {
      let favoriteForm: any = {}
      favoriteForm.id = selectFavoriteIdList[i];
      favoriteForm.favorite = 1;
      globalThis.DataWorker.sendRequest('updateFavorite', {
        context: globalThis.context,
        favoriteForm: JSON.stringify(favoriteForm)
      }, (arg) => {
        if (i === (selectLength - 1)) {
          AppStorage.SetOrCreate<Array<string>>('addFavoriteContactData', [])
          HiLog.i(TAG, 'addFavoriteInfo success refresh.');
          this.requestItem();
        }
      })
    }
    HiLog.i(TAG, 'addFavoriteInfo end.');
  }

  deleteFavorite(deleteFavoriteIdList: string[]) {
    HiLog.i(TAG, 'deleteFavorite start.');
    let favoriteLength: number = deleteFavoriteIdList.length;
    for (let i = 0; i < favoriteLength; i++) {
      let favoriteForm: any = {};
      favoriteForm.id = deleteFavoriteIdList[i];
      favoriteForm.favorite = 0;
      globalThis.DataWorker.sendRequest('updateFavorite', {
        context: globalThis.context,
        favoriteForm: JSON.stringify(favoriteForm)
      }, (arg) => {
        if(i === (favoriteLength - 1)){
          HiLog.i(TAG, 'deleteFavoriteInfo success.');
          AppStorage.SetOrCreate<Array<string>>('deleteFavoriteContactData', [])
          this.requestItem();
        }
      })
    }
    HiLog.i(TAG, 'deleteFavorite end.');
  }

  longItemEditFavorite(favoriteList: FavoriteBean[], isEditSelectList: string[], favoriteBean: FavoriteBean) {
    router.pushUrl({
      url: 'pages/favorites/editFavoriteList',
      params: {
        isEdit: true,
        favoriteList: favoriteList,
        selectNumber: 1,
        favoriteNumber: this.favoriteCount,
        usuallyNumber: favoriteList.length - this.favoriteCount,
        isEditSelectList: isEditSelectList,
        selectFavoriteBean: favoriteBean
      }
    })
  }
}