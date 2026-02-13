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

const TAG = 'LongPressGestureModifier';

export default class LongPressGestureModifier implements GestureModifier {
  public isShowGesture: boolean = true;
  public actionCallback: null | (() => void) = null;

  applyGesture(event: UIGestureEvent): void {
    if (this.isShowGesture) {
      event.addGesture(
        new LongPressGestureHandler({ repeat: false, fingers: 1, duration: 800 })
          .onAction((event: GestureEvent) => {
            try {
              if (this.actionCallback) {
                this.actionCallback();
              }
            } catch (err) {
              HiLog.e(TAG, 'longPressGestureHandler action error ' + err?.message + ', stack: ' + err?.stack);
            }
          })
      )
    }
  }
}