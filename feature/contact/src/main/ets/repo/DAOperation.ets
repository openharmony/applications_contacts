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

import FeatureAbility from '@ohos.ability.featureAbility';

export default class DAOperation {
  readonly uri: string;
  readonly type: number;
  valuesBucket?: object;
  valueBackReferences?: object;
  predicates?: object;
  predicatesBackReferences?: Map<number, number>;
  interrupted?: boolean;
  expectedCount?: number;
  constructor(uri: string, type: number) {
    this.uri = uri;
    this.type = type;
  }

  static newInsert(uri: string) {
    return new DAOperation(uri, FeatureAbility.DataAbilityOperationType.TYPE_INSERT)
  }

  static newDelete(uri: string) {
    return new DAOperation(uri, FeatureAbility.DataAbilityOperationType.TYPE_DELETE)
  }

  static newUpdate(uri: string) {
    return new DAOperation(uri, FeatureAbility.DataAbilityOperationType.TYPE_UPDATE)
  }

  withValueBackReferences(key: string, previousResult: number) {
    if (this.type != FeatureAbility.DataAbilityOperationType.TYPE_INSERT
    && this.type != FeatureAbility.DataAbilityOperationType.TYPE_UPDATE
    && this.type != FeatureAbility.DataAbilityOperationType.TYPE_ASSERT) {
      return;
    }
    if (this.valueBackReferences == undefined) {
      this.valueBackReferences = {};
    }
    this.valueBackReferences[key] = previousResult;
  }

  withValue(key: string, obj: object) {
    if (this.type != FeatureAbility.DataAbilityOperationType.TYPE_INSERT
    && this.type != FeatureAbility.DataAbilityOperationType.TYPE_UPDATE
    && this.type != FeatureAbility.DataAbilityOperationType.TYPE_ASSERT) {
      return;
    }
    if (this.valuesBucket == undefined) {
      this.valuesBucket = {};
    }
    this.valuesBucket[key] = obj;
  }
}