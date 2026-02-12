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

// 导入所需工具类和数据模型
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import BatchSelectContactSource from '../../model/bean/BatchSelectContactSource';
import { ContactVo } from '../../model/bean/ContactVo';
import AlphabetIndexerPresenter from '../contact/alphabetindex/AlphabetIndexerPresenter';
import { ContactInfoGetParamsInCallback } from '../../model/type/ContactParams';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import FavoriteListPresenter from './FavoriteListPresenter';
import { SplitStatus } from '../../util/DisplaySplitUtil';
import EmitterConstant from '../../data/EmitterConstant';
import { emitter } from '@kit.BasicServicesKit';
import AccessibilityUtil from '../../util/AccessibilityUtil';

// 日志标签
const TAG = 'AddFavoriteListPresenter ';

/**
 * 添加收藏联系人列表的Presenter类
 * 负责管理添加收藏页面的业务逻辑、数据处理和页面交互
 */
export default class AddFavoriteListPresenter {
  // 导航路径栈，用于页面跳转控制
  public pathInfos?: NavPathStack;
  // 单例实例
  private static sInstance: AddFavoriteListPresenter;
  // 页面类型，默认、群组或收藏
  public pageType: PageType = PageType.Default

  // 已选择的联系人数量
  public selectCount: number = 0;
  // 联系人总数
  public contactsTotal: number = 0;
  // 全选图标资源
  public icSelectAll: Resource = $r('sys.symbol.checkmark_square_on_square');
  // 全选文本资源
  public allSelectMessage: Resource = $r('app.string.select_all');
  // 添加按钮文本资源
  public addMessage: Resource = $r('app.string.add')

  // 联系人列表数据
  public contactsList: Array<ContactVo> = [];
  // 初始索引位置
  public initialIndex: number = 0;
  // 批量选择联系人数据源
  public contactsSource: BatchSelectContactSource = new BatchSelectContactSource();
  // 字母索引器Presenter
  public alphabetIndexPresenter: AlphabetIndexerPresenter = new AlphabetIndexerPresenter();

  // 群组ID
  public groupId: number = -1;
  // 工具栏更新回调接口
  public updateToolbar: AddFavoriteUpdateToolbar = {
    updateToolbar: (): void => {},
  };
  // 已选择联系人的ID集合
  public checkedStatus: Set<string> = new Set<string>();

  /**
   * 获取单例实例
   * @returns AddFavoriteListPresenter实例
   */
  public static getInstance(): AddFavoriteListPresenter {
    if (AddFavoriteListPresenter.sInstance == null) {
      AddFavoriteListPresenter.sInstance = new AddFavoriteListPresenter();
    }
    return AddFavoriteListPresenter.sInstance;
  }

  // 滚动长度参数
  public sceillOnlenth: number = 0;

  /**
   * 初始化导航路径栈
   * @param pageInfos 导航路径栈
   * @returns 当前实例
   */
  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  /**
   * 页面即将显示时调用
   * 根据页面类型初始化联系人列表数据
   */
  aboutToAppear() {
    if (this.pageType === PageType.Group) {
      this.initContactsListByGroup()
    } else if (this.pageType === PageType.Favorite) {
      this.initContactsListByFavorite()
    }
    this.clearSelection();
  }

  /**
   * 清除选择状态
   */
  clearSelection() {
    this.selectCount = 0;
    this.checkedStatus.clear();
    this.refreshPageMessage();
  }

  /**
   * 页面即将消失时调用
   */
  aboutToDisappear() {
  }

  /**
   * 页面显示时调用
   */
  onPageShow() {
  }

  /**
   * 页面隐藏时调用
   */
  onPageHide() {
  }

  /**
   * 取消返回处理
   * 根据页面类型和设备尺寸决定返回路径
   */
  backCancel() {
    if (this.pageType === PageType.Group) {
      // 群组页面返回上一页
      this.pathInfos?.pop();
    } else if (AppStorage.get('breakpoint') === 'sm' || AppStorage.get('isShowSmartWindow') ||
      AppStorage.get('splitStatus') === SplitStatus.VERTICAL_SPLIT) {
      // 小屏幕或智能窗口模式返回上一页
      this.pathInfos?.clear();////
    } else {
      // 其他情况返回联系人默认页面
      HiLog.w(TAG, 'pathInfos backCancel: ContactDefaultPage');
      FavoriteListPresenter.getInstance().toDefaultPage();
    }
  }

