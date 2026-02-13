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
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import { HiLog, ObjectUtil } from '../../../../../common';
import TraceConstants from '../../../../../common/src/main/ets/TraceConstants';
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { BusinessError } from '@ohos.base';
import taskpool from '@ohos.taskpool';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ContactRepository, Data, Contacts } from '../../../../../feature/contact';
import dataShare from '@ohos.data.dataShare';
import { Context } from '@ohos.abilityAccessCtrl';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { StringUtil } from '../../../../../feature/call/oh_modules/common';
import dotCommon, { faultContactParams } from './DotCommon';
import DotUtil from './DotUtil';
import { CachedContactsPixelMapType, ContactBlobSource } from '../model/type';
import util from '@ohos.util'
import EmitterConstant from '../data/EmitterConstant';
import { emitter } from '@kit.BasicServicesKit';
import GroupIdUtil from './GroupIdUtil';
import { ValuesBucket } from '@kit.ArkData';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { contextConstant } from '@kit.AbilityKit';
import LooseObject from '../model/type/LooseObject';

const TAG: string = 'UserPhoto ';

/*
 * The pixel threshold for determining whether to display as a poster avatar.
 * above MIN_RESOLUTION, will set blob_source 3, and display poster avatar in contact detail page,
 * below MIN_RESOLUTION, will set blob_source 1, and display round avatar in contact detail page.
 */
const MIN_RESOLUTION = 409600;

/*
 * manager class used to manage avatar pixelMap cache.
 */
export class PixelMapManager {
  private constructor() {
  }

  private static instance: PixelMapManager;

  public static resultDT: boolean = true;

  /**
   * get Instance
   * @returns
   */
  public static getInstance(): PixelMapManager {
    if (!PixelMapManager.instance) {
      HiLog.w(TAG, 'init PixelMapManager.instance')
      PixelMapManager.instance = new PixelMapManager();
    }
    return PixelMapManager.instance;
  }

  // {联系人id，BlobSource} 映射
  public contactIdBlobSourceMap = new Map<string, ContactBlobSource>();
  public getBlobSourceMapCopy(): Map<string, ContactBlobSource> {
    let mapCopy: Map<string, ContactBlobSource> = new Map<string, ContactBlobSource>();
    this.contactIdBlobSourceMap.forEach((value: ContactBlobSource, key: string) => {
      mapCopy.set(key, value);
    })
    return mapCopy;
  }
  public initBlobSourceMapByIds(ids: string[]) {
    ids?.forEach(id => {
      this.contactIdBlobSourceMap?.delete(id);
    })
  }
  public updateBlobSourceMap(map: Map<string, ContactBlobSource>, ids: string[]) {
    ids?.forEach(id => {
      this.contactIdBlobSourceMap?.delete(id);
    })

    map.forEach((value, key) => {
      this.contactIdBlobSourceMap?.set(key, value);
    });
  }
  initBlobSourceMap(value: Map<string, ContactBlobSource>) {
    this.contactIdBlobSourceMap = value;
  }

  /**
   * @returns [blobSource, extend1]
   */
  getBlobSourceById(contactId: string): number {
    let blobSource = this.contactIdBlobSourceMap.get(contactId);
    if (blobSource === undefined) {
      return -1;
    } else {
      return blobSource.blobSource;
    }
  }
  /**
   * @returns [rawContactId]
   */
  getRawContactIdById(contactId: string): string {
    let blobSource = this.contactIdBlobSourceMap.get(contactId);
    if (blobSource === undefined) {
      return '';
    } else {
      return blobSource.rawContactId;
    }
  }

  // 联系人列表小头像Map
  public contactListIdMiniPixelMap = new Map<string, PixelMap | null>();
  // 联系人搜索列表小头像Map
  public contactSearchListMiniPixelMap = new Map<string, PixelMap | null>();
  public loadingContactIdSet: Set<string> = new Set();

  // 列表缓存一页小头像（根据类型区分联系人列表及联系人搜索列表）
  cachedContactListIdMiniPixelMap(item: LooseObject, type: CachedContactsPixelMapType) {
    if (type === CachedContactsPixelMapType.CONTACT_LIST) {
      HiLog.w(TAG, 'cachedContactListIdMiniPixelMap');
      if (!this.contactListIdMiniPixelMap.has(item.contactId)) {
        getPixelMapFromFile(item.contactId, (res: PixelMap | null) => {
          if (res) {
            this.contactListIdMiniPixelMap.set(item.contactId, res)
          }
        })
      }
    } else if (type === CachedContactsPixelMapType.CONTACT_SEARCH_LIST) {
      HiLog.w(TAG, 'cachedContactSearchListIdMiniPixelMap');
      let contactSearchId = item.entityId as string;
      // 判断当前id在缓存中是否存在
      if (this.contactSearchListMiniPixelMap.has(contactSearchId)) {
        return;
      }
      // 判断当前id是否正在进行缓存
      if (this.loadingContactIdSet.has(contactSearchId)) {
        return;
      }

      this.loadingContactIdSet.add(contactSearchId);

      getPixelMapFromFile(contactSearchId, (res: PixelMap | null) => {
        if (res) {
          this.contactSearchListMiniPixelMap.set(contactSearchId, res);
        }
        this.loadingContactIdSet.delete(contactSearchId);
      })
    }
  }

