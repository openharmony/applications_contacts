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
import LooseObject from '../../../../../../entry/src/main/ets/model/type/LooseObject';
import { HiLog } from 'common';
import { SearchUtil } from '../../../../../../entry/src/main/ets/util/SearchUtil';
import { SearchContactResult } from '../entity/SearchContactResult';
import { ContactRepository } from './ContactRepository';
import { common } from '@kit.AbilityKit';
import { ContactsSearchResult } from '../../../../../../entry/src/main/ets/model/type';

// @Concurrent
// export async function updateSearchContactList(searchKeyWord: string, countNumbers: number,
//   contactSearchUniqueKey: number, context: common.UIAbilityContext) {
//   const TAG = 'updateSearchContactList';
//
//   HiLog.w(TAG, `Contactsearch Query start: ${searchKeyWord.length},contactnum=${countNumbers},contactSearchUniqueKey=${contactSearchUniqueKey}`);
//   let indexName:string = 'sysContacts';
//   let offset:number = countNumbers;
//   // 查询100条
//   let size:number = 100;
//   let outFields:string[] = ['entityId', 'name', 'organization', 'phoneNumbers','position',
//     'emails','imInfo','familyAddress','note','nickname'];
//   let index:SearchClient.Index = {
//     indexId: '',
//     ownerId: '',
//     indexName: indexName,
//     schemaType: 2,
//     version: '',
//   }
//   当前未确认搜索结果群组展示方式，且融合搜未进行群组高亮标签处理，先删除群组相关字段 'groupName'，避免用户产生误会
//   let clause:SearchClient.SimpleQueryClause = {
//     query:searchKeyWord,
//     searchFields: ['name', 'namePinyin', 'phoneNumbers', 'organization', 'position',
//       'emails', 'note', 'familyAddress', 'imInfo', 'nickname'],
//     queryType:'match'
//   }
//   let filterClause:SearchClient.SimpleFilterClause = {
//     field: 'isDeleted',
//     operator: 'eq',
//     value: 0
//   }
//   let query:SearchClient.Query = {
//     index:index,
//     query:clause,
//     filter:filterClause,
//     outFields:outFields,
//     offset:offset,
//     size:size
//   }
//   let resultFromSearch: SearchContactResult[] = [];
//   let searchSession: SearchClient.SearchSession = await SearchUtil.getInstance().getSearchSession();
//   let searchResult: LooseObject = await searchSession.search(query);
//   resultFromSearch = searchResult['records'] as SearchContactResult[];
//   if (!searchResult || !resultFromSearch) {
//     HiLog.e(TAG, `ContactSearch result empty.`);
//     let result: ContactsSearchResult = {
//       resultList: [],
//       contactsOffsetFromMixSearch: 0,
//       contactsOffsetFromDb: 0
//     }
//     return result;
//   }
//   let mixSearchLen = resultFromSearch?.length;
//   let resultFromDb: SearchContactResult[] = [];
//   HiLog.w(TAG,
//     `mixsearch resultlen= ${resultFromSearch?.length}`);
//   if (resultFromSearch && resultFromSearch.length < 100 && countNumbers === 0) {
//     let contactIds: string[] =resultFromSearch.map(item => item.entityId);
//     ContactRepository.getInstance().init(context);
//     let filterContactIds = await ContactRepository.getInstance().queryContactByContactIds(contactIds, context);
//     resultFromSearch = resultFromSearch.filter(item => filterContactIds.includes(item.entityId));
//     resultFromDb =
//       await ContactRepository.getInstance().queryContactByPhoneNumAndDisplayName(searchKeyWord, contactIds, context);
//     if (resultFromDb && resultFromDb.length) {
//       resultFromSearch = resultFromSearch.concat(...resultFromDb);
//     }
//     HiLog.w(TAG,
//       `aftermixsearch ContactSearchSize db len= ${resultFromDb.length},${contactIds.length},${filterContactIds?.length}`);
//   }
//   HiLog.w(TAG, `ContactSearch end: ${resultFromSearch.length}, mixSearchLen: ${mixSearchLen}`);
//   let result: ContactsSearchResult = {
//     resultList: resultFromSearch,
//     contactsOffsetFromMixSearch: mixSearchLen,
//     contactsOffsetFromDb: resultFromDb?.length
//   }
//   return result;
// }

