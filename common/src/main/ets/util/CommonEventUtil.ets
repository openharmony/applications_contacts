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
import CommonEventManager from '@ohos.commonEventManager';
import { BusinessError } from '@ohos.base';
import { HiLog } from './HiLog';

const TAG = 'CommonEventUtil';

export class CommonEventUtil {
  public static async registerSubscriber(event: string): Promise<CommonEventManager.CommonEventSubscriber> {
    return new Promise((resolve: (subscriber: CommonEventManager.CommonEventSubscriber) => void,
      reject: () => void) => {
      let subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
        events: [event]
      };
      CommonEventManager.createSubscriber(subscribeInfo,
        (err: BusinessError, subscriber: CommonEventManager.CommonEventSubscriber) => {
          HiLog.i(TAG, 'createSubscriber err :' + err);
          if (err != null) {
            HiLog.w(TAG, 'createSubscriber failed:' + err?.message + ', stack: ' + err?.stack);
            reject();
          } else {
            HiLog.i(TAG, 'createSubscriber succeed event is :' + event);
            resolve(subscriber);
          }
        })
    })
  }

  public static subscribe(subscriber: CommonEventManager.CommonEventSubscriber, event: string, callback: Function) {
    CommonEventManager.subscribe(subscriber,
      (error: BusinessError, commonEventData: CommonEventManager.CommonEventData) => {
        if (error != null || event == '') {
          HiLog.w(TAG, 'subscribe error：' + error?.message + ', stack: ' + error?.stack);
        } else {
          HiLog.i(TAG, 'subscribe commonEventData');
          if (commonEventData.event === event) {
            callback()
          }
        }
      });
  }

  public static unsubscribe(subscriber: CommonEventManager.CommonEventSubscriber) {
    if (!subscriber) {
      return;
    }
    CommonEventManager.unsubscribe(subscriber, (err: BusinessError) => {
      // Check whether an exception exists.
      if (err != null && err.code != null) {
        HiLog.w(TAG, 'CommonEventManager.unsubscribe err: %s' + err?.message + ', stack: ' + err?.stack);
      } else {
        HiLog.i(TAG, "CommonEventManager.unsubscribe success!!")
      }
    });
  }
}