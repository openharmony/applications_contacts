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
import Utils from '../../util/Utils';
import resourceManager from '@ohos.resourceManager';
import media from '@ohos.multimedia.media';
import fileIO from '@ohos.fileio';
import DialUtil from '../../util/DialUtil';
import appStorage from './../../util/AppStorageUtil';
import COMMON from '../../model/common';
import router from '@system.router';
import LooseObject from './../../model/bean/LooseObject'
import featureAbility from '@ohos.ability.featureAbility';
import Constants from './../../model/common/Constants';

const TAG = 'DialerPresenter';
/**
 * 拨号盘 P层
 */
export default class DialerPresenter {
  private static mPresenter: DialerPresenter;

  // 号码编辑框最大可显示号码长度，依据p40为25个数字
  readonly NUM_TEXT_MAX_LENGTH = 20;
  // 号码编辑框 最大字体 70px时的最大长度
  readonly NUM_TEXT_MAXSIZE_LENGTH = 14;
  // 号码编辑框数字最大字体大小，单位px
  readonly NUM_TEXT_FONT_SIZE_MAX = 38;
  readonly TAG = 'DailerTablet';
  readonly HOST = 'fd://';
  readonly BASE_PATH = 'data/app/el1/bundle/public/com.ohos.contacts/com.ohos.contacts/assets/entry/resources/rawfile/';
  // 默认显示拨号盘
  panelShow: boolean = true;
  // 默认不显示收展键
  btnShow: boolean = false;
  // 电话号码
  tele_number: string = ''
  tele_num_size: number = this.NUM_TEXT_FONT_SIZE_MAX;
  audioPlayer: any = undefined;
  mAudioPath: string = '';
  //完整长度号码
  all_number: string = ''

  static getInstance() {
    if (this.mPresenter == null) {
      this.mPresenter = new DialerPresenter();
      appStorage.setAndLink('DialerPresenter', this.mPresenter);
    }
    return this.mPresenter;
  }

  onPageShow() {
    // 呼叫前编辑的号码
    if (appStorage.isEditNumber() && appStorage.getNumTextDialer()) {
      this.tele_number = COMMON.toStrings(appStorage.getNumTextDialer())
    }
  }

  aboutToAppear() {
    this.audioPlayer = media.createAudioPlayer();
    // 音频播放暂时替代
    HiLog.i(TAG, 'keypad tone');
    // 设置'dataLoad'事件回调，src属性设置成功后，触发此回调
    this.audioPlayer.on('dataLoad', () => {
      HiLog.i(TAG, 'audio set source success');
      this.audioPlayer.play();
    });
    this.audioPlayer.on('play', () => {
      HiLog.i(TAG, 'audio play success');
    });
    this.audioPlayer.on('reset', () => {
      HiLog.i(TAG, 'audio reset success');
    });
    this.audioPlayer.on('finish', () => {
      HiLog.i(TAG, 'audio play finish');
    });
  }

  onDestroy() {
    this.audioPlayer.release();
    this.audioPlayer = undefined;
  }

