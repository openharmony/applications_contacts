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
import { contact } from '@kit.ContactsKit';
import { Birthday } from '../../../../../../feature/contact/src/main/ets/contract/Birthday';

export class EventBean {
  // contactData 行ID
  public contactDataId: number = -1;
  public calendarEventId?: string;
  public id: string;
  public data: string;
  public eventType: string;
  public eventName: string;
  public labelName?: Resource;
  public pickerData: contact.Event = {
    eventDate: ''
  }

  constructor(id: string, data: string, eventType: string, eventName: string) {
    this.id = id;
    this.data = data;
    this.eventType = eventType;
    this.eventName = eventName;
  }

  setPickerData(eventDate: string, labelName?: string, labelId?: number) {
    this.pickerData.eventDate = eventDate;
    this.pickerData.labelName = labelName;
    this.pickerData.labelId = labelId;
  }

  static getBeanByPickerData(event: contact.Event) {
    let labelId: number = Birthday.apiTypeToSystemType(event.labelId ?? contact.Event.EVENT_OTHER);
    return new EventBean('', event.eventDate, labelId.toString(), '');
  }
}
