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

export class GroupBean {
  id: string; // 联系人id主键
  groupId: string; //群組Id
  groupType: string ; //AIM类型（qq 微博，雅虎等 ）
  groupName: string; //AIM内容

  constructor(id: string, groupId: string, groupType: string, groupName: string) {
    this.id = id;
    this.groupId = groupId;
    this.groupType = groupType;
    this.groupName = groupName;
  }
}
