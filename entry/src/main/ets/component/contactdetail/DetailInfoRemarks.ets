/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { DataItemType } from '../../../../../../feature/contact/src/main/ets/contract/DataType';
import { SelectDialogBuilder } from '../../pages/dialog/SelectSimIdDialog';
import DetailPresenter from '../../presenter/contact/detail/DetailPresenter';
import { BaseContackSubInfoModel } from '../../model/type/ContactParams';
import { ArrayUtil } from '../../../../../../common/src/main/ets/util/ArrayUtil';
import LooseObject from '../../model/type/LooseObject';
import { ContactStrInterface, CustomizedParams } from '../../model/type';
import StringFormatUtil from '../../util/StringFormatUtil';
import { Birthday } from '../../../../../../feature/contact/src/main/ets/contract/Birthday';
import { StringUtil } from '../../../../../../common';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import dataShare from '@ohos.data.dataShare';
import ContactListItem from '../../../../../../feature/contact/src/main/ets/repo/ContactListItem';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ContactRepository } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository'
import { Contacts } from '../../../../../../feature/contact/src/main/ets/contract/Contacts';
import { sharedPreferencesUtils } from '../../../../../../common';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../data/EmitterConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { LengthMetrics } from '@kit.ArkUI';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import IndexPresenter from '../../presenter/IndexPresenter';
import DotUtil from '../../util/DotUtil';

const TAG = 'DetailInfoRemarks';
const DETAILS_PRESS_CHOOSE_EVENT = 'DETAILS_PRESS_CHOOSE_EVENT';

@Component
export default struct DetailInfoRemarks {
  @Link mPresenter: DetailPresenter;
  @Link selectSimBuilder: SelectDialogBuilder;
  @Link maximum: number;
  @Prop telephoneTotal: number;
  @Prop meettingTotal: number;
  @Prop otherTotal: number;
  @Link moreOptionsFlag: boolean;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  isEmptyDetailInfoRemarks(): boolean {
    return (
      !ArrayUtil.isEmpty<BaseContackSubInfoModel>(this.mPresenter.contactForm.emails) ||
        !ArrayUtil.isEmpty<BaseContackSubInfoModel>(this.mPresenter.contactForm.aims) ||
        !ArrayUtil.isEmpty<BaseContackSubInfoModel>(this.mPresenter.contactForm.houses) ||
        !ArrayUtil.isEmpty<BaseContackSubInfoModel>(this.mPresenter.contactForm.websites) ||
        !ArrayUtil.isEmpty<BaseContackSubInfoModel>(this.mPresenter.contactForm.relationships) ||
        !ArrayUtil.isEmpty<BaseContackSubInfoModel>(this.mPresenter.contactForm.events)
    )
  }

  // 处理展开更多与未展开更多情况下分割线的显示
  isDividerShow(totalCount: number, index: number): Visibility {
    if (this.moreOptionsFlag) {
      if (totalCount - 1 !== index) {
        return Visibility.Visible
      } else {
        return Visibility.None
      }
    } else {
      if (this.telephoneTotal + this.meettingTotal + index + 1 < this.maximum && totalCount - 1 === index) {
        return Visibility.None
      } else if (this.telephoneTotal + this.meettingTotal + index + 1 < this.maximum && totalCount - 1 !== index) {
        return Visibility.Visible
      } else {
        return Visibility.None
      }
    }
  }

  isItemShow(index: number): Visibility {
    let isVisibility: Visibility = Visibility.None;
    if (this.moreOptionsFlag) {
      isVisibility = Visibility.Visible
    } else {
      if (this.telephoneTotal + this.meettingTotal + index < this.maximum) {
        isVisibility = Visibility.Visible
      } else {
        isVisibility = Visibility.None
      }
    }
    return isVisibility
  }

