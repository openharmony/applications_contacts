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

import vibrator from '@ohos.vibrator';
import HiLog from '../../util/Hilog';
import StringUtil from '../../util/StringUtil';
import DialUtil from '../../util/DialUtil';
import router from '@system.router';
import featureAbility from '@ohos.ability.featureAbility';
import Constants from './../../model/common/Constants';
import { AudioHepler } from '../../feature/AudioHepler';
import PreferencesUtil from './../../util/PreferencesUtil';

const TAG = 'DialerPresenter';
const DENSITY = 1.5;
const NUM_BUTTON_BASIC_LENGTH = 50;

/**
 * dailer presenter
 */
export default class DialerPresenter {
  private static mPresenter: DialerPresenter;
  private audioWorker: AudioHepler;
  readonly NUM_TEXT_MAX_LENGTH = 20;
  readonly NUM_TEXT_MAXSIZE_LENGTH = 14;
  readonly NUM_TEXT_FONT_SIZE_MAX = 38;
  panelShow: boolean = false;
  btnShow: boolean = true;
  tele_number: string = "";
  tele_num_size: number = this.NUM_TEXT_FONT_SIZE_MAX;
  all_number: string = "";
  dialer_w: number = 50;
  dialer_h: number = 50;
  call_w: number = 50;
  call_h: number = 50;
  call_p: number = 130 * DENSITY;
  moveX: number = 0;
  moveY: number = 800;
  refreshView: boolean;

  static getInstance() {
    if (this.mPresenter == null) {
      this.mPresenter = new DialerPresenter();
    }
    return this.mPresenter;
  }

  onPageShow() {
  }

  aboutToAppear() {
    this.audioWorker = new AudioHepler("AudioWorker", "workers/AudioWorker.js");
  }

  editPhoneNumber(phoneNum): void{
    if (StringUtil.isEmpty(phoneNum)) {
      return;
    }
    this.tele_number = phoneNum;
    this.all_number = phoneNum;

    this.btnShow = false;
    this.call_w = NUM_BUTTON_BASIC_LENGTH * DENSITY;
    this.call_h = NUM_BUTTON_BASIC_LENGTH * DENSITY;
    this.dialer_w = NUM_BUTTON_BASIC_LENGTH * DENSITY;
    this.dialer_h = NUM_BUTTON_BASIC_LENGTH * DENSITY;
    this.call_p = 0;
    this.moveX = 0;
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
    DialUtil.getInstance().dial(phoneNumber, (data, err, value) => {
      if (!PreferencesUtil.isUsed()) {
        PreferencesUtil.setIsUsed(true);
        this.refreshView = !this.refreshView;
      }
      HiLog.i(TAG, 'dial isEmergencyPhoneNumber : ' + data + ' err : ' + err + ' value : ' + value);
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
    // 超长后去除全部空格
    let numStringNoSpace = StringUtil.removeSpace(this.tele_number);
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
    let obj = {
      type: "audio", data: audioFileName
    };
    this.audioWorker.postMessage(obj);
  }
  /*
   * Jump to New Contact
   */
  jumpToAccountants() {
    router.push({
      uri: "pages/contacts/accountants/Accountants",
      params: {
        updataShow: false,
        phoneNumbers: [{
                         phoneNumber: this.all_number
                       }]
      },
    })
  }

  sendMessage() {
    HiLog.i(TAG, 'sendMessage');
    let params = [];
    params.push({
      telephone: this.all_number,
      telephoneFormat: this.all_number
    });
    this.jumpToMms(params);
  }

  jumpToMms(params) {
    let actionData: any = {};
    actionData.contactObjects = JSON.stringify(params);
    actionData.pageFlag = 'conversation';
    let str = {
      'want': {
        'bundleName': Constants.string.MMS_BUNDLE_NAME,
        'abilityName': Constants.string.MMS_ABILITY_NAME,
        'parameters': actionData,
        'entities': [
          Constants.string.MMS_ENTITIES,
        ]
      },
    };
    featureAbility.startAbility(str).then((data) => {
      HiLog.i(TAG, 'jumpToMms,success: ');
    }).catch((error) => {
      HiLog.e(TAG, 'jumpToMms,failed: ');
    })
  }
}