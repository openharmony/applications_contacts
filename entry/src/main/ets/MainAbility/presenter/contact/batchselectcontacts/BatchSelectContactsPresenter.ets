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

import HiLog from '../../../util/HiLog';
import appStorage from '../../../util/AppStorageUtil';
import {ContactVo} from '../../../model/bean/ContactVo';
import callLogService from '../../../model/calllog/CalllogModel';
import Constants from '../../../model/common/Constants';
import PreferencesUtil from '../../../util/PreferencesUtil';
import Common from '../../../model/common';
import Utils from '../../../util/Utils';
import AppStorageUtil from '../../../util/AppStorageUtil';
import {CallBean} from '../../../model/bean/CallBean';
import LooseObject from '../../../model/bean/LooseObject';
import ContactAbilityModel from '../../../model/ContactAbilityModel';
import featureAbility from '@ohos.ability.featureAbility';
import router from '@system.router';

const TAG = 'BatchSelectContactsPresenter ';

/**
 * 短信选择联系人列表 P层
 */
export default class BatchSelectContactsPresenter {
  private static sInstance: BatchSelectContactsPresenter;
  sizeType: SizeType = SizeType.LG;
  selectCount: number = 0;
  // 最近通话记录
  callLogTemp: any[] = [];
  // 联系人列表
  contactsList: any[] = [];
  searchContactList: any[] = [];
  // 简洁布局
  layoutState: boolean = true;
  // 群组列表
  groupList: any[] = [];
  emptyViewText: Resource = $r("app.string.no_recent_contacts");
  controller: TabsController = new TabsController();
  currentIndex: number = 0;
  //  tabTextSrc: string[] | Resource[] = [$r("app.string.recent"), $r("app.string.contact"), $r("app.string.groups")];
  tabTextSrc: string[] | Resource[] = [$r("app.string.recent"), $r("app.string.contact")];
  tabInfo: TabInfo = new TabInfo(0);
  contactsInfo: ContactsInfo = new ContactsInfo();
  // 是否显示底部全选按钮，当本页签无数据时，不显示
  showOption: boolean = false;
  // 搜索关键字
  searchText: string = '';
  // 当前总体已选择的数据，key为电话号码，value为 包含电话号码和姓名的obj
  selectedNumberMap: any = new Map();
  //是否显示搜索列表
  searchLayoutShow: boolean = false;
  selectDisabled: boolean = true;
  isSelectAll: boolean = false;

  public static getInstance(): BatchSelectContactsPresenter {
    if (BatchSelectContactsPresenter.sInstance == null) {
      BatchSelectContactsPresenter.sInstance = new BatchSelectContactsPresenter();
      appStorage.setAndLink('batchselectcontactspresenter', BatchSelectContactsPresenter.sInstance);
    }
    return BatchSelectContactsPresenter.sInstance;
  }

  /**
   * 函数在创建自定义组件的新实例后，在执行其build函数之前执行。
   * 允许在aboutToAppear函数中改变状态变量，这些更改将在后续执行build函数中生效。
   */
  aboutToAppear() {
    this.initCallLog();
    this.initContactsList();
  }

  /**
   * 函数在自定义组件析构消耗之前执行。
   * 不允许在aboutToDisappear函数中改变状态变量，特别是@Link变量的修改可能会导致应用程序行为不稳定。
   */
  aboutToDisappear() {
  }

  /**
   * 当此页面显示时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageShow() {
  }

  /**
   * 当此页面消失时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageHide() {
  }

  /**
   * 点击cancel图标
   */
  cancel() {
    router.back();
  }

  /**
   * 点击ok图标
   */
  comfirm() {
    let checkedList = [];
    this.selectedNumberMap.forEach((value) => {
      checkedList.push(value);
    });
    let contacts = this.dealContactName(checkedList);
    let parameters = {
      contactObjects: JSON.stringify(contacts)
    };
    let result = {
      resultCode: 0,
      want: {
        parameters: parameters
      }
    };
    // 短信新建选择联系人
    featureAbility.terminateSelfWithResult(result)
      .then((data) => {
        HiLog.i(TAG, "terminateSelfWithResult Operation succeeded: ");
      })
      .catch((error) => {
        HiLog.e(TAG, "Operation failed. Cause: %s", JSON.stringify(error.message));
      });
  }

  /**
    * 处理选中的联系人的信息
    *
    * @param {Array} checkedList 选中的list
    * @return {boolean} 返回处理后的联系人
    */
  dealContactName(checkedList) {
    let contacts = [];
    for (let item of checkedList) {
      let contact = {
        contactName: item.name,
        telephone: item.number
      };
      contacts.push(contact);
    }
    return contacts;
  }

