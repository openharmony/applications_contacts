/**
 Copyright (c) 2023 Huawei Device Co., Ltd.
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
import { paramsInterface } from '.';
import MergedCallLog from '../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import SearchContactListItem from '../../../../../../feature/contact/src/main/ets/repo/SearchContactListItem';
import { AlphabetIndexObj, ContactVo } from '../../../ets/model/bean/ContactVo';
import MorandiColor from '../bean/MorandiColor';
import { SearchContactsBean } from '../bean/SearchContactsBean';
export class AllContactGetParam {
  /*
  query contact list
  page is offset page
  */
  public page: number;
  public limit: number;
  public rawContactIds?: string[];
  constructor(page: number, limit: number) {
    this.page = page;
    this.limit = limit;
  }
}

export class AllContactWithPhoneNumbersGetParam {
  /*
  query all contact info with phone number
  this is kind of filter
  */
  public favorite: number;
  public editContact: number;
  public accountId: number = -1;
  public pageTag: string = '';
  public groupId: number = -1;
  constructor(favorite: number, editContact: number, accountId?: number, pageTag?: string, groupId?: number) {
    this.favorite = favorite;
    this.editContact = editContact;
    if (accountId) {
      this.accountId = accountId;
    }
    if (pageTag) {
      this.pageTag = pageTag;
    }
    if (groupId) {
      this.groupId = groupId;
    }
  }
}

export class ContactResultSetQueryParams {
  public resultList: ContactVo[];
  public alphabetIndex: Record<string, AlphabetIndexObj>;

  constructor(resultList: ContactVo[], alphabetIndex: Record<string, AlphabetIndexObj>) {
    this.resultList = resultList;
    this.alphabetIndex = alphabetIndex;
  }
}

export class NameFixInfo {
  /*
  example: name is wangdabao
  namePrefix is wang
  nameSuffix is bao
  */
  // SORT_FIRST_LETTER
  public namePrefix: string;
  // PHOTO_FIRST_NAME
  public nameSuffix: string;
  public displayName: string;
  constructor(prefix: string, suffix: string, displayName: string = '') {
    this.namePrefix = prefix;
    this.nameSuffix = suffix;
    this.displayName = displayName;
  }
}

export class CountAlphabetIndex {
  public count: number;
  public alphabetIndex: Record<string, AlphabetIndexObj>;

  constructor(count: number, alphabetIndex: Record<string, AlphabetIndexObj>) {
    this.count = count;
    this.alphabetIndex = alphabetIndex;
  }
}

export class CountRawContact {
  public count: number;

  constructor(count: number) {
    this.count = count;
  }
}

export class ContactSearchResultData {
  public total: number = 0;
  public data: Array<SearchContactListItem | SearchContactsBean> = [];
  public keyWord: string = '';

  constructor(total: number, data: SearchContactListItem[], keyWord: string) {
    this.total = total;
    this.data = data;
    this.keyWord = keyWord;
  }
}

export interface IContactSearchParams {
  value: string;
  loopRequest: boolean;
  startIndex: number;
  limitNumber: number;
}

export interface ContactInfoGetParamsInCallback {
  contactList: Array;
  alphabetIndex: Record<string, AlphabetIndexObj>;
}

export interface CallInfoGetParamsInCallback {
  callLogList: Array;
  missedList: Array;
  callLogSearchList: Array;
  timeStamp: string;
  isEnd?: boolean;
}

export type IT9PhoneNumbersFavoriteGroup = 'teleNumber';

export type IT9PhoneNumbersFavoriteType = Record<IT9PhoneNumbersFavoriteGroup, string>;

export interface IT9PhoneNumbersQueryParams {
  favorite: IT9PhoneNumbersFavoriteType;
}

export interface IContactListAndAlphabetIndex {
  contactList: ContactVo[];
  alphabetIndex: Record<string, AlphabetIndexObj>;
}

export interface PickerContactList {
  contactList: ContactPickerListItem[];
  defaultSelectContactMap: Map<number, Set>;
  isEnd: boolean;
}

export interface PickerShowSubData {
  dataId: number,
  keyValue: string,
  showValue: ResourceStr
}

export interface contact {
  photoFirstName: string,
  portraitPath: string,
  displayName: string,
  detailInfo: string,
  contactId: ContactVo,
  hasPhoneNumber: string,
  portraitColor: Resource,
}

export interface ContactPickerListItem {
  contactId: number,
  displayName: string,
  pickerShowSubData: PickerShowSubData,
  isFavorite: boolean,
  headChar: string,
  nameSuffix: string,
  namePrefix: string,
  showIndex?: boolean,
  showDivifer?: boolean,
  favoriteOrder: number,
  isFirst: boolean,
  highLight?: number[],
  contact: ContactVo,
  index: number
}

export interface ContactPickerParam {
  isSaveExistContact: boolean,
  isDisplayByName: boolean,
  phoneNumberShow: string,
}

export class ContactFormModel {
  public contactId?: number = -1;
  public displayName: string | Resource = ''; // 没名字，默认为电话号码
  public photoFirstName: string = '';
  public company: string = '';
  public position: string = '';
  public portraitColor: string = MorandiColor.Color[0];
  public detailsBgColor: string = MorandiColor.detailColor[0];
  public favorite: number = 0;
  public phones: ContackPhoneSubInfoModel[] = [];
  public emails: BaseContackSubInfoModel[] = [];
  public houses: BaseContackSubInfoModel[] = [];
  public nickname: BaseContackSubInfoModel[] = [];
  public events: BaseContackSubInfoModel[] = [];
  public relationships: BaseContackSubInfoModel[] = [];
  public remarks: BaseContackSubInfoModel[] = [];
  public websites: BaseContackSubInfoModel[] = [];
  public aims: BaseContackSubInfoModel[] = [];
  public numRecords: BaseContackSubInfoModel[] = [];
  public phoneticName: BaseContackSubInfoModel[] = [];
  public personalRingtone: string = '';
  public personalRingtonePath: string = '';
  public personalNotificationRingtone: string = '';
}

export class BaseContackSubInfoModel {
  public id?: string = '';
  public data: string = '';
  public type?: string = '';
  public labelName?: Resource | string = '';
  public dataType?: number = -1;
  public calendarEventId?: string = '';
  public contactDataId?: number = -1;
}

export class ContackPhoneSubInfoModel extends BaseContackSubInfoModel {
  public num?: string;
  public phoneAddress?: string | Resource;
  public primary?: boolean;
  public dataId?: number;
  public formatNum?: string;
}

export class FavoriteFormType {
  public favorite: number = -1;
}

export class TargetPageClass {
  public url: string;
  public pageIndex: number;
  public params: paramsInterface;

  constructor(urlName: string, pageIndex: number, params: paramsInterface) {
    this.url = urlName;
    this.pageIndex = pageIndex;
    this.params = params;
  }
}

export class SendMessageParams {
  public contactName: string;
  public telephone: string;
  public telephoneFormat: string;
  public contactId?: number;

  constructor(number: string, formatNum: string, name?: string, id?: number) {
    this.telephone = number;
    this.telephoneFormat = formatNum;
    this.contactName = name as string;
    this.contactId = id;
  }
}