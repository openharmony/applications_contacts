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
export interface AnimateCallback {
  finish: ((isPush: boolean, isExit: boolean) => void | undefined) | undefined;
  start: ((isPush: boolean, isExit: boolean) => void | undefined) | undefined;
  onFinish: ((isPush: boolean, isExit: boolean) => void | undefined) | undefined;
}

export interface TitleAnimation {
  titleAnimation: AnimateCallback;
  transitionAnimation: AnimateCallback;
  opacityAnimation: AnimateCallback;
}

const customTransitionMap: Map<number, TitleAnimation> = new Map()

export class CustomTransition {
  private constructor() {
  }

  private static myCustomTransition = new CustomTransition();

  static getInstance() {
    return CustomTransition.myCustomTransition;
  }

  registerNavParam(name: number, titleAnimation: TitleAnimation): void {
    customTransitionMap.set(name, titleAnimation)
  }

  unRegisterNavParam(name: number): void {
    customTransitionMap.delete(name);
  }

  getAnimateParam(name: number): TitleAnimation | undefined {
    if (name == -1) {
      return undefined;
    }
    return customTransitionMap.get(name)
  }
}