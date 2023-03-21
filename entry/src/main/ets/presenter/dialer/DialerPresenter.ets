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
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import audio from '@ohos.multimedia.audio';
import router from '@ohos.router';
import observer from '@ohos.telephony.observer';
import PreferencesUtil from '../../util/PreferencesUtil';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import IndexPresenter from '../IndexPresenter';

const TAG = 'DialerPresenter';

/**
 * dialer presenter
 */
export default class DialerPresenter {
  private static mPresenter: DialerPresenter;
  private _isCallStateChangeObserved = false;
  readonly NUM_TEXT_MAX_LENGTH = 20;
  readonly NUM_TEXT_MAXSIZE_LENGTH = 14;
  readonly NUM_TEXT_FONT_SIZE_MAX = 38;
  private timer: any = null;
  panelShow: boolean = false;
  btnShow: boolean = true;
  isClickDelete: boolean = false;
  isEmergencyNum: boolean = false;
  tele_number: string = "";
  tele_num_size: number = this.NUM_TEXT_FONT_SIZE_MAX;
  all_number: string = "";
  call_p: number = 134;
  call_y: number = 6;
  moveY: number = 336;
  dialerButtonWidth = 48;
  dialerButtonHeight = 48;
  dialerRadius = 24;
  refreshView: boolean;
  callBtnClick: boolean;

  static getInstance() {
    if (this.mPresenter == null) {
      this.mPresenter = new DialerPresenter();
    }
    return this.mPresenter;
  }

  aboutToAppear() {
    if (!PreferencesUtil.isUsed() && !this._isCallStateChangeObserved) {
      observer.on('callStateChange', (callback: {
        state,
        number,
      }) => {
        HiLog.i(TAG, 'callStateChange state' + callback.state);
        if (callback.state === 0) {
          HiLog.i(TAG, "callback.state:" + callback.state);
          this.refresh();
        }
      });
      this._isCallStateChangeObserved = true;
    }
  }

  refresh() {
    if (!PreferencesUtil.isUsed()) {
      PreferencesUtil.setIsUsed(true);
      this.refreshView = !this.refreshView;
    }
  }

  editPhoneNumber(phoneNum): void {
    if (StringUtil.isEmpty(phoneNum) || this.isClickDelete) {
      this.isClickDelete = false;
      return;
    }
    AppStorage.SetOrCreate("tele_number", phoneNum);
    this.all_number = phoneNum;
    this.viewNumberTextProc();
    this.deleteAddSpace();
  }

  onDestroy() {
  }

  /*
   * Change the font size when deleting a number.
   */
  deleteTeleNum() {
    let number: string = AppStorage.Get("tele_number");
    if (this.all_number.length < this.NUM_TEXT_MAX_LENGTH) {
      AppStorage.SetOrCreate("tele_number", this.all_number);
    } else {
      AppStorage.SetOrCreate("tele_number", this.all_number.substr(this.all_number.length - this.NUM_TEXT_MAX_LENGTH));
    }
    if (number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX * this.NUM_TEXT_MAXSIZE_LENGTH / number.length;
    } else if (number.length <= this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX;
    }
  }

  /*
   * Add formatting spaces when deleting a number.
   */
  deleteAddSpace() {
    let number: string = AppStorage.Get("tele_number");
    let teleNumberNoSpace = StringUtil.removeSpace(number);
    this.all_number = StringUtil.removeSpace(this.all_number);
    if (teleNumberNoSpace.length > this.NUM_TEXT_MAXSIZE_LENGTH - 2) {
      AppStorage.SetOrCreate("tele_number", teleNumberNoSpace);
      return;
    }
    if (this.checkNeedNumberSpace(number)) {
      if (teleNumberNoSpace.length <= 3) {
        AppStorage.SetOrCreate("tele_number", teleNumberNoSpace);
        return;
      }
      if (teleNumberNoSpace.length > 3) {
        let split1 = teleNumberNoSpace.substr(0, 3);
        let split2 = teleNumberNoSpace.substr(3, teleNumberNoSpace.length - 3);
        AppStorage.SetOrCreate("tele_number", split1 + ' ' + split2);
        if (teleNumberNoSpace.length > 7) {
          split2 = teleNumberNoSpace.substr(3, 4);
          let split3 = teleNumberNoSpace.substr(7, teleNumberNoSpace.length - 7);
          AppStorage.SetOrCreate("tele_number", split1 + ' ' + split2 + ' ' + split3);
        }
      }
    } else {
      if (teleNumberNoSpace.length > 8) {
        let split4 = teleNumberNoSpace.substr(0, 8);
        let split5 = teleNumberNoSpace.substr(8, teleNumberNoSpace.length - 8);
        AppStorage.SetOrCreate("tele_number", split4 + ' ' + split5);
      }
    }
  }

