/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
// import SearchClient from '../../../../../../entry/src/main/ets/search/search';
import MergedCallLog from '../../../../../call/src/main/ets/entity/MergedCallLog';
import { CallLogTemp, PhoneNum } from '../../../../../call/src/main/ets/entity/CallLogTemp';
import { HiLog, StringUtil } from '../../../../../../common';
// import { getClause, getIndex } from './DialerTaskVariables';
import { ArrayList, HashSet } from '@kit.ArkTS';
import { SearchUtil } from '../../../../../../entry/src/main/ets/util/SearchUtil';
import { DialerSearchResultType } from '../../../../../../entry/src/main/ets/model/type';
import { BusinessError } from '@kit.BasicServicesKit';
import { ContactRepository } from './ContactRepository';
import { ContactsGlobalThisHelper } from 'common/src/main/ets/util/ContactsGlobalThisHelper';
import { common } from '@kit.AbilityKit';
import { CallLogRepository } from '../../../../../call/src/main/ets/repo/CallLogRepository';

@Concurrent
export async function updateDialerSearchList(value: string, contactsCountNumbers: number, teleCountNumbers: number,
  searchContactNameUnique: string[], searchPhoneNumberUnique: string[], dialerSearchUniqueKey: number,
  myCardContactId: string, context: common.UIAbilityContext) {
  const TAG = 'updateDialerSearchList';
  const SEARCH_RULE_CHANGE_LIMIT = 3;
  const DATA_TYPE_CONTACTS = 1;
  const DATA_TYPE_TELEPHONE = 0;
  const SEARCH_SIZE = 100;

  // 输入号码长度小于3时，只搜索联系人，输入号码长度大于等于3时，搜索联系人+通话记录
  HiLog.w(TAG, `mixsearch Query start: ${dialerSearchUniqueKey},value=${value.length},contactnum=${contactsCountNumbers},tel=${teleCountNumbers}`);
  const regex: RegExp = new RegExp('<\/?.+?>', 'g')
  let indexName: string = 'sysTelephone';
  let contactsOffset: number = contactsCountNumbers;
  let teleOffset: number = teleCountNumbers;
  let size: number = SEARCH_SIZE;
  let outFields: string[] = ['contactName', 'phoneNumber', 'numberLocation'];
  // let index: SearchClient.Index = getIndex(indexName);
  // let clause: SearchClient.SimpleQueryClause = getClause(value)
  // let queryTele: SearchClient.Query = {
  //   index: index,
  //   query: clause,
  //   outFields: outFields,
  //   offset: teleOffset,
  //   size: size
  // }
  let contactSIndexName: string = 'sysContacts';
  let contactsOutFields: string[] = ['name', 'phoneNumbers', 'organization'];
  // let contactsIndex: SearchClient.Index = {
  //   indexId: '',
  //   ownerId: '',
  //   indexName: contactSIndexName,
  //   schemaType: 2,
  //   version: '',
  // }
  // let contactsClause: SearchClient.SimpleQueryClause = {
  //   query: value,
  //   searchFields: value.length < SEARCH_RULE_CHANGE_LIMIT ?
  //     ['name', 'nameNumExt'] : ['phoneNumbers', 'name', 'nameNumExt'],
  //   queryType: 'match'
  // }
  // let filterClause: SearchClient.SimpleFilterClause = {
  //   field: 'isDeleted',
  //   operator: 'ne',
  //   value: 1
  // }

  // let logicalFilterClause: SearchClient.LogicalFilterClause;
  // 长度为1添加过滤条件，联系次数大于0
  // if (value.length === 1) {
  //   // 联系次数大于0条件
  //   let filterClauseContactCount: SearchClient.SimpleFilterClause = {
  //     field: 'contactCount',
  //     operator: 'gt',
  //     value: 0
  //   }
  //   logicalFilterClause = {
  //     logicalOperator: 'and',
  //     clauses: [filterClause, filterClauseContactCount]
  //   }
  // } else {
  //   logicalFilterClause = {
  //     logicalOperator: 'and',
  //     clauses: [filterClause]
  //   }
  // }

  // let queryContacts: SearchClient.Query = {
  //   index: contactsIndex,
  //   query: contactsClause,
  //   filter: logicalFilterClause,
  //   outFields: contactsOutFields,
  //   offset: contactsOffset,
  //   size: size
  // }
  // 保存搜索结果，保证搜索返回结果顺序
  let resultList: CallLogTemp[] = [];
  // 联系人库contactId集合
  let contactIdList: string[] = [];
  // 对于contactId相同，phoneNumber相同情况做去重（联系人库本身去重）
  let contactKeySet: HashSet<string> = new HashSet();
  // 用于对含有姓名的联系人做去重
  let contactNameKeySet: Set<string> = new Set(searchContactNameUnique);
  // 用于去重陌生联系人通话记录结果
  let searchPhoneNumberSet: Set<string> = new Set(searchPhoneNumberUnique);
  let contactsResultOffset: number = 0;
  let contactsOffsetFromDb: number = 0;
  /**
   * 搜索结果展示规则:
   * 1、保留搜索返回结果的排序。
   * 2、搜索结果整体排序规则: 联系人搜索结果 + 通话记录搜索结果上下顺序
   * 1、如果联系人匹配上，通话记录结果则不需要展示。
   * 1.1、 手机号+联系人名称一致,重复的搜索结果联系人需要丢弃; 通话记录的手机号和搜索出来的联系人的手机号一致，丢弃到匹配上的通话记录，保留联系人的搜索结果。
   * **/
  try {
    let resultFromDb =
      await ContactRepository.getInstance()
        .queryContactByPhoneNumAndDisplayNameForDialer(value, contactIdList, context);
    if (resultFromDb && resultFromDb.length) {
      for (let i = 0; i < resultFromDb.length; i++) {
        resultList.push(resultFromDb[i]);
      }
      contactsOffsetFromDb = resultFromDb.length;
    } else {
      HiLog.w(TAG, `searchResultQueryContacts is empty.`);
      contactsOffset = 0;
      // 只在第一页的时候如果查不到就返回,进入数据库的查询
      if (contactsCountNumbers === 0) {
        let searchResultsObject: DialerSearchResultType = {
          resultList: [],
          contactsOffset: 0,
          teleOffset: 0,
          contactsResultOffset: 0,
          contactNameKeySet: Array.from(contactNameKeySet),
          searchPhoneNumberSet: Array.from(searchPhoneNumberSet),
          contactsOffsetFromDb: 0
        }
        return searchResultsObject;
      }
    }
    HiLog.w(TAG,
      `aftermixsearch dialerSearchSize len= ${resultFromDb.length},${contactIdList.length}`);

    HiLog.w(TAG, 'dialerSearchUniqueKey: ' + dialerSearchUniqueKey + ' start to request searchSession');
    // let searchSession: SearchClient.SearchSession = await SearchUtil.getInstance().getSearchSession();
    // let searchResultQueryContacts = await searchSession.search<MergedCallLog>(queryContacts);
    // 查询联系人数据库 姓名匹配，联系人无号码时不会放入搜索结果中
    // if (searchResultQueryContacts.records?.length > 0) {
    //   contactsOffset = searchResultQueryContacts.records?.length;
    //   HiLog.w(TAG, 'dialerSearchUniqueKey: ' + dialerSearchUniqueKey + ' QueryContacts success!! contactsOffset: ' +
    //     contactsOffset);
    //   searchResultQueryContacts.records.forEach((item: MergedCallLog) => {
    //     item.phoneNumbers.forEach((phoneNum: PhoneNum) => {
    //       if (!StringUtil.isEmpty(phoneNum.value) && item.entityId !== myCardContactId &&
    //         (item.name.includes('<em>') || phoneNum.value.includes('<em>'))) {
    //         // 查询联系人库，key中加entityId和phoneNum合并号码相同联系人
    //         let key = `${item.entityId}-${phoneNum.value.replace(regex, '')}`;
    //         if (!contactKeySet.has(key)) {
    //           resultList.push(new CallLogTemp(item.entityId, item.name, phoneNum.value, item.organization, '',
    //             item.markType, item.markContent, item.isCloudMark, item.markCount, DATA_TYPE_CONTACTS));
    //           contactKeySet.add(key);
    //         }
    //         if (!contactIdList.includes(item.entityId)) {
    //           contactIdList.push(item.entityId);
    //         }
    //         // 查询联系人库，对应姓名保存为key，由于在通话记录库中做筛选
    //         let nameKey = `${item.name.replace(regex, '')}`;
    //         contactNameKeySet.add(nameKey);
    //       }
    //     })
    //   });
    //   HiLog.w(TAG,
    //     `aftermixsearch dialerSearchSize len= ${resultList.length},${contactIdList.length}`);
    //   if (searchResultQueryContacts.records && searchResultQueryContacts.records?.length < 100 &&
    //     contactsCountNumbers === 0) {
    //     // 融合搜索第一页少于100条数据，到数据库再去搜索一下，给融合搜索补充上
    //     let filterContactIds = await ContactRepository.getInstance().queryContactByContactIds(contactIdList, context);
    //     resultList = resultList.filter(item => filterContactIds.includes(item.entityId));
    //     let resultFromDb =
    //       await ContactRepository.getInstance()
    //         .queryContactByPhoneNumAndDisplayNameForDialer(value, contactIdList, context);
    //     if (resultFromDb && resultFromDb.length) {
    //       for (let i = 0; i < resultFromDb.length; i++) {
    //         resultList.push(resultFromDb[i]);
    //       }
    //       contactsOffsetFromDb = resultFromDb.length;
    //     }
    //     HiLog.w(TAG,
    //       `aftermixsearch dialerSearchSize len= ${resultFromDb.length},${contactIdList.length},${filterContactIds?.length}`);
    //   }
    // } else {
    //   HiLog.w(TAG, `searchResultQueryContacts is empty.`);
    //   contactsOffset = 0;
    //   // 只在第一页的时候如果查不到就返回,进入数据库的查询
    //   if (contactsCountNumbers === 0) {
    //     let searchResultsObject: DialerSearchResultType = {
    //       resultList: [],
    //       contactsOffset: 0,
    //       teleOffset: 0,
    //       contactsResultOffset: 0,
    //       contactNameKeySet: Array.from(contactNameKeySet),
    //       searchPhoneNumberSet: Array.from(searchPhoneNumberSet),
    //       contactsOffsetFromDb: 0
    //     }
    //     return searchResultsObject;
    //   }
    // }
    HiLog.w(TAG, `dialerSearchUniqueKey: ${dialerSearchUniqueKey
    } QueryContacts resultList length is: ${resultList.length}, contactIdList: ${contactIdList}`);
    contactsResultOffset = resultList.length;
    // 查询通话记录数据库（触发条件：1.搜索长度大于等于3   2.查询联系人库返回结果小于100（不满足分页条件））
    if (value.length >= SEARCH_RULE_CHANGE_LIMIT && contactsOffset < SEARCH_SIZE) {
      let callLogResultList = await CallLogRepository.getInstance()
        .queryCallLogByPhoneNumberForDialer(value, contactNameKeySet, searchPhoneNumberSet, teleOffset, size, context);
      if (callLogResultList && callLogResultList.length > 0) {
        teleOffset = callLogResultList.length;
        HiLog.w(TAG, 'dialerSearchUniqueKey: ' + dialerSearchUniqueKey + ' QueryTele success!! teleOffset: ' +
          teleOffset);
        resultList = resultList.concat(callLogResultList);
      } else {
        // 通话记录无返回结果，返回个数置为0
        teleOffset = 0;
      }
    }
  } catch (error) {
    HiLog.e(TAG, `updateDialerSearchList error, code: ${error?.code}, message: ${error?.message}`);
  }
  HiLog.w(TAG, `dialerSearch end: ${resultList.length}, contactIdList: ${contactIdList.length},${contactsOffset},${contactsResultOffset},${contactsOffsetFromDb}`);
  let searchResultsObject: DialerSearchResultType = {
    resultList: resultList,
    contactsOffset: contactsOffset,
    teleOffset: teleOffset??0,
    contactsResultOffset: contactsResultOffset,
    contactNameKeySet: Array.from(contactNameKeySet),
    searchPhoneNumberSet: Array.from(searchPhoneNumberSet),
    contactsOffsetFromDb: contactsOffsetFromDb
  }
  return searchResultsObject;
}

