/**
 * Copyright (c) 2026 Huawei Device Co., Ltd.
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

import MeeTimeAbilityInfoModel from '../../../../../../feature/contact/src/main/ets/entity/MeeTimeAbilityInfoModel';
import { ContactInfo } from './ContactInfo';

export class RichContactInfo extends ContactInfo {
  public photoFirstName: string = ''
  // 对应contactdata名称类型数据，数据库EXTEND7，如果为1，表示联系人名称没有值，当前显示的名称是根据规则从其他详情信息获取的
  public nameUpdate?: number | string | Uint8Array
  public meeTimeAbilityInfoModel: MeeTimeAbilityInfoModel = new MeeTimeAbilityInfoModel()
  public accountId: number = -1

  constructor(id: string) {
    super(id, '', '', [], [], '', '', '', [], [], [], [], [], [], -1, '', '', '')
  }
}