  /*
   * 删除号码时，改变字体大小
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
   * 删除号码时，添加格式化空格
   */
  deleteAddSpace() {
    let teleNumberNoSpace = Utils.removeSpace(this.tele_number);
    this.all_number = Utils.removeSpace(this.all_number);
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
        var split1 = teleNumberNoSpace.substr(0, 3);
        var split2 = teleNumberNoSpace.substr(3, teleNumberNoSpace.length - 3);
        this.tele_number = split1 + ' ' + split2;
      }
      if (teleNumberNoSpace.length > 7) {
        split2 = teleNumberNoSpace.substr(3, 4);
        var split3 = teleNumberNoSpace.substr(7, teleNumberNoSpace.length - 7);
        this.tele_number = split1 + ' ' + split2 + ' ' + split3;
      }
    } else {
      if (teleNumberNoSpace.length > 8) {
        var split4 = teleNumberNoSpace.substr(0, 8);
        var split5 = teleNumberNoSpace.substr(8, teleNumberNoSpace.length - 8);
        this.tele_number = split4 + ' ' + split5;
      }
    }
  }

  /*
   * 输入号码时检查是否需要添加格式化空格
   */
  checkNeedNumberSpace(numText) {
    let isSpace = /[\+;,#\*]/g;
    let isRule = /^\+.*/;
    if (isSpace.test(numText)) { // 号码字符串中包含特殊字符则不添加空格
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
      HiLog.i(TAG, 'dial isEmergencyPhoneNumber : ' + data + ' err : ' + err + ' value : ' + value);
    });
  }

  /*
   * 按键振动
   */
  pressVibrate() {
    vibrator.vibrate(1000, function (error) {
      if (error) {
        HiLog.e(TAG, "pressVibrate error: %s", JSON.stringify(error.message));
      } else {
        HiLog.i(TAG, "Callback returned to indicate a successful vibration.");
      }
    })
  }


  /*
   * 输入号码时添加空格
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
   * 输入号码超长处理
   */
  viewNumberTextProc() {
    // 超长后去除全部空格
    var numStringNoSpace = Utils.removeSpace(this.tele_number);
    var numStringNoSpace_all = Utils.removeSpace(this.all_number);
    this.tele_number = numStringNoSpace_all.length > this.NUM_TEXT_MAX_LENGTH ?
    numStringNoSpace_all.substr(numStringNoSpace_all.length - this.NUM_TEXT_MAX_LENGTH) : this.tele_number;

    if (this.tele_number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_number = Utils.removeSpace(this.tele_number);
    }
    if (this.tele_number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX * this.NUM_TEXT_MAXSIZE_LENGTH / (this.tele_number.length); // 可视号码在16-25位时，适配font-size
    } else {
      this.tele_num_size = this.NUM_TEXT_FONT_SIZE_MAX;
    }
  }

  /*
   * 根据按键数字播放不同音频资源
   */
  playAudio(number) {
    let audioFileName: string = '';
    HiLog.i(TAG, 'SHOW number');
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
    HiLog.i(TAG, 'mAudioPath ');
    if (this.mAudioPath == '') {
      fileIO.open(this.BASE_PATH + audioFileName).then((fdNumber) => {
        let fdPath = this.HOST + '' + fdNumber;
        HiLog.i(TAG, 'first ');
        this.audioPlayer.src = fdPath;
      }).catch(error => {
        HiLog.e(TAG, 'open fd error:%s', JSON.stringify(error.message));
      });
    } else if (this.mAudioPath == audioFileName) {
      this.audioPlayer.seek(0);
      this.audioPlayer.play();
    } else {
      this.audioPlayer.reset();
      fileIO.open(this.BASE_PATH + audioFileName).then((fdNumber) => {
        let fdPath = this.HOST + '' + fdNumber;
        HiLog.i(TAG, 'Show open fd sucess fd');
        this.audioPlayer.src = fdPath;
      }).catch(error => {
        HiLog.e(TAG, 'open fd error:%s', JSON.stringify(error.message));
      });
    }
    this.mAudioPath = audioFileName;
  }
  /*
   * 跳转新建联系人
   */
  jumpToAccountants() {
    router.push({
      uri: "pages/contacts/accountants/Accountants",
      params: {
        //true编辑 false新建
        updataShow: false,
        phoneNumbers: [{phoneNumber: this.all_number}]
      },
    })
  }


  /**
    * 发送消息
    *
    */
  sendMessage() {
    HiLog.i(TAG, 'sendMessage');
    let params = [];
    params.push({
      telephone: this.all_number,
      telephoneFormat: this.all_number
    });
    this.jumpToMms(params);
  }

  /**
     * 跳转短信app
     *
     * @param {string} params 跳转参数
     */
  jumpToMms(params) {
    let actionData: LooseObject = {};
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