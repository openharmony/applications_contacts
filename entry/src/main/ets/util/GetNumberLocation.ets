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
import { ContactsGlobalThisHelper } from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { HiLog, NumberAddressUtil } from '../../../../../common';
import { CallLog } from '../../../../../feature/call';
import taskpool from '@ohos.taskpool';
import { BusinessError } from '@ohos.base';

const TAG = 'AllRecord ';

class NumberLocation {
  getNumberLocation(number: string, callback: Function, isExactMatch?: boolean): void {
    HiLog.w(TAG, 'getNumberLocation');
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    let task = new taskpool.Task(getNumberLocationTask, number, context, isExactMatch as boolean);
    taskpool.execute(task).then((location: Object) => {
      callback(location as string)
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'getNumberLocation error message: ' + err.message + ', error code: ' + err.code);
    });
  }

  getNumberLocationArr(numbers: Array<string>, callback: Function, context?: Context): void {
    HiLog.i(TAG, 'getNumberLocationArr');
    if (!context) {
      context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
    }
    let task = new taskpool.Task(getNumberLocationArrTask, numbers, context);
    taskpool.execute(task).then((locations: Object) => {
      callback(locations as Array<string>);
    })
  }

  getPhoneNumberFromCallList(callList: CallLog[]): string[] {
    let phoneNUmberArr: string[] = [];
    for (let i = 0; i < callList.length; i++) {
      phoneNUmberArr.push(callList[i].phoneNumber);
    }
    return phoneNUmberArr;
  }
}

export default new NumberLocation();

@Concurrent
async function getNumberLocationTask(number: string, context: Context, isExactMatch?: boolean): Promise<string> {
  HiLog.w('NumberLocation  ', 'getNumberLocation');
  try {
    let location = await NumberAddressUtil.getNumberLocation(context, number, isExactMatch);
    return location;
  } catch (err) {
    HiLog.e('NumberLocation  ', 'getNumberLocation, failed: ');
    return '';
  }
}

@Concurrent
async function getNumberLocationArrTask(numbers: Array<string>, context: Context): Promise<Array<string>> {
  HiLog.i('NumberLocation  ', 'getNumberLocationArr');
  try {
    let locations = await NumberAddressUtil.getNumberLocationArr(context, numbers);
    return locations;
  } catch (err) {
    HiLog.e('NumberLocation  ', 'getNumberLocationArr, failed: ');
    return [];
  }
}

