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
import { CallLog } from '../../../../../../feature/call';
import { MergeRule } from '../../../../../../feature/call/src/main/ets/CallLogSetting';
import { SimCardType } from '../../data/Constants';
import { PhoneNumBean } from '../../model/bean/PhoneNumBean';

export class ActionDataType {
  public mergeRule: MergeRule = 0;
  public favoriteForm: string = '';
}

export class ObjNull {
}

export class MissedCallListType {
  public callLog: CallLog[] = [];
  public formId: string = '';
  public title: string = '';
}

export class ContactPhonesType {
  public data: ContactPhonesDataType = new ContactPhonesDataType();
}

export class ContactGetIdPhonesDataType {
  public favorite: string = '';
  public phones: PhonesDataType[] = [];
  public id: number = 0;
  public photoFirstName: string = '';
  public contactId: string = '';
  public isCommonUseType: number = 0;
  public displayName: string = '';
  public phoneNum: string = '';
  public nameSuffix: string = '';
  public namePrefix: string = '';
  public portraitColor: PortraitColorType = new PortraitColorType();
  public isUsuallyShow: boolean = false;
  public portraitPath: string = '';
  public isEditSelect: boolean = false;
  public favoriteOrder: number = 0;
  public position: string = '';
  public showName: string = '';
}

export class PortraitColorType {
  public id: number = 0;
  public type: number = 0;
  public params: string[] = [];
  public bundleName: string = 'com.ohos.contacts';
  public moduleName: string = 'entry';
}

export class ContactPhonesDataType {
  public favorite: string = '';
  public phones: PhonesDataType[] = [];
  public display_name: string = '';
  public nameUpdate: string = '';
  public id: number = 0;
  public photoFirstName: string = '';
}

export class PhonesDataType {
  public num: string = '';
  public id: string = '';
  public numType: string = '';
  public primary: boolean = false;
  public dataId: string = '';
}

type CardDialogInfoFlag = 'selectNum' | 'selectSim' | 'selectRoamingNum';

export class CardDialogInfoType {
  public flag: CardDialogInfoFlag = 'selectNum';
  public phoneList: PhoneNumBean[] = [];
  public simList: CardDialogSimInfo[] = [];
  public lastSimId: number = -1;
  public roamingOriginNumber?: string;
  public roamingOldFormatNumber?: string;
}

export class CardDialogSimInfo {
  public state: boolean = false;
  public slotId: number = 0;
  public name: string | Resource = $r('app.string.NoService');
  public img: Resource = $r('sys.symbol.phone_badge_1');
  public simType: SimCardType = SimCardType.PSIM;
  public index: number = 0;
}