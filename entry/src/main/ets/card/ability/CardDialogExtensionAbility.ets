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
import { CardDialogInfoType } from '../type/commonType';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import WorkFactory, { WorkerType } from '../../workers/WorkFactory';
import { BusinessError } from '@ohos.base';

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
    let param: LooseObject = {
      'session': session,
      'dialogInfo': dialogInfo
    };
    let storage: LocalStorage = new LocalStorage(param);
    session.loadContent('card/common/dialog/CardSelectDialog', storage);
    session.setWindowBackgroundColor('#00000000');
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    HiLog.i(TAG, `UIExtAbility onSessionDestroy`);
  }
}