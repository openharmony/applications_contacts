/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import common from '@ohos.app.ability.common';

import { HiLog } from '../../../../../../common';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { FavoriteBean } from '../../model/bean/FavoriteBean';
import FavoriteDataSource from '../../model/bean/FavoriteDataSource';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import FavoriteListPresenter from './FavoriteListPresenter';
import { HashSet } from '@kit.ArkTS';
import { FavoriteListBean } from '../../model/bean/FavoriteListBean';
import { emitter } from '@kit.BasicServicesKit';

const TAG = 'EditFavoriteListPresenter ';

/**
 * Favorite List Logical Interface Model
 */
export default class EditFavoriteListPresenter {
  public pathInfos: NavPathStack = new NavPathStack();
  private static sInstance: EditFavoriteListPresenter;
  public static EDIT_FAVORITELIST_ITEM_CHECKED = 'editFavoriteListItemChecked';

  public icSelectAll: Resource = $r('sys.symbol.checkmark_square_on_square');
  public allSelectMessage: Resource = $r('app.string.select_all');

  public selectNumber: number = 0;
  public contactsTotal: number = 0;
  public favoriteList: FavoriteBean[] = [];
  public favoriteDataSource: FavoriteDataSource = new FavoriteDataSource();
  public selectedContacts: HashSet<string> = new HashSet();

  public refreshUI: () => void = () => {};
  public isOnMoved: boolean = false;
  private constructor() {
  }

