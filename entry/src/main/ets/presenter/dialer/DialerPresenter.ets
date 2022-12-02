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
import router from '@ohos.router';
import observer from '@ohos.telephony.observer';
import { AudioHepler } from '../../feature/AudioHepler';
import PreferencesUtil from '../../util/PreferencesUtil';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import IndexPresenter from '../IndexPresenter';

const TAG = 'DialerPresenter';

/**
 * dialer presenter
 */
export default class DialerPresenter {
  private static mPresenter: DialerPresenter;
  private audioWorker: AudioHepler;
  private _isCallStateChangeObserved = false;
  readonly NUM_TEXT_MAX_LENGTH = 20;
  readonly NUM_TEXT_MAXSIZE_LENGTH = 14;
  readonly NUM_TEXT_FONT_SIZE_MAX = 38;
  panelShow: boolean = false;
  btnShow: boolean = true;
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
    this.audioWorker = new AudioHepler("AudioWorker", "entry/ets/workers/AudioWorker.js");
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

  editPhoneNumber(phoneNum): void{
    if (StringUtil.isEmpty(phoneNum)) {
      return;
    }
    this.tele_number = phoneNum;
    this.all_number = phoneNum;

    this.btnShow = false;
    this.call_p = 0;
    this.moveY = 0

    this.deleteTeleNum();
    this.deleteAddSpace();
    this.viewNumberTextProc();
  }

  onDestroy() {
    this.audioWorker.postMessage({
      type: "over"
    })
  }

  /*
   * Change the font size when deleting a number.
   */
  deleteTeleNum() {
    if (this.all_number.length < this.NUM_TEXT_MAX_LENGTH) {
      this.tele_number = this.all_number;
    } else {
      this.tele_number = this.all_number.substr(this.all_number.length - this.NUM_TEXT_MAX_LENGTH)
    }
    if (this.tele_number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX * this.NUM_TEXT_MAXSIZE_LENGTH / this.tele_number.length;
    } else if (this.tele_number.length <= this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX;
    }
  }

  /*
   * Add formatting spaces when deleting a number.
   */
  deleteAddSpace() {
    let teleNumberNoSpace = StringUtil.removeSpace(this.tele_number);
    this.all_number = StringUtil.removeSpace(this.all_number);
    if (teleNumberNoSpace.length > this.NUM_TEXT_MAXSIZE_LENGTH - 2) {
      this.tele_number = teleNumberNoSpace;
      return;
    }
    if (this.checkNeedNumberSpace(this.tele_number)) {
      if (teleNumberNoSpace.length <= 3) {
        this.tele_number = teleNumberNoSpace;
        return;
      }
      if (teleNumberNoSpace.length > 3) {
        let split1 = teleNumberNoSpace.substr(0, 3);
        let split2 = teleNumberNoSpace.substr(3, teleNumberNoSpace.length - 3);
        this.tele_number = split1 + ' ' + split2;
        if (teleNumberNoSpace.length > 7) {
          split2 = teleNumberNoSpace.substr(3, 4);
          let split3 = teleNumberNoSpace.substr(7, teleNumberNoSpace.length - 7);
          this.tele_number = split1 + ' ' + split2 + ' ' + split3;
        }
      }
    } else {
      if (teleNumberNoSpace.length > 8) {
        let split4 = teleNumberNoSpace.substr(0, 8);
        let split5 = teleNumberNoSpace.substr(8, teleNumberNoSpace.length - 8);
        this.tele_number = split4 + ' ' + split5;
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

  dialing(phoneNumber) {
    IndexPresenter.getInstance().editPhoneNumber = "";
    PhoneNumber.fromString(phoneNumber).dial().then((rst) => {
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
    switch (this.tele_number.length) {
      case 3:
        if (this.checkNeedNumberSpace(this.tele_number)) {
          this.tele_number = this.tele_number + ' ';
        }
        break;
      case 8:
        this.tele_number = this.tele_number + ' ';
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
    this.tele_number = numStringNoSpace_all.length > this.NUM_TEXT_MAX_LENGTH ?
    numStringNoSpace_all.substr(numStringNoSpace_all.length - this.NUM_TEXT_MAX_LENGTH) : this.tele_number;

    if (this.tele_number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_number = StringUtil.removeSpace(this.tele_number);
    }
    if (this.tele_number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX * this.NUM_TEXT_MAXSIZE_LENGTH / (this.tele_number.length); // 可视号码在16-25位时，适配font-size
    } else {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX;
    }
  }

  /*
   * Play different audio resources based on key digits.
   */
  playAudio(number) {
    let audioFileName: string = '';
    switch (number.toString()) {
      case '1':
        audioFileName = '1.ogg';
        break;
      case '2':
        audioFileName = '2.ogg';
        break;
      case '3':
        audioFileName = '3.ogg';
        break;
      case '4':
        audioFileName = '4.ogg';
        break;
      case '5':
        audioFileName = '5.ogg';
        break;
      case '6':
        audioFileName = '6.ogg';
        break;
      case '7':
        audioFileName = '7.ogg';
        break;
      case '8':
        audioFileName = '8.ogg';
        break;
      case '9':
        audioFileName = '9.ogg';
        break;
      case '0':
        audioFileName = '0.ogg';
        break;
      case '*':
        audioFileName = '10.ogg';
        break;
      case '#':
        audioFileName = '11.ogg';
        break;
      default:
        HiLog.e(TAG, "keytone src is error");
    }
    this.onResourceManager(audioFileName);
  }

  async onResourceManager(FileName) {
    HiLog.i(TAG, "getResourceManager start , FileName is :  " + FileName);
    let fileDescriptor = null;
      HiLog.i(TAG, "into getResourceManager ");
      globalThis.context.resourceManager.getRawFileDescriptor(FileName).then(value => {
        HiLog.i(TAG, "getRawFileDescriptor value");
        fileDescriptor = {
          fd: value.fd,
          offset: value.offset,
          length: value.length
        };
        let obj = {
          type: "audio", data: fileDescriptor
        };
        HiLog.i(TAG, "getRawFile fileDescriptor is  " + JSON.stringify(obj));
        this.audioWorker.postMessage(obj);
      }).catch(error => {
        HiLog.e(TAG, "getRawFile promise error is " + JSON.stringify(error));
      });
  }

  /*
   * Jump to New Contact
   */
  jumpToAccountants() {
    router.push({
      url: "pages/contacts/accountants/Accountants",
      params: {
        updataShow: false,
        phoneNumbers: [{
                         phoneNumber: this.all_number
                       }]
      },
    })
  }

  sendMessage() {
    let formatnum = PhoneNumber.fromString(this.all_number).format();
    PhoneNumber.fromString(this.all_number).sendMessage(formatnum, formatnum);
  }
}