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

import { HiLog } from "../../../../../common"
import { WorkerType } from "./WorkFactory"
import WorkerWrapper from "./base/WorkerWrapper"
import WorkerTask from "./base/WorkerTask"
import { ThreadWorkerGlobalScope } from '@ohos.worker';
import CallLog from '../model/calllog/CalllogModel';
import { CallLogRepository } from '../../../../../feature/call';
import { ContactRepository } from '../../../../../feature/contact';
import ContactAbilityModel from '../model/ContactAbilityModel';

const TAG = "DataWorkerWrapper"

export default class DataWorkerWrapper extends WorkerWrapper {
  private static sInstance: DataWorkerWrapper = undefined;

  private constructor() {
    super()
  }

  static getInstance() {
    HiLog.i(TAG, "getInstance in.")
    if (DataWorkerWrapper.sInstance == undefined || DataWorkerWrapper.sInstance.mWorker == undefined) {
      HiLog.i(TAG, "make DataWorkerWrapper.")
      DataWorkerWrapper.sInstance = new DataWorkerWrapper();
    }
    return DataWorkerWrapper.sInstance;
  }

  getWorkerType(): WorkerType {
    return WorkerType.DataWorker;
  }
}

export enum DataWorkerConstant {
  "deleteCallLogsById",
  "getAllCalls",
  "findByNumberIn",
  "deleteContactById",
  "addContact",
  "getAllContact",
  "getAllContactWithPhoneNumbers",
  "getContactById",
  "updateContact",
  "getIdByTelephone",
}

export class DataWorkerTask extends WorkerTask {
  private static sInstance: DataWorkerTask = undefined;

  private constructor(workerPort: ThreadWorkerGlobalScope) {
    super(workerPort)
  }

  static getInstance(workerPort: ThreadWorkerGlobalScope) {
    HiLog.i(TAG, "getInstance in.")
    if (DataWorkerTask.sInstance == undefined || DataWorkerTask.sInstance.workerPort == undefined) {
      DataWorkerTask.sInstance = new DataWorkerTask(workerPort);
    }
    return DataWorkerTask.sInstance;
  }

  runInWorker(request: string, callBack: (v?: any) => void, param?: any) {
    HiLog.i(TAG, `runInWorker ${request}`)
    switch (request) {
      case DataWorkerConstant[DataWorkerConstant.getAllCalls]:
        CallLog.getAllCalls(param.actionData, param.mergeRule, (data) => {
          HiLog.i(TAG, `getAllCalls result: ${JSON.stringify(data).length}`)
          callBack(data);
        }, param.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.findByNumberIn]:
        CallLogRepository.getInstance().init(param.context);
        CallLogRepository.getInstance().findByNumberIn(param.numbers, (resultList) => {
          callBack(resultList);
        });
        break
      case DataWorkerConstant[DataWorkerConstant.deleteContactById]:
        ContactRepository.getInstance().init(param.context);
        ContactRepository.getInstance().deleteById(param.contactId, (result) => {
          HiLog.i(TAG, `deleteContactById result ${result}`)
          callBack(result);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteCallLogsById]:
        CallLogRepository.getInstance().init(param.context);
        CallLogRepository.getInstance().deleteByIdIn(param.ids, (result) => {
          callBack(result);
        })
        break;
      case DataWorkerConstant[DataWorkerConstant.addContact]:
        const contactInfoAfter = JSON.parse(param.contactInfoAfter)
        ContactAbilityModel.addContact(contactInfoAfter, (arg) => {
          callBack(arg);
        }, param.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getAllContact]:
        ContactAbilityModel.getAllContact(param.actionData, (result) => {
          callBack(result);
        }, param.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getAllContactWithPhoneNumbers]:
        ContactAbilityModel.getAllContactWithPhoneNumbers((resultList) => {
          callBack(resultList);
        }, param.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getContactById]:
        ContactAbilityModel.getContactById(param.contactId, result => {
          callBack(result);
        }, param.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getIdByTelephone]:
        ContactAbilityModel.getIdByTelephone(param.phoneNumber, (contactId) => {
          callBack(contactId);
        }, param.context)
        break
      case DataWorkerConstant[DataWorkerConstant.updateContact]:
        ContactAbilityModel.updateContact(null, JSON.parse(param.contactInfoAfter), (arg) => {
          callBack(arg);
        }, param.context)
        break
      default:
        HiLog.w(TAG, `${request} not allow!!!`)
        break;
    }
  }
}