  deleteContactListIdMiniPixelMap(contactId: string) {
    HiLog.w(TAG, 'deleteContactListIdMiniPixelMap contactId:' + contactId);
    this.contactListIdMiniPixelMap.set(contactId, null);
  }

  updateSearchPixelMapCachedByContactId(contactId: string) {
    if (this.contactSearchListMiniPixelMap.has(contactId)) {
      getPixelMapFromFile(contactId, (res: PixelMap | null) => {
        if (res) {
          HiLog.w(TAG, 'update PixelMapCache');
          this.contactSearchListMiniPixelMap.set(contactId, res);
        } else {
          HiLog.w(TAG, 'delete PixelMapCache');
          this.contactSearchListMiniPixelMap.delete(contactId);
        }
      })
    } else {
      HiLog.w(TAG, 'insert PixelMapCache');
      getPixelMapFromFile(contactId, (res: PixelMap | null) => {
        if (res) {
          this.contactSearchListMiniPixelMap.set(contactId, res);
        }
      })
    }
  }

  updateContactSearchListMiniPixelMap(contactIds: string[]) {
    HiLog.i(TAG, 'updateContactSearchListMiniPixelMap');
    let contactIdsSet: Set<string> = new Set(contactIds);
    let deleteKeys: string[] = [];
    for (let key of this.contactSearchListMiniPixelMap.keys()) {
      if (!contactIdsSet.has(key)) {
        deleteKeys.push(key);
      }
    }

    for (let key of deleteKeys) {
      this.contactSearchListMiniPixelMap.delete(key);
    }
  }

  // 列表释放一页小头像(根据条件筛选清除数据)
  releaseContactListAllPixelMap(isClearContactListPixelMap: boolean, isClearContactSearchListPixelMap: boolean) {
    if (isClearContactListPixelMap) {
      HiLog.w(TAG, 'releaseContactListAllPixelMap');
      this.contactListIdMiniPixelMap.forEach((pixelMap) => {
        pixelMap?.release();
      })
      this.contactListIdMiniPixelMap.clear();
    }
    if (isClearContactSearchListPixelMap) {
      HiLog.w(TAG, 'releaseContactSearchListAllPixelMap');
      this.contactSearchListMiniPixelMap.forEach((pixelMap) => {
        pixelMap?.release();
      })
      this.contactSearchListMiniPixelMap.clear();
    }
  }

  // 释放所有头像
  releaseAllPixelMap() {
    HiLog.w(TAG, 'releaseAllPixelMap');
  }

  // 通过id获取小头像
  getMiniPixelMapById(contactId: string): PixelMap | null | undefined {
    return this.contactListIdMiniPixelMap.get(contactId);
  }
  deletePixelMap(contactId: string) {
  }
  deleteMiniPixelMap(contactId: string) {
  }
}

export const createDir = (filePath: string, callback: () => void) => {
  fs.mkdir(filePath).then(() => {
    callback();
  }).catch((err: BusinessError) => {
    if (err.code === 13600006 || err.code === 13900015) {
      callback();
    }
    HiLog.e(TAG, 'mkdir failed with error message: ' + err.message + ', error code: ' + err.code);
  });
}

export const getImagePackingData = async (pixelMap: PixelMap, callback: (data: ArrayBuffer | null) => void) => {
  let opt: image.PackingOption = { format: 'image/jpeg', quality: 100 }
  const imagePackerApi = image.createImagePacker();
  imagePackerApi.packing(pixelMap, opt).then(async data => {
    imagePackerApi.release();
    callback(data);
  }).catch((error: BusinessError) => {
    HiLog.e(TAG, 'fail to get image packing data: %s', error?.message);
    imagePackerApi.release();
    callback(null)
  });
}

/*
 * Write the avatar data to the specified directory.
 * @param rawContactsIds: A contact object may be associated with multiple raw objects.
 * When modifying the contact's avatar, the avatars of all associated raw records need to be changed.
 */
