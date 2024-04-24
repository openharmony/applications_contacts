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

import router from '@ohos.router';
import pasteboard from '@ohos.pasteboard';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../common/src/main/ets/util/StringUtil';
import StringFormatUtil from '../util/StringFormatUtil';
import { missedCallManager } from '../feature/missedCall/MissedCallManager';
import CallRecordPresenter from './dialer/callRecord/CallRecordPresenter';
import FavoriteListPresenter from './favorite/FavoriteListPresenter';

const TAG = 'IndexPresenter  ';

export default class IndexPresenter {
  private static instance: IndexPresenter;

  public static getInstance(): IndexPresenter {
    if (!IndexPresenter.instance) {
      IndexPresenter.instance = new IndexPresenter();
    }
    return IndexPresenter.instance;
  }

  onPageShow() {
    HiLog.i(TAG, 'onPageShow !!!');
    this.cancelMissedCallNotification()
    if (parseInt(StringFormatUtil.judgeSysTime()) !== AppStorage.Get('sysTime')) {
      HiLog.i(TAG, 'DO requestItem cause systemTime changed');
      CallRecordPresenter.getInstance().requestItem();
      AppStorage.SetOrCreate('sysTime', parseInt(StringFormatUtil.judgeSysTime()));
    }
  }

  getCurrentUrl(){
    let url = router.getState().path+router.getState().name;
    HiLog.i(TAG,'getCurrentUrl:'+url)
    return url;
  }

  goToPage(url: string, pageIndex?: number, params?) {
    HiLog.i(TAG, 'goToPage: ' + url);
    if (pageIndex != undefined && router.getState().index >= pageIndex) {
      if (url == globalThis.presenterManager?.mainUrl || this.getCurrentUrl() == url) {
        router.back({
          url: url,
          params: params
        })
        return;
      }
      router.replaceUrl({
        url: url,
        params: params
      });
    } else {
      router.pushUrl({
        url: url,
        params: params
      });
    }
  }

  cancelMissedCallNotification() {
    HiLog.i(TAG, `cancelMissedCallNotification`);
    missedCallManager.cancelNotification()
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear !!!');
    AppStorage.SetOrCreate('sysTime', parseInt(StringFormatUtil.judgeSysTime()));
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear !!!');
  }

  getCopy(phoneNumber) {
    HiLog.i(TAG, 'Succeeded PasteData is ' + JSON.stringify(phoneNumber));
    let pasteData = pasteboard.createPlainTextData(phoneNumber);
    let systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setPasteData(pasteData, (err, data) => {
      if (err) {
        HiLog.e(TAG, 'Failed to set PasteData. Cause: ' + JSON.stringify(err.message));
        return;
      }
      HiLog.i(TAG, 'Succeeded in setting PasteData.');
    });
  }

  getTabSrc(tabIndex: number, index: number): Resource {
    let imgSrc = $r('app.media.ic_call_filled_normal');
    if (index === 1) {
      imgSrc = $r('app.media.ic_contacts_normal_filled');
    }
    if (index === 2) {
      imgSrc = $r('app.media.ic_feature_normal_filled');
    }
    return imgSrc;
  }

  getTabText(tabIndex: number, index: number): Resource {
    let text = $r('app.string.dialer');
    if (index === 1) {
      text = $r('app.string.contact');
    }
    if (index === 2) {
      text = $r('app.string.favorite');
    }
    return text;
  }

  getTabTextColor(tabIndex: number, index: number): Resource {
    let color = $r('sys.color.ohos_id_color_bottom_tab_text_off');
    if (tabIndex === index) {
      color = $r('sys.color.ohos_id_color_connected');
    }
    return color;
  }
}