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
import { ContactInfo } from '../../../model/bean/ContactInfo';
import { EventBean } from '../../../model/bean/EventBean';
import { PhoneNumBean } from '../../../model/bean/PhoneNumBean';

/**
 * 原始数据处理帮助类
 */
export class OriginalDataHandleHelper {

  /**
   * 电话原始数据，
   */
  public phoneOriginalDataMap = new Map<string, PhoneNumBean>();
  public eventOriginalDataMap = new Map<number, EventBean>();

  public constructor() {

  }

  public phoneOriginalData(phones?: PhoneNumBean[]) {
    if (phones === undefined) {
      return this;
    }

    phones.forEach(phone => {
      this.phoneOriginalDataMap.set(phone.num, phone);
    })

    return this;
  }

  public eventOriginalData(events?: EventBean[]) {
    if (events === undefined) {
      return this;
    }

    events.forEach(event => {
      this.eventOriginalDataMap.set(event.contactDataId, event);
    })

    return this;
  }

  /**
   * 从原始数据需要继承过来的，设置到联系人信息中
   * 因为联系人更新，对于contact_data是先delete，再insert，一些不是通过修改页面设置的值，就会丢失，需要从原始数据继承过来
   * @param contactInfo
   */
  public inheritOriginalDataHandle(contactInfo: ContactInfo) {
    // 更新电话信息，默认信息需要从原始数据继承，否则联系人更新后，电话信息会丢失
    if (contactInfo.phones.length > 0 && this.phoneOriginalDataMap.size > 0) {
      contactInfo.phones.forEach(phone => {
        let oldPhone = this.phoneOriginalDataMap.get(phone.num);
        if (oldPhone !== undefined) {
          phone.primary = oldPhone.primary;
        }
      })
    }
    if (contactInfo.events.length > 0 && this.eventOriginalDataMap.size > 0) {
      contactInfo.events.forEach(event => {
        let oldEvent = this.eventOriginalDataMap.get(event.contactDataId);
        if (oldEvent !== undefined) {
          event.calendarEventId = oldEvent.calendarEventId;
        }
      })
    }

  }
}