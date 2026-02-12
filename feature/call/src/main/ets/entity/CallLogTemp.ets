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

export class PhoneNum {
  public id:string;
  public label:string;
  public value:string;
  constructor(id: string, label: string, value: string) {
    this.id = id;
    this.label = label;
    this.value = value;
  }
}

export class CallLogTemp {
  public entityId: string;
  public name: string;
  public phoneNumber: string;
  public organization: string;
  public numberLocation: string;
  public markType: string;
  public markContent: string;
  public isCloudMark: number;
  public markCount: number;
  public sortValue: number = 0;
  // 用于区分融合搜数据来源 1——融合搜联系人库，0——融合搜通话记录库
  public dataType?: number;
  constructor(
    entityId: string, name: string, phoneNumber: string, organization: string, numberLocation: string,
  markType: string, markContent: string, isCloudMark: number, markCount: number, dataType?: number) {
    this.entityId = entityId;
    this.name = name;
    this.phoneNumber = phoneNumber;
    this.organization = organization;
    this.numberLocation = numberLocation;
    this.markType = markType;
    this.markContent = markContent;
    this.isCloudMark = isCloudMark;
    this.markCount = markCount;
    this.dataType = dataType;
  }
}