  /**
   * 底部全选按钮被点击
   */
  clickSelectAll() {
    switch (this.tabInfo.tabIndex) {
    // 最近页签
      case 0:
        if (this.tabInfo.recentCount != 0 && this.tabInfo.recentCount == this.tabInfo.recentTotal) { // 已经全选，则取消全选
          this.tabInfo.allClickedRecent = false;
          this.unSelectAll();
        } else { // 未全选,则全部选中
          this.tabInfo.allClickedRecent = true;
          this.selectAll();
        }
        break;

    // 联系人列表页签
      case 1:
        if (this.tabInfo.contactsCount != 0 && this.tabInfo.contactsCount == this.tabInfo.contactsTotal) {
          // 已经全选，则取消全选
          this.tabInfo.allClickedContacts = false;
          this.unSelectAll();
        } else {
          // 未全选,则全部选中
          this.tabInfo.allClickedContacts = true;
          this.selectAll();
        }
        break;

    // 群组页签
      case 2:
        if (this.tabInfo.groupsCount != 0 && this.tabInfo.groupsCount == this.tabInfo.groupsTotal) { // 已经全选，则取消全选
          this.tabInfo.allClickedGroups = false;
          this.unSelectAll();
        } else { // 未全选,则全部选中
          this.tabInfo.allClickedGroups = true;
          this.selectAll();
        }
        break;

      default:
        break;
    }
    this.refreshPageMessage();
  }
  /**
   * 取消全选
   * */
  unSelectAll() {
    switch (this.tabInfo.tabIndex) {
    // 最近页签
      case 0:
        this.unSelectAllRecentProc();
        break;

    // 联系人列表页签
      case 1:
        this.unSelectAllContactProc();
        break;

    // 群组页签
      case 2: // 群组页签
        this.groupList.forEach(element => {
          element.checked = false;
        });
        this.tabInfo.groupsCount = 0;
        break;

      default:
        break;
    }
  }

  /**
   * 全选列表项, 每个页签在全选时，将自身的选择结果追加给selectCount
   * */
  selectAll() {
    switch (this.tabInfo.tabIndex) {
    // 最近页签
      case 0:
        this.selectAllRecentProc();
        break;

    // 联系人列表页签
      case 1:
        this.selectAllContactProc();
        break;

    // 群组页签
      case 2:
        this.groupList.forEach(element => {
          element.checked = true;
        });
        this.tabInfo.groupsCount = this.tabInfo.groupsTotal;
        break;

      default:
        break;
    }
  }

  /**
   * 最近联系列表取消全选
   * */
  unSelectAllRecentProc() {
    this.callLogTemp.forEach(element => {
      element.checked = false;
      if (this.checkIfSelectedNumber(element.phoneNumber)) {
        this.deleteSelectedNumber(element.phoneNumber);
      }
    });
    this.tabInfo.recentCount = 0;
  }

