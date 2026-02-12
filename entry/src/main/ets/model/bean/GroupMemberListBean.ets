/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { MemberInfo } from '../../model/bean/ContactVo';

export class GroupMemberListBean {
  public index: number;
  public showIndex: boolean;
  public showDivider: boolean;
  public member: MemberInfo;

  constructor(index: number, showIndex: boolean, showDivider: boolean, member: MemberInfo) {
    this.index = index;
    this.showIndex = showIndex;
    this.showDivider = showDivider;
    this.member = member;
  }
}