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


import dataStorage from '@ohos.data.storage';
import featureAbility from '@ohos.ability.featureAbility';
import common from './../model/common/Constants';
import ObjectUtil from './ObjectUtil';

const TAG = 'PreferencesUtil';
let myDataStorage;

export default {
  async initDataStorage() {

    let context = featureAbility.getContext();
    let path = await context.getFilesDir();
    myDataStorage = dataStorage.getStorageSync(path + "/" + common.string.PATH_OF_PREFERENCES,);
  },

  isUsed() {
    if (!ObjectUtil.isEmpty(myDataStorage)) {
      if (myDataStorage.getSync('IsUsed', 0) === 1) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  },

  setIsUsed(isUsed) {
    if (!ObjectUtil.isEmpty(myDataStorage)) {
      if (isUsed) {
        myDataStorage.putSync('IsUsed', 1);
        myDataStorage.flushSync();
      } else {
        myDataStorage.putSync('IsUsed', 0);
        myDataStorage.flushSync();
      }
    }
  },
}