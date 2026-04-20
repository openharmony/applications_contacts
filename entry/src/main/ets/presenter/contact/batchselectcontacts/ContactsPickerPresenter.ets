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

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import BatchSelectContactSource from '../../../model/bean/BatchSelectContactSource';
import AlphabetIndexerPresenter from '../alphabetindex/AlphabetIndexerPresenter';
import prompt from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import {
  ContackPhoneSubInfoModel,
  ContactPickerListItem,
  ContactPickerParam,
  CountAlphabetIndex,
  IContactListAndAlphabetIndex,
  PickerContactList,
  PickerShowSubData
} from '../../../model/type/ContactParams';
import { CustomizedParams, SingleSelectContact } from '../../../model/type';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import ability from '@ohos.ability.ability';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import Want from '@ohos.app.ability.Want';
import emitter from '@ohos.events.emitter';
import PhoneAccountType from '../../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { HashMap, HashSet, JSON, taskpool } from '@kit.ArkTS';
import BatchSelectFavoriteSource from '../../../model/bean/BatchSelectFavoriteSource';
import ContactListPresenter from '../ContactListPresenter';
import { SearchContactResult } from '../../../model/bean/SearchContactResult';
import SearchContactsSource from '../../../model/bean/SearchContactsSource';
// import { updateSearchPickerList,updateSearchPickerListFromDb } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepoTask';
import { updateSearchPickerListFromDb } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepoTask';
import { contact } from '@kit.ContactsKit';
import { addPermissionUsedRecord } from '../../../util/PermissionUtil';
import { UiExtentionParam } from '../../../uiExtentionAbility/ContactUiExtentionAbility';
import { ValueType } from '@kit.ArkData';
import LooseObject from '../../../model/type/LooseObject';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import ContactPickerDataSource from '../../../model/bean/ContactPickerDataSource';
import { getHeadChar } from '../../../util/UserPhoto';
import DotUtil from '../../../util/DotUtil';
import { ResourceUtil } from '../../../util/ResourceUtil';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import ContactAbilityModel from '../../../model/ContactAbilityModel';
import { AlphabetIndexObj } from '../../../model/bean/ContactVo';
import { common } from '@kit.AbilityKit';
import { numFormat } from '../../../util/NumFormat';

const TAG = 'ContactsPickerPresenter';
const OHOS_URI = 'content://com.ohos.contacts/data/anco/';
const SELECT_EXIST_CONTACT_EVENT = 'SELECT_EXIST_CONTACT_EVENT';

const DELAY_TIME: number = 100;

export const DEFAULT_MAX_SELECT_CONTACTS: number = 10000;

export default class ContactsPickerPresenter {
  private regex: RegExp = new RegExp('<\/?.+?>', 'g')
  public static BATCH_SELECT_ITEM_CHECKED = 'BatchSelectItemChecked';
  public pathInfos?: NavPathStack;
  private static sInstance: ContactsPickerPresenter | null;
  public page: number = 0;
  // 保存至已有联系人参数
  public phoneNumberShow: string = '';
  public customizedParams: CustomizedParams = {};
  public isShowAccountants: boolean = false;
  public myAccountantsModel?: SingleSelectContact;
  // 数据源
  public contactsSource: ContactPickerDataSource = new ContactPickerDataSource();
  public favoriteSource: ContactPickerDataSource = new ContactPickerDataSource();
  public selectedSource: ContactPickerDataSource = new ContactPickerDataSource();
  public searchContactsSource: ContactPickerDataSource = new ContactPickerDataSource();
  public alphabetIndexPresenter: AlphabetIndexerPresenter = new AlphabetIndexerPresenter();
  public selectedContactsMap = new HashMap<number, Set<string>>();
  public contactIdMap = new HashMap<number, ContactPickerListItem[]>();
  public defaultSelectContactMap = new Map<number, Set<string>>();
  public contactList: ContactPickerListItem[] = [];
  public favoriteContactList: ContactPickerListItem[] = [];
  public favoriteContactIdSet: Set<number> = new Set<number>();
  public hasChecked: boolean = false;
  public URI: string = '';
  // 外部需传入的参数
  public uiExtentionParam = ContactsGlobalThisHelper.GetGlobalThis()
    .getValue<UiExtentionParam>(ContactsGlobalThisHelper.UiExtentionAbilityParams);
  public isContactsPicker: boolean = false;
  public isMultiSelect: boolean = true;
  public isDisplayByName: boolean = false;
  public selectLimit: number = DEFAULT_MAX_SELECT_CONTACTS;
  public filter?: contact.ContactSelectionFilter;
  public isSaveExistContact: boolean = false;
  public contactFromPicker: contact.Contact = {
    id: 0,
    key: '',
    emails: [],
    events: [],
    groups: [],
    imAddresses: [],
    phoneNumbers: [],
    portrait: {
      uri: ''
    },
    postalAddresses: [],
    relations: [],
    websites: [],
    name: {
      fullName: ''
    },
    note: {
      noteContent: ''
    },
    organization: {
      name: ''
    }
  };
  public userId: number = -1;
  // 搜索相关
  public task?: taskpool.Task;
  public searchSerInitStatus: number = -1;
  public contactSearchList: ContactPickerListItem[] = [];
  public inputKeyword: string = '';
  public contactSearchCount: number = -1;
  public contactSearchOffset: number = 0;
  // 页面相关
  public totalCount: number = 0;
  public selectedCount: number = 0;
  public allSelectMessage: Resource = $r('app.string.select_all');
  public contactsListInited: boolean = false;
  public refreshUI: () => void = () => {
  };
  // 预览一页数据：200条
  private isOnePageShow = true;
  private onePageDataLength = 200;

  private constructor() {
  }

  public static getInstance(): ContactsPickerPresenter {
    if (ContactsPickerPresenter.sInstance == null) {
      ContactsPickerPresenter.sInstance = new ContactsPickerPresenter();
    }
    return ContactsPickerPresenter.sInstance;
  }

  public static getTestInstance(): ContactsPickerPresenter {
    return new ContactsPickerPresenter();
  }

