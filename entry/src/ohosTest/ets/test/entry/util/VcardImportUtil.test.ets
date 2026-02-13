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
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper';
import VcardImportUtil from '../../../../../main/ets/util/VcardImportUtil';
import Want from '@ohos.app.ability.Want';
import { fileIo } from '@kit.CoreFileKit';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import WorkerWrapper from '../../../../../main/ets/workers/base/WorkerWrapper';
import WorkFactory, { WorkerType } from '../../../../../main/ets/workers/WorkFactory';

export default function VCardImportUtilTest() {
  const VCF = 'BEGIN:VCARD\n' +
    'VERSION:2.1\n' +
    'N;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:;=E5=BD=AD=E5=8B=87=20=30=30=32=32=37=31=34=35;;;\n' +
    'FN;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:=E5=BD=AD=E5=8B=87=20=30=30=32=32=37=31=34=35\n' +
    'TEL;CELL:+8618600638710\n' +
    'TEL;CELL:01059728049\n' +
    'EMAIL;WORK:py.pengyong@ohos.com\n' +
    'ADR;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:;;=E4=B8=AD=E5=9B=BD=28=43=68=69=6E=61=29=2D=E5=8C=97=E4=BA=AC=28=42=65=\n' +
    '=69=6A=69=6E=67=29=2D=E6=B5=B7=E6=B7=80=E5=8C=BA=E4=B8=AD=E5=85=B3=E6=\n' +
    '=9D=91=E5=8C=97=E6=B8=85=E8=B7=AF=31=35=36=E5=8F=B7=E5=AE=9E=E5=88=9B=\n' +
    '=E7=A7=91=E6=8A=80=E7=A4=BA=E8=8C=83=E5=9B=AD=E5=8D=8E=E4=B8=BA=E5=85=\n' +
    '=AC=E5=8F=B8=51=32=32=20=5B=34=2D=42=31=33=32=53=5D;;;;\n' +
    'END:VCARD';
  const VCF_PATH = '/data/storage/el1/base/files/';
  const VCF_URI = '/data/storage/el1/base/files/test.vcf';

  describe('VCardImportUtilTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
      let file: fileIo.File | undefined = undefined;
      try {
        let accessableFiles: boolean = fileIo.accessSync(VCF_PATH);
        if (!accessableFiles) {
          fileIo.mkdirSync(VCF_PATH);
        }

        file = fileIo.openSync(VCF_URI, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        fileIo.writeSync(file.fd, VCF);
      } catch (error) {
        // no need do anything
      } finally {
        if (file != undefined) {
          fileIo.closeSync(file);
        }
      }
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
      try {
        fileIo.rmdirSync(VCF_URI);
        fileIo.rmdirSync(VCF_PATH);
      } catch (e) {
        // no need do anything
      }
    })

    it('VCardUtilTest_importVcardFromWant_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let getWorker: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getWorker)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper);

      const want: Want = {
        uri: 'test'
      };
      VcardImportUtil.importVcardFromWant(want, () => {});
      mocker.verify('getDefaultUIContext', []).never();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    // taskpool执行不了导致实际import并未执行
    it('VCardUtilTest_importVcardFromWant_002', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let getWorker: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getWorker)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper);

      const want: Want = {
        uri: VCF_URI
      };
      VcardImportUtil.importVcardFromWant(want, (contactId: number) => {
        expect(contactId).assertLarger(-1);
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('VCardUtilTest_importContact_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let getWorker: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getWorker)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper);

      VcardImportUtil.importContact(VCF_URI, undefined, (contactId: number) => {
        expect(contactId).assertLarger(-1);
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('VCardUtilTest_importContact_002', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let getWorker: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getWorker)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper);

      let buffer: Uint8Array = new Uint8Array(256);
      buffer.fill(1, 0, 255);
      const iconArray: ArrayBuffer = buffer.buffer.slice(0);
      let source = image.createImageSource(iconArray);
      const pixelMap = source.createPixelMapSync();

      VcardImportUtil.importContact(VCF_URI, pixelMap, (contactId: number) => {
        expect(contactId).assertLarger(-1);
      });

      pixelMap?.release();
      source.release();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('VCardUtilTest_requestNewestContact_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let getWorker: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getWorker)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper);

      VcardImportUtil.requestNewestContact(undefined, (contactId: number) => {
        expect(contactId).assertLarger(-1);
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('VCardUtilTest_saveAndMarkContactPoster_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(), ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let getWorker: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getWorker)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper);

      let buffer: Uint8Array = new Uint8Array(256);
      buffer.fill(1, 0, 255);
      const iconArray: ArrayBuffer = buffer.buffer.slice(0);
      let source = image.createImageSource(iconArray);
      const pixelMap = source.createPixelMapSync();

      VcardImportUtil.saveAndMarkContactPoster('1', pixelMap, (contactId: number) => {
        expect(contactId).assertLarger(-1);
      });
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })

    it('VCardUtilTest_requestItem_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      let getDefaultUIContext: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext);
      when(getDefaultUIContext)().afterReturn(context);
      let getWorker: Function = mocker.mockFunc(ContactsGlobalThisHelper.GetGlobalThis(),
        ContactsGlobalThisHelper.GetGlobalThis().getValue);
      when(getWorker)(ContactsGlobalThisHelper.DataWorkerName).afterReturn(
        WorkFactory.getWorker(WorkerType.DataWorker) as WorkerWrapper);

      VcardImportUtil.requestItem(() => {});
      mocker.verify('getValue', [ContactsGlobalThisHelper.DataWorkerName]).once();
      mocker.clear(ContactsGlobalThisHelper.GetGlobalThis());
    })
  })
}