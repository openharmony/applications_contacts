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
import { configPolicy } from '@kit.BasicServicesKit';
import fileIo from '@ohos.file.fs'
import { ContactInfo } from '../model/bean/ContactInfo'
import json from '@ohos.util.json';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import { image } from '@kit.ImageKit';
import { getImagePackingData, saveImageToFile } from './UserPhoto';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import {
  ContactsGlobalThisHelper
} from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import settings from '@ohos.settings';
import { sharedPreferencesUtils, StringUtil } from '../../../../../common';
import { PhoneNumBean } from '../model/bean/PhoneNumBean'
import { EmailBean } from '../model/bean/EmailBean';
import { BusinessError } from '@ohos.base';
import LooseObject from '../model/type/LooseObject';

const TAG = 'PreDefinedContactUtil'
const preDefinedData = 'etc/contacts/predefined_contact_data.json';
const presetServiceContact = 'preset_service_contact';
export class PreDefinedContactUtil {
  public static resultDT: boolean = true;

  static async getPreDefinedContactLoaded() {
    let ret = await sharedPreferencesUtils.getFromPreferences(presetServiceContact, false) as boolean
    HiLog.i(TAG, `getPreDefinedContactLoaded res: ${ret}`);
    return ret;

  }
  static setPreDefinedContactLoaded() {
    sharedPreferencesUtils.saveToPreferences(presetServiceContact, true);
  }

  static async parsePreDefine() {
    HiLog.i(TAG, `addContactFromPredefined`);

    const path: string = await configPolicy.getOneCfgFile(preDefinedData);
    if (!fileIo.accessSync(path)) {
      HiLog.e(TAG, `addContactFromPredefined cannot access predefined file`);
      return;
    }
    let contactInfo: ContactInfo | undefined = undefined;
    let jsonStr: string = '';
    try {
      jsonStr = fileIo.readTextSync(path);
      contactInfo = json.parse(jsonStr) as ContactInfo;
    } catch (error) {
      HiLog.e(TAG, `parsePreDefine error:${error?.message}, stack: ${error?.stack}`);
      return;
    }
    if (contactInfo == undefined) {
      HiLog.e(TAG, `contactInfo empty`);
      return;
    }
    PreDefinedContactUtil.checkPredefinedExist(contactInfo, (contactId: string, rawId: string) => {
      if (StringUtil.isEmpty(contactId)) {
        PreDefinedContactUtil.insertPreDefinedContact(jsonStr);
      } else {
        PreDefinedContactUtil.updatePreDefinedContact(contactInfo, contactId, rawId);
      }
    })
  }

  static getPredefinedPhoto(callBack: Function) {
    try {
      const imgArr = ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getMediaContentSync($r('app.media.predefined_contact_img'));
      let imgResource = image.createImageSource(imgArr.buffer);
      let pixelMap = imgResource.createPixelMapSync({ desiredSize: { height: 270, width: 270 } });
      imgResource.release().catch((error: BusinessError) => {
      });
      let opt: image.PackingOption = { format: 'image/jpeg', quality: 80 };
      const imagePackerApi = image.createImagePacker();
      imagePackerApi.packing(pixelMap, opt).then(async data => {
        imagePackerApi.release();
        if (data) {
          let photo = new Uint8Array(data);
          callBack?.(photo, pixelMap);
        } else {
          callBack?.(null, null);
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'fail to get image packing data: %s', error?.message);
        imagePackerApi.release();
        callBack?.(null, null);
      });
    } catch (error) {
      HiLog.e(TAG, `getPredefinedPhoto error:${error?.message}, stack: ${error?.stack}`);

    }
  }

  static insertPreDefinedContact(jsonStr: string) {
    PreDefinedContactUtil.getPredefinedPhoto((photo: Uint8Array, pixelMap: PixelMap) => {
      PreDefinedContactUtil.insertContactWithInfoAndPhoto(jsonStr, photo, pixelMap);
    })
  }

  static updatePreDefinedContact(contactInfo: ContactInfo | undefined, contactId: string, rawId: string) {
    if (!contactInfo) {
      return;
    }
    PreDefinedContactUtil.getPredefinedPhoto((photo: Uint8Array, pixelMap: PixelMap) => {
      contactInfo.contactID = contactId;
      contactInfo.rowContactID = rawId;
      PreDefinedContactUtil.updateContactWithInfoAndPhoto(JSON.stringify(contactInfo), photo, pixelMap);
    })
  }

  static insertContactWithInfoAndPhoto(contactInfoStr: string, photo: Uint8Array | null, pixelMap: PixelMap | null) {
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('addContact',
        {
          context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
          contactInfoAfter: contactInfoStr,
          photoBlob: photo,
          isMyCard: false
        }, (arg: string[]) => {
          HiLog.i(TAG, `addContactFromPredefined arg:${arg ? arg : 'undefined'}`);

          PreDefinedContactUtil.setPreDefinedContactLoaded();
          let rawId: string = (arg && arg.length > 0) ? arg[0] : '';
          PreDefinedContactUtil.markPreDefinedContact([rawId]);
          if (pixelMap) {
            saveImageToFile(pixelMap, rawId, () => {
              HiLog.i(TAG, `addContactFromPredefined img saved`);
              pixelMap?.release();
            });
          }
        }
      );
  }

  static updateContactWithInfoAndPhoto(contactInfoStr: string, photo: Uint8Array | null, pixelMap: PixelMap | null) {
    HiLog.i(TAG, `updateContactWithInfoAndPhoto ${contactInfoStr}`);
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('updateContact', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
        contactInfoAfter: contactInfoStr,
        photoBlob: photo,
        deletePhoto: pixelMap === null,
        isMyCard: false
      }, (arg: string) => {
        HiLog.i(TAG, `updateContactFromPredefined arg:${arg}`);

        PreDefinedContactUtil.setPreDefinedContactLoaded();
        PreDefinedContactUtil.markPreDefinedContact([arg]);
        if (pixelMap) {
          saveImageToFile(pixelMap, arg, () => {
            HiLog.i(TAG, `addContactFromPredefined img saved`);
            pixelMap?.release();
          });
        }
      });
  }
  static checkPredefinedExist(contactInfo: ContactInfo | undefined, callBack: Function) {
    const name = contactInfo?.display_name;
    let phones: string[] = [];
    contactInfo?.phones.forEach((phone: PhoneNumBean) => {
      phones.push(phone.num);
    })
    let emails: string[] = [];
    contactInfo?.emails.forEach((email: EmailBean) => {
      emails.push(email.address);
    })
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('checkPreDefinedExist',
        {
          name: name,
          phones: phones,
          emails: emails
        },
        (resultList: LooseObject[]) => {
          HiLog.i(TAG, `resultList: ${resultList}`);
          if (resultList.length) {
            callBack?.(resultList[0].contactId, resultList[0].rawId);
          } else {
            callBack?.('');
          }
        });
  }
  static markPreDefinedContact(contactIds: string[]) {
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('markPreDefinedContact',
        {
          contactIds: contactIds
        },
        (result: number) => {

        });
  }

}