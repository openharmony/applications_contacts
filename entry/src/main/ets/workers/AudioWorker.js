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

import worker from '@ohos.worker';
import media from '@ohos.multimedia.media';
import Log from "@ohos.hilog";

/**
 * dailpad key tone worker
 */
const parentPort = worker.parentPort;
const TAG = "ContactLog";
const DOMAIN = 0x0900;
let audioPlayer = undefined;
let mAudioPath = '';

parentPort.onmessage = function (e) {
    let data = e.data;
    switch (data.type) {
        case "audio":
            if (audioPlayer == undefined) {
                audioPlayer = media.createAudioPlayer();
                audioPlayer.on('dataLoad', () => {
                    audioPlayer.play();
                });
            }
            let fileName = data.data;
            console.log(`fileName is ${JSON.stringify(fileName)}`)
            if (mAudioPath == '') {
                audioPlayer.fdSrc = fileName;
            } else if (mAudioPath == fileName) {
                audioPlayer.seek(0);
                audioPlayer.play();
            } else {
                audioPlayer.reset();
                audioPlayer.fdSrc = fileName;
            }
            mAudioPath = fileName;
            break;
        case "over":
            audioPlayer.release();
            audioPlayer = undefined;
            parentPort.close();
            break;
        default:
            Log.error(DOMAIN, TAG, 'the case is not in this category');
            break;
    }
}