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
class EventClass {
  public NEW_WANT: number;

  constructor() {
    this.NEW_WANT = 1;
  }
}

class StorageClass {
  public mainTabsIndex: string;
  public teleNumber: string;
  public targetPage: string;

  constructor() {
    this.mainTabsIndex = 'mainTabsIndex';
    this.teleNumber = 'teleNumber';
    this.targetPage = 'targetPage';
  }
}

class ConfigClass {
  public useDataWorker: boolean = false;
  public needCache: boolean = false;
}

class ExportClass {
  public appUseDataWorker: string = 'appUseDataWorker';
  public event: EventClass = new EventClass();
  public storage: StorageClass = new StorageClass();
  public config: ConfigClass = {
    useDataWorker: false,
    needCache: false
  };

  initConfig(context: Context): ConfigClass {
    this.config.useDataWorker = context.resourceManager.getBoolean($r('app.boolean.use_data_worker'));
    this.config.needCache=context.resourceManager.getBoolean($r('app.boolean.cache_page_one'));
    return this.config;
  }
}

export default new ExportClass();