const writeImageFileData =
  async (data: ArrayBuffer, id: string, filePath: string, pathDir: string, intoGroup: boolean, rawContactIds: string[],
    callback: () => void) => {
    try {
      if (intoGroup) {
        for (let rawContactId of rawContactIds) {
          let filePathNew = pathDir + '/' + id + '_' + rawContactId;
          let file = fs.openSync(filePathNew, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          await fs.write(file.fd, data);
          fs.closeSync(file);
        }
      } else {
        let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        await fs.write(file.fd, data);
        fs.closeSync(file);
      }
      AppStorage.setOrCreate('contactsWithModifiedPhoto', id + '-' + new Date().getTime());
      HiLog.i(TAG, `writeImageFileData success ${id}`);
      callback();
    } catch (error) {
      let err = error as BusinessError
      HiLog.e(TAG, 'open file failed with error message: ' + err.message + ', error code: ' + err.code);
      callback();
    }
  }

// 保存大头像到文件
export const saveImageToFile = async (pixelMap: PixelMap, id: string, callback?: () => void,
  intoGroup: boolean = true) => {
  let pathDir: string;
  let filePath: string;
  if (intoGroup) {
    // 为适应联系人大头像云同步需求，现将头像文件存储路径由之前的联系人应用沙箱改为群组沙箱路径，以便联系人数据库也能访问
    // 之前的存量头像文件，会在大头像云同步代码升级之后，做一次迁移，因此不影响存量业务的头像展示
    // 其他业务开展时，请注意此修改，调用saveImageToFile方法后，请使用以下群组沙箱groupDir来访问头像文件
    let ctx = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().getApplicationContext();
    let groupDir = await GroupIdUtil.getInstance().getGroupDir(ctx);
    HiLog.w(TAG, `bigPhotoFromFile saveImageToFile groupDir: ${StringUtil.maskSensitiveInfo(groupDir)}`);
    pathDir = groupDir + '/photo';
    filePath = pathDir + '/' + id;
  } else {
    let ctx = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().getApplicationContext();
    ctx.area = contextConstant.AreaMode.EL2;
    pathDir =
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext().getApplicationContext().filesDir + '/photo';
    filePath = pathDir + '/' + id;
  }
  // 根据contactId获取旗下所有rawContactId
  let rawContactIds: string[] = await ContactRepository.getInstance().getRawContactIdsByContactId(id);
  HiLog.w(TAG, `bigPhotoFromFile saveImageToFile contactId: ${id}, rawContactIds: ${rawContactIds}`);
  createDir(pathDir, () => {
    HiLog.i(TAG, `pathDir success`);
    getImagePackingData(pixelMap, (data: ArrayBuffer | null) => {
      if (data != null) {
        // 头像信息写入文件
        writeImageFileData(data, id, filePath, pathDir, intoGroup, rawContactIds, async () => {
          if (intoGroup) {
            await saveImageFileInfoToRdb(filePath, id, rawContactIds, pixelMap);
          }
          callback?.();
        })
      } else {
        callback?.();
      }
    })
  })
}

/*
 * Write the avatar information into the database, including the original avatar image path(detail_info) and blob_source
 */
export const saveImageFileInfoToRdb =
  async (filePath: string, contactId: string, rawContactIds: string[], pixelMap?: PixelMap) => {
    // 默认使用海报显示大头像
    let blobSource = 3;
    try {
      // 需要在此先判断头像文件的比例，为的是存量数据存值：如果比例是1:1，则将blob_source置为1；否则将blob_source置为3
      if (!pixelMap) {
        let task = new taskpool.Task(getPixelMapFromLocalFile, filePath);
        pixelMap = await taskpool.execute(task) as PixelMap;
      }
      let imageInfo = await pixelMap.getImageInfo();
      let height = imageInfo.size.height;
      let width = imageInfo.size.width;
      if (height * width <= MIN_RESOLUTION) {
        blobSource = 1;
      }
      pixelMap?.release().catch((error: BusinessError) => {
      });
      HiLog.w(TAG,
        `bigPhotoFromFile saveImageFileInfoToRdb contactId: ${contactId}, height: ${height}, width: ${width}, blobSource: ${blobSource}`);
      await updateRawContactInfo(contactId, blobSource, rawContactIds);
    } catch (error) {
      let err = error as BusinessError
      HiLog.e(TAG,
        'bigPhotoFromFile saveImageFileInfoToRdb failed, err.message: ' + err.message + ', error code: ' + err.code);
      await updateRawContactInfo(contactId, blobSource, rawContactIds);
    }
  }

export const updateRawContactInfo = async (contactId: string, blobSource: number, rawContactIds: string[]) => {
    try {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let daHelper: dataShare.DataShareHelper =
        await ContactRepository.getInstance().init(context).getDataAbilityHelper();
      let rawContactIdList: string[] = [];
      if (rawContactIds && rawContactIds.length) {
        rawContactIdList = rawContactIds;
      } else {
        rawContactIdList = await ContactRepository.getInstance().getRawContactIdsByContactId(contactId);
      }
      HiLog.w(TAG, `bigPhotoFromFile updateRawContactInfo rawContactIdList: ${rawContactIdList}`);
      // 2.更新数据库字段
      if (rawContactIdList && rawContactIdList.length) {
        for (const rawContactId of rawContactIdList) {
          let fileNameNew = 'photo/' + contactId + '_' + rawContactId;
          let option = new dataSharePredicates.DataSharePredicates();
          option.equalTo(Data.RAW_CONTACT_ID, rawContactId);
          option.and();
          option.equalTo(Data.TYPE_ID, 8);
          let value: ValuesBucket = {};
          value[Data.DETAIL_INFO] = fileNameNew;
          value[Data.BLOB_SOURCE] = blobSource;
          let ret = await daHelper.update(Data.CONTENT_URI, option, value);
          if (ret <= 0) {
            HiLog.w(TAG,
              `bigPhotoFromFile updateRawContactInfo update contact_data failed, contactId: ${contactId}, raw_contact_id = ${rawContactId}`);
          } else {
            HiLog.w(TAG,
              `bigPhotoFromFile updateRawContactInfo update contact_data success, contactId: ${contactId}, raw_contact_id = ${rawContactId}`);
          }
        }
      }
    } catch (error) {
      let err = error as BusinessError
      HiLog.e(TAG,
        'bigPhotoFromFile updateRawContactInfo failed, err.message: ' + err.message + ', error code: ' + err.code);
    }
  }

// init BlobSource Map
export const initBlobSourceMap = (value: Map<string, ContactBlobSource>) => {
  PixelMapManager.getInstance().initBlobSourceMap(value);
}

export const getPixelMapFromFile = (id: string, callback?: Function, context: Context =
ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), needPosterImg: boolean = false, userId?: number) => {
  let blobSource: number = PixelMapManager.getInstance().getBlobSourceById(id);
  let rawContactId: string = PixelMapManager.getInstance().getRawContactIdById(id);
  HiLog.i(TAG,
    `getPixelMapFromFile id:${id} blobSource: ${blobSource}, rawContactId: ${rawContactId}. userId: ${userId}`);

  if (blobSource == 3) {
    getPosterImg(id, callback, context, needPosterImg, rawContactId, userId);
  } else if (blobSource == -1) {
    // 没有头像信息
    callback?.(null);
  } else {
    getOldAvtar(id, blobSource, rawContactId, (pixelMap: PixelMap) => {
      callback?.(pixelMap);
    }, context, userId);
  }
}

