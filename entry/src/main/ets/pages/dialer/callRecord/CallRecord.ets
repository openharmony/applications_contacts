/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

/**
 * call log
 */
import AllRecord from './AllRecord';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import CallRecordPresenter from './../../../presenter/dialer/callRecord/CallRecordPresenter'
import {CallLogTabs} from '../../../component/dialer/CallLogTabs';

const TAG = "CallRecord_Tab";

@Entry
@Component
export default struct CallRecord {
  @State bottomTabIndex: number = 0;
  @State mPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  private controller: TabsController = new TabsController();

  aboutToAppear(){
    HiLog.i(TAG, 'aboutToAppear');
    this.mPresenter.aboutToAppear();
    this.mPresenter.bindUI(()=>{
      this.mPresenter = CallRecordPresenter.getInstance();
    })
  }
  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear');
    this.mPresenter.aboutToDisappear();
  }


  build() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
        CallLogTabs({ controller: this.controller, bottomTabIndex: $bottomTabIndex})

        Tabs({ barPosition: BarPosition.Start, index: this.bottomTabIndex, controller: this.controller }) {
          TabContent() {
            AllRecord({mPresenter:$mPresenter,recordType:0})
          }.align(Alignment.TopStart)

          TabContent() {
            AllRecord({mPresenter:$mPresenter,recordType:1})
          }.align(Alignment.TopStart)

        }
        .onChange((index: number) => {
          this.bottomTabIndex = index
          this.mPresenter.setTabIndex(index);
        })
        .vertical(false)
        .barHeight(0)
        .barWidth(0)
        .barMode(BarMode.Fixed)
        .scrollable(false)
        .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
        .animationDuration(0)
        .zIndex(1)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
  }
}