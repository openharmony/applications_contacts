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

import ArrayList from '@ohos.util.ArrayList';
import { DynamicLoader, HiLog } from '../../../../../../common';
import { FavoriteBean } from '../../model/bean/FavoriteBean';
import FavoriteDataSource from '../../model/bean/FavoriteDataSource';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import emitter from '@ohos.events.emitter';
import {
  ContactDetailParam,
  CustomizedParams,
  DeleteFavoriteParam,
  DisplayNameParam,
  EditFavoriteParam,
  FavoriteListParam,
  RequestParam,
  SelectContactParam,
  UsuallyListParam
} from '../../model/type';
import { CallLog } from '../../../../../../feature/call';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import { ContactVo } from '../../model/bean/ContactVo';
import MorandiColor from '../../model/bean/MorandiColor';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import sim from '@ohos.telephony.sim';
import { DSDS_MODE_V2 } from '../../component/mutisim/DsdaConstants';
import { ProfileUtils } from '../../util/ProfileUtils';
import { FavoriteListBean } from '../../model/bean/FavoriteListBean';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import IndexPresenter from '../IndexPresenter';
import deviceInfo from '@ohos.deviceInfo';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import ContactAbilityModel from '../../model/ContactAbilityModel';
import { contact } from '@kit.ContactsKit';
import DotUtil from '../../util/DotUtil';
import ContactListPresenter from '../contact/ContactListPresenter';

const TAG = 'FavoriteListPresenter  ';
const CHECK_PATH_FOR_DEFAULT_SELECT_CONTACT = ['ContactDetail', 'addFavoriteList', 'editFavoriteList'];
const ARRAY_COUNT = 2;
const FAVORITE_ADD_CONTACT_EVENT = 'FAVORITE_ADD_CONTACT_EVENT';
/**
 * Favorite List Logical Interface Model
 */
export default class FavoriteListPresenter {
  public pathInfos: NavPathStack = new NavPathStack();
  private static sInstance: FavoriteListPresenter;
  public static EMITTER_FAVORITE_DELETE = 'emitterFavoriteDelete';
  public static EMITTER_FAKE_FAVORITE_DELETE = 'emitterFakeFavoriteDelete';
  public favoriteList: FavoriteBean[] = [];
  public usuallyList: FavoriteBean[] = [];
  public favoriteCount: number = 0;
  public isEmptyGroup: boolean = true;
  public favoriteDataSource: FavoriteDataSource = new FavoriteDataSource();
  public isShow: boolean = false;
  public isEditSelectList: FavoriteBean[] = [];
  public usuallySelectArray = new ArrayList<string>();
  public displayNameList: string[] = [];
  public usuallyDisplayNameParameterList: string[] = [];
  public usuallyPhoneParameterList: string[] = [];
  public usuallyTotalCount: number = 0;
  // 记录当前的收藏页面，总的记录数量，用于判断显示无收藏还是收藏列表
  public favoriteListListLen: number = -1//无收藏页面还是列表页面
  public SINGLE_BATCH_NUMBER: number = 500;
  private deleteStatus = false;
  /**
   * Default value should be DSDS mode
   */
  public dsdsMode: number = DSDS_MODE_V2;
  public debounceTimer: number | null = null;
  // share content
  public shareContent: string = '';
  private addFavoriteParams: CustomizedParams = {
    ISSELECT: 0,
    ISADD: 1
  };

