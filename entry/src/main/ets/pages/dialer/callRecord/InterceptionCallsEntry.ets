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
import { HiLog } from '../../../../../../../feature/call/oh_modules/common';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import StringFormatUtil from '../../../util/StringFormatUtil';
import InterceptionCallsRecord from './InterceptionCalls';
import { settings } from '@kit.BasicServicesKit';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';

const TAG = 'InterceptionCallsEntry';
/**
 * InterceptionCalls Entry
 */
let storage = LocalStorage.GetShared()

@Entry(storage)
@Component
export default struct InterceptionCallsEntry {
  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear! ');
    AppStorage.setOrCreate('interceptionCallsSysTime', Number.parseInt(StringFormatUtil.judgeSysTime()));
    CallRecordPresenter.getInstance().limitRefreshInit();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear!');
    CallRecordPresenter.getInstance().limitRefreshUnInit();
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow');
    CallRecordPresenter.getInstance().registerInterceptionCallsDataChangeObserver();
    CallRecordPresenter.getInstance().setInterceptionCallsPageShow(true);

    let timeFormat = settings.getValueSync(ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext() as Context, settings.date.TIME_FORMAT, '12');
     HiLog.i(TAG, 'onPageShow! interceptionCallsSysTime: ' + AppStorage.Get('interceptionCallsSysTime'));
     HiLog.i(TAG, 'onPageShow! SysTime: ' + Number.parseInt(timeFormat));
    if (Number.parseInt(timeFormat) !== AppStorage.Get('interceptionCallsSysTime') as number) {
      HiLog.i(TAG, 'DO requestInterceptionCallsItem cause systemTime changed');
      CallRecordPresenter.getInstance().requestInterceptionCallsItem();
      AppStorage.SetOrCreate('interceptionCallsSysTime', Number.parseInt(
        settings.getValueSync(ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext() as Context, settings.date.TIME_FORMAT, '12')));
    };
  }

  onPageHide() {
    HiLog.i(TAG, 'onPageCover')
    // set interception calls page show
    CallRecordPresenter.getInstance().setInterceptionCallsPageShow(false);
  }

  build() {
    Column() {
      InterceptionCallsRecord()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}