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

/**
 * Favorite List Data Structure Entity
 */
export class FavoriteBean {
  contactId: string;
  /**
   * 0 Favorite 1 Usually
   */
  isCommonUseType: number;
  /**
   * Contact Name
   */
  displayName: string;
  phoneNum: string;
  nameSuffix: string;
  namePrefix: string;
  portraitColor: string;
  /**
   * Display Usually
   */
  isUsuallyShow: boolean;
  portraitPath: string;
  isEditSelect: boolean
  favorite: number;
  company: string;
  position: string;
  show: boolean;
  showName: string;
  phoneNumbers: object[];
  title: string;
  subTitle: string;
  favoriteOrder: string;

  constructor(
    contactId: string,
    isCommonUseType: number,
    displayName: string,
    phoneNum: string,
    nameSuffix: string,
    namePrefix: string,
    portraitColor: string,
    isUsuallyShow: boolean,
    portraitPath: string,
    isEditSelect: boolean,
    favorite: number,
    favoriteOrder: string,
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
    this.isEditSelect = isEditSelect;
    this.favorite = favorite;
    this.favoriteOrder = favoriteOrder;
  }

  public setShowName() {
    this.showName = !StringUtil.isEmpty(this.displayName) ? this.displayName : (!StringUtil.isEmpty(this.company) ? this.company : (!StringUtil.isEmpty(this.position) ? this.position : ""))
  }
}
