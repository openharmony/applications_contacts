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
import CallRecordListDataSource from '../../model/bean/CallRecordListDataSource';
const TAG = 'DialerPresenter';
const SECRET_CODE_START: string = '*#*#';
const SECRET_CODE_END: string = '#*#*';

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
  btnShow: boolean = true;
  isEmergencyNum: boolean = false;
  tele_number: string = '';
  tele_num_size: number = this.NUM_TEXT_FONT_SIZE_MAX;
  all_number: string = '';
  call_p: number = 134;
  call_y: number = 6;
  moveY: number = 336;
  dialerButtonWidth = 48;
  dialerButtonHeight = 48;
  dialerRadius = 24;
  refreshView: boolean;
  callBtnClick: boolean;
  secretCode: string = '';
  isPalyAudioing: boolean = false;
  mAllCallRecordListDataSource: CallRecordListDataSource = new CallRecordListDataSource();
  callLogSearchList: any[] = [];
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
          HiLog.i(TAG, 'callback.state:' + callback.state);
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
    if (StringUtil.isEmpty(phoneNum)) {
      return;
    }
    HiLog.i(TAG, 'editPhoneNumber');
    AppStorage.SetOrCreate('tele_number', phoneNum);
    this.all_number = phoneNum;
    this.viewNumberTextProc();
    this.deleteAddSpace();