@Concurrent
export async function updateDialerSearchListForDbAndMixSearch(value: string, contactsCountNumbers: number,
  teleCountNumbers: number, searchContactNameUnique: string[], searchPhoneNumberUnique: string[],
  dialerSearchUniqueKey: number, myCardContactId: string, page: number, context: common.UIAbilityContext) {
  const TAG = 'updateDialerSearchListForDbAndMixSearch';
  const SEARCH_RULE_CHANGE_LIMIT = 3;
  const DATA_TYPE_CONTACTS = 1;
  const DATA_TYPE_TELEPHONE = 0;
  const SEARCH_SIZE = 100;

  // 输入号码长度小于3时，只搜索联系人，输入号码长度大于等于3时，搜索联系人+通话记录
  HiLog.w(TAG, `Dialerdbsearch Query start: ${dialerSearchUniqueKey},value=${value.length},contactnum=${contactsCountNumbers},tel=${teleCountNumbers},page=${page}`);
  const regex: RegExp = new RegExp('<\/?.+?>', 'g')
  let indexName: string = 'sysTelephone';
  let contactsOffset: number = contactsCountNumbers;
  let teleOffset: number = teleCountNumbers;
  let size: number = SEARCH_SIZE;
  let outFields: string[] = ['contactName', 'phoneNumber', 'numberLocation'];
  // let index: SearchClient.Index = getIndex(indexName);
  // let clause: SearchClient.SimpleQueryClause = getClause(value)
  // let queryTele: SearchClient.Query = {
  //   index: index,
  //   query: clause,
  //   outFields: outFields,
  //   offset: teleOffset,
  //   size: size
  // }
  // 保存搜索结果，保证搜索返回结果顺序
  let resultList: ArrayList<CallLogTemp> = new ArrayList();
  // 联系人库contactId集合
  let contactIdList: string[] = [];
  // 对于contactId相同，phoneNumber相同情况做去重（联系人库本身去重）
  let contactKeySet: HashSet<string> = new HashSet();
  // 用于对含有姓名的联系人做去重
  let contactNameKeySet: Set<string> = new Set(searchContactNameUnique);
  // 用于去重陌生联系人通话记录结果
  let searchPhoneNumberSet: Set<string> = new Set(searchPhoneNumberUnique);
  let contactsResultOffset: number = 0;
  /**
   * 搜索结果展示规则:
   * 1、搜索结果整体排序规则: 联系人搜索结果 + 通话记录搜索结果上下顺序
   * 2、如果联系人匹配上，通话记录结果则不需要展示。
   * 2.1、手机号+联系人名称一致,重复的搜索结果联系人需要丢弃; 通话记录的手机号和搜索出来的联系人的手机号一致，丢弃到匹配上的通话记录，保留联系人的搜索结果。
   * **/
  try {
    let searchResultFromDb =
      await ContactRepository.getInstance().queryContactByPhoneNumAndDisplayNameForDialerLimit(value, page, context);

    // 查询联系人数据库 姓名匹配，联系人无号码时不会放入搜索结果中
    if (searchResultFromDb?.length > 0) {
      contactsOffset = searchResultFromDb?.length;
      searchResultFromDb.forEach((item: CallLogTemp) => {
        if (!StringUtil.isEmpty(item.phoneNumber) && item.entityId !== myCardContactId &&
          (item.name.includes('<em>') || item.phoneNumber.includes('<em>'))) {
          // 查询联系人库，key中加entityId和phoneNum合并号码相同联系人
          let key = `${item.entityId}-${item.phoneNumber.replace(regex, '')}`;
          if (!contactKeySet.has(key)) {
            resultList.add(new CallLogTemp(item.entityId, item.name, item.phoneNumber, item.organization, '',
              item.markType, item.markContent, item.isCloudMark, item.markCount, DATA_TYPE_CONTACTS));
            contactKeySet.add(key);
          }
          if (!contactIdList.includes(item.entityId)) {
            contactIdList.push(item.entityId);
          }
          // 查询联系人库，对应姓名保存为key，由于在通话记录库中做筛选
          let nameKey = `${item.name.replace(regex, '')}`;
          contactNameKeySet.add(nameKey);
        }
      })
    } else {
      HiLog.w(TAG, `searchResultQueryContactsFromDb is empty.`);
      contactsOffset = 0;
    }

    HiLog.w(TAG, `dialerSearchDbUniqueKey: ${dialerSearchUniqueKey
    } QueryContacts resultList length is: ${resultList.length}, contactIdList: ${contactIdList.length}`);
    contactsResultOffset = resultList.length;

    // 查询通话记录数据库（触发条件：1.搜索长度大于等于3   2.查询联系人库返回结果小于100（不满足分页条件））
    if (value.length >= SEARCH_RULE_CHANGE_LIMIT && contactsOffset < SEARCH_SIZE) {
      let callLogResultList = await CallLogRepository.getInstance()
        .queryCallLogByPhoneNumberForDialer(value, contactNameKeySet, searchPhoneNumberSet, teleOffset, size, context);
      if (callLogResultList && callLogResultList.length > 0) {
        teleOffset = callLogResultList.length;
        HiLog.w(TAG, 'dialerSearchDbUniqueKey: ' + dialerSearchUniqueKey + ' QueryTele success!! teleOffset: ' +
          teleOffset);
        callLogResultList.forEach((item: CallLogTemp) => {
          resultList.add(item);
        });
      } else {
        // 通话记录无返回结果，返回个数置为0
        teleOffset = 0;
      }
    }
  } catch (error) {
    let err = error as BusinessError;
    HiLog.e(TAG, `dialerSearchDbUniqueKey: ${dialerSearchUniqueKey} updateDialerSearchList error: code: ${err.code
    }, message: ${err.message}`);
  }
  HiLog.w(TAG,
    `dialerDbSearch end: ${resultList.length} contactsOffset,${contactsOffset},${contactsResultOffset},${teleOffset}`);
  let searchResultsObject: DialerSearchResultType = {
    resultList: resultList.convertToArray(),
    contactsOffset: contactsOffset,
    teleOffset: teleOffset,
    contactsResultOffset: contactsResultOffset,
    contactNameKeySet: Array.from(contactNameKeySet),
    searchPhoneNumberSet: Array.from(searchPhoneNumberSet),
    contactsOffsetFromDb: contactsOffset
  }
  return searchResultsObject;
}