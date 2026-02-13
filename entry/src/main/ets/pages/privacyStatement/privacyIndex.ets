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
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import PrivacyStatement from '../contacts/settings/PrivacyStatement';
import { PrivacyStatementContentTag } from '../../presenter/contact/settings/PrivacyStatementPresenter';
import LooseObject from '../../model/type/LooseObject';
// import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit'

let storage = LocalStorage.getShared()

const TAG = 'PrivacyIndex';


@Entry()
@Component
struct PrivacyIndex {

  @Provide('contactsSettingsNavStack') pathInfos: NavPathStack = new NavPathStack();
  private session: UIExtensionContentSession =
    storage.get<UIExtensionContentSession>('session') as UIExtensionContentSession;

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    const param: LooseObject = {
      contentTag: PrivacyStatementContentTag.ContactPrivacyStatement
    }
    this.pathInfos.pushPathByName('PrivacyStatement', param, false);
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow');
  }

  @Builder
  myRouter(name: string) {
    if (name === 'PrivacyStatement') {
      PrivacyStatement({
        isFromInner: false,
        backPressCallback: () => {
          this.session.sendData({
            'action': 'exit'
          })
          return true;
        }, backgroundColorCustom: $r('app.color.skin_background_secondary')
      });
    }
  }

  build() {
    Navigation(this.pathInfos) {

    }
    .mode(NavigationMode.Stack)
    .navDestination(this.myRouter)
    .height('100%')
    .width('100%')
  }
}