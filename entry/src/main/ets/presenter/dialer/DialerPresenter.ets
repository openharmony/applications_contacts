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
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { DynamicLoader } from '../../../../../../common/src/main/ets/util/DynamicLoader';
import audio from '@ohos.multimedia.audio';
import observer from '@ohos.telephony.observer';
import PreferencesUtil from '../../util/PreferencesUtil';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import CallRecordListDataSource from '../../model/bean/CallRecordListDataSource';
import performanceMonitor from '@ohos.arkui.performanceMonitor';
import call from '@ohos.telephony.call';
import {
  CustomizedParams,
  DialerSearchResultType,
  RecorderLog,
  SingleSelectContact,
  SpeedDialItem
} from '../../model/type';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import { queryAirPlaneStatus } from '../../model/AirplaneModel';
import VoicemailManager from '../../feature/sim/VoicemailManager';
import common from '@ohos.app.ability.common';
import { ArrayUtil, sharedPreferencesUtils } from '../../../../../../feature/call/oh_modules/common';
import { updateDialerSearchList, updateDialerSearchListForDbAndMixSearch } from '../../../../../../feature/contact/src/main/ets/repo/DialerRepoTask';
import taskpool from '@ohos.taskpool';
import sim from '@ohos.telephony.sim';
import { DSDS_MODE_V2 } from '../../component/mutisim/DsdaConstants';
import { CallLogTemp } from '../../../../../../feature/call/src/main/ets/entity/CallLogTemp';
import { SelectDialogBuilder } from '../../pages/dialog/SelectSimIdDialog';
import { CallLog } from '../../../../../../feature/call';
import DotUtil from '../../util/DotUtil';
import { pasteboard, settings, systemParameter } from '@kit.BasicServicesKit';
import { BusinessError } from '@ohos.base';
import { CallLogSearchBo } from '../../model/bean/CallLogSearchBo';
import { simId_ONE, simId_TWO } from '../../feature/sim/SimCardState';
import CallRecordPresenter from './callRecord/CallRecordPresenter';
import DialerConstant from '../../data/DialerConstant';
import { RoamingManager } from '../../feature/roaming/RoamingManager';
import { registerCallStateListener, unregisterCallStateListener } from '../../model/CallStateModel';
import dotCommon, { faultContactParams, videoCallParams } from '../../util/DotCommon';
import SimManager from '../../feature/sim/SimManager';
import deviceInfo from '@ohos.deviceInfo';
import DeviceConstant from '../../data/DeviceConstant';
import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { media } from '@kit.MediaKit';
import { Constants } from '../../data/Constants';
import { preferences } from '@kit.ArkData';
import IndexPresenter from '../IndexPresenter';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import { AppStorageConstant } from '../../../../../../common/src/main/ets/AppStorageConstant';
import { ContactPickerParam } from '../../model/type/ContactParams';
import EnvironmentProp from '../../feature/EnvironmentProp';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { ResourceUtil } from '../../util/ResourceUtil';
import TextUtils from '../../../../../../common/src/main/ets/util/TextUtils';
import ContactListPresenter from '../contact/ContactListPresenter';


const TAG = 'DialerPresenter';
const DIALPAD_TOUCH_OHOS_TONE = '1';
const DIALPAD_TOUCH_PIANO_TONE = '2';
const SECRET_CODE_START_TYPE_ONE: string = '*#*#';
const SECRET_CODE_START_TYPE_TWO: string = '*#';
const SECRET_CODE_END_TYPE_ONE: string = '#*#*';
const SECRET_CODE_END_TYPE_TWO: string = '#';
const SECRET_CODE_END_TYPE_THREE: string = '*';
const RUN_MODE: string = 'const.runmode';
const FACTORY_MODE: string = 'factory';
const SECRET_CODE_ONE: string = '*#*#19467328#*#*';
const SECRET_CODE_TWO: string = '#1#';
const SECRET_CODE_THREE: string = '*#28460';
const SECRET_CODE_MMI_IMEI_DISPLAY: string = '*#06#';

export const CALL_LOG_SEARCH_MIN: number = 3;

