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
import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import WorkFactory, { WorkerType } from '../workers/WorkFactory';
import { HiLog, sharedPreferencesUtils } from '../../../../../common'
import dataShare from '@ohos.data.dataShare';
import { FormCardController } from '../card/common/FormCardController';
import { SpeedDialCardDataType } from '../card/type/speedDialCardType';
import Want from '@ohos.app.ability.Want';
import { PhonesType } from '../card/type/shortcut';
import { ContactBlobSource, ContactReturnObj } from '../model/type';
import { contactPage } from '../card/data/cardData';
import LooseObject from '../model/type/LooseObject';
import { getHeadChar, getPixelMapFromFile } from '../util/UserPhoto';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ContactRepository, Contacts, Data } from '../../../../../feature/contact';
import buffer from '@ohos.buffer';
import { MissedCallNotifier } from '../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier';
import {
  ContactsGlobalThisHelper
} from '../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import call from '@ohos.telephony.call';
import SimManager from '../feature/sim/SimManager';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import image from '@ohos.multimedia.image';
import DotUtil from '../util/DotUtil';
import dotCommon, { contactParams } from '../util/DotCommon';
import { RawContacts } from '../../../../../feature/contact/src/main/ets/contract/RawContacts';
import taskPool from '@ohos.taskpool';
import { formProvider } from '@kit.FormKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { DataShareResultSet } from '@kit.ArkData';
import { ObjectUtil } from '../../../../../common/src/main/ets/util/ObjectUtil';

interface intentType {
  intentName: string
  intentParams: intentParam
};

interface intentParam {
  entityId: string | number
}

interface FormDataType {
  contact?: string,
  formId?: string,
  title?: string,
  isHasVoiceCapability?: boolean,
  speedDialCardH?:number
}

export interface NewContactItem {
  displayName: string | number
  id: string
}

const TAG = 'CardEntryFormAbility';
const CALLLOGSQL = `SELECT * FROM calllog WHERE is_read = 0 AND call_direction = 0 AND
  answer_state  = 0 AND strftime('%s', datetime('now' )) - create_time < 86400
  ORDER BY create_time DESC`

const callLogScheduler = `SELECT remindTimer(MIN(create_time + 86400) * 1000) AS min_time FROM (
  SELECT create_time FROM calllog WHERE is_read = 0 AND call_direction = 0 AND
  answer_state = 0 AND strftime('%s', datetime('now') ) - create_time < 86400
  ORDER BY create_time DESC)`

export default class EntryFormAbility extends FormExtensionAbility {
  public mFormCardController: FormCardController = FormCardController.getInstance();
  public mDataWorker = WorkFactory.getWorker(WorkerType.DataWorker);
  public haveSimCard: boolean = false;
  public haveMultiSimCard: boolean = false;
  public testData: Array<Object> = [];
  public speedDialCardH: number = 0;

  onAddForm(want: Want) {
    ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.CardContextName, this.context)
    HiLog.w(TAG, 'want-x abilityName:' + want?.abilityName);
    const formIdKey: string = 'ohos.extra.param.key.form_identity';
    const formNameKey: string = 'ohos.extra.param.key.form_name';
    let temp = want.parameters;
    let formName: string = '';
    let formId: string = '';
    if (temp !== null && temp !== undefined) {
      formName = temp[formNameKey] as string;
      formId = temp[formIdKey] as string;
      this.speedDialCardH = temp['ohos.extra.param.key.form_height'] as number;
    }

    HiLog.w(TAG, `[formName]: ${formName} [formId]: ${formId}`)