  /* 联系人列表取消全选 */
  unSelectAllContactProc() {
    // 搜索界面
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach(element => {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          if (element.phoneNumbers[i].checked) {
            element.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber);
          }
        }
      });
    } else { // 主列表
      this.contactsList.forEach(element => {
        for (let i = 0; i < element.phoneNumbers.length; i++) {
          if (element.phoneNumbers[i].checked) {
            element.phoneNumbers[i].checked = false;
            this.deleteSelectedNumber(element.phoneNumbers[i].phoneNumber);
          }
        }
      });
    }
    this.tabInfo.contactsCount = 0;
  }

  /* 最近联系页签全选操作 */
  selectAllRecentProc() {
    this.callLogTemp.forEach(element => {
      element.checked = true;
      this.addOrUpdateSelectedNumberMap(element.phoneNumber, element.displayName);
    });
    this.tabInfo.recentCount = this.tabInfo.recentTotal;
  }

  /* 联系人全选操作 */
  selectAllContactProc() {
    // 搜索界面
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach(element => {
        if (!element.phoneNumbers[0].checked) {
          element.phoneNumbers[0].checked = true;
          this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber, element.name.fullName);
        }
      });
    } else {
      // 若是主列表，则只修改主列表数据
      this.contactsList.forEach(element => {
        if (!element.phoneNumbers[0].checked) {
          element.phoneNumbers[0].checked = true;
          this.addOrUpdateSelectedNumberMap(element.phoneNumbers[0].phoneNumber, element.name.fullName);
        }
      });
    }
    this.tabInfo.contactsCount = this.tabInfo.contactsTotal;
  }

  /**
     * 校验当前号码是否已被选择
     *
     * @param {number} number 号码
     * @return {Object} 校验当前号码是否已被选择
     */
  checkIfSelectedNumber(number): boolean {
    if (Utils.isEmpty(number)) {
      return false;
    }
    return this.selectedNumberMap.has(number.replace(/\s+/g, ''));
  }

  onTabChange(tabIndex: number) {
    HiLog.i(TAG, 'onTabChange tabIndex is %s', tabIndex);
    this.tabInfo.tabIndex = tabIndex;
  }

  getEmptyText(): Resource {
    switch (this.tabInfo.tabIndex) {
    // 最近
      case 0:
        this.emptyViewText = $r("app.string.no_recent_contacts");
        break
    // 联系人
      case 1:
        this.emptyViewText = $r("app.string.no_select_contacts");
        break
    // 群组
      case 2:
        this.emptyViewText = $r("app.string.no_group_contacts");
        break
      default:
        this.emptyViewText = $r("app.string.no_recent_contacts");
        break
    }
    return this.emptyViewText;
  }

  /**
   * 当recent-item被点击的回调
   *
   * @param isOn CheckBox是否被选中
   */
  onRecentItemClicked(index: number) {
    HiLog.i(TAG, 'onRecentItemClicked index is %s', index);
    this.checkStateChange(index, {
      checked: !(this.callLogTemp[index].checked)
    });
  }

  /**
   * 当contact-item被点击的回调
   *
   * @param isOn CheckBox是否被选中
   */
  onContactItemClicked(index: number, indexChild: number) {
    HiLog.i(TAG, 'onContactItemClicked index is %s', index);
    HiLog.i(TAG, 'onContactItemClicked indexChild is %s', indexChild);

    let event = {
      contactIndex: index,
      numberIndex: indexChild,
      checked: this.searchLayoutShow ? !(this.searchContactList[index].phoneNumbers[indexChild].checked)
                                     : !(this.contactsList[index].phoneNumbers[indexChild].checked)
    }
    this.checkStateChange(index, event);
  }

  /**
     * 列表复选框状态变化
     *
     * @param {number} index 下标
     * @param {Object} e event事件
     */
  checkStateChange(index, e) {
    HiLog.e(TAG, 'checkStateChange error: %s ', JSON.stringify(e.message));
    HiLog.i(TAG, 'checkStateChange tabIndex is %s', this.tabInfo.tabIndex);
    switch (this.tabInfo.tabIndex) {
    // 最近
      case 0:
        this.changeCallLogItemState(index, e);
        break;

      case 1:
        this.changeContactsItemState(index, e);
        break;

    //      case 2:
    //        this.changeGroupsItemState(index, e);
    //        break;

      default:
        break;
    }
    this.refreshPageMessage();
  }

  /**
     * 联系人主列表或搜索列表点击复选框事件
     *
     * @param {Object} e event事件
     */
  changeContactState(event) {
    // 调用统一的复选框变化函数
    this.checkStateChange(event.contactIndex, event);
  }

  /**
     * 最近页签通话记录复选框状态变化
     *
     * @param {number} index 下标
     * @param {Object} e event事件
     */
  changeCallLogItemState(index, e) {
    HiLog.e(TAG, 'changeCallLogItemState error : %s ', JSON.stringify(e.message));
    this.callLogTemp[index].checked = e.checked;
    AppStorageUtil.SetOrCreate('callLogTemp', this.callLogTemp);
    if (this.callLogTemp[index].checked) {
      this.addOrUpdateSelectedNumberMap(this.callLogTemp[index].phoneNumber, this.callLogTemp[index].displayName);
      this.tabInfo.recentCount++;
    } else {
      this.deleteSelectedNumber(this.callLogTemp[index].phoneNumber);
      this.tabInfo.recentCount--;
    }
  }

  /**
       * 联系人列表页签通话记录复选框状态变化
       *
       * @param {number} index 下标
       * @param {Object} e event事件
       */
  changeContactsItemState(index, e) {
    HiLog.i(TAG, "SHOW changeContactsItemState searchLayoutShow");
    let contactId = '';
    if (!this.contactsInfo.searchLayoutShow) {
      // 联系人主列表界面点击复选框
      contactId = this.contactsList[index].contactId;
    } else {
      // 联系人搜索列表界面点击复选框
      contactId = this.contactsInfo.searchContactList[index].contactId;
    }
    this.checkContactsCount(e, contactId);
  }

  /**
     * 判断当前是否需要增加或减小联系人计数，若所有子号码及主号码都变为未选中，则减1，如果有任何的号码变为选中，则加一
     *
     * @param {Object} e event事件
     * @param {number} contactId 联系人ID
     */
  checkContactsCount(e, contactId) {
    HiLog.i(TAG, "SHOW checkContactsCount searchLayoutShow");
    // 当前为搜索页面
    if (this.contactsInfo.searchLayoutShow) {
      this.contactsInfo.searchContactList.forEach(element => {
        if (contactId == element.contactId) {
          if (e.checked) {
            // 修改前原数据中不存在已选项时，页签计数加1；
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount++;
            }
            element.phoneNumbers[e.numberIndex].checked = true;
            this.contactsInfo.contactsNumberCount++;
            this.addOrUpdateSelectedNumberMap(element.phoneNumbers[e.numberIndex].phoneNumber,
              element.name.fullName);
          } else {
            element.phoneNumbers[e.numberIndex].checked = false;
            this.contactsInfo.contactsNumberCount--;
            // 修改后原数据中不存在已选项时，页签计数减1；
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount--;
            }
            this.deleteSelectedNumber(element.phoneNumbers[e.numberIndex].phoneNumber);
          }
        }
      });
    } else { // 当前为主列表
      this.contactsList.forEach(element => {
        if (contactId == element.contactId) {
          if (e.checked) {
            // 修改前原数据中不存在已选项时，页签计数加1；
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount++;
            }
            element.phoneNumbers[e.numberIndex].checked = true;
            this.contactsInfo.contactsNumberCount++;
            this.addOrUpdateSelectedNumberMap(element.phoneNumbers[e.numberIndex].phoneNumber,
              element.name.fullName);
          } else {
            element.phoneNumbers[e.numberIndex].checked = false;
            this.contactsInfo.contactsNumberCount--;
            // 修改后原数据中不存在已选项时，页签计数减1；
            if (!this.checkIfNeedCount(element)) {
              this.tabInfo.contactsCount--;
            }
            this.deleteSelectedNumber(element.phoneNumbers[e.numberIndex].phoneNumber);
          }
        }
      });
    }
  }

  /**
    * 判断当前联系人元素是否存在已选项，存在则反true，不存在则反false
    *
    * @param {Object} contact 联系人数据
    * @return {boolean} 存在则反true，不存在则反false
    */
  checkIfNeedCount(contact) {
    if (contact.phoneNumbers.length > 0) {
      for (let index = 0; index < contact.phoneNumbers.length; index++) {
        const element = contact.phoneNumbers[index];
        if (element.checked) {
          return true;
        }
      }
    } else {
      return false;
    }
  }

  /* 标题计数刷新函数 */
  refreshPageMessage() {
    this.selectCount = this.selectedNumberMap.size;
    if (this.selectedNumberMap.size > 0) {
      this.selectDisabled = false;
      this.checkAllClickButtonStyle();
    } else {
      this.selectDisabled = true;
      this.isSelectAll = false;
    }
  }

  /**
   * 校验全选按钮的显示样式
   */
  checkAllClickButtonStyle() {
    switch (this.tabInfo.tabIndex) {
    // 最近页签
      case 0:
        if (this.tabInfo.recentCount == this.tabInfo.recentTotal) {
          //          this.changeToFullSelect();
          this.tabInfo.allClickedRecent = true;
        } else {
          //          this.changeToUnFullSelect();
        }
        break;

    // 联系人列表页签
      case 1:
        if (this.tabInfo.contactsCount == this.tabInfo.contactsTotal) {
          //          this.changeToFullSelect();
          this.tabInfo.allClickedContacts = true;
        } else {
          //          this.changeToUnFullSelect();
        }
        break;

    //    // 群组页签
    //      case 2:
    //        if (this.tabInfo.groupsCount == this.tabInfo.groupsTotal) {
    //          //          this.changeToFullSelect();
    //          this.tabInfo.allClickedGroups = true;
    //        }
    //        break;
      default:
        break;
    }
  }

  /**
     * 刷新已选map数据
     *
     * @param {number} number 号码
     * @param {string} name 姓名
     */
  addOrUpdateSelectedNumberMap(number, name) {
    if (Utils.isEmpty(number)) {
      return;
    }
    this.selectedNumberMap.set(number.replace(/\s+/g, ''), {
      name: name,
      number: number.replace(/\s+/g, '')
    });
  }

  /**
   * 从已选号码中删除
   *
   * @param {number} number 号码
   */
  deleteSelectedNumber(number) {
    if (Utils.isEmpty(number)) {
      return;
    }
    this.selectedNumberMap.delete(number.replace(/\s+/g, ''));
  }

  /**
   * 获取最近通话记录
   * */
  initCallLog() {
    HiLog.i(TAG, 'initCallLog start !');
    // 用于防止号码重复校验
    let tempMap = new Map();
    // 用于临时存放不重复的item
    let tempList: any[] = [];

    let mergeRule = PreferencesUtil.getCalllogMergeRule();
    HiLog.i(TAG, 'SHOW initCallLog mergeRule');

    let DAHelper = Common.getDAHelper(Constants.uri.CALLLOG_DB_URI);
    callLogService.getAllCalls(DAHelper, mergeRule, data => {
      AppStorageUtil.setCallLogTotalData(data);
      if (data.hasOwnProperty('callLogList') && !Utils.isEmptyList(data.callLogList)) {
        HiLog.i(TAG, 'data  has callLogList key');
        for (let i = 0; i < data.callLogList.length; i++) {
          HiLog.i(TAG, 'callLogList index is %s', i);
          let element = data.callLogList[i];
          let bgColorIndex = parseInt(element.id, 10) % (Constants.background.Color.length);
          element.portraitColor = Constants.background.Color[bgColorIndex];
          element.suffix = Utils.isEmpty(element.displayName) ? '' : element.displayName.substr(element.displayName.length - 1);
          element.checked = false;
          // 重复的号码无需显示
          if (!tempMap.has(Utils.removeSpace(element.phoneNumber))) {
            HiLog.i(TAG, 'callLogList remove same');
            tempList.push(element);
            tempMap.set(element.phoneNumber, null);
          }
          // 显示最近产生通话记录的50条号码
          if (tempList.length > 50) {
            HiLog.i(TAG, 'callLogList more 50 break!');
            break;
          }

        }
      }

      this.callLogTemp = tempList;
      AppStorageUtil.SetOrCreate('callLogTemp', tempList);
      this.tabInfo.recentTotal = this.callLogTemp.length;
      this.checkOptionState();
    });
  }

  buildCalllog(data: LooseObject): CallBean {
    HiLog.i(TAG, 'buildCalllog start !');
    if (Utils.isEmptyObject(data)) {
      HiLog.i(TAG, 'buildCalllog data is empty');
      return null;
    }
    let callbean: CallBean = new CallBean(data.id, data.phone);
    callbean.setName(data.name)
      .setCallTime(data.callTime)
      .setCallType(data.callType)
      .setCallTag(data.callTag)
      .setSimType(data.simType)
      .setIsHd(data.isHd)
      .setFormatNumber(data.formatNumber)
      .setContactKey(data.contactKey);
    HiLog.i(TAG, 'buildCalllog callbean success!');
    return callbean;
  }

  /**
   * 校验是否需要显示底部全选按钮
   * */
  checkOptionState() {
    switch (this.tabInfo.tabIndex) {
      case 0:
        Utils.isEmptyList(this.callLogTemp) ? this.showOption = false : this.showOption = true;
        break;

      case 1:
        Utils.isEmptyList(this.contactsList) ? this.showOption = false : this.showOption = true;
        break;

      case 2:
        Utils.isEmptyList(this.groupList) ? this.showOption = false : this.showOption = true;
        break;

      default:
        break;
    }
  }

  /*
     * 初始化联系人列表数据
     */
  initContactsList() {
    HiLog.i(TAG, 'initContactsList start!');
    let DAHelper = Common.getDAHelper(Constants.uri.CONTACT_DB_URI);
    ContactAbilityModel.getAllContact(DAHelper, (resultList) => {
      HiLog.i(TAG, 'initContactsList resultList success ' + resultList.length);
      let listTemp: any[] = [];
      if (!Utils.isEmptyList(resultList)) {
        for (let element of resultList) {
          element.name = {};
          element.name.fullName = element.emptyNameData;
          element.name.namePrefix = element.namePrefix;
          element.name.nameSuffix = element.nameSuffix;
          if (element.phoneNumbers != null && element.phoneNumbers.length > 0) {
            element.phoneNumbers.forEach(childEle => {
              childEle.checked = false;
              childEle.labelName = this.getPhoneLabelNameById(childEle.labelId);
              this.initVariableSpan(element);
            });
            listTemp.push(element);
          }
        }
        this.contactsList = listTemp;
        AppStorageUtil.SetOrCreate('contactsList', listTemp);
        this.tabInfo.contactsTotal = this.contactsList.length;
        this.contactsInfo.contactsListTotal = this.contactsList.length;
      } else {
        HiLog.e(TAG, 'select contact list is empty!');
      }
    });
  }


  /**
     * 赋值自定义属性，为后面可变字体搜索做准备
     *
     * @param {Object} item 联系人数据
     */
  initVariableSpan(item) {
    // 初始化可变名称
    let matchString = Utils.getMatchedString(item.emptyNameData, this.searchText);
    if (Utils.isEmpty(matchString) || Utils.isEmpty(this.searchText.trim())) {
      item.name.searchTextStart = '';
      item.name.searchTextMiddle = '';
      item.name.searchTextEnd = item.emptyNameData;
    } else {
      let name = item.emptyNameData;
      let index = name.indexOf(matchString);
      item.name.searchTextStart = name.substr(0, index);
      item.name.searchTextMiddle = name.substr(index, matchString.length);
      item.name.searchTextEnd = name.substr(index + matchString.length);
    }
    // 初始化可变手机号
    for (let i = 0; i < item.phoneNumbers.length; i++) {
      let phoneNumber = item.phoneNumbers[i].phoneNumber;
      let matchStringPhone = Utils.getMatchedString(phoneNumber, this.searchText);
      if (Utils.isEmpty(matchStringPhone) || Utils.isEmpty(this.searchText.trim())) {
        item.phoneNumbers[i].startPhone = '';
        item.phoneNumbers[i].middlePhone = '';
        item.phoneNumbers[i].endPhone = phoneNumber;
      } else {
        let phoneIndex = phoneNumber.indexOf(matchStringPhone);
        item.phoneNumbers[i].startPhone = phoneNumber.substr(0, phoneIndex);
        item.phoneNumbers[i].middlePhone = phoneNumber.substr(phoneIndex, matchStringPhone.length);
        item.phoneNumbers[i].endPhone = phoneNumber.substr(phoneIndex + matchStringPhone.length);
      }
    }
  }

  /**
   * 根据手机号的LabelId获取LabelName
   */
  getPhoneLabelNameById(phoneLabelId: string) {
    let labelName: string | Resource = '';
    switch (parseInt(phoneLabelId, 10)) {
      case 1:
        labelName = "住宅";
        break;

      case 2:
        labelName = "电话";
        break;

      case 3:
        labelName = "单位";
        break;

      case 4:
        labelName = "单位传真";
        break;

      case 5:
        labelName = "住宅传真";
        break;

      case 6:
        labelName = "寻呼机";
        break;

      case 7:
        labelName = "其他";
        break;

      case 12:
        labelName = "总机";
        break;

      case 99:
        labelName = "自定义";
        break;

      default:
        break;
    }
    return labelName;
  }
}

