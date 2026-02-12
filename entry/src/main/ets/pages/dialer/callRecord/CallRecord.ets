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
import { curves, SegmentButtonOptions } from '@kit.ArkUI';
import { ItemRestriction, SegmentButton, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import VoiceMail from '../../speeddial/VoiceMail';
import simCardState, { simId_DEFAULT, simId_ONE, simId_TWO } from '../../../feature/sim/SimCardState';
import { FontScaleState } from '../../../util/fontScaleState';
import BigPhotoCopyUtil from '../../../util/BigPhotoCopyUtil';
import EnvironmentProp from '../../../feature/EnvironmentProp';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';

const TAG = 'CallRecord_Tab';

@Component
export default struct CallRecord {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State bottomTabIndex: number = 0;
  @State mPresenter: CallRecordPresenter = CallRecordPresenter.getInstance();
  @State haveSimCard: boolean = false;
  @Require controller: TabsController;
  @State @Watch('onSegmentButtonIndexChanged') segmentButtonSelectedIndexes: number[] = [0]
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State isShowSegmentBtn: boolean = false;
  @StorageLink('callLogListEmpty') callLogListEmpty: boolean = true;
  @StorageLink('missedListEmpty') missedListEmpty: boolean = true;
  @StorageLink('clearAllRecord') clearAllRecord: boolean = false;
  @StorageLink('isInitViewShow') isInitViewShow: boolean = true;
  @State segmentButtonHeight: number = 56;
  @State segmentButtonOffsetY: number = -this.segmentButtonHeight;
  @StorageProp('fontSizeScale') @Watch('onFontSizeScaleChange') fontSizeScale: number = 0;
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageLink('pasteStatus') pasteStatus: boolean = false;
  private listScroller: ListScroller = new ListScroller();
  private missedScroller: ListScroller = new ListScroller();
  private isPC: boolean = EnvironmentProp.isPC();

  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  @StorageProp('languageConfig') @Watch('languageChange') private language: string = '';

  /**
   * 语言切换后通话记录重新加载
   */
  languageChange() {
    HiLog.i(TAG, `The language is changed, will be refresh`);
    this.mPresenter.updateCallLogDataCreateTime(false);
    this.mPresenter.mAllCallRecordListDataSource.setDataReload(true);
  }

  async aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.haveSimCard = simCardState.haveSimCard;
    this.mPresenter.aboutToAppear();
    this.mPresenter.bindUI((businessStr: string)=>{
      HiLog.w(TAG, businessStr + ' refresh callRecord UI');
      this.mPresenter = CallRecordPresenter.getInstance();
      if (this.isInitViewShow && this.mPresenter.mAllCallRecordListDataSource.totalCount() > 0) {
        this.isInitViewShow = false;
      }
      // 通话记录赋值
      let callLogIsEmpty = this.mPresenter.mAllCallRecordListDataSource.totalCount() <= 0;
      if (this.callLogListEmpty != callLogIsEmpty) {
        this.callLogListEmpty = callLogIsEmpty
      }
      let missLogIsEmpty = this.mPresenter.mMissCallRecordListDataSource.totalCount() <= 0;
      if (this.missedListEmpty != missLogIsEmpty) {
        this.missedListEmpty = missLogIsEmpty
      }
      if (!this.callLogListEmpty || !this.missedListEmpty) {
        this.clearAllRecord = false;
      }
      HiLog.w(TAG, `bindUI  callLogListEmpty: ${this.callLogListEmpty}, missedListEmpty: ${this.missedListEmpty}, ` +
        `clearAllRecord: ${this.clearAllRecord}, isInitViewShow: ${this.isInitViewShow}`);
    })
    this.mPresenter.refreshState('callRecord aboutToAppear');
    AppStorage.SetOrCreate('recordType', 0);
    this.onFontSizeScaleChange();
    // 联系人大头像云同步需求上线之后，在版本升级后，用户第一次打开联系人应用时，当通话记录加载完成之后
    // 需要触发一次存量联系人大头像文件拷贝操作：之前的联系人大头像文件存于联系人应用沙箱下，现在需要拷贝至群组沙箱下，用于云同步
    // 此操作只操作一次，只针对存量用户
    try {
      await BigPhotoCopyUtil.getInstance().copyPhotoFile();
    } catch (error) {
      HiLog.e(TAG, `copyPhotoFile error: ${error?.message}`);
    }
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear');
    if (EnvironmentProp.isPC()) {
      return;
    }
    this.mPresenter.aboutToDisappear();
  }

  onSegmentButtonIndexChanged() {
    let seletedIndex: number = this.segmentButtonSelectedIndexes[0];
    this.controller.changeIndex(seletedIndex);
  }

  onSegmentBtnChange() {
    if (!this.isShowSegmentBtn) {
      if (this.bottomTabIndex === 0) {
        this.segmentButtonOffsetY = -this.segmentButtonHeight
      } else {
        this.isShowSegmentBtn = true;
      }
    } else {
      animateTo({ curve: curves.responsiveSpringMotion() }, () => {
        this.segmentButtonOffsetY = 0;
      });
    }
  }

  onFontSizeScaleChange() {
    if (FontScaleState.isStandardGeer(this.fontSizeScale)) {
      this.segmentButtonHeight = 56;
    } else {
      // 最大放大两倍 20 标准状态下文本的高度，16标准状态文本距离segmentbutton的上下边距之和
      // 16 semngt组件的上下padding之和， 4 semngt组件距离segmentbutton的内间距之和
      this.segmentButtonHeight = (20 + 16) * Math.min(FontScaleState.fontScale, 2) + 16 + 4
    }
    this.segmentButtonOffsetY = -this.segmentButtonHeight;
  }

  @State singleSelectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: this.haveSimCard ? [{ text: $r('app.string.all_call_logs') }, { text: $r('app.string.missed_call') }, {
      text: $r('app.string.voicemail')
    }] : [{ text: $r('app.string.all_call_logs') },
      { text: $r('app.string.missed_call') }] as ItemRestriction<SegmentButtonTextItem>,
    textPadding: {
      left: $r('app.float.id_card_margin_large'),
      right: $r('app.float.id_card_margin_large'),
      bottom: $r('app.float.dialer_common_very_small_margin2'),
      top: $r('app.float.dialer_common_very_small_margin2'),
    },
    selectedFontSize: $r('sys.float.Body_M'),
    selectedFontColor: $r('app.color.skin_ohos_id_color_text_primary'),
    selectedBackgroundColor: $r('app.color.skin_ohos_id_color_foreground_contrary_disable'),
    fontSize: $r('sys.float.Body_M'),
    fontColor: $r('app.color.skin_ohos_id_color_text_secondary'),
    backgroundColor: $r('app.color.skin_ohos_id_color_button_normal'),
    fontWeight: FontWeight.Medium,
    selectedFontWeight: FontWeight.Medium,
  })

  build() {
    NavDestination() {
      Scroll(){
        Column() {
          if (EnvironmentProp.isPC() && this.isShowSegmentBtn) {
            SegmentButton({
              options: this.singleSelectCapsuleOptions,
              selectedIndexes: $segmentButtonSelectedIndexes
            })
              .defaultFocus(false)
              .focusable(false)
              .height(this.isVerde ? 0 : 'auto')
              .padding(this.isVerde ? 0 : {
                top: $r('app.float.id_card_margin_large'),
                bottom: $r('app.float.id_card_margin_large'),
                left: this.spaceLR,
                right: this.spaceLR
              })
              .id('callRecord_contacts_allCalls_segmentButton')
              .animation({ curve: curves.interpolatingSpring(0, 1, 420, 41) })
          }
          Tabs({ barPosition: BarPosition.Start, index: $$this.bottomTabIndex, controller: this.controller }) {
            TabContent() {
              // 全部通话
              AllRecord({
                mPresenter: $mPresenter,
                recordType: 0,
                segmentButtonOffsetY: this.segmentButtonOffsetY,
                segmentButtonHeight: this.segmentButtonHeight,
                isShowSegmentBtn: this.isShowSegmentBtn,
                listScroller: this.listScroller
              })
            }
            .align(Alignment.TopStart)
            .clip(this.isPC ? true : false)
            TabContent() {
              // 未接来电
              AllRecord({
                mPresenter: $mPresenter,
                recordType: 1,
                segmentButtonOffsetY: this.segmentButtonOffsetY,
                segmentButtonHeight: this.segmentButtonHeight,
                isShowSegmentBtn: this.isShowSegmentBtn,
                listScroller: this.missedScroller
              })
            }
            .clip(this.isPC ? true : false)
            .align(Alignment.TopStart)
            if (this.haveSimCard) {
              TabContent() {
                // 语音信箱
                VoiceMail()
              }
            }
          }
          .clip(this.isPC ? true : false)
          .id('callRecord_contacts_selectTab_tabs')
          .onChange((index: number) => {
            HiLog.w(TAG, 'Tabs onChange, index == ' + index);
            this.mPresenter.setTabIndex(index);
            AppStorage.SetOrCreate('recordType', index);
            AppStorage.SetOrCreate('clearAllRecord', false);
          })
          .vertical(false)
          .barHeight(0)
          .barMode(BarMode.Scrollable)
          .scrollable(false)
          .animationDuration(0)
          .zIndex(1)
          .flexShrink(1)
        }
      }
    }
    .backgroundColor(Color.Transparent)
    .hideTitleBar(true)
  }

  onDidBuild(): void {
    HiLog.w(TAG, `CallRecord onDidBuild`);
  }
}