  constructor() {
    // Read dsds config!
    sim.getDsdsMode().then(data => {
      HiLog.i(TAG, 'getDsdsMode: ' + data);
      this.dsdsMode = data;
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'getDsdsMode error: ', error.message);
    });
  }

  public static getInstance(): FavoriteListPresenter {
    if (FavoriteListPresenter.sInstance == null) {
      HiLog.i(TAG, 'FavoriteListPresenter getInstance!');
      FavoriteListPresenter.sInstance = new FavoriteListPresenter();
    }
    return FavoriteListPresenter.sInstance;
  }

  // 联系人数据变更触发回调
  public onContactChange = () => {
    HiLog.i(TAG, 'onContactChange refresh');
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      HiLog.i(TAG, 'onDataChange requestItem')
      this.requestItem();
    }, 200)
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear!');
    ContactRepository.getInstance().registerDataChangeObserver(this.onContactChange);
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear!');
    ContactRepository.getInstance().unRegisterDataChangeObserver(this.onContactChange);
  }

  refreshFavorite(): Promise<FavoriteBean[]> {
    HiLog.i(TAG, 'refreshFavorite start.');
    return new Promise((resolve) => {
      const actionData: Record<string, number> = {};
      actionData.favorite = 1;
      const requestParam: RequestParam<Record<string, number>> = {
        actionData: actionData,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      }
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('getAllFavorite', requestParam, (result: FavoriteBean[]) => {
          HiLog.i(TAG, 'refreshFavorite sc.');
          if (result.length > 0) {
            result[0].isUsuallyShow = true;
          }
          resolve(result)

        })
      HiLog.i(TAG, 'refreshFavorite end.');
    })

  }