  aboutToAppear(isContactMultiSelect: boolean) {
    HiLog.i(TAG, `aboutToAppear...`);
    if (this.uiExtentionParam) {
      this.isContactsPicker = this.uiExtentionParam.isContactsPicker;
      this.isMultiSelect = this.uiExtentionParam.isContactMultiSelect;
      this.isDisplayByName = this.uiExtentionParam.isDisplayByName;
      this.selectLimit = this.uiExtentionParam.selectLimit;
      this.filter = this.uiExtentionParam.filter;
      this.isSaveExistContact = this.uiExtentionParam.isSaveExistContact;
      this.userId = this.uiExtentionParam.userId;
    } else if (this.pathInfos && this.pathInfos.size() > 0) {
      let param = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as ContactPickerParam;
      this.isSaveExistContact = param.isSaveExistContact;
      this.isDisplayByName = param.isDisplayByName;
      this.phoneNumberShow = param.phoneNumberShow;
    }
    this.isMultiSelect = isContactMultiSelect;

    HiLog.w(TAG, `isContactsPicker: ${this.isContactsPicker}, isMultiSelect: ${this.isMultiSelect
    }, isDisplayByName: ${this.isDisplayByName}, selectLimit: ${this.selectLimit
    }, filter is None: ${this.filter === undefined}, isSaveExistContact: ${this.isSaveExistContact}`)
    this.checkTheParameterType();
    this.preInitContactList(this.userId);
    this.refreshPageMessage();
    AppStorage.setOrCreate('isGettingPickerData', false);
  }

  clearAllData() {
    // 控制拉起picker后，选择编辑半模态页面
    this.isShowAccountants = false;
    this.contactIdMap.clear();
    this.selectedContactsMap.clear();
    this.contactsListInited = false;
    this.contactList = [];
    this.hasChecked = false;
    this.favoriteContactList = [];
  }

  aboutToDisAppear() {
    HiLog.w(TAG, `aboutToDisAppear...`);
    this.clearAllData();
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
  }

  // 全选按钮
  selectAllOnClick() {
    HiLog.w(TAG, `selectAllOnClick`);
    let selectCountTmp = this.selectedCount;
    let selectedContactsMapTmp = this.selectedContactsMap;
    if (selectCountTmp < this.totalCount && selectCountTmp < this.selectLimit) {
      // 全选
      for (let contact of this.favoriteContactList) {
        let contactId: number = contact.contactId;
        let contactPickerList: ContactPickerListItem[] = this.contactIdMap.get(contactId);
        if (contactPickerList == undefined || contactPickerList == null) {
            HiLog.w(TAG, `selectAllOnClick contactId not in contactIdMap: ${contactId}`);
            continue;
        }
        if (!selectedContactsMapTmp.hasKey(contactId)) {
          let subDatas = new Set<string>();
          contactPickerList.forEach((item) => {
            subDatas.add(item.pickerShowSubData.keyValue);
          })
          selectCountTmp++;
          selectedContactsMapTmp.set(contactId, subDatas);
        }
        if (selectCountTmp >= this.selectLimit || selectCountTmp >= this.totalCount) {
          if (selectCountTmp >= this.selectLimit) {
            prompt.showToast({
              message: $r('app.string.maximum_selected_contacts', numFormat(this.selectLimit)),
              duration: 1000,
              showMode: prompt.ToastShowMode.SYSTEM_TOP_MOST,
            });
          }
          break;
        }
      }

      if ((selectCountTmp < this.selectLimit) && (selectCountTmp < this.totalCount)) {
        for (let contact of this.contactList) {
          let contactId: number = contact.contactId;
          let contactPickerList: ContactPickerListItem[] = this.contactIdMap.get(contactId);
          if (!selectedContactsMapTmp.hasKey(contactId)) {
            let subDatas = new Set<string>();
            contactPickerList.forEach((item) => {
              subDatas.add(item.pickerShowSubData.keyValue);
            })
            selectCountTmp++;
            selectedContactsMapTmp.set(contactId, subDatas);
          }
          if (selectCountTmp >= this.selectLimit || selectCountTmp >= this.totalCount) {
            if (selectCountTmp >= this.selectLimit) {
              prompt.showToast({
                message: $r('app.string.maximum_selected_contacts', numFormat(this.selectLimit)),
                duration: 1000,
                showMode: prompt.ToastShowMode.SYSTEM_TOP_MOST,
              });
            }
            break;
          }
        }
      }
      this.selectedCount = selectCountTmp;
      this.selectedContactsMap = selectedContactsMapTmp;
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(true, this.selectedCount);
    } else {
      // 取消全选
      this.selectedContactsMap.clear();
      AccessibilityUtil.getInstance().sendAllSelectedOrDeselected(false, this.selectedCount);
      this.selectedCount = 0;
    }
    emitter.emit(ContactsPickerPresenter.BATCH_SELECT_ITEM_CHECKED);
    this.refreshPageMessage();
  }

  // 单击
  itemOnClick(contactId: number, subData: string = '', dataId: number) {
    HiLog.w(TAG, `itemOnClick, contactId: ${contactId}, subData: ${StringUtil.maskSensitiveInfo(subData)}, dataId: ${dataId}`);

    if (this.isSaveExistContact) {
      this.saveExistContact(contactId);
      return;
    }

    if (this.isMultiSelect) {
      this.itemOnMultiClick(contactId, subData);
    } else {
      this.itemOnSingleClick(contactId, subData, dataId);
    }

    let eventData: emitter.EventData = {
      data: { 'contactId': contactId }
    };
    emitter.emit(ContactsPickerPresenter.BATCH_SELECT_ITEM_CHECKED, eventData);
    this.refreshPageMessage();
  }

  itemOnSingleClick(contactId: number, subData: string = '', dataId: number) {
    if (this.selectedCount > 0) {
      this.selectedCount = 0;
      this.selectedContactsMap.clear();
    }
    this.selectedCount++;
    this.selectedContactsMap.set(contactId, new Set<string>().add(subData));

    this.URI = OHOS_URI + dataId.toString();
  }

