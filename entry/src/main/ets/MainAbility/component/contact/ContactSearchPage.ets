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

import ContactListItemView from './ContactListItemView';
import {ContactVo} from '../../model/bean/ContactVo';
import HiLog from '../../util/HiLog';

/**
 * 搜索联系人界面；
 */
@Component
export default struct ContactSearchPage {
  @Link private showSearch: boolean;
  @Link private isSearched: boolean;
  @State private mSerchText: string = "";
  private mContactList: ContactVo[] = [new ContactVo("1", "5", "12345", "公司", "职位", "#FF53804D", false, "", ""),
  new ContactVo("2", "5", "12345", "公司", "职位", "#FF53804D", false, "", ""),
  new ContactVo("3", "5", "12345", "公司", "职位", "#FF53804D", false, "", ""),
  new ContactVo("4", "5", "12345", "公司", "职位", "#FF53804D", false, "", ""),
  new ContactVo("5", "5", "12345", "公司", "职位", "#FF53804D", false, "", "")];

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
      Guide({ searchText: $mSerchText, showSearch: $showSearch, isSearched: $isSearched })
      if (this.showSearch && this.mSerchText.length > 0) {
        if (this.mSerchText.length > 0) {
          SearchContactList({ list: this.mContactList });
        } else {
          NoContact();
        }
      } else {
        TranslateBg();
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct Guide {
  @Link private searchText: string;
  @Link private showSearch: boolean;
  @Link private isSearched: boolean;

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Image($r("app.media.ic_public_back"))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Fill)
        .margin({ left: 25 })
        .onClick(() => {
          this.showSearch = false;
          this.isSearched = false;
        })
      TextInput({ placeholder: $r("app.string.contact_list_search") })
        .height(40)
        .width('75%')
        .margin({ left: 20 })
        .type(InputType.Normal)
        .placeholderColor(Color.Gray)
        .placeholderFont({ size: 18, weight: 2 })
        .enterKeyType(EnterKeyType.Search)
        .caretColor(Color.Green)
        .borderRadius(20)
        .onChange(value => {
          this.searchText = value;
          if (this.searchText.length > 0) {
            this.isSearched = true;
          } else {
            this.isSearched = false;
          }
        })
        .onTouch(event => {
          if (event.type == TouchType.Down) {
            this.showSearch = true;
          }
        })
    }
    .width('100%')
    .height(50)
    .backgroundColor(Color.White)
    .opacity(1)
    .margin({ bottom: 5 })
  }
}

@Component
struct TranslateBg {
  build() {
    Flex() {
    }.width('100%').flexGrow(1).opacity(0.2).backgroundColor(Color.Gray)
  }
}

@Component
struct NoContact {
  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Image($r("app.media.no_contacts_illustration"))
        .width(px2vp(210))
        .height(px2vp(210))
        .objectFit(ImageFit.Contain)
        .margin(20)
      Text($r("app.string.contact_list_search_empty"))
        .fontSize(px2fp(28))
        .fontColor('#999')
        .fontWeight(400)
    }.width('100%').height('85%')
  }
}

@Component
struct SearchContactList {
  private list: ContactVo[];

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Start,
      justifyContent: FlexAlign.Start
    }) {
      Text($r("app.string.contact_list_search"))
        .width('100%')
        .height(45)
        .fontSize(px2fp(40))
        .fontWeight(500)
        .fontColor('#747474')
        .padding({ left: 25 })

      List({ initialIndex: 0, space: 5 }) {
        ForEach(this.list, (item, index) => {
          ListItem() {
            ContactListItemView({ item: item, index: index })
          }.enabled(true)
        }, (item: ContactVo) => item.contactId.toString())
      }
      .width("90%")
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .onScrollIndex((fristIndex: number, lastIndex: number) => {
      })
      .editMode(true)
      .onItemDelete((index: number) => {
        return true;
      })
    }
    .width('100%')
    .flexGrow(1)
  }
}