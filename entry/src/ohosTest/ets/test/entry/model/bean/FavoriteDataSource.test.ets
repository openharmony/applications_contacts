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
import { FavoriteBean } from '../../../../../../main/ets/model/bean/FavoriteBean';
import FavoriteDataSource from '../../../../../../main/ets/model/bean/FavoriteDataSource';
import { FavoriteListBean } from '../../../../../../main/ets/model/bean/FavoriteListBean';
import MorandiColor from '../../../../../../main/ets/model/bean/MorandiColor';
import { SearchContactResult } from '../../../../../../main/ets/model/bean/SearchContactResult';

export default function FavoriteDataSourceTest() {
  describe('FavoriteDataSourceTest', () => {
    it('FavoriteDataSourceTest_totalCount', 0, () => {
      let cd = new FavoriteDataSource();
      expect(cd.totalCount()).assertEqual(0);
    })

    it('FavoriteDataSourceTest_getFavoriteList', 0, () => {
      let cd = new FavoriteDataSource();
      expect(JSON.stringify(cd.getFavoriteList())).assertEqual(JSON.stringify([]));
    })

    it('FavoriteDataSourceTest_refresh', 0, () => {
      let favoriteList: FavoriteBean[] = [];
      let cd = new FavoriteDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.refresh(favoriteList);
      mocker.verify('notifyDataReload', []).times(0);
      mocker.clear(cd);
    })

    it('FavoriteDataSourceTest_getData', 0, () => {
      let favoriteList: FavoriteBean[] = [];
      let cd = new FavoriteDataSource();
      expect(cd.getData(0)).assertEqual(null);
      favoriteList.push(new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, ''))
      favoriteList.push(new FavoriteBean('', -1, '', '', '', '', $r("sys.color.ohos_id_color_special1"), false, '', false, 0, ''))
      cd.refresh(favoriteList)
      let fb = cd.getData(0)
      if (fb != null) {
        expect(fb.showDivider).assertEqual(true)
      }
      let fb1 = cd.getData(1)
      if (fb1 != null) {
        expect(fb1.showDivider).assertEqual(false)
      }
    })

    it('FavoriteDataSourceTest_indexOf', 0, () => {
      let item: FavoriteBean = new FavoriteBean('1', -1, '', '', '', '', MorandiColor.color[0], false, '', false, 0, '');
      let uselessObj: SearchContactResult =
        new SearchContactResult('', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
      let favoriteListBean = new FavoriteListBean(0, true, true, item, uselessObj);
      let cd = new FavoriteDataSource();
      expect(cd.indexOf(favoriteListBean)).assertEqual(-1);

      let list: FavoriteBean[] = [item];
      let favoriteData: FavoriteListBean[] = [favoriteListBean];
      cd.favoriteList = list;
      cd.favoriteData = favoriteData;
      expect(cd.indexOf(favoriteListBean)).assertEqual(0);
    })

    it('FavoriteDataSourceTest_remove', 0, () => {
      let cd = new FavoriteDataSource();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cd, cd.notifyDataReload);
      cd.remove(-1);
      mocker.verify('notifyDataReload', []).never();
      let item: FavoriteBean = new FavoriteBean('1', -1, '', '', '', '', MorandiColor.color[0], false, '', false, 0, '');
      let list: FavoriteBean[] = [item];
      let uselessObj: SearchContactResult =
        new SearchContactResult('', '', '', '', '', '', [], [], '', '', [], [], '', '', [], [], 0, '', '', '');
      let favoriteListBean = new FavoriteListBean(0, true, true, item, uselessObj);
      let favoriteData: FavoriteListBean[] = [favoriteListBean];
      cd.favoriteList = list;
      cd.favoriteData = favoriteData;
      cd.remove(0, 0);
      mocker.verify('notifyDataReload', []).once();
      mocker.clear(cd);
    })
  })
}