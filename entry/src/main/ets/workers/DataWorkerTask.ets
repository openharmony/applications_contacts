/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HiLog } from '../../../../../common'
import { WorkerType } from './WorkFactory'
import WorkerWrapper from './base/WorkerWrapper'
import WorkerTask from './base/WorkerTask'
import { ThreadWorkerGlobalScope } from '@ohos.worker';
import CallLog from '../model/calllog/CalllogModel';
import { CallLog as CallLogClass } from '../../../../../feature/call/src/main/ets/entity/CallLog';
import { CallLogRepository } from '../../../../../feature/call';
import { ContactRepository } from '../../../../../feature/contact';
import ContactAbilityModel from '../model/ContactAbilityModel';
import LooseObject from '../model/type/LooseObject'
import {
  CallInfoGetParamsInCallback,
  ContactInfoGetParamsInCallback,
  ContactSearchResultData,
  CountAlphabetIndex,
  CountRawContact,
  PickerContactList,
} from '../model/type/ContactParams'
import { ContactInfo } from '../model/bean/ContactInfo'
import { ContactVo } from '../model/bean/ContactVo'
import { AllCallsGetActionData, ContactBlobSource, ContactReturnArray, ContactReturnObj } from '../model/type'
import { FavoriteBean } from '../model/bean/FavoriteBean'
import { GroupBean, IntelligenceGroupInfo } from '../model/bean/GroupBean'
import ArrayList from '@ohos.util.ArrayList'
import { AccountVo } from '../model/bean/AccountVo'
import CallDetail from '../model/bean/CallDetail'
import RecentDeleteBean from '../model/bean/RecentDeleteBean';
import GroupListItem from '../../../../../feature/contact/src/main/ets/repo/GroupListItem'
import { contact } from '@kit.ContactsKit'
import BigPhotoCopyUtil from '../util/BigPhotoCopyUtil'
import { ContactPhotoVo } from '../util/UserPhoto'
import { UtilAuditLog } from '../../../../../common/src/main/ets/util/AuditLogUtils';

const TAG = 'DataWorkerTask'

export enum DataWorkerConstant {
  'deleteCallLogsById',
  'getAllCalls',
  'getAllCallsProxy',
  'getInterceptionCalls',
  'getFirstMissedCall',
  'findByNumberIn',
  'deleteContactById',
  'deleteContactByIds',
  'addContact',
  'copyContact',
  'getAllAccount',
  'getAllContact',
  'getAllContactWithPhoneNumbers',
  'getContactById',
  'getContactIdByRawId',
  'getContactByIdList',
  'getContactMeeTimeAbilityById',
  'updateContact',
  'getIdByTelephone',
  'updateFavorite',
  'getAllFavorite',
  'getFavoriteByIndex',
  'getAllUsually',
  'getAllUsuallyByRawContact',
  'getDisplayNamesFindUsually',
  'moveSortFavorite',
  'getSearchContact',
  'getQueryT9PhoneNumbers',
  'handleCallLogSearchList',
  'getAllContactSize',
  'getAllRawContactSize',
  'getAllContactSizeAndIndex',
  'getAllFavoriteSizeAndIndex',
  'setPrimary',
  'updateFavoriteList',
  'deleteFavorite',
  'isHasContactByPhoneNumAndDisplayName',
  'updateUsuallyList',
  'addGroup',
  'getAllGroup',
  'renameGroup',
  'removeGroup',
  'deleteGroupsById',
  'queryGroupItemByName',
  'updateGroupMemberList',
  'queryAllGroupMember',
  'deleteMemberByGroupId',
  'deleteMembers',
  'findMemberByPhoneIsNotNull',
  'getContactSize',
  'getContactIdWithBlobNotNull',
  'getContactIdToBlobDataMap',
  'getContactByPhoneNums',
  'getRecorderMessage',
  'activateRestore',
  'getAllRecentDeleteContacts',
  'deleteRecycleContactByIds',
  'restoreRecycleContacts',
  'findGroupByGroupIds',
  'restoreContacts',
  'getPickerDataByIds',
  'getMyCard',
  'findNewestContact',
  'markContactAsPoster',
  'bigPhotoFileCopy',
  'checkPreDefinedExist',
  'markPreDefinedContact',
  'getPickerContacts',
  'saveRingToneToContact',
  'queryLocalRingToneUsedTimes',
  'queryOrganizationIntelligenceGroupStatistic',
  'queryCityIntelligenceGroupStatistic',
  'queryLatestContactTimeIntelligenceGroupStatistic',
  'queryIntelligenceGroupContactsByOrganization',
  'queryIntelligenceGroupContactsByTimestamp',
  'updateContactOrganizationInfo',
  'queryIntelligenceGroupContactsByCity',
  'intelligenceGroupQueryContactsForSendMsgByOrganization',
  'intelligenceGroupQueryContactsForSendMsgByTimestamp',
  'intelligenceGroupQueryContactsForSendMsgByCity',
  findRawIdById
}

