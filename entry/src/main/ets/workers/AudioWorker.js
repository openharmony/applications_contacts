import worker from '@ohos.worker';
import media from '@ohos.multimedia.media';
import Log from "@ohos.hilog";

/**
 * dailpad key tone worker
 */
const parentPort = worker.parentPort;
const HOST = 'fd://';
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
            let fdNumber = data.data.fd;
            if (mAudioPath == '') {
                let fdPath = HOST + '' + fdNumber;
                audioPlayer.src = fdPath;
            } else if (mAudioPath == fileName) {
                audioPlayer.seek(0);
                audioPlayer.play();
            } else {
                audioPlayer.reset();
                let fdPath = HOST + '' + fdNumber;
                audioPlayer.src = fdPath;
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