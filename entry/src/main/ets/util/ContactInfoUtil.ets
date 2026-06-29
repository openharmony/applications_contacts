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
import { AIMBean } from '../model/bean/AIMBean';
import { AssociatedPersonBean } from '../model/bean/AssociatedPersonBean';
import { EmailBean } from '../model/bean/EmailBean';
import { EventBean } from '../model/bean/EventBean';
import { GroupBean } from '../model/bean/GroupBean';
import { HouseBean } from '../model/bean/HouseBean';
import { PhoneNumBean } from '../model/bean/PhoneNumBean';

export class ContactInfoUtil {
  // 是否为同一个手机号对象
  public static isPhoneNumEquals(original: PhoneNumBean, other: PhoneNumBean): boolean {
    if (original == undefined && other == undefined) {
      return true;
    }
    if (original == undefined || other == undefined) {
      return false;
    }
    return original.selectTextCustom == other.selectTextCustom &&
      original.num == other.num &&
      original.numType == other.numType &&
      original.primary == other.primary;
  }

  public static isEmailEquals(original: EmailBean, other: EmailBean): boolean {
    if (original == undefined && other == undefined) {
      return true;
    }
    if (original == undefined || other == undefined) {
      return false;
    }
    return original.selectTextCustom == other.selectTextCustom &&
      original.address == other.address &&
      original.emailType == other.emailType;
  }

  public static isAimEquals(original: AIMBean, other: AIMBean): boolean {
    if (original == undefined && other == undefined) {
      return true;
    }
    if (original == undefined || other == undefined) {
      return false;
    }
    return original.selectTextCustom == other.selectTextCustom &&
      original.aimName == other.aimName &&
      original.aimType == other.aimType;
  }

  public static isHouseEquals(original: HouseBean, other: HouseBean): boolean {
    if (original == undefined && other == undefined) {
      return true;
    }
    if (original == undefined || other == undefined) {
      return false;
    }
    return original.selectTextCustom == other.selectTextCustom &&
      original.houseType == other.houseType &&
      original.houseName == other.houseName;
  }

  public static isRelationshipEquals(original: AssociatedPersonBean, other: AssociatedPersonBean): boolean {
    if (original == undefined && other == undefined) {
      return true;
    }
    if (original == undefined || other == undefined) {
      return false;
    }
    return original.selectTextCustom == other.selectTextCustom &&
      original.associatedPersonId == other.associatedPersonId &&
      original.name == other.name &&
      original.associatedType == other.associatedType;
  }

  public static isEventEquals(original: EventBean, other: EventBean): boolean {
    if (original == undefined && other == undefined) {
      return true;
    }
    if (original == undefined || other == undefined) {
      return false;
    }
    return original.data == other.data &&
      original.eventType == other.eventType &&
      original.eventName == other.eventName &&
      original.labelName == other.labelName;
  }

  public static isGroupEquals(original: GroupBean, other: GroupBean): boolean {
    if (original == undefined && other == undefined) {
      return true;
    }
    if (original == undefined || other == undefined) {
      return false;
    }
    return original.groupName == other.groupName &&
      original.groupNotes == other.groupNotes &&
      original.isDeleted == other.isDeleted &&
      original.groupType == other.groupType;
  }

  public static filterRemovePhones(original: PhoneNumBean[], needRemove: PhoneNumBean[]): PhoneNumBean[] {
    return original.filter(item => {
      let isContain = true;
      for (let remove of needRemove) {
        if (ContactInfoUtil.isPhoneNumEquals(remove, item)) {
          isContain = false;
          break;
        }
      }
      return isContain;
    });
  }

  public static filterRemoveEmails(original: EmailBean[], needRemove: EmailBean[]): EmailBean[] {
    return original.filter(item => {
      let isContain = true;
      for (let remove of needRemove) {
        if (ContactInfoUtil.isEmailEquals(remove, item)) {
          isContain = false;
          break;
        }
      }
      return isContain;
    });
  }

  public static filterRemoveAims(original: AIMBean[], needRemove: AIMBean[]): AIMBean[] {
    return original.filter(item => {
      let isContain = true;
      for (let remove of needRemove) {
        if (ContactInfoUtil.isAimEquals(remove, item)) {
          isContain = false;
          break;
        }
      }
      return isContain;
    });
  }

  public static filterRemoveHouses(original: HouseBean[], needRemove: HouseBean[]): HouseBean[] {
    return original.filter(item => {
      let isContain = true;
      for (let remove of needRemove) {
        if (ContactInfoUtil.isHouseEquals(remove, item)) {
          isContain = false;
          break;
        }
      }
      return isContain;
    });
  }

  public static filterRemoveWebsites(original: string[], needRemove: string[]): string[] {
    return original.filter(item => {
      let isContain = true;
      for (let remove of needRemove) {
        if (remove == item) {
          isContain = false;
          break;
        }
      }
      return isContain;
    });
  }

  public static filterRemoveRelationships(original: AssociatedPersonBean[],
    needRemove: AssociatedPersonBean[]): AssociatedPersonBean[] {
    return original.filter(item => {
      let isContain = true;
      for (let remove of needRemove) {
        if (ContactInfoUtil.isRelationshipEquals(remove, item)) {
          isContain = false;
          break;
        }
      }
      return isContain;
    });
  }

  public static filterRemoveEvents(original: EventBean[], needRemove: EventBean[]): EventBean[] {
    return original.filter(item => {
      let isContain = true;
      for (let remove of needRemove) {
        if (ContactInfoUtil.isEventEquals(remove, item)) {
          isContain = false;
          break;
        }
      }
      return isContain;
    });
  }

  public static filterRemoveGroups(original: GroupBean[], needRemove: GroupBean[]): GroupBean[] {
    return original.filter(item => {
      let isContain = true;
      for (let remove of needRemove) {
        if (ContactInfoUtil.isGroupEquals(remove, item)) {
          isContain = false;
          break;
        }
      }
      return isContain;
    });
  }
}