const PAGE_FLAG: string = 'callSetting';
const BUNDLE_NAME: string = 'com.ohos.callsetting';
const ABILITY_NAME: string = 'com.ohos.callsetting.CallSettingAbility';
const ENTITIES: string = 'entity.system.home';
const RECORDER_BUNDLE_NAME: string = 'com.ohos.soundrecorder';
const RECORDER_ABILITY_NAME: string = 'MainAbility';
const CALL_EVENT: string = 'CALL_EVENT';
const SPEED_DIAL_DIALOG_EVENT: string = 'SPEED_DIAL_DIALOG_EVENT';
const PRESS_DIALER_EVENT = 'PRESS_DIALER_EVENT';
const regex = /^[0-9*#+,;]+$/;
const DIALER_SEARCH_LENGTH_ONE = 1;
const DIALER_SEARCH_LENGTH_THREE = 3;
const DIALER_SEARCH_OFFSET = 100;
const DIALER_DB_SEARCH_LIMIT = 5000;

// 超过最大长度，不需要查询归属地，+8618515009431  len=14，有归属地；再加一位：15，需要查询归属地，刷新归属地信息为空；
// 长度大于20，不需要查询归属地了 ip前缀(17900)+手机号
export const QUERY_LOCATION_PHONE_NUMBER_MAX_LEN = 20;

// 号码长度小于2，不需要查询归属地
export const QUERY_LOCATION_PHONE_NUMBER_MIN_LEN = 2;

const DELAY_TIME: number = 50;

const DIAL_PAD_CONTACT_SEARCH_EVENT = 'DIAL_PAD_CONTACT_SEARCH_EVENT';

export default class DialerPresenter {
  // 设计稿上圆角都是16vp
  public static RADIUS_SIZE: number = 32;
  public isShowBtn: boolean = true;
  public task?: taskpool.Task;
  public taskForDbAndMixSearch?: taskpool.Task;
  public countNumber: number = 0;
  public contactsCountNumbers: number = 0;
  public teleCountNumbers: number = 0;
  // 融合搜联系人库搜索结果处理后数据长度
  public contactsResultLength: number = 0;
  // 用于对含有姓名的联系人分页查询做去重
  public searchContactNameUnique: string[] = [];
  // 用于去重分页查询中陌生联系人通话记录结果
  public searchPhoneNumberUnique: string[] = [];
  public pathInfos?: NavPathStack;
  private static mPresenter: DialerPresenter | null;
  private _isCallStateChangeObserved = false;
  public readonly NUM_TEXT_MAX_LENGTH = 20;
  public readonly NUM_TEXT_MAXSIZE_LENGTH = 16;
  public readonly NUM_TEXT_FONT_SIZE_MAX = 38;
  public readonly NUM_TEXT_FONT_SIZE_MIN = 20;
  private timer: number | null = null;
  //Indicates whether to display the dial plate.
  public btnShow: boolean = true;
  public isEmergencyNum: boolean = false;
  public tele_number: string = '';
  public all_number: string = '';
  public textSelectStart: number = -1;
  public textSelectEnd: number = -1;
  public afterActionCaret: number[] = [0, 0];
  public setSpeedNumber: string = '';
  // 是否展示暗码弹框
  public isSecretCodeDialog: boolean = false;
  public serialPixelMap?: image.PixelMap;
  public eidPixelMap?: image.PixelMap;
  public textController: TextInputController = new TextInputController();
  public noSimCardDialogController?: CustomDialogController | null;
  public airplaneVoiceAlertDialogController?: CustomDialogController | null;
  public airplaneSpeedAlertDialogController?: CustomDialogController | null;
  public notSetSpeedDialDialogController?: CustomDialogController | null;
  public notSetVoicemailDialogController?: CustomDialogController | null;
  public secretCodeDialogController?: CustomDialogController | null;
  // Default value should be DSDS mode
  public dsdsMode: number = DSDS_MODE_V2;
  public multiDialingCallConflicts: boolean = false;
  public moveY: number = 0;
  public buttonMoveY: number = 0;
  public dialerButtonWidth = '60vp';
  public dialerButtonWidthInMulti: number = 0;
  public phoneWidth: number = 0;
  public dialerRadius = 24;
  public refreshView?: boolean;
  public callBtnClick?: boolean;
  public secretCode: string = '';
  public mAllCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  public dialerSearchList: Array<CallLogTemp> = [];
  public clearFlag?: boolean;
  private taskId: number = -1;
  private voicemailManager: VoicemailManager = new VoicemailManager();
  public myAccountantsModel: SingleSelectContact | undefined;
  public serialStr: string = '';
  public eidStr: string = '';
  public pixelMapArr: Array<PixelMap> = [];
  public imeiStrArr: string[] = [];
  public isShowImeiPanel: boolean = false;
  public sizeValue: string = '{"height": 0}';
  private static foregroundCallBack?: () => void;
  private mSoundPoolDescriptor?: resourceManager.RawFileDescriptor;
  private mSoundPool?: media.SoundPool;
  public soundIdList = new Map<String, number>();
  private timerId: number = -1;
  private audioRendererInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_ENFORCED_TONE,
    rendererFlags: 1
  };
  private readonly NUM_SOUND_STREAMS: number = 12;
  public isKeyboardInput: boolean = false;
  builder: SelectDialogBuilder = {
    title: '',
    multiSimCardItems: [{
      name: '',
      img: $r('sys.symbol.phone_badge_1'),
    }, {
      name: '',
      img: $r('sys.symbol.phone_badge_2'),
    }],
  };
  public callParams: CustomizedParams = {
    ENC: 7,
    SLOT: 0,
    ISMULTISIMCARD: 0
  };
  public customizedParams: CustomizedParams = {};
  public speedDialDialog: CustomizedParams = {
    ISSET: 0
  }
  public onCallsChange = () => {
    HiLog.w(TAG, 'onCallsChange refresh');
    CallRecordPresenter.getInstance().initStarted = false;
  }
  private searchCustomParams: CustomizedParams = {};

  static getInstance(): DialerPresenter {
    if (DialerPresenter.mPresenter == null) {
      DialerPresenter.mPresenter = new DialerPresenter();
    }
    return DialerPresenter.mPresenter;
  }

  getCallStateChangeObserved() {
    return this._isCallStateChangeObserved;
  }

  getVoicemailManager() {
    return this.voicemailManager;
  }

  setTimer(timer: number | null) {
    this.timer = timer;
  }

  getTimer() {
    return this.timer;
  }

  setTaskId(taskId: number) {
    this.taskId = taskId;
  }

  getTaskId() {
    return this.taskId;
  }

  aboutToAppear() {
    // 监听通话状态
    registerCallStateListener();
    this.updatePhoneWidth();
    this.createSoundPool();
    // Read dsds config!
    sim.getDsdsMode().then(data => {
      HiLog.i(TAG, 'getDsdsMode: ' + data);
      this.dsdsMode = data;
    });

    if (!PreferencesUtil.isUsed() && !this._isCallStateChangeObserved) {
      interface StatesInterface {
        state: call.CallState
        number: string
      }

      try {
        observer.on('callStateChange', (callback: StatesInterface) => {
          HiLog.i(TAG, 'callStateChange state' + callback.state);
          if (callback.state === 0) {
            this.refresh();
            CallRecordPresenter.getInstance().onCallsChange();
          }
        });
      } catch (err) {
        HiLog.e(TAG, 'callStateChange ERR : ' + (err as Error).message);
      }
      this._isCallStateChangeObserved = true;
    }
  }

  aboutToDisappear() {
    // 关闭监听通话状态
    unregisterCallStateListener();
    this.releaseSoundPool();
    if (this.taskId != -1) {
      clearTimeout(this.taskId);
      this.taskId = -1;
    }
  }

  //TODO 调用位置多且重复
  updatePhoneWidth() {
    //read phone width
    const size = AppStorage.get('windowWidthPX') as number;
    //Remaining width after removing two buttons and margin
    this.dialerButtonWidthInMulti = size - vp2px(4 + 4 + 60 + 60);
  }

  refresh() {
    if (!PreferencesUtil.isUsed()) {
      PreferencesUtil.setIsUsed(true);
      this.refreshView = !this.refreshView;
    }
  }

  //设置文本选择状态
  setTextSelectStatus(selectStart: number, selectEnd: number) {
    HiLog.w(TAG, `setTextSelectStatus, start: ${selectStart}, end: ${selectEnd} `);
    this.textSelectStart = selectStart;
    this.textSelectEnd = selectEnd;
  }

  setTextSelectStatusForInit(len: number) {
    if (len === 0) {
      this.textSelectStart = -1;
      this.textSelectEnd = -1;

    } else if (len === 1) {
      this.textSelectStart = 1;
      this.textSelectEnd = 1;
    }
  }

  setCaret() {
    const formatStr = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
      AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
    let formatIndex = this.computeFormatIndex(formatStr, this.afterActionCaret[0]);
    HiLog.w(TAG, `formatIndex: ${formatIndex},afterActionCaret:${this.afterActionCaret[0]}`);
    this.textController.caretPosition(formatIndex);
  }

  isNumberic(message: string): boolean {
    //1.去除空白字符
    let removeSpaceStr: string = message.replace(new RegExp('\\s+', 'g'), '');
    //2.表示字符串是否由 [0-9,.()+-;*#]这个字符数组(可以出现1次或者多次)组成
    const pattern = /^[0-9,.()+-;*#]+$/;
    return pattern.test(removeSpaceStr);
  };

  getDataFromClipBoard() {
    pasteboard.getSystemPasteboard().getData((err: BusinessError, pasteData: pasteboard.PasteData) => {
      if (err) {
        HiLog.e(TAG, `failed to get paste data. Code is ${err.code}, message is ${err.message}`);
        AppStorage.setOrCreate('isHasDate', false);
        AppStorage.setOrCreate('pasteData', '');
        AppStorage.setOrCreate('pasteStatus', false);
        return;
      }
      // 获取剪切板的内容--纯文本内容
      let message: string = pasteData.getPrimaryText();
      HiLog.w(TAG, `paste value length: ${message?.length}`);
      if (message?.length > 0) {
        // Check whether the data in the current clipboard is the same as that in the previous clipboard.
        sharedPreferencesUtils.getFromPreferences('clipBoardValue', '').then((value: preferences.ValueType) => {
          HiLog.w(TAG, ` clipBoardValue value length: ${(value as string)?.length}`);
          let res = message.localeCompare(value as string);
          HiLog.w(TAG, `result res ${res}`);
          if (res === 0) {
            AppStorage.setOrCreate('pasteStatus', false);
          } else {
            AppStorage.setOrCreate('pasteStatus', true)
            sharedPreferencesUtils.saveToPreferences('clipBoardValue', message);
          }
          if (StringUtil.isEmpty(message)) {
            HiLog.w(TAG, `value is null, return`);
            AppStorage.setOrCreate('isHasDate', false);
            AppStorage.setOrCreate('pasteData', '');
            return;
          }
          if (this.isNumberic(message)) {
            HiLog.w(TAG, `isNumberic after length: ${message?.length} `);
            AppStorage.setOrCreate('isHasDate', true); //过滤之后是否有数据
            AppStorage.setOrCreate('pasteData', message);
            // 设置拨号盘默认拉起显示
            AppStorage.setOrCreate('showDialBtn', true);
          } else {
            HiLog.w(TAG, `isNumberic, value is null, return`);
            AppStorage.setOrCreate('isHasDate', false);
            AppStorage.setOrCreate('pasteData', '');
          }
        });
        // 判断在获取剪切板数据的时候当前页面是不是在电话页面,不在电话页面需要在下次点击电话页签的时候让它显示.
        if ((AppStorage.get('isClickShowPaste') === undefined || AppStorage.get('isClickShowPaste')) &&
          (AppStorage.get('mainTabsIndex') !== IndexPresenter.getInstance().callIndex)) {
          HiLog.w(TAG, `clipBoard change,click callIndex show in`);
          AppStorage.setOrCreate('isClickShowPaste', false);
        }
      } else {
        HiLog.w(TAG, `getPrimaryText error: ${message}`);
        AppStorage.setOrCreate('pasteStatus', false);
        AppStorage.setOrCreate('isHasDate', false);
        AppStorage.setOrCreate('pasteData', '');
        sharedPreferencesUtils.saveToPreferences('clipBoardValue', '');
      }
    });
  }


  pasteFunc() {
    let oldpasteData: string | undefined = AppStorage.get('pasteData');
    let pasteData: string | undefined = oldpasteData?.replaceAll('-','')
    AppStorage.setOrCreate('backCallLogPage', 1);
    if (pasteData) {
      let telNumberWithSpace: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
        AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
      if (StringUtil.isEmpty(telNumberWithSpace)) {
        HiLog.w(TAG, `direct paste initialization...`);
        this.pasteInit();
      }
      // *#06#
      if (pasteData === SECRET_CODE_MMI_IMEI_DISPLAY) {
        clearInterval(this.timerId);
        this.timerId = setInterval(() => {
          if (this.isShowImeiPanel) {
            AppStorage.SetOrCreate('isDialerShowImeiPanel', true);
            clearInterval(this.timerId);
          }
        }, 50)
        this.handleIMEIDisplay();
        return;
      }
      let newPasteData: string = StringUtil.removeSpace(pasteData);
      if (newPasteData !== '') {
        call.inputDialerSpecialCode(newPasteData, (err: BusinessError) => {
          if (err) {
            HiLog.e(TAG, 'inputDialerSpecialCode error: ' + err?.message + ', stack: ' + err?.stack);
            // 不是暗码或者异常正常走粘贴的逻辑
            // Replace the selected content in the text box.
            let result: string =
              DialerPresenter.getInstance().replaceSelectedStr(telNumberWithSpace, pasteData as string);
            // 用于格式化显示
            AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, result);
            // The cursor does not appear when you paste it for the first time.
            AppStorage.setOrCreate(Constants.KEY_IS_PASTE_SHOW_CURSOR, false);
            // 发送聚焦到输入框
            let isOpenAccessibility: boolean = AppStorage.get(AccessibilityUtil.ISOPENACCESSIBILITY) ?? false;
            HiLog.w(TAG, `isOpenAccessibility: ${isOpenAccessibility} `);
            if (isOpenAccessibility) {
              AccessibilityUtil.getInstance().instantlySendAccessibilityEvent(isOpenAccessibility, 'telNumberInput');
            }
          } else {
            // 其他暗码弹菜单,号码清空
            HiLog.w(TAG, 'inputDialerSpecialCode success');
            this.resetTelNumber();
          }
        });
      }
    } else {
      HiLog.w(TAG, `this pastedata is ${pasteData} `);
    }
  }

  // 截取光标之前的号码计算除了特殊字符之外的长度
  computeActionIndex(cur: string, index: number) {
    cur.substring(0, index).split('').forEach((value) => {
      // 判断截取的value值是否为拨号盘能输入的内容，先将不是拨号盘输入的内容的光标位去掉
      if (!(regex.test(value))) {
        index--;
      }
    })
    return index;
  }

  // 截取光标之前的号码将特殊字符的长度加上(格式化后最准确的光标位数)
  computeFormatIndex(formatStr: string, index: number) {
    let initIndex = index;
    for (let i = 0; i < formatStr.length; i++) {
      // find out all before orignal index spaces count and add the index
      if (!(regex.test(formatStr[i])) && i <= initIndex) {
        initIndex++;
      }
    }
    return initIndex;
  }

  getInsertStr(cur: string, insert: string): string {
    HiLog.w(TAG, `getInsertStr. textSelectStart: ${this.textSelectStart} textSelectEnd: ${this.textSelectEnd}`);
    const insertStr = cur.substring(0, this.textSelectStart) + insert + cur.substring(this.textSelectEnd);
    const computeIndex = this.computeActionIndex(insertStr, (cur.substring(0, this.textSelectStart) + insert).length);
    HiLog.w(TAG, `computeIndex: ${computeIndex} `);
    this.afterActionCaret = [computeIndex, computeIndex];
    return insertStr;
  }

  longPressNumberChange(number: string) {
    let originalNumber: string = AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string;
    if (StringUtil.isEmpty(originalNumber)) {
      HiLog.w(TAG, 'originalNumber is Empty');
      return;
    }
    HiLog.w(TAG,
      `longPressNumberChange. textSelectStart: ${this.textSelectStart} textSelectEnd: ${this.textSelectEnd}`);
    let firstHalf: string = originalNumber.substring(0, this.textSelectStart);
    let secondHalf: string = originalNumber.substring(this.textSelectEnd);
    let newNumber: string = firstHalf.substring(0, this.textSelectStart - 1) + number + secondHalf;
    HiLog.w(TAG, `nueNumber length: ${newNumber?.length} `);
    AppStorage.setOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, newNumber);
    this.all_number = newNumber;
  }

  static setForegroundCallBack(foregroundCallBack: () => void) {
    HiLog.w(TAG, `setForegroundCallBack...`);
    DialerPresenter.foregroundCallBack = foregroundCallBack;
  }

  foregroundOperation() {
    if (DialerPresenter.foregroundCallBack) {
      HiLog.w(TAG, 'DialerPresenter foregroundCallBack running');
      DialerPresenter.foregroundCallBack();
      DialerPresenter.foregroundCallBack = undefined;
    }
  }

  afterDialDeal() {
    HiLog.w(TAG, 'initializing...');
    CallRecordPresenter.getInstance().initStarted = false;
    this.resetTelNumber();
    AppStorage.setOrCreate('showTelNumber', true);
  }

  // 拨打电话
  dialClick(context: UIContext, slot?: number, isHicar?: boolean) {
    let pasteStatus: boolean | undefined = AppStorage.get('pasteStatus') as boolean | undefined;
    if (pasteStatus) {
      HiLog.w(TAG, 'click calling, pasteStatus disappear');
      AppStorage.setOrCreate('pasteStatus', false);
    }
    HiLog.w(TAG, `dialClick slot: ${slot} `);
    let telNumber: string | undefined = AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) as string | undefined;
    if (telNumber !== undefined && telNumber.length > 0) {
      // 点击拨号按钮后，隐藏电话号码（使界面产生变化，优化通话场景，响应时延）
      AppStorage.setOrCreate('showTelNumber', false);
      let isShowSmartWindow: boolean | undefined = AppStorage.get('isShowSmartWindow') as boolean | undefined;
      RoamingManager.getInstance().handleRoaming(context, this.all_number, (slot === undefined ? undefined : {
        accountId: slot
      }),
        (successFlag: boolean) => {
          // PC、小窗模式、!isSuccess(拨打电话出现弹窗情况),会使应用一直处于前台,可直接重置信息
          if (EnvironmentProp.isPC() || isShowSmartWindow || !successFlag) {
            this.afterDialDeal();
          } else {
            // 拨打电话成功时,页面置于后台,挂断电话后，应用重新置于前台时,重置信息
            // 拨打电话显示顺序: 点击拨号按钮--号码屏蔽(通话记录不出现)--通话页面显示--挂断电话应用置于前台--通话记录出现
            DialerPresenter.setForegroundCallBack(() => {
              this.afterDialDeal();
            })
          }
        });
      if (isHicar !== true) {
        // 联系人打点-拨号盘点击拨号按钮
        this.callParams.ENC = 0;
        let isHyacinthMode: boolean | undefined = AppStorage.get('isHyacinthMode')
        HiLog.w(TAG,`HyacinthMode status is ${isHyacinthMode}`)
        let isSatelliteMode: boolean | undefined = AppStorage.get('isSatelliteMode');
        if (isSatelliteMode) { //天通
          let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
          let slotId: number = Number(settings.getValueSync(context, 'satellite_slot_id', '0'));
          this.callParams.SLOT = slotId
        } else if (isHyacinthMode) { //风信子   satellite_slot_id卡槽号
          let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
          let slotId: number = Number(settings.getValueSync(context, 'satellite_slot_id', '0'));
          this.callParams.SLOT = slotId
        } else {
          this.callParams.SLOT = (slot === undefined ? AppStorage.Get<number>('defaultSlot') : slot)
        }
        this.callParams.ISMULTISIMCARD = (slot === undefined ? 0 : 1);
        DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
      }
    } else {
      let num: number = AppStorage.Get<number>('recordType') as number;
      let callRecordList: CallRecordListDataSource;
      if (num === 0) {
        callRecordList = CallRecordPresenter.getInstance().mAllCallRecordListDataSource
      } else {
        callRecordList = CallRecordPresenter.getInstance().mMissCallRecordListDataSource
      }
      if (callRecordList.totalCount() > 0) {
        let callLogData = callRecordList.getData(0);
        if (callLogData !== null) {
          let pn: string = callLogData.phoneNumber;
          if (pn !== undefined && pn.length > 0) {
            HiLog.w(TAG, `pn: ${pn.length} `);
            this.editPhoneNumber(pn);
          }
        }
      }
    }
  }

  /**
   * Filter out invalid input,
   * Prevent invalid content from being added to the text box without passing through the inputFilter.
   * @param number
   * @returns
   */
  filterInvalidInput(number: string): string {
    HiLog.w(TAG, 'filterInvalidInput');
    return number.replace(new RegExp('[^0-9*#＊＃+\\-,; ]', 'g'), '')
      .replace(new RegExp('[＊]', 'g'), '*')
      .replace(new RegExp('[＃]', 'g'), '#');
  }

  replaceSelectedStr(current: string, text: string): string {
    HiLog.w(TAG, 'replaceSelectedStr');
    const insertStr = current.substring(0, this.textSelectStart) + text + current.substring(this.textSelectEnd);
    const computeIndex = this.computeActionIndex(insertStr, this.textSelectStart + text.length);
    this.afterActionCaret = [computeIndex, computeIndex];
    return insertStr;
  }

  getCutStr(cur: string): string {
    HiLog.w(TAG, 'getCutStr');
    const computeIndex = this.computeActionIndex(cur, this.textSelectStart);
    this.afterActionCaret = [computeIndex, computeIndex];
    return cur;
  }

  deleteStr(cur: string): string {
    HiLog.w(TAG, 'deleteStr');
    if (this.textSelectStart === this.textSelectEnd) {
      const startIndex =
        (regex.test(cur[this.textSelectStart - 1])) ? (this.textSelectStart - 1) : (this.textSelectStart - 2);
      // 删除数字无障碍播报
      let deleteContent: string = cur.substring(startIndex, this.textSelectEnd);
      let broadcastNum: string =
        ResourceUtil.getStringByResource($r('app.string.accessibility_deleted'), deleteContent);
      if (!StringUtil.isEmpty(deleteContent)) {
        AccessibilityUtil.getInstance().sendAccessibilityEventInfo(broadcastNum);
      }
      const deleteStr = cur.substring(0, startIndex) + cur.substring(this.textSelectEnd);
      const computeIndex = this.computeActionIndex(deleteStr, startIndex);
      this.afterActionCaret = [computeIndex, computeIndex];
      return deleteStr;
    } else {
      const deleteStr = cur.substring(0, this.textSelectStart) + cur.substring(this.textSelectEnd);
      const computeIndex = this.computeActionIndex(deleteStr, this.textSelectStart);
      let deleteContentString: string = cur.substring(this.textSelectStart, this.textSelectEnd);
      let broadcastString: string =
        ResourceUtil.getStringByResource($r('app.string.accessibility_deleted'), deleteContentString);
      AccessibilityUtil.getInstance().sendAccessibilityEventInfo(broadcastString);
      this.afterActionCaret = [computeIndex, computeIndex];
      return deleteStr;
    }
  }

  editPhoneNumber(phoneNum: string): void {
    HiLog.w(TAG, 'editPhoneNumber, phoneNun len: ' + phoneNum?.length)
    if (StringUtil.isEmpty(phoneNum)) {
      // Reset caret index when clear input.
      this.afterActionCaret = [0, 0];
      return;
    }
    phoneNum = this.filterInvalidInput(phoneNum);
    HiLog.w(TAG, 'editPhoneNumber filterInvalid ,phoneNun len: ' + phoneNum?.length)
    if (StringUtil.isEmpty(phoneNum)) {
      // Reset caret index when clear input.
      this.afterActionCaret = [0, 0];
      return;
    }
    // Set Cursor
    AppStorage.SetOrCreate('isPastShowCursor', false);
    let newVal: string = this.getInsertStr('', phoneNum);
    HiLog.w(TAG, `editPhoneNumber length ${newVal.length} `);
    AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, newVal); //用于格式化显示
    this.all_number = newVal;
  }

  onDestroy() {
  }

  setAndFormatNumber(number: string) {
    this.all_number = StringUtil.removeSpace(number); //去除空格之后的数字 考虑是不是要直接用tele_number
    //存放无空格显示
    AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, this.all_number);
    let formatNumber: string = '';
    // 未格式化之前的号码大于16或者带有特殊字符或者长度小于等于3的均不格式化
    if (this.all_number.length > this.NUM_TEXT_MAXSIZE_LENGTH || !this.checkNeedNumberSpace(number) ||
      this.all_number.length <= 3) {
      formatNumber = this.all_number;
    } else {
      formatNumber = new PhoneNumber(this.all_number).dynamicPhoneFormat();
    }
    //用于拨号盘号码显示
    AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, formatNumber);
  }

  /*
   * Check whether formatting spaces are required when entering a number.
   */
  checkNeedNumberSpace(numText: string) {
    let isSpace: RegExp = new RegExp('[\\+;,#\\*]', 'g');
    let isRule: RegExp = new RegExp('^\\+.*');

    if (isSpace.test(numText)) {
      // If the number string contains special characters, no space is added.
      if (isRule.test(numText)) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  dialing(context: UIContext, phoneNumber: string, options?: call.DialCallOptions): Promise<boolean> {
    return new Promise((resolve, reject) => {
      this.editPhoneNumber('');
      RoamingManager.getInstance().handleRoaming(context, phoneNumber, options, (isSuccess: boolean) => {
        if (isSuccess) {
          this.refresh();
          resolve(true);
        } else {
          HiLog.w(TAG, 'dial failed');
          resolve(false)
        }
        ;
      });
    });
  }

  videoDialing(context: UIContext, phoneNumber: string, options: call.DialCallOptions) {
    options.videoState = call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL;
    this.dialing(context, phoneNumber, options);
    setTimeout(() => {
      this.resetTelNumber();
      AppStorage.setOrCreate('showTelNumber', true);
      this.callBtnClick = false;
    }, 10)
  }

  /*
   * Two cards, both of which are registered with VoLTE, and then a pop-up window is displayed for selection.
   * If there are two cards and only one card is registered with the VoLTE,
   * use the VoLTE card to make a call without popping up the window.
   * There are two cards and only one card is registered with VoLTE. By default, card 2 is set.
   * */
  multiSimCardVideoDialing(context: UIContext) {
    let voLteRegStates: boolean[] = AppStorage.get('voLteRegStates') as boolean[];
    const isAllRegvoLteStates = voLteRegStates[0] && voLteRegStates[1];
    if (!isAllRegvoLteStates) {
      let accountId: number = voLteRegStates[0] ? dotCommon.eventParam.SIM_CARD_ONE : dotCommon.eventParam.SIM_CARD_TWO;
      // 联系人打点-视频呼叫-拨号盘-双卡只注册一个VoLTE卡
      this.dialerVideoCall(accountId, dotCommon.eventParam.SELECT_TRUE, dotCommon.eventParam.SELECT_FALSE,
        dotCommon.eventParam.CARD_NUMBER_ONE);
      this.videoDialing(context, this.all_number, {
        accountId: accountId
      })
      return;
    }
    // In the case of multiple SIM cards, if the default SIM card is set, the call is directly made.
    if (AppStorage.get<number>('defaultSlot') !== -1) {
      let accountId: number = AppStorage.get<number>('defaultSlot') as number;
      // 联系人打点-视频呼叫-拨号盘-双卡有默认卡
      this.dialerVideoCall(accountId, dotCommon.eventParam.SELECT_TRUE, dotCommon.eventParam.SELECT_TRUE,
        dotCommon.eventParam.CARD_NUMBER_ONE);
      this.clearVideoDialingNum(context, accountId);
      return;
    }
    this.selectSimBuilder(context);
  }

  clearVideoDialingNum(context: UIContext, value: number) {
    const optionsObj: call.DialOptions = {
      accountId: value,
      videoState: call.VideoStateType.TYPE_VIDEO_BIDIRECTIONAL
    }
    this.callBtnClick = true;
    this.dialing(context, this.all_number, optionsObj);
    this.resetTelNumber();

    this.callBtnClick = false;
  }

  selectSimBuilder(context: UIContext) {
    let teleNumber: string = AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) as string;
    this.builder.title = $r('app.string.contacts_call_number', teleNumber);
    this.builder.callback = (value: number) => {
      // 联系人打点-视频呼叫-拨号盘-双卡注册两张VoLTE卡
      this.dialerVideoCall(value, dotCommon.eventParam.SELECT_TRUE, dotCommon.eventParam.SELECT_FALSE,
        dotCommon.eventParam.CARD_NUMBER_TWO);
      this.clearVideoDialingNum(context, value);
    }
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('findByNumberIn', {
        actionData: {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          numbers: teleNumber,
          limit: 1,
          page: 1
        }
      }, (resultList: CallLog[]) => {
        /* Encapsulate the attributes required on the detail page based on the obtained raw call record data. */
        if (!ArrayUtil.isEmpty(resultList)) {
          this.builder.lastSimId = resultList[0].simId;
        } else {
          this.builder.lastSimId = -1;
        }

        let spnList = AppStorage.get<Array<string | Resource>>('spnList');
        if (spnList && this.builder.multiSimCardItems) {
          for (let index = 0; index < spnList.length; index++) {
            this.builder.multiSimCardItems[index].name = spnList[index];
          }
        }
        this.builder.controller?.open();
      });
  }


  /*
   * Add a space when entering a number.
   */
  ifNeedSpace() {
    let needNumber: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) ?
      AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) as string : '';
    switch (needNumber.length) {
      case 3:
        if (this.checkNeedNumberSpace(needNumber)) {
          AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, needNumber + ' ');
        }
        break;
      case 8:
        AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, needNumber + ' ');
        break;
      default:
        break;
    }
  }

  playAudio(number: number | string, type?: string) {
    let focusModelEnable = AppStorage.get('focusModelEnable') as boolean;
    // 如果免打扰开启，按键音无声
    if (focusModelEnable) {
      HiLog.w(TAG, 'do not disturb cancels the keypad tone.')
      return;
    }
    if (type == DIALPAD_TOUCH_OHOS_TONE || type == DIALPAD_TOUCH_PIANO_TONE) {
      this.startHwTone(number);
    } else {
      HiLog.i(TAG, 'playKeyTone: do nothing');
    }
  }

  async playSoundVideo(soundId: number | undefined, playParameters: media.PlayParameters = {}): Promise<void> {
    this.mSoundPool?.play(soundId, playParameters, (error, streamId) => {
      if (error) {
        HiLog.e(TAG, `play soundPoolerror: ${error.message}.`);
      } else {
        HiLog.i(TAG, `play soundPool Success, streamId is ${streamId}.`);
      }
    });
  }

  /*
   * Play different audio resources based on key digits.
   */
  startHwTone(number: number | string) {
    // 如果声音模式不是震动，拨号不调用播放声音接口
    let audioRingMode: audio.AudioRingMode = ContactsGlobalThisHelper.GetGlobalThis().getAudioRingMode();
    let isNormalFlag = audioRingMode == audio.AudioRingMode.RINGER_MODE_NORMAL;
    if (!isNormalFlag) {
      HiLog.w(TAG, 'startHwTone not normal ringerMode, not playAudio');
      return;
    }
    switch (number.toString()) {
      case '1':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_1);
        break;
      case '2':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_2);
        break;
      case '3':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_3);
        break;
      case '4':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_4);
        break;
      case '5':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_5);
        break;
      case '6':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_6);
        break;
      case '7':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_7);
        break;
      case '8':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_8);
        break;
      case '9':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_9);
        break;
      case '0':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_0);
        break;
      case '*':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_S);
        break;
      case '#':
        this.tonePlayer(audio.ToneType.TONE_TYPE_DIAL_P);
        break;
      default:
        HiLog.e(TAG, 'keytone src is error');
    }
  }

  public createSoundPool(): void {
    if (this.mSoundPool !== undefined) {
      HiLog.i(TAG, 'soundPool has been created and loaded');
      return;
    }
    HiLog.i(TAG, 'begin createSoundPool');
    try {
      media?.createSoundPool(this.NUM_SOUND_STREAMS, this.audioRendererInfo, (error, soundPool) => {
        if (error) {
          HiLog.e(TAG, `createSoundPool error: ${error.message}.`);
        } else {
          HiLog.i(TAG, 'createSoundPool Success.');
          this.mSoundPool = soundPool;
        }
      });
      this.setSourceInfo();
      this.setErrorCallback();
    } catch (e) {
      HiLog.e(TAG, `createSoundPool error: ${e.message}.`);
    }
  }

  public releaseSoundPool(): void {
    HiLog.i(TAG, 'begin release SoundPool.');
    if (this.mSoundPool) {
      this.mSoundPool.release(() => {
        HiLog.i(TAG, 'soundPool released.');
      });
    }
  }

  async setSourceInfo(): Promise<void> {
    this.mSoundPool?.on('loadComplete', this.loadCompleteCallback().bind(this));
    this.mSoundPool?.on('playFinished', this.playFinishedCallback().bind(this));
  }

  private playFinishedCallback(): Callback<void> {
    return () => {
      HiLog.i(TAG, 'on play Finished.');
    };
  }

  private loadCompleteCallback(): Callback<number> {
    return (soundId) => {
      HiLog.i(TAG, `on load completed, soundId is : ${soundId}.`);
    };
  }

  private setErrorCallback(): void {
    this.mSoundPool?.on('error', this.soundPoolCallback().bind(this));
  }

  private soundPoolCallback(): ErrorCallback {
    return (error) => {
      HiLog.e(TAG, `error happened, error: ${error.message}.`);
    };
  }

  async tonePlayer(type: number) {
    HiLog.w(TAG, 'TonePlayer');
    if (this.timer) {
      clearTimeout(this.timer);
    }
    let tonePlayer: audio.TonePlayer;
    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_DTMF,
      rendererFlags: 0
    };
    this.timer = setTimeout(async () => {
      try {
        tonePlayer = await audio.createTonePlayer(audioRendererInfo);
        await tonePlayer.load(type);
        await tonePlayer.start();
        setTimeout(async () => {
          await tonePlayer.stop();
          await tonePlayer.release();
        }, 30)
      } catch (err) {
        HiLog.e(TAG, 'tonePlayer err = ' + err?.message + ', stack: ' + err?.stack);
      }
    }, 50)
  };

  /*
   * Jump to New Contact
   * 从拨号盘拨陌生号码后新建联系人
   */
  jumpToAccountants() {
    let phoneNumber: Record<string, string> = {
      'phoneNumber': AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) ?
        AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) as string : '',
    }
    let phoneNumbers: Array<Object> = [phoneNumber];
    const params: Record<string, Object> = {
      'updataShow': false,
      'phoneNumbers': phoneNumbers
    };
    // 拨号盘调转
    DynamicLoader.getInstance().fire(DynamicLoader.ACCOUNTANTS).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.ACCOUNTANTS, params);
    });
  }

  /*
 *  New Contact Model
 */
  creatAccountantsObj(phoneNum: string) {
    if (StringUtil.isEmpty(phoneNum)) {
      phoneNum = '';
    }
    let phoneNumber: Record<string, string> = {
      'phoneNumber': phoneNum,
    }
    let contact: SingleSelectContact = {
      updataShow: false,
      phoneNumbers: [phoneNumber],
    } as SingleSelectContact;
    this.myAccountantsModel = contact;
  }

  sendMessage() {
    let number: string = AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) as string;
    PhoneNumber.fromString(number).format().then((formatNum: string) => {
      PhoneNumber.fromString(this.all_number).sendMessage(formatNum, formatNum);
    });
  }

  async sendMessageWithPhoneNum(phoneNum: string) {
    let formatNum = await PhoneNumber.fromString(phoneNum).format();
    PhoneNumber.fromString(phoneNum).sendMessage(formatNum, phoneNum);
  }

  saveCallRecordExistingContact(phoneNum: string) {
    if (this.pathInfos?.getAllPathName().some(item => item === 'SingleSelectContactPage')) {
      return;
    }
    HiLog.i(TAG, 'saveCallRecordExistingContact start.');
    if (StringUtil.isEmpty(phoneNum)) {
      phoneNum = '';
    }
    const params: ContactPickerParam = {
      phoneNumberShow: phoneNum,
      isSaveExistContact: true,
      isDisplayByName: true,
    };
    DynamicLoader.getInstance().fire(DynamicLoader.SINGLE_SELECT_CONTACTS_PAGE).then(() => {
      this.pathInfos?.pushPathByName('SingleSelectContactPage', params);
    });
  }

  dealSecretCode(value: string) {
    let length = value.length;
    if (length > 8 && value.startsWith(SECRET_CODE_START_TYPE_ONE) && value.endsWith(SECRET_CODE_END_TYPE_ONE)) {
      if (value === SECRET_CODE_ONE && systemParameter.getSync(RUN_MODE) !== FACTORY_MODE) {
        this.secretCode = '';
      } else {
        this.secretCode = value;
      }
    } else if (length > 3 && value.startsWith(SECRET_CODE_START_TYPE_TWO) && value.endsWith(SECRET_CODE_END_TYPE_TWO)) {
      this.secretCode = value;
    } else if (length > 3 && value.startsWith(SECRET_CODE_START_TYPE_TWO) &&
    value.endsWith(SECRET_CODE_END_TYPE_THREE)) {
      this.secretCode = value;
    } else if (value === SECRET_CODE_TWO && systemParameter.getSync(RUN_MODE) === FACTORY_MODE) {
      // 过滤版本（只支持生产版本）
      this.secretCode = value;
    } else if (value === SECRET_CODE_THREE) {
      this.secretCode = value;
    } else {
      this.secretCode = '';
    }
    if (this.secretCode !== '') {
      if (this.secretCode === SECRET_CODE_MMI_IMEI_DISPLAY) {
        this.handleIMEIDisplay()
      } else {
        PhoneNumber.fromString(this.secretCode).dialerSpecialCode();
      }
    }
  }

  handleIMEIDisplay() {
    HiLog.w(TAG, `handleIMEIDisplay.`);
    if (this.isSecretCodeDialog) {
      return
    }
    if (SimManager.isDualSim()) {
      this.handleDualImeiPanel()
    } else {
      this.handleIMEIPanel()
    }
  }

  handleDualImeiPanel() {
    SimManager.getIMEIs(imeiArr => {
      let imeiStr = DeviceConstant.DEVICE_INFO_IMEI
      let imei1Str = DeviceConstant.DEVICE_INFO_IMEI1
      let imei2Str = DeviceConstant.DEVICE_INFO_IMEI2
      let firstImei = imeiArr[0]
      let secondImei = imeiArr[1]
      let title = imeiStr
      let message = ''
      if (firstImei.length > 0 && secondImei.length > 0) {
        message = `${imei1Str + ':' + firstImei}\n${imei2Str + ':' + secondImei}`
      } else if (firstImei.length > 0 && secondImei.length == 0) {
        message = imeiStr + ':' + firstImei
      } else if (secondImei.length > 0 && firstImei.length == 0) {
        message = imeiStr + ':' + secondImei
      } else {
        HiLog.e(TAG, 'getIMEIs is null')
        return
      }
      this.handelImeiDialog(title, message, imeiArr)
    })
  }

  async handelImeiDialog(title: string, message: string, imeiArr: string[]) {
    let snStr = DeviceConstant.DEVICE_INFO_SN
    let serial = deviceInfo.serial
    this.serialStr = serial;
    if (serial.length > 0) {
      message = `${message}\n${snStr + ':' + serial}`
    } else {
      HiLog.e(TAG, 'deviceInfo serial is null')
    }
    if (message.length == 0) {
      HiLog.e(TAG, 'showImeiAlertDialog message is null')
      return
    }
    let imeiDialogArr: string[] = []
    imeiDialogArr.push(title)
    imeiDialogArr.push(message)
    AppStorage.setOrCreate('secretCodeDialogContents', imeiDialogArr)
    // const generateBarcode = await import('@hms.core.scan.generateBarcode');
    // const scanCore = await import('@hms.core.scan.scanCore');
    let imeiPixelMap: Map<string, image.PixelMap> = new Map();
    await Promise.all(imeiArr.map(async (imei) => {
      try {
        // let pixelMap: image.PixelMap = await generateBarcode.default.createBarcode(imei, {
        //   scanType: scanCore.default.ScanType.CODE128_CODE,
        //   height: 2000,
        //   width: 4000,
        // });
        // imeiPixelMap.set(imei, pixelMap);
      } catch (err) {
        HiLog.e(TAG, 'createBarcode error: ' + err);
      }
    }))
    let imeiStr: string = '';
    let imeiStrArr: string[] = [];
    let imeiPixelMapArr: image.PixelMap[] = [];
    for (let index = 0; index < imeiArr.length; index++) {
      imeiStr = `IMEI${index + 1}:${imeiArr[index]}`;
      let pm: image.PixelMap | undefined = imeiPixelMap.get(imeiArr[index])
      if (pm) {
        imeiStrArr.push(imeiStr);
        imeiPixelMapArr.push(pm);
      } else {
        HiLog.e(TAG, `get imeiPixelMap empty, index: ${index}`);
      }
    }
    this.imeiStrArr = imeiStrArr;
    this.pixelMapArr = imeiPixelMapArr;

    this.eidStr = await SimManager.getEid();
    // if (this.eidStr) {
    //   this.eidPixelMap = await generateBarcode.default.createBarcode(this.eidStr, {
    //     scanType: scanCore.default.ScanType.CODE128_CODE,
    //     height: 2000,
    //     width: 4000,
    //   });
    // }

    if (this.serialStr.length > 0) {
      // this.serialPixelMap = await generateBarcode.default.createBarcode(this.serialStr, {
      //   scanType: scanCore.default.ScanType.CODE128_CODE,
      //   height: 2000,
      //   width: 4000,
      // });
    } else {
      HiLog.e(TAG, 'deviceInfo serial is null');
    }
    this.isShowImeiPanel = true;
  }

  handleIMEIPanel() {
    SimManager.getIMEIs(imeiArr => {
      let imeiStr = DeviceConstant.DEVICE_INFO_IMEI
      let imei = imeiArr[0]
      let title = imeiStr
      let message: string = ''
      if (imei.length > 0) {
        message = imeiStr + ':' + imei
      } else {
        HiLog.e(TAG, 'getIMEIs is null');
        return
      }
      this.handelImeiDialog(title, message, imeiArr)
    })
  }

  /**
   * Dialer Search
   */
  dialerSearch() {
    // 每次搜索置为空，记录本次搜索内容
    this.dialerSearchList = [];
    this.countNumber = 0;
    this.contactsCountNumbers = 0;
    this.teleCountNumbers = 0;
    this.contactsResultLength = 0;
    this.searchContactNameUnique = [];
    this.searchPhoneNumberUnique = [];
    let teleNumber: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) ?
      AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE) as string : '';
    HiLog.w(TAG, `dialerSearch start: ${TextUtils.getMaskString(teleNumber)}`);
    if (TextUtils.isEmpty(teleNumber)) {
      HiLog.w(TAG, 'teleNumber is empty');
      return;
    } else if (teleNumber.length === DIALER_SEARCH_LENGTH_THREE) {
      AppStorage.setOrCreate('dialerSearchNumber', -1);
    }
    let regex: RegExp = new RegExp('\\s*', 'g');
    // 输入号码长度为1时，过滤特殊字符，不触发查询
    if (teleNumber.length == DIALER_SEARCH_LENGTH_ONE && !new RegExp('[0-9]').test(teleNumber)) {
      HiLog.w(TAG, 'query not trigger');
      if (this.mAllCallRecordListDataSource) {
        this.mAllCallRecordListDataSource.refreshAll([]);
      }
      AppStorage.setOrCreate('isShowBtn', false);
      AppStorage.setOrCreate('dialerSearchNumber', 0);
      CallLogSearchBo.getInstance().refreshCurSearchResult(teleNumber, CallLogSearchBo.MATCH_SIZE_INIT);
      this.clearFlag = true;
      return;
    }
    performanceMonitor.begin('CONTACTS_DIALER_BUTTON_PRESS', performanceMonitor.ActionType.LAST_UP);
    let teleNumbers = teleNumber.replace(regex, '');
    let callLogSearchBo = CallLogSearchBo.getInstance();
    if (!callLogSearchBo.judgeIsQuery(teleNumbers)) {
      // 没有匹配到，设置标记位
      AppStorage.setOrCreate('isShowBtn', false);
      AppStorage.setOrCreate('dialerSearchNumber', 0);
      callLogSearchBo.refreshCurSearchResult(teleNumbers, this.countNumber);
      return;
    }
    // 查询通话记录
    this.clearFlag = false;
    if (this.task) {
      try {
        taskpool.cancel(this.task as taskpool.Task);
        HiLog.w(TAG, 'dialerSearch taskpool cancel success');
      } catch (err) {
        HiLog.e(TAG, 'dialerSearch taskpool cancel error ' + (err as BusinessError).message);
      }
    }
    if (this.taskForDbAndMixSearch) {
      try {
        taskpool.cancel(this.taskForDbAndMixSearch as taskpool.Task);
        HiLog.w(TAG, 'taskForDbAndMixSearch taskpool cancel success');
      } catch (err) {
        HiLog.e(TAG, `taskForDbAndMixSearch taskpool cancel error: code: ${err.code}, message: ${err.message}`);
      }
    }
    let callRecord = CallRecordPresenter.getInstance().allRecordLen();
    let contactRecord = ContactListPresenter.getInstance().contactListDataSource.totalCount();
    // 如果通话记录和联系人列表都没有数据就不进行搜索浪费功耗
    if (callRecord === 0 && contactRecord === 0) {
      HiLog.e(TAG, `dialerSearch callRecord:${callRecord},contactRecord:${contactRecord}`);
      AppStorage.setOrCreate('isShowBtn', false);
      AppStorage.setOrCreate('dialerSearchNumber', 0);
      this.mAllCallRecordListDataSource.refreshAll([]);
      return;
    }
    this.dialerSearchTask(teleNumbers);
  }

  /**
   * Dialer Search
   */
  dialerSearchWhenContactMixSearchNoResult(searchKey: string) {
    HiLog.w(TAG, `dialerSearchWhenContactMixSearchNoResult start: ${TextUtils.getMaskString(searchKey)}`);
    // 每次搜索置为空，记录本次搜索内容
    this.dialerSearchList = [];
    this.countNumber = 0;
    this.contactsCountNumbers = 0;
    this.teleCountNumbers = 0;
    this.contactsResultLength = 0;
    this.searchContactNameUnique = [];
    this.searchPhoneNumberUnique = [];
    this.clearFlag = false;
    if (this.taskForDbAndMixSearch) {
      try {
        taskpool.cancel(this.taskForDbAndMixSearch as taskpool.Task);
        HiLog.w(TAG, 'taskForDbAndMixSearch cancel success');
      } catch (err) {
        HiLog.e(TAG, `taskForDbAndMixSearch cancel error: code: ${err.code}, message: ${err.message}`);
      }
    }
    this.dialerSearchTaskForDbAndMixSearch(searchKey, 1);
  }

  /**
   * 拨号盘搜索结果处理,联系人是数据库搜索,通话记录是融合搜索
   * countNumber —— 拨号盘搜索最终结果展示数量
   * contactsCountNumbers —— 融合搜联系人库分页查询起始点
   * teleCountNumbers —— 融合搜通话记录库分页查询起始点
   * contactsResultLength —— 返回结果中联系人数据总长度（分页后联系人数据拼接点）
   * resultList —— 单次搜索任务返回的数据集合（包括融合搜联系人库与通话记录库）
   * contactsOffset —— 单次搜索任务融合搜联系人库返回个数
   * teleOffset —— 单次搜索任务融合搜通话记录库返回个数
   * contactsResultOffset —— 单次融合搜联系人库处理后结果长度
   *
   * @param teleNumbers search content
   */
  dialerSearchTaskForDbAndMixSearch(teleNumbers: string, page: number) {
    // 单次搜索唯一标识（过程包含请求融合搜及返回结果）
    let dialerSearchUniqueKey: number = new Date().valueOf();
    let myCardContactId: string = AppStorage.get(AppStorageConstant.MYCARD_CONTACT_ID) ?? '';
    HiLog.w(TAG, `dialerSearchTaskForDbAndMixSearch start. search content: ${TextUtils.getMaskString(teleNumbers)
    }, dialerSearchUniqueKey: ${dialerSearchUniqueKey}, myCardContactId: ${myCardContactId}`);
    let contactsOffset = 0;
    let teleOffset = 0;
    this.taskForDbAndMixSearch =
      new taskpool.Task(updateDialerSearchListForDbAndMixSearch, teleNumbers, this.contactsCountNumbers,
        this.teleCountNumbers, this.searchContactNameUnique, this.searchPhoneNumberUnique, dialerSearchUniqueKey,
        myCardContactId, page, ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    let runnable = (searchResultsObject: Object) => {
      HiLog.i(TAG, `dialerSearchUniqueKey: ${dialerSearchUniqueKey
      } dialerSearchTaskForDbAndMixSearch execute end dialerSearchList length result: ${this.dialerSearchList.length}`);
      let searchResults = searchResultsObject as DialerSearchResultType;
      // 单次搜索任务返回的数据集合（包括融合搜联系人库与通话记录库）
      let resultList = searchResults.resultList as Array<CallLogTemp>;
      // 单次搜索任务融合搜联系人库返回个数
      contactsOffset = searchResults.contactsOffset as number;
      // 单次搜索任务融合搜通话记录库返回个数
      teleOffset = searchResults.teleOffset as number;
      // 单次融合搜联系人库处理后结果长度
      let contactsResultOffset = searchResults.contactsResultOffset as number;
      this.searchContactNameUnique = searchResults.contactNameKeySet as string[];
      this.searchPhoneNumberUnique = searchResults.searchPhoneNumberSet as string[];
      this.taskForDbAndMixSearch = undefined;
      // 查询结果，查询出有结果（1）本次查询有结果（2）本次查询为0条，之前有搜索到记录
      if (resultList.length != 0 || (resultList.length == 0 && this.dialerSearchList.length != 0)) {
        AppStorage.setOrCreate('isShowBtn', true);
        this.countNumber += resultList.length;
        this.contactsCountNumbers += contactsOffset;
        this.teleCountNumbers += teleOffset;
        if (ArrayUtil.isEmpty(this.dialerSearchList)) {
          this.dialerSearchList = this.dialerSearchList.concat(resultList);
        } else {
          // 二次查询后需要对数据进行拼接（每次返回数据结果是已知联系人+陌生通话记录）联系人数据需要拼接到上次结果集联系人数据后，通话记录直接插入上次结果后
          if (contactsOffset > 0) {
            this.dialerSearchList.splice(this.contactsResultLength, 0, ...resultList.slice(0, contactsResultOffset));
          }
          if (teleOffset > 0) {
            this.dialerSearchList = this.dialerSearchList.concat(resultList.slice(contactsResultOffset));
          }
        }
        this.contactsResultLength += contactsResultOffset;
        this.mAllCallRecordListDataSource.refreshAll(this.dialerSearchList);
        AppStorage.setOrCreate('dialerSearchNumber', this.countNumber);
      } else {
        HiLog.w(TAG, 'dialerSearchDbUniqueKey: ' + dialerSearchUniqueKey + ' dialerSearchTask end result empty: ' +
        resultList.length);
        AppStorage.setOrCreate('isShowBtn', false);
        AppStorage.setOrCreate('dialerSearchNumber', 0);
        this.mAllCallRecordListDataSource.refreshAll([]);
      }
      // 当次查询联系人与通话记录返回结果均小于100，说明不需要在进行分页查询，搜索结束
      if (contactsOffset <= DIALER_DB_SEARCH_LIMIT && teleOffset < DIALER_SEARCH_OFFSET) {
        // 刷新本次搜索结果
        this.searchCustomParams.SEARCHKEY = TextUtils.getMaskString(teleNumbers);
        this.searchCustomParams.MIXSEARCHNUMBER = 0;
        this.searchCustomParams.ISSTARTDBSEARCH = 1;
        this.searchCustomParams.DBSEARCHNUMBER = this.contactsCountNumbers;
        DotUtil.getInstance()
          .contactDot(this.searchCustomParams, DIAL_PAD_CONTACT_SEARCH_EVENT);
        return;
      }
      // 联系人搜索一次500条，通话记录多次,一次搜出了大于100条，继续搜索第二页
      this.dialerSearchTaskForDbAndMixSearch(teleNumbers, -1);
    }

    if (teleNumbers.length > 1) {
      // 延迟50ms搜索，避免快速输入时，一直搜索
      taskpool.executeDelayed(DELAY_TIME, this.taskForDbAndMixSearch, taskpool.Priority.HIGH).then(runnable).catch(
        (error: BusinessError) => {
          if (error.message !== dotCommon.eventParam.SEARCH_CONTACT_FAIL_MASSAGE) {
            // 联系人故障打点-搜索通话记录异常
            faultContactParams.FAULT_INFO = error.message;
            DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.CALLLOG_SEARCH_ERROR);
          }
          HiLog.e(TAG, `dialerSearchDbUniqueKey: ${dialerSearchUniqueKey
          } delay task updateDialerSearchList error: code: ${error.code}, message: ${error.message}`);
        })
    } else {
      taskpool.execute(this.taskForDbAndMixSearch, taskpool.Priority.HIGH)
        .then(runnable)
        .catch((error: BusinessError) => {
          if (error.message !== dotCommon.eventParam.SEARCH_CONTACT_FAIL_MASSAGE) {
            // 联系人故障打点-搜索通话记录异常
            faultContactParams.FAULT_INFO = error.message;
            DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.CALLLOG_SEARCH_ERROR);
          }
          HiLog.e(TAG, `dialerSearchDbUniqueKey: ${dialerSearchUniqueKey
          } task updateDialerSearchList error: code: ${error.code}, message: ${error.message}`);
        })
    }
  }

  /**
   * 拨号盘搜索结果处理
   * countNumber —— 拨号盘搜索最终结果展示数量
   * contactsCountNumbers —— 融合搜联系人库分页查询起始点
   * teleCountNumbers —— 融合搜通话记录库分页查询起始点
   * contactsResultLength —— 返回结果中联系人数据总长度（分页后联系人数据拼接点）
   * resultList —— 单次搜索任务返回的数据集合（包括融合搜联系人库与通话记录库）
   * contactsOffset —— 单次搜索任务融合搜联系人库返回个数
   * teleOffset —— 单次搜索任务融合搜通话记录库返回个数
   * contactsResultOffset —— 单次融合搜联系人库处理后结果长度
   * @param teleNumbers search key
   */
  dialerSearchTask(teleNumbers: string) {
    // 单次搜索唯一标识（过程包含请求融合搜及返回结果）
    let dialerSearchUniqueKey: number = new Date().valueOf();
    let myCardContactId: string = AppStorage.get(AppStorageConstant.MYCARD_CONTACT_ID) ?? '';
    HiLog.w(TAG, `dialerSearchTask start. search content: ${teleNumbers?.length
    },dialerSearchUniqueKey:${dialerSearchUniqueKey},myCardContactId: ${myCardContactId},${this.contactsCountNumbers}`);
    let contactsOffset = 0;
    let teleOffset = 0;
    this.task = new taskpool.Task(updateDialerSearchList, teleNumbers, this.contactsCountNumbers, this.teleCountNumbers,
      this.searchContactNameUnique, this.searchPhoneNumberUnique, dialerSearchUniqueKey, myCardContactId,
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    let runnable = (searchResultsObject: Object) => {
      HiLog.i(TAG, `dialerSearchUniqueKey: ${dialerSearchUniqueKey
      } dialerSearchTask execute end dialerSearchList length: ${this.dialerSearchList.length}`);
      let searchResults = searchResultsObject as DialerSearchResultType;
      // 单次搜索任务返回的数据集合（包括融合搜联系人库与通话记录库）
      let resultList = searchResults.resultList as Array<CallLogTemp>;
      // 融合搜第一次搜索,并且联系人搜索数量为0
      if (this.contactsCountNumbers === 0 && (!resultList || resultList.length === 0)) {
        this.dialerSearchWhenContactMixSearchNoResult(teleNumbers);
        return;
      }
      // 单次搜索任务融合搜联系人库返回个数
      contactsOffset = searchResults.contactsOffset as number;
      // 单次搜索任务融合搜通话记录库返回个数
      teleOffset = searchResults.teleOffset as number;
      // 单次融合搜联系人库处理后结果长度
      let contactsResultOffset = searchResults.contactsResultOffset as number;
      // 单次融合搜联系人库处理后结果长度
      let contactsOffsetFromDb = searchResults.contactsOffsetFromDb as number;
      this.searchContactNameUnique = searchResults.contactNameKeySet as string[];
      this.searchPhoneNumberUnique = searchResults.searchPhoneNumberSet as string[];
      this.task = undefined;
      // 只搜到一批小于100的情况下进行打点看是否从数据库搜索
      if (this.contactsCountNumbers === 0 && (contactsOffset < 100)) {
        this.searchCustomParams.SEARCHKEY = TextUtils.getMaskString(teleNumbers);
        this.searchCustomParams.MIXSEARCHNUMBER = (contactsResultOffset - contactsOffsetFromDb);
        this.searchCustomParams.ISSTARTDBSEARCH = ((contactsOffsetFromDb > 0) ? 1 : 0);
        this.searchCustomParams.DBSEARCHNUMBER = contactsOffsetFromDb;
        DotUtil.getInstance()
          .contactDot(this.searchCustomParams, DIAL_PAD_CONTACT_SEARCH_EVENT);
      }
      // 查询结果，查询出有结果（1）本次查询有结果（2）本次查询为0条，之前有搜索到记录
      if (resultList.length != 0 || (resultList.length == 0 && this.dialerSearchList.length != 0)) {
        HiLog.w(TAG, 'dialerSearchUniqueKey: ' + dialerSearchUniqueKey + ' dialerSearchTask end: ' + resultList.length);
        AppStorage.setOrCreate('isShowBtn', true);
        this.countNumber += resultList.length;
        this.contactsCountNumbers += contactsOffset;
        this.teleCountNumbers += teleOffset;
        if (ArrayUtil.isEmpty(this.dialerSearchList)) {
          this.dialerSearchList = this.dialerSearchList.concat(resultList);
        } else {
          // 二次查询后需要对数据进行拼接（每次返回数据结果是已知联系人+陌生通话记录）联系人数据需要拼接到上次结果集联系人数据后，通话记录直接插入上次结果后
          if (contactsOffset > 0) {
            this.dialerSearchList.splice(this.contactsResultLength, 0, ...resultList.slice(0, contactsResultOffset));
          }
          if (teleOffset > 0) {
            this.dialerSearchList = this.dialerSearchList.concat(resultList.slice(contactsResultOffset));
          }
        }
        this.contactsResultLength += contactsResultOffset;
        this.mAllCallRecordListDataSource.refreshAll(this.dialerSearchList);
        AppStorage.setOrCreate('dialerSearchNumber', this.countNumber);
      } else {
        HiLog.w(TAG, 'dialerSearchUniqueKey: ' + dialerSearchUniqueKey + ' dialerSearchTask end result empty: ' +
        resultList.length);
        AppStorage.setOrCreate('isShowBtn', false);
        AppStorage.setOrCreate('dialerSearchNumber', 0);
        this.mAllCallRecordListDataSource.refreshAll([]);
      }
      // 当次查询联系人与通话记录返回结果均小于100，说明不需要在进行分页查询，搜索结束
      if (contactsOffset < DIALER_SEARCH_OFFSET && teleOffset < DIALER_SEARCH_OFFSET) {
        // 刷新本次搜索结果
        HiLog.w(TAG, 'dialerSearchUniqueKey: ' + dialerSearchUniqueKey + ' dialerSearchTask finish dialerSearchList: ' +
        this.dialerSearchList.length);
        CallLogSearchBo.getInstance().refreshCurSearchResult(teleNumbers, this.countNumber);
        if (this.contactsCountNumbers > DIALER_SEARCH_OFFSET) {
          this.searchCustomParams.SEARCHKEY = TextUtils.getMaskString(teleNumbers);
          this.searchCustomParams.MIXSEARCHNUMBER = this.contactsCountNumbers;
          this.searchCustomParams.ISSTARTDBSEARCH = 0;
          this.searchCustomParams.DBSEARCHNUMBER = 0;
          DotUtil.getInstance()
            .contactDot(this.searchCustomParams, DIAL_PAD_CONTACT_SEARCH_EVENT);
        }
        return;
      }
      // 搜出了大于100条，继续搜索第二页
      this.dialerSearchTask(teleNumbers);
    }

    if (teleNumbers.length > 1) {
      // 延迟50ms搜索，避免快速输入时，一直搜索
      taskpool.executeDelayed(DELAY_TIME, this.task, taskpool.Priority.HIGH).then(runnable).catch(
        (error: BusinessError) => {
          if (error.message !== dotCommon.eventParam.SEARCH_CONTACT_FAIL_MASSAGE) {
            // 联系人故障打点-搜索通话记录异常
            faultContactParams.FAULT_INFO = error.message;
            DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.CALLLOG_SEARCH_ERROR);
          }
          HiLog.e(TAG, `dialerSearchUniqueKey: ${dialerSearchUniqueKey
          } delay task updateDialerSearchList error: code: ${error.code}, message: ${error.message}`);
        })
    } else {
      taskpool.execute(this.task, taskpool.Priority.HIGH).then(runnable).catch((error: BusinessError) => {
        if (error.message !== dotCommon.eventParam.SEARCH_CONTACT_FAIL_MASSAGE) {
          // 联系人故障打点-搜索通话记录异常
          faultContactParams.FAULT_INFO = error.message;
          DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.CALLLOG_SEARCH_ERROR);
        }
        HiLog.e(TAG, `dialerSearchUniqueKey: ${dialerSearchUniqueKey
        } task updateDialerSearchList error: code: ${error.code}, message: ${error.message}`);
      })

    }
  }

  jumpToContactDetail(detailParam: Record<string, boolean | string>) {
    DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
      if (AppStorage.get('breakpoint') === 'sm') {
        this.pathInfos?.pushPathByName('ContactDetail', detailParam);
      } else {
        this.pathInfos?.replacePathByName('ContactDetail', detailParam);
      }
    });
  }

  jumpToRecordListByPhone(params: RecorderLog) {
    let actionData: Record<string, number> = {
      'id': params.id || -1
    };
    let str: Record<string, Object> = {
      'bundleName': RECORDER_BUNDLE_NAME,
      'abilityName': RECORDER_ABILITY_NAME,
      'parameters': actionData,
      'entities': [
        ENTITIES
      ]
    };
    ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()
      .startAbility(str)
      .then(() => {
        HiLog.w(TAG, 'jumpToCallSetting, startAbility success');
      })
      .catch((error: Error) => {
        HiLog.e(TAG, 'jumpToCallSetting, failed Cause: ' + error?.message);
      })
  }

  jumpToRecordList() {
    let str: Record<string, Object> = {
      'bundleName': RECORDER_BUNDLE_NAME,
      'abilityName': RECORDER_ABILITY_NAME,
      'entities': [
        ENTITIES
      ]
    };
    ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()
      .startAbility(str)
      .then(() => {
        HiLog.w(TAG, 'jumpToCallSetting, startAbility success');
      })
      .catch((error: Error) => {
        HiLog.e(TAG, 'jumpToCallSetting, failed Cause: ' + error?.message);
      })
  }

  jumpBatchDeleteView() {
    DynamicLoader.getInstance().fire(DynamicLoader.BATCH_DELETE_RECORD_PAGE).then(() => {
      this.pathInfos?.pushPathByName('BatchDeleteRecord', '', true);
    });
  }

  jumpToHarassmentFilter() {
    this.pathInfos?.pushPathByName('HarassmentFilter', '');
  }

  jumpToCallSetting() {
    let actionData: Record<string, string> = {
      'pageFlag': PAGE_FLAG
    };
    let str: Record<string, Object> = {
      'bundleName': BUNDLE_NAME,
      'abilityName': ABILITY_NAME,
      'parameters': actionData,
      'entities': [
        ENTITIES
      ]
    };
    ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()
      .startAbility(str)
      .then(() => {
        HiLog.w(TAG, 'jumpToCallSetting, startAbility success');
      })
      .catch((error: Error) => {
        HiLog.e(TAG, 'jumpToCallSetting, failed Cause: ' + error?.message);
      })
  }

  jumpToFeedbackMenu() {
    let context = getContext(this) as common.UIAbilityContext;
    const want: Want = {
      bundleName: 'com.ohos.hiviewcare',
      abilityName: 'FeedBackAbility',
      parameters: {
        pafAppid: '6052',
        bName: 'com.ohos.callui'
      }
    }
    try {
      context.startAbility(want, (err) => {
        if (err.code) {
          HiLog.e(TAG, `jumpToFeedbackMenu startAbility failed, err code: ${err?.code}, message: ${err?.message}`);
        } else {
          HiLog.i(TAG, 'jumpToFeedbackMenu startAbility succeed');
        }
      });
    } catch (err) {
      HiLog.e(TAG, `jumpToFeedbackMenu startAbility failed, err code: ${err?.code}, message: ${err?.message}`);
    }
  }

  isTheValueIsOne(number: string): boolean {
    // Check whether it is a voice mailbox.
    if (number === '1') {
      return true;
    } else {
      return false;
    }
  }

  speedDialAction(uiContext: UIContext, number: string) {
    HiLog.i(TAG, 'speedDialAction: ' + number);
    if (this.isTheValueIsOne(number)) {
      // Check whether a card is available.
      let haveSimCard: boolean = AppStorage.get('haveSimCard') as boolean;
      if (!haveSimCard) {
        this.noSimCardDialogController?.open();
        DialogControllerManager.getInstance().addDialogController(this.noSimCardDialogController);
        return;
      }
    }
    let reg = new RegExp('[1-9]');
    if (reg.test(number)) {
      let context = ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName);
      queryAirPlaneStatus(context, (airplaneOn: boolean) => {
        if (airplaneOn) {
          HiLog.i(TAG, 'airplane on');
          this.airplaneAlertShow(number);
        } else {
          this.speedDialEvent(uiContext, number);
        }
      });
    }
  }

  pasteInit() {
    this.textSelectStart = 0;
    this.textSelectEnd = 0;
  }

  async speedDialEvent(context: UIContext, number: string) {
    if (this.isTheValueIsOne(number)) {
      HiLog.i(TAG, 'voicemail event');
      // For dual SIM cards, select a number in the dialog box that is displayed.
      let haveMultiSimCard: boolean = AppStorage.get('haveMultiSimCard') as boolean;
      if (haveMultiSimCard) {
        AppStorage.setOrCreate('isMultiCardSelected', true);
      } else {
        let defaultSlot: number = AppStorage.get('defaultSlot') as number;
        this.cardSelected(context, defaultSlot);
      }
    } else {
      HiLog.i(TAG, 'speedDial event');
      let speedDialInfo: string = await sharedPreferencesUtils.getFromPreferences('speedDialObjString', '') as string;
      if (speedDialInfo === '') {
        // 联系人打点--长按拨号盘按钮
        DotUtil.getInstance().contactDot(this.customizedParams, PRESS_DIALER_EVENT);
        this.setSpeedNumber = number;
        this.notSetSpeedDialDialogController?.open();
        DialogControllerManager.getInstance().addDialogController(this.notSetSpeedDialDialogController);
        return;
      }
      let speedDial: Record<string, SpeedDialItem> = JSON.parse(speedDialInfo);
      let obj = speedDial[number];
      if (!obj) {
        // 联系人打点--长按拨号盘按钮
        DotUtil.getInstance().contactDot(this.customizedParams, PRESS_DIALER_EVENT);
        this.setSpeedNumber = number;
        this.notSetSpeedDialDialogController?.open();
        DialogControllerManager.getInstance().addDialogController(this.notSetSpeedDialDialogController);
      } else if (!StringUtil.isEmpty(obj.contactTelephone)) {
        HiLog.i(TAG, 'Determine the number of cards.');
        let haveMultiSimCard: boolean = AppStorage.get('haveMultiSimCard') as boolean;
        if (!haveMultiSimCard) {
          // 联系人打点--单卡时拨号盘长按号码直接呼出
          this.callParams.ENC = 7;
          this.callParams.SLOT = AppStorage.Get<number>('defaultSlot');
          this.callParams.ISMULTISIMCARD = 0;
          DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
          RoamingManager.getInstance().handleRoaming(context, obj.contactTelephone);
        } else {
          let defaultSlot: number = AppStorage.get('defaultSlot') as number;
          HiLog.i(TAG, `Speed dialing in dual-SIM mode, defaultSlot is ${defaultSlot}`);
          if (defaultSlot === simId_ONE || defaultSlot === simId_TWO) {
            RoamingManager.getInstance().handleRoaming(context, obj.contactTelephone);
          } else {
            this.all_number = obj.contactTelephone;
            this.editPhoneNumber(this.all_number);
          }
        }
      }
    }
  }

  async cardSelected(context: UIContext, value: number) {
    // Check whether the voice mailbox is set.
    let data: string = await this.voicemailManager.getVoicemailNumber(value);
    if (StringUtil.isEmpty(data)) {
      HiLog.w(TAG, 'getVoiceMailNumber err');
      this.notSetVoicemailDialogController?.open();
      DialogControllerManager.getInstance().addDialogController(this.notSetVoicemailDialogController);
    } else {
      let params: Record<string, number> = {
        'accountId': value
      }
      RoamingManager.getInstance().handleRoaming(context, data, params);
    }
  }

  airplaneAlertShow(number: string) {
    HiLog.i(TAG, 'airplaneAlertShow');
    if (this.isTheValueIsOne(number)) {
      this.airplaneVoiceAlertDialogController?.open();
      DialogControllerManager.getInstance().addDialogController(this.airplaneVoiceAlertDialogController);
    } else {
      this.airplaneSpeedAlertDialogController?.open();
      DialogControllerManager.getInstance().addDialogController(this.airplaneSpeedAlertDialogController);
    }
  }

  handleInputChange(input: string) {
    // 拨号盘支持暗码场景
    this.dealSecretCode(input);
    // we need get before text change caret position, for the case from zero character to one character,
    // the caret change will trigger after text change
    // do special logic for this case
    this.setTextSelectStatusForInit(input.length);
    // formatNumber
    // Whether the dial plate is cut
    let isDialerInputCut: boolean | undefined = AppStorage.get('isDialerInputCut') as boolean | undefined;
    if (isDialerInputCut) {
      //TODO 剪切验证
      input = this.getCutStr(input);
      HiLog.w(TAG, 'cutflag result length: ' + input.length);
      AppStorage.SetOrCreate('isDialerInputCut', false);
    }
    this.setAndFormatNumber(input); //格式化
    //TODO 设置光标位置
    this.setCaret();
  }

  resetTelNumber() {
    HiLog.w(TAG, 'resetTelNumber...')
    AppStorage.setOrCreate('backCallLogPage', 0);
    if (!AppStorage.get('isNavigationModeSplit')) {
      AppStorage.setOrCreate('lastNumber', AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string);
    }
    setTimeout(() => {
      AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_NO_SPACE, '');
      this.all_number = '';
      AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, '');
    }, 150)
  }

  dialerVideoCall(slot: number, isMultiSIMCard: number, hasDefaultSIMCard: number, registeredVoLTECard: number) {
    videoCallParams.ENC = 0;
    videoCallParams.SLOT = slot;
    videoCallParams.ISMULTISIMCARD = isMultiSIMCard;
    videoCallParams.HAS_DEFAULT_SIM_CARD = hasDefaultSIMCard;
    videoCallParams.REGISTERED_VOLTE_CARD = registeredVoLTECard;
    DotUtil.getInstance().contactDot(videoCallParams, dotCommon.eventName.VIDEO_CALLING_EVENT);
  }

  public static unInstance(): void {
    HiLog.w(TAG, 'unInstance...');
    DialerPresenter.mPresenter = null;
  }

  callMenuBoolean(index: number) {
    if (index == 1 || index == 3) {
      return false;
    }
    return true;
  }

  public releasePixelMap() {
    if (this.pixelMapArr) {
      for (let index = 0; index < this.pixelMapArr.length; index++) {
        this.pixelMapArr[index]?.release();
      }
    }
    this.pixelMapArr = [];
    this.imeiStrArr = [];
  }
}