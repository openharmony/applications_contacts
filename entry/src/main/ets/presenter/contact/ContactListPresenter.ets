/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { DelayTaskHelper } from '../../../../../../common/src/main/ets/util/DelayTaskHelper';
import { AlphabetIndexObj, ContactVo } from '../../model/bean/ContactVo';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import emitter from '@ohos.events.emitter';
import ContactListDataSource from '../../model/bean/ContactListDataSource';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import SearchContactsSource from '../../model/bean/SearchContactsSource';
import AlphabetIndexerPresenter from './alphabetindex/AlphabetIndexerPresenter';
import { LimitRefreshDataUtil } from '../../util/LimitRefreshDataUtil';
import { ContactBlobSource, ContactIdParam, CustomizedParams, PageLimit, ReqData, FindPhotoByIdActionData,
  CachedContactsPixelMapType, ContactsSearchResult} from '../../model/type';
import { AllContactGetParam, CountAlphabetIndex } from '../../model/type/ContactParams';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { DynamicLoader, sharedPreferencesUtils, StringUtil } from '../../../../../../common';
import ArrangeContactsPresenter from './settings/ArrangeContactsPresenter';
import taskpool from '@ohos.taskpool';
// import { updateSearchContactList } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepoTask';
import { SpeedDialItem } from '../../model/type/index';
import { SearchContactResult } from '../../model/bean/SearchContactResult';
import { BusinessError } from '@ohos.base';
import { initBlobSourceMap, PixelMapManager, getPixelMapFromFile, ContactPhotoVo } from '../../util/UserPhoto';
import { CommonEventUtil } from '../../../../../../common/src/main/ets/util/CommonEventUtil';
import { CommonEventConstants } from '../../../../../../common/src/main/ets/CommonEventConstants';
import CommonEventManager from '@ohos.commonEventManager';
import { mergeDuplicateContactsByUrl, queryRepeatContacts } from '../../task/TaskService';
import { PhoneNum } from '../../../../../../feature/call/src/main/ets/entity/CallLogTemp';
import DotUtil from '../../util/DotUtil';
import { ProfileUtils } from '../../util/ProfileUtils';
import { CallLogSearchBo } from '../../model/bean/CallLogSearchBo';
import dataShare from '@ohos.data.dataShare';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { ChangeIdInfo, ListenChangeContactUtil } from '../../util/ListenChangeContactUtil';
import { AppStorageConstant } from '../../../../../../common/src/main/ets/AppStorageConstant';
import ContactAbilityModel, { searchContactByPhoneNumAndDisplayNameForLimit } from '../../model/ContactAbilityModel';
import DialerPresenter from '../dialer/DialerPresenter';
import dotCommon, { faultContactParams } from '../../util/DotCommon';
import DialerConstant from '../../data/DialerConstant';
import SmsManagerUtils from '../../util/SmsManagerUtils';
import IndexPresenter from '../IndexPresenter';
import MorandiColor from '../../model/bean/MorandiColor'
import { resourceManager } from '@kit.LocalizationKit';
import { ResourceUtil } from '../../util/ResourceUtil';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { PreDefinedContactUtil } from '../../util/PreDefineContactUtil'
import { contact } from '@kit.ContactsKit';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import ContactListShowInfo from '../../model/bean/ContactListShowInfo';
import { ContactIdsParam } from './settings/ArrangeContactsPresenter';
import common from '@ohos.app.ability.common';
import { osAccount } from '@kit.BasicServicesKit';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import EmitterConstant from '../../data/EmitterConstant';
import { SystemModeController } from '../../util/SystemModeController';
import { accessibility } from '@kit.AccessibilityKit';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import TextUtils from '../../../../../../common/src/main/ets/util/TextUtils';
import { ContactsConstants } from '../../../../../../common/src/main/ets/ContactsConstants';

const TAG = 'ContactListPresenter  ';
const DELAY_TIME: number = 100;
const EMITTER_SEARCH_ID: number = 105;
const SEARCH_PAGE_NUMBER: number = 1000;
const FIRST_SEARCH_LIMIT: number = 10;
const SEVENTY_ONE: number = 71 * 60 * 1000;
const ONE_HOUR: number = 60 * 60 * 1000;
const SEARCH_RESULT_EVENT: string = 'SEARCH_RESULT_EVENT';
const hasComma: RegExp = new RegExp(',', 'g');
const COMMA_REPLACE: string = '&comma;';
const labelMatch: RegExp = new RegExp('<|>', 'gi');
const CONTACT_SEARCH_OFFSET = 100;

// Type of the control that is clicked in the contact list.
export enum ContactClickType {
  LOGIN_IN,
  IMPORT_CONTACT,
  CREATE_CONTACT,
  SCAN_CARD
}

const prefixList: string[] =
  ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
    'W', 'X', 'Y', 'Z'];
const ONE_MONTH: number = 60 * 60 * 24 * 30 * 1000;
const TWO_DAY: number = 60 * 60 * 24 * 2 * 1000;
const NOTIFY_MODIFY_TYPE_NOT_MODIFY = 'NOT_MODIFY';
const CONTACT_LIST_SEARCH_EVENT = 'CONTACT_LIST_SEARCH_EVENT';

// Contact List Logical Interface Model
export default class ContactListPresenter {
  public task?: taskpool.Task;
  public searchDbTask?: taskpool.Task;
  public pathInfos?: NavPathStack;
  private static sInstance: ContactListPresenter | null;
  public getAllContactsError: boolean = false;
  public queryContactsType: string = 'all';
  public isEmptyGroup: boolean = true;
  public settingsMenu: Resource[] = [$r('app.string.call_setting_type_setting')];
  /**
   * 联系人列表数据源DataSource
   */
  public contactListDataSource: ContactListDataSource = new ContactListDataSource();
  public searchContactsSource: SearchContactsSource = new SearchContactsSource();
  public myCardIndex: number = 0;
  // 是否显示
  public isShow: boolean = false;
  public initStarted: boolean = false;
  public contactSearchList: SearchContactResult[] = [];
  public contactSearchCount: number = 0;
  public contactSearchNumber: number = 0;
  public tempValue: string = '';
  public isSearchBackgroundColor: boolean = true;
  // isSearchPage
  public isSearchPage: boolean = false;
  public inputKeyword: string = '';
  public alphabetIndexPresenter: AlphabetIndexerPresenter = AlphabetIndexerPresenter.getInstance();
  // contactSearch parameters
  public screenHeight: number = 0;
  public theoreticalHeight: number = 3120;
  public isFullTitle: boolean = true;
  public refreshState?: () => void = () => {
  }
  public refreshDeleteContact?: () => void = () => {
  }
  public charingFlag: boolean = false;
  public screenOffFlag: boolean = false;
  public noUseFlag: boolean = false;
  public subscriberList: CommonEventManager.CommonEventSubscriber[] = [];
  public timestamp: number = 0;
  public workerId: number = 0;
  public total: number = -1;
  public contactsSize: number = 0;
  public emitterId: number = 108;
  public deletingContact: boolean = false;
  public isAutoMerge: boolean = false;
  public repeatNum: number = 0;
  // 相同联系人的id的集合，如[[1,2], [3,4]]；id 1和2比较为重复联系人，id 3和4比较为重复联系人，且他们都是相同的名字aaa
  // 相同联系人的id的集合，如[[6,7], [8,9]]；id 6和7比较为重复联系人，id 8和9比较为重复联系人，且他们都是相同的名字bbb
  // 是否首次自动合并
  public isFirstAutoMerge: boolean = true;
  // 更新的联系人index集合
  public updateContactIndexList: number[] = [];
  public accountType: number = -1;
  public autoMergeDialogController: CustomDialogController = new CustomDialogController({
    builder: null
  });
  public apresenter: ArrangeContactsPresenter = ArrangeContactsPresenter.getInstance();
  public debounceTimer: number | null = null;
  public contactSearchDebounceTimer: number = -1;
  public dialerSearchDebounceTimer: number = -1;
  // 刷新联系人列表，根据不携带id的消息
  public refreshContactListByNoIdMsgTimer: number | null = null;
  public isCancel: boolean = false;
  public autoMergeCancelState: boolean = false;
  public alwaysAutoMerge: boolean = false;
  public searchResultParams: CustomizedParams = {
    ISRESULT: 0
  };
  public static SINGLE_REFRESH_MAX_SIZE = 100;
  // 搜索服务初始化状态
  public searchSerInitStatus: number = -1;
  // 点击联系人tab页，就开始查询联系人列表页数据
  public initRequestItem: boolean = false;
  // 提前初始化第一页数据
  public startPreInitFlag: boolean = false;
  public shareContent: string = '';
  public curBp = '';
  public limitDataRefresh: LimitRefreshDataUtil<PageLimit, ContactVo[]> | undefined = undefined;
  public localId = -1;
  // 启动是否从联系人图标进入
  public intoFromContactIconFlag = false;

  public contactPhotoLimitRefresh:
  LimitRefreshDataUtil<FindPhotoByIdActionData, ContactPhotoVo[]> | undefined = undefined;

  public firstItemIndex: number = -1;
  public lastItemIndex: number = -1;
  public hasCachePhotoFinish: boolean = false;
  public hasScrollIndexCachePhotoFinish: boolean = false;
  public queryAllEnd: boolean = true;

  private scroller: Scroller = new Scroller();

  public isSameAccountWithLocal(userId: number): boolean {
    // 和本用户空间是相同的空间信息
    if (userId === this.localId) {
      return true;
    } else {
      return false;
    }
  }

  private searchCustomParams: CustomizedParams = {};

