/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { DynamicLoader } from '../../../../../../common/src/main/ets/util/DynamicLoader';

const TAG = 'IntelligenceGroupListPresenter  ';

export default class IntelligenceGroupListPresenter {
  public pathInfos?: NavPathStack;
  private static intelligenceGroupInstance: IntelligenceGroupListPresenter;

  public static getInstance(): IntelligenceGroupListPresenter {
    if (IntelligenceGroupListPresenter.intelligenceGroupInstance == null) {
      HiLog.w(TAG, 'IntelligenceGroup getInstance!');
      IntelligenceGroupListPresenter.intelligenceGroupInstance = new IntelligenceGroupListPresenter();
    }
    return IntelligenceGroupListPresenter.intelligenceGroupInstance;
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  aboutToAppear() {
    HiLog.w(TAG, 'groupList aboutToAppear!');
  }

  back() {
    this.pathInfos?.pop();
  }

  /**
   * load category detail page for display contact stastics order by company or city or contact time
   *
   * @param groupName groupName
   * @param categoryGroupType categoryGroupType
   */
  toIntelliGenceGroupListDetail(groupName: string, categoryGroupType: string) {
    HiLog.i(TAG, `toIntelliGenceGroupListDetail:${groupName},${categoryGroupType}`);
    let params: Record<string, boolean | string> = {
      'groupName': groupName,
      'categoryGroupType': categoryGroupType
    }
    DynamicLoader.getInstance().fire(DynamicLoader.INTELLIGENCE_GROUP_SINGLE_CATEGORY_DETAIL).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.INTELLIGENCE_GROUP_SINGLE_CATEGORY_DETAIL, params);
    });
  }
}