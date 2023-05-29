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

import AlphabetIndexerPresenter from '../../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';

@Component
export struct AlphabetIndexerPage {
  scroller: Scroller;
  @Link presenter: AlphabetIndexerPresenter;
  private selectedAlphabetIndex: number = 0;
  private popDataSource: string[] = [];
  @Prop selected: number;
  @Link isClicked: boolean;
  @Link drag: boolean;

  build() {
    Column() {
      AlphabetIndexer({ arrayValue: this.presenter.alphabetIndexList, selected: this.selected })
        .selectedColor(0x1358e4)
        .popupColor(0x0254f6)
        .selectedBackgroundColor(0xe7eefe)
        .popupBackground(0xf3f3f3)
        .usingPopup(this.drag ? false : true)
        .selectedFont({ size: 16 })
        .popupFont({ size: 24 })
        .itemSize(20)
        .alignStyle(IndexerAlign.Right)
        .onSelect((index: number) => {
          this.drag = false;
          this.isClicked = true;
          this.selectedAlphabetIndex = index;
          let scrollIndex = this.presenter.getListScrollIndex(this.selectedAlphabetIndex);
          this.scroller.scrollToIndex(scrollIndex);
          // Set the click status of the index bar, otherwise there will be issues with the list scroll
          setTimeout(() => {
            this.isClicked = false;
          }, 200);
        })
        .onRequestPopupData((index: number) => {
          this.popDataSource = this.presenter.getAlphabetPopData(index).slice();
          return this.popDataSource;
        })
        .onPopupSelect((index: number) => {
          let scrollIndex = this.presenter.getListScrollIndex(this.selectedAlphabetIndex, this.popDataSource, index);
          this.scroller.scrollToIndex(scrollIndex);
        })
    }
  }
}