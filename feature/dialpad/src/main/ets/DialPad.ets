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
import { PhoneNumber } from "../../../../../feature/phonenumber/src/main/ets/PhoneNumber";
import SmartSearchList from "./entity/SmartSearchList";

/**
 * Dialpad object, which provides dialpad-related services.
 */
export default class DialPad {
  private input: string;
  private dialKey: [];
  constructor() {
  }

  inputKey(key: string) {
    this.playTone(key);
    this.input = this.input + key;
    return this.input;
  }

  private playTone(tone: string) {
  }

  call() {
    PhoneNumber.fromString(this.input).dial();
    this.clearInput();
  }

  clearInput() {
    this.input = "";
  }

  getDialKey() {

  }

  getSmartSearchResult() {
    return new SmartSearchList();
  }
}