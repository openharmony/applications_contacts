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

@Component
export default struct DetailInfoListItemView {
  private title: string;
  private content: string | Resource;
  private hasRow: boolean;

  build() {
    Row() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
        Text(this.title)
          .fontSize(16)
        Text(this.content)
          .fontSize(14)
          .fontColor($r('app.color.gray'))
      }

      Blank();

      Image($r('app.media.ic_contacts_arrow_up'))
        .align(Alignment.Center)
        .width("20vp")
        .height("20vp")
        .visibility(this.hasRow ? Visibility.Visible : Visibility.None)
        .opacity(0.2)
    }
    .width('100%')
    .height("60vp")
    .padding({ top: 5, bottom: 5 })
  }
}