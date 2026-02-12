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
import { beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import CardDialogExtensionAbility from '../../../../../../main/ets/card/ability/CardDialogExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';
import StartOptions from '@ohos.app.ability.StartOptions';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { HiLog } from '../../../../../../../../common/src/main/ets/util/HiLog';

const TAG = 'CardDialogExtensionAbility';

export default function CardDialogExtensionAbilityTest() {

  let cardDialogExtensionAbility: CardDialogExtensionAbility;

  describe('CardDialogExtensionAbilityTest', () => {

    beforeEach(() => {
      cardDialogExtensionAbility = new CardDialogExtensionAbility();
    })

    it('CardDialogExtensionAbility_onSessionCreate', 0, () => {
      let context: common.UIExtensionContext = {
        startAbility: (want: Want, options?: StartOptions): Promise<void> =>
        new Promise <void>(resolve => resolve())
      } as common.UIExtensionContext;
      cardDialogExtensionAbility.context = context;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);
      mocker.mockFunc(cardDialogExtensionAbility.mDataWorker, cardDialogExtensionAbility.mDataWorker.sendRequest);

      let want: Want = {
        parameters: {
          dialogInfo: {
            flag: 'selectNum',
            phoneList: [],
            simList: [],
            lastSimId: -1,
            abilityName: 'com.ohos.sceneboard.systemdialog'
          }
        }
      };

      let result = false;
      let result1 = false;
      let session: UIExtensionContentSession = {
        loadContent: (path: string, storage?: LocalStorage): void => {
          result = true;
        },
        setWindowBackgroundColor: (color: string): void => {
          result1 = true;
        }
      } as UIExtensionContentSession;

      cardDialogExtensionAbility.onSessionCreate(want, session);

      mocker.verify('set', ['mDataWorker', cardDialogExtensionAbility.mDataWorker]).once();
      mocker.verify('sendRequest', ['init', {
        context: cardDialogExtensionAbility.context
      }]).once();
      expect(result).assertTrue();
      expect(result1).assertTrue();

      mocker.clear(cardDialogExtensionAbility.mDataWorker);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CardDialogExtensionAbility_onSessionCreate_want_noParameters', 0, () => {
      let context: common.UIExtensionContext = {
        startAbility: (want: Want, options?: StartOptions): Promise<void> =>
        new Promise <void>(resolve => resolve())
      } as common.UIExtensionContext;
      cardDialogExtensionAbility.context = context;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);
      mocker.mockFunc(cardDialogExtensionAbility.mDataWorker, cardDialogExtensionAbility.mDataWorker.sendRequest);

      let want: Want = {
      };

      let result = false;
      let result1 = false;
      let session: UIExtensionContentSession = {
        loadContent: (path: string, storage?: LocalStorage): void => {
          result = true;
        },
        setWindowBackgroundColor: (color: string): void => {
          result1 = true;
        }
      } as UIExtensionContentSession;

      cardDialogExtensionAbility.onSessionCreate(want, session);

      mocker.verify('set', ['mDataWorker', cardDialogExtensionAbility.mDataWorker]).once();
      mocker.verify('sendRequest', ['init', {
        context: cardDialogExtensionAbility.context
      }]).once();
      expect(result).assertTrue();
      expect(result1).assertTrue();

      mocker.clear(cardDialogExtensionAbility.mDataWorker);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('CardDialogExtensionAbility_onSessionCreate_catch', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis().set);
      mocker.mockFunc(cardDialogExtensionAbility.mDataWorker, cardDialogExtensionAbility.mDataWorker.sendRequest);

      let want: Want = {
        parameters: {
          dialogInfo: {
            flag: 'selectNum',
            phoneList: [],
            simList: [],
            lastSimId: -1,
            abilityName: 'com.ohos.sceneboard.systemdialog'
          }
        }
      };

      let result = false;
      let result1 = false;
      let session: UIExtensionContentSession = {
        loadContent: (path: string, storage?: LocalStorage): void => {
          result = true;
        },
        setWindowBackgroundColor: (color: string): void => {
          result1 = true;
        }
      } as UIExtensionContentSession;

      cardDialogExtensionAbility.context = {
        startAbility: (want: Want, options?: StartOptions): Promise<void> =>
        new Promise <void>((resolve: (value: void | PromiseLike<void>) => void,
                            reject: (reason?: BusinessError) => void) => {
          reject({
            code: 1, message: 'error'
          } as BusinessError);
        })
      } as common.UIExtensionContext;

      cardDialogExtensionAbility.onSessionCreate(want, session);

      mocker.verify('set', ['mDataWorker', cardDialogExtensionAbility.mDataWorker]).once();
      mocker.verify('sendRequest', ['init', {
        context: cardDialogExtensionAbility.context
      }]).once();
      expect(result).assertTrue();
      expect(result1).assertTrue();

      mocker.clear(cardDialogExtensionAbility.mDataWorker);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
  })
}