  itemOnMultiClick(contactId: number, subData: string = '') {
    if (this.selectedContactsMap.hasKey(contactId)) {
      // 点击的联系人ID 已选择
      let subDatas: Set<string> | undefined = this.selectedContactsMap.get(contactId);
      if (this.isDisplayByName) {
        // 联系人维度 直接移除
        this.selectedCount--;
        this.selectedContactsMap.remove(contactId);
        HiLog.i(TAG, 'itemOnClick联系人维度 直接移除:contactId：' + contactId);
      } else if (subDatas.has(subData)) {
        // 号码维度 点击的号码 已选择 直接移除
        subDatas.delete(subData);
        if (subDatas.size <= 0) {
          // 选择号码为空，直接移除ID
          this.selectedCount--;
          this.selectedContactsMap.remove(contactId);
        } else {
          // 更新 ID 所对应的已选择号码
          this.selectedContactsMap.set(contactId, subDatas);
        }
        HiLog.i(TAG, 'itemOnClick号码维度 点击的号码 已选择 直接移除:contactId：' + contactId);
      } else {
        // 号码维度 点击的号码 未选择，直接添加，并更新 ID 所对应的已选择号码
        subDatas.add(subData);
        this.selectedContactsMap.set(contactId, subDatas);
        HiLog.i(TAG, 'itemOnClick号码维度 点击的号码 未选择，直接添加，并更新 ID 所对应的已选择号码:subData：' + subData);
      }
    } else if (this.selectedCount + 1 > this.selectLimit) {
      // 点击的联系人ID 未选择，新增 ID，但超出最大选择数量
      prompt.showToast({
        message: $r('app.string.maximum_selected_contacts', numFormat(this.selectLimit)),
        duration: 1000,
        showMode: prompt.ToastShowMode.SYSTEM_TOP_MOST,
      });
    } else {
      // 点击的联系人ID 未选择，新增 ID 所对应的已选择号码
      this.selectedCount++;
      this.selectedContactsMap.set(contactId, new Set<string>().add(subData));
      HiLog.i(TAG, 'itemOnClick执行新增联系人:subData：' + subData);
    }

    HiLog.i(TAG, 'itemOnClick这里点击了选择联系人列表中的项,selectedContactsMap:' + JSON.stringify(this.selectedContactsMap));
  }

  initDefaultSelected(defaultSelectContactMap: Map<number, Set<string>>) {
    for (let contact of this.contactIdMap) {
      let contactId: number = contact[0];
      let contactPickerList: ContactPickerListItem[] = contact[1];
      if (this.isMultiSelect && this.selectedCount + 1 > this.selectLimit) {
        prompt.showToast({
          message: $r('app.string.maximum_selected_contacts', numFormat(this.selectLimit)),
          duration: 1000,
          showMode: prompt.ToastShowMode.SYSTEM_TOP_MOST,
        });
        break;
      } else if (!this.isMultiSelect && this.selectedCount >= 1) {
        break;
      }
      if (defaultSelectContactMap.has(contactId)) {
        let subData = defaultSelectContactMap.get(contactId);
        if (subData?.size === 0) {
          if (contactPickerList.length > 0) {
            contactPickerList.forEach((item) => {
              subData?.add(item.pickerShowSubData.keyValue);
            })
          } else {
            subData?.add('');
          }
        }
        if (!this.selectedContactsMap.hasKey(contactId)) {
          this.selectedCount++;
        }
        this.selectedContactsMap.set(contactId, subData);
      }
    }
    emitter.emit(ContactsPickerPresenter.BATCH_SELECT_ITEM_CHECKED);
  }

  initSelectedDataSource() {
    HiLog.w(TAG, `initSelectedDataSource`);
    let selectedContactList: ContactPickerListItem[] = [];
    for (let contact of this.contactIdMap) {
      let contactId: number = contact[0];
      let contactPickerList: ContactPickerListItem[] = contact[1];
      let pickerShowSubDatas = this.selectedContactsMap.get(contactId);
      if (pickerShowSubDatas) {
        let contactPickerListTmp =
          contactPickerList.filter(item => pickerShowSubDatas.has(item.pickerShowSubData.keyValue));
        selectedContactList.push(...contactPickerListTmp);
      }
    }
    HiLog.w(TAG, `initSelectedDataSource, selectedContactList size: ${selectedContactList.length}`);
    this.selectedSource.refresh(selectedContactList);
  }

  // picker 页 完成按钮
  selectBatchContact() {
    HiLog.w(TAG, 'selectBatchContact.');
    let ids: Set<number> = new Set();
    HiLog.w(TAG, `selectBatchContact, selectedContactList : ` + this.selectedContactsMap);
    this.selectedContactsMap.forEach((phones, contactId) => {
      if (contactId) {
        ids.add(contactId);
        HiLog.w(TAG, `selectBatchContact, contactId : ` + contactId);
      }
    })
    HiLog.w(TAG, `selectBatchContact, ids : ` + ids);
    this.getPickerDataByIds(ids, (contactIdPickerDataMap: Map<number, contact.Contact>) => {
      HiLog.w(TAG, `selectBatchContact, contactIdPickerDataMap : ` + JSON.stringify(Array.from(contactIdPickerDataMap.entries())));
      this.confirm(contactIdPickerDataMap);
    })
  }

