/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { Constants } from '../../data/Constants';
import { HiCarConstants } from '../../data/HiCarConstants';
import HiCarUtil from '../../util/HiCarUtil';
import HiCarCallListPage from './HiCarCallListPage';
import HiCarContactPage from './HiCarContactPage';
import HiCarDialerPage from './HiCarDialerPage';
import { HiLog } from '../../../../../../common';
import IndexPresenter from '../../presenter/IndexPresenter';
import HiCarCallRecordPresenter from '../../presenter/dialer/callRecord/HiCarCallRecordPresenter';
import { CustomizedParams } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import DialerPresenter from '../../presenter/dialer/DialerPresenter';
import { SymbolGlyphModifier } from '@kit.ArkUI';

const TAG = 'HiCarIndex';
const CONTACTS_TAB_SWITCH_EVENT = 'CONTACTS_TAB_SWITCH_EVENT';
const TAB_SWITCHING_DELAY = 20;
const LOAD_CONTACTS_DELAY = 600;
const CONTACT_LIST_BAR_INDEX = 0;

@Component
export struct HiCarIndex {
  private controller: TabsController = new TabsController();
  private tabSwitchParams: CustomizedParams = {
    FLAG: 0,
    ACTION: 0
  };
  @LocalStorageProp(Constants.KEY_WINDOW_AVOID_AREA_HEIGHT_PX) @Watch('onWindowChange') windowAvoidAreaHeightPx: number = 0;
  @LocalStorageProp(Constants.KEY_WINDOW_AVOID_AREA_WIDTH_PX) @Watch('onWindowChange') windowAvoidAreaWidthPx: number = 0;
  @StorageLink(Constants.KEY_WINDOW_WIDTH_PX) @Watch('onWindowChange') windowWidthPx: number = 0;
  @StorageLink(Constants.KEY_WINDOW_HEIGHT_PX) @Watch('onWindowChange') windowHeightPx: number = 0;
  @StorageLink(Constants.KEY_DPI) @Watch('onWindowChange') dpi: number = 0;
  @Link hiCarTabIndex: number;
  @Link bottomTabIndex: number;
  @StorageProp(HiCarConstants.KEY_IS_IN_HICAR) isInHiCar: boolean = false;
  @StorageLink(Constants.KEY_SELECT_CONTACT_ID) selectContactId: string = '';
  @StorageLink(Constants.KEY_SHOW_DIAL_BTN) showDialBtn: boolean = true;
  @Consume('pathInfos') pathInfos: NavPathStack;

  //window窗口切换获取window宽度和高度存在时序问题，保证获取的宽度、高度及避让区域高度宽度正确
  onWindowChange() {
    HiLog.i(TAG, 'onWindowChange.');
    HiCarUtil.getInstance().refreshAttributes(this.windowAvoidAreaHeightPx, this.windowAvoidAreaWidthPx,
      this.getUIContext());
  }

  private getBarWidth(): Length {
    return HiCarUtil.getInstance().getIsBarOnLeft() ? $r('app.float.id_bar_width_hicar') : '100%';
  }

  private getBarHeight(): Length {
    return HiCarUtil.getInstance().getIsBarOnLeft() ? '100%' : $r('app.float.id_height_56');
  }

  private getBarPosition(): BarPosition {
    return HiCarUtil.getInstance().getIsBarOnLeft() ? BarPosition.Start : BarPosition.End;
  }

  private tabBarClick(item: number): void {
    this.selectContactId = '';
    if (item === IndexPresenter.getInstance().callIndex) {
      HiCarCallRecordPresenter.getInstance().setPageShow(true);
    } else {
      HiCarCallRecordPresenter.getInstance().setPageShow(false);
    }
  }