  public static getInstance(): EditFavoriteListPresenter {
    if (EditFavoriteListPresenter.sInstance == null) {
      HiLog.i(TAG, 'EditFavoriteListPresenter getInstance!');
      EditFavoriteListPresenter.sInstance = new EditFavoriteListPresenter();
    }
    return EditFavoriteListPresenter.sInstance;
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  /**
   * Remove selected data
   * @param selectFavoriteIdList
   */
  deleteFavoriteInfo(selectFavoriteIdList: string[]) {
    HiLog.i(TAG, 'deleteFavoriteInfo start.');
    let favoriteLength = selectFavoriteIdList.length;
    if (favoriteLength > 0) {
      AppStorage.SetOrCreate<Array<string>>('deleteFavoriteContactData', selectFavoriteIdList);
    }
    HiLog.i(TAG, 'deleteFavoriteInfo end.');
  }



  // 更新页面底部工具栏
  refreshPageMessage() {
    HiLog.i(TAG, 'refreshPageMessage start !')
    this.selectNumber = this.selectedContacts.length;
    if (this.selectNumber === this.contactsTotal && this.contactsTotal > 0) {
      HiLog.w(TAG, `1 this.selectNumber: ${this.selectNumber}, this.contactsTotal: ${this.contactsTotal}`)
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square_fill');
      this.allSelectMessage = $r('app.string.unselect_all');
    } else if (this.selectNumber === 0) {
      HiLog.w(TAG, `2 this.selectNumber: ${this.selectNumber}, this.contactsTotal: ${this.contactsTotal}`)
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square');
      this.allSelectMessage = $r('app.string.select_all');
    } else {
      HiLog.w(TAG, `3 this.selectNumber: ${this.selectNumber}, this.contactsTotal: ${this.contactsTotal}`)
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square');
      this.allSelectMessage = $r('app.string.select_all');
    }
    this.refreshUI();
  }


  /**
   * Remove UsuallyInfo
   * @param selectedUsuallyList
   */
  deleteUsuallyInfo(selectedUsuallyList: string[]) {
    HiLog.i(TAG, 'deleteUsuallyInfo start.');
    let usuallyLength = selectedUsuallyList.length;
    if (usuallyLength > 0) {
      AppStorage.SetOrCreate<Array<string>>('deleteUsuallyContactData', selectedUsuallyList);
    }
    HiLog.i(TAG, 'deleteUsuallyInfo end.');
  }


  onItemClick(item: FavoriteBean, index: number) {
    HiLog.w(TAG, 'onItemClick contactId: ' + item.contactId + ',  index: ' + index);
    if (this.selectedContacts.has(item.contactId)) {
      this.selectedContacts.remove(item.contactId);
    } else {
      this.selectedContacts.add(item.contactId);
    }
    let eventData: emitter.EventData = {
      data: { 'contactId': item.contactId }
    };
    emitter.emit(EditFavoriteListPresenter.EDIT_FAVORITELIST_ITEM_CHECKED, eventData);
    this.refreshPageMessage();
  }


  /**
   * Favorite Move Sort
   * @param favoriteList
   */
  moveSortFavorite(callback: (needCancelFavorite: string[]) => void) {
    HiLog.i(TAG, `moveSortFavorite start. selectNumber: ${this.selectNumber},
      contactsTotal: ${this.contactsTotal}, favoriteList.lenght:  ${this.favoriteList.length}`);
    let lastIndex = this.contactsTotal - this.selectNumber;
    let needCancelFavorite: string[] = [];
    let favorites: FavoriteBean[] = [];
    if (lastIndex > 0) {
      for (let i = 0; i < this.favoriteList.length; i++) {
        if (this.selectedContacts.has(this.favoriteList[i].contactId)) {
          needCancelFavorite.push(this.favoriteList[i].contactId);
        } else {
          favorites.push(this.favoriteList[i]);
        }
      }
      if (this.isOnMoved) {
        this.sortFavorite(favorites, needCancelFavorite, callback);
      } else {
        callback(needCancelFavorite);
      }
    } else {
      if (callback) {
        this.favoriteDataSource.getFavoriteList().forEach((favorite) => {
          needCancelFavorite.push(favorite.contactId);
        })
        callback(needCancelFavorite);
      } else {
        AppStorage.SetOrCreate<number>('editFavoriteDrag', 1);
        this.pathInfos.pop();
      }
    }
    HiLog.i(TAG, 'moveSortFavorite end.');
  }

  /**
   * Favorite Move Sort
   * @param favoriteList
   */
  sortFavorite(favorites: FavoriteBean[], needCancelFavorite?: string[],
    callback?: (needCancelFavorite: string[]) => void) {
    HiLog.i(TAG, `sortFavorite start. selectNumber: ${this.selectNumber}, contactsTotal: ${this.contactsTotal}`);
    let favoriteOrder = 0;
    // 记录需要发送请求的数量
    let requestsToBeSent = 0;
    // 记录已经发送请求的数量
    let requestsCompleted = 0;
    const needCancelFavoriteArray = needCancelFavorite || [];
    favorites.forEach((favorite) => {
      favoriteOrder++;
      // 检查当前项的favoriteOrder是否已更新，如果没有更新则发送请求
      if (favorite.favoriteOrder !== favoriteOrder.toString()) {
        requestsToBeSent++;
        let favoriteForm: Record<string, string | number> = {}
        favoriteForm.id = favorite.contactId;
        favoriteForm.favoriteOrder = favoriteOrder;
        const moveSortFavoriteData: Record<string, common.UIAbilityContext | string> = {
          'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          'favoriteForm': JSON.stringify(favoriteForm)
        }
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('moveSortFavorite',
          moveSortFavoriteData, () => {
            requestsCompleted++;
            if (requestsCompleted === requestsToBeSent) {
              if (callback) {
                callback(needCancelFavoriteArray);
              } else {
                AppStorage.SetOrCreate<number>('editFavoriteDrag', 1);
                this.pathInfos.pop(false);
              }
            }
          })
      }
    })
    if (requestsToBeSent == 0 && this.selectNumber == 0) {
      this.cancelEditFavorite()
    } else if (requestsToBeSent == 0 && needCancelFavoriteArray.length > 0 && callback) {
      callback(needCancelFavoriteArray);
    }
    this.isOnMoved = false;
    HiLog.i(TAG, 'sortFavorite end.');
  }

  /**
   * Cancel Editing
   */
  cancelEditFavorite() {
    AppStorage.setOrCreate<number>('cancelEditFavorite', 2);
    if (AppStorage.get('breakpoint') === 'sm' || AppStorage.get('isShowSmartWindow')) {
      this.pathInfos?.clear(false);
    } else {
      FavoriteListPresenter.getInstance().setPageShow(true);
      if (AppStorage.get('splitStatus') === SplitStatus.VERTICAL_SPLIT) {
        this.pathInfos?.clear(false);
        return;
      }
      FavoriteListPresenter.getInstance().toDefaultPage();
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, `EditFavoriteListPresenter aboutToAppear !  favoriteList length: ${this.favoriteList.length}`);
    this.favoriteDataSource.refresh(this.favoriteList);
    this.contactsTotal = this.favoriteList.length;
    if (this.selectedContacts.length > 0) {
      emitter.emit(EditFavoriteListPresenter.EDIT_FAVORITELIST_ITEM_CHECKED);
    }
    this.refreshPageMessage();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'EditFavoriteListPresenter aboutToDisappear!');
    this.favoriteDataSource.refresh(this.favoriteList);
  }

  onPageShow() {
    HiLog.i(TAG, 'EditFavoriteListPresenter onPageShow!');
  }

  onPageHide() {
    HiLog.i(TAG, 'EditFavoriteListPresenter onPageCover!');
  }
}