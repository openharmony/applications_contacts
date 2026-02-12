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

import { HiLog } from '../../../../../common';
import { RoamingManager } from '../feature/roaming/RoamingManager';
import { call } from '@kit.TelephonyKit';
import { CallLogSearchBo } from '../model/bean/CallLogSearchBo';
import { simId_ONE, simId_TWO } from '../feature/sim/SimCardState';
import { Constants } from '../data/Constants';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { ContactReturnObj, CustomizedParams, PageLimit, ReqData, RequestParam } from '../model/type';
import { ArrayUtil } from '../../../../../common/src/main/ets/util/ArrayUtil';
import { CallLog } from '../../../../../feature/call/src/main/ets/entity/CallLog';
import DotUtil from '../util/DotUtil';
import { HiCarConstants } from '../data/HiCarConstants';
import { ContactVo } from '../model/bean/ContactVo';
import HiCarContactListDataSource from '../model/bean/HiCarContactListDataSource';
import { FavoriteBean } from '../model/bean/FavoriteBean';
import FavoriteDataSource from '../model/bean/FavoriteDataSource';
import { LimitRefreshDataUtil } from './LimitRefreshDataUtil';
import { display } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';

const TAG = 'HiCarUtil';
const CALL_EVENT = 'CALL_EVENT';

export default class HiCarUtil {
  // 单例对象
  private static instance?: HiCarUtil;
  private static LEN_280 = 280;
  private static LEN_360 = 360;
  private static MARGIN_16 = 16;
  private static BUTTON_HEIGHT_32 = 32;
  private static BUTTON_HEIGHT_40 = 40;
  private static BUTTON_HEIGHT_48 = 48;
  private static FONT_SIZE_24 = '24vp';
  private static FONT_SIZE_26 = '26vp';
  private static BREAKPOINT_S = 600;
  private static BREAKPOINT_M = 840;
  private static BREAKPOINT_L = 1440;
  private static SMALL_DEVICE_MARGIN = 16;
  private static SMALL_DEVICE_GUTTER = 8;
  private static MEDIUM_DEVICE_MARGIN = 24;
  private static MEDIUM_DEVICE_GUTTER = 12;
  private static LARGE_DEVICE_MARGIN = 32;
  private static LARGE_DEVICE_GUTTER = 16;
  private static XLARGE_DEVICE_MARGIN = 40;
  private static XLARGE_DEVICE_GUTTER = 20;
  private static TAB_HEIGHT = 56;
  private static TAB_WIDTH = 88;
  private windowDisplayAreaHeightPx: number = 0;
  private windowDisplayAreaWidthPx: number = 0;
  private isBarOnLeft: boolean = true;
  private isDialButtonOnRight: boolean = false;
  private tabContentWidth: number = 0;
  private dialPadWidth: number = 0;
  private dialPadButtonHeight: number = 0;
  private dialFontSize: string = '';
  private tabContentPadding: number = 0;
  private contactSearchBoxWidth: number = 0;
  private hiCarContactListDataSource: HiCarContactListDataSource = new HiCarContactListDataSource();
  private favoriteDataSource: FavoriteDataSource = new FavoriteDataSource();

  public static getInstance(): HiCarUtil {
    if (HiCarUtil.instance === undefined) {
      HiCarUtil.instance = new HiCarUtil();
    }
    return HiCarUtil.instance;
  }

  public getWindowDisplayAreaWidthPx(): number {
    return this.windowDisplayAreaWidthPx;
  }

  public getWindowDisplayAreaHeightPx(): number {
    return this.windowDisplayAreaHeightPx;
  }

  public getIsBarOnLeft(): boolean {
    return this.isBarOnLeft;
  }

  public getIsDialButtonOnRight(): boolean {
    return this.isDialButtonOnRight;
  }

  public getTabContentWidth(): number {
    return this.tabContentWidth;
  }

  public getDialPadWidth(): number {
    return this.dialPadWidth;
  }

  public getDialPadButtonHeight(): number {
    return this.dialPadButtonHeight;
  }

  public getDialFontSize(): string {
    return this.dialFontSize;
  }