//    this.callHistorySearch()
  }

  onDestroy() {
  }

  /*
   * Change the font size when deleting a number.
   */
  deleteTeleNum() {
//    this.callHistorySearch()
    let number: string = AppStorage.Get('tele_number');
    if (this.all_number.length < this.NUM_TEXT_MAX_LENGTH) {
      AppStorage.SetOrCreate('tele_number', this.all_number);
    } else {
      AppStorage.SetOrCreate('tele_number', this.all_number.substr(this.all_number.length - this.NUM_TEXT_MAX_LENGTH));
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
    let number: string = AppStorage.Get('tele_number');
    let teleNumberNoSpace = StringUtil.removeSpace(number);
    this.all_number = StringUtil.removeSpace(this.all_number);
    if (teleNumberNoSpace.length > this.NUM_TEXT_MAXSIZE_LENGTH - 2) {
      AppStorage.SetOrCreate('tele_number', teleNumberNoSpace);
      return;
    }
    if (this.checkNeedNumberSpace(number)) {
      if (teleNumberNoSpace.length <= 3) {
        AppStorage.SetOrCreate('tele_number', teleNumberNoSpace);
        return;
      }
      if (teleNumberNoSpace.length > 3) {
        let split1 = teleNumberNoSpace.substr(0, 3);
        let split2 = teleNumberNoSpace.substr(3, teleNumberNoSpace.length - 3);
        AppStorage.SetOrCreate('tele_number', split1 + ' ' + split2);
        if (teleNumberNoSpace.length > 7) {
          split2 = teleNumberNoSpace.substr(3, 4);
          let split3 = teleNumberNoSpace.substr(7, teleNumberNoSpace.length - 7);
          AppStorage.SetOrCreate('tele_number', split1 + ' ' + split2 + ' ' + split3);
        }
      }
    } else {
      if (teleNumberNoSpace.length > 8) {
        let split4 = teleNumberNoSpace.substr(0, 8);
        let split5 = teleNumberNoSpace.substr(8, teleNumberNoSpace.length - 8);
        AppStorage.SetOrCreate('tele_number', split4 + ' ' + split5);
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
    this.editPhoneNumber('');
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
    let needNumber: string = AppStorage.Get('tele_number');
    switch (needNumber.length) {
      case 3:
        if (this.checkNeedNumberSpace(needNumber)) {
          AppStorage.SetOrCreate('tele_number', needNumber + ' ');
        }
        break;
      case 8:
        AppStorage.SetOrCreate('tele_number', needNumber + ' ');
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
    let number: string = AppStorage.Get('tele_number');
    AppStorage.SetOrCreate('tele_number', numStringNoSpace_all.length > this.NUM_TEXT_MAX_LENGTH ?
    numStringNoSpace_all.substr(numStringNoSpace_all.length - this.NUM_TEXT_MAX_LENGTH) : number
    );
    if (number.length > this.NUM_TEXT_MAXSIZE_LENGTH) {
      AppStorage.SetOrCreate('tele_number', StringUtil.removeSpace(number));
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

  async tonePlayer(type) {
    HiLog.i(TAG, 'TonePlayer type: ' + type);
    let that = this;
    let tonePlayer = null;
    let audioRendererInfo = {
      content: audio.ContentType.CONTENT_TYPE_UNKNOWN,
      usage: audio.StreamUsage.STREAM_USAGE_DTMF,
      rendererFlags: 0
    };

    if (!this.isPalyAudioing) {
      this.isPalyAudioing = true;
      tonePlayer = await audio.createTonePlayer(audioRendererInfo);
      await tonePlayer.load(type);
      await tonePlayer.start();
      setTimeout(async () => {
        that.isPalyAudioing = false;
        await tonePlayer.stop();
        await tonePlayer.release();
      }, 15)
    }
  };

  /*
   * Jump to New Contact
   */
  jumpToAccountants() {
    router.push({
      url: 'pages/contacts/accountants/Accountants',
      params: {
        updataShow: false,
        phoneNumbers: [{
                         phoneNumber: AppStorage.Get('tele_number')
                       }]
      },
    })
  }

  sendMessage() {
    let formatnum = PhoneNumber.fromString(this.all_number).format();
    PhoneNumber.fromString(this.all_number).sendMessage(formatnum, formatnum);
  }

  saveCallRecordExistingContact() {
    HiLog.i(TAG, 'saveCallRecordExistingContact start.');
    router.pushUrl({
      url: 'pages/contacts/batchselectcontacts/SingleSelectContactPage',
      params: {
        phoneNumberShow: AppStorage.Get('tele_number'),
        editContact: 2,
      }
    });
  }

  dealSecretCode(value: string) {
    let length = value.length;
    if (length > 8 && value.startsWith(SECRET_CODE_START) && value.endsWith(SECRET_CODE_END)) {
      let str = value.substring(SECRET_CODE_START.length, length - SECRET_CODE_END.length);
      this.secretCode = str;
    } else {
      this.secretCode = '';
    }
  }

  callHistorySearch() {
    let teleNumber: string = AppStorage.Get('tele_number');
    globalThis.DataWorker.sendRequest('getQueryT9PhoneNumbers', {
      favoriteForm: JSON.stringify({favorite:{teleNumber:teleNumber.replace(/\s*/g,'')}}),
      context: globalThis.context
    }, (result) => {
      let nameArray = [];
      for (let i = 0; i < result.length; i++) {
        nameArray.push(result[i].showName);
        result[i].displayName = result[i]?.showName || result[i]?.phoneNumbers[0]?.phoneNumber || '';
        result[i].phoneNumber = result[i]?.phoneNumbers[0]?.phoneNumber || '';
      }
      const queryCall = {context: globalThis.context,mergeRule: '', actionData: {teleNumber:teleNumber.replace(/\s*/g,''), nameArray}};
      globalThis.DataWorker?.sendRequest('getCallHistorySearch', queryCall, (data) => {
        this.callLogSearchList = [];
        if(data.callLogList.length > 0 || result.length > 0){
          this.callLogSearchList = [...this.callLogSearchList,...result]
          for (let i = 0; i < data.callLogList.length; i++) {
            const displayName = data?.callLogList[i]?.displayName || data?.callLogList[i]?.phoneNumber;
            if(!nameArray.includes(displayName)){
              nameArray.push(displayName)
              this.callLogSearchList.push({...data.callLogList[i], displayName});
            }
          }
        }
        this.mAllCallRecordListDataSource.refreshAll(this.callLogSearchList.sort((a: any, b: any)=> (a.count || 0) - (b.count || 0)));
      })
    })
  }

  jumpToContactDetail(phoneNumber) {
    router.pushUrl(
      {
        url: 'pages/contacts/details/ContactDetail',
        params: {
          sourceHasPhone: true,
          phoneNumberShow: phoneNumber
        }
      }
    )
  }
}