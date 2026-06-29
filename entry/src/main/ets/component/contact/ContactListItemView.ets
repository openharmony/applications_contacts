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

import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import ContactListPresenter from '../../presenter/contact/ContactListPresenter';
import { getPixelMapFromFile, PixelMapManager } from '../../util/UserPhoto';
import emitter from '@ohos.events.emitter';
import { VibrationEffect } from '../../model/type/EnumUtil';
import VibrationUtils from '../../util/VibrationUtils';
import LooseObject from '../../model/type/LooseObject';
import { CustomizedParams, SingleSelectContact } from '../../model/type';
import DotUtil from '../../util/DotUtil';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { LengthMetrics, SubHeader } from '@kit.ArkUI';
import { DynamicLoader } from '../../../../../../common/src/main/ets/util/DynamicLoader';
import ContactListShowInfo from '../../model/bean/ContactListShowInfo';
import { FontScaleState } from '../../util/fontScaleState';
import { ProfileUtils } from '../../util/ProfileUtils';
import { TextModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../data/ThemeColorConstant'
import { BusinessError } from '@kit.BasicServicesKit';
import { DisplaySplitUtil} from '../../util/DisplaySplitUtil';
import { i18n } from '@kit.LocalizationKit';
import { sim } from '@kit.TelephonyKit'
import { PhoneNumber } from '../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import EmitterConstant from '../../data/EmitterConstant';
import { DialogControllerManager } from '../../MainAbility/ControllerManager';
import CustomButtons from '../../pages/dialog/CustomButtons';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { PCSubTitle } from './SubHeader';
import LongPressGestureModifier from '../../util/LongPressGestureModifier';

const TAG = 'ContactListItemView ';
const DELETE_CONTACT_EVENT = 'DELETE_CONTACT_EVENT';
const DELETE_CONTACT_DIALOG_EVENT = 'DELETE_CONTACT_DIALOG_EVENT';
const VIEW_CONTACT_DETAILS_EVENT = 'VIEW_CONTACT_DETAILS_EVENT';
const PRESS_CONTACT_EVENT = 'PRESS_CONTACT_EVENT';
const SHARE_CONTACT_EVENT = 'SHARE_CONTACT_EVENT';
const MULTISELECT_CONTACT_EVENT = 'MULTISELECT_CONTACT_EVENT';

/**
 * The contact item component is used to display a single contact.
 */
@Component
@Reusable
export default struct ContactListItemView {
  public myAccountantsModel: SingleSelectContact | undefined;
  // showSubHeaderIndex
  @Link showSubHeaderIndex: Number;
  @Consume('pathInfos') pathInfos: NavPathStack;
  private presenter: ContactListPresenter = ContactListPresenter.getInstance();
  // changedId
  @StorageProp('contactsWithModifiedPhoto') @Watch('change') changedId: string = '';
  // 监听列表变更变更通知
  @StorageProp('contactListUpdated') @Watch('updatePixelMap') contactListUpdated: number = 0;
  @StorageLink('selectContactId') @Watch('updateIsSelected') selectContactId: string = '';
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageLink('deleteContactItemId') deleteContactItemId: string = '';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 显示信息对象
  @State showInfo: ContactListShowInfo =
    new ContactListShowInfo(false, true, '', '', '', '', '', '', '');
  // 字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageProp('isVerde') isVerde: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @State isPressed: boolean = false;
  // 是否由畅连拉起
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @StorageProp('isMeetimeNeedSplit') isMeetimeNeedSplit: boolean = false;

  // 联系人列表页本行联系人数据是否是详情页进入的联系人
  // 对于非手机，大屏，联系人列表页，进入详情的联系人有背景色
  // 原始方式使用表达式判断，看trace presenter变化后，会导致组件刷新
  @State isSelected: boolean = false;
  // 更新
  updateIsSelected() {
    this.isSelected = this.showInfo.contactId === this.selectContactId ? true : false;
  }

  multiselectContactParams: CustomizedParams = {
    ENC: 2
  };
  deleteContactParams: CustomizedParams = {
    ENC: 0
  };
  contactParams: CustomizedParams = {
    ENC: 1
  };
  deleteDialogContactParams: CustomizedParams = {
    ISPOP: 0,
    ISDELETE: 0
  };
  viewContactDetailParams: CustomizedParams = {
    LEVELONE: 0,
    LEVELTWO: -1,
    ISSAVE: 1,
    MARKTYPE: 0,
    MARKSOURCE: ''
  };
  customParams: CustomizedParams = {};
  @State private index: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 头像信息
  @State photoPixelMap: PixelMap | null = null;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  // 是否分享
  @State canBeShared: boolean = false;
  @State isMenuShown: boolean = false;
  @State canBeDeleted: boolean = false;
  @State canBeMultiselect: boolean = false;

  @StorageLink('isSaveContact') isSaveContact: number = 0;
  @State isConfirmChecked: boolean = false;

  // 动态设置长按手势
  @State longPressGestureModifier: LongPressGestureModifier = new LongPressGestureModifier();

  deleteDialogControler: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.delete_dialog_title'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          // 删除联系人对话框-取消删除情况下打点
          this.deleteDialogContactParams.ISPOP = 1;
          this.deleteDialogContactParams.ISDELETE = 0;
          DotUtil.getInstance().contactDot(this.deleteDialogContactParams, DELETE_CONTACT_DIALOG_EVENT);
          this.presenter.onDeleteDialogCancel();
          this.deleteDialogControler?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        action: () => {
          // 删除联系人对话框确认删除情况下打点
          this.deleteDialogContactParams.ISPOP = 1;
          this.deleteDialogContactParams.ISDELETE = 1;
          DotUtil.getInstance().contactDot(this.deleteDialogContactParams, DELETE_CONTACT_DIALOG_EVENT);
          this.presenter.onDeleteDialogConfirm(this.index, this.showInfo.contactId, false, () => {
            this.showSubHeaderIndex = 0;
          });
          this.deleteContactItemId = this.showInfo.contactId;
          if (this.showInfo.isShowIndex) {
            this.showSubHeaderIndex = this.index + 1;
            this.presenter.contactListDataSource.notifyDataReload();
          }
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    closeAnimation: { duration: 100 },
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isPC ? BlurStyle.COMPONENT_ULTRA_THICK :
      this.isThemeActive ? BlurStyle.NONE : undefined,
    shadow: this.isPC ? ShadowStyle.OUTER_DEFAULT_SM : undefined
  });

  private longPressGestureCallback(): void {
    VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
    ProfileUtils.buildShareContent(this.showInfo.contactId, (shareContent: string) => {
      this.presenter.shareContent = shareContent;
      this.canBeMultiselect = !StringUtil.isEmpty(this.showInfo.contactId);
      this.canBeShared = !StringUtil.isEmpty(this.presenter.shareContent);
      this.canBeDeleted = !StringUtil.isEmpty(this.showInfo.contactId);
      this.isMenuShown = true;
    })
  }

  /**
   * 显示时，获取头像
   */
  aboutToAppear() {
    HiLog.w(TAG, `aboutToAppear: contactId= ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0, 1)}:${this.showInfo.contactTitle.length},${this.index}`);
    // 选中状态标记位作为变量，需要刷新
    // 创建组件时，需要判断状态值，否则在showInfo设置前已经监听到了selectContactId变化，触发了刷新，showInfo更新后，无法刷新了
    // 复用组件时需要判断，否则可能设置不上值或复用之前的值
    this.updateIsSelected();
    // 联系人列表头像：使用 contact_id 去查contact_date表中的头像数据
    getPixelMapFromFile(this.showInfo.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
    // 动态绑定长按手势
    this.longPressGestureModifier.isShowGesture = !this.isFromMeetime;
    this.longPressGestureModifier.actionCallback = this.longPressGestureCallback.bind(this);
  }

  aboutToRecycle(): void {
    this.photoPixelMap = null;
    this.myAccountantsModel = undefined;
    this.showInfo = new ContactListShowInfo(false, true, '', '', '', '', '', '', '');
    this.index = -1;
  }

  /**
   * 复用
   * @param params
   */
  aboutToReuse(params: LooseObject) {
    HiLog.w(TAG, `aboutToReuseBefore: contactId= ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0, 1)}:${this.showInfo.contactTitle.length},${this.index}`);
    this.showInfo = params.showInfo;
    this.index = params.index;
    HiLog.w(TAG, `aboutToReuseAfter: contactId= ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0, 1)}:${this.showInfo.contactTitle.length},${this.index}`);
    // 选中状态标记位作为变量，需要刷新
    // 创建组件时，需要判断状态值，否则在showInfo设置前已经监听到了selectContactId变化，触发了刷新，showInfo更新后，无法刷新了
    // 复用组件时需要判断，否则可能设置不上值或复用之前的值
    this.updateIsSelected();
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

  onDeleteClick() {
    HiLog.w(TAG, 'onDeleteClick');
    this.deleteDialogControler?.open();
    DialogControllerManager.getInstance().addDialogController(this.deleteDialogControler);
  }

  aboutToDisappear() {
    this.deleteDialogControler = null;
    this.photoPixelMap?.release();
  }

  change() {
    const id = this.changedId.split('-')[0]
    HiLog.w(TAG,
      `change: id == ${id}  nameRawContactId == ${this.showInfo.nameRawContactId}, contactId = ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0,
        1)}:${this.showInfo.contactTitle.length},${this.index}`);
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
    HiLog.w(TAG, `updatePixelMap: contactId= ${this.showInfo.contactId}, contactTitle= ${this.showInfo.contactTitle.slice(0, 1)}:${this.showInfo.contactTitle.length},${this.index}`);   
    // 联系人列表头像：使用 contact_id 去查contact_date表中的头像数据
    let isCache = PixelMapManager.getInstance().contactListIdMiniPixelMap.has(this.showInfo.contactId);
    let cachePixelMap = PixelMapManager.getInstance().contactListIdMiniPixelMap.get(this.showInfo.contactId);
    if (isCache && cachePixelMap?.getImageInfo()) {
      this.photoPixelMap = cachePixelMap;
      HiLog.w(TAG, 'aboutToReuse: cacheImage contactId ' + this.showInfo.contactId)
    }
    // 联系人列表头像：使用 contact_id 去查contact_date表中的头像数据
    getPixelMapFromFile(this.showInfo.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  @Builder
  MenuPreview() {
    Scroll() {
      Row() {
        Row() {
          this.ContactAvatar();
        }
        .constraintSize({ minHeight: $r('app.float.id_card_image_mid') })
        .width($r('app.float.id_card_image_mid'))
        .layoutWeight(0)

        List() {
          ListItem() {
            Column() {
              Text(this.showInfo.contactTitle ? this.showInfo.contactTitle : $r('app.string.noName'))
                .textAlign(TextAlign.Start)
                .fontColor($r('app.color.skin_font_primary'))
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .width('100%')
                .constraintSize({ minHeight: '21vp' })
                .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
                .padding({
                  right: this.isVerde ? 56 :
                  i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level8') : 0
                })
              if (!StringUtil.isEmpty(this.showInfo.contactSubTitle)) {
                Text(this.showInfo.contactSubTitle)
                  .width('100%')
                  .fontColor($r('app.color.skin_font_tertiary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .padding({
                    right: this.isVerde ? 56 :
                      i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level8') : 0
                  })
              }
            }
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .layoutWeight(1)
        .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
        .width($r('app.float.listItem_width_xl'))
        .margin({
          left: $r('sys.float.padding_level8')
        })
      }
      .accessibilityLevel('no-hide-descendants')
      .padding({
        left: $r('app.float.id_card_margin_xl'),
        right: $r('app.float.id_card_margin_xl'),
        top: $r('app.float.id_card_margin_mid'),
        bottom: $r('app.float.id_card_margin_mid'),
      })
      .align(Alignment.Start)
      .borderRadius($r('sys.float.corner_radius_level10'))
      .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
      .width(DisplaySplitUtil.isHorizonSplit() ? 'auto' : '100%')
      .height($r('app.float.id_item_height_max'))
    }
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
  MenuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.multiple_choices') })
        .padding({
          left: $r('app.float.id_card_margin_xxl')
        })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('ContactListView_Contacts_multiple_choices_MenuItem')
        .onClick(() => {
          // 联系人打点--联系人列表长按联系人点击多选
          DotUtil.getInstance().contactDot(this.multiselectContactParams, MULTISELECT_CONTACT_EVENT);
          ContextMenu.close();
          DynamicLoader.getInstance().fire(DynamicLoader.BATCH_DELETE_CONTACTS).then(() => {
            HiLog.i(TAG, 'Touch and hold multiple options in the contact list. ');
            AppStorage.setOrCreate('longPressSelectContactId', this.showInfo.contactId);
            AppStorage.setOrCreate('toBatchDeleteContactsNavStack', this.pathInfos);
            // 淡入淡出，转场动画设置为false
            this.pathInfos.pushPathByName('BatchDeleteContacts', '', false);
          });
        })
        .enabled(this.canBeMultiselect)
      this.MenuDivider()
      MenuItem({ content: $r('app.string.delete') })
        .padding({
          left: $r('app.float.id_card_margin_xxl')
        })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('ContactListView_Contacts_delete_MenuItem')
        .onClick(() => {
          setTimeout(() => {
            // 删除联系人入口-长按某联系人删除打点
            DotUtil.getInstance().contactDot(this.deleteContactParams, DELETE_CONTACT_EVENT);
            ContextMenu.close();
            this.deleteDialogControler?.open();
            DialogControllerManager.getInstance().addDialogController(this.deleteDialogControler);
          }, 300)
        })
        .enabled(this.canBeDeleted)
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .backgroundBlurStyle(this.isPC ? BlurStyle.COMPONENT_REGULAR : undefined)
    .shadow({
      radius: this.isPC ? $r('sys.float.ohos_id_default_shadow_s') : 0
    })
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
        .onError((error) => {
          if (error.error?.code == 101000) {
            getPixelMapFromFile(this.showInfo.contactId, (res: PixelMap | null) => {
              this.photoPixelMap = res;
              HiLog.w(TAG, 'ContactAvatar photoPixelMap refresh')
            })
          }
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
    RelativeContainer() {
      if (((this.showInfo.isShowIndex as boolean && !StringUtil.isEmpty(this.showInfo.namePrefix)) ||
        (this.showSubHeaderIndex === this.index))) {
        if (this.isPC) {
          PCSubTitle({
            subtitle: this.showInfo.namePrefix,
            titleMargin: {
              start: LengthMetrics.resource($r('sys.float.padding_level4')),
              end: LengthMetrics.resource($r('sys.float.padding_level4'))
            }
          })
            .id('SubHeader')
        } else {
          Row() {
            Text(this.showInfo.namePrefix)
              .margin({
                start: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level4')) :
                LengthMetrics.resource($r('sys.float.padding_level8'))
              })
              .fontColor($r('app.color.skin_ohos_fa_text_secondary'))
              .lineHeight(19)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
          }
          .width(this.isPC ? 'calc(100% - 8vp)' : '100%')
          .padding({ top: this.isPC ? 0 : 22, bottom: this.isPC ? $r('sys.float.padding_level4') : 0 })
          .alignItems(this.isPC ? VerticalAlign.Bottom : VerticalAlign.Center)
          .constraintSize({
            minHeight: this.isPC ? $r('app.float.id_item_height_sm') : $r('app.float.id_item_height_large')
          })
          .height(this.isPC ? $r('app.float.id_item_height_sm') : undefined)
          .backgroundColor(this.isFromMeetime ? $r('app.color.skin_background_secondary') : $r('app.color.start_window_background'))
          .alignRules({
            start: { anchor: '__container__', align: HorizontalAlign.Start },
          })
          .id('SubHeader')
        }
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

          if (!StringUtil.isEmpty(this.showInfo.contactSubTitle)) {
            Text(this.getSubTitle())
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
              .margin({ top: $r('app.float.id_card_margin_sm') })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: $r('app.float.id_card_margin_mid'),
          bottom: $r('app.float.id_card_margin_mid'),
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
        .width(this.isPC ? 'calc(100% - 56vp)' : `calc(100% - 60vp)`)
      }
      .constraintSize({ minHeight: this.isPC ? $r('app.float.id_item_height_large') :
        $r('app.float.id_item_height_max') })
      .width('100%')
      .padding({
        start: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level4')) :
        LengthMetrics.resource(this.spaceLR),
        end: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level0')) :
        LengthMetrics.resource($r('app.float.id_card_margin_xxxxl'))
      })
      .borderRadius(this.isPC ? $r('sys.float.padding_level4') : 0)
      .backgroundColor(this.isPressed ? $r('app.color.skin_interactive_click') :
        (this.showInfo.contactId === this.selectContactId && this.curBp != 'sm') ?
          'rgba(10,88,246,0.1)' : 'rgba(0,0,0,0)')
      .stateStyles({
        clicked:{
          .backgroundColor($r('app.color.skin_interactive_click'))
        }
      })
      .onTouch((event: TouchEvent) => {
        switch (event.type) {
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
      .id('ContactListView_Contacts_Click_Column')
      .bindContextMenu(this.isMenuShown && !this.isFromMeetime, this.MenuBuilder, {
        preview: this.MenuPreview(),
        previewAnimationOptions: { scale: [1.0, 1.0], transition: TransitionEffect.OPACITY.animation({
          duration: 200, curve: Curve.Ease,
        }).combine(TransitionEffect.scale({
          x: 1.08, y: 1.08
        })).combine(TransitionEffect.translate({
          x: -12, y: 0
        })).combine(TransitionEffect.opacity(10)),
        },
        transition: TransitionEffect.OPACITY.animation({
          duration: 200, curve: Curve.Ease
        }).combine(TransitionEffect.scale({ x: 1.0, y: 1.0})),
        placement: Placement.BottomLeft,
        offset: {
          x: 0,
          y: $r('sys.float.padding_level4')
        },
        onAppear: () => {
          // 联系人打点-联系人列表长按某联系人
          DotUtil.getInstance().contactDot(this.customParams, PRESS_CONTACT_EVENT);
        },
        onDisappear: () => {
          this.isMenuShown = false;
        },
        backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
        backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined
      })
      .gestureModifier(this.longPressGestureModifier)
      .onMouse((event: MouseEvent) => {
        if (event.button == MouseButton.Right && event.action == MouseAction.Release) {
          VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
          ProfileUtils.buildShareContent(this.showInfo.contactId, (shareContent: string) => {
            this.presenter.shareContent = shareContent;
            this.canBeMultiselect = !StringUtil.isEmpty(this.showInfo.contactId);
            this.canBeShared = !StringUtil.isEmpty(this.presenter.shareContent);
            this.canBeDeleted = !StringUtil.isEmpty(this.showInfo.contactId);
            this.isMenuShown = true;
          });
        }
      })
      .alignRules({
        start: { anchor: 'SubHeader', align: HorizontalAlign.Start },
        top: { anchor: 'SubHeader', align: VerticalAlign.Bottom }
      })
      .parallelGesture(
        GestureGroup(GestureMode.Exclusive,
          LongPressGesture({ repeat: false, duration: 500 })
            .tag('sessionListLongPress')
            .onAction(() => {
              this.isMenuShown = true
              VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
              ProfileUtils.buildShareContent(this.showInfo.contactId, (shareContent: string) => {
                this.presenter.shareContent = shareContent;
                this.canBeMultiselect = !StringUtil.isEmpty(this.showInfo.contactId);
                this.canBeShared = !StringUtil.isEmpty(this.presenter.shareContent);
                this.canBeDeleted = !StringUtil.isEmpty(this.showInfo.contactId);
                this.isMenuShown = true;
              })
            }),
          // TapGesture处理点击手势，count参数为需要检测的点击次数，fingers参数为需要检测的手指数量
          TapGesture({ count: 1, fingers: 1 })
            .onAction(() => {
              HiLog.w(TAG, 'listItemView onClick');
              const params: Record<string, boolean | string | number> = {
                'sourceHasId': true,
                'contactId': this.showInfo.contactId,
                'nameRawContactId': this.showInfo.nameRawContactId,
                'itemIndex': this.index,
                'isMyCard': false
              };
              if (this.isSelected && this.curBp != 'sm') {
                return;
              }
              // 联系人打点-点击查看联系人详情
              DotUtil.getInstance().contactDot(this.viewContactDetailParams, VIEW_CONTACT_DETAILS_EVENT);
              if (this.pathInfos.size() > 0 &&
                this.pathInfos.getAllPathName()[this.pathInfos.size() - 1] === 'ContactDetail') {
                this.pathInfos.replacePathByName('ContactDetail', params, false);
              } else {
                DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
                  if (this.curBp === 'md' || this.curBp === 'lg') {
                    this.pathInfos?.clear();
                    this.pathInfos.pushPathByName('ContactDetail', params, false);
                  } else {
                    this.pathInfos.pushPathByName('ContactDetail', params);
                  }
                });
              }
            })
        ))
      .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })

      // 显示下划线
      if (this.showInfo.isShowDivifer as boolean) {
        Divider().height('1px')
          .color($r('app.color.skin_ohos_id_color_list_separator'))
          .margin({
            end: this.isPC ? LengthMetrics.vp(8) :
              this.curBp === 'lg' ? LengthMetrics.vp(24) : LengthMetrics.vp(32),
            start: this.isPC ? LengthMetrics.vp(48) :
              this.curBp === 'lg' ? LengthMetrics.vp(76) : LengthMetrics.vp(72)
          })
          .alignRules({
            bottom: { anchor: 'ContactListView_Contacts_Click_Column', align: VerticalAlign.Bottom }
          })
      }
    }
    .height('auto')
    .direction(Direction.Auto)
    .margin(this.isPC ? {
      start: LengthMetrics.resource($r('sys.float.padding_level8')),
      end: LengthMetrics.resource($r('sys.float.padding_level12'))
    } : undefined)
  }

  static buildPhoneNumberRecByNumber(number: string): Record<string, string> {
    let phoneNumber = PhoneNumber.fromString(number).phoneNumFormat();

    let phoneNumberRec: Record<string, string> = {
      'phoneNumber': phoneNumber
    };

    return phoneNumberRec;
  }

  @Builder
  deleteDialogCloudDialog() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.contact_will_be_deleted'))
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Regular)
              .width('100%')
              .fontColor($r('app.color.skin_font_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 3 : 10)
              .textAlign(TextAlign.Start);
          }
          .constraintSize({ minHeight: $r('app.float.id_setting_22') })

          Row() {
            Column() {
              Checkbox()
                .height($r('app.float.id_card_margin_max'))
                .width($r('app.float.id_card_margin_max'))
                .select(this.isConfirmChecked)
                .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') : undefined)
                .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
                .margin($r('sys.float.padding_level0'))
                .padding($r('sys.float.padding_level1'))
                .selectedColor($r('app.color.skin_comp_background_emphasize'))
                .onChange((value: boolean) => {
                  this.isConfirmChecked = value;
                })
            }
            .padding({
              end: LengthMetrics.resource($r('sys.float.padding_level6'))
            })

            Column() {
              Text($r('app.string.read_and_understand'))
                .width('100%')
                .constraintSize({ minHeight: $r('app.float.id_card_title_margin_top') })
                .fontColor($r('app.color.skin_font_primary'))
                .fontSize($r('sys.float.Subtitle_S'))
                .fontWeight(FontWeight.Regular)
            }
            .onClick(() => {
              this.isConfirmChecked = !this.isConfirmChecked;
            })
            .layoutWeight(1)
          }
          .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        }
        .width('100%')
      }
      .padding({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12')
      })
      .margin({
        bottom: 56 + 8
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)

      CustomButtons({
        confirmButtonEnabled: this.isConfirmChecked,
        isErrorConfirmButton: true,
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.dialog_delete'),
        onCancel: () => {
          // 删除联系人对话框取消删除情况下打点
          this.deleteDialogContactParams.ISPOP = 1;
          this.deleteDialogContactParams.ISDELETE = 0;
          DotUtil.getInstance().contactDot(this.deleteDialogContactParams, DELETE_CONTACT_DIALOG_EVENT);
          this.presenter.onDeleteDialogCancel();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.isConfirmChecked = false;
        },
        onConfirm: () => {
          // 删除联系人对话框确认删除情况下打点
          this.deleteDialogContactParams.ISPOP = 1;
          this.deleteDialogContactParams.ISDELETE = 1;
          DotUtil.getInstance().contactDot(this.deleteDialogContactParams, DELETE_CONTACT_DIALOG_EVENT);
          this.presenter.onDeleteDialogConfirm(this.index, this.showInfo.contactId, false, () => {
            this.showSubHeaderIndex = 0;
          });
          this.deleteContactItemId = this.showInfo.contactId;
          if (this.showInfo.isShowIndex) {
            this.showSubHeaderIndex = this.index + 1;
            this.presenter.contactListDataSource.notifyDataReload();
          }
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.isConfirmChecked = false;
        }
      })
        .flexShrink(0)
    }
    .width('100%')
  }
}