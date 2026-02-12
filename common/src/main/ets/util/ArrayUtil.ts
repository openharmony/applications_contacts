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
let FIFTY: number = 50;
let FORTY_NINE: number = 49;
let ONE: number = 1;
let TWO: number = 2;
let THREE: number = 3;
let MAX_OFFSET: number = 2500;
export class ArrayUtil {
  public static getCurrentPage(index: number): number {
    if (index < FIFTY) {
      return 1;
    }
    let temp = index - FORTY_NINE;
    let x = parseInt(`${temp / MAX_OFFSET}`);
    let result = x + ONE;
    let y = temp % MAX_OFFSET;
    if (y > 0) {
      result++;
    }
    return result;
  }

  public static getOffsetForSession(page: number): number {
    let offset: number = 0;
    if (page < THREE) {
      offset = (page - ONE) * FIFTY;
    } else {
      offset = (page - TWO) * MAX_OFFSET + FIFTY; // The length of the number array received by the backend interface is 2550
    }
    return offset;
  }

  public static getOffetByPageAndLimit(page: number, limit: number): number {
    let offset = (page - 1) * limit;
    return offset;
  }
  /**
   * 第一页查50条，之后每页查询2500条
   * @param page
   * @returns
   */
  public static getLimitForSession(page: number): number {
    let limit: number = 0;
    if (page === ONE) {
      limit = FIFTY;
    } else {
      limit = MAX_OFFSET; // The length of the number array received by the backend interface is 2550
    }
    return limit;
  }

  /**
   * 返回查询第page页时，先前已查询过的总数
   * @param page
   * @returns queriedCount
   */
  public static getQueriedCount(page: number) : number {
    if (page <= ONE) {
      return 0;
    } else {
      return FIFTY + (page - 1) * MAX_OFFSET;
    }
  }
  public static isEmpty<T>(list: Array<T>): boolean {
    return list === undefined || list === null || list.length === 0;
  }

  public static cutArray(array: string[], subLength: number): Array<string[]> {
    let index: number = 0;
    let newArr: Array<string[]> = [];
    while (index < array.length) {
      newArr.push(array.slice(index, index += subLength));
    }
    return newArr;
  }
}