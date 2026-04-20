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

/**
 * ContactsService接口
 */
export default interface IIdlContactsService {

  insertContacts(data: string, callBack: InsertContactsCallback): void;

  queryUserInfoByPhoneNumber(data: string, callback: QueryUserInfoByPhoneNumberCallback): void;

  batchQueryContactCapability(data: string, callback: BatchQueryContactCapabilityCallback): void;

  queryContactCapabilityByPhoneNumbers(contactId: number, phoneNumberList: string, callback: queryContactCapabilityByPhoneNumbersCallback): void;
}

export type QueryAllContactsCallback = (returnValue: string) => void;

export type InsertContactsCallback = (errCode: number) => void;

export type UpdateContactsByIdCallback = (errCode: number) => void;

export type UpdateAccountInfoCallback = (errCode: number) => void;

export type UpdateDeviceInfoCallback = (errCode: number) => void;

export type QueryCallRecordsByContactIdCallback = (returnValue: string) => void;

export type DeleteCallRecordsCallback = (errCode: number) => void;

export type CollectContactCallback = (errCode: number) => void;

export type DeleteContactsByIdCallback = (errCode: number) => void;

export type UpdateCapabilitiesCallback = (errCode: number) => void;

export type QueryCallRecordsByPhoneNumberCallback = (returnValue: string) => void;

export type UpdateCallRecordsByContactIdCallback = (errCode: number) => void;

export type UpdateCallRecordByPhoneCallback = (errCode: number) => void;

export type QueryContactInfoCallback = (returnValue: string) => void;

export type InsertCallRecordCallback = (errCode: number) => void;

export type UpdateCallRecordByIdCallback = (errCode: number) => void;

export type QueryDeviceInfoCallback = (returnValue: string) => void;

export type UpdateAllDeviceInfoCallback = (errCode: number) => void;

export type QueryCallRecordsCallback = (returnValue: string) => void;

export type QueryUserInfoByPhoneNumberCallback = (returnValue: string) => void;

export type BatchQueryContactCapabilityCallback = (returnValue: string) => void;

export type queryContactCapabilityByPhoneNumbersCallback = (returnValue: string) => void;