export class DataWorkerTask extends WorkerTask {
  private str: string = '';
  private boolean: boolean = false;

  public getStr (): string {
    return this.str;
  }

  public getBoolean (): boolean {
    return this.boolean;
  }

  private static sInstance?: DataWorkerTask;
  private static sInstanceCurThreadUse?: DataWorkerTask;

  private constructor (workerPort?: ThreadWorkerGlobalScope) {
    super(workerPort)
  }

  static getInstance (workerPort?: ThreadWorkerGlobalScope) {
    HiLog.i(TAG, 'getInstance in.' + ' time:' + (new Date()).valueOf());
    if (DataWorkerTask.sInstance == undefined || DataWorkerTask.sInstance.workerPort == undefined) {
      DataWorkerTask.sInstance = new DataWorkerTask(workerPort);
    }
    return DataWorkerTask.sInstance;
  }

  static getInstanceCurThread () {
    if (DataWorkerTask.sInstanceCurThreadUse === undefined) {
      HiLog.i(TAG, 'DataWorkerTask getInstance!');
      DataWorkerTask.sInstanceCurThreadUse = new DataWorkerTask();
    }
    return DataWorkerTask.sInstanceCurThreadUse;
  }

  runInWorker (request: string, callBack: Function, param?: LooseObject, log?: UtilAuditLog) {
    switch (request) {
      // 静默访问方式查询calllog
      case DataWorkerConstant[DataWorkerConstant.getAllCallsProxy]:
        let paramObjProxy = param?.actionData as AllCallsGetActionData;
        if (paramObjProxy) {
          paramObjProxy.isProxyQuery = true;
        } else {
          paramObjProxy = {
            isProxyQuery: true
          }
        }
        CallLog.getAllCalls(paramObjProxy, (data: CallInfoGetParamsInCallback) => {
          HiLog.i(TAG, `enter getAllCalls`)
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.getAllCalls]:
        let paramObj = param?.actionData as AllCallsGetActionData;
        if (paramObj) {
          paramObj.isProxyQuery = false;
        } else {
          paramObjProxy = {
            isProxyQuery: false
          }
        }
        CallLog.getAllCalls(param?.actionData, (data: CallInfoGetParamsInCallback) => {
          HiLog.i(TAG, `enter getAllCalls`)
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.getInterceptionCalls]:
        CallLog.getInterceptionCalls(param?.actionData, (data: CallInfoGetParamsInCallback) => {
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.getFirstMissedCall]:
        CallLog.getFirstMissedCall(param?.actionData, (data: CallLogClass[]) => {
          HiLog.i(TAG, `getFirstMissedCall result size: ${data?.length}`)
          callBack(data);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.findByNumberIn]:
        CallLogRepository.getInstance().init(param?.actionData?.context);
        CallLogRepository.getInstance().findByNumberIn(param?.actionData, (resultList) => {
          callBack(resultList);
        });
        break
      case DataWorkerConstant[DataWorkerConstant.deleteContactById]:
        ContactRepository.getInstance().init(param?.context);
        ContactRepository.getInstance().deleteById(param?.contactId, (result: number | undefined) => {
          HiLog.w(TAG, `deleteContactById result ${result}`)
          callBack(result);
        }, log);
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteContactByIds]:
        ContactRepository.getInstance().init(param?.context);
        ContactRepository.getInstance().deleteByIdIn(param?.ids, (result: number | undefined) => {
          callBack(result);
        }, log);
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteCallLogsById]:
        CallLogRepository.getInstance().init(param?.context);
        CallLogRepository.getInstance().deleteByIdIn(param?.ids, param?.phoneNumbers, (result) => {
          callBack(result);
        })
        break;
      case DataWorkerConstant[DataWorkerConstant.addContact]:
        const contactInfoAfter: ContactInfo = JSON.parse(param?.contactInfoAfter)
        contactInfoAfter.photo = param?.photoBlob || contactInfoAfter.photo;
        // 返回值为rawId，contactId的数组；提前查询一下contactId，可以并发查，避免使用时重新查询，要等待查询结果
        ContactAbilityModel.addContact(contactInfoAfter, (arg: string[]) => {
          callBack(arg);
        }, param?.isMyCard, param?.context, log)
        break
      case DataWorkerConstant[DataWorkerConstant.copyContact]:
        ContactRepository.getInstance().init(param?.context);
        ContactAbilityModel.copyContact(param?.copyList, param?.context,
          param?.accountId, (result: number | undefined) => {
            HiLog.i(TAG, `copyContact result ${result}`)
            callBack(result);
          });
        break
      case DataWorkerConstant[DataWorkerConstant.getAllAccount]:
        ContactAbilityModel.getAllAccount((result: AccountVo[]) => {
          callBack(result);
        })
        break
      case DataWorkerConstant[DataWorkerConstant.getAllContact]:
        ContactAbilityModel.getAllContact(param?.actionData, (result: ContactVo[]) => {
          callBack(result);
        })
        break
      case DataWorkerConstant[DataWorkerConstant.getAllContactWithPhoneNumbers]:
        ContactAbilityModel.getAllContactWithPhoneNumbers((resultList: ContactInfoGetParamsInCallback) => {
          callBack(resultList);
        }, JSON.parse(param?.favoriteForm), param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getContactById]:
        ContactAbilityModel.getContactById(param?.contactId, (result: ContactReturnObj) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getContactIdByRawId]:
        ContactAbilityModel.getContactIdByRawId(param?.rawContactId, (contactId: string[]) => {
          callBack?.(contactId);
        }, param?.context);
        break
      case DataWorkerConstant[DataWorkerConstant.getContactMeeTimeAbilityById]:
        ContactAbilityModel.getContactMeeTimeAbilityById(param?.contactId, (result: ContactReturnObj) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getContactByIdList]:
        ContactAbilityModel.getContactByIdList(param?.contactIdList, (result: ContactReturnArray) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getIdByTelephone]:
        ContactAbilityModel.getIdByTelephone(param?.phoneNumber, param?.quickSearchKey ?? -1, (contactId: string[]) => {
          callBack(contactId);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.isHasContactByPhoneNumAndDisplayName]:
        ContactAbilityModel.isHasContactByPhoneNumAndDisplayName(param?.phoneNumber,
          param?.displayName, (isHasContact: boolean) => {
            callBack(isHasContact);
          }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.updateContact]:
        let contactBefore: ContactInfo = param?.contactInfoBefore;
        const query: ContactInfo = param?.contactInfoAfter;
        query.photo = param?.photoBlob || query.photo;
        let deletePhoto: boolean = param?.deletePhoto;
        ContactAbilityModel.updateContact(null, contactBefore, query, deletePhoto, (arg: string) => {
          callBack(arg);
        }, param?.isMyCard, param?.context, log)
        break
      case DataWorkerConstant[DataWorkerConstant.updateFavorite]:
        ContactAbilityModel.updateFavorite(null, JSON.parse(param?.favoriteForm), (arg: number) => {
          callBack(arg);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.updateFavoriteList]:
        ContactAbilityModel.updateFavoriteList(null, JSON.parse(param?.favoriteList),
          param?.favorite, param?.favoriteOrder, (arg: undefined) => {
            callBack(arg);
          }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.deleteFavorite]:
        ContactAbilityModel.deleteFavorite(param?.favoriteList, (arg: undefined) => {
          callBack(arg);
        }, param?.context);
        break
      case DataWorkerConstant[DataWorkerConstant.updateUsuallyList]:
        ContactAbilityModel.updateUsuallyList(null, JSON.parse(param?.usuallyList), (arg: undefined) => {
          callBack(arg);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getAllFavorite]:
        ContactAbilityModel.getAllFavorite((result: FavoriteBean[]) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getFavoriteByIndex]:
        ContactAbilityModel.getFavoriteByIndex(param?.actionData, param?.index, (result: FavoriteBean[]) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getAllUsually]:
        ContactAbilityModel.getAllUsually((result: CallLogClass[]) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getAllUsuallyByRawContact]:
        ContactAbilityModel.getAllUsuallyByRawContact((result: Array<LooseObject>) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getDisplayNamesFindUsually]:
        ContactAbilityModel.getDisplayNamesFindUsually(param?.displayName,
          param?.usuallyPhone, (result: FavoriteBean[]) => {
            callBack(result);
          }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.moveSortFavorite]:
        ContactAbilityModel.moveSortFavorite(null, JSON.parse(param?.favoriteForm), (result: string) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getSearchContact]:
        ContactAbilityModel.getSearchContact(param?.actionData, (result: ContactSearchResultData) => {
          callBack(result);
        }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getQueryT9PhoneNumbers]:
        ContactAbilityModel.getQueryT9PhoneNumbers((resultList: ContactVo[]) => {
          callBack(resultList);
        }, JSON.parse(param?.favoriteForm), param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.handleCallLogSearchList]:
        CallLog.handleCallLogSearchList(param?.timeStamp, (resultList: CallInfoGetParamsInCallback) => {
          callBack(resultList);
        }, param?.data, param?.result, param?.nameArray, param?.callLogSearchList)
        break
      case DataWorkerConstant[DataWorkerConstant.getAllContactSize]:
        ContactAbilityModel.getAllContactSize((result: CountAlphabetIndex) => {
          callBack(result);
        }, param?.hasMyCard)
        break
      case DataWorkerConstant[DataWorkerConstant.getAllRawContactSize]:
        ContactAbilityModel.getAllRawContactSize((result: CountRawContact) => {
          callBack(result);
        })
        break
      case DataWorkerConstant[DataWorkerConstant.getAllContactSizeAndIndex]:
        ContactAbilityModel.getAllContactSizeAndIndex((result: CountAlphabetIndex) => {
          callBack(result);
        })
        break
      case DataWorkerConstant[DataWorkerConstant.getAllFavoriteSizeAndIndex]:
        ContactAbilityModel.getAllFavoriteSizeAndIndex((result: CountAlphabetIndex) => {
          callBack(result);
        })
        break
      case DataWorkerConstant[DataWorkerConstant.getContactIdWithBlobNotNull]:
        ContactRepository.getInstance()
          .getContactIdWithBlobNotNull((result: ContactBlobSource[]) => {
            callBack(result);
          }, param?.contactIds, param?.page, param?.userId);
        break
      case DataWorkerConstant[DataWorkerConstant.getContactIdToBlobDataMap]:
        ContactRepository.getInstance()
          .getContactIdWithBlobNotNull((result: ContactBlobSource[]) => {
            let map = new Map<string, ContactBlobSource>();
            result.forEach((item: ContactBlobSource) => {
              map.set(item.contactId, item);
            });
            HiLog.i(TAG, `getContactIdToBlobDataMap result: ${map.size}`)
            callBack(map);
          }, param?.contactIds, param?.page, param?.userId);
        break;
      case DataWorkerConstant[DataWorkerConstant.setPrimary]:
        // 不关心返回值
        ContactAbilityModel.setPrimary(param?.contactId, param?.dataType, param?.dataId, param?.primary);
        break
      case DataWorkerConstant[DataWorkerConstant.addGroup]:
        ContactAbilityModel.addGroup(param?.groupName, param?.groupAccountId, (arg: string) => {
          callBack(arg);
        }, param?.context)
      case DataWorkerConstant[DataWorkerConstant.getAllGroup]:
        ContactAbilityModel.getAllGroup((data: GroupBean[]) => {
          HiLog.i(TAG, `getAllGroup result size: ${data?.length}`)
          callBack(data);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.renameGroup]:
        ContactAbilityModel.renameGroup(param?.groupInfo, (result: string) => {
          callBack(result);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.removeGroup]:
        ContactAbilityModel.removeGroup(param?.id, (result: string) => {
          callBack(result);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteGroupsById]:
        ContactAbilityModel.deleteGroupsById(param?.ids, (arg: string) => {
          callBack(arg);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.queryGroupItemByName]:
        ContactAbilityModel.queryGroupItemByName(param?.groupName, (arg: GroupBean) => {
          callBack(arg);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.updateGroupMemberList]:
        ContactAbilityModel.updateGroupMemberList(JSON.parse(param?.selectMemberList),
          param?.groupId, (arg: string) => {
            callBack(arg);
          }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.queryAllGroupMember]:
        ContactAbilityModel.queryAllGroupMember(param?.groupId, (result: ContactVo[]) => {
          callBack(result);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteMemberByGroupId]:
        ContactAbilityModel.deleteMemberByGroupId(param?.groupId, (arg: string) => {
          callBack(arg);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteMembers]:
        ContactAbilityModel.deleteMembers(param?.groupId, param?.contactId, (arg: number) => {
          callBack(arg);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.findMemberByPhoneIsNotNull]:
        ContactAbilityModel.findMemberByPhoneIsNotNull(param?.groupId, (result: ContactVo[]) => {
          callBack(result);
        }, param?.context);
        break
      case DataWorkerConstant[DataWorkerConstant.getContactSize]:
        ContactAbilityModel.getContactSize(param?.accountId, (result: number) => {
          callBack(result);
        })
        break
      case DataWorkerConstant[DataWorkerConstant.getRecorderMessage]:
        CallLog.getRecorderMessage(param?.callDetailList, (result: CallDetail[]) => {
          callBack(result);
        })
        break
      case DataWorkerConstant[DataWorkerConstant.activateRestore]:
        ContactAbilityModel.activateRestore(param?.context);
        break
      case DataWorkerConstant[DataWorkerConstant.getAllRecentDeleteContacts]:
        ContactAbilityModel.getAllRecentDeleteContacts((result: RecentDeleteBean[]) => {
          HiLog.w(TAG, `getAllRecentDeleteContacts result: ${result.length}`)
          callBack(result);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteRecycleContactByIds]:
        ContactRepository.getInstance().init(param?.context);
        ContactRepository.getInstance().deleteRecycleContactByIds(param?.ids, (result: number | undefined) => {
          HiLog.w(TAG, `deleteRecycleContactByIds result: ${result}`)
          callBack(result);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.restoreRecycleContacts]:
        ContactRepository.getInstance().init(param?.context);
        ContactRepository.getInstance().restoreRecycleContactByIds(param?.ids, (result: number | undefined) => {
          HiLog.w(TAG, `restoreRecycleContacts result: ${result}`)
          callBack(result);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.findGroupByGroupIds]:
        ContactRepository.getInstance().init(param?.context);
        ContactRepository.getInstance().findGroupByGroupIds(param?.ids, param?.userId, (result: GroupListItem[]) => {
          HiLog.i(TAG, `findGroupByGroupIds result: ${result.length}`)
          callBack(result);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.restoreContacts]:
        ContactRepository.getInstance().init(param?.context);
        ContactRepository.getInstance().restoreContacts((success: boolean) => {
          callBack?.(success);
        })
        break;
      case DataWorkerConstant[DataWorkerConstant.getPickerDataByIds]:
        ContactAbilityModel.getPickerDataByIds(param?.contactIds, param?.userId,
          (contactIdPickerDataMap: Map<number, contact.Contact>) => {
            HiLog.w(TAG, `getPickerDataByIds contactIdPickerDataMap size: ${contactIdPickerDataMap.size}`)
            callBack(contactIdPickerDataMap);
          }, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.getMyCard]:
        ContactAbilityModel.getMyCard((result: ContactVo[]) => {
          callBack?.(result);
        })
        break;
      case DataWorkerConstant[DataWorkerConstant.findNewestContact]:
        ContactAbilityModel.findNewestContact((contactId: string[]) => {
          callBack?.(contactId);
        }, param?.context)
        break;
      case DataWorkerConstant[DataWorkerConstant.markContactAsPoster]:
        ContactAbilityModel.markContactAsPoster(param?.contactIds, (result: number) => {
          callBack?.(result);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.bigPhotoFileCopy]:
        BigPhotoCopyUtil.getInstance().bigPhotoFileCopy((result: string) => {
          callBack?.(result);
        })
        break;
      case DataWorkerConstant[DataWorkerConstant.checkPreDefinedExist]:
        HiLog.i(TAG, `checkPreDefinedExist`);
        const name: string = param?.name;
        const phones: string[] = param?.phones;
        const emails: string[] = param?.emails;
        ContactRepository.getInstance().checkPreDefinedExist(name, phones, emails, (result: LooseObject[]) => {
          callBack?.(result);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.markPreDefinedContact]:
        HiLog.i(TAG, `markPreDefinedContact`);
        const contactIds: string[] = param?.contactIds;
        ContactRepository.getInstance().markPreDefinedContact(contactIds, (result: number) => {
          callBack?.(result);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.getPickerContacts]:
        HiLog.i(TAG, `getPickerContacts`);
        ContactAbilityModel.getPickerContacts(param?.isDisplayByName, param?.contactSelectionFilter,
          param?.userId, param?.page, param?.isFavorite, param?.isOnePageShow,
          (result: PickerContactList) => {
            HiLog.w(TAG, `getPickerContacts end`);
            callBack?.(result);
          }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.saveRingToneToContact]:
        HiLog.i(TAG, `saveRingToneToContact`);
        ContactAbilityModel.saveRingToneToContact(
          param?.id, param?.uri, param?.ringToneName, param?.ringToneFilePath, (result: boolean) => {
          HiLog.w(TAG, `saveRingToneToContact end`);
          callBack?.(result);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryLocalRingToneUsedTimes]:
        HiLog.i(TAG, `queryLocalRingToneUsedTimes`);
        ContactAbilityModel.queryLocalRingToneUsedTimes(
          param?.id, param?.uri, (result: number) => {
          HiLog.w(TAG, `queryLocalRingToneUsedTimes end`);
          callBack?.(result);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryIntelligenceGroupContactsByOrganization]:
        ContactAbilityModel.queryIntelligenceGroupContactsByOrganization(param?.organization, param?.page as number,
          (result: ContactInfoGetParamsInCallback) => {
            callBack(result);
          }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.queryIntelligenceGroupContactsByCity]:
        ContactAbilityModel.queryIntelligenceGroupContactsByCity(param?.location, param?.page as number,
          (result: ContactInfoGetParamsInCallback) => {
            callBack(result);
          }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.queryOrganizationIntelligenceGroupStatistic]:
        ContactAbilityModel.queryOrganizationIntelligenceGroupStatistic((result: IntelligenceGroupInfo[]) => {
          callBack(result);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.queryCityIntelligenceGroupStatistic]:
        ContactAbilityModel.queryCityIntelligenceGroupStatistic((result: IntelligenceGroupInfo[]) => {
          callBack(result);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.queryLatestContactTimeIntelligenceGroupStatistic]:
        ContactAbilityModel.queryLatestContactTimeIntelligenceGroupStatistic((result: IntelligenceGroupInfo[]) => {
          callBack(result);
        }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.updateContactOrganizationInfo]:
        ContactAbilityModel.updateContactOrganizationInfo(param?.rawContactIds, param?.organization,
          (result: boolean) => {
            callBack(result);
          }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.queryIntelligenceGroupContactsByTimestamp]:
        ContactAbilityModel.queryIntelligenceGroupContactsByTimestamp(param?.contactTimeType, param?.page as number,
          (result: ContactInfoGetParamsInCallback) => {
            callBack(result);
          }, param?.context);
        break;
      case DataWorkerConstant[DataWorkerConstant.intelligenceGroupQueryContactsForSendMsgByOrganization]:
        ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByOrganization((
          resultList: ContactInfoGetParamsInCallback) => {
          callBack(resultList);
        }, param?.origanization, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.intelligenceGroupQueryContactsForSendMsgByCity]:
        ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByCity((
          resultList: ContactInfoGetParamsInCallback) => {
          callBack(resultList);
        }, param?.location, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.intelligenceGroupQueryContactsForSendMsgByTimestamp]:
        ContactAbilityModel.intelligenceGroupQueryContactsForSendMsgByTimestamp((
          resultList: ContactInfoGetParamsInCallback) => {
          callBack(resultList);
        }, param?.contactTimeType, param?.context)
        break
      case DataWorkerConstant[DataWorkerConstant.findRawIdById]:
        ContactRepository.getInstance().init(param?.context);
        ContactRepository.getInstance().findRawIdById(param?.contactId, (result: number | undefined) => {
          HiLog.i(TAG, `findRawIdById result ${result}`);
          callBack(result);
        });
        break;
      default:
        HiLog.w(TAG, `${request} not allow!!!`)
        break;
    }
  }
}