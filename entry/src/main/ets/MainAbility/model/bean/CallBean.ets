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

export class CallBean {
  readonly id: string ;
  phone: string ;
  name: string ;
  callTime: string ;
  // Call type: 1: incoming call; 2: outgoing call; 3: missed call; 5: rejected call
  callType: string ;
  // Home area of the number
  callTag: string ;
  // Call SIM card. 0: SIM card 1, 1: SIM card 2.
  simType: string ;
  // Indicates whether an HD call is supported. true: HD call; false: non-HD call
  isHd: string ;
  // Format Phone Number
  formatNumber: string ;
  // Contact ID.
  contactKey: string ;
  // Call Times
  num: string;
  // Indicates whether to be selected. The default value is false.
  isChecked: boolean = false;
  portraitColor: string;
  suffix: string;
  constructor(id: string, phone: string) {
    this.id = id;
    this.phone = phone;
  }

  setName(name: string): CallBean {
    this.name = name;
    return this;
  }

  setCallTime(callTime: string) {
    this.callTime = callTime;
    return this;
  }

  setCallType(callType: string) {
    this.callType = callType;
    return this;
  }

  setCallTag(callTag: string) {
    this.callTag = callTag;
    return this;
  }

  setSimType(simType: string) {
    this.simType = simType;
    return this;
  }

  setIsHd(isHd: string) {
    this.isHd = isHd;
    return this;
  }

  setFormatNumber(formatNumber: string) {
    this.formatNumber = formatNumber;
    return this;
  }

  setContactKey(contactKey: string) {
    this.contactKey = contactKey;
    return this;
  }

  setNum(num: string) {
    this.num = num;
    return this;
  }

  setIsChecked(isChecked: boolean) {
    this.isChecked = isChecked;
    return this;
  }

  setPortraitColor(portraitColor: string) {
    this.portraitColor = portraitColor;
    return this;
  }

  setSuffix(suffix: string) {
    this.suffix = suffix;
    return this;
  }
}