export const getPhotoPixelMapFromDB = (id: string, callback?: Function, context: Context =
ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), userId?: number) => {
  let rawContactId: string = PixelMapManager.getInstance().getRawContactIdById(id);
  HiLog.i(TAG,
    `getPhotoPixelMapFromDB id:${id} rawContactId: ${rawContactId}. userId: ${userId}`);
  getImageBlobDataFromDB(id, callback, context, rawContactId, userId);
}

/**
 * picker get photo by localuserId
 */
export const getPixelMapFromFileForContactPicker =
  (id: string, localId: number, userId: number, callback?: Function, context: Context =
  ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), needPosterImg: boolean = false) => {
    let blobSource: number = PixelMapManager.getInstance().getBlobSourceById(id);
    let rawContactId: string = PixelMapManager.getInstance().getRawContactIdById(id);
    HiLog.i(TAG,
      `getPixelMapFromFile id:${id} blobSource: ${blobSource}, rawContactId: ${rawContactId}. userId: ${userId}`);
    if (blobSource == 3) {
      getPosterImg(id, callback, context, needPosterImg, rawContactId, userId);
    } else if (blobSource == -1) {
      // 没有头像信息
      callback?.(null);
    } else {
      getSmallAvtar(id, blobSource, rawContactId, (pixelMap: PixelMap) => {
        callback?.(pixelMap);
      }, context, localId, userId);
    }
  }

