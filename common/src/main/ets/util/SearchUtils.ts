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

const TAG = 'Contacts SearchUtils ';

/**
 * SearchUtils utils 工具类
 *
 * @since 2025-08-23
 */
export default class SearchUtils {

  /**
   * 搜索排序的最大值
   */
  public static readonly SEARCH_SORT_MAX_VALUE: number = 128190;

  /**
   * 搜索排序的盐值
   */
  public static readonly SEARCH_SORT_SALTED: number = 10000;

  /**
   * 搜索电话号码全匹配排序的盐值
   */
  public static readonly SEARCH_TELE_SORT_SALTED: number = 1000;

  /**
   * 号码前缀
   */
  public static readonly PHONE_PREFIX = '+86';

  /**
   * 将字符串按照指定字节长度截断
   *
   * @param value 字符串
   * @param length 字节长度
   * @returns 前length个字节长度的字符
   */
  static getHighlightName(name: string, searchKey: string): string {
    let upperCaseName = name.toUpperCase();
    let upperCaseSearchKey = searchKey.toUpperCase();
    let index = upperCaseName.indexOf(upperCaseSearchKey);
    if (index === -1) {
      return name;
    }
    let pre = name.slice(0, index);
    let highLight = name.slice(index, index + searchKey.length);

    let suffix = name.slice(index + searchKey.length);
    return pre + '<em>' + highLight + '</em>' + suffix;
  }

  /**
   * 通过联系人名称计算联系人的排序值
   *
   * @param name 联系人名称
   * @param contactedCount 联系频次
   * @param searchKey 搜索内容
   * @returns  排序值
   */
  static calcContactNameSortValue(name: string, contactedCount: number, searchKey: string): number {
    let nameIndex: number = name.indexOf(searchKey);
    // seachkey在联系人名称中的索引超过5就是5了
    nameIndex = (nameIndex > 5) ? 5 : nameIndex;
    let matchValue = 5 - nameIndex;
    if (name === searchKey) {
      // 全匹配计算公式 全匹配匹配度是6
      return SearchUtils.SEARCH_SORT_MAX_VALUE - (2 * 6 + contactedCount) - SearchUtils.SEARCH_SORT_SALTED;
    }
    // 部分匹配计算公式
    return SearchUtils.SEARCH_SORT_MAX_VALUE - (2 * matchValue + contactedCount) + name.length;
  }

  /**
   * 通过电话号码计算联系人的排序值
   *
   * @param phoneNumber 电话号码
   * @param contactedCount 联系频次
   * @param searchKey 搜索内容
   * @returns  排序值
   */
  static calcPhoneNumberSortValue(phoneNumber: string, contactedCount: number, searchKey: string): number {
    let nameIndex: number = phoneNumber.indexOf(searchKey);
    nameIndex = (nameIndex > 5) ? 5 : nameIndex;
    let matchValue = 5 - nameIndex;
    if (phoneNumber === searchKey) {
      // 全匹配计算公式 全匹配匹配度是6
      return SearchUtils.SEARCH_SORT_MAX_VALUE - (2 * 6 + contactedCount) + SearchUtils.SEARCH_TELE_SORT_SALTED;
    }
    // 部分匹配计算公式
    return SearchUtils.SEARCH_SORT_MAX_VALUE - (2 * matchValue + contactedCount) + SearchUtils.SEARCH_SORT_SALTED +
    phoneNumber.length;
  }
}