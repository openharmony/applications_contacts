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
import BasicDataSource from './BasicDataSource';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { MemberInfo } from '../../model/bean/ContactVo';
import { GroupMemberListBean } from './GroupMemberListBean';
const TAG = 'GroupMemberDataSource ';

export default class GroupListDetailPresenter extends BasicDataSource {
  private memberList: MemberInfo[] = [];

  public totalCount(): number {
    return this.memberList.length;
  }

  public getFavoriteList(): MemberInfo[] {
    return this.memberList;
  }

  public getData(index: number): GroupMemberListBean | null {
    if (ArrayUtil.isEmpty(this.memberList) || index >= this.memberList.length) {
      HiLog.w(TAG, 'getData memberList is empty');
      return null;
    } else {
      let member: MemberInfo = this.memberList[index];
      let preContact: MemberInfo = this.memberList[index - 1];
      let showIndex: boolean = (index == 0 || !(member.member.namePrefix == preContact.member.namePrefix));
      let showDivider: boolean = false;
      if (index < this.memberList.length - 1) {
        let nextContact: MemberInfo = this.memberList[index + 1];
        showDivider = (member.member.namePrefix == nextContact.member.namePrefix);
      } else {
        showDivider = false;
      }
      member.member.title =
        (StringUtil.isEmpty(member.member.showName) ? member.member.phoneNum : member.member.showName);
      if (StringUtil.isEmpty(member.member.company)) {
        member.member.subTitle = StringUtil.isEmpty(member.member.position) ? '' : member.member.position;
      } else {
        member.member.subTitle = member.member.company.concat(' ')
          .concat(StringUtil.isEmpty(member.member.position) ? '' : member.member.position);
      }
      return new GroupMemberListBean(index, showIndex, showDivider, member);
    }
  }
  public refresh(memberList: MemberInfo[]): void {
    HiLog.w(TAG, 'refresh!');
    this.memberList = memberList;
    this.notifyDataReload();
  }
  public remove(index: number, count?: number) {
    if (index < 0 || index >= this.totalCount()) {
      return;
    }
    HiLog.w(TAG, ' remove:' + index);
    this.memberList.splice(index, count ? count : 1);
    this.notifyDataReload();
  }
  public getMemberData() {
    return this.memberList;
  }
}