  /**
   * 解析changeInfo
   * @param changeInfo
   * @returns
   */
  parseChangeIdInfo(changeInfo?: dataShare.ChangeInfo): ChangeIdInfo {
    HiLog.w(TAG, 'parseChangeIdInfo');
    let changeIdInfo: ChangeIdInfo = new ChangeIdInfo();
    if (changeInfo === undefined) {
      return changeIdInfo;
    }
    if (changeInfo.values.length <= 0) {
      return changeIdInfo;
    }

    let valuesBucket: ValuesBucket = changeInfo.values[0];
    if (valuesBucket === undefined) {
      HiLog.w(TAG, 'valuesBucket has no value!');
      return changeIdInfo;
    }
    let uriInfo: string = changeInfo?.uri;
    // 如果通知带userId信息，判断userId与当前的localUserId是否相同，相同才处理此通知
    let userIdStr = valuesBucket['userId'] as string;
    if (!StringUtil.isEmpty(userIdStr)) {
      let userId = Number(userIdStr);
      if (!this.isSameAccountWithLocal(userId)) {
        HiLog.w(TAG, `notify userId:${userId} not equal localId: ${this.localId}, changeInfo type: ${changeInfo?.type}`);
        return changeIdInfo;
      }
    }
    let updateIdStr = valuesBucket['updateIdStr'] as string;
    let delIdStr = valuesBucket['delIdStr'] as string;
    let notifyModifyType = valuesBucket['notifyModifyType'] as string;
    if (delIdStr !== undefined && delIdStr.length > 0) {
      changeIdInfo.delRawContactIdArr = delIdStr.split(',');
    }
    if (updateIdStr !== undefined && updateIdStr.length > 0) {
      changeIdInfo.updateRawContactIdArr = updateIdStr.split(',');
    }
    if (notifyModifyType !== undefined) {
      changeIdInfo.notifyModifyType = notifyModifyType;
    }
    return changeIdInfo;
  }

