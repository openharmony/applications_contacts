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
import { describe, it, expect, MockKit } from '@ohos/hypium';
import { MemberInfo } from '../../../../../../main/ets/model/bean/ContactVo';
import GroupMemberDataSource from '../../../../../../main/ets/model/bean/GroupMemberDataSource';

export default function GroupMemberDataSourceTest() {
  describe('GroupMemberDataSourceTest', () => {
    it('GroupMemberDataSourceTest_totalCount', 0, () => {
      let gd = new GroupMemberDataSource();
      expect(gd.totalCount()).assertEqual(0)
    })

    it('GroupMemberDataSourceTest_getFavoriteList', 0, () => {
      let gd = new GroupMemberDataSource();
      expect(gd.getFavoriteList().length).assertEqual(0)
    })

    it('GroupMemberDataSourceTest_refresh', 0, () => {
      let memberList: MemberInfo[] = [];
      let gd = new GroupMemberDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(gd, gd.notifyDataReload);
      gd.refresh(memberList)
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(gd);
    })

    it('GroupMemberDataSourceTest_getData', 0, () => {
      let memberList: MemberInfo[] = [];
      let groupMemberDataSource = new GroupMemberDataSource();
      memberList.push(new MemberInfo());
      memberList.push(new MemberInfo());
      groupMemberDataSource.refresh(memberList);
      expect(groupMemberDataSource.getData(0)?.index).assertEqual(0)
    })

    it('GroupMemberDataSourceTest_getMemberData', 0, () => {
      let gd = new GroupMemberDataSource();
      expect(gd.getMemberData().length).assertEqual(0)
    })

    it('GroupMemberDataSourceTest_remove', 0, () => {
      let memberList: MemberInfo[] = [];
      let gd = new GroupMemberDataSource();
      expect(gd.getData(-1)).assertEqual(null)
      memberList.push(new MemberInfo())
      memberList.push(new MemberInfo())
      gd.refresh(memberList)
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(gd, gd.notifyDataReload);
      gd.remove(0)
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(gd);
    })

    it('GroupMemberDataSourceTest_remove_01', 0, () => {
      let gd = new GroupMemberDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(gd, gd.notifyDataReload);
      gd.remove(0)
      mocker.verify('notifyDataReload', []).never();
      mocker.clear(gd);
    })
  })
}