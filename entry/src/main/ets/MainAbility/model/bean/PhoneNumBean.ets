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

/**
 * 电话号码对象
 */
export class PhoneNumBean{
  id:string
  num: string
  numType: string  // 号码类型：手机，住宅
  homeArea: string  // 归属地
  carriers: string  // 运营商
  constructor(id:string, num: string, numType: string,homeArea: string, carriers: string){
    this.id = id;
    this.num = num;
    this.numType = numType;
    this.homeArea = homeArea;
    this.carriers = carriers;
  }
}