  /**
   * 刷新列表
   */
  public refreshContactList() {
    HiLog.w(TAG, 'onContactChangeRefresh')
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      this.requestMyCard();
      let changeIdInfo = ListenChangeContactUtil.getInstance().consumeChangeIds();
      if (changeIdInfo.delRawContactIdArr.length > 0 || changeIdInfo.updateRawContactIdArr.length > 0) {
        // 云同步场景
        if (changeIdInfo.delRawContactIdArr.length + changeIdInfo.updateRawContactIdArr.length >=
        ContactListPresenter.SINGLE_REFRESH_MAX_SIZE) {
          HiLog.w(TAG, 'onContactChange batch operate requestItem')
          this.requestItem();
          return;
        }
        // 刷新删除联系人，都是同步处理，不存在异步
        this.refreshContactListDatasourceAndPhotoByDelIds(changeIdInfo.delRawContactIdArr);
        // 刷新更新或新增列表
        let refreshContactListDataSourceByIdsPromise =
          this.refreshContactListDataSourceAndPhotoByIds(changeIdInfo.updateRawContactIdArr);
        // 刷新根据联系人列表刷新二级索引和数量信息
        refreshContactListDataSourceByIdsPromise.then(() => {
          this.refreshAlphabetIndexAndCount();
        });
      }
    }, this.curBp === 'sm' ? 800 : 0)
  }

  // 云同步刷新列表
  public refreshContactListByNoIdMsg() {
    // 刷新列表，之前的单个联系人id，不需要处理了
    ListenChangeContactUtil.getInstance().consumeChangeIds();
    clearTimeout(this.refreshContactListByNoIdMsgTimer);
    DelayTaskHelper.delayTask(async () => {
      HiLog.w(TAG, 'onContactChange requestItem' + ' time:' + (new Date()).valueOf());
      this.setCurrentPage(1);
      this.requestItem();
      AppStorage.setOrCreate('contactListUpdated', new Date().valueOf());
    }, DelayTaskHelper.DELAY_TASK_NAME_REFRESH_CONTACT_LIST_BY_NO_ID_MSG, 1000)
  }

  public onContactChange = (changeInfo?: dataShare.ChangeInfo) => {
    if (this.localId === -1) {
      let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
      accountManager.getOsAccountLocalId().then(localIdQuery => {
        this.localId = localIdQuery;
        this.onContactChangeHandleAfterQueryLocalId(changeInfo);
      }).catch((e: BusinessError) => {
        HiLog.e(TAG, `getOsAccountLocalId error: ${e?.code}, ${e?.message}`);
      });
    } else {
      this.onContactChangeHandleAfterQueryLocalId(changeInfo);
    }
  }

  // 联系人表变更，触发回调
  public onContactChangeHandleAfterQueryLocalId = (changeInfo?: dataShare.ChangeInfo) => {
    HiLog.w(TAG, 'onContactChange refresh type: ' + changeInfo?.type + ' time:' + (new Date()).valueOf());
    let importingSimContacts: boolean | undefined = AppStorage.get('importingSimContacts');
    CallLogSearchBo.getInstance().refreshCallChangeFlag();

    if (!importingSimContacts) {
      // 通知都有具体操作类型了
      let changeIdInfo = this.parseChangeIdInfo(changeInfo);
      // 云同步修改为rdb方式同步后，通知时不携带联系人id信息，对于没有带id的通知，查询所有数据方式刷新列表
      // 如果通知的信息不带id，可能属于未更新信息的通知，如果为更新，不刷新
      if (changeIdInfo.delRawContactIdArr.length <= 0 &&
        changeIdInfo.updateRawContactIdArr.length <= 0 &&
        changeIdInfo.notifyModifyType !== NOTIFY_MODIFY_TYPE_NOT_MODIFY
      ) {
        this.refreshContactListByNoIdMsg();
        return;
      }
      // 记录变更的联系人id
      ListenChangeContactUtil.getInstance().produceChangeIds(changeIdInfo);

      this.refreshContactList();
    }

    if (!StringUtil.isEmpty(this.inputKeyword)) {
      if (this.contactSearchDebounceTimer !== -1) {
        clearTimeout(this.contactSearchDebounceTimer);
        this.contactSearchDebounceTimer = -1;
      }
      this.contactSearchDebounceTimer = setTimeout(() => {
        HiLog.w(TAG, 'onContactChange refresh contactResult search!');
        // 搜索框搜索时更新联系人头像，需要更新头像缓存
        let contactSearchChangeId = AppStorage.get<string>('contactSearchChangeId') ?? '-1';
        if (contactSearchChangeId !== '-1') {
          HiLog.i(TAG, 'onContactChange updatePixelMapCache contactSearchChangeId ' + contactSearchChangeId);
          PixelMapManager.getInstance().updateSearchPixelMapCachedByContactId(contactSearchChangeId);
        }
        // this.getSearchContactResult(this.inputKeyword);
      }, 1000)
    }
    if ((AppStorage.get<string>(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE)?.length ?? 0) >= 1) {
      if (this.dialerSearchDebounceTimer !== -1) {
        clearTimeout(this.dialerSearchDebounceTimer);
        this.dialerSearchDebounceTimer = -1;
      }
      this.dialerSearchDebounceTimer = setTimeout(() => {
        HiLog.w(TAG, 'onContactChange refresh dialer search!');
        DialerPresenter.getInstance().dialerSearch();
      }, 800)
    }
  }
  public onNewContactToIndex = (newContactId: string, newContactIndex: number) => {
    if (AppStorage.get('breakpoint') != 'sm') {
      AppStorage.setOrCreate('selectContactId', newContactId);
    }
  };

  /**
   * 判断排序是否错误，打印排序错误的信息
   * @param contactVo
   */
  public judgeAndLogSortError(contactVo: ContactVo) {
    let sortFirstLetter = contactVo.namePrefix;
    let sort = contactVo.sort;
    // 特殊字符排序错误
    if (sortFirstLetter === '#') {
      if (sort !== '-1') {
        this.logSortError('# sort error', contactVo);
      }
      return;
    }
    // 无名氏处理
    if (sortFirstLetter === '...') {
      if (sort !== '99') {
        this.logSortError('... sort error', contactVo);
      }
      return;
    }
    // 字母处理
    if (sortFirstLetter.length > 0) {
      if (sortFirstLetter.charCodeAt(0).toString() !== sort) {
        this.logSortError(sortFirstLetter.charAt(0) + ' sort error', contactVo);
      }
      return;
    } else {
      this.logSortError('sortFirstLetter has no value, sort error', contactVo);
    }
  }

  public logSortError(title: string, contactVo: ContactVo) {
    HiLog.w(TAG, title + ', sort error sortFirstLetter: ' + contactVo.namePrefix + '  sort:' + contactVo.sort);
  }

  /**
   * 刷新联系人头像
   * @param contactIds
   */
  public refreshContactPhotoByIds(contactIds: string[]) {
    if (contactIds.length <= 0) {
      return;
    }
    let mapCopy = PixelMapManager.getInstance().getBlobSourceMapCopy();
    let refreshList: string[] = [];
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactIdWithBlobNotNull', {
        'contactIds': contactIds
      }, (result: ContactBlobSource[]) => {
        PixelMapManager.getInstance().initBlobSourceMapByIds(contactIds);

        if (result) {
          let map = new Map<string, ContactBlobSource>();
          result.forEach((item: ContactBlobSource) => {
            map.set(item.contactId, item);

            let oldBlobsourceItem: ContactBlobSource | undefined = mapCopy.get(item.contactId);
            let oldBlobsource : number = oldBlobsourceItem ? oldBlobsourceItem.blobSource : -1;
            if (item.blobSource != oldBlobsource) {
              refreshList.push(item.contactId)
            }
          })
          // 更新map信息
          PixelMapManager.getInstance().updateBlobSourceMap(map, contactIds);

          for (const refreshId of refreshList) {
            AppStorage.setOrCreate('contactsWithModifiedPhoto', refreshId + '-' + new Date().getTime());
          }

          // 设置列表变更时间
          AppStorage.setOrCreate('contactListUpdated', new Date().valueOf());
        }
      });
  }

  /**
   * 删除信息
   * @param rawContactIdsDel
   */
  public refreshContactListDatasourceAndPhotoByDelIds(rawContactIdsDel: string[]) {
    if (rawContactIdsDel.length <= 0) {
      return;
    }
    let contactList = this.contactListDataSource.contactList;
    let contactIdsDel: string[] = [];
    rawContactIdsDel.forEach(rawContactIdDel => {
      // 从列表移除
      for (let i = contactList.length - 1; i >= 0; i--) {
        // 找到删除的元素，移除
        if (contactList[i].nameRawContactId === rawContactIdDel) {
          contactIdsDel.push(contactList[i].contactId);
          // 找到合适的位置，不需要后续处理了，移除
          this.removeAndRefreshIndex(i);
          break;
        }
      }
    });
    // 刷新头像信息
    // 更新map信息
    PixelMapManager.getInstance().updateBlobSourceMap(new Map, contactIdsDel);
    if (AppStorage.get('mainTabsIndex') === IndexPresenter.getInstance().contactIndex) {
      HiLog.w(TAG, 'IndexPresenter emitDefaultSelectedContact succ');
      IndexPresenter.getInstance().emitDefaultSelectedContact();
    }
  }

  /**
   * 移除元素，刷新列表
   * @param contactListDataSource
   * @param contactList
   * @param i
   */
  public removeAndRefreshIndex(i: number) {
    // # 存在111，222，333，显示为：  # 111，222，333
    // 修改111为444，会移除111，然后444被挪到后边，此时显示为: 222  333 444；少了#
    // 所以需要刷新移动元素的下一个元素
    let isHandleNextFlag = i + 1 < this.contactListDataSource.contactList.length;
    // i大于0，即i存在上一个元素，i移除后，i位置对应的下划线可能需要删除，就需要刷新
    let isHandlePreFlag = i > 0;
    this.contactListDataSource.contactList.splice(i, 1);
    this.contactListDataSource.notifyDataDelete(i);
    // 刷新i元素的下一个元素；此时移除了i，i的下一个元素的下标就变成了i，所以notify i
    if (isHandleNextFlag) {
      this.contactListDataSource.notifyDataChange(i);
    }
    if (isHandlePreFlag) {
      this.contactListDataSource.notifyDataChange(i - 1);
    }
  }

  /**
   * 根据变化的联系人id刷新联系人列表
   * @param rawContactIds
   */
  public refreshContactListDataSourceAndPhotoByIds(rawContactIds: string[]): Promise<boolean> {
    return new Promise((resolve, reject) => {
      if (rawContactIds.length <= 0) {
        resolve(true);
        return;
      }
      // 根据id查询所有联系人，这些联系人是刷新的
      let actionData: AllContactGetParam = new AllContactGetParam(0, Number.MAX_VALUE);
      actionData.rawContactIds = rawContactIds;
      const reqData: ReqData<AllContactGetParam> = {
        actionData: actionData
      }
      // 根据id查寻变化的联系人
      // 我的名片在此处被过滤
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('getAllContact', reqData, (contactVoListNew: ContactVo[]) => {
          // 数据库通知，通知的是rawContactId, 头像信息是contactId映射，查出contactId，在处理头像
          let updateContactIds: string[] = [];
          contactVoListNew.forEach(contactVo => {
            if ((!contactVo.sort || contactVo.sort === '') && contactVo.displayName) {
              if (contactVo.namePrefix && contactVo.namePrefix.length > 0 && contactVo.namePrefix !== '#') {
                contactVo.sort = contactVo.namePrefix;
                if (!contactVo.sortKey) {
                  contactVo.sortKey = contactVo.displayName;
                }
              }
            }
            updateContactIds.push(contactVo.contactId);
          });
          // 刷新更新或新增联系人头像
          this.refreshContactPhotoByIds(updateContactIds);

          // 刷新列表
          this.refreshContactListDataSourceByContacts(contactVoListNew);
          resolve(true);
        })
    });
  }

  // 刷新联系人列表数据源
  public refreshContactListDataSourceByContacts(contactVoListNew: ContactVo[]) {
    let contactListBefore = this.contactListDataSource.contactList;
    // 更新的话，从原来移除，
    for (let i = contactVoListNew.length - 1; i >= 0; i--) {
      // 如果已经找到合适的位置，移除，不需要后续处理了
      if (this.removeOrReplaceContactBefore(contactListBefore, contactVoListNew[i])) {
        // 更新的联系人找到合适的位置，不需要后续处理了，从处理列表移除
        contactVoListNew.splice(i, 1);
      }
    }

    if (contactVoListNew.length > 0) {
      this.addNewContacts(contactListBefore, contactVoListNew);
    }

    // 弹到指定联系人处
    if (AppStorage.has(AppStorageConstant.NEW_CONTACT_ID)) {
      const newContactId = AppStorage.get<number>(AppStorageConstant.NEW_CONTACT_ID);
      AppStorage.delete(AppStorageConstant.NEW_CONTACT_ID);
      let contactIndex = -1;
      for (let item of this.contactListDataSource.contactList) {
        contactIndex++;
        if (newContactId === Number(item.contactId)) {
          this.onNewContactToIndex(item.contactId, contactIndex);
          break;
        }
      }
    }
  }

  public refreshAlphabetIndexAndCount() {
    HiLog.w(TAG, 'refreshAlphabetIndexAndCount');
    // 刷新二级索引
    this.alphabetIndexPresenter.initContactList(this.contactListDataSource.contactList);
    // 生成二级索引信息
    let alphabetIndex: Record<string, AlphabetIndexObj> = {}
    let index = 0;
    let len = this.contactListDataSource.contactList.length;
    this.contactListDataSource.contactList.forEach(contactVo => {
      ContactAbilityModel.addAlphabetIndexObj(contactVo, index, alphabetIndex, index === len - 1);
      ++index;
    })
    // 赋值二级索引
    this.alphabetIndexPresenter.alphabetIndex = alphabetIndex;
    HiLog.i(TAG, `refreshAlphabetIndexAndCount before total:${this.total}`)
    let getAllContactSizePromise = this.getAllContactSizeAsync();
    // 获得数量信息和头像后，刷新页面信息
    Promise.all([getAllContactSizePromise]).then(() => {
      HiLog.w(TAG, 'refreshAlphabetIndexAndCount: total:' + this.total);
      AppStorage.setOrCreate('contactListListLen', this.total);
      // 刷新列表展示
      if (this.refreshState) {
        this.refreshState();
      }
    });
  }

  /**
   * 移除或更新之前的联系人
   * 如果是更新，找到之前的联系人信息，
   *    如果name没有变，直接将新的数据赋值给旧的，返回true
   *    如果name变了，将原来的移除，返回false
   * 如果新增，不会处理，返回false
   * @param contactListBefore
   * @param contactVoNew
   * @returns
   */
  public removeOrReplaceContactBefore(contactListBefore: ContactVo[], contactVoNew: ContactVo) {
    let index = 0;
    for (let contactVoOld of contactListBefore) {
      if (contactVoOld.contactId === contactVoNew.contactId) {
        // displayName没有变，则不需要重新刷新位置
        if (contactVoOld.sortKey === contactVoNew.sortKey) {
          contactListBefore[index] = contactVoNew;
          this.contactListDataSource.notifyDataChange(index);
          // 处理完成
          return true;
        }
        // displayName改变了，需要重新刷到自己的位置，处理未完成
        // 移除原来的
        this.removeAndRefreshIndex(index);
        return false;
      }
      ++index;
    }
    // 为新增，之前没有对应的元素
    return false;
  }

  /**
   * 刷新单个联系人
   * @param contactListBefore
   * @param contactVoNew
   * @returns
   */
  public addNewContacts(contactListBefore: ContactVo[], contactListNew: ContactVo[]) {
    let startIndex = 0;
    // contactListNew是按sortkey排序的，前一个找到了位置index，后一个从index之后找就可以
    for (let contactVoNew of contactListNew) {
      startIndex = this.refreshContactFromStartIndex(contactListBefore, contactVoNew, startIndex);
    }
  }

  /**
   * 刷新单个联系人
   * @param contactListBefore
   * @param contactVoNew
   * @returns
   */
  public refreshContactFromStartIndex(contactListBefore: ContactVo[], contactNew: ContactVo, startIndex: number) {

    for (let i = startIndex; i < contactListBefore.length; i++) {
      // 更新的联系人，小于i位置元素，相当于在i位置插入更新的联系人
      if (this.compare(contactNew, contactListBefore[i]) <= 0) {
        this.addAndRefreshIndex(contactNew, i);
        // 因为new元素是升序的，下一个元素，可以从i向后查找位置
        return i;
      }
    }

    // 说明排在最后
    // 相当于在contactListBefore.length位置插入更新的联系人
    this.addAndRefreshIndex(contactNew, contactListBefore.length);
    // 从最后一个开始向后查位置
    return contactListBefore.length - 1;
  }

  public addAndRefreshIndex(contactNew: ContactVo, i: number) {
    // 插入位置i，存在元素，则i位置元素会后移，插入元素后，下移的元素也需要刷新
    // 刷新i元素的下一个元素
    // # 存在111，222，333，显示为：  # 111，222，333
    // 修改222为111，会被挪到第一个，此时显示为: # 111 # 111 333；所以需要刷新add元素的下一个元素

    // 存在前一个元素
    let handlePreFlag = i > 0;

    // 1 2 4
    // 插入3, 是在index=2位置插入
    // 需要在i位置位置插入元素
    this.contactListDataSource.contactList.splice(i, 0, contactNew);
    this.contactListDataSource.notifyDataAdd(i);
    // 存在后一个元素
    let handleNextFlag = i + 1 < this.contactListDataSource.contactList.length;
    // 如果插入的位置i是第一个，全部刷新 || 没有元素，新建第一个
    if ((!handlePreFlag && handleNextFlag) || (!handlePreFlag && !handleNextFlag)) {
      this.contactListDataSource.notifyDataReload();
    } else if ((handlePreFlag && handleNextFlag) || (handlePreFlag && !handleNextFlag)) {
      // 插入的位置i是中间部分，从插入位置i的上一个做刷新 || 插入元素是最后的位置
      let contactList = this.contactListDataSource.contactList;
      let preIndex = i - 1;
      contactList.forEach((item, index) => {
        if (index >= preIndex) {
          this.contactListDataSource.notifyDataChange(index);
        }
      })
    }
  }

  public compare(contact1: ContactVo, contact2: ContactVo) {
    let res = contact1.sort.localeCompare(contact2.sort);
    if (res === 0) {
      let arr = [contact1.sortKey, contact2.sortKey];
      arr.sort();
      if (contact1.sortKey === arr[0]) {
        // 联系人1小
        res = -1;
      } else {
        res = 1;
      }
    }
    return res;
  }

  // 查询前触发处理，处理二级索引
  public mPrepareCallBack = () => {
  };

  private getAllContactSizeAsync(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('getAllContactSize', undefined, (result: CountAlphabetIndex) => {
          HiLog.i(TAG, `getAllContactSize before total: ${this.total}`);
          if (this.total == 0 && result.count > 0) {
            PreDefinedContactUtil.getPreDefinedContactLoaded().then((result: boolean) => {
              if (!result) {
                PreDefinedContactUtil.parsePreDefine();
              } else {
                HiLog.i(TAG, `The predefined contact has been loaded`);
              }
            })
          }
          this.total = result.count;
          AppStorage.setOrCreate('contactCount', this.total)
          HiLog.w(TAG, 'getAllContactSize: total:' + this.total);
          resolve(true);
        })
    });
  }

  private constructor() {
  }

  public static getDTTestInstance(): ContactListPresenter {
    // 用于DT测试创建实例对象
    return new ContactListPresenter();
  }

  public static getInstance(): ContactListPresenter {
    if (ContactListPresenter.sInstance == null) {
      HiLog.w(TAG, 'Contact getInstance!');
      ContactListPresenter.sInstance = new ContactListPresenter();
    }
    return ContactListPresenter.sInstance;
  }

  /**
   *
   * @param refreshState contactList的refresh方法
   * @param refreshDeleteContact 标题联系人数量变化
   */
  bindUI(refreshState?: () => void, refreshDeleteContact?: () => void) {
    this.refreshState = refreshState;
    this.refreshDeleteContact = refreshDeleteContact;
  }

  /**
   * 点击联系人tab页，就开始查询联系人列表页数据
   */
  startInitRequestItem() {
    HiLog.w(TAG, 'initRequestItem: ' + this.initRequestItem);
    if (!this.initRequestItem) {
      this.initRequestItem = true;
      HiLog.w(TAG, 'startInitRequestItem: ' + this.initRequestItem);
      this.requestItem();
    }
  }

  /**
   * 进入联系人列表前，先查询第一页数据，使进入联系人列表时，加载时延达标
   */
  public async startPreInit(callback?: () => void) {
    // 已经初始化了，不需要提前初始化了
    if (this.initStarted) {
      HiLog.w(TAG, 'initStarted is true, not startPreInit');
      return;
    }
    // 已经提前初始化了，不需要了
    if (this.startPreInitFlag) {
      HiLog.w(TAG, 'startPreInitFlag is true, not startPreInit');
      return;
    }
    this.startPreInitFlag = true;
    HiLog.w(TAG, 'startPreInit invoke');
    // 提前获取前10条数据，铺满一页
    const actionData: PageLimit = {
      page: 1,
      limit: 10
    };
    const reqData: ReqData<PageLimit> = {
      actionData: actionData
    }
    if (this.intoFromContactIconFlag) {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequestUiThread('getAllContact', reqData, (result: ContactVo[]) => {
          this.handlePreQueryResult(result, callback);
        });
    } else {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('getAllContact', reqData, (result: ContactVo[]) => {
          this.handlePreQueryResult(result, callback);
        });
    }
  }

  public handlePreQueryResult(result: ContactVo[], callback?: () => void) {
    // 如果
    if (this.contactListDataSource.contactList.length === 0 &&
      result.length > 0) {
      // 将datasource的元素替换为result的
      this.contactListDataSource.refresh(0, result, true);
    }
    if (this.total <= 0 && result.length > 0) {
      HiLog.i(TAG, `startPreInit getAllContact before total: ${this.total}`);
      this.total = result.length;
      HiLog.i(TAG, `startPreInit getAllContact total: ${this.total}`)
      if (this.refreshState) {
        this.refreshState();
      }
    }
    if (typeof callback === 'function') {
      callback();
    }
  }

  /**
   * 初始化
   */
  startInit() {
    // 查询列表
    this.startInitRequestItem();
    if (!this.initStarted) {
      this.initStarted = true;
      HiLog.w(TAG, 'startInit');
      this.createSubscriber();
    }
  }

  aboutToAppear(autoMergeDialogController: CustomDialogController) {
    AppStorage.setOrCreate('isBatchDeleting', false);
    this.autoMergeDialogController = autoMergeDialogController;
    HiLog.w(TAG, 'Contact aboutToAppear!');
    // 注册变更监听
    this.limitRefreshInit();
    ContactRepository.getInstance().registerDataChangeObserver(this.onContactChange);
    this.startInit();
    this.screenHeight = AppStorage.get('windowHeightPx') as number;
    // 监听通知，触发列表刷新
    let innerEvent: emitter.InnerEvent = {
      eventId: this.emitterId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEvent, () => {
      HiLog.w(TAG, 'executing a query');
      this.requestItem();
    })
  }

  /**
   * 联系人应用退后台导致查询联系人失败兜底
   */
  initContactListWhenCreateDataHelperFailed() {
    HiLog.w(TAG, 'initContactListWhenCreateDataHelperFailed enter!');
    // 注册变更监听
    ContactRepository.getInstance().registerDataChangeObserver(this.onContactChange);
    HiLog.w(TAG, `initContactListWhenCreateDataHelperFailed initRequestItem: ${this.initRequestItem}`);
    this.initRequestItem = true;
    this.requestItem();
  }

  limitRefreshInit(): void {
    HiLog.w(TAG, 'limitRefreshInit...')
    let isBatchDeleting = AppStorage.get('isBatchDeleting') as boolean;
    if (isBatchDeleting || this.limitDataRefresh != undefined) {
      HiLog.w(TAG, 'limitRefreshInit has init return...')
      return;
    }
    // 查询数据的工具
    this.limitDataRefresh =
      new LimitRefreshDataUtil<PageLimit, ContactVo[]>('getAllContact',
        (page: number, limit: number, result: ContactVo[]) => {
          this.queryAllEnd = false;
          if (page == 1) {
            this.contactsSize = 0;
          }
          let contactCount = result.length;
          HiLog.w(TAG, 'page ' + page + ' contactCount ' + contactCount + ' contactsSize ' + this.contactsSize);
          this.contactsSize += contactCount;
          let isEnd: boolean = contactCount < limit || this.total === this.contactsSize;
          HiLog.w(TAG, `getAllContact refreshPage ${page}, length is: ${result.length}, isEnd is ${isEnd}`);
          this.contactListDataSource.refresh(ArrayUtil.getOffsetForSession(page), result, isEnd);
          this.alphabetIndexPresenter.initContactList(this.contactListDataSource.contactList);
          AppStorage.setOrCreate('contactListListLen', this.contactListDataSource.contactList.length);

          if (isEnd && AppStorage.has(AppStorageConstant.NEW_CONTACT_ID)) {
            const newContactId = AppStorage.get<number>(AppStorageConstant.NEW_CONTACT_ID);
            AppStorage.delete(AppStorageConstant.NEW_CONTACT_ID);
            let contactIndex = -1;
            for (let item of this.contactListDataSource.contactList) {
              contactIndex++;
              if (newContactId === Number(item.contactId)) {
                this.onNewContactToIndex(item.contactId, contactIndex);
                break;
              }
            }
          }

          // 根据列表信息，设置二级索引
          if (isEnd) {
            this.queryAllEnd = true;
            // 二级索引相关
            let alphabetIndex: Record<string, AlphabetIndexObj> = {};
            let index = 0;
            this.contactListDataSource.contactList.forEach(contactVo => {
              ContactAbilityModel.addAlphabetIndexObj(contactVo, index,
                alphabetIndex, index === this.contactListDataSource.contactList.length - 1);
              if (index < 10) {
                // sort、sortKey、namePrefix、displayName
                let sortKeyInitials: string = '';
                if (!StringUtil.isEmpty(contactVo.sortKey)) {
                  sortKeyInitials = contactVo.sortKey.substring(0, 1);
                }
                let displayNameInitials: string = '';
                if (!StringUtil.isEmpty(contactVo.displayName)) {
                  displayNameInitials = contactVo.displayName.substring(0, 1) + '**';
                }
                HiLog.w(TAG, 'sort is ' + contactVo.sort + ' sortKey is ' + sortKeyInitials + ' displayName is ' +
                  displayNameInitials + ' namePrefix is ' + contactVo.namePrefix);
              }
              // 判断是否排序是否正确
              this.judgeAndLogSortError(contactVo);
              index++;
            })
            this.alphabetIndexPresenter.initAlphabetIndex(alphabetIndex);
            this.refreshAlphabetIndexAndCount();
          }
          return isEnd;
        })

    this.limitDataRefresh.setPrepareCallBack(this.mPrepareCallBack);
  }

  /**
   * 检查合并
   * @param autoMergeDialogController
   */
  checkMerge(autoMergeDialogController: CustomDialogController) {
    this.autoMergeDialogController = autoMergeDialogController;
    let isFirstAutoMerge = sharedPreferencesUtils.getFromPreferences('isFirstAutoMerge', true);
    let isCancel = sharedPreferencesUtils.getFromPreferences('isCancel', false);
    let isAutoMerge = sharedPreferencesUtils.getFromPreferences('isAutoMerge', false);
    let alwaysAutoMerge = sharedPreferencesUtils.getFromPreferences('alwaysAutoMerge', false);
    let autoMergeCancelState = sharedPreferencesUtils.getFromPreferences('autoMergeCancelState', false);
    Promise.all([isFirstAutoMerge, isCancel, isAutoMerge, alwaysAutoMerge, autoMergeCancelState])
      .then((value) => {
        HiLog.w(TAG, 'get initial variable');
        this.isFirstAutoMerge = value[0] as boolean;
        this.isCancel = value[1] as boolean;
        this.isAutoMerge = value[2] as boolean;
        this.alwaysAutoMerge = value[3] as boolean;
        this.autoMergeCancelState = value[4] as boolean;

        if (this.isFirstAutoMerge) {
          // isFirstAutoMerge：第一次自动合并
          HiLog.w(TAG, 'isFirstAutoMerge: ' + this.isFirstAutoMerge);
          this.checkRepeatContact(autoMergeDialogController);
        } else if (this.alwaysAutoMerge || this.isAutoMerge) {
          // alwaysAutoMerge：总是自动合并，isAutoMerge：自动合并开关
          HiLog.w(TAG, `alwaysAutoMerge: ${this.alwaysAutoMerge}, isAutoMerge: ${this.isAutoMerge}`);
          this.checkCondition();
        } else if (this.autoMergeCancelState) {
          // autoMergeCancelState：仅本次合并
          HiLog.w(TAG, `autoMergeCancelState: ${this.autoMergeCancelState}`);
          sharedPreferencesUtils.getFromPreferences('checkAutoMergeTime', 0).then((checkAutoMergeTime) => {
            HiLog.w(TAG, `checkAutoMergeTime: ${checkAutoMergeTime}`);
            let startTime = checkAutoMergeTime as number;
            let now = new Date().getTime();
            HiLog.w(TAG, 'now - checkAutoMergeTime:' + (now - startTime));
            if (now - startTime > ONE_MONTH) {
              // 距离上次 仅本次合并 大于1个月
              this.checkRepeatContact(autoMergeDialogController);
            }
          });
        } else if (this.isCancel) {
          HiLog.w(TAG, 'isCancel: ' + this.isCancel);
          autoMergeDialogController.close();
        }
      })
  }

  checkCondition() {
    // 距离上次 合并重复联系人 大于2天
    sharedPreferencesUtils.getFromPreferences('autoMergeTime', 0).then((autoMergeTime) => {
      HiLog.w(TAG, 'autoMergeTime: ' + autoMergeTime);
      let startTime = autoMergeTime as number;
      let now = new Date().getTime();
      HiLog.w(TAG, 'now - autoMergeTime:' + (now - startTime));
      if (now - startTime > TWO_DAY) {
        HiLog.w(TAG, 'checkCondition start!!');
        // 查询重复联系人，并合并
        mergeDuplicateContactsByUrl(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
        // 监听通知
        if (this.subscriberList.length == 4) {
          CommonEventUtil.subscribe(this.subscriberList[0], CommonEventConstants.COMMON_EVENT_CHARGING, () => {
            // 充电中
            HiLog.w(TAG, 'the phone is charging!');
            this.charingFlag = true;
            if (this.charingFlag && this.screenOffFlag && this.noUseFlag) {
              mergeDuplicateContactsByUrl(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
            }
          });
          CommonEventUtil.subscribe(this.subscriberList[1], CommonEventConstants.COMMON_EVENT_SCREEN_OFF, () => {
            // 锁屏中
            HiLog.w(TAG, 'the phone is screen off!');
            this.noUseFlag = true;
            let id = setTimeout(() => {
              // 锁屏状态超过 71分钟
              HiLog.w(TAG, 'the phone is screen off over 71 min!');
              this.screenOffFlag = true;
              if (this.charingFlag && this.screenOffFlag && this.noUseFlag) {
                mergeDuplicateContactsByUrl(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
              } else {
                clearTimeout(id);
              }
            }, SEVENTY_ONE)
          });
          CommonEventUtil.subscribe(this.subscriberList[2], CommonEventConstants.COMMON_EVENT_DISCHARGING, () => {
            HiLog.w(TAG, 'the phone is disCharging!');
            this.charingFlag = false;
          });
          CommonEventUtil.subscribe(this.subscriberList[3], CommonEventConstants.COMMON_EVENT_SCREEN_ON, () => {
            HiLog.w(TAG, 'the phone is screen on!');
            this.screenOffFlag = false;
            this.noUseFlag = false;
          });
        }
      }
    })
  }

  createSubscriber() {
    // 延迟执行
    setTimeout(() => {
      let charging: Promise<CommonEventManager.CommonEventSubscriber> =
        CommonEventUtil.registerSubscriber(CommonEventConstants.COMMON_EVENT_CHARGING);
      let screenOff: Promise<CommonEventManager.CommonEventSubscriber> =
        CommonEventUtil.registerSubscriber(CommonEventConstants.COMMON_EVENT_SCREEN_OFF);
      let disCharging: Promise<CommonEventManager.CommonEventSubscriber> =
        CommonEventUtil.registerSubscriber(CommonEventConstants.COMMON_EVENT_DISCHARGING);
      let screenOn: Promise<CommonEventManager.CommonEventSubscriber> =
        CommonEventUtil.registerSubscriber(CommonEventConstants.COMMON_EVENT_SCREEN_ON);
      Promise.all([charging, screenOff, disCharging, screenOn])
        .then((value: CommonEventManager.CommonEventSubscriber[]) => {
          HiLog.w(TAG, 'createSubscriber succeed subscriber length :' + value.length);
          this.subscriberList = value;
        });
    }, 500);
  }

  unSubscriber() {
    if (this.subscriberList.length > 0) {
      this.subscriberList.forEach(value => {
        CommonEventUtil.unsubscribe(value);
      })
    }
  }

  checkRepeatContact(autoMergeDialogController: CustomDialogController) {
    // has repeat contacts
    queryRepeatContacts(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()).then((repeatNum: number) => {
      HiLog.w(TAG, `queryRepeatContacts end. repeatNum: ${repeatNum}`);
      // 存在重复联系人，打开提示框
      this.repeatNum = repeatNum;
      if (this.repeatNum > 0 && this.isFirstAutoMerge) {
        this.isFirstAutoMerge = false;
        autoMergeDialogController?.open();
        DialogControllerManager.getInstance().addDialogController(this.autoMergeDialogController);
      }
    })
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'Contact aboutToDisappear!');
    ContactRepository.getInstance().unRegisterDataChangeObserver(this.onContactChange);
    emitter.off(this.emitterId);
    this.limitDataRefresh?.release();
    this.limitDataRefresh = undefined;
    this.initStarted = false;
  }

  /**
   * 设置显示页面
   * @param isShow
   */
  setPageShow(isShow: boolean) {
    HiLog.w(TAG, `setPageShow   isShow == ${isShow}`);
    if (this.isShow == isShow) {
      HiLog.w(TAG, 'isShow not change, return');
      return;
    }
    this.isShow = isShow;
    this.limitRefreshInit();
    this.limitDataRefresh?.setTaskForeground(isShow);
    sharedPreferencesUtils.getFromPreferences('accountType', -1).then(data => {
      if (this.accountType != data) {
        this.initStarted = false;
        this.accountType = data as number;
      }
      // 如果是显示页面
      if (this.isShow) {
        this.startInit();
        HiLog.w(TAG, 'isFirstAutoMerge:' + this.isFirstAutoMerge);
        this.repeatNum = 0;
        this.autoMergeDialogController?.close();
        DialogControllerManager.getInstance().dialogControllerSet.clear();
        this.checkMerge(this.autoMergeDialogController);
      }
    })
  }

  requestItem() {
    HiLog.w(TAG, 'Contacts requestItem!');
    // 查数量信息
    let getAllContactSizePromise = this.getAllContactSizeAsync();
    // 处理头像信息
    let getPhotosPromise = this.getPhotosInfoAsync();
    // 查询联系人列表
    this.limitDataRefresh?.requestItem();
    // 获得数量信息和头像后，刷新页面信息
    Promise.all([getAllContactSizePromise, getPhotosPromise]).then(() => {
      // 刷新列表展示
      if (this.refreshState) {
        this.refreshState();
      }
    });

    this.requestMyCard();
  }

  requestMyCard() {
    HiLog.i(TAG, 'start requestMyCard');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getMyCard', undefined, (result: ContactVo[]) => {
        HiLog.w(TAG, 'requestMyCard len: ' + result.length);
        if (result.length) {
          let vo = result[0];
          AppStorage.setOrCreate(AppStorageConstant.CARD_CONTACT_INFO, this.getCardDataByVo(vo));
          AppStorage.setOrCreate(AppStorageConstant.MYCARD_CONTACT_ID, vo.contactId);
          this.refreshContactPhotoByIds([vo.contactId]);
        } else {
          let portraitColor = MorandiColor.color[0];
          let emptyVo: ContactVo = new ContactVo('', '', '', '', '', '', portraitColor, true, '', '', '');
          let context = ContactsGlobalThisHelper.GetGlobalThis()
            .getDefaultUIContext();
          emptyVo.showName = ResourceUtil.resourceToString($r('app.string.my_card'), context);
          AppStorage.setOrCreate(AppStorageConstant.CARD_CONTACT_INFO, this.getCardDataByVo(emptyVo));
          AppStorage.setOrCreate(AppStorageConstant.MYCARD_CONTACT_ID, '');
        }
      });
  }

  public getCardDataByVo(contact: ContactVo) {
    // 当前联系人名字首字母和上个联系人不同，显示首字母
    let showIndex: boolean = true;
    // 显示下划线
    let showDivifer: boolean = false;
    // 显示名字信息
    contact.title = (StringUtil.isEmpty(contact.showName) ? contact.phoneNum : contact.showName);
    if (StringUtil.isEmpty(contact.title)) {
      contact.title = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.noName').id);
    }
    if (StringUtil.isEmpty(contact.company)) {
      contact.subTitle = StringUtil.isEmpty(contact.position) ? '' : contact.position;
    } else {
      contact.subTitle =
        contact.company.concat(' ').concat(StringUtil.isEmpty(contact.position) ? '' : contact.position);
    }
    return new ContactListShowInfo(showIndex, showDivifer, contact.contactId, contact.nameRawContactId,
      contact.headChar, contact.portraitPath, contact.namePrefix, contact.title, contact.subTitle);
  }

  // 异步分页查询头像
  public page: number = 0;
  public map: Map<string, ContactBlobSource> = new Map();
  /**
   * 获取头像信息
   * @returns
   */
  getPhotosInfoAsync(userId?: number): Promise<boolean> {
    return new Promise((resolve, reject) => {
      // 查询有头像信息的记录
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
        .sendRequest('getContactIdToBlobDataMap', { page: this.page, userId: userId }, (resultMap: Map<string, ContactBlobSource>) => {
          HiLog.i(TAG, `getPhotosInfoAsync size: ${resultMap.size}, currentPage :${this.page}`);
          try {
            if (resultMap && resultMap.size < 2500) {
              resultMap.forEach((value, key) => {
                this.map.set(key, value);
              });
              initBlobSourceMap(this.map);
              // 联系人列表更新，触发头像查询
              AppStorage.setOrCreate('contactListUpdated', new Date().valueOf());
              this.page = 0;
              resolve(true);
            } else {
              resultMap.forEach((value, key) => {
                this.map.set(key, value);
              });
              initBlobSourceMap(this.map);
              this.page++;
              this.getPhotosInfoAsync(userId);
            }
          } catch (error) {
            HiLog.e(TAG, `getPhotosInfoAsync error processing resultMap: ${error?.message}`);
            reject(error);
          }
        });
    });
  }
  setCurrentPage(currentPage?: number) {
    this.limitDataRefresh?.setCurrentPage(currentPage ? currentPage : this.contactListDataSource.getCurrentPage());
  }

  /**
   * Cancel button for deleting a dialog box.
   */
  onDeleteDialogCancel() {
    HiLog.w(TAG, 'onDeleteDialogCancel !!!');
  }

  /**
   * 删除联系人
   * Confirm button for deleting a dialog box
   *
   * @param result
   */
  async onDeleteDialogConfirm(index: number, contactId: string, isMyCard: boolean, deleteCallback?: Function) {
    HiLog.w(TAG, `onDeleteDialogConfirm contactId=${contactId},index=${index},isMyCard=${isMyCard}`);
    // 在删除联系人时，快速拨号如果关联了删除的联系人，需要一起删除
    let speedString: string = await sharedPreferencesUtils.getFromPreferences('speedDialObjString', '') as string;
    const contactIdParam: ContactIdParam = {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      contactId: contactId,
      operationScenario: 'manul delete',
    }
    // 删除标记置为true
    this.deletingContact = true;
    if (!StringUtil.isEmpty(speedString)) {
      let speedDialArr: Record<string, SpeedDialItem | null> = JSON.parse(speedString);
      Object.entries(speedDialArr).forEach(item => {
        if (item[1] != null) {
          if (contactIdParam.contactId == item[1].contactId) {
            speedDialArr[item[0]] = null;
          }
        }
      })
      sharedPreferencesUtils.saveToPreferences('speedDialObjString', JSON.stringify(speedDialArr));
    }
    // 删除联系人
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteContactById', contactIdParam, (result: number | undefined) => {
        SmsManagerUtils.notifyMmsWhenDeleteContact([contactIdParam.contactId].map(Number), result === 0 ? 0 : -1);
        if (result == 0 || result == undefined) {
          HiLog.i(TAG, `deleteContactById success`);
          emitter.emit({ eventId: EmitterConstant.CONTACT_LIST_CACHE_UPDATE });
          if (isMyCard) {
            setTimeout(() => {
              this.deleteMyCardTotally(contactIdParam.contactId);
            }, 200);
          }
        } else {
          HiLog.w(TAG, 'deleteContactById error:' + result);
        }
      });
    // 刷新联系人数量
    if (this.refreshDeleteContact != undefined && !isMyCard) {
      this.refreshDeleteContact();
    }
    // 重新加载，删除指定index
    animateTo({
      duration: 200,
      onFinish: () => {
        this.contactListDataSource.notifyDataReload();
        this.alphabetIndexPresenter.initContactList(this.contactListDataSource.contactList);
        deleteCallback && deleteCallback();
      }
    }, () => {
      // 根据index移除
      if (!isMyCard) {
        if (index > 0) {
          AppStorage.setOrCreate('selectContactId', this.contactListDataSource.contactList[index-1].contactId)
        } else if (index == 0 && this.contactListDataSource.totalCount() > 1) {
          AppStorage.setOrCreate('selectContactId', this.contactListDataSource.contactList[1].contactId);
        } else {
          AppStorage.setOrCreate('selectContactId', this.contactListDataSource.contactList[0].contactId)
        }
        this.contactListDataSource.removeIndex(index);
      }
    })
  }

  deleteMyCardTotally(contactId: string) {
    HiLog.i(TAG, `deleteMyCardTotally id:${contactId}`);
    let contactIdParam: ContactIdParam = {
      context: getContext(this) as common.UIAbilityContext,
      contactId: contactId
    }
    ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('findRawIdById', contactIdParam, (result: number) => {
        let contactRawIdParam: ContactIdsParam = {
          context: getContext(this) as common.UIAbilityContext,
          ids: [result.toString()]
        }
        HiLog.i(TAG, `findRawIdById rawId :${result}`);
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
          .sendRequest('deleteRecycleContactByIds', contactRawIdParam, (result: number) => {
            HiLog.i(TAG, `deleteMyCardTotally result:${result}`);
          })
      })
  }

  /**
   * Share Cancel Button
   */
  onShareDialogCancel() {
    HiLog.w(TAG, 'onShareDialogCancel !!! ');
  }

  /**
   * Share confirmation button
   */
  onShareDialogConfirm() {
    HiLog.w(TAG, 'onShareDialogConfirm !!! ');
  }

  /**
   * Event callback when an item is clicked in the sharing dialog box
   *
   * @param item item
   * @param index index
   */
  onShareItemClick(item: string, index: number | null) {
    HiLog.w(TAG, 'onShareItemClick !!! index is %s' + index);
  }

  /**
   * Log in to openharmony ID.
   */
  loginAccount() {
    HiLog.w(TAG, 'loginAccount !!');
    this.pathInfos?.pushPathByName('', '');
  }

  /**
   * Import Contact dialog box
   */
  importContact() {
    HiLog.w(TAG, 'importContact !!');
    this.pathInfos?.pushPathByName('', '');
  }

  /**
   * New Contact
   * 联系人列表页，新建联系人
   */
  createContact() {
    HiLog.w(TAG, 'createContact !!');
    DynamicLoader.getInstance().fire(DynamicLoader.ACCOUNTANTS).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.ACCOUNTANTS, this.total);
    });
  }

  /**
   * 发送消息给畅连
   */
  sendMsgToMeetime(uiExtensionSession: UIExtensionContentSession, actionType: string) {
    HiLog.w(TAG, 'sendMsgToMeetime');
    let msg: Record<string, string> = {
      'action': actionType
    };
    uiExtensionSession?.sendData(msg);
  }

  /**
   *  The settings page is displayed
   */
  toSettings(isNoBack?: boolean) {
    HiLog.w(TAG, 'toSettings !!');
    DynamicLoader.getInstance().fire('Settings').then(() => {
      HiLog.w(TAG, 'toSettings: total:' + this.total);
      this.pathInfos?.pushPathByName('Settings', this.total, true);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `loadSettings err: msg: ${err.message}, code: ${err.code}`);
    });
  }

  /**
   * Scan the business card.
   */
  scanCard() {
    HiLog.w(TAG, 'scanCard !!');
    this.pathInfos?.pushPathByName('', '');
  }

  /**
   * Processing contactSearch data
   */
  processData(value: Array<PhoneNum>): string[] {
    let data: string[] = [];
    // 多结果字段（邮箱，地址，IM）只展示第一个匹配的值
    for (let item of value) {
      if (item.value.includes('<em>')) {
        data = item.value.replace(hasComma, COMMA_REPLACE).split(labelMatch);
        break;
      }
    }
    return data;
  }

 // async getSearchContact(value: string) {
 //    HiLog.i(TAG, `getSearchContact start.value=${value}`);
 //    if ('' === value) {
 //      this.isSearchBackgroundColor = true;
 //      this.searchContactsSource.refresh(this.contactSearchList);
 //      let innerEvent: emitter.InnerEvent = {
 //        eventId: 102,
 //        priority: emitter.EventPriority.HIGH
 //      };
 //      emitter.emit(innerEvent, {
 //        data: {
 //          'contactSearchList': 0
 //        }
 //      });
 //      return;
 //    }
 //    HiLog.i(TAG, 'getSearchContact: sending request to worker');
 //    let actionData: Record<string, Context | string> = {
 //      'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext() as Context,
 //      'actionData': value
 //    }
 //    ContactsGlobalThisHelper.GetGlobalThis()
 //      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
 //      .sendRequest('getSearchContact', actionData, (result: ContactSearchResultData) => {
 //        HiLog.i(TAG, `yh getSearchContact result= ${result}`);
 //        this.isSearchBackgroundColor = false;
 //        this.contactSearchList = result.data;
 //        this.contactSearchCount = this.contactSearchList.length;
 //        this.searchContactsSource.refresh(this.contactSearchList);
 //        let innerEvent: emitter.InnerEvent = {
 //          eventId: 102,
 //          priority: emitter.EventPriority.HIGH
 //        };
 //        emitter.emit(innerEvent, {
 //          data: {
 //            'contactSearchList': this.contactSearchCount
 //          }
 //        });
 //      })
 //    HiLog.i(TAG, 'getSearchContact: request sent to worker');
 //    HiLog.i(TAG, 'getSearchContact end.');
 //  }

  /**
   * 搜索联系人
   * @param value
   * Search for Contacts
   */
  // getSearchContactResult(value: string) {
  //   HiLog.w(TAG, `getSearchContactResult start:${value?.length}, ${TextUtils.getMaskString(value)}`);
  //   this.contactSearchList = [];
  //   AppStorage.setOrCreate('isSearchBackgroundColor', true);
  //   this.contactSearchCount = 0;
  //   this.inputKeyword = value;
  //   // 第一次搜索结果缓存头像由于无法确认缓存范围，在ContactSearch组件onScrollIndex中进行
  //   this.hasScrollIndexCachePhotoFinish = AppStorage.get<boolean>('firstCacheSearchPhotoEnd') ?? false;
  //   // 分页查询时，只需触发一次
  //   this.hasCachePhotoFinish = false;
  //   if (value.replace(/\s*/g, '') === '') {
  //     HiLog.w(TAG, 'getSearchContactResult value is empty');
  //     this.isSearchBackgroundColor = true;
  //     this.contactSearchList = [];
  //     this.searchContactsSource.refresh(this.contactSearchList);
  //     let innerEvent: emitter.InnerEvent = {
  //       eventId: 102,
  //       priority: emitter.EventPriority.HIGH
  //     };
  //     emitter.emit(innerEvent, {
  //       data: {
  //         'contactSearchCount': 0
  //       }
  //     });
  //     if (this.task) {
  //       try {
  //         taskpool.cancel(this.task as taskpool.Task);
  //         HiLog.w(TAG, 'search taskpool value empty cancel success');
  //       } catch (err) {
  //         HiLog.e(TAG, `search taskpool cancel error: code: ${err.code}, message: ${err.message}`);
  //       }
  //     }
  //     if (this.searchDbTask) {
  //       try {
  //         taskpool.cancel(this.searchDbTask as taskpool.Task);
  //         HiLog.w(TAG, 'searchDbTask taskpool cancel success');
  //       } catch (err) {
  //         HiLog.e(TAG, `searchDbTask taskpool cancel error: code: ${err.code}, message: ${err.message}`);
  //       }
  //     }
  //     return;
  //   } else {
  //     this.isSearchBackgroundColor = true;
  //     this.inputKeyword = value;
  //     if (this.task) {
  //       try {
  //         taskpool.cancel(this.task as taskpool.Task);
  //         HiLog.w(TAG, 'search taskpool cancel success');
  //       } catch (err) {
  //         HiLog.e(TAG, `search taskpool cancel error: code: ${err.code}, message: ${err.message}`);
  //       }
  //     }
  //     if (this.searchDbTask) {
  //       try {
  //         taskpool.cancel(this.searchDbTask as taskpool.Task);
  //         HiLog.w(TAG, 'searchDbTask taskpool cancel success');
  //       } catch (err) {
  //         HiLog.e(TAG, `searchDbTask taskpool cancel error: code: ${err.code}, message: ${err.message}`);
  //       }
  //     }
  //     this.contactSearchTask();
  //   }
  // }

  /**
   * Search Contacts from db
   *
   * @param searchkey searchkey
   */
  getSearchContactResultFromDb(searchkey: string) {
    HiLog.w(TAG, 'getSearchContactResultFromDb start!!');
    this.contactSearchList = [];
    AppStorage.setOrCreate('isSearchBackgroundColor', true);
    this.contactSearchCount = 0;
    this.inputKeyword = searchkey;
    // 第一次搜索结果缓存头像由于无法确认缓存范围，在ContactSearch组件onScrollIndex中进行
    this.hasScrollIndexCachePhotoFinish = AppStorage.get<boolean>('firstCacheSearchPhotoEnd') ?? false;
    // 分页查询时，只需触发一次
    this.hasCachePhotoFinish = false;
    if (searchkey.replace(/\s*/g, '') === '') {
      HiLog.w(TAG, 'getSearchContactResultFromDb value is empty');
      this.isSearchBackgroundColor = true;
      this.contactSearchList = [];
      this.searchContactsSource.refresh(this.contactSearchList);
      let innerEvent: emitter.InnerEvent = {
        eventId: 102,
        priority: emitter.EventPriority.HIGH
      };
      emitter.emit(innerEvent, {
        data: {
          'contactSearchCount': 0
        }
      });
      if (this.searchDbTask) {
        try {
          taskpool.cancel(this.searchDbTask as taskpool.Task);
          HiLog.w(TAG, 'searchDbTask value empty cancel success');
        } catch (err) {
          HiLog.e(TAG, `searchDbTask taskpool cancel error: code: ${err.code}, message: ${err.message}`);
        }
      }
      return;
    } else {
      this.isSearchBackgroundColor = true;
      this.inputKeyword = searchkey;
      if (this.searchDbTask) {
        try {
          taskpool.cancel(this.searchDbTask as taskpool.Task);
          HiLog.w(TAG, 'searchDbTask cancel success');
        } catch (err) {
          HiLog.e(TAG, `searchDbTask taskpool cancel error: code: ${err.code}, message: ${err.message}`);
        }
      }
      this.contactSearchTaskFromDb(1, 5000);
    }
  }

  /**
   * handle Contacts data from db
   *
   * @param searchResultsObject search data
   * @param contactSearchUniqueKey contactSearchUniqueKey
   * @param page page
   */
  async searchContactFromDbHandle(searchResultsObject: object, contactSearchUniqueKey: number, page: number) {
    let myCardContactId: string = AppStorage.get(AppStorageConstant.MYCARD_CONTACT_ID) ?? '';
    let searchResultsFromDb = searchResultsObject as Array<SearchContactResult>;

    // 过滤我的名片联系人
    let searchResults: SearchContactResult[] = searchResultsFromDb.filter(item => item.entityId !== myCardContactId);
    HiLog.w(TAG, `searchContactFromDbHandle: ${contactSearchUniqueKey
    } contactSearchDbTask execute Length: ${searchResultsFromDb.length
    }, searchResults Length: ${searchResults.length}, myCardContactId: ${myCardContactId},contactSearchCount:${this.contactSearchCount}`);
    // 判断第一批99条
    if (searchResults.length != 0 || (searchResults.length == 0 && this.contactSearchList.length != 0)) {
      this.contactSearchCount += searchResults.length;
      this.contactSearchList = this.contactSearchList.concat(searchResults);
      this.searchContactsSource.refresh(this.contactSearchList);
      AppStorage.setOrCreate('contactSearchNumber', this.contactSearchCount);
      AppStorage.setOrCreate('isSearchBackgroundColor', true);

      HiLog.w(TAG, `searchContactFromDbHandle: ${contactSearchUniqueKey} contactSearchTask end: ${searchResults.length
      }, contactSearchNumber: ${this.contactSearchCount} isSearchBackgroundColor: true`);

      this.cacheContactSearchPixelMap(searchResults.length);
      AppStorage.setOrCreate('pickerSearchResult', 1);
    } else {
      this.contactSearchList = [];
      this.searchContactsSource.refresh([]);
      this.contactSearchCount = 0;
      AppStorage.setOrCreate('contactSearchNumber', this.contactSearchCount);
      AppStorage.setOrCreate('isSearchBackgroundColor', false);
      HiLog.w(TAG, `searchContactFromDbHandle: ${contactSearchUniqueKey
      } contactSearchDbTask end result empty: ${searchResults.length
      }, contactSearchDbNumber empty: ${this.contactSearchCount} isSearchBackgroundColor: false`);
      AppStorage.setOrCreate('pickerSearchResult', -1);
    }
    this.searchDbTask = undefined;
    //联系人打点--数据库搜索完毕上报打点
    this.searchCustomParams.SEARCHKEY = TextUtils.getMaskString(this.inputKeyword);
    this.searchCustomParams.MIXSEARCHNUMBER = 0;
    this.searchCustomParams.ISSTARTDBSEARCH = 1;
    this.searchCustomParams.DBSEARCHNUMBER = this.contactSearchCount;
    DotUtil.getInstance()
      .contactDot(this.searchCustomParams, CONTACT_LIST_SEARCH_EVENT);
    return;
  }

  /**
   * 分页从数据库查询
   *
   * @param page page
   * @param limit limit
   */
  contactSearchTaskFromDb(page: number, limit: number) {
    // 单次搜索唯一标识（过程包含请求融合搜及返回结果）
    let contactSearchUniqueKey: number = new Date().valueOf();
    HiLog.w(TAG, `contactSearchTaskFromDb start!! search content db: ${TextUtils.getMaskString(this.inputKeyword)
    }, contactSearchUniqueKey: ${contactSearchUniqueKey}`);
    this.searchDbTask =
      new taskpool.Task(searchContactByPhoneNumAndDisplayNameForLimit, this.inputKeyword, page, limit,
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    if (this.inputKeyword.length > 1) {
      taskpool.executeDelayed(DELAY_TIME, this.searchDbTask, taskpool.Priority.HIGH).then(
        (searchResultsObject: object) => {
          this.searchContactFromDbHandle(searchResultsObject, contactSearchUniqueKey, page);
        }).catch((error: BusinessError) => {
        if (error.message !== dotCommon.eventParam.SEARCH_CONTACT_FAIL_MASSAGE) {
          // 联系人故障打点-联系人搜索失败
          faultContactParams.FAULT_INFO = error.message;
          DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.SEARCH_CONTACTS_FAIL);
        }
        HiLog.e(TAG, `contactSearchdbUniqueKey: ${contactSearchUniqueKey
        } task updateSearchContactListDelayed error: code: ${error.code}, message: ${error.message}`);
      });
    } else {
      // 搜索的文字，长度为1，不延迟查询
      // 搜索联系人加载时延，测试步骤为：输入一个字符，等待结果，延迟100ms执行，就会导致时延有问题，所以长度为1，不延迟查询了，直接查询
      taskpool.execute(this.searchDbTask, taskpool.Priority.HIGH).then(async (searchResultsObject: object) => {
        this.searchContactFromDbHandle(searchResultsObject, contactSearchUniqueKey, page);
      }).catch((error: BusinessError) => {
        if (error.message !== dotCommon.eventParam.SEARCH_CONTACT_FAIL_MASSAGE) {
          // 联系人故障打点-联系人搜索失败
          faultContactParams.FAULT_INFO = error.message;
          DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.SEARCH_CONTACTS_FAIL);
        }
        HiLog.e(TAG, `contactSearchDbUniqueKey: ${contactSearchUniqueKey
        } task updateSearchContactList error: code: ${error.code}, message: ${error.message}`);
      });
    }
  }

  // contactSearchTask() {
  //   // 单次搜索唯一标识（过程包含请求融合搜及返回结果）
  //   let contactSearchUniqueKey: number = new Date().valueOf();
  //   HiLog.w(TAG, `contactSearchTask start!! search content: ${this.inputKeyword?.length
  //   }, contactSearchUniqueKey: ${contactSearchUniqueKey}, count=${this.contactSearchCount}`);
  //   this.task = new taskpool.Task(updateSearchContactList, this.inputKeyword, this.contactSearchCount,
  //     contactSearchUniqueKey, ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
  //   if (this.inputKeyword.length > 1) {
  //     taskpool.executeDelayed(DELAY_TIME, this.task, taskpool.Priority.HIGH).then(
  //       async (searchResultsObject: Object) => {
  //         this.searchContactCallBack(searchResultsObject, contactSearchUniqueKey);
  //       }).catch((error: BusinessError) => {
  //       if (error.message !== dotCommon.eventParam.SEARCH_CONTACT_FAIL_MASSAGE) {
  //         // 联系人故障打点-联系人搜索失败
  //         faultContactParams.FAULT_INFO = error.message;
  //         DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.SEARCH_CONTACTS_FAIL);
  //       }
  //       HiLog.e(TAG, `contactSearchUniqueKey: ${contactSearchUniqueKey
  //       } task updateSearchContactListDelayed error: code: ${error.code}, message: ${error.message}`);
  //     });
  //   } else {
  //     // 搜索的文字，长度为1，不延迟查询
  //     // 搜索联系人加载时延，测试步骤为：输入一个字符，等待结果，延迟100ms执行，就会导致时延有问题，所以长度为1，不延迟查询了，直接查询
  //     taskpool.execute(this.task, taskpool.Priority.HIGH).then(async (searchResultsObject: Object) => {
  //       this.searchContactCallBack(searchResultsObject, contactSearchUniqueKey);
  //     }).catch((error: BusinessError) => {
  //       if (error.message !== dotCommon.eventParam.SEARCH_CONTACT_FAIL_MASSAGE) {
  //         // 联系人故障打点-联系人搜索失败
  //         faultContactParams.FAULT_INFO = error.message;
  //         DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.SEARCH_CONTACTS_FAIL);
  //       }
  //       HiLog.e(TAG, `contactSearchUniqueKey: ${contactSearchUniqueKey
  //       } task updateSearchContactList error: code: ${error.code}, message: ${error.message}`);
  //     });
  //   }
  // }

  // search contact callback
  // async searchContactCallBack(searchResultsObject: Object, contactSearchUniqueKey: number) {
  //   let myCardContactId: string = AppStorage.get(AppStorageConstant.MYCARD_CONTACT_ID) ?? '';
  //   let contactSearchResults = searchResultsObject as ContactsSearchResult;
  //   let searchResultsSource: SearchContactResult[] = contactSearchResults.resultList;
  //   let mixSearchLen = contactSearchResults.contactsOffsetFromMixSearch;
  //   let dbSearchLen = contactSearchResults.contactsOffsetFromDb;
  //   // 过滤我的名片联系人
  //   let searchResults: SearchContactResult[] = searchResultsSource.filter(item => item.entityId !== myCardContactId);
  //   HiLog.w(TAG, `contactSearchUniqueKey: ${contactSearchUniqueKey
  //   } contactSearchTask execute searchResultsSource Length: ${searchResultsSource.length
  //   }, searchResults Length: ${searchResults.length}, myCardContactId: ${myCardContactId}`);
  //   if ((!searchResults || searchResults.length === 0) && this.contactSearchCount === 0){
  //     // 第一批并且没有数据，需要使用联系人数据库的结果,使用联系人数据库搜索的DataSource
  //     this.getSearchContactResultFromDb(this.inputKeyword);
  //     return;
  //   }
  //   //联系人打点--融合搜索完毕上报打点
  //   if (this.contactSearchCount === 0 && searchResults.length < CONTACT_SEARCH_OFFSET) {
  //     this.searchCustomParams.SEARCHKEY = TextUtils.getMaskString(this.inputKeyword);
  //     this.searchCustomParams.MIXSEARCHNUMBER = mixSearchLen;
  //     this.searchCustomParams.ISSTARTDBSEARCH = dbSearchLen > 0 ? 1 : 0;
  //     this.searchCustomParams.DBSEARCHNUMBER = dbSearchLen;
  //     DotUtil.getInstance()
  //       .contactDot(this.searchCustomParams, CONTACT_LIST_SEARCH_EVENT);
  //   }
  //   if (searchResults.length != 0 || (searchResults.length == 0 && this.contactSearchList.length != 0)) {
  //     this.contactSearchCount += searchResults.length;
  //     this.contactSearchList = this.contactSearchList.concat(searchResults);
  //     this.searchContactsSource.refresh(this.contactSearchList);
  //     AppStorage.setOrCreate('contactSearchNumber', this.contactSearchCount);
  //     AppStorage.setOrCreate('isSearchBackgroundColor', true);
  //
  //     HiLog.w(TAG, `contactSearchUniqueKey: ${contactSearchUniqueKey} contactSearchTask end: ${searchResults.length
  //     }, contactSearchNumber: ${this.contactSearchCount} isSearchBackgroundColor: true`);
  //
  //     this.cacheContactSearchPixelMap(searchResults.length);
  //     setTimeout(() => {
  //       accessibility.sendAccessibilityEvent(({
  //         type: 'announceForAccessibility',
  //         bundleName: 'com.ohos.contacts',
  //         triggerAction: 'common',
  //         textAnnouncedForAccessibility: ResourceUtil.getPluralStringByResource($r('app.plural.found_contacts'),
  //           searchResults.length)
  //       })).then(() => {
  //       })
  //     }, 400)
  //     AppStorage.setOrCreate('pickerSearchResult', 1);
  //   } else {
  //     this.contactSearchList = [];
  //     this.searchContactsSource.refresh([]);
  //     this.contactSearchCount = 0;
  //     AppStorage.setOrCreate('contactSearchNumber', this.contactSearchCount);
  //     AppStorage.setOrCreate('isSearchBackgroundColor', false);
  //     HiLog.w(TAG, `contactSearchUniqueKey: ${contactSearchUniqueKey
  //     } contactSearchTask end result empty: ${searchResults.length
  //     }, contactSearchNumber empty: ${this.contactSearchCount} isSearchBackgroundColor: false`);
  //     AppStorage.setOrCreate('pickerSearchResult', -1);
  //   }
  //   this.task = undefined;
  //   if (searchResults.length < CONTACT_SEARCH_OFFSET) {
  //     //联系人打点--融合搜索完毕上报打点
  //     if (this.contactSearchCount > CONTACT_SEARCH_OFFSET) {
  //       this.searchCustomParams.SEARCHKEY = TextUtils.getMaskString(this.inputKeyword);
  //       this.searchCustomParams.MIXSEARCHNUMBER = this.contactSearchCount;
  //       this.searchCustomParams.ISSTARTDBSEARCH = 0;
  //       this.searchCustomParams.DBSEARCHNUMBER = 0;
  //       DotUtil.getInstance()
  //         .contactDot(this.searchCustomParams, CONTACT_LIST_SEARCH_EVENT);
  //     }
  //     return;
  //   }
  //   this.contactSearchTask();
  // }

  sendEmitter(isSearchPage: boolean) {
    let innerEvent: emitter.InnerEvent = {
      eventId: EMITTER_SEARCH_ID,
      priority: emitter.EventPriority.HIGH
    };
    emitter.emit(innerEvent, {
      data: {
        'isSearchPage': isSearchPage
      }
    });
  }

  toGroupList(isNoBack?: boolean) {
    this.pathInfos?.pushPathByName('GroupList', '', true);
  }

  heightConversion(heightConversion: number): number {
    return px2vp(heightConversion / this.theoreticalHeight * this.screenHeight);
  }

  toDefaultPage() {  //联系人的默认界面
    if (AppStorage.get('maintenanceMode')) {
      this.pathInfos?.clear(false);
      return;
    }
    HiLog.w(TAG,
      'pathInfos pushPathByName: ContactDefaultPage --- isShowSmartWindow:' + AppStorage.get('isShowSmartWindow'));
    if (!AppStorage.get('isNavigationModeSplit')) {
      return;
    }
    if (AppStorage.get('breakpoint') !== 'sm') {
      this.pathInfos?.clear();
      this.pathInfos?.pushPathByName('ContactDefaultPage', '', false);
    }
  }

  openDefaultContactsDetail() {
    let selectedContactId = (AppStorage.get('selectContactId') ?? '') as string;
    HiLog.w(TAG, `openDefaultContactsDetail ${selectedContactId}`);

    try {
      const listDataSource = this.contactListDataSource.contactList[0];
      if (!listDataSource || !listDataSource.contactId) {
        HiLog.w(TAG, 'listDataSource is empty or listDataSource.contactId is empty');
        return;
      }
      let index: number = 0;
      this.contactListDataSource.contactList.forEach(item => {
        if (item.contactId == selectedContactId) {
          index = this.contactListDataSource.contactList.indexOf(item);
        }
      })
      const params: Record<string, boolean | string | number> = {
        'sourceHasId': true,
        'contactId': selectedContactId ? selectedContactId : listDataSource.contactId,
        'itemIndex': index,
      };
      this.scroller.scrollToIndex(0, false, ScrollAlign.CENTER);
      DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
        this.pathInfos?.replacePathByName('ContactDetail', params);
      });
    } catch (err) {
      HiLog.e(TAG, `open default contacts detail err: ${err.message}`);
    }
  }

  public handleDelContact(index: number, contactId: number = -1): void {
    HiLog.w(TAG, `handleDelContact  index: ${index},contactId=${contactId}`)
    if (index < 0 && contactId > 0) {
      index = this.contactListDataSource.getIndexByContactId(contactId);
      HiLog.w(TAG, `handleDelContact index from contactListDataSource: ${index}`)
    }
    if (index < 0) {
      HiLog.e(TAG, `handleDelContact, index invalid.`)
      return;
    }
    // 刷新数量
    if (this.refreshDeleteContact != undefined) {
      this.refreshDeleteContact();
    }
    // 删除下标对应联系人，重新加载，初始化二级索引
    this.contactListDataSource.removeIndex(index);
    if (index > 0) {
      AppStorage.setOrCreate('selectContactId', this.contactListDataSource.contactList[index-1].contactId);
    } else if (index == 0 && this.contactListDataSource.totalCount() > 0) {
      AppStorage.setOrCreate('selectContactId', this.contactListDataSource.contactList[0].contactId);
    } else {
      this.contactListDataSource.totalCount()
    }
    this.contactListDataSource.notifyDataReload();
    this.alphabetIndexPresenter
      .initContactList(this.contactListDataSource.contactList);
  }

  public static unInstance(): void {
    HiLog.w(TAG, 'unInstance...');
    ContactListPresenter.sInstance = null;
  }

  cacheContactSearchPixelMap(searchResultLength: number) {
    // 需要保留的缓存头像contactId
    let cacheContactIds: string[] = [];
    this.firstItemIndex = AppStorage.get('firstItemIndex') ?? -1;
    this.lastItemIndex = AppStorage.get('lastItemIndex') ?? -1;
    let contactSearchListCache = this.contactSearchList;
    if (this.hasScrollIndexCachePhotoFinish && this.firstItemIndex !== -1 && this.lastItemIndex !== -1) {
      HiLog.i(TAG, 'cacheContactSearchPixelMap');
      // 当前搜索结果长度大于需要缓存最大索引，且一次搜索中只触发一次缓存
      if (contactSearchListCache.length >= this.lastItemIndex + 1 && !this.hasCachePhotoFinish) {
        cacheContactIds = this.processCache(contactSearchListCache, cacheContactIds);
      } else if (!this.hasCachePhotoFinish && searchResultLength < CONTACT_SEARCH_OFFSET &&
        this.lastItemIndex + 1 > contactSearchListCache.length) {
        // 一次搜索中未触发过缓存且上次索引大于本次搜索长度，需要更新索引，重新缓存
        let cacheLength: number = (this.lastItemIndex + 1) - this.firstItemIndex;
        this.firstItemIndex =
          contactSearchListCache.length - cacheLength >= 0 ? contactSearchListCache.length - cacheLength : 0;
        this.lastItemIndex = contactSearchListCache.length - 1 >= 0 ? contactSearchListCache.length - 1 : 0;
        cacheContactIds = this.processCache(contactSearchListCache, cacheContactIds);
      }

      if (!ArrayUtil.isEmpty(cacheContactIds)) {
        PixelMapManager.getInstance().updateContactSearchListMiniPixelMap(cacheContactIds);
      }
    }
  }

  private processCache(contactSearchListCache: SearchContactResult[], cacheContactIds: string[]): string[] {
    let contactListSlice = contactSearchListCache.slice(this.firstItemIndex, this.lastItemIndex + 1);
    contactListSlice.forEach(item => {
      PixelMapManager.getInstance()
        .cachedContactListIdMiniPixelMap(item, CachedContactsPixelMapType.CONTACT_SEARCH_LIST);
      cacheContactIds.push(item.entityId);
    });
    this.hasCachePhotoFinish = true;
    return cacheContactIds;
  }
}