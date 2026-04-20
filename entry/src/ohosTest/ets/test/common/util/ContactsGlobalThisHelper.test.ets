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
import { describe, expect, it } from '@ohos/hypium';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { common } from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';

export default function ContactsGlobalThisHelperTest() {
  describe('ContactsGlobalThisHelperTest', () => {

    it('ContactsGlobalThisHelperTest_hasValue_true', 0, () => {
      ContactsGlobalThisHelper.GetGlobalThis().set<string>(ContactsGlobalThisHelper.UIContextName, 'testValue');
      let result4 = ContactsGlobalThisHelper.GetGlobalThis().hasValue(ContactsGlobalThisHelper.UIContextName);
      expect(result4).assertTrue();
    })

    it('ContactsGlobalThisHelperTest_getDefaultUIContext_return', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<common.UIAbilityContext>(ContactsGlobalThisHelper.UIContextName, context);
      let result = ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext();
      expect(result).assertEqual(context);
    })

    it('ContactsGlobalThisHelperTest_getDefaultCardDialogContext', 0, () => {
      let result1 = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardDialogContext();
      expect(result1).assertEqual(undefined);
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.CardDialogContextName, '111');
      let result3 = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardDialogContext();
      expect(result1).not().assertEqual(result3);
      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.CardDialogContextName);
    })

    it('ContactsGlobalThisHelperTest_getCardMissedCallAbilityContext_return', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<common.UIAbilityContext>(ContactsGlobalThisHelper.CardMissedCallAbilityContextName, context);

      let result = ContactsGlobalThisHelper.GetGlobalThis().getCardMissedCallAbilityContext();

      expect(result).assertEqual(context);
    })


    it('ContactsGlobalThisHelperTest_getCardMissedCallAbilityContext', 0, () => {
      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.CardMissedCallAbilityContextName);

      let result = ContactsGlobalThisHelper.GetGlobalThis().getCardMissedCallAbilityContext();

      expect(result).assertUndefined();
    })

    it('ContactsGlobalThisHelperTest_getCardShortcutAbilityContext_return', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<common.UIAbilityContext>(ContactsGlobalThisHelper.CardShortcutAbilityContextName, context);

      let result = ContactsGlobalThisHelper.GetGlobalThis().getCardShortcutAbilityContext();

      expect(result).assertEqual(context);
    })


    it('ContactsGlobalThisHelperTest_getCardShortcutAbilityContext', 0, () => {
      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.CardShortcutAbilityContextName);

      let result = ContactsGlobalThisHelper.GetGlobalThis().getCardShortcutAbilityContext();

      expect(result).assertUndefined();
    })

    it('ContactsGlobalThisHelperTest_getCardSpeedDialAbilityContext_return', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<common.UIAbilityContext>(ContactsGlobalThisHelper.CardSpeedDialAbilityContextName, context);

      let result = ContactsGlobalThisHelper.GetGlobalThis().getCardSpeedDialAbilityContext();

      expect(result).assertEqual(context);
    })


    it('ContactsGlobalThisHelperTest_getCardSpeedDialAbilityContext', 0, () => {
      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.CardSpeedDialAbilityContextName);

      let result = ContactsGlobalThisHelper.GetGlobalThis().getCardSpeedDialAbilityContext();

      expect(result).assertUndefined();
    })

    it('ContactsGlobalThisHelperTest_getCardDialogExtensionAbilityContext_return', 0, () => {
      let context: common.UIAbilityContext = DTGlobalContext.getContext()
        .getObject("contactContext") as common.UIAbilityContext;
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<common.UIAbilityContext>(ContactsGlobalThisHelper.CardDialogExtensionAbilityContextName, context);

      let result = ContactsGlobalThisHelper.GetGlobalThis().getCardDialogExtensionAbilityContext();

      expect(result).assertEqual(context);
    })


    it('ContactsGlobalThisHelperTest_getCardDialogExtensionAbilityContext', 0, () => {
      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.CardDialogExtensionAbilityContextName);

      let result = ContactsGlobalThisHelper.GetGlobalThis().getCardDialogExtensionAbilityContext();

      expect(result).assertUndefined();
    })

    it('ContactsGlobalThisHelperTest_getDefaultCardContext', 0, () => {
      let result1 = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
      expect(result1).assertEqual(undefined);
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.CardContextName, '111');
      let result3 = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
      expect(result1).not().assertEqual(result3);
      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.CardContextName);
    })

    it('ContactsGlobalThisHelperTest_getCardUIContext', 0, () => {
      let result1 = ContactsGlobalThisHelper.GetGlobalThis().getCardUIContext();
      expect(result1).assertEqual(undefined);
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.CardContextName, '111');
      let result3 = ContactsGlobalThisHelper.GetGlobalThis().getCardUIContext();
      expect(result1).not().assertEqual(result3);
      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.CardContextName);
    })

    it('ContactsGlobalThisHelperTest_getDetaultContext', 0, () => {
      let context: common.Context = DTGlobalContext.getContext()
        .getObject("contactContext") as common.Context;
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<common.Context>(ContactsGlobalThisHelper.UIContextName, context);

      let result1 = ContactsGlobalThisHelper.GetGlobalThis().getDetaultContext();

      expect(result1).assertEqual(context);

      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.UIContextName);
      let result2 = ContactsGlobalThisHelper.GetGlobalThis().getDetaultContext();

      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.UIContextName);

      expect(result2).assertUndefined();
    })

    it('ContactsGlobalThisHelperTest_getSpeedDialContext', 0, () => {
      let result1 = ContactsGlobalThisHelper.GetGlobalThis().getSpeedDialContext();
      expect(result1).assertEqual(undefined);
      ContactsGlobalThisHelper.GetGlobalThis().set(ContactsGlobalThisHelper.SpeedDialContextName, '111');
      let result3 = ContactsGlobalThisHelper.GetGlobalThis().getSpeedDialContext();
      expect(result1).not().assertEqual(result3);
      ContactsGlobalThisHelper.GetGlobalThis().remove(ContactsGlobalThisHelper.SpeedDialContextName);

    })
    it('ContactsGlobalThisHelperTest_remove', 0, () => {
      ContactsGlobalThisHelper.GetGlobalThis().set<string>('testKey', 'testValue');
      ContactsGlobalThisHelper.GetGlobalThis().remove('testKey');
      expect(ContactsGlobalThisHelper.GetGlobalThis().hasValue('testKey')).assertFalse();
    })

    it('ContactsGlobalThisHelperTest_getAudioRingMode', 0, () => {
      let audioMode: audio.AudioRingMode = 0;
      ContactsGlobalThisHelper.GetGlobalThis()
        .set<audio.AudioRingMode>(ContactsGlobalThisHelper.AudioRingMode, audioMode);
      let result: audio.AudioRingMode = ContactsGlobalThisHelper.GetGlobalThis().getAudioRingMode();
      expect(result).assertEqual(audioMode);
    })
  })
}