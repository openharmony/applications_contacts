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
import { fileIo } from '@kit.CoreFileKit';
import VCardUtil from '../util/VCardUtil';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import { initBlobSourceMap, saveImageToFile, base64StrToPixelMap } from '../util/UserPhoto';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { ContactBlobSource, paramsInterface } from '../model/type';
import { sharedPreferencesUtils } from '../../../../../feature/call/oh_modules/common';
import { taskpool } from '@kit.ArkTS';
import { transWordsInVCard } from './VcardParseUtil';

const TAG = 'VcardImportUtil'

const TMP_FILE_FOLDER = 'importTmp';
const TMP_FILE_NAME = 'importTmpFile.vcf';


export default class VcardImportUtil {
  static importVcardFromWant(want:Want, importCallBack: Function) {
    HiLog.i(TAG, 'importVcardFromWant');
    try {
      let vcfUri = want.uri;
      if (!vcfUri?.endsWith('vcf')) {
        HiLog.i(TAG, 'not vcf file');
        return;
      }

      const srcFile = fileIo.openSync(vcfUri, fileIo.OpenMode.READ_ONLY);
      VcardImportUtil.checkTmpDirExist();
      const tempDir = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().getApplicationContext().tempDir;
      let sandBoxTmpFile = tempDir + '/' + TMP_FILE_FOLDER + '/' + TMP_FILE_NAME;
      if (!VcardImportUtil.copyFileIntoSandBox(srcFile, sandBoxTmpFile)) {
        return;
      }

      let sandBoxImportFile = sandBoxTmpFile + '.vcf'
      let pixelMap = VcardImportUtil.findImgInFile(sandBoxTmpFile, sandBoxImportFile);
      let fileBeforTrans: string = '';
      if (pixelMap) {
        fileBeforTrans = sandBoxImportFile;
        fileIo.rmdirSync(sandBoxTmpFile);
      } else {
        fileBeforTrans = sandBoxTmpFile;
        fileIo.rmdirSync(sandBoxImportFile);
      }

      taskpool.execute(transWordsInVCard, fileBeforTrans, 0).then((fileAfterTrans) => {
        if (typeof fileAfterTrans !== 'string') {
          HiLog.i(TAG, `fileAfterTrans error`);
          return;
        }

        VcardImportUtil.importContact(fileAfterTrans, pixelMap, importCallBack);
      })
    } catch (error) {
      HiLog.e(TAG, `copyFileIntoSandBox error:${error?.message}, stack: ${error?.stack}`);
      return;
    }
  }

  static checkTmpDirExist() {
    const tempDir = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().getApplicationContext().tempDir;
    const tmpFolderPath = tempDir + '/' + TMP_FILE_FOLDER;
    if (!fileIo.accessSync(tmpFolderPath)) {
      try {
        fileIo.mkdirSync(tmpFolderPath);
      } catch (error) {
        HiLog.e(TAG, `mk import file folder error:${error?.message}, stack: ${error?.stack}`);
        return;
      }
    }
  }

  static copyFileIntoSandBox(srcFile: fileIo.File, dstPath: string) {
    let dstFile: fileIo.File | undefined = undefined;
    try {
      if (fileIo.accessSync(dstPath)) {
        fileIo.rmdirSync(dstPath);
      }
      dstFile = fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.copyFileSync(srcFile.fd, dstFile.fd);
      fileIo.closeSync(dstFile);
      return true;
    } catch (error) {
      HiLog.e(TAG, `copyFileIntoSandBox error:${error?.message}, stack: ${error?.stack}`);
      return false;
    }
  }
  static findImgInFile(srcFilePath: string, dstFilePath: string) {
    let dstFile: fileIo.File | undefined = undefined;
    let readIterator = fileIo.readLinesSync(srcFilePath, {
      encoding: 'utf-8'
    });
    let retPixelMap: PixelMap | undefined = undefined;
    try {
      if (fileIo.accessSync(dstFilePath)) {
        fileIo.rmdirSync(dstFilePath);
      }
      dstFile = fileIo.openSync(dstFilePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      let vcardEnd: boolean = false;
      let contactCount = 0;
      for (let it = readIterator.next(); !it.done; it = readIterator.next()) {
        let tmpStr = it.value;
        if (tmpStr.includes('BEGIN:VCARD')) {
          vcardEnd = false;
          if (contactCount++ >= 1) {
            // VCARD文件联系人数量大于2，非碰一碰分享解析，结束查找头像逻辑
            HiLog.i(TAG, `findImgInFile break`);
            break;
          }
        }
        if (!vcardEnd) {
          fileIo.writeSync(dstFile.fd, tmpStr, {
            encoding: 'utf-8'
          });
          if (tmpStr.includes('END:VCARD')) {
            vcardEnd = true;
            continue;
          }
        } else {
          if (tmpStr.includes('contactImg')) {
            continue;
          }
          retPixelMap = base64StrToPixelMap(tmpStr);
          break;
        }
      }
    } catch (error) {
      HiLog.e(TAG, `findImgInFile error:${error?.message}, stack: ${error?.stack}`)
    } finally {
      fileIo.closeSync(dstFile);
    }
    return retPixelMap;
  }

  static requestNewestContact(contactLAvatar: PixelMap | undefined, callBack: Function) {
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('findNewestContact', {}, (contactIds: string[]) =>{
        if (!contactIds.length) {
          HiLog.i(TAG, 'newest contact not found');
          return;
        }
        HiLog.i(TAG, `findNewContact id:${contactIds[0]}`);
        const contactId = contactIds[0];

        if (contactLAvatar) {
          VcardImportUtil.saveAndMarkContactPoster(contactId, contactLAvatar, callBack);
        } else {
          callBack?.(contactId);
        }
      })
  }

  static saveAndMarkContactPoster(contactId: string, contactLAvatar: PixelMap, callBack: Function) {
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('markContactAsPoster', {contactIds: [contactId]}, (result: number) => {
        HiLog.i(TAG, `saveAndMarkContactPoster result:${result}`);

        VcardImportUtil.requestItem(() => {
          saveImageToFile(contactLAvatar, contactId, () => {
            callBack?.(contactId);
          })
        })
      })
  }

  static requestItem(callback?:Function) {
    HiLog.i(TAG, 'Contacts requestItem!');
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('getContactIdWithBlobNotNull', {}, (result: ContactBlobSource[]) => {
        if (result) {
          let map = new Map<string, ContactBlobSource>();
          result.forEach((item: ContactBlobSource) => {
            map.set(item.contactId, item);
          })
          initBlobSourceMap(map);
          AppStorage.setOrCreate('contactListUpdated', new Date().valueOf());
          HiLog.i(TAG, 'Contacts requestItem start');
          callback?.();
        }
      });
  }

  static importContact(file: string, pixelMap: PixelMap | undefined, callBack: Function) {
    const CONTEXT = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let accountId: number = -1;
    sharedPreferencesUtils.getFromPreferences('accountType', -1).then(value => {
      accountId = value as number;
    })
    VCardUtil.importVCard(CONTEXT, file, accountId, (success: boolean) => {
      HiLog.i(TAG, `import Vcard from want success:${success}`);
      fileIo.rmdir(file);
      if (success) {
        setTimeout(() => {
          VcardImportUtil.requestNewestContact(pixelMap, callBack);
        }, 1500)

      }
    });
  }
}