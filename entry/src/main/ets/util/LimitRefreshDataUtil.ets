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
import { ArrayUtil, HiLog, StringUtil } from '../../../../../common';
import { PageLimit, ReqData } from '../model/type';
import { DataWorkerConstant } from '../workers/DataWorkerTask';
import { ObjectUtil } from '../../../../../common/src/main/ets/util/ObjectUtil';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';

const TAG: string = 'LimitRefreshDataUtil';

export class LimitRefreshDataUtil<T extends PageLimit, R> {
  public getLimitByPage: ((page: number) => number) | undefined = undefined;
  private taskId: number = -1;
  // 查询第几页
  private page: number = 0;
  private task: string = '';
  private actionData?: T;
  private resultCallBack: (resultPage: number, limit: number, result: R) => boolean = () => false;
  private prepareCallBack: () => void = () => {
  };
  private isForeground: boolean = true;
  private currentPage: number = 1;
  private refreshedPages: Array<number> = [];
  private paused: boolean = false;

  constructor(task: string, resultCallBack: (resultPage: number, limit: number, result: R) => boolean, actionData?: T) {
    if (DataWorkerConstant[task] === undefined) {
      HiLog.w(TAG, `${task} not in DataWorkerConstant!!!`)
      return
    }
    this.task = task;
    this.actionData = actionData;
    this.resultCallBack = resultCallBack;
  }

  public setForeground(foreground: boolean) {
    this.isForeground = foreground;
  }

  public setRefreshedPages(pages: Array<number>) {
    this.refreshedPages = pages;
  }

  public getRefreshedPages(): Array<number> {
    return this.refreshedPages;
  }

  public getCurrentPage(): number {
    return this.currentPage;
  }

  public setPage(page: number) {
    this.page = page;
  }

  public setTaskId(task: number) {
    this.taskId = task;
  }

  public getTaskId(): number {
    return this.taskId;
  }

  public setTask(task: string) {
    this.task = task;
  }

  public getTask(): string {
    return this.task;
  }

  public setPause(pause: boolean) {
    this.paused = pause;
  }

  public getPause(): boolean {
    return this.paused;
  }

  public getResultCallBack() {
    return this.resultCallBack
  }

  public setPrepareCallBack(prepareCallBack: () => void) {
    this.prepareCallBack = prepareCallBack;
  }

  public setCurrentPage(current: number) {
    this.currentPage = current;
  }

  public setTaskForeground(foreground: boolean) {
    if (this.isForeground === foreground) {
      HiLog.w(TAG, `${this.task}  setTaskForeground before: ${foreground.toString()}, ` +
        `this.paused == ${this.paused}, this.taskId == ${this.taskId}`);
      return;
    }
    HiLog.i(TAG, `${this.task}  setTaskForeground: ${foreground.toString()}, ` +
      `this.paused == ${this.paused}, this.taskId == ${this.taskId}`);
    this.isForeground = foreground;
    if (foreground && this.paused) {
      if (this.taskId !== -1) {
        this.page = 0;
        this.requestItem();
      } else if (this.page != 0) {
        this.queryAll();
      }
    }
  }

  public setActionData(actionData: T) {
    this.actionData = actionData;
  }

  public requestItem() {
    HiLog.i(TAG, 'requestItem: ' + this.task + ' ' + this.taskId + ' ' + this.isForeground);
    // 查询任务名称
    if (StringUtil.isEmpty(this.task)) {
      HiLog.w(TAG, 'this.task is empty!!');
      return;
    }
    // 存在延迟任务时，主动请求，取消延迟任务；然后进行查询
    if (this.taskId != -1) {
      clearTimeout(this.taskId);
      this.taskId = -1;
    }
    // page为0，说明刚进入查询，从第一页开始查询
    if (this.page === 0) {
      //Refresh from the currently displayed page
      if (this.prepareCallBack && this.prepareCallBack != undefined) {
        HiLog.i(TAG, this.task + ' prepare');
        this.prepareCallBack();
      }
      HiLog.i(TAG, this.task + ' start');
      this.page = this.currentPage;
      this.refreshedPages = [];
      // 查询所有数据
      this.queryAll();
    } else {
      // 不是初始第一次进入查询，设置延迟任务
      HiLog.i(TAG, `${this.task}  isLoading,  this.page == ${this.page}, this.paused: ${this.paused}}`);
      this.taskId = setTimeout(() => {
        this.requestItem();
      }, this.isForeground ? 5000 : 1000);
    }
  }

  public queryAll() {
    if (this.page === 0) {
      HiLog.w(TAG, this.task + ' queryAll finished!')
      return;
    }
    this.paused = false;
    let pageLimit = this.getLimitByPage ?
    this.getLimitByPage(this.page) :
    ArrayUtil.getLimitForSession(this.page);
    this.queryPage(this.page, pageLimit, (isEnd) => {
      // isEnd；当前页查询出的数量和当前页查询limit比较出的结果
      if (!isEnd) {
        if (this.taskId != -1) {
          HiLog.i(TAG, `this.taskId: ${this.taskId}`)
          this.page = 0;
          this.requestItem();
          return
        }
        this.refreshedPages.push(this.page);
        this.page = this.getNextPage(this.page);
        // 查询操作在展示中，继续查询所有
        if (this.isForeground) {
          HiLog.i(TAG, `this.queryAll`)
          this.queryAll();
        } else {
          // 查询操作不在展示中，暂停
          this.paused = true;
          HiLog.i(TAG, this.task + ' background paused')
        }
      } else {
        // 查询结束，page置为0，回到初始状态
        HiLog.i(TAG, this.task + ' queryAll finish');
        this.page = 0;
        if (this.taskId != -1) {
          HiLog.i(TAG, `this.taskId: ${this.taskId}` + ', queryAll finish, still has timeoutTask, need query again.');
          this.requestItem();
        }
      }
    });
  }

  public queryPage(page: number, limit: number, callback?: (isEnd: boolean) => void) {
    const actionData: PageLimit | T = {
      page,
      limit
    };
    if (this.actionData) {
      ObjectUtil.assign(actionData, this.actionData);
    }
    HiLog.i(TAG, this.task + ', queryPage, page:' + page + ',limit:' + limit);
    const reqData: ReqData<PageLimit | T> = {
      actionData: actionData
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest(this.task, reqData, (data: R) => {
      let isEnd = true;
      if (this.resultCallBack) {
        isEnd = this.resultCallBack(page, limit, data);
      } else if (Array.isArray(data)) {
        isEnd = data.length < limit
      }
      if (callback) {
        callback(isEnd);
      }
    })
  }

  getNextPage(page: number) {
    if (!this.refreshedPages.includes(this.currentPage)) {
      return this.currentPage;
    }
    let next: number = page;
    while (this.refreshedPages.includes(next)) {
      if (next <= this.currentPage && next > 1) {
        next--;
      } else {
        if (next < this.currentPage) {
          next = this.currentPage;
        }
        next++;
      }
    }
    return next
  }

  public release(): void {
    HiLog.i(TAG, 'start release...,taskName : ' + this.task + ' ,taskId: ' + this.taskId);
    if (this.taskId > 0) {
      clearTimeout(this.taskId);
      this.taskId = -1;
    }
  }
}