const getSmallAvtar =
  (id: string, blobSourceType: number, rawContactId: string, callback: Function | undefined,
    context: Context, localId: number, userId: number) => {
    try {
      let pixelMap = PixelMapManager.getInstance().getMiniPixelMapById(id);
      HiLog.w(TAG,
        `getoldAvtar  id:${id}, blobsource:${blobSourceType}, pixelMap:${pixelMap?.getPixelBytesNumber()
        }, rawContactId: ${rawContactId}, userId: ${userId}`);
      if (!pixelMap?.getPixelBytesNumber()) {
        HiLog.i(TAG, `getoldAvtar id:${id} pixelmap empty`);
        switch (blobSourceType) {
          case 2:
            // 根据数据库中blob_data 初始化头像
            getImageBlobDataFromDB(id, callback, context, rawContactId, userId);
            break;
          case 1:
          case 0:
            getImageFileFromLocal(id, callback, context, true, rawContactId, (localId === userId), userId);
            break;
          default:
            HiLog.w(TAG, `contact photo file and blod data not exist: ${id}`)
            callback?.(null);
            break;
        }
      } else {
        // 头像已初始化
        callback?.(pixelMap);
      }
    } catch (error) {
      // 联系人故障打点-联系人头像解析失败
      faultContactParams.FAULT_INFO = error.message;
      DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.ADD_CONTACTS_PHOTO_FAIL);
      HiLog.e('UserPhoto ', 'getPixelMapFromFile error: ' + error?.message + ', stack: ' + error?.stack);
    }
  }

const getOldAvtar =
  (id: string, blobSourceType: number, rawContactId: string, callback: Function | undefined,
    context: Context, userId?: number) => {
  try {
    let pixelMap = PixelMapManager.getInstance().getMiniPixelMapById(id);
    HiLog.w(TAG,
      `getoldAvtar  id:${id}, blobsource:${blobSourceType}, pixelMap:${pixelMap?.getPixelBytesNumber()
      }, rawContactId: ${rawContactId}, userId: ${userId}`);
    if (!pixelMap?.getPixelBytesNumber()) {
      HiLog.i(TAG, `getoldAvtar id:${id} pixelmap empty`);
      switch (blobSourceType) {
        case 2:
          // 根据数据库中blob_data 初始化头像
          getImageBlobDataFromDB(id, callback, context, rawContactId, userId);
          break;
        case 1:
        case 0:
          getImageFileFromLocal(id, callback, context, true, rawContactId, true, userId);
          break;
        default:
          HiLog.w(TAG, `contact photo file and blod data not exist: ${id}`)
          callback?.(null);
          break;
      }
    } else {
      // 头像已初始化
      callback?.(pixelMap);
    }
  } catch (error) {
    // 联系人故障打点-联系人头像解析失败
    faultContactParams.FAULT_INFO = error.message;
    DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.ADD_CONTACTS_PHOTO_FAIL);
    HiLog.e('UserPhoto ', 'getPixelMapFromFile error: ' + error?.message);
  }
}

const getPosterImg = (id: string, callback: Function | undefined, context: Context, needPosterImg: boolean,
  rawContactId: string, userId?: number) => {
  HiLog.i(TAG,
    `getPosterImg id:${id}, needPosterImg:${needPosterImg}, rawContactId: ${rawContactId}, userId: ${userId}`);
  if (needPosterImg) {
    // 从本地文件获取头像
    getImageFileFromLocal(id, (pixelMap: PixelMap) => {
      callback?.(pixelMap);
    }, context, false, rawContactId);
  } else {
    // mini头像，从 map缓存 获取
    let pm = PixelMapManager.getInstance().getMiniPixelMapById(id);
    if (pm && pm.getPixelBytesNumber()) {
      HiLog.i(TAG, `getPosterImg from Cache, id:${id}, rawContactId: ${rawContactId}`);
      callback?.(pm);
      return;
    }
    // 查询数据库contact_data的头像字段，获取头像
    getImageBlobDataFromDB(id, (pixelMap: PixelMap) => {
      callback?.(pixelMap);
    }, context, rawContactId, userId);
  }
}

const getImageBlobDataFromDB =
  (id: string, callback: Function | undefined, context: Context, rawContactId: string, userId?: number) => {
  let task = new taskpool.Task(getPixelMapFromDB, id, context, rawContactId, userId ?? -1);
  taskpool.execute(task).then((pixelMap: Object) => {
    callback?.(pixelMap);
  });
}