  /*
   * Check whether formatting spaces are required when entering a number.
   */
  checkNeedNumberSpace(numText) {
    let isSpace = /[\+;,#\*]/g;
    let isRule = /^\+.*/;
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

  dialing(phoneNumber, options?: any) {
    IndexPresenter.getInstance().editPhoneNumber = "";
    PhoneNumber.fromString(phoneNumber).dial(options).then((rst) => {
      this.refresh();
    });
  }

  /*
   * Key vibration
   */
  pressVibrate() {
  }

  /*
   * Add a space when entering a number.
   */
  ifNeedSpace() {
    let needNumber: string = AppStorage.Get("tele_number");
    switch (needNumber.length) {
      case 3:
        if (this.checkNeedNumberSpace(needNumber)) {
          AppStorage.SetOrCreate("tele_number", needNumber + ' ');
        }
        break;
      case 8:
        AppStorage.SetOrCreate("tele_number", needNumber + ' ');
        break;
      default:
        break;
    }
  }

  /*
   * Processing of Overlong Input Numbers
   */
  viewNumberTextProc() {
    let numStringNoSpace_all = StringUtil.removeSpace(this.all_number);
    let number: string = AppStorage.Get("tele_number");
    AppStorage.SetOrCreate("tele_number", numStringNoSpace_all.length > this.NUM_TEXT_MAX_LENGTH ?
    numStringNoSpace_all.substr(numStringNoSpace_all.length - this.NUM_TEXT_MAX_LENGTH) : number
    );
    if (number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      AppStorage.SetOrCreate("tele_number", StringUtil.removeSpace(number));
    }
    if (number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX * this.NUM_TEXT_MAXSIZE_LENGTH / (number.length); // 可视号码在16-25位时，适配font-size
    } else {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX;
    }
  }

  /*
   * Play different audio resources based on key digits.
   */
  playAudio(number) {
    switch (number.toString()) {
      case '1':
        this.tonePlayer(1);
        break;
      case '2':
        this.tonePlayer(2);
        break;
      case '3':
        this.tonePlayer(3);
        break;
      case '4':
        this.tonePlayer(4);
        break;
      case '5':
        this.tonePlayer(5);
        break;
      case '6':
        this.tonePlayer(6);
        break;
      case '7':
        this.tonePlayer(7);
        break;
      case '8':
        this.tonePlayer(8);
        break;
      case '9':
        this.tonePlayer(9);
        break;
      case '0':
        this.tonePlayer(0);
        break;
      case '*':
        this.tonePlayer(10);
        break;
      case '#':
        this.tonePlayer(11);
        break;
      default:
        HiLog.e(TAG, "keytone src is error");
    }
  }

  async tonePlayer(type) {
    HiLog.i(TAG, 'TonePlayer');
    if (this.timer) clearTimeout(this.timer);
    let tonePlayer = null;
    let audioRendererInfo = {
      content: 5,
      usage: 6,
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
        HiLog.e(TAG, 'tonePlayer err = ' + JSON.stringify(err));
      }
    }, 50)
  };

  /*
   * Jump to New Contact
   */
  jumpToAccountants() {
    router.push({
      url: "pages/contacts/accountants/Accountants",
      params: {
        updataShow: false,
        phoneNumbers: [{
                         phoneNumber: AppStorage.Get("tele_number")
                       }]
      },
    })
  }

  sendMessage() {
    let formatnum = PhoneNumber.fromString(this.all_number).format();
    PhoneNumber.fromString(this.all_number).sendMessage(formatnum, formatnum);
  }
}