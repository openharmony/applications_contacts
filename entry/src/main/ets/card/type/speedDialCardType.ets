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
import { PhoneNumBean } from '../../model/bean/PhoneNumBean';

export class SpeedDialCardDataType {
  public contactId: string = '';
  public displayName: string = '';
  public nameSuffix: string = '';
  public phones: PhoneNumBean[] = [];
  public showName: string = '';
  public photoFirstName?: string = '';
  public id?: number = 0;
  public base64Str?: string = ''
  public formId: string = ''
}

export class PortraitColorType {
  public id: number = 0;
  public type: number = 0;
  public params: string[] = [];
  public bundleName: string = 'com.ohos.contacts';
  public moduleName: string = 'entry';
}

export class phonesDataType {
  public favorite: string = '';
  public display_name: string = '';
  public nameUpdate: string = '';
  public phones: PhoneNumBean[] = [];
  public id: number = 0;
  public photoFirstName: string = '';
}

export class UpdateToCardType {
  public title: string = '';
  public formId: string = '';
  public contact: string = '';
}