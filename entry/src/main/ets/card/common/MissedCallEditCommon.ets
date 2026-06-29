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
import formProvider from '@ohos.app.form.formProvider';
import { HiLog } from '../../../../../../feature/call/oh_modules/common';
import formBindingData from '@ohos.app.form.formBindingData';
import { BusinessError } from '@ohos.base';

const TAG = 'missedCallEditCommon';

export default class missedCallEditCommon {
  public updateToCard = (formId: string, data: formBindingData.FormBindingData) => {
    formProvider.updateForm(formId, data).then(() => {
      HiLog.i(TAG, '[formProvider updateForm] success');
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, '[updateToCard err]' + err?.message );
    })
  }
}