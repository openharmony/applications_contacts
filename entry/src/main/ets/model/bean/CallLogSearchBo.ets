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
import { CALL_LOG_SEARCH_MIN } from '../../presenter/dialer/DialerPresenter';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
const TAG = 'CallLogSearchBo';
/**
 * 拨号盘输入号码，通话日志搜索业务对象
 */
export class CallLogSearchBo {
  private static callLogSearchBoInstance: CallLogSearchBo;
  // 初始为1，表示默认需要查询，需要从查询1变为-》0，才不需要查询了
  public static MATCH_SIZE_INIT = 1;
  public preNumberLength: number = 0;
  public preNumber: string = '';
  public preMatchSize: number = CallLogSearchBo.MATCH_SIZE_INIT;
  /**
   * 刷新通话记录时
   */
  public refreshCallLogFlag = false;

  constructor() {
  }

  /**
   * 拨号码时，如果联系人信息或通话记录信息变了，可能生成新的要被查询的记录，所以需要 查询
   * (1)通话记录刷新，可能生成之前没有查到的记录，需要重新查询; 但是从通话记录页面到拨号页面后，通话记录监听变更的监听被去掉了，所以监听不到
   *     在原生联系人，通过详情页面拨号，无法监听，通过点击拨号按钮事件刷新
   *     在畅连，打电话，无法触发
   * (2)联系人改变，可能生成之前没有查到的记录，需要重新查询，这个可以监听到
   */
  public refreshCallChangeFlag() {
    this.refreshCallLogFlag = true;
  }

  /**
   * 判断本次是否需要继续匹配通话记录
   * @returns
   */
  public judgeIsQuery(teleNumber: string): boolean {
    // 通话记录改变，本次号码变更必须查询，查询后可获取最新结果，将通话记录刷新标记置为false
    if (this.refreshCallLogFlag == true) {
      this.refreshCallLogFlag = false;
      return true;
    }
    // 上次号码长度大于等于3，说明上次已经查询过
    // 如果上次已经搜索过(上次电话号码长度 >= CALL_LOG_SEARCH_MIN)
    // 且为继续点击拨号盘，增加长度，如果上次搜索的通话记录长度为0，则不需要查询数据库，因为111查不到通话记录，111x更查不到
    // 长度超过20位后，号码会触发两次查询，相同长度，上次没查到，下次查也查不到
    // 短信跳转呼叫前编辑，直接传号码，可能是 123 4567 8900；查询没有通话记录；下次传123 4567 8901 仍需要查询
    // 使用标记判断，是否是从外部跳转至呼叫前编辑
    if (ContactsGlobalThisHelper.GetGlobalThis().
      getValue<boolean>(ContactsGlobalThisHelper.ToEditBeforeCallingFromExternalAppFlag) === true) {
      HiLog.i(TAG, 'ToEditBeforeCallingFromExternalAppFlag true');
      ContactsGlobalThisHelper.GetGlobalThis().
        set(ContactsGlobalThisHelper.ToEditBeforeCallingFromExternalAppFlag, false);
      return true;
    }
    // 需要排除在号码中间插入，15搜索不到时，135可以搜到
    if (this.preNumberLength >= CALL_LOG_SEARCH_MIN && this.preNumberLength <= teleNumber.length &&
      teleNumber.indexOf(this.preNumber) !== -1) {
      if (this.preMatchSize <= 0) {
        return false;
      }
    }

    return true;
  }

  /**
   *
   * @param teleNumber
   * @param mAllCallRecordListDataSource
   */
  public refreshCurSearchResult(teleNumber: string, matchSize: number) {
    this.preNumber = teleNumber;
    this.preNumberLength = teleNumber.length;
    this.preMatchSize = matchSize;
  }

  public static getInstance() {
    if (CallLogSearchBo.callLogSearchBoInstance == null) {
      CallLogSearchBo.callLogSearchBoInstance = new CallLogSearchBo();
    }
    return CallLogSearchBo.callLogSearchBoInstance;
  }
}