//Refresh Usually Contacts
  refreshUsually() {
    HiLog.i(TAG, 'refreshUsually start.');
    const actionData: Record<string, number> = {};
    actionData.favorite = 0;
    const requestParam: RequestParam<Record<string, number>> = {
      actionData: actionData,
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllUsually', requestParam, (result: CallLog[]) => {
        HiLog.i(TAG, 'refreshUsually sc.');
        let resultCount = result.length;
        if (resultCount > 0) {
          let usuallySelectDisplayNameListCount = this.usuallySelectArray.length;
          this.usuallyTotalCount = 0;
          let usuallyContainDisplayNameCount: number = 0;
          this.displayNameList = [];
          this.usuallyDisplayNameParameterList = [];
          this.usuallyPhoneParameterList = [];
          for (let i = 0; i < resultCount; i++) {
            if ('' !== result[i].displayName && this.displayNameList.indexOf(result[i].displayName) === -1) {
              this.displayNameList.push(result[i].displayName);
              if (this.usuallySelectArray.has(result[i].displayName)) {
                usuallyContainDisplayNameCount++;
              }
            }
          }
          if (usuallyContainDisplayNameCount === this.displayNameList.length &&
            usuallyContainDisplayNameCount === usuallySelectDisplayNameListCount) {
            this.refreshFavoriteList(this.favoriteList);
            return;
          }
          for (let i = 0; i < resultCount; i++) {
            if ('' !== result[i].displayName) {
              if (this.usuallyTotalCount < 10) {
                if (usuallySelectDisplayNameListCount > 0) {
                  if (!this.usuallySelectArray.has(result[i].phoneNumber)) {
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
                if (this.usuallyPhoneParameterList.length > 0) {
                  this.getDisplayNamesFindUsually(this.usuallyDisplayNameParameterList, this.usuallyPhoneParameterList);
                } else {
                  this.refreshFavoriteList(this.favoriteList);
                }
                return;
              }
            }
          }
          if (this.usuallyPhoneParameterList.length > 0) {
            this.getDisplayNamesFindUsually(this.usuallyDisplayNameParameterList, this.usuallyPhoneParameterList);
          } else {
            this.refreshFavoriteList(this.favoriteList);
          }
        } else {
          // refresh list
          this.refreshFavoriteList(this.favoriteList);
        }
      })
    HiLog.i(TAG, 'refreshUsually end.');
  }

  /**
   * 常用联系人刷新
   * 常用联系人功能已删除
   */
  refreshNewUsually(): Promise<FavoriteBean[]> {
    HiLog.i(TAG, 'refreshNewUsually start.');
    return new Promise((resolve) => {
      const actionData: Record<string, number> = {};
      actionData.favorite = 0;
      const requestParam: RequestParam<Record<string, number>> = {
        actionData: actionData,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
      }
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('getAllUsuallyByRawContact', requestParam, (result: FavoriteBean[]) => {
          HiLog.i(TAG, 'refreshNewUsually sc');
          resolve(result)
        })
    })
  }

  getDisplayNamesFindUsually(displayNameList: string[], usuallyPhoneList: string[]) {
    HiLog.i(TAG, 'getDisplayNamesFindUsually start.');
    const displayNameParam: DisplayNameParam = {
      displayName: displayNameList,
      usuallyPhone: usuallyPhoneList,
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getDisplayNamesFindUsually', displayNameParam, (result: FavoriteBean[]) => {
        let totalCount = result.length;
        HiLog.i(TAG, 'getDisplayNamesFindUsually sc');
        if (null != result && totalCount > 0) {
          this.favoriteList = this.favoriteList.concat(result);
          this.refreshFavoriteList(this.favoriteList);
        }
      })
    HiLog.i(TAG, 'getDisplayNamesFindUsually end.');
  }

  /**
   * 解析picker页选中的联系人
   *
   * @param data data
   * @returns
   */
  public async parseContactForResult(data: contact.Contact[]): Promise<void> {
    if (!data || data.length === 0) {
      HiLog.i(TAG, `parseContactForResult data invalid.`);
      return;
    }
    HiLog.i(TAG, `parseContactForResult len=${ContactListPresenter.getInstance().total},${this.favoriteDataSource.totalCount()}`);
    let contactIds: string[] = [];
    let addFavoriteCount: number = 0;
    for (let i = 0; i < data.length; i++) {
      let contactId = data[i]?.id;
      if (contactId) {
        contactIds.push((contactId).toString());
        addFavoriteCount++;
      } else {
        HiLog.i(TAG, `parseContactForResult data contactId invalid.`);
      }
    }
    // 联系人打点--收藏联系人添加
    if (contactIds.length === (ContactListPresenter.getInstance().total - this.favoriteDataSource.totalCount())) {//
      this.addFavoriteParams.ISSELECT = 2;
    } else if (contactIds.length > 1) {
      this.addFavoriteParams.ISSELECT = 1;
    } else if (contactIds.length === 1) {
      this.addFavoriteParams.ISSELECT = 0;
    }
    this.addFavoriteParams.ISADD = 1;
    DotUtil.getInstance().contactDot(this.addFavoriteParams, FAVORITE_ADD_CONTACT_EVENT);
    HiLog.i(TAG, `parseContactForResult len=${contactIds.length}`);
    if (contactIds.length === 0) {
      HiLog.e(TAG, 'updateFavoriteList db, contactIds is empty.');
      return;
    }
    const favoriteListParam: FavoriteListParam = {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      favoriteList: JSON.stringify(contactIds),
      favorite: 1,
      favoriteOrder: addFavoriteCount + 1
    }
    // 更新数据库联系人收藏字段为1
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('updateFavoriteList', favoriteListParam, () => {
        AppStorage.setOrCreate<Array<FavoriteBean>>('addFavoriteContactData', []);
        HiLog.i(TAG, 'addFavoriteList picker success refresh.');
      })
    HiLog.i(TAG, 'parseContactForResult end.');
  }

    /**
   * Refresh Favorite List; 收藏联系人查询，会刷新；常用联系人查询查询，也会刷新
   * @param favoriteList
   */
  refreshFavoriteList(favoriteList: FavoriteBean[]) {
    HiLog.i(TAG, 'refreshFavoriteList start.');
    if (this.favoriteCount < this.favoriteList.length) {
      this.favoriteList[this.favoriteCount].isUsuallyShow = true;
    }
    this.favoriteDataSource.refresh(favoriteList);
    let innerEvent: emitter.InnerEvent = {
      eventId: 100,
      priority: emitter.EventPriority.HIGH
    };

    this.favoriteListListLen = this.favoriteList.length
    AppStorage.setOrCreate('favoriteListLength', this.favoriteListListLen)
    emitter.emit(innerEvent, {
      data: {
        'favoriteListListLen': this.favoriteList.length
      }
    });
  }

  goContactDetail(contactId: string) {
    HiLog.w(TAG, 'goContactDetail start.');
    const params: ContactDetailParam = {
      sourceHasId: true,
      contactId: contactId
    };
    DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
      if (AppStorage.get('breakpoint') !== 'sm') {
        this.pathInfos.replacePathByName('ContactDetail', params);
      } else {
        this.pathInfos.pushPathByName('ContactDetail', params);
      }
    }).catch((error: Error) => {
      HiLog.e(TAG, `DynamicLoader fire failed: ${error?.message}`);
    });
  }

  /**
   * 显示收藏tab
   * @param show
   */
  async setPageShow(show: boolean, fullScreenPaddingBottom?: number) {
    if (show) {
      HiLog.i(TAG, 'onPageShow!');
      AppStorage.setOrCreate('selectFavoriteContact', '')
      let deleteContact: number | undefined = AppStorage.get<number>('DetailDeleteContact');
      let editFavoriteDrag: number | undefined = AppStorage.get<number>('editFavoriteDrag');
      // 添加收藏的列表
      let addFavoriteContactData: ContactVo[] | undefined = AppStorage.get<Array<ContactVo>>('addFavoriteContactData');
      let deleteFavoriteContactData: string[] | undefined = AppStorage.get<Array<string>>('deleteFavoriteContactData');
      let deleteUsuallyContactData: string[] | undefined = AppStorage.get<Array<string>>('deleteUsuallyContactData');
      if (deleteUsuallyContactData !== undefined && deleteUsuallyContactData.length > 0) {
        HiLog.i(TAG, 'onPageShow deleteUsuallyContactData!');
        this.deleteUsually(deleteUsuallyContactData);
        AppStorage.setOrCreate<Array<string>>('deleteUsuallyContactData', []);
      }

      let cancelEditFavorite: number | undefined = AppStorage.get<number>('cancelEditFavorite');
      let that = this;
      if (deleteContact !== undefined && deleteContact === 1) {
        HiLog.i(TAG, 'onPageShow deleteContact!');
        this.requestItem();
        AppStorage.setOrCreate<number>('DetailDeleteContact', 0);
      } else if (editFavoriteDrag !== undefined && editFavoriteDrag === 1) {
        HiLog.i(TAG, 'onPageShow editFavoriteDrag!');
        this.requestItem();
        AppStorage.setOrCreate<number>('editFavoriteDrag', 0);
      } else if (addFavoriteContactData !== undefined && addFavoriteContactData.length > 0) {
        // 添加新的收藏联系人，跳转回收藏列表场景
        HiLog.i(TAG, 'onPageShow addFavoriteContactData!');
        // 新添加收藏的联系人的id
        let selectFavoriteIdList: Array<string> = [];
        addFavoriteContactData.forEach(contact => {
          selectFavoriteIdList.push(contact.contactId);
        })

        if (ArrayUtil.isEmpty(this.favoriteList)) {
          // 根据addFavoriteContactData生成常用联系人信息，在数据库更新常用联系人
          this.addFavoriteInfoLocal(addFavoriteContactData, selectFavoriteIdList);
        } else {
          // 更新畅连联系人信息
          this.addFavoriteInfo(selectFavoriteIdList, fullScreenPaddingBottom);
        }
        // 设置为添加收藏为空集合
        AppStorage.setOrCreate<Array<FavoriteBean>>('addFavoriteContactData', []);
      } else if (cancelEditFavorite !== undefined && 2 === cancelEditFavorite) {
        HiLog.i(TAG, 'onPageShow cancelEditFavorite!');
        this.cancelAllFavoriteSelectInfo();
        AppStorage.setOrCreate<number>('cancelEditFavorite', 0);
      } else if (deleteFavoriteContactData !== undefined && deleteFavoriteContactData.length > 0) {
        HiLog.i(TAG, 'onPageShow deleteFavoriteContactData!');
        this.deleteFavorite(deleteFavoriteContactData);
        AppStorage.setOrCreate<Array<string>>('deleteFavoriteContactData', []);
      } else {
        if (this.isShow === show) {
          HiLog.w(TAG, 'setPageShow not change.');
        } else {
          HiLog.i(TAG, 'onPageShow else!');
          this.requestItem();
        }
      }
    }
    this.isShow = show;
  }

  cancelAllFavoriteSelectInfo() {
    HiLog.i(TAG, 'cancelAllFavoriteSelectInfo start.');
    this.isEditSelectList = [];
  }

  requestItem() {
    HiLog.i(TAG, 'requestItem start.');
    this.refreshFavorite().then((favoriteList: FavoriteBean[]) => {
        this.favoriteCount = favoriteList.length;
        this.favoriteList = favoriteList;
        this.refreshFavoriteList(this.favoriteList);
        if (!this.deleteStatus) {
          this.favoriteDataSource.notifyDataReloadOperation();
        } else {
          this.deleteStatus = false;
        }
        if (AppStorage.get('mainTabsIndex') === IndexPresenter.getInstance().favoriteIndex) {
          this.emitFavoriteDefaultSelectedContact();
        }
    })
  }

  addFavorite() {
    const params: SelectContactParam = {
      addFavorite: 0,
      selectType: 1
    };
    DynamicLoader.getInstance().fire(DynamicLoader.ADD_FAVORITE_LIST_PAGE).then(() => {
      this.pathInfos?.pushPathByName('addFavoriteList', params);
    }).catch((error: Error) => {
      HiLog.e(TAG, `DynamicLoader fire failed: ${error?.message}`);
    });
  }

  editFavorite() {
    const params: EditFavoriteParam = {
      favoriteList: this.favoriteList
    };
    DynamicLoader.getInstance().fire(DynamicLoader.EDIT_FAVORITE_LIST_PAGE).then(() => {
      this.pathInfos?.pushPathByName('editFavoriteList', params);
    }).catch((error: Error) => {
      HiLog.e(TAG, `DynamicLoader fire failed: ${error?.message}`);
    });
  }

  updateFavorite(favoriteStatus: number, contactId: number, item: FavoriteListBean) {
    HiLog.w(TAG, 'updateFavorite start.');
    setTimeout(() => {
      let favoriteForm: Record<string, number> = {};
      favoriteForm.id = contactId;
      favoriteForm.favorite = favoriteStatus;
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('updateFavorite', {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          favoriteForm: JSON.stringify(favoriteForm)
        }, (arg: number) => {
          HiLog.w(TAG, 'updateFavorite success.');
          this.favoriteDataSource.deleteFavoriteContactId(contactId.toString());
          if (AppStorage.get('breakpoint') !== 'sm') {
            AppStorage.setOrCreate('updateFavoriteDetailId', contactId);
          }
          this.deleteStatus = true;
        })
    }, 300)
    if (favoriteStatus === 0) {
      let index = this.favoriteDataSource.indexOf(item);
      this.favoriteDataSource.remove(index);
    }
  }

  /**
   * 添加常用联系人
   * @param addFavoriteContactData
   * @param selectFavoriteIdList
   */
  addFavoriteInfoLocal(addFavoriteContactData: ContactVo[], selectFavoriteIdList: string[]) {
    let favoriteList: Array<FavoriteBean> = [];
    addFavoriteContactData.forEach((contact, i) => {
      let favorite = new FavoriteBean('', -1, '', '', '', '', MorandiColor.color[0], true, '', false, 0, '');
      favorite.contactId = contact.contactId;
      favorite.isCommonUseType = 0;
      favorite.displayName = contact.showName;
      favorite.namePrefix = contact.namePrefix;
      favorite.nameSuffix = contact.nameSuffix;
      favorite.position = contact.position;
      favorite.portraitColor = MorandiColor.color[Math.abs(Number.parseInt(favorite.contactId)) % 6];
      favorite.isUsuallyShow = false;
      favorite.favoriteOrder = (this.favoriteCount + 1 + i) + '';
      favorite.favorite = 1;
      favorite.setShowName();
      favorite.setHeadChar();
      favoriteList.push(favorite);
    })

    this.favoriteList = favoriteList;
    this.favoriteCount = this.favoriteList.length;
    this.refreshFavoriteList(favoriteList);

    HiLog.i(TAG, 'addFavoriteInfoLocal start.');
    const favoriteListParam: FavoriteListParam = {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      favoriteList: JSON.stringify(selectFavoriteIdList),
      favorite: 1,
      favoriteOrder: this.favoriteCount + 1
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('updateFavoriteList', favoriteListParam, () => {
        AppStorage.setOrCreate<Array<FavoriteBean>>('addFavoriteContactData', []);
        HiLog.i(TAG, 'addFavoriteList success refresh.');
      })
    HiLog.i(TAG, 'addFavoriteInfoLocal end.');
  }

  /**
   * 添加收藏信息，添加完成后，重新查询收藏信息
   * @param selectFavoriteIdList
   */
  async addFavoriteInfo(selectFavoriteIdList: string[], fullScreenPaddingBottom?: number, context?: UIContext) {
    HiLog.w(TAG, 'addFavoriteInfo start.');
    let favoriteOrder = await ContactAbilityModel.queryFavoriteOrder()
    const favoriteListParam: FavoriteListParam = {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      favoriteList: JSON.stringify(selectFavoriteIdList),
      favorite: 1,
      favoriteOrder: favoriteOrder + 1
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('updateFavoriteList', favoriteListParam, () => {
        AppStorage.SetOrCreate<Array<string>>('addFavoriteContactData', [])
        HiLog.i(TAG, 'addFavoriteList success refresh.');
        // 重新查询收藏列表，确保UI正确更新
        this.requestItem();
        try {
          let isThemeActive: boolean = AppStorage.get('isThemeActive') as boolean;
          if (context) {
            context.getPromptAction().showToast({
              message: $r('app.string.favorite_contacts'),
              textColor: isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined,
              bottom: (fullScreenPaddingBottom ? fullScreenPaddingBottom : 0) + 80,
              backgroundColor: isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
              backgroundBlurStyle: isThemeActive ? BlurStyle.NONE : undefined
            })
          } else {
            promptAction.showToast({
              message: $r('app.string.favorite_contacts'),
              bottom: (fullScreenPaddingBottom ? fullScreenPaddingBottom : 0) + 80,
            });
          }
        } catch (err) {
          HiLog.e(TAG, 'addFavoriteInfo, prompt.showToast err: ' + err?.message + ', stack: ' + err?.stack);
        }
      })
    HiLog.w(TAG, 'addFavoriteInfo end.');
  }

  async deleteFavorite(deleteFavoriteIdList: string[]) {
    HiLog.w(TAG, 'deleteFavorite start.');
    let array: string[][] = ArrayUtil.cutArray(deleteFavoriteIdList, this.SINGLE_BATCH_NUMBER);
    if (array.length >= ARRAY_COUNT) {
      emitter.emit(FavoriteListPresenter.EMITTER_FAKE_FAVORITE_DELETE);
    }
    for (let i = 0; i < array.length; i++) {
      await this.batchDeletionBasic(array[i], array.length, i);
    }
    HiLog.w(TAG, 'deleteFavorite end.');
  }

  //数量过多时，分批删除的方法
  batchDeletionBasic(array: string[], arrayLength: number, index: number) {
    return new Promise<void>(resolve => {
      const favoriteListParam: DeleteFavoriteParam = {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        favoriteList: array,
      }
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('deleteFavorite', favoriteListParam, (result: number | undefined) => {
          if (result) {
            HiLog.w(TAG, 'deleteFavoriteList error:' + result);
          }
          if (arrayLength > 1) {
            this.sendProgressSubscription(favoriteListParam.favoriteList.length);
          }
          // Reset data for next use when executing the last batch
          if (index === (arrayLength - 1)) {
            AppStorage.SetOrCreate<Array<string>>('deleteFavoriteContactData', [])
            this.requestItem();
            HiLog.w(TAG, 'deleteContacts end');
          }
          resolve();
        });
      setTimeout(() => {
        this.favoriteDataSource.notifyDataReloadOperation();
      }, 200)
    })

  }

  sendProgressSubscription(selectedCounts: number) {
    let eventData: emitter.EventData = {
      data: {
        selectedCounts: selectedCounts,
      }
    }
    emitter.emit(FavoriteListPresenter.EMITTER_FAVORITE_DELETE, eventData);
  }

  deleteUsually(deleteUsuallyList: string[]) {
    HiLog.i(TAG, 'deleteUsually start.');
    const usuallyListParam: UsuallyListParam = {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      usuallyList: JSON.stringify(deleteUsuallyList),
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('updateUsuallyList', usuallyListParam, () => {
        HiLog.i(TAG, 'deleteUsually success.');
        AppStorage.SetOrCreate<Array<string>>('deleteUsuallyContactData', [])
        this.requestItem();
      })
    HiLog.i(TAG, 'deleteUsually end.');
  }

  longItemEditFavorite(favoriteList: FavoriteBean[], isEditSelectList: FavoriteBean[], favoriteBean: FavoriteBean) {
    HiLog.w(TAG, `longItemEditFavorite, defaultSelectId: ${favoriteBean.contactId}`);
    const params: EditFavoriteParam = {
      favoriteList: favoriteList,
      defaultSelectId: favoriteBean.contactId,
    };
    DynamicLoader.getInstance().fire(DynamicLoader.EDIT_FAVORITE_LIST_PAGE).then(() => {
      this.pathInfos?.pushPathByName('editFavoriteList', params, false);
    }).catch((error: Error) => {
      HiLog.e(TAG, `DynamicLoader fire failed: ${error?.message}`);
    });
  }

  toDefaultPage() {
    if (AppStorage.get('maintenanceMode')) {
      this.pathInfos?.clear(false);
      return;
    }
    HiLog.w(TAG,
      'pathInfos pushPathByName: FavoriteDefaultPage --- isShowSmartWindow:' + AppStorage.get('isShowSmartWindow'));
    if (!AppStorage.get('isNavigationModeSplit')) {
      return;
    }
    if (AppStorage.get('breakpoint') !== 'sm') {
      this.pathInfos?.clear(false);
      this.pathInfos?.pushPathByName('FavoriteDefaultPage', '', false);
    }
  }

  openFavoriteDefaultContactsDetail() {
    try {
      if (this.favoriteDataSource.getData(0) === null) {
        HiLog.w(TAG, 'this.favoriteDataSource.getData(0) is null');
        return;
      }
      if (this.favoriteListListLen === 0) {
        this.toDefaultPage();
      } else if (this.favoriteListListLen > 0) {
        this.goContactDetail(this.favoriteDataSource.getData(0)?.favorite.contactId as string);
      }
    } catch (err) {
      HiLog.e(TAG, `open favorite default contacts detail err: ${err?.message}, stack: ${err?.stack}`);
    }
  }

  emitFavoriteDefaultSelectedContact() {
    if (AppStorage.get('maintenanceMode')) {
      return;
    }
    try {
      if (!IndexPresenter.getInstance().isNeedDefaultSelectedDevice()) {
        return;
      }
      const allPaths = this.pathInfos.getAllPathName();
      if (allPaths.length > 1) {
        return;
      }
      if (this.isExistTargetPath(allPaths)) {
        return;
      }
      this.openFavoriteDefaultContactsDetail();
    } catch (err) {
      HiLog.e(TAG, `emit favorite default selected contact err: ${err?.message}, stack: ${err?.stack}`);
    }
  }

  isExistTargetPath(allPaths: string[]): boolean {
    if (CHECK_PATH_FOR_DEFAULT_SELECT_CONTACT.some(item => allPaths.includes(item))) {
      return true;
    }
    return false;
  }
}