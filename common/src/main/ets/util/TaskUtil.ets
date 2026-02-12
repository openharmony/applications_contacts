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
import taskpool from '@ohos.taskpool';
import ArrayList from '@ohos.util.ArrayList';
import common from '@ohos.app.ability.common';
import { HiLog } from './HiLog';

const TAG = 'TaskUtil';

export class TaskUtil {
  public static taskList: ArrayList<taskpool.Task> = new ArrayList();

  public static executeTask(task: Function, param: common.UIAbilityContext): taskpool.Task {
    HiLog.i(TAG, 'context : ' + param)
    let newtask: taskpool.Task = new taskpool.Task(task, param);
    TaskUtil.taskList.add(newtask);
    taskpool.execute(newtask).then(() => {
      HiLog.i(TAG, 'task excute success')
      TaskUtil.taskList.remove(newtask);
    });
    return newtask;
  }

  public static cancelTask(task: taskpool.Task) {
    try {
      taskpool.cancel(task);
    } catch (err) {
      HiLog.e(TAG, 'cancelTask failed with error: ' + err);
    }
    TaskUtil.taskList.remove(task);
  }

  public static cancelAll() {
    TaskUtil.taskList.forEach((task: taskpool.Task) => {
      try {
        taskpool.cancel(task);
      } catch (err) {
        HiLog.e(TAG, 'cancelTask failed with error: ' + err);
      }
    })
    TaskUtil.taskList.clear();
  }
}