  // picker 返回数据
  confirm(contactIdPickerDataMap: Map<number, contact.Contact>, isFinish: boolean = true) {
    try {
      HiLog.w(TAG, `confirm! isContactsPicker: ${this.isContactsPicker}`);

      let contacts = this.dealContactName(contactIdPickerDataMap);
      let pickerDataResult = this.dealPickerDataResult(contactIdPickerDataMap);

      let selectContactIds: number[] = [];
      let selectContactCount: number = contactIdPickerDataMap.size;
      for (let contactId of contactIdPickerDataMap.keys()) {
        selectContactIds.push(contactId);
      }
      HiLog.w(TAG, `selectContactCount: ${selectContactCount}, selectContactIds: ${selectContactIds}`);

      let parameters: Record<string, string | number | number[]> = {
        'contactObjects': JSON.stringify(contacts),
        'selectContactCount': selectContactCount,
        'selectContactIds': selectContactIds
      };
      let want: Want = {
        'parameters': parameters,
        'uri': this.URI
      };
      // 单选的时候，需要通过 terminateSelfWithResult 传递数据
      let result: ability.AbilityResult = {
        'resultCode': 0,
        'want': this.isMultiSelect && this.isContactsPicker ? undefined : want
      };
      let resultData: Record<string, Object> = {
        'resultCode': 0,
        'want': want
      };

      if (!this.isContactsPicker) {
        // 兼容 uiExtension 方式 调用联系人picker，不支持大数据量传输
        ContactsGlobalThisHelper.GetGlobalThis().getUIExtensionContentSession()?.sendData(resultData);
      } else {
        // 兼容 数据库方式 调用联系人picker，大数据量分批传输
        let index = 0;
        let total = pickerDataResult.length;
        const len = 100;
        do {
          let data: contact.Contact[] = [];
          if (pickerDataResult.length <= len) {
            data = [...pickerDataResult];
            pickerDataResult = [];
          } else {
            data = pickerDataResult.splice(0, len);
          }
          HiLog.w(TAG, `index: ${index}, total: ${total}, data length : ${data.length}`);
          let parameters: Record<string, string | number> = {
            'pickerData': JSON.stringify(data),
            'index': index,
            'total': total
          };
          ContactsGlobalThisHelper.GetGlobalThis().getUIExtensionContentSession()?.sendData(parameters);
          index++;
        } while (pickerDataResult.length > 0)
        HiLog.w(TAG, `sendData end`);
      }

      // 兼容 通过 startAbility 方式调用数据（只支持单选）
      ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()?.terminateSelfWithResult(result)
        .then(() => {
          HiLog.w(TAG, 'terminateSelfWithResult Operation succeeded ');
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'Operation failed. Cause: %s', error?.message);
        });

      // 点击完成才增加访问记录
      if (isFinish) {
        addPermissionUsedRecord(this.uiExtentionParam?.callerToken ?? -1);
      }
    } catch (error) {
      HiLog.e(TAG, `confirm error: ${error?.message}`);
    } finally {
      HiLog.w(TAG, 'isGettingPickerData set false.');
      AppStorage.setOrCreate('isGettingPickerData', false);
    }
  }

  // 从批量选择跳转到编辑联系人（保存至已有联系人）
  saveExistContact(contactId: number) {
    HiLog.w(TAG, `saveExistContact. contactId: ${contactId
    }, phoneNumberShow: ${StringUtil.maskSensitiveInfo(this.phoneNumberShow)}`);
    // 联系人打点--点击选择至已有联系人页面
    this.customizedParams.ISSELECT = 1;
    DotUtil.getInstance().contactDot(this.customizedParams, SELECT_EXIST_CONTACT_EVENT);

    AccessibilityUtil.getInstance().sendAccessibilityEventInfo(
      ResourceUtil.getStringByResourceId($r('app.string.accessibility_selected').id));

    this.myAccountantsModel = {
      updataShow: true,
      contactId: contactId,
      editContact: 2,
      phoneNumberShow: this.phoneNumberShow,
      newContactData: this.contactFromPicker,
    } as SingleSelectContact;
    this.isShowAccountants = true;
    if (this.isSaveExistContact && this.isContactsPicker) {
      HiLog.i(TAG, 'isFromPickerSaveExistContact !!');
      AppStorage.setOrCreate('isFromPickerSaveExistContact', true);
    }
    this.refreshPageMessage();
  }

  // 过滤未选择的手机号码并去重
  dealPickerDataResult(contactIdPickerDataMap: Map<number, contact.Contact>): contact.Contact[] {
    HiLog.w(TAG, 'dealPickerDataResult start!');
    let pickerDataResult: contact.Contact[] = [];
    contactIdPickerDataMap.forEach((pickerData: contact.Contact, contactId: number) => {
      if (this.isDisplayByName) {
        pickerDataResult.push(pickerData);
      } else {
        let selectedTels = this.selectedContactsMap.get(contactId);
        let phones: contact.PhoneNumber[] = [];
        pickerData.phoneNumbers?.forEach((phone) => {
          if (selectedTels.has(phone.phoneNumber)) {
            // 去重操作，相同号码只返回 1个
            selectedTels.delete(phone.phoneNumber);
            phones.push(phone);
          }
        })
        pickerData.phoneNumbers = phones;
        pickerDataResult.push(pickerData);
      }
    })
    HiLog.i(TAG, 'dealPickerDataResult end!');
    return pickerDataResult;
  }

  // 兼容旧方法的数据处理方式
  dealContactName(contactIdPickerDataMap: Map<number, contact.Contact>) {
    HiLog.w(TAG, 'dealContactName.');
    let contacts: Record<string, string | number>[] = [];
    this.selectedContactsMap.forEach((phones: Set<string>, contactId: number) => {
      let contactPicker = contactIdPickerDataMap.get(contactId);
      let name = contactPicker?.name?.fullName ?? '';
      if (this.isDisplayByName) {
        // 以联系人维度选择 返回全量号码
        if ((contactPicker?.phoneNumbers?.length ?? 0) > 0) {
          contactPicker?.phoneNumbers?.forEach((phoneNumber) => {
            let contact: Record<string, string | number> = {
              'contactName': name,
              'telephone': phoneNumber.phoneNumber,
              'id': contactId,
              'contactId': contactId,
            };
            contacts.push(contact);
          })
        } else {
          let contact: Record<string, string | number> = {
            'contactName': name,
            'telephone': '',
            'id': contactId,
            'contactId': contactId,
          };
          contacts.push(contact);
        }
      } else {
        phones?.forEach((phoneNumber: string) => {
          if (!StringUtil.isEmpty(phoneNumber)) {
            let contact: Record<string, string | number> = {
              'contactName': name,
              'telephone': phoneNumber,
              'id': contactId,
              'contactId': contactId,
            };
            contacts.push(contact);
          }
        })
      }
    })
    return contacts;
  }

  // 刷新页面信息
  refreshPageMessage() {
    HiLog.w(TAG, 'refreshPageMessage');
    if (this.selectedCount >= this.selectLimit || this.selectedCount >= this.totalCount) {
      this.allSelectMessage = $r('app.string.unselect_all');
    } else {
      this.allSelectMessage = $r('app.string.select_all');
    }
    this.refreshUI();
  }

  // 初始化数据
  initContactList() {
    HiLog.w(TAG, `initContactsList start! page: ${this.page}`);
    ContactListPresenter.getInstance().getPhotosInfoAsync(this.userId).then(() => {
      if (!this.hasChecked) {
        // 先查下收藏联系人
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)?.sendRequest('getPickerContacts', {
          'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          'isDisplayByName': this.isDisplayByName,
          'contactSelectionFilter': this.filter,
          'userId': this.userId,
          'page': this.page,
          'isFavorite': true,
          'isOnePageShow': false,
        }, (result: PickerContactList) => {
          HiLog.i(TAG, `favoritecontactList size: ${result.contactList.length}`);
          let favoriteContactListTmp = this.favoriteContactList;
          let favoriteContactIdListTmp = this.favoriteContactIdSet;
          for (let contact of result.contactList) {
            favoriteContactListTmp.push(contact);
            if (!this.favoriteContactIdSet.has(contact.contactId)) {
              let contactPickerList: ContactPickerListItem[] = this.contactIdMap.get(contact.contactId) ?? [];
              contactPickerList.push(contact);
              this.contactIdMap.set(contact.contactId, contactPickerList);
              favoriteContactIdListTmp.add(contact.contactId);
            }
          }
          this.favoriteContactIdSet = favoriteContactIdListTmp;
          this.hasChecked = true;
          // 收藏排序
          if (favoriteContactListTmp.length > 0) {
            favoriteContactListTmp.sort((a, b) => {
              return a.favoriteOrder - b.favoriteOrder
            })
          }
          this.favoriteContactList = favoriteContactListTmp;

          if (result.defaultSelectContactMap.size > 0) {
            this.initDefaultSelected(result.defaultSelectContactMap)
          }
          result.defaultSelectContactMap.forEach((value, key) => {
            if (this.defaultSelectContactMap.has(key)) {
              // 如果 key 已存在，合并两个 Set
              const existingSet = this.defaultSelectContactMap.get(key);
              existingSet?.forEach(item => {
                value.add(item);
              });
              this.defaultSelectContactMap.set(key, value);
            } else {
              this.defaultSelectContactMap.set(key, value);
            }
          });
        })
      }

      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)?.sendRequest('getPickerContacts', {
        'context': ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        'isDisplayByName': this.isDisplayByName,
        'contactSelectionFilter': this.filter,
        'userId': this.userId,
        'page': this.page,
        'isFavorite': false,
        'isOnePageShow': this.isOnePageShow,
      }, (result: PickerContactList) => {
        HiLog.w(TAG, `getPickerContacts success. page: ${this.page}, isEnd: ${result.isEnd}, contactList size:
          ${result.contactList.length}, defaultSelectContactMap size: ${result.defaultSelectContactMap.size}`);
        if (this.page == 0 && !this.isOnePageShow && this.totalCount <= this.onePageDataLength) {
          this.contactList = [];
        }
        let contactListTmp = this.contactList;
        let contactIdMapTmp = this.contactIdMap;
        let favoriteContactIdListTmp = this.favoriteContactIdSet;
        for (let contact of result.contactList) {
          contactListTmp.push(contact);
          if (!this.favoriteContactIdSet.has(contact.contactId)) {
            let contactPickerList: ContactPickerListItem[] = this.contactIdMap.get(contact.contactId) ?? [];
            contactPickerList.push(contact);
            contactIdMapTmp.set(contact.contactId, contactPickerList);
            favoriteContactIdListTmp.add(contact.contactId)
          }
        }
        this.contactList = contactListTmp;
        this.contactIdMap = contactIdMapTmp;
        HiLog.w(TAG, `favoriteContactList size: ${this.favoriteContactList.length},
          contactList: ${this.contactList.length}`);

        // 总联系人数量
        this.totalCount = this.contactIdMap.length;
        // 更新收藏列表数据源
        this.favoriteSource.refresh(this.favoriteContactList);
        // 更新联系人列表数据源
        this.contactsSource.refresh(this.contactList);

        // 二级索引相关
        let alphabetIndex: Record<string, AlphabetIndexObj> = {};
        let favoriteAlphabetIndex: Record<string, AlphabetIndexObj> = {};
        this.contactList.forEach((contact, index) => {
          ContactAbilityModel.addAlphabetIndexObj(
            contact, index, alphabetIndex, index === this.contactList.length - 1);
        })
        this.favoriteContactList.forEach((contact, index) => {
          ContactAbilityModel.addAlphabetIndexObj(
            contact, index, favoriteAlphabetIndex, index === this.favoriteContactList.length - 1);
        })

        this.alphabetIndexPresenter.initFavoriteAlphabetIndex(favoriteAlphabetIndex);
        this.alphabetIndexPresenter.initAlphabetIndex(alphabetIndex);
        this.alphabetIndexPresenter.initContactList(this.contactList, true);
        // 快速刷新  数据少或者非首页数据时
        if (!this.isOnePageShow || result.isEnd) {
          // 初始化 默认选择联系人
          if (result.defaultSelectContactMap.size > 0) {
            this.initDefaultSelected(result.defaultSelectContactMap)
          }
          result.defaultSelectContactMap.forEach((value, key) => {
            if (this.defaultSelectContactMap.has(key)) {
              // 如果 key 已存在，合并两个 Set
              const existingSet = this.defaultSelectContactMap.get(key);
              existingSet?.forEach(item => {
                value.add(item);
              });
              this.defaultSelectContactMap.set(key, value);
            } else {
              this.defaultSelectContactMap.set(key, value);
            }
          });

          this.contactsListInited = true;
          this.refreshPageMessage();
        }

        if (!result.isEnd) {
          // 首屏刷新数据查询200条
          if (this.page == 0 && this.totalCount <= this.onePageDataLength && this.isOnePageShow) {
            this.page = 0;
            this.isOnePageShow = false;
            setTimeout(() => {
              this.contactsListInited = true;
              this.refreshPageMessage();
            }, 750)
          } else {
            this.page++;
          }
          HiLog.w(TAG, `initContactList again, page: ${this.page}`);
          this.initContactList();
        }
      });
    });
  }

  // 初始化数据
  async preInitContactList(userId: number) {
    // 查询数据前先给原来数据全清空掉
    this.clearAllData();
    HiLog.w(TAG, `preInitContactList start! filter is undefined: ${this.filter == undefined}, userId: ${userId}`);
    ContactListPresenter.getInstance().getPhotosInfoAsync(userId);
    // 先查一遍总数
    let countAlphabetIndex = await ContactAbilityModel.getAllContactSizeSync(userId, true);
    let total = (countAlphabetIndex as CountAlphabetIndex).count;
    let forNum: number = Math.ceil(total / 10000);
    HiLog.i(TAG, `preInitContactList getAllContactSizeSync current total: ${total}, forNum: ${forNum}`);
    let result: PickerContactList = {
      contactList: [],
      defaultSelectContactMap: new Map(),
      isEnd: false
    };
    let resultMap: Map<number, PickerContactList> = new Map<number, PickerContactList>();
    let promiseList: Promise<boolean>[] = []
    for (let i = 0; i < forNum; i++) {
      promiseList.push(new Promise(async (resolve) => {
        let task1: taskpool.Task;
        this.isOnePageShow = i == 0 ? true : false;
        if (this.filter !== undefined) {
          task1 = new taskpool.Task(getPickerContactsByFilter, this.isDisplayByName, this.filter, userId, i, false,
            this.isOnePageShow, ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
        } else {
          task1 = new taskpool.Task(getPickerContactsNoFilter, this.isDisplayByName, userId, i, false,
            this.isOnePageShow, ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
        }
        taskpool.execute(task1).then((data: object) => {
          let pickerContactList = data as PickerContactList;
          resultMap.set(i, pickerContactList);
          HiLog.w(TAG, `initContactList page: ${i} queryAllEnd: ${pickerContactList.isEnd},
            contactListSize: ${pickerContactList.contactList.length}`);
          resolve(true);
        });
      }));
    }
    await Promise.all(promiseList).then(() => {
      for (let i = 0; i < resultMap.size; i++) {
        let temp = resultMap.get(i) as PickerContactList;
        result.contactList.push(...temp.contactList);
        temp.defaultSelectContactMap.forEach((value, key) => {
          result.defaultSelectContactMap.set(key, value);
        })
      }
      this.refreshContactPickerList(result);
    }).catch((error: Error) => {
      HiLog.e(TAG, `Error in Promise.all: ${error?.message}`);
    });
  }

  refreshContactPickerList(result: PickerContactList) {
    HiLog.i(TAG, 'allContacts size is '+ result.contactList.length);
    if (this.page == 0 && !this.isOnePageShow && this.totalCount <= this.onePageDataLength) {
      this.contactList = [];
    }
    let contactListTmp = this.contactList;
    let contactIdMapTmp = this.contactIdMap;
    let favoriteContactListTmp = this.favoriteContactList;
    for (let contact of result.contactList) {
      contactListTmp.push(contact);
      let contactPickerList: ContactPickerListItem[] = this.contactIdMap.get(contact.contactId) ?? [];
      contactPickerList.push(contact);
      contactIdMapTmp.set(contact.contactId, contactPickerList);
      if (!this.hasChecked && contact.isFavorite) {
        let favoriteContact: ContactPickerListItem = {
          contactId: contact.contactId,
          displayName: contact.displayName,
          pickerShowSubData: contact.pickerShowSubData,
          isFavorite: contact.isFavorite,
          headChar: contact.headChar,
          nameSuffix: contact.nameSuffix,
          namePrefix: contact.namePrefix,
          favoriteOrder: contact.favoriteOrder,
          isFirst: contact.isFirst
        }
        favoriteContactListTmp.push(favoriteContact);
      }
    }
    // 收藏排序
    if (favoriteContactListTmp.length > 0) {
      favoriteContactListTmp.sort((a, b) => {
        return a.favoriteOrder - b.favoriteOrder
      })
    }
    this.favoriteContactList = favoriteContactListTmp;
    if (result.defaultSelectContactMap.size > 0) {
      this.initDefaultSelected(result.defaultSelectContactMap)
    }
    result.defaultSelectContactMap.forEach((value, key) => {
      if (this.defaultSelectContactMap.has(key)) {
        // 如果 key 已存在，合并两个 Set
        const existingSet = this.defaultSelectContactMap.get(key);
        existingSet?.forEach(item => {
          value.add(item);
        });
        this.defaultSelectContactMap.set(key, value);
      } else {
        this.defaultSelectContactMap.set(key, value);
      }
    });
    this.contactList = contactListTmp;
    this.contactIdMap = contactIdMapTmp;
    HiLog.w(TAG, `favoriteContactList size: ${this.favoriteContactList.length},
          contactList: ${this.contactList.length}`);

    // 总联系人数量
    this.totalCount = this.contactIdMap.length;
    // 更新收藏列表数据源
    this.favoriteSource.refresh(this.favoriteContactList);
    // 更新联系人列表数据源
    this.contactsSource.refresh(this.contactList);

    // 二级索引相关
    let alphabetIndex: Record<string, AlphabetIndexObj> = {};
    let favoriteAlphabetIndex: Record<string, AlphabetIndexObj> = {};
    this.contactList.forEach((contact, index) => {
      ContactAbilityModel.addAlphabetIndexObj(
        contact, index, alphabetIndex, index === this.contactList.length - 1);
    })
    this.favoriteContactList.forEach((contact, index) => {
      ContactAbilityModel.addAlphabetIndexObj(
        contact, index, favoriteAlphabetIndex, index === this.favoriteContactList.length - 1);
    })

    this.alphabetIndexPresenter.initFavoriteAlphabetIndex(favoriteAlphabetIndex);
    this.alphabetIndexPresenter.initAlphabetIndex(alphabetIndex);
    this.alphabetIndexPresenter.initContactList(this.contactList, true);
    // 快速刷新  数据少或者非首页数据时

    if (result.defaultSelectContactMap.size > 0) {
      this.initDefaultSelected(result.defaultSelectContactMap)
    }
    result.defaultSelectContactMap.forEach((value, key) => {
      if (this.defaultSelectContactMap.has(key)) {
        // 如果 key 已存在，合并两个 Set
        const existingSet = this.defaultSelectContactMap.get(key);
        existingSet?.forEach(item => {
          value.add(item);
        });
        this.defaultSelectContactMap.set(key, value);
      } else {
        this.defaultSelectContactMap.set(key, value);
      }
    });
    this.contactsListInited = true;
    this.refreshPageMessage();
  }

  /**
   * 从数据库搜索联系人
   * @param value
  * Search for Contacts
   */
  getSearchContactResultFromDb(value: string) {
    HiLog.w(TAG, 'getSearchContactResultFromDb start!!');
    this.contactSearchList = [];
    this.contactSearchOffset = 0;
    this.inputKeyword = value;
    if (value.replace(/\s*/g, '') === '') {
      HiLog.w(TAG, 'getSearchContactResultFromDb value is empty');
      this.contactSearchList = [];
      this.searchContactsSource.refresh(this.contactSearchList);
      if (this.task) {
        try {
          taskpool.cancel(this.task as taskpool.Task);
          HiLog.w(TAG, 'search taskpool value empty cancel success');
        } catch (err) {
          HiLog.e(TAG, 'search taskpool value empty cancel error ' + (err as BusinessError).message);
        }
      }
      return;
    } else {
      this.inputKeyword = value;
      if (this.task) {
        try {
          taskpool.cancel(this.task as taskpool.Task);
          HiLog.w(TAG, 'search taskpool cancel success');
        } catch (err) {
          HiLog.e(TAG, 'search taskpool cancel error ' + (err as BusinessError).message);
        }
      }
      this.contactSearchTaskFromDb();
    }
  }

  contactSearchTaskFromDb() {
    HiLog.w(TAG, `contactSearchTaskFromDb start, contactSearchOffset: ${this.contactSearchOffset}`);
    this.task = new taskpool.Task(updateSearchPickerListFromDb, this.inputKeyword, this.contactSearchOffset,ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    taskpool.executeDelayed(DELAY_TIME, this.task, taskpool.Priority.HIGH).then((searchResultsObject: Object) => {
      let searchResults: SearchContactResult[] = searchResultsObject as SearchContactResult[];
      HiLog.w(TAG, `contactSearchTaskFromDb searchResults size: ${searchResults.length}`);
      this.contactSearchOffset += searchResults.length;
      if (searchResults.length !== 0 || (searchResults.length === 0 && this.contactSearchList.length !== 0)) {
        // SearchContactResult 类型转换成 ContactPickerListItem 类型
        searchResults.forEach((searchResult) => {
          let contactId = Number.parseInt(searchResult.entityId);
          if (this.contactIdMap.hasKey(contactId)) {
            let contactPickerList = this.contactIdMap.get(contactId);
            contactPickerList.forEach((item) => {
              let pickerShowSubData: PickerShowSubData = {
                dataId: item.pickerShowSubData.dataId,
                keyValue: item.pickerShowSubData.keyValue,
                showValue: PhoneNumber.fromString(item.pickerShowSubData.keyValue).dynamicPhoneFormat(),
              }
              let searchContact: ContactPickerListItem = {
                contactId: contactId,
                displayName: searchResult.name,
                pickerShowSubData: pickerShowSubData,
                isFavorite: false,
                headChar: item.headChar,
                nameSuffix: item.nameSuffix,
                namePrefix: item.namePrefix,
                favoriteOrder: 0,
                isFirst: item.isFirst,
                highLight: PhoneNumber.formatDisplayPhoneNumber(pickerShowSubData.showValue as string,
                  this.inputKeyword)
              }

              this.contactSearchList.push(searchContact);
            })
          }
        })
      } else {
        HiLog.w(TAG, `contactSearchTaskFromDb contactSearchCount3: ${this.contactSearchList.length}`);
        this.contactSearchList = [];
      }
      this.contactSearchCount = this.contactSearchList.length;
      HiLog.w(TAG, `contactSearchTaskFromDb contactSearchCount4: ${this.contactSearchCount}`);
      this.searchContactsSource.refresh(this.contactSearchList);
      this.task = undefined;
      // if (searchResults.length >= 100) {
      //   HiLog.w(TAG, `contactSearchTaskFromDb again!`);
      //   this.contactSearchTask();
      // }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `contactSearchTaskFromDb error: ${error.message}`);
    })
  }



  /**
   * 搜索联系人
   * @param value
  * Search for Contacts
   */
  // getSearchContactResult(value: string) {
  //   HiLog.w(TAG, 'getSearchContactResult start!!');
  //   this.contactSearchList = [];
  //   this.contactSearchOffset = 0;
  //   this.inputKeyword = value;
  //   if (value.replace(/\s*/g, '') === '') {
  //     HiLog.w(TAG, 'getSearchContactResult value is empty');
  //     this.contactSearchList = [];
  //     this.searchContactsSource.refresh(this.contactSearchList);
  //     if (this.task) {
  //       try {
  //         taskpool.cancel(this.task as taskpool.Task);
  //         HiLog.w(TAG, 'search taskpool value empty cancel success');
  //       } catch (err) {
  //         HiLog.e(TAG, 'search taskpool value empty cancel error ' + (err as BusinessError).message);
  //       }
  //     }
  //     return;
  //   } else {
  //     this.inputKeyword = value;
  //     if (this.task) {
  //       try {
  //         taskpool.cancel(this.task as taskpool.Task);
  //         HiLog.w(TAG, 'search taskpool cancel success');
  //       } catch (err) {
  //         HiLog.e(TAG, 'search taskpool cancel error ' + (err as BusinessError).message);
  //       }
  //     }
  //     this.contactSearchTask();
  //   }
  // }

  // contactSearchTask() {
  //   HiLog.w(TAG, `contactSearchTask start, contactSearchOffset: ${this.contactSearchOffset}`);
  //   this.task = new taskpool.Task(updateSearchPickerList, this.inputKeyword, this.contactSearchOffset);
  //   taskpool.executeDelayed(DELAY_TIME, this.task, taskpool.Priority.HIGH).then((searchResultsObject: Object) => {
  //     let searchResults: SearchContactResult[] = searchResultsObject as SearchContactResult[];
  //     HiLog.w(TAG, `contactSearchTask searchResults size: ${searchResults.length}`);
  //     this.contactSearchOffset += searchResults.length;
  //     if (searchResults.length !== 0 || (searchResults.length === 0 && this.contactSearchList.length !== 0)) {
  //       // SearchContactResult 类型转换成 ContactPickerListItem 类型
  //       searchResults.forEach((searchResult) => {
  //         let contactId = Number.parseInt(searchResult.entityId);
  //         if (this.contactIdMap.hasKey(contactId)) {
  //           let contactPickerList = this.contactIdMap.get(contactId);
  //           contactPickerList.forEach((item) => {
  //             let pickerShowSubData: PickerShowSubData = {
  //               dataId: item.pickerShowSubData.dataId,
  //               keyValue: item.pickerShowSubData.keyValue,
  //               showValue: PhoneNumber.fromString(item.pickerShowSubData.keyValue).dynamicPhoneFormat(),
  //             }
  //             let searchContact: ContactPickerListItem = {
  //               contactId: contactId,
  //               displayName: searchResult.name,
  //               pickerShowSubData: pickerShowSubData,
  //               isFavorite: false,
  //               headChar: item.headChar,
  //               nameSuffix: item.nameSuffix,
  //               namePrefix: item.namePrefix,
  //               favoriteOrder: 0,
  //               isFirst: item.isFirst,
  //               highLight: PhoneNumber.formatDisplayPhoneNumber(pickerShowSubData.showValue as string,
  //                 this.inputKeyword)
  //             }
  //
  //             this.contactSearchList.push(searchContact);
  //           })
  //         }
  //       })
  //     } else {
  //       HiLog.w(TAG, `contactSearchTask contactSearchCount3: ${this.contactSearchList.length}`);
  //       this.contactSearchList = [];
  //     }
  //     this.contactSearchCount = this.contactSearchList.length;
  //     HiLog.w(TAG, `contactSearchTask contactSearchCount4: ${this.contactSearchCount}`);
  //     this.searchContactsSource.refresh(this.contactSearchList);
  //     this.task = undefined;
  //     // if (searchResults.length >= 100) {
  //     //   HiLog.w(TAG, `contactSearchTask again!`);
  //     //   this.contactSearchTask();
  //     // }
  //   }).catch((error: BusinessError) => {
  //     HiLog.e(TAG, `contactSearchTask error: ${error.message}`);
  //   })
  // }

  getPickerDataByIds(
    contactIds: Set<number>, callBack: (contactIdPickerDataMap: Map<number, contact.Contact>) => void) {
    HiLog.w(TAG, `getPickerDataByIds all start, contactIds size: ${contactIds.size}.`);
    if (AppStorage.get<boolean>('isGettingPickerData')) {
      HiLog.w(TAG, `is getting picker data.`);
      return;
    }
    AppStorage.setOrCreate('isGettingPickerData', true);

    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getPickerDataByIds', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        contactIds: Array.from(contactIds),
        userId: this.userId,
      }, (contactIdPickerDataMap: Map<number, contact.Contact>) => {
        if (contactIdPickerDataMap.size <= 0) {
          HiLog.e(TAG, 'getPickerDataByIds failed , result is null ');
        }
        HiLog.w(TAG, 'getPickerDataByIds end');
        callBack(contactIdPickerDataMap);
      })
  }

  checkTheParameterType() {
    HiLog.w(TAG, `checkTheParameterType`)
    let result: BusinessError = {
      code: 0,
      name: '',
      message: ''
    }
    if (this.selectLimit < 1 || this.selectLimit > DEFAULT_MAX_SELECT_CONTACTS) {
      result.code = 401;
      result.message = `The selectLimit parameter is incorrect.`;
    } else if (this.filter) {
      let hasFilterClause = false;

      if (result.code === 0 && this.filter.filterClause.id) {
        hasFilterClause = true;
        result = this.checkFilterOptions(this.filter.filterClause.id, 'id');
      }
      if (result.code === 0 && this.filter.filterClause.name) {
        hasFilterClause = true;
        result = this.checkFilterOptions(this.filter.filterClause.name, 'name');
      }
      if (result.code === 0 && this.filter.filterClause.focusModeList) {
        hasFilterClause = true;
        result = this.checkFilterOptions(this.filter.filterClause.focusModeList, 'focusModeList');
      }
      if (result.code === 0 && this.filter.filterClause.dataItem) {
        hasFilterClause = true;
        result = this.checkFilterOptions(this.filter.filterClause.dataItem.options, 'dataItem');
      }
      if (result.code === 0 && !hasFilterClause) {
        result.code = 401;
        result.message = `The filterClause parameter is incorrect.`;
      }
    }
    HiLog.w(TAG, `checkTheParameterType result code: ${result?.code}, name: ${result?.name},
     message: ${result?.message}`);
    if (result.code !== 0) {
      ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()?.terminateSelfWithResult({
        resultCode: result.code
      })
    }
  }

  checkFilterOptions(filterOptions: Array<contact.FilterOptions>, flag: string): BusinessError {
    let result: BusinessError = {
      code: 0,
      name: '',
      message: ''
    }
    if (filterOptions.length > 0 && filterOptions.length < 4) {
      for (let filterOption of filterOptions) {
        switch (filterOption.filterCondition) {
          case contact.FilterCondition.EQUAL_TO:
          case contact.FilterCondition.NOT_EQUAL_TO:
          case contact.FilterCondition.CONTAINS:
            if (typeof filterOption.value !== 'string') {
              result.code = 401;
              result.message =
                `The filterClause(${flag}) parameter is incorrect, value type is ${typeof filterOption.value}`;
            }
            break;
          case contact.FilterCondition.IN:
          case contact.FilterCondition.NOT_IN:
            if (typeof filterOption.value !== 'object') {
              result.code = 401;
              result.message =
                `The filterClause(${flag}) parameter is incorrect, value type is ${typeof filterOption.value}`;
            }
            break;
        }
        if (result.code !== 0) {
          break;
        }
      }
    } else {
      result.code = 401;
      result.message =
        `The filterClause(${flag}) parameter is incorrect, filterOptions length is ${filterOptions.length}`;
    }
    return result;
  }

  returnDefaultSelectContactData() {
    HiLog.w(TAG, `returnDefaultSelectContactData. defaultSelectContactMap size: ${this.defaultSelectContactMap.size}`);
    this.selectedContactsMap.clear();
    let ids: Set<number> = new Set();
    this.defaultSelectContactMap.forEach((subDataKeys, contactId) => {
      this.selectedContactsMap.set(contactId, subDataKeys);
      ids.add(contactId);
    })
    this.getPickerDataByIds(ids, (contactIdPickerDataMap: Map<number, contact.Contact>) => {
      this.confirm(contactIdPickerDataMap, false);
    })
  }

  public static unInstance(): void {
    HiLog.i(TAG, 'unInstance...');
    ContactsPickerPresenter.sInstance = null;
  }
}

@Concurrent
async function getPickerContactsByFilter(isDisplayByName: boolean,
  contactSelectionFilter: contact.ContactSelectionFilter, userId: number, page: number, isFavorite: boolean,
  isOnePageShow: boolean, context?: common.UIAbilityContext): Promise<PickerContactList> {
  return await ContactAbilityModel.getPickerContactsSync(isDisplayByName, contactSelectionFilter,
    userId, page, isFavorite, isOnePageShow, context);
}

@Concurrent
async function getPickerContactsNoFilter(isDisplayByName: boolean, userId: number, page: number, isFavorite: boolean,
  isOnePageShow: boolean, context?: common.UIAbilityContext): Promise<PickerContactList> {
  return await ContactAbilityModel.getPickerContactsSync(isDisplayByName, undefined, userId, page,
    isFavorite, isOnePageShow, context);
}