  build() {
    Column() {
      List() {
        if (this.isEmptyDetailInfoRemarks()) {
          LazyForEach(this.mPresenter.detailInfoRemarksSources, (item: ContactStrInterface, index: number) => {
            if (JSON.parse(item.data).data) {
              ListItem() {
                Column() {
                  DetailInfoListItem({
                    listItem: JSON.parse(item.data),
                    mPresenter: $mPresenter,
                    hasArrow: false,
                  });
                  Divider()
                    .color($r('app.color.skin_ohos_id_color_list_separator'))
                    .strokeWidth('1px')
                    .width('100%')
                    .visibility(this.isDividerShow(this.mPresenter.detailInfoRemarksSources.totalCount(), index))
                    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4'), })
                }
              }
              .visibility(this.isItemShow(index))
            }
          }, (item: ContactStrInterface, index: number) => JSON.stringify(item) + JSON.stringify(index))
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
  }
}

@Reusable
@Component
struct DetailInfoListItem {
  @Link mPresenter: DetailPresenter;
  @Prop listItem: BaseContackSubInfoModel;
  @Prop hasArrow: boolean;
  @State inShowCalendar: boolean = false;
  @State mIndexPresenter: IndexPresenter = IndexPresenter.getInstance();
  private isPC: boolean = EnvironmentProp.isPC();
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @State isPressed: boolean = false;
  @State isMenuShown: boolean = false;
  @StorageProp('isInDetailLongPress') isInDetailLongPress: boolean = false;

  detailPressChooseParams: CustomizedParams = {
    ISSELECT: 0,
    ITEM: -1
  };

  aboutToReuse(params: LooseObject) {
    this.listItem = params.listItem;
  }

  dataString(): string {
    let tempStr: string = ''
    if (this.listItem.dataType == DataItemType.EVENT) {
      tempStr = StringFormatUtil.stringFormatDateResource(
        this.listItem.data ?? '',
        Number.parseInt(StringUtil.transferEmptyStrIfUndefined(this.listItem?.type)) == Birthday.TYPE_LUNARBIRTHDAY
      )
    } else {
      tempStr = this.listItem.data as string
    }
    return tempStr
  }

  @Builder
  sheetComponentBuilder() {
    Column() {
      Row() {
        UIExtensionComponent(
          {
            bundleName: 'com.ohos.contactsdataability',
            abilityName: 'PermissionExtAbility',
            parameters: {
              'ability.want.params.uiExtensionType': 'sys/commonUI'
            }
          }
        )
          .onReceive((data) => {
            this.inShowCalendar = false;
            sharedPreferencesUtils.saveToPreferences('showBirthdayBanners', false);
            emitter.emit(EmitterConstant.UPDATE_SHOW_BIRTHDAY_BANNERS_EMITTER_ID);
            if (Number(data['result']) === 1) {
              let conditionArgs = new dataSharePredicates.DataSharePredicates();
              ContactRepository.getInstance()
                .getDataAbilityHelper()
                .then((dataAbilityHelper: dataShare.DataShareHelper) => {
                  dataAbilityHelper.query(Contacts.CONTACT_SYNC_CALENDER_URI, conditionArgs, ContactListItem.COLUMNS)
                })
                .catch((error: Error) => {
                  HiLog.e(TAG, `Error querying contact sync calendar: ${error?.message}`);
                });
            }
          })
          .width(0)
          .height(0)
      }
      .width(0)
      .height(0)
    }
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.copy') })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .onClick(() => {
          this.detailPressChooseParams.ISSELECT = 1;
          this.detailPressChooseParams.ITEM = 0;
          this.mIndexPresenter.getCopy(this.dataString());
        })
    }
    .onDisAppear(() => {
      DotUtil.getInstance().contactDot(this.detailPressChooseParams, DETAILS_PRESS_CHOOSE_EVENT);
    })
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }


  build() {
    Column() {
      Text(this.dataString())
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
        .constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xxl') })

      Text(this.listItem.labelName)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight(FontWeight.Regular)
        .margin({ top: $r('app.float.id_card_margin_sm') })
        .constraintSize({ minHeight: $r('app.float.id_groupList_lineHeight_xl') })
    }
    .onTouch((event: TouchEvent) => {
      if (this.isMenuShown) {
        this.isPressed = false;
        return;
      }
      switch (event.type) {
        case TouchType.Down:
        case TouchType.Move:
          this.isPressed = true;
          break;
        case TouchType.Up:
        case TouchType.Cancel:
          this.isPressed = false;
          break;
      }
    })
    .onHover((isHover: boolean) => {
      if (isHover) {
        this.isPressed = true;
      } else {
        this.isPressed = false;
      }
    })
    .backgroundColor(this.isPressed
      ? $r('app.color.skin_interactive_click') : $r('app.color.skin_ohos_id_color_list_card_bg'))
    .borderRadius($r('sys.float.padding_level8'))
    .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO) })
    .bindSheet(this.inShowCalendar, this.sheetComponentBuilder(), {
      dragBar: false,
      showClose: false,
      width: 0,
      height: 0,
      borderColor: { top: '#00000000' },
      maskColor: Color.Transparent,
    })
    // 除了生日项，其它类型 不响应点击事件，否则无障碍语音播报会有问题
    .onClick(this.listItem.dataType == DataItemType.EVENT ? () => {
      HiLog.i(TAG, 'DetailInfoListItem onClick');
      if (this.listItem.dataType == DataItemType.EVENT) {
        this.inShowCalendar = true;
      }
    } : null)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4'),
      top: this.isPC ? $r('sys.float.padding_level3') : 10,
      bottom: this.isPC ? $r('sys.float.padding_level3') : 10
    })
    .constraintSize({
      minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
    })
    .gesture(GestureGroup(GestureMode.Exclusive,
      LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
        .onAction((event: GestureEvent) => {
          this.isPressed = false;
          this.isMenuShown = true;
        })
    ))
    .onMouse((event: MouseEvent) => {
      if (event.button === MouseButton.Right && event.action === MouseAction.Release) {
        this.isMenuShown = true
      }
    })
    .bindContextMenu(this.isMenuShown, this.MenuBuilder, {
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: { scale: [1.0, 1.0] },
      placement: Placement.BottomLeft,
      offset: { x: 0, y: $r('sys.float.padding_level4') },
      backgroundColor: this.isThemeActive ? ($r('app.color.skin_ohos_id_color_list_card_bg')) : undefined,
      backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
      onAppear: () => {
        this.isInDetailLongPress = true;
      },
      onDisappear: () => {
        this.isInDetailLongPress = false;
      },
      aboutToDisappear: () => {
        this.isMenuShown = false;
      }
    })
  }
}