  public getTabContentPadding(): number {
    return this.tabContentPadding;
  }

  public getContactSearchBoxWidth(): number {
    return this.contactSearchBoxWidth;
  }

  public getHiCarContactListDataSource(): HiCarContactListDataSource {
    return this.hiCarContactListDataSource;
  }

  public getFavoriteDataSource(): FavoriteDataSource {
    return this.favoriteDataSource;
  }

  public getHiCarDPI(): void {
    display.getAllDisplays().then((data) => {
      for (let index = 0; index < data.length; index++) {
        const element = data[index];
        if (element.name === HiCarConstants.HI_CAR) {
          AppStorage.setOrCreate(Constants.KEY_DPI, element.densityPixels);
          return;
        }
      }
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `getAllDisplays error: ${err.message}`);
    })
  }

  public px2vp(px: number): number {
    const dpi: number | undefined = AppStorage.get(Constants.KEY_DPI);
    if (dpi === undefined || dpi === 0) {
      HiLog.w(TAG, 'Failed to obtain the HiCar DPI.');
      return -1;
    }
    return px / dpi;
  }

  //刷新属性
  public refreshAttributes(windowAvoidAreaHeightPx: number, windowAvoidAreaWidthPx: number, context?: UIContext): void {
    HiLog.i(TAG, 'Do refreshAttributes.');
    if (context === undefined) {
      HiLog.w(TAG, 'Failed to obtain context.');
      return;
    }
    const windowWidthPx = AppStorage.get(Constants.KEY_WINDOW_WIDTH_PX) as number;
    const windowHeightPx = AppStorage.get(Constants.KEY_WINDOW_HEIGHT_PX) as number;
    this.windowDisplayAreaWidthPx = windowWidthPx - windowAvoidAreaWidthPx;
    this.windowDisplayAreaHeightPx = windowHeightPx - windowAvoidAreaHeightPx;
    if (this.windowDisplayAreaHeightPx < this.windowDisplayAreaWidthPx) {
      this.isBarOnLeft = true;
    } else {
      this.isBarOnLeft = false;
    }
    const _height = this.px2vp(this.windowDisplayAreaHeightPx) - (this.isBarOnLeft ? 0 : HiCarUtil.TAB_HEIGHT);
    if (_height < HiCarUtil.LEN_360 && this.px2vp(windowWidthPx) > HiCarUtil.BREAKPOINT_S) {
      this.isDialButtonOnRight = true;
    } else {
      this.isDialButtonOnRight = false;
    }
    this.tabContentWidth = this.refreshTabContentWidth(windowWidthPx, context);
    this.contactSearchBoxWidth = this.refreshContactSearchBoxWidth(windowWidthPx, context);
    this.dialPadWidth = this.refreshDialPadWidth(windowWidthPx, context);
    this.dialPadButtonHeight = this.refreshDialPadButtonHeight(this.windowDisplayAreaHeightPx, context);
    this.dialFontSize = this.refreshDialFontSize(this.windowDisplayAreaHeightPx, context);
    this.tabContentPadding = (this.px2vp(this.windowDisplayAreaWidthPx) - (this.isBarOnLeft ? HiCarUtil.TAB_WIDTH :
      0) - this.tabContentWidth) / 2;
  }

  /**
   * 获取TabContent显示的宽度：：4栅格设备，TabContent显示区域距离左右边界距离16vp;8栅格设备宽度占6栅格，12栅格占10栅格
   *
   * @returns TabContent区域的宽度，单位vp
   */
  public refreshTabContentWidth(windowWidthPx: number, context: UIContext): number {
    let _width = 0;
    let tabContentWidth = 0;
    const windowWidthVp = this.px2vp(windowWidthPx);
    if (this.isBarOnLeft) {
      _width = windowWidthVp - HiCarUtil.TAB_WIDTH;
    } else {
      _width = windowWidthVp;
    }
    if (windowWidthVp < HiCarUtil.BREAKPOINT_S) {
      //4栅格
      tabContentWidth = _width - 2 * HiCarUtil.MARGIN_16;
    } else if (windowWidthVp < HiCarUtil.BREAKPOINT_M) {
      //8栅格
      tabContentWidth = (windowWidthVp - HiCarUtil.MEDIUM_DEVICE_MARGIN * 2 - HiCarUtil.MEDIUM_DEVICE_GUTTER * 7) / 8 *
        6 + 5 * HiCarUtil.MEDIUM_DEVICE_GUTTER;
    } else if (windowWidthVp < HiCarUtil.BREAKPOINT_L) {
      //12栅格
      tabContentWidth = (windowWidthVp - HiCarUtil.LARGE_DEVICE_MARGIN * 2 - HiCarUtil.LARGE_DEVICE_GUTTER * 11) / 12 *
        10 + 9 * HiCarUtil.LARGE_DEVICE_GUTTER;
    } else {
      tabContentWidth = (windowWidthVp - HiCarUtil.XLARGE_DEVICE_MARGIN * 2 - HiCarUtil.XLARGE_DEVICE_GUTTER * 11) /
        12 * 10 + 9 * HiCarUtil.XLARGE_DEVICE_GUTTER;
    }
    return tabContentWidth;
  }

  /**
   * 获取联系人搜索界面搜索框的宽度：4栅格设备，显示区域距离左右边界距离16vp;8栅格设备宽度占6栅格，12栅格占10栅格
   *
   * @returns 联系人搜索界面搜索框的宽度，单位vp
   */
  public refreshContactSearchBoxWidth(windowWidthPx: number, context: UIContext): number {
    let contactSearchBoxWidth = 0;
    const windowWidthVp = this.px2vp(windowWidthPx);
    if (windowWidthVp < HiCarUtil.BREAKPOINT_S) {
      //4栅格
      contactSearchBoxWidth = windowWidthVp - 2 * HiCarUtil.MARGIN_16;
    } else if (windowWidthVp < HiCarUtil.BREAKPOINT_M) {
      //8栅格
      contactSearchBoxWidth = (windowWidthVp - HiCarUtil.MEDIUM_DEVICE_MARGIN * 2 - HiCarUtil.MEDIUM_DEVICE_GUTTER *
        7) / 8 * 6 + 5 * HiCarUtil.MEDIUM_DEVICE_GUTTER;
    } else if (windowWidthVp < HiCarUtil.BREAKPOINT_L) {
      //12栅格
      contactSearchBoxWidth = (windowWidthVp - HiCarUtil.LARGE_DEVICE_MARGIN * 2 - HiCarUtil.LARGE_DEVICE_GUTTER * 11) /
        12 * 10 + 9 * HiCarUtil.LARGE_DEVICE_GUTTER;
    } else {
      contactSearchBoxWidth = (windowWidthVp - HiCarUtil.XLARGE_DEVICE_MARGIN * 2 - HiCarUtil.XLARGE_DEVICE_GUTTER *
        11) / 12 * 10 + 9 * HiCarUtil.XLARGE_DEVICE_GUTTER;
    }
    return contactSearchBoxWidth;
  }

  /**
   * 获取拨号盘总宽度：4栅格设备，占3栅格；8栅格设备宽度占5栅格，12栅格占7栅格
   *
   * @returns 拨号盘的整体宽度，单位vp
   */
  public refreshDialPadWidth(windowWidthPx: number, context: UIContext): number {
    let dialPadWidth = 0;
    const windowWidthVp = this.px2vp(windowWidthPx);
    if (windowWidthVp < HiCarUtil.BREAKPOINT_S) {
      //4栅格
      dialPadWidth = (windowWidthVp - HiCarUtil.SMALL_DEVICE_MARGIN * 2 - HiCarUtil.SMALL_DEVICE_GUTTER * 3) / 4 * 3 +
        2 * HiCarUtil.SMALL_DEVICE_GUTTER;
    } else if (windowWidthVp < HiCarUtil.BREAKPOINT_M) {
      //8栅格
      dialPadWidth = (windowWidthVp - HiCarUtil.MEDIUM_DEVICE_MARGIN * 2 - HiCarUtil.MEDIUM_DEVICE_GUTTER * 7) / 8 * 5 +
        4 * HiCarUtil.MEDIUM_DEVICE_GUTTER;
    } else if (windowWidthVp < HiCarUtil.BREAKPOINT_L) {
      //12栅格
      dialPadWidth = (windowWidthVp - HiCarUtil.LARGE_DEVICE_MARGIN * 2 - HiCarUtil.LARGE_DEVICE_GUTTER * 11) / 12 * 7 +
        6 * HiCarUtil.LARGE_DEVICE_GUTTER;
    } else {
      dialPadWidth = (windowWidthVp - HiCarUtil.XLARGE_DEVICE_MARGIN * 2 - HiCarUtil.XLARGE_DEVICE_GUTTER * 11) / 12 *
        7 + 6 * HiCarUtil.XLARGE_DEVICE_GUTTER;
    }
    return dialPadWidth;
  }

  /**
   * 获取拨号盘单个按钮高度
   *
   * @returns 单位vp
   */
  public refreshDialPadButtonHeight(windowDisplayAreaHeightPx: number, context: UIContext): number {
    let buttonHeight = 0;
    const windowDisplayAreaHeightVp = this.px2vp(windowDisplayAreaHeightPx);
    if (windowDisplayAreaHeightVp < HiCarUtil.LEN_280) {
      buttonHeight = HiCarUtil.BUTTON_HEIGHT_32;
    } else if (windowDisplayAreaHeightVp <= HiCarUtil.LEN_360) {
      buttonHeight = HiCarUtil.BUTTON_HEIGHT_40;
    } else {
      buttonHeight = HiCarUtil.BUTTON_HEIGHT_48;
    }
    return buttonHeight;
  }

  /**
   * 获取拨号盘单个按钮内字体在不同尺寸的大小
   *
   * @returns 单位vp
   */
  public refreshDialFontSize(windowDisplayAreaHeightPx: number, context: UIContext): string {
    let fontSize = '24';
    const windowDisplayAreaHeightVp = this.px2vp(windowDisplayAreaHeightPx);
    if (windowDisplayAreaHeightVp < HiCarUtil.LEN_280) {
      fontSize = HiCarUtil.FONT_SIZE_24;
    } else if (windowDisplayAreaHeightVp <= HiCarUtil.LEN_360) {
      fontSize = HiCarUtil.FONT_SIZE_24;
    } else {
      fontSize = HiCarUtil.FONT_SIZE_26;
    }
    return fontSize;
  }

  public static release(): void {
    HiCarUtil.instance = undefined;
  }

  /**
   * 1双卡情况下，设置了默认拨号卡，点击联系人使用默认号码拨号；2双卡情况下，没设置了默认拨号卡，使用传入的卡号拨号
   */
  public dialClick(uiContext: UIContext, phoneNum: string, haveMultiSimCard: boolean, defaultSlot: number,
                   slotId?: number): void {
    if (call.hasVoiceCapability()) {
      CallLogSearchBo.getInstance().refreshCallChangeFlag();
      if (haveMultiSimCard) {
        // 1双卡情况下，设置了默认拨号卡，点击联系人使用默认号码拨号
        if (defaultSlot === simId_ONE || defaultSlot === simId_TWO) {
          HiLog.i(TAG, 'Dial using default number.');
          RoamingManager.getInstance().handleRoaming(uiContext, phoneNum, {
            accountId: defaultSlot
          });
          return;
        }
        //2双卡情况下，没设置了默认拨号卡，使用传入的卡号拨号
        RoamingManager.getInstance().handleRoaming(uiContext, phoneNum, {
          accountId: slotId
        });
        HiLog.i(TAG, 'Dial using slotId.');
      } else {
        //单卡直接拨号
        RoamingManager.getInstance().handleRoaming(uiContext, phoneNum);
        HiLog.i(TAG, 'Single calling card.');
      }
    }
  }

  public getDialPadHeight(): number {
    return this.dialPadButtonHeight * 4 + 3 * HiCarConstants.DIAL_BUTTON_MARGIN;
  }

  public getButtonWidth(): number {
    return (this.dialPadWidth - 2 * HiCarConstants.DIAL_BUTTON_MARGIN) / 3;
  }

  /**
   * 根据contactId查询数据库获取联系人电话号码并拨号
   */
  public contactDialingByContactId(uiContext: UIContext, contactId: string, haveMultiSimCard: boolean,
                                   defaultSlot: number, enc: number): void {
    let firstUsedSlotId: number = 0;
    let callParams: CustomizedParams = {
      ENC: enc,
      SLOT: 0,
      ISMULTISIMCARD: 0
    };
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactById', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        contactId: contactId
      }, (result: ContactReturnObj) => {
        if (result.data === undefined) {
          HiLog.e(TAG, `Contactid is not exist.`);
          return;
        }
        if (ArrayUtil.isEmpty(result.data.phones)) {
          HiLog.e(TAG, `Contact phone is not exist.`);
          return;
        }
        const phoneNum = result.data.phones[0].num;
        //单卡
        if (!haveMultiSimCard) {
          RoamingManager.getInstance().handleRoaming(uiContext, phoneNum);
          DotUtil.getInstance().contactDot(callParams, CALL_EVENT);
          HiLog.i(TAG, 'Single calling card.');
          return;
        }
        //双卡情况：与联系人第一次通话使用的卡号，无通话记录默认卡一
        const numbers: string[] = [phoneNum];
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('findByNumberIn', {
          actionData: {
            context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
            numbers: numbers,
            limit: 1,
            page: 1
          }
        }, (resultList: CallLog[]) => {
          if (resultList === undefined) {
            HiLog.e(TAG, 'Failed to query call records.')
            return;
          }
          const temp = resultList.pop()?.simId;
          if (temp === undefined) {
            HiLog.i(TAG, 'No call records');
          } else {
            firstUsedSlotId = temp;
          }
          this.dialClick(uiContext, phoneNum, haveMultiSimCard, defaultSlot, firstUsedSlotId);
          callParams.ISMULTISIMCARD = 1;
          callParams.SLOT = (defaultSlot === simId_ONE || defaultSlot === simId_TWO) ? defaultSlot : firstUsedSlotId;
          DotUtil.getInstance().contactDot(callParams, CALL_EVENT);
        });
      });
  }

  /**
   * 进入联系人列表前，先查询第一页数据，使进入联系人列表时，加载时延达标
   */
  public preInitContactList(): void {
    HiLog.i(TAG, 'enter preInitContactList');
    // 提前获取前10条数据，铺满一页
    const actionData: PageLimit = {
      page: 1,
      limit: 10
    };
    const reqData: ReqData<PageLimit> = {
      actionData: actionData
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllContact', reqData, (result: ContactVo[]) => {
        if (this.hiCarContactListDataSource.contactList.length === 0 &&
          result.length > 0) {
          HiLog.i(TAG, 'pre init contact list.');
          this.hiCarContactListDataSource.refresh(0, result, true);
        }
      });
  }

  /**
   * 初始化联系人列表
   */
  public initContactList(): void {
    HiLog.i(TAG, 'init contact list.');
    const limitDataRefresh: LimitRefreshDataUtil<PageLimit, ContactVo[]> =
      new LimitRefreshDataUtil<PageLimit, ContactVo[]>('getAllContact', (page: number, limit: number, result: ContactVo[]) => {
        let isEnd: boolean = result.length < limit;
        HiLog.i(TAG, `getAllContact refreshPage ${page}, length is: ${result.length}, isEnd is ${isEnd}`);
        this.hiCarContactListDataSource.refresh(ArrayUtil.getOffsetForSession(page), result, isEnd);
        return isEnd;
      })
    limitDataRefresh.requestItem();
  }

  /**
   * 初始化收藏数据库
   */
  public initFavoriteDataSource(): void {
    const actionData: Record<string, number> = {};
    actionData.favorite = 1;
    const requestParam: RequestParam<Record<string, number>> = {
      actionData: actionData,
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getAllFavorite', requestParam, (result: FavoriteBean[]) => {
        HiLog.i(TAG, 'refreshFavorite sc.');
        this.favoriteDataSource.refresh(result);
      })
  }
}