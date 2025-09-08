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
/**

 SearchContactResult List Data Structure Entity
 */
 export class SearchContactResult {
 /*
 联系人id
 /
 public entityId: string;
 public entityName: string;
 /*
 联系人名称艾风 艾慕青
 */
public name: string;
public namePinyin: string;
public organization: string;
public position: string;
public phoneNumbers: object[] = [];
public emails: object[] = [];
public note: string;
public familyAddress: string;
public imInfo: object[] = [];
public groupName:Object[] = [];
public nickname: string;
public meeTimeUri: string;
public relationShip:Object[] = [];
public hicall:Object[] = [];
public isDeleted:number;
public iconUrl:String;
public iconData:String;
public sortFirstLetter: string;
public checked: boolean = false;
constructor(
  entityId: string,
entityName: string,
name: string,
namePinyin: string,
organization: string,
position: string,
phoneNumbers: object[] = [],
emails: object[] = [],
note: string,
familyAddress: string,
imInfo: object[] = [],
groupName:Object[] = [],
nickname: string,
meeTimeUri: string,
relationShip:Object[] = [],
hicall:Object[] = [],
isDeleted:number,
iconUrl:String,
iconData:String,
sortFirstLetter: string,
) {
  this.entityId = entityId;
  this.entityName = entityName;
  this.name = name;
  this.namePinyin = namePinyin;
  this.organization = organization;
  this.position = position;
  this.phoneNumbers = phoneNumbers;
  this.emails = emails;
  this.note = note;
  this.familyAddress = familyAddress;
  this.imInfo = imInfo;
  this.groupName = groupName;
  this.nickname = nickname;
  this.meeTimeUri = meeTimeUri;
  this.relationShip = relationShip;
  this.hicall = hicall;
  this.isDeleted = isDeleted;
  this.iconUrl = iconUrl;
  this.iconData = iconData;
  this.sortFirstLetter = sortFirstLetter;
}
}