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

/**
 * Call record object (detail page)
 */
let NextId = 0;

export class CallLogBean {
  id: string ;
  time: string ;
  action: string ;
  calledNumber: string ;
  status: string ;
  constructor(time: string, action: string, calledNumber: string, status: string) {
    this.id = `${NextId++}`;
    this.time = time;
    this.action = action;
    this.calledNumber = calledNumber;
    this.status = status;
  }
}