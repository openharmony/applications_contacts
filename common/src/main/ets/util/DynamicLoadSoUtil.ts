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
/**
 * 动态加载so工具
 */
export class DynamicLoadSoUtil {
  private static instance: DynamicLoadSoUtil | null = null;

  public static getInstance(): DynamicLoadSoUtil {
    if (DynamicLoadSoUtil.instance === null) {
      DynamicLoadSoUtil.instance = new DynamicLoadSoUtil();
    }
    return DynamicLoadSoUtil.instance;
  }

  /**
   * 加载vcard
   * @returns
   */
  async loadVcard() {
    return await import('@ohos.telephony.vcard');
  }

  async loadCameraPicker() {
    return await import('@ohos.multimedia.cameraPicker');
  }

  async loadPhotoAccessHelper() {
    return await import('@ohos.file.photoAccessHelper');
  }

  async loadCalendarManager() {
    return await import('@ohos.calendarManager');
  }

  async loadBundleManager() {
    return await import('@ohos.bundle.bundleManager');
  }

  // public async loadSmartMobility(): Promise<ESObject> {
  //   return await import('@hms.carService.smartMobilityCommon');
  // }

}