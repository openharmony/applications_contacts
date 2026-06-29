/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import DataType, { DataItemType } from './DataType';
import { contact } from '@kit.ContactsKit';
import PhoneAccountType from '../../../../../../feature/account/src/main/ets/type/PhoneAccountType';

/**
 * Phone Data Type - Relator
 */
export class Relation extends DataType {
  public static readonly CONTENT_ITEM_TYPE: string = 'relation';
  public static readonly CONTENT_ITEM_TYPE_ID: number = DataItemType.RELATION;
  public static readonly NAME: string = DataType.DATA;
  public static readonly TYPE_ASSISTANT: number = 1;
  public static readonly TYPE_BROTHER: number = 2;
  public static readonly TYPE_CHILD: number = 3;
  public static readonly TYPE_PARTNER: number = 4;
  public static readonly TYPE_FATHER: number = 5;
  public static readonly TYPE_FRIEND: number = 6;
  public static readonly TYPE_MANAGER: number = 7;
  public static readonly TYPE_MOTHER: number = 8
  public static readonly TYPE_PARENTS: number = 9;
  public static readonly TYPE_DOMESTIC_PARTNER: number = 10;
  public static readonly TYPE_REFERRED_BY: number = 11;
  public static readonly TYPE_RELATIVE: number = 12;
  public static readonly TYPE_SISTERS: number = 13;
  public static readonly TYPE_SPOUSES: number = 14;

  static getTypeLabelResource(type: number) {
    switch (type) {
      case Relation.TYPE_CHILD:
        return $r('app.string.relationship_type_children');
      case Relation.TYPE_DOMESTIC_PARTNER:
        return $r('app.string.relationship_type_partner');
      case Relation.TYPE_ASSISTANT:
        return $r('app.string.relationship_type_assistant');
      case Relation.TYPE_BROTHER:
        return $r('app.string.relationship_type_brother');
      case Relation.TYPE_PARTNER:
        return $r('app.string.relationship_type_mates');
      case Relation.TYPE_FATHER:
        return $r('app.string.relationship_type_father');
      case Relation.TYPE_FRIEND:
        return $r('app.string.relationship_type_friend');
      case Relation.TYPE_MANAGER:
        return $r('app.string.relationship_type_bosses');
      case Relation.TYPE_MOTHER:
        return $r('app.string.relationship_type_mother');
      case Relation.TYPE_PARENTS:
        return $r('app.string.relationship_type_parents');
      case Relation.TYPE_REFERRED_BY:
        return $r('app.string.relationship_type_introducer');
      case Relation.TYPE_RELATIVE:
        return $r('app.string.relationship_type_kinship');
      case Relation.TYPE_SISTERS:
        return $r('app.string.relationship_type_sisters');
      case Relation.TYPE_SPOUSES:
        return $r('app.string.relationship_type_spouses');
      case Relation.TYPE_CUSTOM:
        return $r('app.string.relationship_type_custom');
      default:
        return $r('app.string.relationship_type_custom');
    }
  }

  static apiTypeToSystemType(type: number): number {
    switch (type) {
      case contact.Relation.CUSTOM_LABEL:
        return PhoneAccountType.TYPE_ID_CUSTOM;
      case contact.Relation.RELATION_ASSISTANT:
        return Relation.TYPE_ASSISTANT;
      case contact.Relation.RELATION_BROTHER:
        return Relation.TYPE_BROTHER;
      case contact.Relation.RELATION_CHILD:
        return Relation.TYPE_CHILD;
      case contact.Relation.RELATION_DOMESTIC_PARTNER:
        return Relation.TYPE_DOMESTIC_PARTNER;
      case contact.Relation.RELATION_FATHER:
        return Relation.TYPE_FATHER;
      case contact.Relation.RELATION_FRIEND:
        return Relation.TYPE_FRIEND;
      case contact.Relation.RELATION_MANAGER:
        return Relation.TYPE_MANAGER;
      case contact.Relation.RELATION_MOTHER:
        return Relation.TYPE_MOTHER;
      case contact.Relation.RELATION_PARENT:
        return Relation.TYPE_PARENTS;
      case contact.Relation.RELATION_PARTNER:
        return Relation.TYPE_PARTNER;
      case contact.Relation.RELATION_REFERRED_BY:
        return Relation.TYPE_REFERRED_BY;
      case contact.Relation.RELATION_RELATIVE:
        return Relation.TYPE_RELATIVE;
      case contact.Relation.RELATION_SISTER:
        return Relation.TYPE_SISTERS;
      case contact.Relation.RELATION_SPOUSE:
        return Relation.TYPE_SPOUSES;
      default:
        return Relation.TYPE_ASSISTANT;
    }
  }

  constructor() {
    super();
  }
}