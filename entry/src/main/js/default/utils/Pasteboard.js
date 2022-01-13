/*
* Copyright (c) 2021 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the 'License');
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an 'AS IS' BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import pasteboard from '@ohos.pasteboard';
import LOG from '../utils/ContactsLog.js';
var TAG = 'pasteBoard';

let commonPasteboard = {

    getPasteboard() {
        let sysPasteboard = pasteboard.getSystemPasteboard();
        return sysPasteboard.getPasteData();
    },
    setPasteboard(text) {
        let sysPasteboard = pasteboard.getSystemPasteboard();
        let textData = pasteboard.createPlainTextData(text);
        sysPasteboard.setPasteData(textData, () => {
            LOG.info(TAG + 'setPasteboard' + 'pasteboard setPasteData done');
        });
    }
};

export {commonPasteboard};