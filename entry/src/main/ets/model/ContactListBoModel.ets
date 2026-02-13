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
export class ContactListBoModel {
  // 标记是否可以点击搜索栏，进入搜索页面；true，可以； false，不可以
  private toSearchPage: boolean = true;
  private static instance: ContactListBoModel | null = null;

  /**
   * 获取实例
   * @returns
   */
  public static getInstance() {
    if (ContactListBoModel.instance === null) {
      ContactListBoModel.instance = new ContactListBoModel();
    }

    return ContactListBoModel.instance;
  }

  /**
   * 设置
   * @param toSearchPage
   */
  public setToSearchPage(toSearchPage: boolean) {
    this.toSearchPage = true;
  }

  public getToSearchPage() {
    return this.toSearchPage;
  }
}