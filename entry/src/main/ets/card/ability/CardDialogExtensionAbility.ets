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
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import LooseObject from '../../model/type/LooseObject';
import { CardDialogInfoType, CardDialogSimInfo } from '../type/commonType';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import WorkFactory, { WorkerType } from '../../workers/WorkFactory';
import { BusinessError } from '@ohos.base';
import sim from '@ohos.telephony.sim';
import radio from '@ohos.telephony.radio';

const TAG = 'CardDialogExtensionAbility';


export default class CardDialogExtensionAbility extends UIExtensionAbility {
  public mDataWorker: WorkerWrapper = WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper;
  onSessionCreate(want: Want, session: UIExtensionContentSession) {
    let sceneboardWant: Want = {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'com.ohos.sceneboard.systemdialog'
    };
    this.context.startAbility(sceneboardWant).then(() => {
      HiLog.i(TAG, 'CardDialogExtensionAbility startAbility Success');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'jumpToContact, failed. Cause: ' + `${error?.message}`);
    });
    HiLog.i(TAG, 'CallBannerExtensionAbility start' + `want:${want?.abilityName}`);
    ContactsGlobalThisHelper.GetGlobalThis()
      .set(ContactsGlobalThisHelper.UIContextName, this.context);
    ContactsGlobalThisHelper.GetGlobalThis()
      .set<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName, this.mDataWorker);
    this.mDataWorker.sendRequest('init', {
      context: this.context
    });
    let dialogInfo: CardDialogInfoType = want.parameters?.dialogInfo as CardDialogInfoType;
    this.refreshSimDisplayNames(dialogInfo)
      .catch((err: BusinessError) => {
        HiLog.e(TAG, `refreshSimDisplayNames failed: ${err?.message}`);
      })
      .then(() => {
        let param: LooseObject = {
          'session': session,
          'dialogInfo': dialogInfo
        };
        let storage: LocalStorage = new LocalStorage(param);
        session.loadContent('card/common/dialog/CardSelectDialog', storage);
        session.setWindowBackgroundColor('#00000000');
      });
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    HiLog.i(TAG, `UIExtAbility onSessionDestroy`);
  }

  /**
   * 对无效 name 重新查询
   */
  private refreshSimDisplayNames(dialogInfo: CardDialogInfoType): Promise<void> {
    if (!dialogInfo?.simList || dialogInfo.simList.length === 0) {
      return Promise.resolve();
    }
    let tasks: Promise<void>[] = [];
    dialogInfo.simList.forEach((item: CardDialogSimInfo) => {
      if (typeof item.name === 'string' && item.name.length > 0 && item.name !== 'null') {
        return;
      }
      let slotId: number = item.slotId;
      tasks.push(this.querySimDisplayName(slotId).then((name: string) => {
        item.name = name;
      }));
    });
    return Promise.all(tasks).then(() => {});
  }

  private querySimDisplayName(slotId: number): Promise<string> {
    return new Promise((resolve) => {
      sim.getShowName(slotId, (err: BusinessError<void>, value: string) => {
        if (!err && value && value !== 'null' && value.length > 0) {
          resolve(value);
          return;
        }
        radio.getOperatorName(slotId, (error, data) => {
          if (!error && data && data.length > 0) {
            resolve(data);
            return;
          }
          try {
            resolve(this.context.resourceManager.getStringSync($r('app.string.NoService')));
          } catch (e) {
            resolve('');
          }
        });
      });
    });
  }
}
