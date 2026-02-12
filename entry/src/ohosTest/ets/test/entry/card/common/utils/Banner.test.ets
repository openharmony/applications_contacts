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
import Banner from '../../../../../../../main/ets/card/common/utils/Banner';
import { common, Want } from '@kit.AbilityKit';
import { CardDialogInfoType } from '../../../../../../../main/ets/card/type/commonType';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import { rpc } from '@kit.IPCKit';

export default function BannerTest() {
  describe('BannerTest', () => {

    let banner: Banner;

    beforeEach(() => {
      banner = Banner.getInstance();
    })

    it('BannerTest_bannerStart_context_null', 0, () => {
      let num: number = 1;
      let dialogInfo: CardDialogInfoType = {
        flag: 'selectNum',
        phoneList: [],
        simList: [],
        lastSimId: 1,
      };

      let mocker: MockKit = new MockKit();
      let getDefaultCardContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext);
      when(getDefaultCardContext)().afterReturn(null);

      banner.bannerStart(dialogInfo);

      expect(banner.getConnectionId()).assertEqual(num);
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('BannerTest_bannerStart_remote_null', 0, () => {
      let dialogInfo: CardDialogInfoType = {
        flag: 'selectNum',
        phoneList: [],
        simList: [],
        lastSimId: 1,
      };

      let result = false;
      let context: common.FormExtensionContext = {
        connectServiceExtensionAbility: (want: Want, options: common.ConnectOptions) => {
          result = true;
          options.onConnect({
            bundleName: '', abilityName: ''
          }, null);
          options.onDisconnect({
            bundleName: '', abilityName: ''
          });
          options.onFailed(401)
          return 1;
        }
      } as common.FormExtensionContext;

      let mocker: MockKit = new MockKit();
      let getDefaultCardContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext);
      when(getDefaultCardContext)().afterReturn(context);

      banner.bannerStart(dialogInfo);

      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('BannerTest_bannerStart', 0, () => {
      let dialogInfo: CardDialogInfoType = {
        flag: 'selectNum',
        phoneList: [],
        simList: [],
        lastSimId: 1,
      };

      let result = false;
      let context: common.FormExtensionContext = {
        connectServiceExtensionAbility: (want: Want, options: common.ConnectOptions) => {
          result = true;
          options.onConnect({
            bundleName: '', abilityName: ''
          }, new rpc.RemoteObject(''));
          options.onDisconnect({
            bundleName: '', abilityName: ''
          });
          options.onFailed(401)
          return 1;
        }
      } as common.FormExtensionContext;

      let mocker: MockKit = new MockKit();
      let getDefaultCardContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultCardContext);
      when(getDefaultCardContext)().afterReturn(context);

      banner.bannerStart(dialogInfo);

      expect(result).assertTrue();

      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

  })
}