  aboutToAppear(): void {
    HiLog.i(TAG, 'HiCarIndex aboutToAppear.');
    HiCarUtil.getInstance().getHiCarDPI();
    HiCarUtil.getInstance().refreshAttributes(this.windowAvoidAreaHeightPx, this.windowAvoidAreaWidthPx,
      this.getUIContext());
    // 延迟600ms执行，提前初始化联系人列表第一页数据，查询收藏数据，使切换联系人页面，满足加载时延
    setTimeout(() => {
      HiLog.i(TAG, 'setTimeout invoke startPreInit');
      HiCarUtil.getInstance().initFavoriteDataSource();
      HiCarUtil.getInstance().preInitContactList();
    }, LOAD_CONTACTS_DELAY);
    //重置路由
    this.pathInfos.clear();
    //手机的页面重置成默认界面，数据重置
    this.selectContactId = ''
    this.bottomTabIndex = CONTACT_LIST_BAR_INDEX;
    IndexPresenter.getInstance().curIndex = CONTACT_LIST_BAR_INDEX;
    AppStorage.setOrCreate(Constants.KEY_MAIN_TABS_INDEX, CONTACT_LIST_BAR_INDEX);
    this.showDialBtn = true;
    AppStorage.setOrCreate(Constants.KEY_IS_SHOW_CONTACT_SEARCH, false);
    //清空手机输入的电话号码
    DialerPresenter.getInstance().resetTelNumber();
    DialerPresenter.getInstance().editPhoneNumber('');
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'HiCarIndex aboutToDisappear.');
    this.hiCarTabIndex = CONTACT_LIST_BAR_INDEX;
    //清空hicar上输入的电话号码
    DialerPresenter.getInstance().resetTelNumber();
    DialerPresenter.getInstance().editPhoneNumber('');
    HiCarUtil.release();
    HiCarCallRecordPresenter.release();
  }

  build() {
    Column() {
      Tabs({
        barPosition: this.getBarPosition(),
        index: $$this.hiCarTabIndex,
        controller: this.controller
      }) {
        TabContent() {
          HiCarCallListPage()
            .backgroundColor($r('app.color.skin_ohos_id_color_background'))
        }
        .align(Alignment.TopStart)
        .tabBar(new BottomTabBarStyle({ normal: new SymbolGlyphModifier($r('sys.symbol.phone_fill')) },
          $r('app.string.dialer_calllog')))

        TabContent() {
          HiCarContactPage()
            .backgroundColor($r('app.color.skin_ohos_id_color_background'))
        }
        .align(Alignment.TopStart)
        .tabBar(new BottomTabBarStyle({ normal: new SymbolGlyphModifier($r('sys.symbol.person_2_fill')) },
          $r('app.string.contact')))

        TabContent() {
          HiCarDialerPage()
            .backgroundColor($r('app.color.skin_ohos_id_color_background'))
        }
        .align(Alignment.TopStart)
        .tabBar(new BottomTabBarStyle({
          normal: new SymbolGlyphModifier($r('sys.symbol.dial'))
        }, $r('app.string.dial')))
      }
      .width('100%')
      .height('100%')
      .vertical(HiCarUtil.getInstance().getIsBarOnLeft() ? true : false)
      .barMode(BarMode.Fixed)
      .barWidth(this.getBarWidth())
      .barHeight(this.getBarHeight())
      .scrollable(false)
      .animationDuration(0)
      .onTabBarClick((item: number) => {
        HiLog.i(TAG, `hiCarTabIndex onTabBarClick: ${item}`);
        this.tabSwitchParams.FLAG = item + 3;
        DotUtil.getInstance().contactDot(this.tabSwitchParams, CONTACTS_TAB_SWITCH_EVENT);
        setTimeout(() => {
          this.tabBarClick(item);
        }, TAB_SWITCHING_DELAY);
      })
      .onChange((index: number) => {
        HiLog.i(TAG, `Tabs onChange, index == ${index}`);
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: px2vp(this.windowAvoidAreaWidthPx), bottom: px2vp(this.windowAvoidAreaHeightPx) })
  }
}