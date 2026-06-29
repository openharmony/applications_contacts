/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import media from '@ohos.multimedia.media';
import HashMap from '@ohos.util.HashMap';
import fs from '@ohos.file.fs'
import audio from '@ohos.multimedia.audio';
import { HiLog, StringUtil } from '../../../../../../common';
import { BusinessError } from '@ohos.base';

const TAG: string = 'ResourceAudioManager';

/**
 * Internal Audio Manager which works with audio resources
 */
class ResourceAudioManager {
  private players: HashMap<string, media.AVPlayer> = new HashMap();
  private ringPlayer?: media.AVPlayer = undefined;
  private ringToneFile: fs.File | undefined = undefined;

  public dataChange: boolean = false;

  async playFromFileOnce(filePath: string) {
    HiLog.i(TAG, `play from file once, file at : ${(StringUtil.maskSensitiveInfo(filePath))}`);
    try {
      if (this.ringToneFile) {
        fs.closeSync(this.ringToneFile);
      }
    } catch (err) {
      HiLog.e(TAG, `playFromFileOnce fs closeSync error: code: ${err.code} message: ${err.message}`);
    }
    const loopFlag: boolean = false;
    await this.ringPlayer?.release();
    this.ringPlayer = await this.createFilePlayer(filePath, loopFlag);
    HiLog.i(TAG, `playFromFileOnce done`);
  }

  async playFromFileLoop(filePath: string) {
    HiLog.i(TAG, `play from file loop`);
    const loopFlag: boolean = true;
    await this.ringPlayer?.release();
    this.ringPlayer = await this.createFilePlayer(filePath, loopFlag);
    HiLog.i(TAG, `playFromFileLoop done`);
  }

  private async createFilePlayer(filePath: string, loop: boolean): Promise<media.AVPlayer> {
    let player: media.AVPlayer = await media.createAVPlayer();
    if (!filePath) {
      HiLog.e(TAG, `empty filePath`);
      return player;
    }
    this.setCallback(player, loop, filePath);
    let f: fs.File | undefined = undefined;
    try {
      let fdPath = 'fd://';
      f = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      this.ringToneFile = f;
      fdPath = fdPath + '' + f.fd;
      HiLog.i(TAG, `fd: ${f.fd}`);
      player.url = fdPath;
    } catch (err) {
      HiLog.e(TAG, ` error: code: ${err.code} message: ${err.message}`);
    } finally {
    }
    return player;
  }

  releaseRing() {
    HiLog.i(TAG, `releaseRing`);
    this.ringPlayer?.release();
    try {
      if (this.ringToneFile) {
        fs.closeSync(this.ringToneFile);
      }
    } catch (err) {
      HiLog.e(TAG, `releaseRing fs closeSync error: code: ${err.code} message: ${err.message}`);
    }
  }

  setCallback(player: media.AVPlayer, loop: boolean, resourceFileName: string = '') {
    player.on('stateChange', async (state, reason) => {
      HiLog.i(TAG, `setCallback stateChange: ${state} ${reason}`);
      switch (state) {
        case 'initialized': {
          let audioRendererInfo: audio.AudioRendererInfo = {
            content: audio.ContentType.CONTENT_TYPE_UNKNOWN,
            usage: audio.StreamUsage.STREAM_USAGE_RINGTONE,
            rendererFlags: 0
          };
          player.audioRendererInfo = audioRendererInfo;
          player.prepare();
          break;
        }
        case 'prepared': {
          player.setVolume(1.0);
          player.loop = loop;
          player.play();
          break;
        }
        case 'completed': {
          player.stop();
          break;
        }
        case 'stopped': {
          player.release();
          break;
        }
        case 'released': {
          break;
        }
      }
    });
    player.on('error', async (error: BusinessError) => {
      HiLog.e(TAG, `audio player error code: ${error?.code}`);
      HiLog.e(TAG, `audio player error message: ${error?.message}`);
    });
    player.on('audioInterrupt', async (info: audio.InterruptEvent) => {
      HiLog.i(TAG, 'audioInterrupt:' + resourceFileName);
      if (info.hintType === audio.InterruptHint.INTERRUPT_HINT_STOP) {
        try {
          await player?.stop();
          player?.release();
        } catch (error) {
          HiLog.e(TAG, `Failed to stopPlayerFor, error code: ${error?.code}, error message: ${error?.message}`);
        }
      }
    });
  }

}

export default new ResourceAudioManager();