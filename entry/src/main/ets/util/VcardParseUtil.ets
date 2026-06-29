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
import fs from '@ohos.file.fs';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import VCardUtil from './VCardUtil'

/*
   *filePath should be a sandbox path
   *transFlag 0:import 1:export
   * */
@Concurrent
export function transWordsInVCard(filePath: string, transFlag: number) : string {
  HiLog.i('VcardParseUtil', `transWordsInVcard start fransFlag:${transFlag}`);
  let readerIterator = fs.readLinesSync(filePath, {encoding: 'utf-8'});
  let tmpFile: fs.File | undefined = undefined;
  let retPath: string = '';
  try {
    tmpFile = fs.openSync(filePath + '.vcf', fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    for (let it = readerIterator.next(); !it.done; it = readerIterator.next()) {
      let tmpStr = VCardUtil.transPatterns(it.value, transFlag);
      fs.writeSync(tmpFile.fd, tmpStr, {
        encoding: 'utf-8'
      });
      retPath = tmpFile.path;
    }
  } catch (e) {
    HiLog.e('VcardParseUtil', `transWordsInVCard error ${e?.message}, stack: ${e?.stack}`);
  } finally {
    fs.closeSync(tmpFile);
  }
  return retPath;
}

