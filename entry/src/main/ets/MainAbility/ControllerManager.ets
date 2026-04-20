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
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';

const TAG = 'ControllerManager';

export class DialogControllerManager {
  public dialogControllerSet: Set<CustomDialogController> = new Set();

  private constructor() {
  }

  private static instance: DialogControllerManager;

  /**
   * get Instance
   * @returns
   */
  public static getInstance(): DialogControllerManager {
    if (!DialogControllerManager.instance) {
      HiLog.w(TAG, 'init DialogControllerManager instance');
      DialogControllerManager.instance = new DialogControllerManager();
    }
    return DialogControllerManager.instance;
  }

  closeAll() {
    if (this.dialogControllerSet == null || this.dialogControllerSet.size <= 0) {
      HiLog.w(TAG, 'close all, set is null or size < 0 ');
      return;
    }
    this.dialogControllerSet.forEach((element: CustomDialogController) => {
      element?.close();
    });
    this.dialogControllerSet.clear();
  }

  addDialogController(dialogController: CustomDialogController | null | undefined) {
    if (dialogController) {
      if (!DialogControllerManager.getInstance().dialogControllerSet.has(dialogController)) {
        HiLog.w(TAG, 'add dialog controller');
        DialogControllerManager.getInstance().dialogControllerSet.add(dialogController);
      }
    }
  }
}