    let formBinding: formBindingData.FormBindingData = this.onAddProxies(formId, formName);
    setTimeout(() => {
      if (want?.parameters?.formWantInfo) {
        this.onAddIntentInfo(formId, formName);
      } else {
        this.onAddToUpdate(formId, formName);
      }
    }, 0);
    this.updateSpeedDialCardIdList(formId, 'add', formName);
    return formBinding;
  }

  onAddIntentInfo(formId: string, formName: string) {
    if (formName === 'MissedCall') {
      HiLog.w(TAG, `Small Art Suggestions build missCallCard formId: ${formId}`)
      this.onAddTemplateToMissedCall(formId);
    }
  }

  async onAddToUpdate(formId: string, formName: string) {
    MissedCallNotifier.getInstance().init(this.context)
    if (formName === 'MissedCall') {
      this.onAddTemplateToMissedCall(formId);
    } else if (formName === 'shortcut') {
      let hasData: SpeedDialCardDataType[] = await this.queryContactByFormId(formId, formName)
      HiLog.w(TAG, `onAddToUpdate hasDataLength: ${hasData?.length}, formName: ${formName}, formId: ${formId}`)
      this.onAddTemplateToShortcut(formId, hasData);
    } else if (formName === 'SpeedDial') {
      let hasData: SpeedDialCardDataType[] = await this.queryContactByFormId(formId, formName)
      HiLog.w(TAG, `onAddToUpdate hasDataLength: ${hasData?.length}, formName: ${formName}, formId: ${formId}`)
      this.onAddTemplateToSpeedDial(formId, hasData);
    }
  }

  onAddTemplateToMissedCall(formId: string) {
    sharedPreferencesUtils.init(this.context)
    const dsOptions: dataShare.DataShareHelperOptions = {
      isProxy: true
    };
    const PROXY_URI = 'datashareproxy://com.ohos.contactsdataability';
    const PROXY_URI_CONTACT = 'datashareproxy://com.ohos.contactsdataability/calls/call_setting';
    const template: dataShare.Template = {
      predicates: {
        'callLog': CALLLOGSQL
      },
      scheduler: callLogScheduler
    };
    dataShare.createDataShareHelper(this.context, PROXY_URI, dsOptions).then((dataShareHelper) => {
      HiLog.w(TAG, 'createDataShareHelper MissedCall succeed');
      dataShareHelper.delTemplate(PROXY_URI_CONTACT, formId);
      dataShareHelper.addTemplate(PROXY_URI_CONTACT, formId, template);
      HiLog.w(TAG, 'dataShareHelper MissedCall');
    })
  }

  onAddTemplateToShortcut(formId: string, contactsList: SpeedDialCardDataType[]) {
    const PROXY_URI = 'datashareproxy://com.ohos.contactsdataability';
    const PROXY_URI_CONTACT = 'datashareproxy://com.ohos.contactsdataability/contacts/setting';
    const dsOptions: dataShare.DataShareHelperOptions = {
      isProxy: true
    };
     let idList: string[] = [];
    contactsList.forEach((item: SpeedDialCardDataType) => {
      idList.push(item.contactId)
    });
    HiLog.w(TAG, `[TemplateToShortcut][idList]: ${idList} [formId]: ${formId}`);
    const template: dataShare.Template = {
      predicates: {
        'subscriptionList': `select contact_id,display_name from raw_contact
          where contact_id in (${idList}) and is_deleted = 0`
      },
      scheduler: ''
    };
    HiLog.w(TAG, '[onAddTemplateToShortcut template]');
    dataShare.createDataShareHelper(this.context, PROXY_URI, dsOptions).then((dataShareHelper) => {
      HiLog.w(TAG, `createDataShareHelper Shortcut succeed, dataShareHelper : ${formId}`);
      dataShareHelper.delTemplate(PROXY_URI_CONTACT, formId);
      dataShareHelper.addTemplate(PROXY_URI_CONTACT, formId, template);
      HiLog.w(TAG, 'dataShareHelper Shortcut');
    })
  }

  async onAddDataToShortcut(formId: string, contactsList: SpeedDialCardDataType[], formName: string) {
    let formData: FormDataType = {
      contact: JSON.stringify(contactsList),
      formId: formId,
      title: 'onAddDataToShortcut'
    };
    let formBinding: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    this.mFormCardController.updateToCard(formId, formBinding);
  }

  onAddTemplateToSpeedDial(formId: string, contactsList: SpeedDialCardDataType[]) {
    const PROXY_URI = 'datashareproxy://com.ohos.contactsdataability';
    const PROXY_URI_CONTACT = 'datashareproxy://com.ohos.contactsdataability/contacts/setting';
    const dsOptions: dataShare.DataShareHelperOptions = {
      isProxy: true
    };
     let idList: string[] = [];
    contactsList.forEach((item: SpeedDialCardDataType) => {
      idList.push(item.contactId)
    });
    HiLog.w(TAG, `[TemplateToSpeedDial][idList]: ${idList} [formId]: ${formId}`);
    const template: dataShare.Template = {
      predicates: {
        'subscriptionList': `select contact_id,display_name from raw_contact
          where contact_id in (${idList}) and is_deleted = 0`
      },
      scheduler: ''
    };
    HiLog.w(TAG, '[onAddTemplateToSpeedDial template]');
    dataShare.createDataShareHelper(this.context, PROXY_URI, dsOptions).then((dataShareHelper) => {
      HiLog.w(TAG, `createDataShareHelper SpeedDial succeed, dataShareHelper : ${formId}`);
      dataShareHelper.delTemplate(PROXY_URI_CONTACT, formId);
      dataShareHelper.addTemplate(PROXY_URI_CONTACT, formId, template);
      HiLog.w(TAG, 'dataShareHelper SpeedDial');
    });
  }

  async onAddDataToSpeedDial(formId: string, contactsList: SpeedDialCardDataType[], formName: string) {
    let oldData: SpeedDialCardDataType[] = await this.queryContactByFormId(formId, formName)
    HiLog.w(TAG, 'onAddDataToSpeedDial oldData' + formId + 'length:' + oldData?.length);
    let dataMap: Map<string, SpeedDialCardDataType | null> = new Map();
    oldData.forEach(item => {
      dataMap.set(item.contactId, null);
    });
    contactsList.forEach((item) => {
      HiLog.w(TAG, `onAddDataToSpeedDial formImages:${formId},${item.contactId}`);
      dataMap.set(item.contactId, item);
    });
    dataMap.forEach((val: SpeedDialCardDataType | null, key: string) => {
      if (val === null) {
        dataMap.delete(key);
      } else {
        (val as SpeedDialCardDataType).nameSuffix = getHeadChar((val as SpeedDialCardDataType).displayName);
        dataMap.set(key, val);
      }
    })
    let sortData: SpeedDialCardDataType[] = Array.from((dataMap as Map<string, SpeedDialCardDataType>).values())
    HiLog.w(TAG, `onAddDataToSpeedDial sortData' formId: ${formId} 'length:' ${sortData?.length}`);
    let sortContactList = this.speedDailDataSort(sortData, formId)
    let base64Data = await this.onAddImage(sortContactList);
    let compressBase64Data: SpeedDialCardDataType[] = await this.compressBase64Data(base64Data, formId)

    const formData: FormDataType = {
      contact: JSON.stringify(compressBase64Data),
      formId: formId,
      title: 'onAddDataToSpeedDial',
    };
    let formBinding: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    this.mFormCardController.updateToCard(formId, formBinding);
  }

  speedDailDataSort(speedDialData: SpeedDialCardDataType[], formId: string) {
    return speedDialData.sort((a, b) => {
      const aIndex = a.formId.indexOf(formId);
      const bIndex = b.formId.indexOf(formId);
      const aNum = parseInt(a.formId.slice(aIndex + formId.length + 1));
      const bNum = parseInt(b.formId.slice(bIndex + formId.length + 1));
      return aNum - bNum;
    });
  }

  async compressBase64Data(base64Data: SpeedDialCardDataType[], formId: string) {
    let numBaseStr = 0;
    for (let i = 0; i < base64Data.length; i++) {
      if (base64Data[i].base64Str !== '') {
        numBaseStr++;
      }
    }

    // 头像数据不会超限的标准
    let imageSize = 35 * 1024;
    switch (numBaseStr) {
      case 4:
        imageSize = 8 * 1024;
        break;
      case 3:
        imageSize = 11 * 1024;
        break;
      case 2:
        imageSize = 17 * 1024;
        break;
      case 1:
        imageSize = 35 * 1024;
        break;
    }

    for (let i = 0; i < base64Data.length; i++) {
      if (base64Data[i].base64Str) {
        let compressedBaseStr = await this.compressBase64String(imageSize, formId, base64Data[i].base64Str);
        base64Data[i].base64Str = compressedBaseStr;
      }
    }
    return base64Data;
  }

  async compressBase64String(imageSize: number, formId: string, item?: string) {
    HiLog.w(TAG, `imageSize is ${imageSize}, fromId: ${formId}`)
    const IMAGE_QUALITY = 0;
    const imagePackerApi = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: IMAGE_QUALITY };
    const imageSource: image.ImageSource = image.createImageSource(item);
    const pixelMap = await imageSource.createPixelMap({ desiredSize: { height: vp2px(90), width: vp2px(90) } })
    try {
      let compressedImageData: ArrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
      if (imageSize > compressedImageData.byteLength) {
        // 使用packing二分压缩获取图片文件流
        compressedImageData = await this.packingImage(compressedImageData, pixelMap, IMAGE_QUALITY, imageSize);
      } else {
        let imageScale = 1;
        const REDUCE_SCALE = 0.4;
        while (compressedImageData.byteLength > imageSize) {
          if (imageScale > 0) {
            imageScale = imageScale - REDUCE_SCALE;
            await pixelMap.scale(imageScale, imageScale);
            compressedImageData = await this.packing(pixelMap, IMAGE_QUALITY);
          } else {
            break;
          }
        }
      }
      HiLog.w(TAG, `compressImageSize is ${compressedImageData?.byteLength}, formId: ${formId}`)
      let result = 'data:image/jpeg;base64,' + buffer.from(compressedImageData).toString('base64');
      return result
    } catch (error) {
      HiLog.e(TAG, `Compressed image fail errMsg: ${error?.code},${error?.message}`)
      return ''
    } finally {
      imageSource.release();
      imagePackerApi.release();
      pixelMap?.release();
    }
  }

  async packingImage(compressedImageData: ArrayBuffer, sourcePixelMap: image.PixelMap, 
    imageQuality: number, maxCompressedImageByte: number): Promise<ArrayBuffer> {
    const packingArray: number[] = [];
    const DICHOTOMY_ACCURACY = 10;
    for (let i = 0; i <= 100; i += DICHOTOMY_ACCURACY) {
      packingArray.push(i);
    }
    let left = 0;
    let right = packingArray.length - 1;
    // 二分压缩图片
    while (left <= right) {
      const mid = Math.floor((left + right) / 2);
      imageQuality = packingArray[mid];
      compressedImageData = await this.packing(sourcePixelMap, imageQuality);
      // 判断查找一个尽可能接近但不超过压缩目标的压缩大小
      if (compressedImageData.byteLength <= maxCompressedImageByte) {
        left = mid + 1;
        if (mid === packingArray.length - 1) {
          break;
        }
        // 获取下一次二分的图片质量参数（mid+1）压缩的图片文件流数据
        compressedImageData = await this.packing(sourcePixelMap, packingArray[mid + 1]);
        if (compressedImageData.byteLength > maxCompressedImageByte) {
          compressedImageData = await this.packing(sourcePixelMap, packingArray[mid]);
          break;
        }
      } else {
        // 目标值不在当前范围的右半部分，将搜索范围的右边界向左移动，以缩小搜索范围并继续在下一次迭代中查找左半部分。
        right = mid - 1;
      }
    }
    return compressedImageData;
  }

  async packing(sourcePixelMap: image.PixelMap, imageQuality: number): Promise<ArrayBuffer> {
    const imagePackerApi = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: imageQuality };
    const data: ArrayBuffer = await imagePackerApi.packing(sourcePixelMap, packOpts);
    return data;
  }

  async onAddImage(contactsList: SpeedDialCardDataType[]) {
    let promiseList: Promise<string>[] = []
    contactsList.forEach((item) => {
      promiseList.push(
        new Promise(async (resolve: (value: string) => void) => {
          let blob: string = await this.getBlobDataFromId(item.contactId)
          item.base64Str = blob
          resolve(blob as string)
        })
      )
    })
    return Promise.all(promiseList).then(() => {
      return contactsList;
    })
  }

  /**
   * TODO meng
   * @param contactId
   * @returns
   */
  async getBlobDataFromId(contactId: string) {
    HiLog.w(TAG, `getBlobDataFromId contactId:${contactId}`);

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('contact_id', contactId);
      conditionArgs.equalTo('type_id', 8);
      let dataShareHelper = await ContactRepository.getInstance()
        .init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext())
        .getDataAbilityHelper();
      resultSet = await dataShareHelper.query(Data.CONTENT_URI, conditionArgs,
        [RawContacts.CONTACT_ID, Data.BLOB_SOURCE, Data.RAW_CONTACT_ID, Data.DETAIL_INFO, Data.BLOB_DATA]);
      if (resultSet.rowCount === 0) {
        return '';
      }
      resultSet.goToFirstRow();
      // 适配智能合并场景头像显示问题
      let contactBlobSourceList: ContactBlobSource[] = [];
      do {
        let item: ContactBlobSource = {
          contactId: resultSet.getString(resultSet.getColumnIndex(RawContacts.CONTACT_ID)),
          blobSource: resultSet.getLong(resultSet.getColumnIndex(Data.BLOB_SOURCE)),
          rawContactId: resultSet.getString(resultSet.getColumnIndex(Data.RAW_CONTACT_ID)),
          detailInfo: resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO)),
          blobData: resultSet.getBlob(resultSet.getColumnIndex(Data.BLOB_DATA)),
        }
        contactBlobSourceList.push(item);
      } while (resultSet.goToNextRow());
      // 开始遍历通过contactId查询到的所有头像信息，进行筛选，确认最后的缩略图和大图;
      // 规则：先查询detail_info ，存在，则用raw_contact_id排序，获取raw_contact_id最大的一个
      // 若没有detail_info，则用raw_contact_id排序，获取raw_contact_id最大的一个blob_data;
      let blobData = resultSet.getBlob(resultSet.getColumnIndex(Data.BLOB_DATA));
      let resultFilter = this.getContactIdWithBlobNotNullByFilter(contactBlobSourceList);
      if (resultFilter && resultFilter.blobData !== undefined && resultFilter.blobData !== null) {
        blobData = resultFilter.blobData;
        HiLog.w(TAG, '[EntryFormAbility] getBlobDataFromId blobData filter success!');
      }
      let result = 'data:image/jpeg;base64,' + buffer.from(blobData.buffer).toString('base64');
      return result;
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  getContactIdWithBlobNotNullByFilter(contactBlobSourceList: ContactBlobSource[]) {
    contactBlobSourceList.sort((v1, v2) => {
      return parseInt(v2.rawContactId) - parseInt(v1.rawContactId);
    })
    let resultDefault: ContactBlobSource = contactBlobSourceList[0];
    try {
      let itemList = contactBlobSourceList;
      // 默认初始值
      let itemResult: ContactBlobSource = itemList[0];
      if (itemList && itemList.length === 1) {
           itemResult = itemList[0];
      } else {
        // 查询detail_info,存在,则用raw_contact_id排序，获取raw_contact_id最大的一个detail_info的头像
        let detailInfoNotNullList = itemList.filter((v) => {
          return v.detailInfo !== undefined && v.detailInfo !== null && v.detailInfo !== '';
        })
        if (detailInfoNotNullList && detailInfoNotNullList.length) {
          detailInfoNotNullList.sort((v1, v2) => {
            return parseInt(v2.rawContactId) - parseInt(v1.rawContactId);
          })
          let result = detailInfoNotNullList[0];
          HiLog.w('CardEntryFormAbility getContactIdWithBlobNotNullCompareFileScale ',
            `getContactIdWithBlobNotNull by detailInfo, contactId: ${itemList[0].contactId},rawContactId: ${result.rawContactId},blobSource: ${result.blobSource},detailInfo: ${result.detailInfo}`);
          itemResult = result;
        } else {
          // 若没有detail_info，则用raw_contact_id排序，获取raw_contact_id最大的一个blob_data
          itemList.sort((v1, v2) => {
            return parseInt(v2.rawContactId) - parseInt(v1.rawContactId);
          })
          HiLog.w('CardEntryFormAbility getContactIdWithBlobNotNullCompareFileScale ',
            `getContactIdWithBlobNotNull by blobSource, contactId: ${itemList[0].contactId}, rawContactId: ${itemList[0].rawContactId},blobSource: ${itemList[0].blobSource}, detailInfo: ${itemList[0].detailInfo}`);
          itemResult = itemList[0];
        }
      }
      return itemResult;
    } catch (err) {
      HiLog.e('CardEntryFormAbility getContactIdWithBlobNotNullCompareFileScale ',
        `getContactIdWithBlobNotNull error: ${err.message}`);
    }
    return resultDefault;
  }

  onAddProxies(formId: string, formName: string) {
    const PROXY_URI = formName === 'MissedCall'
      ? 'datashareproxy://com.ohos.contactsdataability/calls/call_setting'
      : 'datashareproxy://com.ohos.contactsdataability/contacts/setting';
    const formData: FormDataType = {
      speedDialCardH: this.speedDialCardH,
      isHasVoiceCapability: call.hasVoiceCapability(),
      formId: formId,
      title: 'onAddProxies',
    };
    const missedCallFormData: FormDataType = {
      isHasVoiceCapability: call.hasVoiceCapability()
    };
    let formBinding: formBindingData.FormBindingData = formBindingData.createFormBindingData(formName === 'MissedCall'
      ? missedCallFormData : formData);
    const proxies: Array<formBindingData.ProxyData> = [
      {
        'key': PROXY_URI,
        'subscriberId': formId
      }
    ];
    formBinding['proxies'] = proxies;
    return formBinding;
  }

  onCastToNormalForm(formId: string) {
    HiLog.w(TAG, `[EntryFormAbility] onCastToNormalForm, formId: ${formId}`);
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    // 若卡片支持定时更新/定点更新/卡片使用方主动请求更新功能，则提供方需要重写该方法以支持数据更新
    HiLog.w(TAG, '[EntryFormAbility] onUpdateForm');
    this.onAddTemplateToSpeedDial(formId, [])
  }

  onChangeFormVisibility(newStatus: Record<string, number>) {
    // Called when the form provider receives form events from the system.
    // 需要配置formVisibleNotify为true，且为系统应用才会回调
    HiLog.w(TAG, '[EntryFormAbility] onChangeFormVisibility');
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
    // 若卡片支持触发事件，则需要重写该方法并实现对事件的触发
    ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.CardContextName, this.context);
    this.mDataWorker = WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper;
    ContactsGlobalThisHelper.GetGlobalThis()
      .set<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName, this.mDataWorker);
    this.mDataWorker.sendRequest('init', {
      context: this.context
    });
    HiLog.w(TAG, `[onFormEvent]: ${formId},${message?.length}`);
    let data: LooseObject = JSON.parse(message);
    let flag: string = data.params.flag;
    let abilityName: string = data.params.abilityName
    HiLog.w(TAG, `[flag]:${formId},${flag}`);
    let context: Context = this.context;
    let simManager = new SimManager();
    simManager.init();
    switch (flag) {
      case 'jumpToAddPage':
        this.jumpToAddPage(formId, abilityName)
        break;
      case 'missedCallCard':
        this.onMissedCallCard(context);
        break;
      case 'shortCutCardDetail':
      case 'missedCallCardDetail':
        this.onCardDetail(data, formId, flag, context);
        break;
      case 'getContactByPhones':
        this.onGetContactByPhones(data, formId, context);
        break;
      case 'updateTemplate':
        this.onUpdateTemplate(data, formId);
        break;
      case 'updateContactsList':
        this.onUpdateContactsList(data, formId);
        break;
      case 'speedDialByPhone':
        this.onSpeedDialByPhone(data);
        break;
      case 'queryMissedCall':
        this.onQueryMissedCall(formId);
        break;
      case 'dialNumber':
        this.onDialNumber(data);
        break;
    }
    simManager.recycle()
  }

  // 点击添加按钮到一级编辑页
  private jumpToAddPage(formId: string, abilityName: string) {
    HiLog.w(TAG, `jumpToAddPage formId: ${formId}, abilityName: ${abilityName}`)
    // 联系人打点-快捷方式空白卡片点击"+"添加联系人
    DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.CARD_ADD_CONTACT_EVENT);
    try {
      formProvider.openFormEditAbility(abilityName, formId)
    } catch (err) {
      HiLog.e(TAG, `code: ${(err as BusinessError)?.code} msg: ${(err as BusinessError)?.message}`);
    }
  }

  getContactList(idList: Array<Record<string, string | number>>) {
    idList.forEach(item => {
      this.mFormCardController?.mDataWorker?.sendRequest('getContactById', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext(),
        contactId: item.id
      }, (result: ContactReturnObj, error: Error) => {
        if (error) {
          HiLog.e(TAG, `sendRequest error:${error?.message}`);
        } else {
          HiLog.w(TAG + '[result]', result?.data?.rowContactID);
        }
      })
    })
  }

  async onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    // 当对应的卡片删除时触发的回调，入参是被删除的卡片ID
    let contactListInFormCard: SpeedDialCardDataType[] = await this.queryContactByFormId(formId, 'deleteForm')
    if (contactListInFormCard.length > 0) {
      for (const item of contactListInFormCard) {
        let deleteFormId = item.formId?.split('//').filter(item => !item.includes(formId)).join('//')
        await this.updateContactFormId(item.contactId, deleteFormId)
      }
      HiLog.w(TAG, `delete formCard success length: ${contactListInFormCard.length}, formId: ${formId}`)
    }

    HiLog.w(TAG + '[EntryFormAbility] removeFormID-----', formId);
    // 从首选项中删除已保存的2*2快速拨号卡片的formId
    this.updateSpeedDialCardIdList(formId, 'delete');
  }


  onConfigurationUpdate() {
    // 当系统配置信息置更新时触发的回调
    HiLog.w(TAG, '[EntryFormAbility] configurationUpdate');
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    // 卡片提供方接收查询卡片状态通知接口，默认返回卡片初始状态。
    HiLog.w(TAG, '[EntryFormAbility] onAcquireFormState');
    return formInfo.FormState.READY;
  }

  onMissedCallCard(context: Context) {
    let startAbilityPage = contactPage.PAGE_FLAG_DIALER;
    this.mFormCardController.clickToContactRecord(context, startAbilityPage);
  }

  onCardDetail(data: LooseObject, formId: string, flag: string, context: Context) {
    // 联系人打点-卡片查看联系人详情
    contactParams.ENC = data.params.cardType
    DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.CARD_VIEW_DETAIL_EVENT);
    HiLog.w(TAG + '[clickToContactDetail]', formId);
    if (flag === 'missedCallCardDetail') {
      let phone: string = data.params.phone;
      let numList: string[] = [phone];
      this.mFormCardController.setMissedCallBadgeNumberByPhone(numList);
      this.mFormCardController.setMissedCallToRead([phone]);
    } else {
      let phoneList: PhonesType[] = data.params.phoneList;
      let numList: string[] = phoneList.map(item => item.num);
      this.mFormCardController.setMissedCallBadgeNumberByPhone(numList);
      this.mFormCardController.setMissedCallToRead(numList);
    }
  }

  onGetContactByPhones(data: LooseObject, formId: string, context: Context) {
    HiLog.w(TAG, '[getContactByPhones start]');
    this.mFormCardController.getContactByPhones(data.params.callLog, data.params.contactType,
      (result: Record<string, string>[]) => {
        interface FormDataType {
          callLogForContact: Record<string, string>[],
          formId: string,
          title: string
        }

        const formData: FormDataType = {
          callLogForContact: result,
          formId: formId,
          title: 'missedCall'
        };
        let formBinding: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        this.mFormCardController.updateToCard(formId, formBinding);
        HiLog.w(TAG + '[getContactByPhones callLogForContact]', formId);
      });
  }

  async onUpdateTemplate(data: LooseObject, formId: string) {
    let formName: string = data.params.formName;
    let contactList: SpeedDialCardDataType[] = await this.queryContactByFormId(formId, formName);
    HiLog.w(TAG, `[updateTemplate] formName: ${formName} formId: ${formId} length: ${contactList?.length}`);
    if (formName === 'shortcut') {
      this.onAddTemplateToShortcut(formId, contactList);
      this.onAddDataToShortcut(formId, contactList, formName);
    } else if (formName === 'SpeedDial') {
      this.onAddTemplateToSpeedDial(formId, contactList);
      this.onAddDataToSpeedDial(formId, contactList, formName);
    }
  }

  async onUpdateContactsList(data: LooseObject, formId: string) {
    let formName: string = data.params.formName;
    let contactList = await this.queryContactByFormId(formId, formName);
    HiLog.w(TAG, `[onUpdateContactsList] formName: ${formName} formId: ${formId} length: ${contactList?.length}`);
    if (formName === 'shortcut') {
      this.onAddDataToShortcut(formId, contactList, formName);
    } else if (formName === 'SpeedDial') {
      this.onAddDataToSpeedDial(formId, contactList, formName);
    }
  }

  onSpeedDialByPhone(data: LooseObject) {
    // 联系人打点-未接来电卡片呼叫联系人
    contactParams.ENC = data.params.cardType;
    DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.CARD_CALL_CONTACT_EVENT);
    let phone: string = data.params.phone;
    let numList: string[] = [phone];
    this.mFormCardController.setMissedCallBadgeNumberByPhone(numList);
    if (call.hasVoiceCapability()) {
      this.mFormCardController.dealCallNumber(phone);
    } else {
      this.mFormCardController.callSharingNumber(phone);
    }
    this.mFormCardController.setMissedCallToRead([phone]);
  }

  onQueryMissedCall(formId: string) {
    this.mFormCardController.getFirstMissedCall(formId, 'MissedCall');
  }

  onDialNumber(data: LooseObject) {
    // 联系人打点-快捷方式卡片/快速拨号卡片呼叫联系人
    contactParams.ENC = data.params.cardType;
    DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.CARD_CALL_CONTACT_EVENT);
    let contactId: string = data.params.contactId;
    HiLog.w(TAG, 'dialNumber=====' + contactId);
    this.mFormCardController.getContactPhone(contactId);
  }

  //通过formId查询被添加到卡片上的联系人
  async queryContactByFormId(formId: string, formName: string) {
    HiLog.w(TAG, `queryContactByFormId formId: ${formId}, formName: ${formName}`)

    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let speedDialData: SpeedDialCardDataType[] = []
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.contains('form_id', formId);
      conditionArgs.and()
      conditionArgs.equalTo('is_deleted', '0');

      if (!this.context) {
        HiLog.e(TAG, `The context is null, will be get from Global.`)
        this.context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
      }

      let dataShareHelper = await ContactRepository.getInstance()
        .init(this.context)
        .getDataAbilityHelper();
      let columnName = ['id', 'display_name', 'form_id', 'photo_first_name']
      resultSet = await dataShareHelper.query(Contacts.CONTACT_URI, conditionArgs, columnName);
      HiLog.w(TAG, `queryContactByFormId count is ${resultSet?.rowCount}, formId: ${formId}`)
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          let nameSuffix: string = resultSet.getString(resultSet.getColumnIndex(Contacts.PHOTO_FIRST_NAME));
          let displayName: string = resultSet.getString(resultSet.getColumnIndex(Contacts.DISPLAY_NAME));
          let contactId: string = resultSet.getString(resultSet.getColumnIndex(Contacts.ID));
          let id: string = resultSet.getString(resultSet.getColumnIndex(Contacts.ID));
          let formId: string = resultSet.getString(resultSet.getColumnIndex(Contacts.FORM_ID));
          let obj: SpeedDialCardDataType = {
            contactId: contactId,
            displayName: displayName,
            nameSuffix: nameSuffix,
            phones: [],
            showName: displayName,
            id: Number(id),
            formId: formId
          }
          speedDialData.push(obj)
        } while (resultSet.goToNextRow())
      }
      return speedDialData
    } finally {
      ObjectUtil.closeResultSet(resultSet);
    }
  }

  async updateContactFormId(contactId: string, formId: string) {
    HiLog.w(TAG, `updateContactFormId formId: ${formId}, contactId: ${contactId}`)
    try {
      let dataShareHelper = await ContactRepository.getInstance()
        .init(this.context)
        .getDataAbilityHelper();
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('id', contactId);

      let insertValues: Record<string, string | number> = {
        'form_id': formId ? formId.toString() : '',
      };
      dataShareHelper.update(
        Contacts.CONTACT_URI,
        conditionArgs,
        insertValues,
      )
    } catch (error) {
      HiLog.e(TAG, `updateContactFormId fail msg:${error?.code},${error?.message}`)
    }
  }

  // 在首选项中存入或删除2*2快速拨号卡片Id
  public async updateSpeedDialCardIdList(formId: string, type: string, formName?: string) {
    if (formName && formName != 'SpeedDial') {
      HiLog.i(TAG, 'updateSpeedDialCardIdList, formName is not SpeedDial');
      return;
    }
    sharedPreferencesUtils.init(this.context);
    await sharedPreferencesUtils.removePreferencesFromCache('speedDialCardIdList');
    let res: string[] = await sharedPreferencesUtils.getFromPreferences('speedDialCardIdList', []) as string[];
    switch (type) {
      case 'add':
        if (res && res.length > 0) {
          if (!res.includes(formId)) {
            // 首选项中不存在formId，则push
            res.push(formId);
          }
        } else {
          res = [];
          res.push(formId);
        }
        await sharedPreferencesUtils.saveToPreferences('speedDialCardIdList', res);
        break;
      case 'delete':
        if (res && res.length > 0) {
          if (res.includes(formId)) {
            // 首选项中存在formId,则过滤掉formId
            res.splice(res.indexOf(formId), 1);
            await sharedPreferencesUtils.saveToPreferences('speedDialCardIdList', res);
          }
        }
        break;
      default:
        break;
    }
  }
};


