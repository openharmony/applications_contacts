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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { Relation } from '../../../../../../../../feature/contact/src/main/ets/contract/Relation'

export default function RelationTest() {
  describe('RelationTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
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
    })
    it('RelationTest_getTypeLabelResource', 0, () => {
      const imgSrc1: Resource = Relation.getTypeLabelResource(Relation.TYPE_CHILD);
      const expectedImgSrc1: Resource = $r("app.string.relationship_type_children");
      expect(JSON.stringify(imgSrc1)).assertEqual(JSON.stringify(expectedImgSrc1));

      const imgSrc2: Resource = Relation.getTypeLabelResource(Relation.TYPE_DOMESTIC_PARTNER);
      const expectedImgSrc2: Resource = $r("app.string.relationship_type_partner");
      expect(JSON.stringify(imgSrc2)).assertEqual(JSON.stringify(expectedImgSrc2));

      const imgSrc3: Resource = Relation.getTypeLabelResource(Relation.TYPE_ASSISTANT);
      const expectedImgSrc3: Resource = $r("app.string.relationship_type_assistant");
      expect(JSON.stringify(imgSrc3)).assertEqual(JSON.stringify(expectedImgSrc3));

      const imgSrc4: Resource = Relation.getTypeLabelResource(Relation.TYPE_BROTHER);
      const expectedImgSrc4: Resource = $r("app.string.relationship_type_brother");
      expect(JSON.stringify(imgSrc4)).assertEqual(JSON.stringify(expectedImgSrc4));

      const imgSrc5: Resource = Relation.getTypeLabelResource(Relation.TYPE_PARTNER);
      const expectedImgSrc5: Resource = $r("app.string.relationship_type_mates");
      expect(JSON.stringify(imgSrc5)).assertEqual(JSON.stringify(expectedImgSrc5));

      const imgSrc6: Resource = Relation.getTypeLabelResource(Relation.TYPE_FATHER);
      const expectedImgSrc6: Resource = $r("app.string.relationship_type_father");
      expect(JSON.stringify(imgSrc6)).assertEqual(JSON.stringify(expectedImgSrc6));

      const imgSrc7: Resource = Relation.getTypeLabelResource(Relation.TYPE_FRIEND);
      const expectedImgSrc7: Resource = $r("app.string.relationship_type_friend");
      expect(JSON.stringify(imgSrc7)).assertEqual(JSON.stringify(expectedImgSrc7));

      const imgSrc8: Resource = Relation.getTypeLabelResource(Relation.TYPE_MANAGER);
      const expectedImgSrc8: Resource = $r("app.string.relationship_type_bosses");
      expect(JSON.stringify(imgSrc8)).assertEqual(JSON.stringify(expectedImgSrc8));

      const imgSrc9: Resource = Relation.getTypeLabelResource(Relation.TYPE_MOTHER);
      const expectedImgSrc9: Resource = $r("app.string.relationship_type_mother");
      expect(JSON.stringify(imgSrc9)).assertEqual(JSON.stringify(expectedImgSrc9));

      const imgSrc10: Resource = Relation.getTypeLabelResource(Relation.TYPE_PARENTS);
      const expectedImgSrc10: Resource = $r("app.string.relationship_type_parents");
      expect(JSON.stringify(imgSrc10)).assertEqual(JSON.stringify(expectedImgSrc10));

      const imgSrc11: Resource = Relation.getTypeLabelResource(Relation.TYPE_REFERRED_BY);
      const expectedImgSrc11: Resource = $r("app.string.relationship_type_introducer");
      expect(JSON.stringify(imgSrc11)).assertEqual(JSON.stringify(expectedImgSrc11));

      const imgSrc12: Resource = Relation.getTypeLabelResource(Relation.TYPE_RELATIVE);
      const expectedImgSrc12: Resource = $r("app.string.relationship_type_kinship");
      expect(JSON.stringify(imgSrc12)).assertEqual(JSON.stringify(expectedImgSrc12));

      const imgSrc13: Resource = Relation.getTypeLabelResource(Relation.TYPE_SISTERS);
      const expectedImgSrc13: Resource = $r("app.string.relationship_type_sisters");
      expect(JSON.stringify(imgSrc13)).assertEqual(JSON.stringify(expectedImgSrc13));

      const imgSrc14: Resource = Relation.getTypeLabelResource(Relation.TYPE_SPOUSES);
      const expectedImgSrc14: Resource = $r("app.string.relationship_type_spouses");
      expect(JSON.stringify(imgSrc14)).assertEqual(JSON.stringify(expectedImgSrc14));

      const imgSrc15: Resource = Relation.getTypeLabelResource(Relation.TYPE_CUSTOM);
      const expectedImgSrc15: Resource = $r("app.string.relationship_type_custom");
      expect(JSON.stringify(imgSrc15)).assertEqual(JSON.stringify(expectedImgSrc15));

      const imgSrc16: Resource = Relation.getTypeLabelResource(Relation.TYPE_INVALID);
      const expectedImgSrc16: Resource = $r("app.string.relationship_type_custom");
      expect(JSON.stringify(imgSrc16)).assertEqual(JSON.stringify(expectedImgSrc16));
    })

    it('RelationTest_apiTypeToSystemType', 0, () => {
      expect(Relation.apiTypeToSystemType(0)).assertEqual(10000);
      expect(Relation.apiTypeToSystemType(1)).assertEqual(Relation.TYPE_ASSISTANT);
      expect(Relation.apiTypeToSystemType(2)).assertEqual(Relation.TYPE_BROTHER);
      expect(Relation.apiTypeToSystemType(3)).assertEqual(Relation.TYPE_CHILD);
      expect(Relation.apiTypeToSystemType(4)).assertEqual(Relation.TYPE_DOMESTIC_PARTNER);
      expect(Relation.apiTypeToSystemType(5)).assertEqual(Relation.TYPE_FATHER);
      expect(Relation.apiTypeToSystemType(6)).assertEqual(Relation.TYPE_FRIEND);
      expect(Relation.apiTypeToSystemType(7)).assertEqual(Relation.TYPE_MANAGER);
      expect(Relation.apiTypeToSystemType(8)).assertEqual(Relation.TYPE_MOTHER);
      expect(Relation.apiTypeToSystemType(9)).assertEqual(Relation.TYPE_PARENTS);
      expect(Relation.apiTypeToSystemType(10)).assertEqual(Relation.TYPE_PARTNER);
      expect(Relation.apiTypeToSystemType(11)).assertEqual(Relation.TYPE_REFERRED_BY);
      expect(Relation.apiTypeToSystemType(12)).assertEqual(Relation.TYPE_RELATIVE);
      expect(Relation.apiTypeToSystemType(13)).assertEqual(Relation.TYPE_SISTERS);
      expect(Relation.apiTypeToSystemType(14)).assertEqual(Relation.TYPE_SPOUSES);
      expect(Relation.apiTypeToSystemType(77)).assertEqual(Relation.TYPE_ASSISTANT);
    })

  })
}