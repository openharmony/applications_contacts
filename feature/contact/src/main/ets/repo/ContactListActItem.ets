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

import { Contacts } from '../contract/Contacts';
import { RawContacts } from '../contract/RawContacts';
import DataColumns from '../contract/DataColumns';
import { ValuesBucket } from '@kit.ArkData';
import { DataItemType } from '../contract/DataType';
import { HiLog } from 'common';


export default class ContactListActItem {
  public rawContactId: string = '';

  public mail?: string = '';
  public im?: string = '';
  public nickname?: string = '';
  public organization?: string = '';
  public phone: string[] = [];
  public name: string = '';
  public structuredPostal?: string = '';
  public photo?: string = '';
  public groupMembership?: string = '';
  public note?: string = '';
  public event?: string = '';
  public website?: string = '';
  public relation?: string = '';
  public contactMisc?: string = '';
  public hiCallDevice?: string = '';
  public camCard?: string = '';
  public sipAddress?: string = '';

  constructor(resultSet: ValuesBucket[]) {
    // 遍历 resultSet，根据 type_id 设置相应的属性
    resultSet.forEach((contactInfo: ValuesBucket) => {
      this.rawContactId = contactInfo.raw_contact_id!.toString() ;
      const typeId: number= Number(contactInfo.type_id as string);
      const detailInfo: string = contactInfo.detail_info as string;
      switch (typeId) {
        case DataItemType.EMAIL:
          this.mail = detailInfo;
          break;
        case DataItemType.IM:
          this.im = detailInfo;
          break;
        case DataItemType.NICKNAME:
          this.nickname = detailInfo;
          break;
        case DataItemType.ORGANIZATION:
          this.organization = detailInfo;
          break;
        case DataItemType.PHONE:
          this.phone.push(detailInfo);
          break;
        case DataItemType.NAME:
          this.name = detailInfo;
          break;
        case DataItemType.STRUCTURED_POSTAL:
          this.structuredPostal = detailInfo;
          break;
        case DataItemType.PHOTO:
          this.photo = detailInfo;
          break;
        case DataItemType.GROUP_MEMBERSHIP:
          this.groupMembership = detailInfo;
          break;
        case DataItemType.NOTE:
          this.note = detailInfo;
          break;
        case DataItemType.EVENT:
          this.event = detailInfo;
          break;
        case DataItemType.WEBSITE:
          this.website = detailInfo;
          break;
        case DataItemType.RELATION:
          this.relation = detailInfo;
          break;
        case DataItemType.CONTACT_MISC:
          this.contactMisc = detailInfo;
          break;
        case DataItemType.HI_CALL_DEVICE:
          this.hiCallDevice = detailInfo;
          break;
        case DataItemType.CAM_CARD:
          this.camCard = detailInfo;
          break;
        case DataItemType.SIP_ADDRESS:
          this.sipAddress = detailInfo;
          break;
        default:
          break;
      }
    })
  }

  public getOtherInfo(): number {
    const values: (string | undefined)[] = [this.mail, this.im, this.nickname, this.organization,
      this.structuredPostal,this.photo, this.groupMembership, this.note, this.event, this.website, this.relation,
      this.contactMisc, this.hiCallDevice, this.camCard, this.sipAddress];
    let otherInfo: number = 0;
    values.forEach((value, index) => {
      if (value && value !== '') {
        otherInfo |= 1 << index;
      }
    })
    return otherInfo;
  }

}