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
import { HiLog, sharedPreferencesUtils } from '../../../../../../feature/call/oh_modules/common';
import ShortcutEditCommon from '../common/ShortcutEditCommon';
import SpeedDialEditCommon from '../common/SpeedDialEditCommon'
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { ShortcutDataType, UpdateToCardType } from '../type/shortcut';
import formBindingData from '@ohos.app.form.formBindingData';
import { SpeedDialDataType } from '../type/speedDial';
import { contact } from '@kit.ContactsKit';

let storage = LocalStorage.getShared();
const TAG = 'FormContactPicker'

@Entry(storage)
@Component
struct FormContactPicker {
  private session: UIExtensionContentSession | undefined = storage.get<UIExtensionContentSession>('session');
  @State shortcutEditCommon: ShortcutEditCommon = new ShortcutEditCommon();
  @State speedDialEditCommon: SpeedDialEditCommon = new SpeedDialEditCommon();
  private formId: string = AppStorage.get('cardFormId') as string;
  private cardType: string = '';
  private context: Context = getContext(this);
  @State shortCardData: ShortcutDataType[] = [];
  @State speedDialData: SpeedDialDataType[] = [];
  @State filterContactCard: contact.ContactSelectionFilter | undefined = undefined;

  async aboutToAppear() {
    this.formId = AppStorage.get('cardFormId') as string;
    HiLog.w(TAG, `contactPicker aboutToAppear, formId: ${this.formId}`);
    this.cardType = AppStorage.get('cardAbilityName') as string
    this.speedDialData = await this.speedDialEditCommon.queryContactByFormId(this.formId, this.context);
    let idList =
      this.speedDialData.filter(obj => obj.contactId !== undefined).map(obj => obj.contactId) as string[]
    if (idList.length > 0) {
      this.filterContactCard = {
        filterType: contact.FilterType.SHOW_FILTER,
        filterClause: {
          id: [
            {
              filterCondition: contact.FilterCondition.NOT_IN,
              value: idList
            }
          ],
          dataItem: {
            field: contact.DataField.PHONE,
            options: [{
              filterCondition: contact.FilterCondition.IS_NOT_NULL
            }]
          }
        }
      }
    } else {
      this.filterContactCard = {
        filterType: contact.FilterType.SHOW_FILTER,
        filterClause: {
          dataItem: {
            field: contact.DataField.PHONE,
            options: [{
              filterCondition: contact.FilterCondition.IS_NOT_NULL
            }]
          }
        }
      }
    }
  }

  aboutToDisappear(): void {
    HiLog.w(TAG, `contactPicker aboutToDisappear`);
  }

  onPageShow() {
    HiLog.w(TAG, `contactPicker onPageShow`);
  }

  private terminalSelf() {
    HiLog.w(TAG, `kill PickContactPage`);
    this.session?.terminateSelf();
  }

  build() {
    Column() {
      UIExtensionComponent({
        bundleName: 'com.ohos.contacts',
        abilityName: 'ContactUiExtentionAbility',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'targetUrl': 'BatchSelectContactsPage',
          'isContactMultiSelect': this.cardType === 'ShortcutCardAbility' ? false : true,
          'isDisplayByName': true,
          'selectLimit': 4 - this.speedDialData.length,
          'filter': this.filterContactCard
        }
      })
        .size({ width: '100%', height: '100%' })
        .defaultFocus(true)
        .onReceive(async (data) => {
          if (data.resultCode === 0) {
            if (this.cardType === 'ShortcutCardAbility') {
              AppStorage.setOrCreate('shortcutCardData', data)
            } else if (this.cardType === 'SpeedDialCardAbility') {
              AppStorage.setOrCreate('speedDialCardData', data)
            }
          }
          this.terminalSelf()
        })
    }
  }
}