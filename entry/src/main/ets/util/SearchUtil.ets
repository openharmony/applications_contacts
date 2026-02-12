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
// import SearchClient from '../search/search';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'SearchUtil';

export class SearchUtil {

  private static instance: SearchUtil;

  // private beginSearchSession: SearchClient.SearchSession | undefined;

  private isInSearchSession: boolean = false;

  public static getInstance(): SearchUtil {
    if (!SearchUtil.instance) {
      SearchUtil.instance = new SearchUtil();
    }
    return SearchUtil.instance;
  }

  // 初始化SearchSession(搜索框获焦时/拨号盘输入时就初始化,提高搜索效率)
  public async initSearchSession(): Promise<void> {
    // if (this.beginSearchSession || this.isInSearchSession) {
    //   return;
    // }
    // 加入标记位，保证短时间多次触发只执行一次
    this.isInSearchSession = true;
    try {
      HiLog.w(TAG, 'initSearchSession');
      // this.beginSearchSession = await SearchClient.beginSearch([]);
    } catch (error) {
      let err = error as BusinessError;
      HiLog.e(TAG, 'initSearchSession error message: ' + err.message + ', error code: ' + err.code);
    } finally {
      HiLog.w(TAG, 'initSearchSession end');
      this.isInSearchSession = false;
    }
  }

  // 获取搜索SearchSession对象
  public async getSearchSession(): Promise<void> {
    // if (!this.beginSearchSession) {
    //   this.beginSearchSession = await SearchClient.beginSearch([]);
    //   HiLog.w(TAG, 'getSearchSession end');
    // }
    // return this.beginSearchSession;
  }

  // 应用切后台时SearchSession需断连释放（退出搜索框时也进行断连）
  public async disconnectSearchSession() {
    // if (this.beginSearchSession) {
    //   HiLog.w(TAG, 'disconnectSearchSession');
    //   await SearchClient.endSearch(this.beginSearchSession);
    //   this.beginSearchSession = undefined;
    // }
  }
}