// 本地文件获取
const getImageFileFromLocal = async (id: string, callback: Function | undefined,
  context: Context, isOld: boolean, rawContactId: string, isOldPath: boolean = true, userId?: number) => {
  HiLog.w('UserPhoto', `bigPhotoFromFile getImageFileFromLocal rawContactId: ${rawContactId}, userId: ${userId}`);
  let detailInfo: string = '';
  let task = new taskpool.Task(getFilePathFromRDB, id, rawContactId, context, userId ?? -1);
  detailInfo = await taskpool.execute(task) as string;
  HiLog.w('UserPhoto', `bigPhotoFromFile getImageFileFromLocal, contactId: ${id} detailInfo: ${detailInfo}`);
  let groupDir = await GroupIdUtil.getInstance().getGroupDir(context.getApplicationContext());
  const filePath = isOldPath ? groupDir + '/' + detailInfo : '/data/storage/el4/base/files/' + detailInfo;
  fs.access(filePath).then((res: boolean) => {
    if (res && !StringUtil.isEmpty(detailInfo)) {
      let task = new taskpool.Task(getPixelMapFromLocalFile, filePath);
      taskpool.execute(task).then((pixelMap: Object) => {
        HiLog.w('UserPhoto', `bigPhotoFromFile getImageFileFromLocal from file success!`);
        callback?.(pixelMap);
      });
    } else if (isOldPath) {
      getImageFileFromLocal(id, callback, context, isOld, rawContactId, false, userId);
    } else if (isOld) {
      HiLog.w('UserPhoto', 'bigPhotoFromFile getImageFileFromLocal begin getImageBlobDataFromDB');
      getImageBlobDataFromDB(id, callback, context, rawContactId, userId);
    } else {
      callback?.();
    }
  }).catch((err: BusinessError) => {
    HiLog.e(TAG, 'access failed with error message: ' + err.message + ', error code: ' + err.code);
  });

}

@Concurrent
async function getFilePathFromRDB(
  id: string, rawContactId: string, context: Context, userId?: number): Promise<String> {
  HiLog.w('UserPhoto', `bigPhotoFromFile start. userId: ${userId}`);
  let detailInfo = '';

  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('contact_id', id);
    conditionArgs.and();
    conditionArgs.equalTo('type_id', 8);
    if (!StringUtil.isEmpty(rawContactId)) {
      conditionArgs.and();
      conditionArgs.equalTo('raw_contact_id', rawContactId);
      HiLog.w('UserPhoto', `bigPhotoFromFile getFilePathFromRDB raw_contact_id: ${rawContactId}`);
    }
    let dataShareHelper: dataShare.DataShareHelper =
      await ContactRepository.getInstance().init(context).getDataAbilityHelper();
    resultSet = await dataShareHelper.query(Data.CONTENT_URI, conditionArgs, [Data.DETAIL_INFO]);
    if (resultSet && resultSet.rowCount > 0) {
      HiLog.w('UserPhoto', `bigPhotoFromFile getFilePathFromRDB resultSet.rowCount: ${resultSet.rowCount}`);
      resultSet.goToFirstRow();
      do {
        let detailInfoQuery = resultSet.getString(resultSet.getColumnIndex(Data.DETAIL_INFO));
        if (!StringUtil.isEmpty(detailInfoQuery)) {
          detailInfo = detailInfoQuery;
          HiLog.w('UserPhoto',
            `bigPhotoFromFile getFilePathFromRDB detailInfo: ${detailInfo}, contactId: ${id}, rawContactId: ${rawContactId}`);
          break;
        }
      } while (resultSet.goToNextRow());
    }
    return detailInfo;
  } catch (error) {
    HiLog.e('UserPhoto ', 'bigPhotoFromFile getFilePathFromRDB error: ' + error?.message);
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
  return detailInfo;
}

@Concurrent
async function getPixelMapFromLocalFile(filePath: string): Promise<PixelMap | null> {
  let imageSource: image.ImageSource | null = null;
  try {
    hiTraceMeter.startTrace(TraceConstants.TRACE_DETAIL_CREATE_BIG_PHOTO,
      TraceConstants.TRACE_DETAIL_CREATE_BIG_PHOTO_ID);
    imageSource = image.createImageSource(filePath);
    if (imageSource !== undefined) {
      let pixelMap = await imageSource.createPixelMap().catch((error: BusinessError) => {
        HiLog.e('UserPhoto', `createPixelMap error:${error?.message}`);
      });
      hiTraceMeter.finishTrace(TraceConstants.TRACE_DETAIL_CREATE_BIG_PHOTO,
        TraceConstants.TRACE_DETAIL_CREATE_BIG_PHOTO_ID);
      return pixelMap ? pixelMap : null;
    } else {
      HiLog.i('UserPhoto', 'createImageSource filePath result empty');
      hiTraceMeter.finishTrace(TraceConstants.TRACE_DETAIL_CREATE_BIG_PHOTO,
        TraceConstants.TRACE_DETAIL_CREATE_BIG_PHOTO_ID);
    }
  } catch (error) {
    // 联系人故障打点-联系人头像解析失败
    // Report Fault Dot Message
    faultContactParams.FAULT_INFO = error.message;
    DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.ADD_CONTACTS_PHOTO_FAIL);
    HiLog.e('UserPhoto ', 'getPixelMapFromLocalFile error: ' + error?.message);
  } finally {
    imageSource?.release().catch((error: BusinessError) => {
      HiLog.e('UserPhoto', ' release resource error: ' + error?.message);
    })
  }
  return null;
}