// @Concurrent
// export async function updateSearchPickerList(searchKeyWord: string, countNumbers: number) {
//   const TAG = 'updateSearchPickerList';
//
//   HiLog.w(TAG, 'Query start, searchKeyWord length is ' + searchKeyWord.length);
//   let indexName: string = 'sysContacts';
//   let offset: number = countNumbers;
//   // 查询100条
//   let size: number = 100;
//   let outFields: string[] = ['entityId', 'name', 'phoneNumbers'];
//   let index: SearchClient.Index = {
//     indexId: '',
//     ownerId: '',
//     indexName: indexName,
//     schemaType: 2,
//     version: '',
//   }
//   let clause: SearchClient.SimpleQueryClause = {
//     query: searchKeyWord,
//     searchFields: ['name', 'namePinyin', 'phoneNumbers'],
//     queryType: 'match'
//   }
//   let filterClause: SearchClient.SimpleFilterClause = {
//     field: 'isDeleted',
//     operator: 'eq',
//     value: 0
//   }
//   let query: SearchClient.Query = {
//     index: index,
//     query: clause,
//     filter: filterClause,
//     outFields: outFields,
//     offset: offset,
//     size: size
//   }
//   let searchSession: SearchClient.SearchSession = await SearchUtil.getInstance().getSearchSession();
//   let searchResult: LooseObject = await searchSession.search(query);
//
//   if (searchResult['records']) {
//     HiLog.w(TAG, 'QueryContacts success!! searchResultLength: ' + searchResult['records'].length);
//     for (let i = 0; i < searchResult['records'].length; i++) {
//       let newArr: Object[] = []
//       if (searchResult['records'][i].phoneNumbers) {
//         searchResult['records'][i].phoneNumbers.forEach((item: Object) => {
//           if (!JSON.stringify(newArr).includes(JSON.stringify(item))) {
//             newArr.push(item)
//           }
//         })
//       }
//       searchResult['records'][i].phoneNumbers = newArr
//     }
//   }
//
//   return searchResult['records'] || [];
// }

@Concurrent
export async function updateSearchPickerListFromDb(searchKeyWord: string, countNumbers: number,
  context: common.UIAbilityContext) {
  const TAG = 'updateSearchPickerListFromDb';

  HiLog.w(TAG, `Contactsearch Query start from DB: ${searchKeyWord.length}, contactnum=${countNumbers}`);

  if (!searchKeyWord || searchKeyWord.trim().length === 0) {
    HiLog.i(TAG, 'Search keyword is empty, return empty result');
    return [];
  }

  try {
    ContactRepository.getInstance().init(context);

    let resultFromDb: SearchContactResult[] = [];

    resultFromDb = await ContactRepository.getInstance().queryContactByPhoneNumAndDisplayName(
      searchKeyWord,
      [],
      context
    );

    if (resultFromDb && resultFromDb.length > 0) {
      const startIndex = countNumbers;
      const endIndex = Math.min(startIndex + 100, resultFromDb.length); // 每次最多返回100条

      if (startIndex >= resultFromDb.length) {
        HiLog.i(TAG, 'No more data, reached end of results');
        return [];
      }

      const pagedResults = resultFromDb.slice(startIndex, endIndex);

      if (pagedResults && pagedResults.length > 0) {
        for (let i = 0; i < pagedResults.length; i++) {
          let newArr: Object[] = [];
          if (pagedResults[i].phoneNumbers) {
            pagedResults[i].phoneNumbers.forEach((item: Object) => {
              if (!JSON.stringify(newArr).includes(JSON.stringify(item))) {
                newArr.push(item);
              }
            });
          }
          pagedResults[i].phoneNumbers = newArr;
        }
      }

      HiLog.w(TAG, `Query from DB success!! searchResultLength: ${pagedResults.length}, total: ${resultFromDb.length}`);
      return pagedResults || [];
    }

    HiLog.w(TAG, 'No results found from database');
    return [];

  } catch (error) {
    HiLog.e(TAG, `Database query failed: ${error?.message}`);
    return [];
  }
}

