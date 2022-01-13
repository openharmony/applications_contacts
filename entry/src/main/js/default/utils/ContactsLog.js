/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const APP_TAG = 'Contacts JS: timestamp: ';

export default {
    data: {
        pageTag: ' msg: '
    },
    debug(msg) {
        console.debug(APP_TAG + new Date().getTime() + this.data.pageTag + msg);
    },
    log(msg) {
        console.log(APP_TAG + new Date().getTime() + this.data.pageTag + msg);
    },
    info(msg) {
        console.info(APP_TAG + new Date().getTime() + this.data.pageTag + msg);
    },
    warn(msg) {
        console.warn(APP_TAG + new Date().getTime() + this.data.pageTag + msg);
    },
    error(msg) {
        console.error(APP_TAG + new Date().getTime() + this.data.pageTag + msg);
    }
}