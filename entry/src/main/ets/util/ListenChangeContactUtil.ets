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

export class ChangeIdInfo {
  public delRawContactIdArr: string[] = [];
  public updateRawContactIdArr: string[] = [];
  // 可能存在更新或删除联系人，但根据条件没有匹配的，也会通知，通知具体类型，无修改
  public notifyModifyType = '';
}

export class ListenChangeContactUtil {

  private static instance: ListenChangeContactUtil | null = null;

  private changeIdInfo: ChangeIdInfo = new ChangeIdInfo();

  public static getInstance() {
    if (ListenChangeContactUtil.instance === null) {
      ListenChangeContactUtil.instance = new ListenChangeContactUtil();
    }
    return ListenChangeContactUtil.instance;
  }

  public consumeChangeIds(): ChangeIdInfo {
    let changeIdInfoCopy = this.changeIdInfo;
    this.changeIdInfo = new ChangeIdInfo();
    return changeIdInfoCopy;
  }

  public produceChangeIds(changeIdInfoProduce: ChangeIdInfo) {
    changeIdInfoProduce.delRawContactIdArr.forEach(delId => {
      this.changeIdInfo.delRawContactIdArr.push(delId);
    })

    changeIdInfoProduce.updateRawContactIdArr.forEach(updateId => {
      this.changeIdInfo.updateRawContactIdArr.push(updateId)
    })

  }
}