@Concurrent
async function getPixelMapFromDB(contactId: string, context: Context, rawContactId: string, userId?: number) {
  let imageSource: image.ImageSource | null = null;
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    HiLog.i('UserPhoto  ',
      `getPixelMapFromDB contactId: ${contactId}, rawContactId: ${rawContactId}, userId: ${userId}`);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('contact_id', contactId);
    conditionArgs.equalTo('type_id', 8);
    if (!StringUtil.isEmpty(rawContactId)) {
      conditionArgs.equalTo(Data.RAW_CONTACT_ID, rawContactId);
    }
    let dataShareHelper: dataShare.DataShareHelper =
      await ContactRepository.getInstance().init(context).getDataAbilityHelper(userId);
    resultSet = await dataShareHelper.query(Data.CONTENT_URI, conditionArgs, [Data.BLOB_DATA]);
    if (resultSet.rowCount === 0) {
      return null;
    }
    resultSet.goToFirstRow();
    let blobData: Uint8Array = resultSet.getBlob(resultSet.getColumnIndex(Data.BLOB_DATA));

    imageSource = image.createImageSource(blobData.buffer);
    if (imageSource !== undefined) {
      let pixelMap = await imageSource.createPixelMap({ desiredSize: { height: vp2px(128), width: vp2px(128) } });
      return pixelMap;
    }
  } catch (error) {
    // 联系人故障打点-联系人头像解析失败
    faultContactParams.FAULT_INFO = error.message;
    DotUtil.getInstance().reportFaultEvent(faultContactParams, dotCommon.faultEventName.ADD_CONTACTS_PHOTO_FAIL);
    HiLog.e('UserPhoto  ', 'getPixelMapFromDB error: ' + error?.message);
    emitter.emit(EmitterConstant.GET_ALL_CONTACTS_EMITTER_ID);
  } finally {
    imageSource?.release().catch((error: BusinessError) => {
      HiLog.e('UserPhoto', ' release resource error: ' + error?.message);
    })
    ObjectUtil.closeResultSet(resultSet);
  }
  return null;
}

export const delFileById = async (id: string, refresh?: boolean) => {
  try {
    PixelMapManager.getInstance().deletePixelMap(id);
    if (refresh) {
      AppStorage.setOrCreate('contactsWithModifiedPhoto', id + '-' + new Date().getTime());
    }
  } catch (err) {
    HiLog.e(TAG, 'remove file failed with error message: ' + err.message + ', error code: ' + err.code);
  }
}

const allChinese: RegExp = new RegExp('^[\\u4E00-\\u9FA5]+$');
const allEnglish: RegExp = new RegExp('^[a-zA-Z]+$');
const hasChinese: RegExp = new RegExp('[\\u4E00-\\u9FA5]');
const hasEnglish: RegExp = new RegExp('[a-zA-Z]');

export function getHeadChar(name?: string): string {
  if (StringUtil.isEmpty(name) || (typeof name !== 'string')) {
    return '';
  }
  name = name.replace(new RegExp('<\/?.+?>', 'g'), '')
  let headChar = '';

  if (hasChinese.test(name)) {
    for (let i = name.length - 1; i >= 0; --i) {
      if (hasChinese.test(name[i])) {
        headChar = name[i];
        break;
      }
    }
  } else if (hasEnglish.test(name[0])) {
    headChar = name[0];
  } else {
    headChar = '';
  }
  return headChar;
}

export async function pickPhotoThumbnail(uri: string, context: Context): Promise<PixelMap | null> {
  try {
    const photoAccessHelper = await import('@ohos.file.photoAccessHelper')
    let phAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);
    let predicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('uri', uri);
    let fetchResult = await phAccessHelper.getAssets({
      fetchColumns: [],
      predicates: predicates
    });
    let asset = await fetchResult.getFirstObject();
    let pixelMap = await asset.getThumbnail({ width: vp2px(128), height: vp2px(128) });
    HiLog.w(TAG, '[picker] getThumbnail asset uri = ' + asset.uri);
    return pixelMap;
  } catch (error) {
    HiLog.e('UserPhoto ', 'pickPhotoThumbnail error: ' + error?.message);
  }
  return null
}

