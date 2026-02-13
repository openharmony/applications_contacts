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
import { display } from '@kit.ArkUI';
import curves from '@ohos.curves';
import { i18n } from '@kit.LocalizationKit';

// 热区
const HOT_AREA_LENGTH =
  Math.round(display.getDefaultDisplaySync().densityDPI * 10 / 25.4 / display.getDefaultDisplaySync().densityPixels);
// 滚动速度: 贝塞尔曲线
const SLIDE_SELECT_SPEED_CURVE = curves.cubicBezierCurve(0.33, 0, 0.67, 1);
// 滚动速度: 最大速度
const AUTO_SPEED_MAX: number = Math.round(2400 / display.getDefaultDisplaySync().densityPixels);

const TAG: string = 'SlidingMultipleSelectionsUtil';



// 滑动多选时，滚动条滚动的方向
enum ScrollDir {
  NONE = 'NONE',
  TOP = 'TOP',
  BOTTOM = 'BOTTOM'
}


export class SlidingMultipleSelectionsUtil {

  private selectStartIndex = -1;
  private selectEndIndex = -1;
  private targetState: boolean = false;
  private scroller?: Scroller;

  public oldSelectStatus: boolean[] = [];
  public curSelectStatus: boolean[] = [];

  public scrollStartIndex: number = -1;
  public scrollEndIndex: number = -1;

  public isSliding: boolean = true;
  public isStopScroll: boolean = false;

  // 滚动部位显示区域的高度
  public contentHeight: number = 0;
  public areaY: number = 0;
  public listWidth: number = 0;
  private checkBoxWidth: number = 0;
  private isAutoScroll: boolean = false;
  private scrollDir: ScrollDir = ScrollDir.NONE;

  constructor(scroller: Scroller, checkBoxWidth: number) {
    this.scroller = scroller;
    this.checkBoxWidth = checkBoxWidth;
  }


  onActionStart(finger: FingerInfo) {
    if (finger === undefined) {
      return;
    }
    let index = this.getIndex(finger);
    if (index >= 0 && index < this.oldSelectStatus.length) {
      this.selectStartIndex = index;
      this.targetState = !this.oldSelectStatus[index];
      HiLog.i(TAG, `onActionStart selectStartIndex: ${this.selectStartIndex}, targetState: ${this.targetState}`);
    }
  }

  onActionUpdate(finger: FingerInfo, getCurSelectStatus: (index: number) => boolean): number[] {
    let updateIndexes: number[] = [];
    if (finger === undefined) {
      return updateIndexes;
    }
    let index = this.getIndex(finger);

    if (index >= 0 && index < this.oldSelectStatus.length && this.selectEndIndex !== index) {
      HiLog.i(TAG, `onActionUpdate selectEndIndex: ${this.selectEndIndex}, index: ${index}`);
      let minIndex = this.selectEndIndex;
      let maxIndex = index;
      if (this.selectEndIndex > index) {
        minIndex = index;
        maxIndex = this.selectEndIndex;
      }
      for (let i = minIndex; i <= maxIndex; ++i) {
        this.curSelectStatus[i] = getCurSelectStatus(i);
        HiLog.i(TAG, `onActionUpdate i: ${i}, curSelectStatus: ${this.curSelectStatus[i]}`);
      }

      this.selectEndIndex = index;
      let startIndex = this.selectStartIndex;
      let endIndex = this.selectEndIndex;
      if (this.selectStartIndex > this.selectEndIndex) {
        startIndex = this.selectEndIndex;
        endIndex = this.selectStartIndex;
      }

      for (let i = 0; i < this.oldSelectStatus.length; ++i) {
        let curState = this.curSelectStatus[i];
        let oldState = this.oldSelectStatus[i];
        if (i >= startIndex && i <= endIndex) {
          // 改变
          if (curState !== this.targetState) {
            updateIndexes.push(i)
            HiLog.w(TAG, `i: ${i}, curState: ${curState}, this.targetState: ${this.targetState}`);
            this.curSelectStatus[i] = this.targetState;
          }
        } else {
          // 不改变
          if (curState !== oldState) {
            updateIndexes.push(i)
            HiLog.w(TAG, `i: ${i}, curState: ${curState}, oldState: ${oldState}`);
            this.curSelectStatus[i] = oldState;
          }
        }
      }
      HiLog.i(TAG, `onActionUpdate updateIndexes: ${updateIndexes.toString()}`);
    }
    if (!this.isStopScroll) {
      this.autoScroll(finger);
    }
    return updateIndexes;
  }

  onActionEnd() {
    HiLog.i(TAG, `onActionEnd`);
    this.selectStartIndex = -1;
    this.selectEndIndex = -1;
    this.oldSelectStatus = [];
    this.curSelectStatus = [];
    this.scroller?.scrollBy(0, 0);
  }

  onGestureRecognizerJudgeBegin(finger: FingerInfo, current: GestureRecognizer) {
    if (this.isSliding && current.isBuiltIn() && current.getType() == GestureControl.GestureType.PAN_GESTURE &&
      finger !== undefined &&
      (i18n.isRTL(i18n.System.getSystemLanguage()) ? finger.localX < this.checkBoxWidth
        : finger.localX > this.listWidth - this.checkBoxWidth)) {
      return GestureJudgeResult.REJECT;
    }
    return GestureJudgeResult.CONTINUE;
  }

  getIndex(finger: FingerInfo): number {
    let index = this.scroller?.getItemIndex(finger.localX, finger.localY) ?? -1;
    if (index === -1) {
      if (this.scrollDir === ScrollDir.TOP) {
        index = this.scrollStartIndex;
      } else if (this.scrollDir === ScrollDir.BOTTOM) {
        index = this.scrollEndIndex;
      }
    }
    return index;
  }

  stopScroll() {
    this.scroller?.scrollBy(0, 0);
    this.scrollDir = ScrollDir.NONE;
    this.isAutoScroll = false;
  }

  autoScroll(finger: FingerInfo) {
    let pointY = finger.globalY - this.areaY;
    if (pointY <= HOT_AREA_LENGTH) {
      if (this.isAutoScroll && pointY <= 0) {
        return;
      }
      const speedFlag = pointY > 0 ? SLIDE_SELECT_SPEED_CURVE
        .interpolate(1 - pointY / HOT_AREA_LENGTH) : 1;
      this.scroller?.scrollEdge(Edge.Top, {
        velocity: speedFlag * AUTO_SPEED_MAX
      })
      this.scrollDir = ScrollDir.TOP;
      this.isAutoScroll = true;
    } else if (pointY > this.contentHeight - HOT_AREA_LENGTH) {
      if (this.isAutoScroll && pointY >= this.contentHeight) {
        return;
      }
      const speedFlag = pointY < this.contentHeight ? SLIDE_SELECT_SPEED_CURVE
        .interpolate(1 - (this.contentHeight - pointY) / HOT_AREA_LENGTH) : 1;
      this.scroller?.scrollEdge(Edge.Bottom, {
        velocity: speedFlag * AUTO_SPEED_MAX
      })
      this.scrollDir = ScrollDir.BOTTOM;
      this.isAutoScroll = true;
    } else {
      if (this.isAutoScroll) {
        this.stopScroll();
      }
    }
  }
}