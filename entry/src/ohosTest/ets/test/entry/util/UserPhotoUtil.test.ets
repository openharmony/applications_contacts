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
import { afterAll, afterEach,
  ArgumentMatchers,
  beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium'
import { HiLog } from '../../../../../../../feature/call/oh_modules/common'
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'
import {
  createDir,
  delFileById,
  getHeadChar,
  getImagePackingData,
  getPixelMapFromFile,
  pickPhotoThumbnail,
  PixelMapManager,
  saveImageToFile
} from '../../../../../main/ets/util/UserPhoto'
import { DTGlobalContext } from '../../../testability/TestAbility'
import common from '@ohos.app.ability.common'
import type image from '@ohos.multimedia.image'
import type colorSpaceManager from '@ohos.graphics.colorSpaceManager'
import type rpc from '@ohos.rpc'
import LooseObject from '../../../../../main/ets/model/type/LooseObject'
import { CachedContactsPixelMapType, ContactBlobSource } from '../../../../../main/ets/model/type/index';

const TAG = 'UserPhotoTest';

export default function UserPhotoTest() {
  describe('UserPhotoTest', () => {
    let pixelMap: LooseObject = {}
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
      let context = DTGlobalContext.getContext().getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.UIContextName, context);
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('Contacts_UserPhotoTest_initBlobSourceMap_one', 0, () => {
      let map = new Map<string, ContactBlobSource>();
      map.set("1", {
        contactId: '1',
        blobSource: 1,
        rawContactId: '1',
        detailInfo: ''
      });
      PixelMapManager.getInstance().initBlobSourceMap(map);
      const responseData = 1;
      expect(responseData).assertEqual(PixelMapManager.getInstance().getBlobSourceById('1'));
    })

    it('Contacts_UserPhotoTest_initBlobSourceMap_two', 1, () => {
      let map = new Map<string, ContactBlobSource>();
      map.set("1", {
        contactId: '1',
        blobSource: 1,
        rawContactId: '1',
        detailInfo: ''
      });
      PixelMapManager.getInstance().initBlobSourceMap(map);
      const responseData = -1;
      expect(responseData).assertEqual(PixelMapManager.getInstance().getBlobSourceById('2'));
    })

    it('Contacts_UserPhotoTest_createDir', 0, () => {
      let result = 0;
      createDir('11', () => {
        result = 1
      });
      expect(result).assertEqual(0);
    })

    it('Contacts_UserPhotoTest_getPixelMapFromFile_one', 0, async () => {
      HiLog.i(TAG, 'execute UserPhotoTest_getPixelMapFromFile_one,The profile picture is not initialized.');
      let result = 0;
      getPixelMapFromFile('11', (res: PixelMap | null) => {
        result = 1;
      })
      expect(PixelMapManager.resultDT).assertTrue();
    })

    it('Contacts_UserPhotoTest_getPixelMapFromFile_case_2', 0, () => {
      HiLog.i(TAG, 'execute UserPhotoTest_getPixelMapFromFile_one,The profile picture is not initialized.');
      let map = new Map<string, ContactBlobSource>();
      map.set("1", {
        contactId: '1',
        blobSource: 2,
        rawContactId: '1',
        detailInfo: ''
      });
      PixelMapManager.getInstance().initBlobSourceMap(map);
      HiLog.i(TAG, 'execute UserPhotoTest_getPixelMapFromFile_one, The value of blobSource is 2.');
      let result = 0;
      getPixelMapFromFile('1', (res: PixelMap | null) => {
        result = 1;
      })
      expect(result).assertEqual(0);
    })

    it('Contacts_UserPhotoTest_getPixelMapFromFile_case_1', 0, () => {
      HiLog.i(TAG, 'execute UserPhotoTest_getPixelMapFromFile_one,The profile picture is not initialized.');
      let map = new Map<string, ContactBlobSource>();
      map.set("1", {
        contactId: '1',
        blobSource: 1,
        rawContactId: '1',
        detailInfo: ''
      });
      PixelMapManager.getInstance().initBlobSourceMap(map);
      HiLog.i(TAG, 'execute UserPhotoTest_getPixelMapFromFile_one, The value of blobSource is 1.');
      let result = 0;
      getPixelMapFromFile('1', (res: PixelMap | null) => {
        result = 1;
      })
      expect(result).assertEqual(0);
    })

    it('Contacts_UserPhotoTest_getPixelMapFromFile_case_0', 0, () => {
      HiLog.i(TAG, 'execute UserPhotoTest_getPixelMapFromFile_one,The profile picture is not initialized.');
      let map = new Map<string, ContactBlobSource>();
      map.set("1", {
        contactId: '1',
        blobSource: 0,
        rawContactId: '1',
        detailInfo: ''
      });
      PixelMapManager.getInstance().initBlobSourceMap(map);
      HiLog.i(TAG, 'execute UserPhotoTest_getPixelMapFromFile_one, The value of blobSource is 0.');
      let result = 0;
      getPixelMapFromFile('1', (res: PixelMap | null) => {
        result = 1;
      })
      expect(result).assertEqual(0);
    })

    it('Contacts_UserPhotoTest_getHeadChar_001', 0, () => {
      let headChar = getHeadChar('');
      expect(headChar).assertEqual('');
    })

    it('Contacts_UserPhotoTest_getHeadChar_002', 0, () => {
      let headChar = getHeadChar('a中国bc人');
      expect(headChar).assertEqual('人');
    })

    it('Contacts_UserPhotoTest_getHeadChar_003', 0, () => {
      let headChar = getHeadChar('ab54c@!..');
      expect(headChar).assertEqual('a');
    })

    it('Contacts_UserPhotoTest_getHeadChar_004', 0, () => {
      let headChar = getHeadChar('@123.,.');
      expect(headChar).assertEqual('');
    })

    it('Contacts_UserPhotoTest_pickPhotoThumbnail_001', 0, async () => {
      let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      let result = await pickPhotoThumbnail('123', context);
      expect(result).assertNull();
    })

    it('Contacts_UserPhotoTest_delFileById', 0, async () => {
      delFileById('123', true);
      expect(AppStorage.Has('contactsWithModifiedPhoto')).assertTrue();
    })

    it('Contacts_UserPhotoTest_getImagePackingData', 0, async () => {
      let result = 0;
      await getImagePackingData(pixelMap as image.PixelMap, () => {
        result = 1;
      });
      expect(result).assertEqual(0);
    })

    it('Contacts_UserPhotoTest_getBlobSourceMapCopy', 0, () => {
      PixelMapManager.getInstance().contactIdBlobSourceMap.set(
        "1", {
        contactId: '1',
        blobSource: 0,
        rawContactId: '1',
        detailInfo: ''
      }
      );
      PixelMapManager.getInstance().contactIdBlobSourceMap.set(
        "2", {
        contactId: '2',
        blobSource: 0,
        rawContactId: '2',
        detailInfo: ''
      }
      );
      expect(PixelMapManager.getInstance().getBlobSourceMapCopy().size).assertEqual(2)
    })

    it('Contacts_UserPhotoTest_updateBlobSourceMap', 0, () => {
      let map = new Map<string, ContactBlobSource>();
      map.set("1", {
        contactId: '1',
        blobSource: 0,
        rawContactId: '1',
        detailInfo: ''
      });
      map.set("2", {
        contactId: '2',
        blobSource: 0,
        rawContactId: '2',
        detailInfo: ''
      })
      PixelMapManager.getInstance().updateBlobSourceMap(map, ['1'])
      expect(PixelMapManager.getInstance().contactIdBlobSourceMap.size).assertEqual(2)
    })

    it('Contacts_UserPhotoTest_cachedContactListIdMiniPixelMap_01', 0, () => {
      let data: LooseObject = {
        contactId: '1'
      }
      PixelMapManager.getInstance().contactListIdMiniPixelMap.set('2', null);

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(getPixelMapFromFile, getPixelMapFromFile))(ArgumentMatchers.any);
      PixelMapManager.getInstance().cachedContactListIdMiniPixelMap(data, CachedContactsPixelMapType.CONTACT_LIST);
      expect(PixelMapManager.getInstance().contactListIdMiniPixelMap.size).assertEqual(1);
      PixelMapManager.getInstance().contactListIdMiniPixelMap.clear();
      mocker.clear(getPixelMapFromFile);
    })

    it('Contacts_UserPhotoTest_cachedContactListIdMiniPixelMap_02', 0, () => {
      let data: LooseObject = {
        entityId: '1'
      }
      PixelMapManager.getInstance().contactSearchListMiniPixelMap.set('1', null);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(getPixelMapFromFile, getPixelMapFromFile);
      PixelMapManager.getInstance()
        .cachedContactListIdMiniPixelMap(data, CachedContactsPixelMapType.CONTACT_SEARCH_LIST);
      mocker.verify('getPixelMapFromFile', [ArgumentMatchers.any]).never();
      PixelMapManager.getInstance().contactSearchListMiniPixelMap.clear();
      mocker.clear(getPixelMapFromFile);
    })

    it('Contacts_UserPhotoTest_cachedContactListIdMiniPixelMap_03', 0, () => {
      let data: LooseObject = {
        entityId: '1'
      }
      PixelMapManager.getInstance().contactSearchListMiniPixelMap.set('2', null);

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(getPixelMapFromFile, getPixelMapFromFile))(ArgumentMatchers.any);
      PixelMapManager.getInstance()
        .cachedContactListIdMiniPixelMap(data, CachedContactsPixelMapType.CONTACT_SEARCH_LIST);
      expect(PixelMapManager.getInstance().contactSearchListMiniPixelMap.size).assertEqual(1);
      PixelMapManager.getInstance().contactSearchListMiniPixelMap.clear();
      mocker.clear(getPixelMapFromFile);
    })

    it('Contacts_UserPhotoTest_updateContactSearchListMiniPixelMap', 0, () => {
      let contactIds: string[] = ['1'];
      PixelMapManager.getInstance().contactSearchListMiniPixelMap.set('2', null);

      PixelMapManager.getInstance().updateContactSearchListMiniPixelMap(contactIds);
      expect(PixelMapManager.getInstance().contactSearchListMiniPixelMap.size).assertEqual(0);
      PixelMapManager.getInstance().contactSearchListMiniPixelMap.clear();
    })

    it('Contacts_UserPhotoTest_releaseContactListAllPixelMap', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(PixelMapManager.getInstance().contactListIdMiniPixelMap,
        PixelMapManager.getInstance().contactListIdMiniPixelMap.clear);
      mocker.mockFunc(PixelMapManager.getInstance().contactSearchListMiniPixelMap,
        PixelMapManager.getInstance().contactSearchListMiniPixelMap.clear);
      PixelMapManager.getInstance().releaseContactListAllPixelMap(true, true);
      mocker.verify('clear', []).times(2);
      mocker.clear(PixelMapManager.getInstance().contactListIdMiniPixelMap);
      mocker.clear(PixelMapManager.getInstance().contactSearchListMiniPixelMap);
    })
  })
}