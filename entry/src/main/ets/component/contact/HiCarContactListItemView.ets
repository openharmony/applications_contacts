/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { StringUtil, HiLog } from '../../../../../../common';
import { simId_DEFAULT } from '../../feature/sim/SimCardState';
import HiCarUtil from '../../util/HiCarUtil';
import { Constants, Favorite } from '../../data/Constants';
import { HiCarContactSubHeader } from '../../pages/hicar/HiCarCommonComponent';
import { HiCarConstants } from '../../data/HiCarConstants';
import { FavoriteListBean } from '../../model/bean/FavoriteListBean';
import HiCarContactListShowInfo from '../../model/bean/HiCarContactListShowInfo';

const TAG = 'HiCarContactListItemView ';

/**
 * 联系人列表单个项目组件
 */
@Component
export struct HiCarContactListItemView {
  @Prop item: HiCarContactListShowInfo;
  private favorite: string = Favorite.FALSE;
  private isShowDivider: boolean = false;
  @StorageLink(Constants.KEY_HAVE_MULTI_SIM_CARD) haveMultiSimCard: boolean = false;
  @StorageLink(Constants.KEY_DEFAULT_SLOT) defaultSlot: number = simId_DEFAULT;

  build() {
    if (this.item.isFavorited === this.favorite) {
      Column() {
        if (this.item.isShowIndex as boolean && !StringUtil.isEmpty(this.item.namePrefix) && this.favorite ===
        Favorite.FALSE) {
          HiCarContactSubHeader({ subHeaderName: this.item.namePrefix })
        }

        Column() {
          Row() {
            Text(this.item.contactTitle)
              .fontColor($r('app.color.skin_font_primary'))
              .fontSize($r('app.float.id_text_size_body1_hicar'))
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

          }
          .layoutWeight(1)
          .height('100%')
          .onClick(() => {
            HiCarUtil.getInstance().contactDialingByContactId(this.getUIContext(), this.item.contactId,
              this.haveMultiSimCard, this.defaultSlot, HiCarConstants.CONTACT_DOT_ENC_CONTACTS);
          })

          if (this.isShowDivider) {
            Divider()
              .height(Constants.DIVIFER_HEIGHT)
              .color($r('app.color.skin_ohos_id_color_list_separator'))
          }
        }
        .width('100%')
        .height($r('app.float.id_contact_list_item_height_hicar'))
      }
      .padding({ right: HiCarUtil.getInstance().getTabContentPadding() })
    }
  }
}

/**
 * 联系人列表收藏单个项目组件
 */
@Component
export struct HiCarFavoriteItemView {
  @Prop item: FavoriteListBean;
  @StorageLink(Constants.KEY_HAVE_MULTI_SIM_CARD) haveMultiSimCard: boolean = false;
  @StorageLink(Constants.KEY_DEFAULT_SLOT) defaultSlot: number = simId_DEFAULT;

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.item.favorite.displayName)
            .fontColor($r('app.color.skin_font_primary'))
            .fontSize($r('app.float.id_text_size_body1_hicar'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

        }
        .layoutWeight(1)
        .height('100%')
        .onClick(() => {
          HiCarUtil.getInstance().contactDialingByContactId(this.getUIContext(), this.item.favorite.contactId,
            this.haveMultiSimCard, this.defaultSlot, HiCarConstants.CONTACT_DOT_ENC_CONTACTS);
        })

        if (this.item.showDivider) {
          Divider()
            .height(Constants.DIVIFER_HEIGHT)
            .color($r('app.color.skin_ohos_id_color_list_separator'))
        }
      }
      .width('100%')
      .height($r('app.float.id_contact_list_item_height_hicar'))
    }
    .padding({ right: HiCarUtil.getInstance().getTabContentPadding() })
  }
}
