/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import { getPixelMapFromFile, PixelMapManager } from '../../util/UserPhoto';
import { VibrationEffect } from '../../model/type/EnumUtil';
import VibrationUtils from '../../util/VibrationUtils';
import LooseObject from '../../model/type/LooseObject';
import { CustomizedParams, SingleSelectContact } from '../../model/type';
import { ColorMetrics, LengthMetrics, SubHeader } from '@kit.ArkUI';
import { DynamicLoader } from '../../../../../../common/src/main/ets/util/DynamicLoader';
import ContactListShowInfo from '../../model/bean/ContactListShowInfo';
import { FontScaleState } from '../../util/fontScaleState';
import { TextModifier } from '@ohos.arkui.modifier';
import { i18n } from '@kit.LocalizationKit';
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { Constants } from '../../data/Constants';
import DotUtil from '../../util/DotUtil';

const TAG = 'IntelligenceGroupContactListItem ';
const INTELLIGENCE_GROUP_CONTACT_CLICK_EVENT = 'INTELLIGENCE_GROUP_CONTACT_CLICK_EVENT';

/**
 * The itelligence group contact item component is used to display a single contact.
 */
@Component
@Reusable
export default struct IntelligenceGroupContactListItem {
  public myAccountantsModel: SingleSelectContact | undefined;
  // showSubHeaderIndex
  @Link showSubHeaderIndex: Number;
  @Consume('pathInfos') pathInfos: NavPathStack;
  // changedId
  @StorageProp('contactsWithModifiedPhoto') @Watch('change') changedId: string = '';
  // 监听列表变更变更通知
  @StorageProp('contactListUpdated') @Watch('updatePixelMap') contactListUpdated: number = 0;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 显示信息对象
  @State showInfo: ContactListShowInfo =
    new ContactListShowInfo(false, true, Constants.EMTPY_STR, Constants.EMTPY_STR, Constants.EMTPY_STR,
      Constants.EMTPY_STR, Constants.EMTPY_STR, Constants.EMTPY_STR, Constants.EMTPY_STR);
  // 字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageProp('isVerde') isVerde: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @State isPressed: boolean = false;
  // 是否由畅连拉起
  @StorageProp('isMeetimeNeedSplit') isMeetimeNeedSplit: boolean = false;
  // 联系人列表页本行联系人数据是否是详情页进入的联系人
  // 对于非手机，大屏，联系人列表页，进入详情的联系人有背景色
  // 原始方式使用表达式判断，看trace presenter变化后，会导致组件刷新
  @State isSelected: boolean = false;

  customParams: CustomizedParams = {};
  @State private index: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 头像信息
  @State photoPixelMap: PixelMap | null = null;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @State isContactListItemHover: boolean = false;
  intelligenceGroupContactCustomParams: CustomizedParams = {};

