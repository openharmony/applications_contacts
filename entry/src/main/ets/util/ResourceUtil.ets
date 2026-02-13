/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import resourceManager from '@ohos.resourceManager';
import common from '@ohos.app.ability.common';
import {
  ContactsGlobalThisHelper
} from '../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';


export class ResourceUtil {
  static resourceToString(title: Resource, context: common.UIAbilityContext): string {
    let resource: resourceManager.Resource = {
      bundleName: title.bundleName,
      moduleName: title.moduleName,
      id: title.id
    }
    let titleString = context.resourceManager.getStringSync(resource.id);
    return titleString;
  }

  static resourceToStringById(resource: ResourceStr) {
    if (typeof resource === 'string') {
      return resource;
    }
    return ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()?.resourceManager?.getStringSync(resource.id);
  }

  /**
   * 如果是文本信息配置，使用getString
   * @param resource
   * @returns
   */
  static getStringByResource(resource: Resource, ...args: Array<string | number>) {
    return ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()?.resourceManager?.getStringSync(resource.id, ...args)
  }

  static getStringByResourceId(resourceId: number) {
    if (typeof resourceId !== 'number') {
      return '';
    }
    return ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()?.resourceManager?.getStringSync(resourceId)
  }

  static getPluralStringByResource(resource: Resource, num: number) {
    return ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()?.resourceManager?.getPluralStringValueSync(resource, num)
  }

  /**
   * 如果是width，height等的配置，使用getNumber
   * @param resource
   * @returns
   */
  static getNumberByResource(resource: Resource) {
    return ContactsGlobalThisHelper.GetGlobalThis()
      .getDefaultUIContext()?.resourceManager?.getNumber(resource.id)
  }


}