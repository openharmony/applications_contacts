/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { getHeadChar } from '../../util/UserPhoto';

/**
 * Favorite List Data Structure Entity
 */
export class FavoriteBean {
  public contactId: string;
  /**
   * 0 Favorite 1 Usually
   */
  public isCommonUseType: number;
  /**
   * Contact Name
   */
  public displayName: string | Resource;
  public phoneNum: string;
  public nameSuffix: string;
  public namePrefix: string;
  public portraitColor: Resource;
  /**
   * Display Usually
   */
  public isUsuallyShow: boolean;
  public portraitPath: string;
  // public isEditSelect: boolean
  public favorite: number;
  public company: string = '';
  public position: string = '';
  public show: boolean = false;
  public showName: string = '';
  public phoneNumbers: object[] = [];
  public title: string = '';
  public subTitle: string = '';
  public favoriteOrder: string;
  public headChar: string = '';
  phones: string[] = [];
  id: number = -1;

  constructor(
    contactId: string,
    isCommonUseType: number,
    displayName: string,
    phoneNum: string,
    nameSuffix: string,
    namePrefix: string,
    portraitColor: Resource,
    isUsuallyShow: boolean,
    portraitPath: string,
    isEditSelect: boolean,
    favorite: number,
    favoriteOrder: string,
    phones: string[] = [],
    id: number = -1
  ) {
    this.contactId = contactId;
    this.isCommonUseType = isCommonUseType;
    this.displayName = displayName;
    this.phoneNum = phoneNum;
    this.nameSuffix = nameSuffix;
    this.namePrefix = namePrefix;
    this.portraitColor = portraitColor;
    this.isUsuallyShow = isUsuallyShow;
    this.portraitPath = portraitPath;
    this.favorite = favorite;
    this.favoriteOrder = favoriteOrder;
    this.phones = phones;
    this.id = id;
  }

  public setShowName() {
    this.showName = !StringUtil.isEmpty(this.displayName as string) ? this.displayName as string : (!StringUtil.isEmpty(this.company) ? this.company : (!StringUtil.isEmpty(this.position) ? this.position : ''))
  }

  public setHeadChar() {
    this.headChar = getHeadChar(this.showName);
  }
}