  /**
   * 全选/取消全选按钮点击事件
   */
  clickSelectAll() {
    HiLog.w(TAG, `clickSelectAll start, selectCount: ${this.selectCount}, contactsTotal: ${this.contactsTotal}`);
    if (this.selectCount != 0 && this.selectCount === this.contactsTotal) {
      // 已全选状态下点击则取消全选
      this.checkedStatus.clear();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, this.contactsTotal);
    } else {
      // 非全选状态下点击则全选
      this.contactsList.forEach((element): void => {
        this.checkedStatus.add(element.contactId);
      });
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, this.contactsTotal);
    }
    // 发送选择事件
    this.sendSelectedEvent(null);
    // 刷新页面显示
    this.refreshPageMessage();
  }

  /**
   * 发送选择事件
   * @param id 联系人ID
   */
  sendSelectedEvent(id: string | null) {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_LIST_ADD_MEMBERS_ITEM_CHECKED,
    };
    let eventData: emitter.EventData = {
      data: {
        'id': id
      }
    };
    emitter.emit(innerEvent, eventData);
  }

  /**
   * 刷新页面显示信息
   * 更新选择数量、全选状态和工具栏
   */
  refreshPageMessage() {
    HiLog.i(TAG, 'refreshPageMessage start !')
    this.selectCount = this.checkedStatus.size;
    if (this.selectCount > 0 && this.selectCount === this.contactsTotal) {
      // 全选状态
      HiLog.i(TAG, 'checkAllClickButtonStyle contact select all ');
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square_fill');
      this.allSelectMessage = $r('app.string.unselect_all');
    } else {
      // 非全选状态
      HiLog.i(TAG, 'checkAllClickButtonStyle contact unselect all ');
      this.icSelectAll = $r('sys.symbol.checkmark_square_on_square');
      this.allSelectMessage = $r('app.string.select_all');
    }
    // 更新工具栏
    this.updateToolbar.updateToolbar();
  }

  /**
   * 重置初始索引
   * @param firstIndex 初始索引值
   */
  resetInitialIndex(firstIndex: number) {
    HiLog.i(TAG, 'resetInitialIndex firstIndex is %s', firstIndex.toString());
    this.initialIndex = firstIndex;
  }

  /**
   * 添加群组成员
   */
  addGroupContacts() {
    HiLog.i(TAG, 'addGroupContacts start.');
    let checkedList: Array<string> = [];
    this.contactsList.forEach((contact) => {
      if (this.checkedStatus.has(contact.contactId)) {
        checkedList.push(contact.nameRawContactId)
      }
    })
    // 将选择的群组成员添加到存储
    AppStorage.setOrCreate<Array<string>>('addGroupContactData', checkedList);
    // 返回上一页
    this.pathInfos?.pop();
    HiLog.i(TAG, 'addGroupContacts end.');
  }

  /**
   * 添加收藏联系人
   */
  addFavoriteContacts() {
    HiLog.i(TAG, 'addFavoriteContacts start.');
    let checkedContactList: Array<ContactVo> = [];
    this.contactsList.forEach((contact) => {
      if (this.checkedStatus.has(contact.contactId)) {
        checkedContactList.push(contact)
      }
    })
    // 将收藏的联系人添加到storage
    AppStorage.setOrCreate<Array<ContactVo>>('addFavoriteContactData', checkedContactList);
    if (AppStorage.get('breakpoint') === 'sm' || AppStorage.get('isShowSmartWindow')) {
      // 小屏幕或智能窗口模式返回上一页
      this.pathInfos?.pop();
    } else {
      // 大屏幕模式返回上一页并触发默认选中联系人事件
      this.pathInfos?.pop();
      FavoriteListPresenter.getInstance().emitFavoriteDefaultSelectedContact();
    }
    HiLog.i(TAG, 'addFavoriteContacts end.');
  }

  /**
   * 联系人项点击事件
   * @param item 点击的联系人对象
   * @param index 点击的索引位置
   */
  itemOnClick(item: ContactVo, index: number) {
    HiLog.w(TAG, 'contactId: ' + item.contactId + ',  index: ' + index);
    if (this.checkedStatus.has(item.contactId)) {
      // 如果已选中则取消选中
      this.checkedStatus.delete(item.contactId);
    } else {
      // 如果未选中则添加选中
      this.checkedStatus.add(item.contactId);
    }
    // 发送选择事件
    this.sendSelectedEvent(item.contactId);
    // 刷新页面显示
    this.refreshPageMessage();
  }

  /**
   * 根据收藏状态初始化联系人列表数据
   */
  initContactsListByFavorite() {
    HiLog.i(TAG, 'initContactsList start!');
    let favoriteForm: Record<string, number> = {
      'favorite': 0
    }
    let data: Record<string, Context | string> = {
      'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      'favoriteForm': JSON.stringify(favoriteForm)
    }
    // 通过Worker获取所有有电话号码的联系人
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)?.sendRequest(
      'getAllContactWithPhoneNumbers',
      data,
      (resultList: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, 'initContactsList resultList success.');
        let listTemp: ContactVo[] = [];
        if (!ArrayUtil.isEmpty(resultList.contactList)) {
          for (let element of resultList.contactList) {
            element.name.fullName = element.emptyNameData;
            element.name.namePrefix = element.namePrefix;
            element.name.nameSuffix = element.nameSuffix;
            listTemp.push(element);
          }
        } else {
          HiLog.e(TAG, 'select contact list is empty!');
        }

        // 更新联系人列表数据
        this.contactsList = listTemp;
        this.contactsSource.refresh(this.contactsList);
        this.contactsTotal = this.contactsList.length;
        // 初始化字母索引器
        this.alphabetIndexPresenter.initContactList(this.contactsList);
        this.alphabetIndexPresenter.initAlphabetIndex(resultList.alphabetIndex);
      });
  }

  /**
   * 根据群组ID初始化联系人列表数据
   */
  initContactsListByGroup() {
    HiLog.i(TAG, 'initContactsList start!');
    let favoriteForm: Record<string, number | string> = {
      'favorite': -1,
    }
    favoriteForm.pageTag = 'group';
    favoriteForm.groupId = this.groupId;

    let data: Record<string, Context | string> = {
      'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      'favoriteForm': JSON.stringify(favoriteForm)
    }
    // 通过Worker获取指定群组下的联系人
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)?.sendRequest(
      'getAllContactWithPhoneNumbers',
      data,
      (resultList: ContactInfoGetParamsInCallback) => {
        HiLog.i(TAG, 'initContactsList resultList success.');
        let listTemp: ContactVo[] = [];
        if (!ArrayUtil.isEmpty(resultList.contactList)) {
          for (let element of resultList.contactList) {
            element.name.fullName = element.emptyNameData;
            element.name.namePrefix = element.namePrefix;
            element.name.nameSuffix = element.nameSuffix;
            listTemp.push(element);
          }
        } else {
          HiLog.e(TAG, 'select contact list is empty!');
        }

        // 更新联系人列表数据
        this.contactsList = listTemp;
        this.contactsSource.refresh(this.contactsList);
        this.contactsTotal = this.contactsList.length;
        // 初始化字母索引器
        this.alphabetIndexPresenter.initContactList(this.contactsList);
        this.alphabetIndexPresenter.initAlphabetIndex(resultList.alphabetIndex);
      });
  }

  /**
   * 设置工具栏更新回调
   * @param updateToolbar 工具栏更新回调接口
   */
  setUpdateToolbar(updateToolbar: AddFavoriteUpdateToolbar) {
    this.updateToolbar = updateToolbar;
  }
}

/**
 * 工具栏更新回调接口
 */
export interface AddFavoriteUpdateToolbar {
  updateToolbar: () => void
}

/**
 * 事件接口定义
 */
export interface EventInterface {
  contactIndex: number
  numberIndex: number
  checked: boolean
}

/**
 * 页面类型枚举
 */
export enum PageType {
  Default, // 默认页面
  Group, // 群组页面
  Favorite // 收藏页面
}