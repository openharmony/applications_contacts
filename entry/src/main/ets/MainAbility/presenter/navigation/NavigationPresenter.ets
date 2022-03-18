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
 * 进入联系人底部导航栏
 */
export default {
  getTabSrc(tabIndex: number, index: number): Resource{
    let imgSrc = $r('app.media.phone')
    if (index === 0) {
      imgSrc = $r("app.media.ic_phonecall_m")
    } else if (index === 1) {
      imgSrc = $r("app.media.ic_contacts_m")
    } else {
      imgSrc = $r("app.media.ic_contacts_favorite_m")
    }
    return imgSrc
  },

  getTabText(tabIndex: number, index: number): Resource {
    let text = $r('app.string.dialer')
    if (index === 1) {
      text = $r('app.string.contact')
    }
    return text
  },

  getTabTextColor(tabIndex: number, index: number): string{
    let color = '#66182431'
    if (tabIndex === index) {
      color = '#00CB87'
    }
    return color
  }
}