export class TabInfo {
  tabIndex: number = 0;
  recentTotal: number = 0;
  contactsTotal: number = 0;
  groupsTotal: number = 0;
  // 是否点击过全选 ：当点击全选时置为true，当点击取消全选时置为false，适配大数据时的情况
  allClickedRecent: boolean = false;
  allClickedContacts: boolean = false;
  allClickedGroups: boolean = false;
  // 各页签的计数
  recentCount: number = 0;
  contactsCount: number = 0;
  groupsCount: number = 0;
  refreshGroupItemState: boolean = false;
  constructor(tabIndex: number) {
    this.tabIndex = tabIndex;
  }
}

/**
 * 联系人列表相关数据
 */
export class ContactsInfo {
  searchContactList = [];
  // 当前已选择的联系人列表，后续大数据时使用
  selectedContactMap = new Map();
  // 是否显示搜索页
  searchLayoutShow: boolean = false;
  // 搜索匹配条数
  searchPhoneNum: number = 0;
  // 是否是搜索列表
  showSearchList: boolean = false;
  // 是否显示默认号码
  showDefaultNumber: boolean = true;
  // 是否显示子号码列表
  showNumberList: boolean = true;
  // 是否显示主号码复选框
  phoneCheckShow: boolean = true;
  // 是否显示子号码列表复选框
  childPhoneCheckShow: boolean = true;
  contactsListCount: number = 0;
  contactsListTotal: number = 0;
  // 对联系人列表已选择的号码计数
  contactsNumberCount: number = 0;
  constructor() {

  }
}