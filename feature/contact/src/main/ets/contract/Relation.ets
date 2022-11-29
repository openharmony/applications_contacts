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

import DataType from './DataType';
import {DataItemType} from './DataType';

/**
 * Phone Data Type - Relator
 */
export class Relation extends DataType {
  static readonly CONTENT_ITEM_TYPE: string = "relation";
  static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.RELATION;
  static readonly NAME: string = DataType.DATA;
  static readonly TYPE_ASSISTANT: number = 1;
  static readonly TYPE_BROTHER: number = 2;
  static readonly TYPE_CHILD: number = 3;
  static readonly TYPE_PARTNER: number = 4;
  static readonly TYPE_FATHER: number= 5;
  static readonly TYPE_FRIEND: number = 6;
  static readonly TYPE_MANAGER: number = 7;
  static readonly TYPE_MOTHER: number = 8
  static readonly TYPE_PARENTS: number = 9;
  static readonly TYPE_DOMESTIC_PARTNER: number = 10;
  static readonly TYPE_REFERRED_BY: number = 11;
  static readonly TYPE_RELATIVE: number = 12;
  static readonly TYPE_SISTERS: number = 13;
  static readonly TYPE_SPOUSES: number = 14;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Relation.TYPE_CHILD:
        return $r("app.string.relationship_type_children");
      case Relation.TYPE_DOMESTIC_PARTNER:
        return $r("app.string.relationship_type_partner");
      case Relation.TYPE_ASSISTANT:
        return $r("app.string.relationship_type_assistant");
      case Relation.TYPE_BROTHER:
        return $r("app.string.relationship_type_brother");
      case Relation.TYPE_PARTNER:
        return $r("app.string.relationship_type_mates");
      case Relation.TYPE_FATHER:
        return $r("app.string.relationship_type_father");
      case Relation.TYPE_FRIEND:
        return $r("app.string.relationship_type_friend");
      case Relation.TYPE_MANAGER:
        return $r("app.string.relationship_type_bosses");
      case Relation.TYPE_MOTHER:
        return $r("app.string.relationship_type_mother");
      case Relation.TYPE_PARENTS:
        return $r("app.string.relationship_type_parents");
      case Relation.TYPE_REFERRED_BY:
        return $r("app.string.relationship_type_introducer");
      case Relation.TYPE_RELATIVE:
        return $r("app.string.relationship_type_kinship");
      case Relation.TYPE_SISTERS:
        return $r("app.string.relationship_type_sisters");
      case Relation.TYPE_SPOUSES:
        return $r("app.string.relationship_type_spouses");
      case Relation.TYPE_CUSTOM:
        return $r("app.string.relationship_type_custom");
      default:
        return $r("app.string.relationship_type_custom");
    }
  }

  constructor() {
    super();
  }
}