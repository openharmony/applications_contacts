import worker from '@ohos.worker';
import fileIO from '@ohos.fileio';
import media from '@ohos.multimedia.media';

/**
 * dailpad key tone worker
 */
const TAG = "AudioWorker";
const parentPort = worker.parentPort;
const HOST = 'fd://';
const BASE_PATH = 'data/app/el1/bundle/public/com.ohos.contacts/com.ohos.contacts/assets/entry/resources/rawfile/';
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
            let audioFileName = data.data;
            if (mAudioPath == '') {
                fileIO.open(BASE_PATH + audioFileName).then((fdNumber) => {
                    let fdPath = HOST + '' + fdNumber;
                    audioPlayer.src = fdPath;
                }).catch(error => {
                });
            } else if (mAudioPath == audioFileName) {
                audioPlayer.seek(0);
                audioPlayer.play();
            } else {
                audioPlayer.reset();
                fileIO.open(BASE_PATH + audioFileName).then((fdNumber) => {
                    let fdPath = HOST + '' + fdNumber;
                    audioPlayer.src = fdPath;
                }).catch(error => {
                });
            }
            mAudioPath = audioFileName;
            break;
        case "over":
            audioPlayer.release();
            audioPlayer = undefined;
            parentPort.close();
            break;
        default:
            break;
    }
}

