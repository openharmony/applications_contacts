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

const TAG = 'NavigationPresenter  ';

/**
 * Navigation bar of the contacts
 */
export default {
  getTabSrc(tabIndex: number, index: number): Resource{
    let imgSrc = $r('app.media.ic_call_filled_actived');
    if (index === 0) {
      imgSrc = $r("app.media.ic_call_filled_normal");
      if (tabIndex === index) {
        imgSrc = $r("app.media.ic_call_filled_actived");
      }
    } else if (index === 1) {
      imgSrc = $r("app.media.ic_contacts_normal_filled");
      if (tabIndex === index) {
        imgSrc = $r("app.media.ic_contacts_actived_filled");
      }
    } else {
      imgSrc = $r("app.media.ic_feature_normal_filled");
      if (tabIndex === index) {
        imgSrc = $r("app.media.ic_feature_actived_filled");
      }
    }
    return imgSrc;
  },

  getTabText(tabIndex: number, index: number): Resource {
    let text = $r('app.string.dialer');
    if (index === 1) {
      text = $r('app.string.contact');
    }
    return text;
  },

  getTabTextColor(tabIndex: number, index: number): Resource{
    let color = $r('sys.color.ohos_id_color_bottom_tab_text_off');
    if (tabIndex === index) {
      color = $r('sys.color.ohos_id_color_connected');
    }
    return color;
  }
}