export function copyPixelMap(ori:PixelMap | undefined): PixelMap | undefined {
  if (ori === undefined || ori === null) {
    return ori;
  }
  const oriBytesNumber = ori.getPixelBytesNumber();
  const buffer = new ArrayBuffer(oriBytesNumber);
  ori.readPixelsToBufferSync(buffer);
  let oriImgInfo = ori.getImageInfoSync();
  HiLog.i(TAG, `copyPixelMap oriImgInfo:${oriImgInfo}`)
  let bgraBuffer = rgba2BGRA(buffer);
  let ret = image.createPixelMapSync(bgraBuffer, {
    size:{width: oriImgInfo.size.width, height: oriImgInfo.size.height},
  })
  return ret;
}

export function rgba2BGRA(data: ArrayBuffer): ArrayBuffer {
  let len = data.byteLength;
  let tmpBuffer = new ArrayBuffer(len);
  let rgbaData = new DataView(data);
  let bgraData = new DataView(tmpBuffer);

  for (let i = 0; i < len; i += 4) {
    bgraData.setUint8(i, rgbaData.getUint8(i + 2));
    bgraData.setUint8(i + 1, rgbaData.getUint8(i + 1));
    bgraData.setUint8(i + 2, rgbaData.getUint8(i));
    bgraData.setUint8(i + 3, rgbaData.getUint8(i + 3));
  }
  return tmpBuffer;
}

export function base64StrToPixelMap(base64Str: string): PixelMap {
  let helper = new util.Base64Helper();

  let buffer = helper.decodeSync(base64Str, util.Type.MIME).buffer as ArrayBuffer;
  let imageSource = image.createImageSource(buffer);
  let opts: image.DecodingOptions = { editable: true};
  let retPixelMap = imageSource.createPixelMapSync(opts);
  imageSource.release().catch((error: BusinessError) => {
  });
  return retPixelMap;
}

export class ContactPhotoVo {
  public contactId: string;
  public pixelMap: PixelMap;

  constructor(contactId: string, pixelMap: PixelMap) {
    this.contactId = contactId;
    this.pixelMap = pixelMap;
  }
}

export function buildContactPhotoVo(contactId: string, blobData: Uint8Array): ContactPhotoVo {
  let imageSource = image.createImageSource(blobData.buffer);
  let pixelMap = imageSource.createPixelMapSync({
    desiredSize: {
      height: vp2px(128),
      width: vp2px(128)
    }
  });
  imageSource.release();
  return new ContactPhotoVo(contactId, pixelMap);
}

@Concurrent
export function scalePixelMap(pixelMap: image.PixelMap, context: Context): image.PixelMap {
  HiLog.w('UserPhoto', `scalePixelMap start`)
  try {
    const oriBytesNumber = pixelMap.getPixelBytesNumber();
    const buffer = new ArrayBuffer(oriBytesNumber);
    pixelMap.readPixelsToBufferSync(buffer);
    let oriImgInfo = pixelMap.getImageInfoSync();

    let len = buffer.byteLength;
    let tmpBuffer = new ArrayBuffer(len);
    let rgbaData = new DataView(buffer);
    let bgraData = new DataView(tmpBuffer);
    for (let i = 0; i < len; i += 4) {
      bgraData.setUint8(i, rgbaData.getUint8(i + 2));
      bgraData.setUint8(i + 1, rgbaData.getUint8(i + 1));
      bgraData.setUint8(i + 2, rgbaData.getUint8(i));
      bgraData.setUint8(i + 3, rgbaData.getUint8(i + 3));
    }
    let imgScaled = image.createPixelMapSync(tmpBuffer, {
      size:{width: oriImgInfo.size.width, height: oriImgInfo.size.height},
    })

    if (imgScaled) {
      HiLog.w('UserPhoto', `imgScaled is not null`);
      let scaledImgInfo = imgScaled.getImageInfoSync();
      let scaledL: number = 0;
      if (scaledImgInfo) {
        let size = scaledImgInfo.size;
        scaledL = size.width;
        let cropY = (size.height - size.width) / 2;
        if (cropY < 0) {
          cropY = 0;
        }
        imgScaled.cropSync({
          size: {height:scaledL, width:scaledL},
          x:0,
          y:cropY
        })
      }
      let vpValue = context.resourceManager.getNumber($r('app.float.id_card_image_mid'));
      let scale = 0.5;
      if (scaledL > 0) {
        scale = vp2px(vpValue) * 2 / scaledL;
      }
      imgScaled.scaleSync(scale, scale);
      return imgScaled;
    } else {
      HiLog.w('UserPhoto', `imgScaled is null`);
      return pixelMap;
    }
  } catch (err) {
    HiLog.e('UserPhoto', `scalePixelMap err: ${err.message}`)
    return pixelMap;
  }
}