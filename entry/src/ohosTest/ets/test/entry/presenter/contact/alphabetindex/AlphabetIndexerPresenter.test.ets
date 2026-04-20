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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import { AlphabetIndexObj, CharIndex, ContactVo } from '../../../../../../../main/ets/model/bean/ContactVo'
import AlphabetIndexerPresenter
  from '../../../../../../../main/ets/presenter/contact/alphabetindex/AlphabetIndexerPresenter'

export default function AlphabetIndexerPresenterTest() {
  describe('AlphabetIndexerPresenterTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.

    let alphabetIndexerPresenter: AlphabetIndexerPresenter;
    let contactVo: ContactVo;

    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.

      alphabetIndexerPresenter = new AlphabetIndexerPresenter();
      contactVo = new ContactVo("", "", "", "", "", "", {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: '',
      }, true, "", "", '0');
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
    it('AlphabetIndexerPresenterTest_getInstance', 0, () => {
      expect(typeof AlphabetIndexerPresenter.getInstance()).assertEqual(typeof alphabetIndexerPresenter);
    })
    it('AlphabetIndexerPresenterTest_initContactList', 0, () => {
      const contactList: ContactVo[] = [contactVo];
      alphabetIndexerPresenter.initContactList(contactList);

      expect(JSON.stringify(alphabetIndexerPresenter.contactList)).assertEqual(JSON.stringify([{"namePrefix":""}] ));
    })

    it('AlphabetIndexerPresenterTest_initContactList_02', 0, () => {
      let FAVORITE_SYMBOL = '☆';
      contactVo.favorite = '1';
      contactVo.namePrefix = '张'
      const contactList: ContactVo[] = [contactVo];
      alphabetIndexerPresenter.favoriteData = [];
      alphabetIndexerPresenter.alphabetIndexList = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
        'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
      alphabetIndexerPresenter.initContactList(contactList, true);

      expect(JSON.stringify(alphabetIndexerPresenter.alphabetIndexList)).assertEqual(JSON.stringify([FAVORITE_SYMBOL,
        '#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
        'V', 'W', 'X', 'Y', 'Z']));
      expect(JSON.stringify(alphabetIndexerPresenter.favoriteData)).assertEqual(JSON.stringify([{'namePrefix':'张'}]));
    })
    it('AlphabetIndexerPresenterTest_initAlphabetIndex', 0, () => {
      const alphabetIndex: Record<string, AlphabetIndexObj> = {'test': new AlphabetIndexObj()}

      alphabetIndexerPresenter.initAlphabetIndex(alphabetIndex);

      expect(JSON.stringify(alphabetIndexerPresenter.alphabetIndex)).assertEqual(JSON.stringify(alphabetIndex));
    })
    it('AlphabetIndexerPresenterTest_getAlphabetPopData_01', 0, () => {
      const popData = alphabetIndexerPresenter.getAlphabetPopData(27);

      expect(popData.length).assertEqual(0);
    })
    it('AlphabetIndexerPresenterTest_getAlphabetPopData_02', 0, () => {
      let charIndex01 = new CharIndex('testChar_01');
      let charIndex02 = new CharIndex('testChar_02');
      let alphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.zhPrefix = [charIndex01, charIndex02];
      alphabetIndexerPresenter.alphabetIndex = {'A': alphabetIndexObj};

      const popData = alphabetIndexerPresenter.getAlphabetPopData(1);

      expect(popData.toString()).assertEqual(['testChar_01', 'testChar_02'].toString());
    })
    it('AlphabetIndexerPresenterTest_getAlphabetPopData_03', 0, () => {
      AppStorage.setOrCreate('isVerde', true);
      alphabetIndexerPresenter.existAlphabetIndexList = ['0', '1'];
      let charIndex01 = new CharIndex('testChar_01');
      let charIndex02 = new CharIndex('testChar_02');
      let alphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.zhPrefix = [charIndex01, charIndex02];
      alphabetIndexerPresenter.alphabetIndex = {'A': alphabetIndexObj};

      const popData = alphabetIndexerPresenter.getAlphabetPopData(1);

      expect(JSON.stringify(popData)).assertEqual(JSON.stringify([]));
    })
    it('AlphabetIndexerPresenterTest_getListScrollIndex_01', 0, () => {
      const res = alphabetIndexerPresenter.getListScrollIndex(true, 1);

      expect(res).assertEqual(-1);
    })
    it('AlphabetIndexerPresenterTest_getListScrollIndex_02', 0, () => {
      let alphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.enPrefix.start = 1;
      alphabetIndexerPresenter.alphabetIndex = {'A': alphabetIndexObj};

      const res = alphabetIndexerPresenter.getListScrollIndex(true, 1);

      expect(res).assertEqual(-1);
    })
    it('AlphabetIndexerPresenterTest_getListScrollIndex_03', 0, () => {
      const FAVORITE_SYMBOL = '☆';
      AppStorage.setOrCreate('isVerde', true);
      alphabetIndexerPresenter.existAlphabetIndexList = [FAVORITE_SYMBOL];
      let mocker: MockKit = new MockKit();
      let relpceFavoriteIndexString: Function = mocker.mockFunc(alphabetIndexerPresenter,
        alphabetIndexerPresenter.relpceFavoriteIndexString);
      when(relpceFavoriteIndexString)(FAVORITE_SYMBOL).afterReturn('0');
      let alphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.zhPrefix = [new CharIndex('testChar', 100, 1)];
      alphabetIndexObj.enPrefix.start = 0;
      alphabetIndexerPresenter.alphabetIndex = {'0': alphabetIndexObj};
      alphabetIndexerPresenter.contactList = [contactVo];

      const res = alphabetIndexerPresenter.getListScrollIndex(true, 0, ['testChar'], 0, false);

      expect(res).assertEqual(100);
      mocker.clear(alphabetIndexerPresenter);
    })

    it('AlphabetIndexerPresenterTest_getListScrollIndex_04', 0, () => {
      const FAVORITE_SYMBOL = '☆';
      AppStorage.setOrCreate('isVerde', true);
      alphabetIndexerPresenter.existAlphabetIndexList = [FAVORITE_SYMBOL];
      let mocker: MockKit = new MockKit();
      let relpceFavoriteIndexString: Function = mocker.mockFunc(alphabetIndexerPresenter,
        alphabetIndexerPresenter.relpceFavoriteIndexString);
      when(relpceFavoriteIndexString)(FAVORITE_SYMBOL).afterReturn('0');
      let alphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.zhPrefix = [new CharIndex('testChar', 100, 1)];
      alphabetIndexObj.enPrefix.start = 0;
      alphabetIndexerPresenter.alphabetIndex = {'0': alphabetIndexObj};
      alphabetIndexerPresenter.contactList = [contactVo];

      const res = alphabetIndexerPresenter.getListScrollIndex(false, 0, ['testChar'], 0, true);

      expect(res).assertEqual(103);
      mocker.clear(alphabetIndexerPresenter);
    })
    it('AlphabetIndexerPresenterTest_getListScrollIndex_05', 0, () => {
      const FAVORITE_SYMBOL = '☆';
      AppStorage.setOrCreate('isVerde', true);
      alphabetIndexerPresenter.existAlphabetIndexList = [FAVORITE_SYMBOL];
      let mocker: MockKit = new MockKit();
      let relpceFavoriteIndexString: Function = mocker.mockFunc(alphabetIndexerPresenter,
        alphabetIndexerPresenter.relpceFavoriteIndexString);
      when(relpceFavoriteIndexString)(FAVORITE_SYMBOL).afterReturn('0');
      let alphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.zhPrefix = [new CharIndex('testChar', 100, 1)];
      alphabetIndexObj.enPrefix.start = 26;
      alphabetIndexerPresenter.alphabetIndex = {'0': alphabetIndexObj};
      alphabetIndexerPresenter.contactList = [contactVo];

      const res = alphabetIndexerPresenter.getListScrollIndex(true, 0, ['testChar'], 0, true);

      expect(res).assertEqual(0);
      mocker.clear(alphabetIndexerPresenter);
    })
    it('AlphabetIndexerPresenterTest_getListScrollIndex_06', 0, () => {
      const FAVORITE_SYMBOL = '☆';
      AppStorage.setOrCreate('isVerde', false);
      alphabetIndexerPresenter.alphabetIndexList = [FAVORITE_SYMBOL];
      let mocker: MockKit = new MockKit();
      let relpceFavoriteIndexString: Function = mocker.mockFunc(alphabetIndexerPresenter,
        alphabetIndexerPresenter.relpceFavoriteIndexString);
      when(relpceFavoriteIndexString)(FAVORITE_SYMBOL).afterReturn('0');
      let alphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.zhPrefix = [new CharIndex('testChar', 100, 1)];
      alphabetIndexObj.enPrefix.start = 0;
      alphabetIndexerPresenter.alphabetIndex = {'0': alphabetIndexObj};
      alphabetIndexerPresenter.contactList = [contactVo];

      const res = alphabetIndexerPresenter.getListScrollIndex(true, 0, ['testChar'], -1, true);

      expect(res).assertEqual(4);
      mocker.clear(alphabetIndexerPresenter);
    })

    it('AlphabetIndexerPresenterTest_getAlphabetSelected_01', 0, () => {
      const FAVORITE_SYMBOL = '☆';
      AppStorage.setOrCreate('isVerde', true);
      alphabetIndexerPresenter.existAlphabetIndexList = [FAVORITE_SYMBOL];
      alphabetIndexerPresenter.favoriteData = [{'namePrefix':'张'}];
      contactVo.namePrefix = 'A';
      alphabetIndexerPresenter.contactList = [contactVo];

      const res = alphabetIndexerPresenter.getAlphabetSelected(0);

      expect(res).assertEqual(0);
    })

    it('AlphabetIndexerPresenterTest_getAlphabetSelected_02', 0, () => {
      AppStorage.setOrCreate('isVerde', false);
      alphabetIndexerPresenter.favoriteData = [{'namePrefix':'张'}];
      contactVo.namePrefix = 'A';
      alphabetIndexerPresenter.contactList = [contactVo];

      const res = alphabetIndexerPresenter.getAlphabetSelected(0);

      expect(res).assertEqual(-1);
    })

    it('AlphabetIndexerPresenterTest_getAlphabetSelected_03', 0, () => {
      AppStorage.setOrCreate('isVerde', true);
      alphabetIndexerPresenter.existAlphabetIndexList = ['A'];
      contactVo.namePrefix = 'A';
      alphabetIndexerPresenter.contactList = [contactVo];
      alphabetIndexerPresenter.swipeSelectedAlphabetIndex = 2;
      alphabetIndexerPresenter.selectedAlphabetIndex = 1;

      const res = alphabetIndexerPresenter.getAlphabetSelected(0);

      expect(res).assertEqual(1);
    })

    it('AlphabetIndexerPresenterTest_getAlphabetSelected_04', 0, () => {
      AppStorage.setOrCreate('isVerde', false);
      alphabetIndexerPresenter.alphabetIndexList = ['A'];
      contactVo.namePrefix = 'A';
      alphabetIndexerPresenter.contactList = [contactVo];

      const res = alphabetIndexerPresenter.getAlphabetSelected(0);

      expect(res).assertEqual(0);
    })

    it('AlphabetIndexerPresenterTest_initExistAlphabetIndexList_01', 0, () => {
      const FAVORITE_SYMBOL = '☆';
      alphabetIndexerPresenter.initExistAlphabetIndexList(true);

      expect(JSON.stringify(alphabetIndexerPresenter.existAlphabetIndexList)).
      assertEqual(JSON.stringify([FAVORITE_SYMBOL, '#', 'A', 'D', 'G', 'J', 'M', 'P', 'S', 'V', 'Z']));
    })

    it('AlphabetIndexerPresenterTest_initFavoriteAlphabetIndex', 0, () => {
      const alphabetIndexObj: AlphabetIndexObj = new AlphabetIndexObj();
      alphabetIndexObj.enPrefix = new CharIndex('testChar', 100, 1);
      alphabetIndexObj.zhPrefix = [new CharIndex('testChar', 100, 1)];
      const alphabetIndex: Record<string, AlphabetIndexObj> = {'test': alphabetIndexObj};
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(alphabetIndexerPresenter, alphabetIndexerPresenter.reloadAlphabetIndex);
      let favoriteString: Function = mocker.mockFunc(alphabetIndexerPresenter, alphabetIndexerPresenter.favoriteString);
      when(favoriteString)().afterReturn('0');
      alphabetIndexerPresenter.initFavoriteAlphabetIndex(alphabetIndex);
      mocker.verify('reloadAlphabetIndex', []).once();
      mocker.clear(alphabetIndexerPresenter);
    })

    it('AlphabetIndexerPresenterTest_relpceFavoriteIndexString', 0, () => {
      const FAVORITE_SYMBOL = '☆';
      let mocker: MockKit = new MockKit();
      let favoriteString: Function = mocker.mockFunc(alphabetIndexerPresenter, alphabetIndexerPresenter.favoriteString);
      when(favoriteString)().afterReturn('0');
      expect(alphabetIndexerPresenter.relpceFavoriteIndexString(FAVORITE_SYMBOL)).assertEqual('0');
      mocker.clear(alphabetIndexerPresenter);
    })
  })
}