  /**
   * 显示时，获取头像
   */
  aboutToAppear() {
    HiLog.w(TAG,
      `aboutToAppear: contactId= ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0,
        1)}:${this.showInfo.contactTitle.length}`);
    // 选中状态标记位作为变量，需要刷新
    // 创建组件时，需要判断状态值，否则在showInfo设置前已经监听到了selectContactId变化，触发了刷新，showInfo更新后，无法刷新了
    // 复用组件时需要判断，否则可能设置不上值或复用之前的值
    // 联系人列表头像：使用 contact_id 去查contact_date表中的头像数据
    getPixelMapFromFile(this.showInfo.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  aboutToRecycle(): void {
    this.photoPixelMap = null;
    this.myAccountantsModel = undefined;
    this.showInfo = new ContactListShowInfo(false, true, Constants.EMTPY_STR, Constants.EMTPY_STR, Constants.EMTPY_STR,
      Constants.EMTPY_STR, Constants.EMTPY_STR, Constants.EMTPY_STR, Constants.EMTPY_STR);
  }

  /**
   * 复用
   * @param params
   */
  aboutToReuse(params: LooseObject) {
    HiLog.w(TAG,
      `aboutToReuseBefore: contactId= ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0,
        1)}:${this.showInfo.contactTitle.length}`);
    this.showInfo = params.showInfo;
    this.index = params.index;
    HiLog.w(TAG,
      `aboutToReuseAfter: contactId= ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0,
        1)}:${this.showInfo.contactTitle.length}`);
    // 选中状态标记位作为变量，需要刷新
    // 创建组件时，需要判断状态值，否则在showInfo设置前已经监听到了selectContactId变化，触发了刷新，showInfo更新后，无法刷新了
    let isCache = PixelMapManager.getInstance().contactListIdMiniPixelMap.has(this.showInfo.contactId);
    let cachePixelMap = PixelMapManager.getInstance().contactListIdMiniPixelMap.get(this.showInfo.contactId);
    if (this.photoPixelMap) {
      this.photoPixelMap.release(() => {
        if (isCache && cachePixelMap?.getImageInfo()) {
          this.photoPixelMap = cachePixelMap;
          HiLog.w(TAG, 'aboutToReuse: cacheImage contactId ' + this.showInfo.contactId)
        }
      })
    } else {
      if (isCache && cachePixelMap?.getImageInfo()) {
        this.photoPixelMap = cachePixelMap;
        HiLog.w(TAG, 'aboutToReuse: cacheImage contactId ' + this.showInfo.contactId)
      }
    }
    getPixelMapFromFile(this.showInfo.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  aboutToDisappear() {
    this.photoPixelMap?.release();
  }

  change() {
    const id = this.changedId.split('-')[0];
    HiLog.w(TAG,
      `change: id == ${id}  nameRawContactId == ${this.showInfo.nameRawContactId}, contactId = ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0,
        1)}:${this.showInfo.contactTitle.length}`);
    if (this.showInfo.contactId === id) {
      // 联系人列表头像：使用 contact_id 去查contact_date表中的头像数据
      getPixelMapFromFile(this.showInfo.contactId, (res: PixelMap | null) => {
        this.photoPixelMap = res;
      })
    }
  }

  /**
   * 更新头像信息
   */
  updatePixelMap() {
    HiLog.w(TAG,
      `updatePixelMap: contactId= ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0,
        1)}:${this.showInfo.contactTitle.length}`);
    // 联系人列表头像：使用 contact_id 去查contact_date表中的头像数据
    let isCache = PixelMapManager.getInstance().contactListIdMiniPixelMap.has(this.showInfo.contactId);
    let cachePixelMap = PixelMapManager.getInstance().contactListIdMiniPixelMap.get(this.showInfo.contactId);
    if (isCache && cachePixelMap?.getImageInfo()) {
      this.photoPixelMap = cachePixelMap;
      HiLog.w(TAG, 'aboutToReuse: cacheImage contactId ' + this.showInfo.contactId);
    }
    // 联系人列表头像：使用 contact_id 去查contact_date表中的头像数据
    getPixelMapFromFile(this.showInfo.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r('app.float.id_card_margin_xxl'), right: $r('app.float.id_card_margin_xxl') })
  }

  @Builder
  ContactAvatar() {
    if (this.photoPixelMap) {
      Image(this.photoPixelMap)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .objectFit(ImageFit.Auto)
        .borderRadius($r('app.float.id_card_image_mid'))
        .draggable(false)
        .onError(() => {
          HiLog.e(TAG, 'photoPixelMap onError!!')
        })
    } else if (StringUtil.isEmpty(this.showInfo.headChar)) {
      if (StringUtil.isEmpty(this.showInfo.portraitPath)) {
        Image($r('app.media.ic_user_portrait'))
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Auto)
          .borderRadius($r('app.float.id_card_image_mid'))
          .draggable(false)
          .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
          .onError(() => {
            HiLog.e(TAG, 'ic_user_portrait_morandi onError!!')
          })
      } else {
        Image(this.showInfo.portraitPath)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Auto)
          .borderRadius($r('app.float.id_card_image_mid'))
          .draggable(false)
          .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .onError(() => {
            HiLog.e(TAG, 'portraitPath onError!!')
          })
      }
    } else {
      Text(this.showInfo.headChar)
        .fontSize('16vp')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
        .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
        .constraintSize({ minHeight: $r('app.float.id_card_image_mid') })
        .width($r('app.float.id_card_image_mid'))
        .textAlign(TextAlign.Center)
        .borderRadius($r('app.float.id_card_image_mid'))
        .accessibilityLevel('no')
    }
  }

  getSubTitle(): string | Resource {
    return this.showInfo.contactSubTitle;
  }

  getTitle(): string | Resource {
    return this.showInfo.contactTitle;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (((this.showInfo.isShowIndex as boolean && !StringUtil.isEmpty(this.showInfo.namePrefix)) ||
          (this.showSubHeaderIndex === this.index))) {
          SubHeader({
            secondaryTitle: this.showInfo.namePrefix,
            secondaryTitleModifier: this.isThemeActive ?
            new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined,
            contentPadding: {
              start: this.isPC ? LengthMetrics.vp(-40) : LengthMetrics.vp(-16),
              end: LengthMetrics.vp(-16)
            }
          })
            .margin({
              start: (this.isPC || (this.curBp === 'lg')) ? LengthMetrics.vp(24) : LengthMetrics.vp(16),
              end: this.isPC ? LengthMetrics.vp(0) : LengthMetrics.vp(32)
            })
        }

        Row() {
          Row() {
            this.ContactAvatar();
          }
          .height($r('app.float.id_card_image_mid'))
          .width($r('app.float.id_card_image_mid'))

          Column() {
            Text(this.getTitle() ? this.getTitle() : $r('app.string.noName'))
              .width('100%')
              .fontColor($r('app.color.skin_font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
              .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
              .direction(Direction.Ltr)
              .constraintSize({ minHeight: '21vp' })

            if (!StringUtil.isEmpty(this.showInfo.contactSubTitle)) {
              Text(this.getSubTitle())
                .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
                .margin({ top: $r('app.float.id_card_margin_sm') })
                .constraintSize({ minHeight: '19vp' })
            }
          }
          .alignItems(HorizontalAlign.Start)
          .padding({
            top: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_card_margin_large_hicar') :
              undefined,
            bottom: FontScaleState.isSmallerFourGeer(this.fontSizeScale) ? $r('app.float.id_card_margin_large_hicar') :
              undefined,
          })
          .margin({
            start: this.isPC ? LengthMetrics.resource($r('app.float.id_card_margin_large')) :
            LengthMetrics.resource($r('app.float.id_card_margin_xxl')),
            end: FontScaleState.isStandardGeer(this.fontSizeScale) ? LengthMetrics.vp(0) :
            LengthMetrics.resource($r('app.float.id_width_16')),
            top: FontScaleState.fetchSeniorListSpace() === 0 ? LengthMetrics.vp(0) :
            LengthMetrics.resource(FontScaleState.fetchSeniorListSpace() as Resource),
            bottom: FontScaleState.fetchSeniorListSpace() === 0 ? LengthMetrics.vp(0) :
            LengthMetrics.resource(FontScaleState.fetchSeniorListSpace() as Resource)
          })
          .width('calc(100% - 56vp)')
        }
        .constraintSize({
          minHeight: this.isPC ? $r('app.float.id_item_height_large') :
          $r('app.float.id_item_height_max')
        })
        .width('100%')
        .padding({
          start: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level12')) :
          LengthMetrics.resource(this.spaceLR),
          end: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level0')) :
          LengthMetrics.resource($r('app.float.id_card_margin_xxxxl'))
        })
        .onTouch((event: TouchEvent) => {
          switch (event.type) {
            case TouchType.Down:
              this.isPressed = true;
              break;
            case TouchType.Up:
            case TouchType.Cancel:
              this.isPressed = false;
              break;
          }
        })
        .stateStyles({
          clicked: {
            .backgroundColor($r('sys.color.interactive_click'))
          },
          normal: {
            .backgroundColor(this.isContactListItemHover ? $r('sys.color.interactive_hover') : 'rgba(0,0,0,0)')
          },
           pressed: {
             .backgroundColor($r('sys.color.interactive_pressed'))
           },
        })
        .onHover((isHover: boolean) => {
          this.isContactListItemHover = isHover;
        })
        .id('ContactListView_Contacts_Click_Column')
        .onMouse((event: MouseEvent) => {
          if (event.button == MouseButton.Right && event.action == MouseAction.Release) {
            VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
          }
        })
        .alignRules({
          start: { anchor: 'SubHeader', align: HorizontalAlign.Start },
          top: { anchor: 'SubHeader', align: VerticalAlign.Bottom }
        })
        .onClick(() => {
          HiLog.i(TAG, 'listItemView onClick');
          const params: Record<string, boolean | string | number> = {
            'sourceHasId': true,
            'contactId': this.showInfo.contactId,
            'nameRawContactId': this.showInfo.nameRawContactId,
            'itemIndex': this.index,
            'pageTag': Constants.FROM_PAGE_INTELLIGENCE_GROUPD
          };
          if (this.isSelected && this.curBp != 'sm') {
            return;
          }
          if (this.pathInfos.size() > 0 &&
            this.pathInfos.getAllPathName()[this.pathInfos.size() - 1] === 'ContactDetail') {
            this.pathInfos.replacePathByName('ContactDetail', params, false);
          } else {
            DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
              if (this.curBp === 'md') {
                this.pathInfos.replacePathByName('ContactDetail', params, false);
              } else {
                this.pathInfos.pushPathByName('ContactDetail', params);
              }
            });
          }
        })
        .focusBox({
          margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_TWO),
          strokeColor: ColorMetrics.resourceColor($r('sys.color.interactive_focus'))
        })
      }
      .height('auto')
      .padding({
        bottom: '1px'
      })

      // 显示下划线
      if (this.showInfo.isShowDivifer as boolean) {
        Divider().height('1px')
          .color($r('app.color.skin_ohos_id_color_list_separator'))
          .margin({
            end: LengthMetrics.vp(32),
            start: this.isPC ? LengthMetrics.vp(72) :
              (this.curBp === 'lg' ? LengthMetrics.vp(80) : LengthMetrics.vp(72))
          })
          .alignRules({
            bottom: { anchor: 'ContactListView_Contacts_Click_Column', align: VerticalAlign.Bottom }
          })
      }
    }

  }

  static buildPhoneNumberRecByNumber(number: string): Record<string, string> {
    let phoneNumber = PhoneNumber.fromString(number).phoneNumFormat();

    let phoneNumberRec: Record<string, string> = {
      'phoneNumber': phoneNumber
    };

    return phoneNumberRec;
  }
}