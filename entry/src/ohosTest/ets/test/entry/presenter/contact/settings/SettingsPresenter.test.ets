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
import { describe, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium';
import SettingsPresenter, { FileInfo } from '../../../../../../../main/ets/presenter/contact/settings/SettingsPresenter';
import ArrayList from '@ohos.util.ArrayList';
import {
  PrivacyStatementContentTag
} from '../../../../../../../main/ets/presenter/contact/settings/PrivacyStatementPresenter';
import { DynamicLoader } from '../../../../../../../../../feature/call/oh_modules/common';
import LooseObject from '../../../../../../../main/ets/model/type/LooseObject';


export default function SettingsPresenterTest() {

  describe('SettingsPresenterTest', () => {

    it("SettingsPresenter_aboutToAppear", 0, () => {
      SettingsPresenter.getInstance().aboutToAppear();
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
    })

    it("SettingsPresenter_aboutToDisappear", 0, () => {
      SettingsPresenter.getInstance().aboutToDisappear();
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
    })

    it("SettingsPresenter_getInstance", 0, async () => {
      expect(SettingsPresenter.getInstance()).not().assertNull();
    })

    it("SettingsPresenter_importAndExport", 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      SettingsPresenter.getInstance().pathInfos = new NavPathStack();
      when(mockFunc)(DynamicLoader.IMPORT_AND_EXPORT_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(SettingsPresenter.getInstance().pathInfos?.pushPathByName('ImportAndExport', ''));
      }));
      SettingsPresenter.getInstance().importAndExport();
      expect(SettingsPresenter.getInstance().pathInfos?.getParamByName('ImportAndExport').toString()).assertEqual('');
      mocker.clear(DynamicLoader.getInstance());
    })

    it("SettingsPresenter_importAndExport_pathInfos_undefined", 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      SettingsPresenter.getInstance().pathInfos = undefined;
      when(mockFunc)(DynamicLoader.IMPORT_AND_EXPORT_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(SettingsPresenter.getInstance().pathInfos?.pushPathByName('ImportAndExport', ''));
      }));
      SettingsPresenter.getInstance().importAndExport();
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
      mocker.clear(DynamicLoader.getInstance());
    })

    it("SettingsPresenter_recentDelete", 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      SettingsPresenter.getInstance().pathInfos = new NavPathStack();
      when(mockFunc)(DynamicLoader.RECENT_DELETE_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(SettingsPresenter.getInstance().pathInfos?.pushPathByName(DynamicLoader.RECENT_DELETE_PAGE, ''));
      }));
      SettingsPresenter.getInstance().recentDelete();
      expect(SettingsPresenter.getInstance().pathInfos?.getParamByName(DynamicLoader.RECENT_DELETE_PAGE).toString())
        .assertEqual('');
      mocker.clear(DynamicLoader.getInstance());
    })

    it("SettingsPresenter_recentDelete_undefined", 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      SettingsPresenter.getInstance().pathInfos = undefined;
      when(mockFunc)(DynamicLoader.RECENT_DELETE_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(SettingsPresenter.getInstance().pathInfos?.pushPathByName(DynamicLoader.RECENT_DELETE_PAGE, ''));
      }));
      SettingsPresenter.getInstance().recentDelete();
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
      mocker.clear(DynamicLoader.getInstance());
    })

    it("SettingsPresenter_arrangeContacts", 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      SettingsPresenter.getInstance().pathInfos = new NavPathStack();
      when(mockFunc)(DynamicLoader.ARRANGE_CONTACTS_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(SettingsPresenter.getInstance().pathInfos?.pushPathByName(DynamicLoader.ARRANGE_CONTACTS_PAGE, ''));
      }));
      SettingsPresenter.getInstance().arrangeContacts();
      expect(SettingsPresenter.getInstance().pathInfos?.getParamByName(DynamicLoader.ARRANGE_CONTACTS_PAGE).toString())
        .assertEqual('');
      mocker.clear(DynamicLoader.getInstance());
    })

    it("SettingsPresenter_arrangeContacts_pathInfos_undefined", 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      SettingsPresenter.getInstance().pathInfos = undefined;
      when(mockFunc)(DynamicLoader.ARRANGE_CONTACTS_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(SettingsPresenter.getInstance().pathInfos?.pushPathByName(DynamicLoader.ARRANGE_CONTACTS_PAGE, ''));
      }));
      SettingsPresenter.getInstance().arrangeContacts();
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
      mocker.clear(DynamicLoader.getInstance());
    })

    it("SettingsPresenter_accountList", 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      SettingsPresenter.getInstance().pathInfos = new NavPathStack();
      when(mockFunc)(DynamicLoader.ACCOUNT_LIST_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(SettingsPresenter.getInstance().pathInfos?.pushPathByName(DynamicLoader.ACCOUNT_LIST_PAGE, ''));
      }));
      SettingsPresenter.getInstance().accountList();
      expect(SettingsPresenter.getInstance().pathInfos?.getParamByName(DynamicLoader.ACCOUNT_LIST_PAGE).toString())
        .assertEqual('');
      mocker.clear(DynamicLoader.getInstance());
    })

    it("SettingsPresenter_accountList_undefined", 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire);
      SettingsPresenter.getInstance().pathInfos = undefined;
      when(mockFunc)(DynamicLoader.ACCOUNT_LIST_PAGE).afterReturn(new Promise<void> ((resolve: Function) => {
        resolve(SettingsPresenter.getInstance().pathInfos?.pushPathByName(DynamicLoader.ACCOUNT_LIST_PAGE, ''));
      }));
      SettingsPresenter.getInstance().accountList();
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
      mocker.clear(DynamicLoader.getInstance());
    })

    it("SettingsPresenter_fileInfo", 0, async () => {
      let fileNames: string[] = [];
      let fileDetailList = SettingsPresenter.fileInfo(fileNames, '/data/storage/el4/base/files');
      expect(fileDetailList.length).assertEqual(0);
    })

    it("SettingsPresenter_queryVCF", 0, async () => {
      expect(SettingsPresenter.queryVCF().length).assertEqual(0);
    })

    it("SettingsPresenter_queryVCF_error", 0, async () => {
      let mocker:MockKit=new MockKit();
      when(mocker.mockFunc(SettingsPresenter.getInstance(),SettingsPresenter.fileInfo))(ArgumentMatchers.any)
        .afterThrow('error');
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
      mocker.clear(SettingsPresenter.getInstance());
    })

    it("SettingsPresenter_importVCF", 0, async () => {
      let fileNames: ArrayList<string> = new ArrayList();
      fileNames.add('00001.vcf');
      fileNames.add('00002.vcf');
      let contactsIsMore = true;
      let account = 1;
      SettingsPresenter.getInstance().importVCF(fileNames, contactsIsMore, account);
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
    })

    it("SettingsPresenter_event", 0, async () => {
      SettingsPresenter.getInstance().event(1, false);
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
    })

    it("SettingsPresenter_exportVCF", 0, async () => {
      SettingsPresenter.getInstance().exportVCF(['1'], true, 1);
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
    })

    it("SettingsPresenter_changeFileName", 0, async () => {
      let mocker:MockKit = new MockKit();
      SettingsPresenter.getInstance().changeFileName(1);
      expect(SettingsPresenter.getInstance().total).assertEqual(0);
    })

    it("SettingsPresenter_getLevel", 0, async () => {
      SettingsPresenter.getInstance().total = 9;
      expect(SettingsPresenter.getInstance().getLevel()).assertEqual(0);
      SettingsPresenter.getInstance().total = 100;
      expect(SettingsPresenter.getInstance().getLevel()).assertEqual(1);
      SettingsPresenter.getInstance().total = 500;
      expect(SettingsPresenter.getInstance().getLevel()).assertEqual(2);
      SettingsPresenter.getInstance().total = 1000;
      expect(SettingsPresenter.getInstance().getLevel()).assertEqual(3);
      SettingsPresenter.getInstance().total = 10000;
      expect(SettingsPresenter.getInstance().getLevel()).assertEqual(4);
    })

    it("SettingsPresenter_importProgress", 0, async () => {
      SettingsPresenter.getInstance().total = 9;
      expect(SettingsPresenter.getInstance().importProgress(0)).assertEqual(10);
      SettingsPresenter.getInstance().total = 100;
      expect(SettingsPresenter.getInstance().importProgress(0)).assertEqual(8);
      SettingsPresenter.getInstance().total = 500;
      expect(SettingsPresenter.getInstance().importProgress(0)).assertEqual(6);
      SettingsPresenter.getInstance().total = 1000;
      expect(SettingsPresenter.getInstance().importProgress(0)).assertEqual(5);
      SettingsPresenter.getInstance().total = 10000;
      expect(SettingsPresenter.getInstance().importProgress(0)).assertEqual(2);
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(SettingsPresenter.getInstance(),SettingsPresenter.getInstance().getLevel))()
        .afterReturn(5);
      expect(SettingsPresenter.getInstance().importProgress(0)).assertEqual(0);
      mocker.clear(SettingsPresenter.getInstance());
    })

    it("SettingsPresenter_exportProgress", 0, async () => {
      SettingsPresenter.getInstance().total = 9;
      expect(SettingsPresenter.getInstance().exportProgress(0)).assertEqual(100);
      SettingsPresenter.getInstance().total = 100;
      expect(SettingsPresenter.getInstance().exportProgress(0)).assertEqual(50);
      SettingsPresenter.getInstance().total = 500;
      expect(SettingsPresenter.getInstance().exportProgress(0)).assertEqual(30);
      SettingsPresenter.getInstance().total = 1000;
      expect(SettingsPresenter.getInstance().exportProgress(0)).assertEqual(20);
      SettingsPresenter.getInstance().total = 10000;
      expect(SettingsPresenter.getInstance().exportProgress(0)).assertEqual(10);
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(SettingsPresenter.getInstance(),SettingsPresenter.getInstance().getLevel))()
        .afterReturn(5);
      expect(SettingsPresenter.getInstance().exportProgress(0)).assertEqual(0);
      mocker.clear(SettingsPresenter.getInstance());
    })

    it("SettingsPresenter_FileInfo_constructor", 0, async () => {
      let fileInfo: FileInfo = new FileInfo('test', 'data', 0);
      expect(fileInfo.filename).assertEqual('test');
    })

  })
}