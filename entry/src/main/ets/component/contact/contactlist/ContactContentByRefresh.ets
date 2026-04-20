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
import { ContactListBoModel } from '../../../model/ContactListBoModel';
import { VibrationEffect } from '../../../model/type/EnumUtil';
import { AlphabetIndexerPage } from '../../../pages/contacts/alphabetindex/AlphabetIndexerPage';
import { HiLog } from '../../../../../../../common';
import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
import VibrationUtils from '../../../util/VibrationUtils';
import { ContactContent } from './ContactContent';
import displaySync from '@ohos.graphics.displaySync';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import { GlobalContext } from '../../../util/GlobalContext';

const TAG = 'ContactContentByRefresh  ';
/**
 * 云同步开关开启，联系人列表，刷新
 */
@Component
export struct ContactContentByRefresh {
  @StorageLink('isContactSearch') isContactSearch: boolean = false;
  @Link presenter: ContactListPresenter;
  @Link private contactListListLen: number;
  @Link private navigationMenusOpacity: number;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @StorageProp('fontScale') fontScale: number = 1;
  @StorageProp('isVerde') isVerde: boolean = false;
  scroller: Scroller = GlobalContext.getContext().getObject('scrollerContactList') as Scroller;
  @Link alphabetSelected: number;
  @Link isAlphabetClicked: boolean;
  @Link stages: number;
  myDisplaySync:displaySync.DisplaySync = displaySync.create();
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  @Link searchValueLength: number;
  @Link searchOffsetY: number;
  @Link isReBindScroll: boolean;
  updateStage() {
    if (this.stages == 0) {
      this.myDisplaySync.start();
      this.myDisplaySync.on('frame', (frameInfo: displaySync.IntervalInfo)=> {
        this.updateStage();
      });
    }
    HiLog.w(TAG, 'this.stages: ' + this.stages);
    this.stages = this.stages + 1;
    if (this.stages == 2) {
      HiLog.w(TAG, 'this.stages: ' + this.stages + ' stop');
      this.myDisplaySync.off('frame');
      this.myDisplaySync.stop()
    }
  }

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear...')
    this.updateStage();
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Refresh({
        refreshing: false,
        builder: this.RefreshBlank()
      }) {
        ContactContent({
          contactListListLen: $contactListListLen,
          navigationMenusOpacity: $navigationMenusOpacity,
          scroller: this.scroller,
          alphabetSelected: this.alphabetSelected,
          isAlphabetClicked: this.isAlphabetClicked,
          searchValueLength: this.searchValueLength,
          stages: this.stages,
          presenter: this.presenter,
          searchOffsetY: this.searchOffsetY,
          isReBindScroll: this.isReBindScroll,
        })
      }
      .id('ContactList_Contacts_Refresh_Refresh')
      .onStateChange((refreshStatus: RefreshStatus) => {
        if (refreshStatus === RefreshStatus.Drag) {
          this.hideIndexTitleTabBar = false;
        }
        if (refreshStatus === RefreshStatus.Drag || refreshStatus === RefreshStatus.OverDrag) {
          ContactListBoModel.getInstance().setToSearchPage(false);
        } else {
          ContactListBoModel.getInstance().setToSearchPage(true);
        }
      }).clip(false)
      .pullToRefresh(false)
    }
  }

  @Builder
  RefreshBlank() {
    Blank()
    .width('100%')
  }
}