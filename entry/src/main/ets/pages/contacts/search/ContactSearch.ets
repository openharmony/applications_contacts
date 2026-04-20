/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
import { StringUtil, DynamicLoader } from '../../../../../../../common/';
import emitter from '@ohos.events.emitter';
import LooseObject from '../../../model/type/LooseObject';
import curves from '@ohos.curves';
import { getHeadChar, getPixelMapFromFile, PixelMapManager } from '../../../util/UserPhoto';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import MorandiColor from '../../../model/bean/MorandiColor';
import NameDisposal from '../../../feature/NameDisposal'
import { CachedContactsPixelMapType, ContactIdParam, CustomizedParams, SpeedDialItem } from '../../../model/type';
import DotUtil from '../../../util/DotUtil';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import { FontScaleState } from '../../../util/fontScaleState';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { AppStorageConstant } from '../../../../../../../common/src/main/ets/AppStorageConstant';
import { inputMethod } from '@kit.IMEKit';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import VibrationUtils from '../../../util/VibrationUtils';
import { VibrationEffect } from '../../../model/type/EnumUtil';
import dotCommon, { contactParams, deleteDialogContactParams, customParams } from '../../../util/DotCommon';
import { ProfileUtils } from '../../../util/ProfileUtils';
import { sharedPreferencesUtils } from '../../../../../../../common';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import SmsManagerUtils from '../../../util/SmsManagerUtils';
import { TextModifier } from '@ohos.arkui.modifier';
import EnvironmentProp, { DeviceUtil } from '../../../feature/EnvironmentProp';
import deviceInfo from '@ohos.deviceInfo';
import { DisplaySplitUtil } from '../../../util/DisplaySplitUtil';
import { LengthMetrics } from '@kit.ArkUI';
import { ArrayUtil } from '../../../../../../../common/src/main/ets/util/ArrayUtil';
import { PhoneNum } from '../../../../../../../feature/call/src/main/ets/entity/CallLogTemp';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import { PCDeviceConstant } from '../../../data/PCDeviceConstant';
import { ContactIdsParam } from '../../../presenter/contact/settings/ArrangeContactsPresenter';
import common from '@ohos.app.ability.common';
import { PCSubTitle } from '../../../component/contact/SubHeader';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import CustomButtons from '../../dialog/CustomButtons';
import LongPressGestureModifier from '../../../util/LongPressGestureModifier';
// import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { i18n } from '@kit.LocalizationKit';
import { ResourceUtil } from '../../../util/ResourceUtil';

const TAG = 'ContactSearch ';
const NUMBER_ZERO: number = 0;
const NUMBER_ONE: number = 1;
const NUMBER_TWO: number = 2;
const TITLE_HEIGHT: number = 56;
const hasNumber: RegExp = new RegExp('[0-9]');
const hasComma: RegExp = new RegExp(',', 'g');
const COMMA_REPLACE: string = '&comma;';
const labelMatch: RegExp = new RegExp('<|>', 'gi');
const CLICK_SEARCH_RESULT_EVENT: string = 'CLICK_SEARCH_RESULT_EVENT';
const SEARCH_LIST_ITEM_PADDING: number = 32;
// 长按时点击事件延时时间（ms），保证组件消失动效执行结束
const DIALOG_CONTROLLER_TIME_OUT: number = 300;
const CLEAR_PIXE_MAP_CACHE_INTERVAL_TIME: number = 5 * 60 * 1000;

@Component
export struct ContactSearch {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Link presenter: ContactListPresenter;
  @Link offSetY: number;
  emitterId: number = 102;
  @State placeholder: string = '';
  @State cancelIsTouch: boolean = false;
  @State longPressIndex: number = -1;
  @State isConfirmChecked: boolean = false;

  @State scaleNum: number = 1.0; // 长按菜单放大缩小动效系数
  @State itemWidth: number = 0; // 长按菜单宽度
  // 动态设置长按手势
  @State longPressGestureModifier: LongPressGestureModifier = new LongPressGestureModifier();
  curIndex: number = -1;
  @StorageLink('isContactSearch') isContactSearch: boolean = false;
  @StorageLink('contactSearchNumber') @Watch('contactSearchNumberChange') contactSearchNumber: number = 0;
  @StorageLink('isSearchBackgroundColor') isSearchBackgroundColor: boolean = true;
  @StorageLink('contactsList_y') contactsList_y: number = 0;
  customizedParams: CustomizedParams = {};
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State searchEntityid: string = '';
  menuEntityId: string = '';
  // Floating window status
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  // Avoidance distance
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 无障碍字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  private isPC: boolean = EnvironmentProp.isPC();
  firstItemIndex: number = -1;
  lastItemIndex: number = -1;
  firstCacheSearchPhotoEnd: boolean = false;
  private timerId: number = -1;
  @StorageProp('isVerde') isVerde: boolean = false;
  // 畅连适配
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @StorageProp('isMeetimeNeedSplit') isMeetimeNeedSplit: boolean = false;
  @StorageProp('isMeetimePC') isMeetimePC: boolean = false;
  @StorageProp('meetimeCurBp') meetimeCurBp: string = 'sm';
  private scroller: Scroller = new Scroller();

  deleteDialogControler: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.delete_dialog_title'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        action: () => {
          // 删除联系人对话框取消删除情况下打点
          deleteDialogContactParams.ISPOP = 1;
          deleteDialogContactParams.ISDELETE = 0;
          DotUtil.getInstance().contactDot(deleteDialogContactParams, dotCommon.eventName.DELETE_CONTACT_DIALOG_EVENT);
          this.presenter.onDeleteDialogCancel();
          this.deleteDialogControler?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      },
      secondaryButton: {
        value: $r('app.string.dialog_delete'),
        action: () => {
          // 删除联系人对话框确认删除情况下打点
          deleteDialogContactParams.ISPOP = 1;
          deleteDialogContactParams.ISDELETE = 1;
          DotUtil.getInstance().contactDot(deleteDialogContactParams, dotCommon.eventName.DELETE_CONTACT_DIALOG_EVENT);
          this.onDeleteDialogConfirm(this.menuEntityId);
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    closeAnimation: { duration: 100 }
  });

  // search delete confirm
  async onDeleteDialogConfirm(contactId: string) {
    HiLog.w(TAG, 'onDeleteDialogConfirm !!! ');
    // 在删除联系人时，快速拨号如果关联了删除的联系人，需要一起删除
    let speedString: string = await sharedPreferencesUtils.getFromPreferences('speedDialObjString', '') as string;
    const contactIdParam: ContactIdParam = {
      context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(),
      contactId: contactId,
      operationScenario: 'Delete associated speed dials when removing a contact.',
    }
    if (!StringUtil.isEmpty(speedString)) {
      let speedDialArr: Record<string, SpeedDialItem | null> = JSON.parse(speedString);
      Object.entries(speedDialArr).forEach(item => {
        if (item[1] != null) {
          if (contactIdParam.contactId == item[1].contactId) {
            speedDialArr[item[0]] = null;
          }
        }
      })
      sharedPreferencesUtils.saveToPreferences('speedDialObjString', JSON.stringify(speedDialArr));
    }
    // 删除联系人
    ContactsGlobalThisHelper.GetGlobalThis()
      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('deleteContactById', contactIdParam, (result: number | undefined) => {
        SmsManagerUtils.notifyMmsWhenDeleteContact([contactIdParam.contactId].map(Number), result === 0 ? 0 : -1);
        if (result) {
          HiLog.w(TAG, 'deleteContactById error:' + result);
        }

        const myCardId: string | undefined = AppStorage.get(AppStorageConstant.MYCARD_CONTACT_ID);
        if (contactId == myCardId) {
          this.deleteMyCardTotally(contactId);
        }
      });
  }

  deleteMyCardTotally(contactId: string) {
    HiLog.i(TAG, `deleteMyCardTotally id:${contactId}`);
    let contactIdParam: ContactIdParam = {
      context: getContext(this) as common.UIAbilityContext,
      contactId: contactId
    }
    ContactsGlobalThisHelper.GetGlobalThis().getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
      .sendRequest('findRawIdById', contactIdParam, (result: number) => {
        let contactRawIdParam: ContactIdsParam = {
          context: getContext(this) as common.UIAbilityContext,
          ids: [result.toString()]
        }
        HiLog.i(TAG, `findRawIdById rawId :${result}`);
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName)
          .sendRequest('deleteRecycleContactByIds', contactRawIdParam, (result: number) => {
            HiLog.i(TAG, `deleteMyCardTotally result:${result}`);
          })
      })
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
    .opacity(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.isFromMeetime ? $r('app.color.skin_background_secondary') :
      (this.isThemeActive ? Color.Transparent : $r('app.color.skin_background_primary')))
  }

  private longPressGestureCallback(): void {
    VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
    this.longPressIndex = this.curIndex;
  }

  aboutToAppear() {
    let innerEvent: emitter.InnerEvent = {
      eventId: this.emitterId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEvent, (data) => {
      this.contactSearchNumber = data?.data?.['contactSearchCount'];
    })
    // 动态绑定长按手势
    this.curIndex = -1;
    this.longPressGestureModifier.isShowGesture = !this.isFromMeetime;
    this.longPressGestureModifier.actionCallback = this.longPressGestureCallback.bind(this);
    clearInterval(this.timerId);
    this.timerId = setInterval(() => {
      // 定时清除联系人搜索头像缓存，防止内存持续占用
      PixelMapManager.getInstance().releaseContactListAllPixelMap(false, true);
    }, CLEAR_PIXE_MAP_CACHE_INTERVAL_TIME);
  }

  aboutToDisappear() {
    emitter.off(this.emitterId);
    AppStorage.setOrCreate('firstCacheSearchPhotoEnd', false);
    AppStorage.setOrCreate('contactSearchChangeId', '-1');
    PixelMapManager.getInstance().releaseContactListAllPixelMap(false, true);
    clearInterval(this.timerId);
    this.timerId = -1;
  }

  contactSearchNumberChange() {
    const deviceType: string = deviceInfo.deviceType;
    if (this.curBp === 'sm' || this.isShowSmartWindow || deviceType === 'tablet' &&
      DisplaySplitUtil.isVerticalSplit()) {
      HiLog.w(TAG, 'toSearchDetail Screen size: ' + this.curBp + ' Is Small window:' + this.isShowSmartWindow);
      return;
    }
    if (DeviceUtil.isFoldable() && this.curBp === 'md') {
      HiLog.w(TAG, `contactSearchNumberChange: the current device is foldable screen`);
      return;
    }
    this.toSearchDetail();
  }

  toSearchDetail() {
    HiLog.w(TAG, 'toSearchDetail contactSearchNumber :' + this.contactSearchNumber);
    if (this.presenter.searchContactsSource.getData(0) === null) {
      return;
    }

    let inputMethodController = inputMethod.getController();
    let searchEntityid = this.presenter.searchContactsSource.getData(0)!.contact.entityId;
    HiLog.w(TAG, 'toSearchDetail searchEntityid:' + searchEntityid);
    if (this.searchEntityid === searchEntityid) {
      return;
    }

    this.searchEntityid = searchEntityid;
    const params: Record<string, boolean | string> = {
      'sourceHasId': true,
      'contactId': this.searchEntityid,
    };
    if (this.curBp !== 'sm') {
      AppStorage.setOrCreate<number>(AppStorageConstant.NEW_CONTACT_ID,
        Number(this.searchEntityid));
      ContactListPresenter.getInstance().refreshContactListDataSourceAndPhotoByIds(
        [this.searchEntityid]);
    }
    // 平板状态下搜索默认会跳转第一个搜索结果的详情页
    DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
      this.pathInfos.replacePathByName('ContactDetail', params);
    });

    setTimeout(() => {
      inputMethodController.showTextInput();
      focusControl.requestFocus('contactList_contacts_valueChange_search');
    }, 10)
  }

  onBackPress() {
    if (this.isVerde) {
      HiLog.w(TAG, 'v isContactSearch value change: contactSearch/onBackpress');
      this.isContactSearch = false;
      this.contactsList_y = 0;
    } else {
      animateTo({
        curve: curves.interpolatingSpring(0, 1, 342, 38)
      }, () => {
        HiLog.w(TAG, 'isContactSearch value change: contactSearch/onBackpress');
        this.isContactSearch = false;
        this.contactsList_y = 0;
      });
    }
  }

  private getBackgroundColor(): Resource | Color {
    let backgroundColor: Resource | Color = $r('app.color.skin_background_primary');
    if (this.isFromMeetime) {
      backgroundColor = $r('app.color.skin_background_secondary');
    } else if (StringUtil.isEmpty(this.presenter.inputKeyword)) {
      backgroundColor = Color.Transparent;
    }
    return backgroundColor;
  }

  // MenuPreview
  @Builder
  MenuPreview(item: LooseObject) {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Row() {
        SearchPhotoView({ item: item, presenter: this.presenter })

        Column() {
          Column() {
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Text(!StringUtil.isEmpty(item.contact.name) ? item.contact.name.replace(new RegExp('<\/?.+?>', 'g'), '') :
              $r('app.string.noName'))
                .fontColor($r('app.color.skin_ohos_fa_text_primary'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
            }
            .width('100%')
            .flexShrink(1)

            Flex({
              direction: FlexDirection.Row,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center,
              wrap: FlexWrap.Wrap
            }) {
              if (!StringUtil.isEmpty(item.contact.organization)) {
                Text(item.contact.organization.replace(new RegExp('<\/?.+?>', 'g'), ''))
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
              }
            }
            .width('100%')
            .flexShrink(1)
            .margin({ top: $r('app.float.id_card_margin_sm') })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .flexShrink(1)
        .alignItems(HorizontalAlign.Start)
        .margin({
          start: this.isPC ? LengthMetrics.vp(0) : LengthMetrics.resource($r('app.float.id_card_margin_xxl'))
        })
      }
      .borderRadius($r('sys.float.corner_radius_level10'))
      .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
      .alignItems(VerticalAlign.Center)
      .width(this.itemWidth)
      .constraintSize({
        minHeight: this.isPC ? $r('app.float.id_item_height_large') : $r('app.float.id_item_height_max')
      })
      .padding({
        left: this.isPC ? 8 : this.isMeetimePC ? $r('sys.float.padding_level12') : this.spaceLR,
        right: this.isPC ? 8 : this.isMeetimePC ? $r('sys.float.padding_level12') : this.spaceLR
      })
    }
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({ left: $r('app.float.id_card_margin_xl'), right: $r('app.float.id_card_margin_xl') })
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
                .select(false)
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
          deleteDialogContactParams.ISPOP = 1;
          deleteDialogContactParams.ISDELETE = 0;
          DotUtil.getInstance().contactDot(deleteDialogContactParams, dotCommon.eventName.DELETE_CONTACT_DIALOG_EVENT);
          this.presenter.onDeleteDialogCancel();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.isConfirmChecked = false;
        },
        onConfirm: () => {
          // 删除联系人对话框确认删除情况下打点
          deleteDialogContactParams.ISPOP = 1;
          deleteDialogContactParams.ISDELETE = 1;
          DotUtil.getInstance().contactDot(deleteDialogContactParams, dotCommon.eventName.DELETE_CONTACT_DIALOG_EVENT);
          this.onDeleteDialogConfirm(this.menuEntityId);
          DialogControllerManager.getInstance().dialogControllerSet.clear();
          this.isConfirmChecked = false;
        }
      })
        .flexShrink(0)
    }
    .width('100%')
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.delete') })
        .padding({
          start: LengthMetrics.resource($r('app.float.id_card_margin_xl'))
        })
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('ContactSearch_Contacts_delete_MenuItem')
        .onClick(() => {
          setTimeout(() => {
            // 删除联系人入口-长按搜索结果删除打点
            contactParams.ENC = 2;
            DotUtil.getInstance().contactDot(contactParams, dotCommon.eventName.DELETE_CONTACT_EVENT);
            ContextMenu.close();
            this.deleteDialogControler?.open();
            DialogControllerManager.getInstance().addDialogController(this.deleteDialogControler);
          }, DIALOG_CONTROLLER_TIME_OUT)
          this.longPressIndex = -1;
        })
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
  }

  build() {
   Navigation() {
    Stack() {
      if (this.contactSearchNumber > NUMBER_ZERO &&
      this.isSearchBackgroundColor) {
        Column() {
          List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
            ListItem() {
                if (this.contactSearchNumber > 0) {
                  if (this.isPC) {
                    PCSubTitle({
                      subtitle: ResourceUtil.getPluralStringByResource($r('app.plural.found_contacts'),
                        this.contactSearchNumber)
                    })
                      .margin({ start: LengthMetrics.vp(-14) })
                  } else {
                    SubHeader({
                      secondaryTitle: ResourceUtil.getPluralStringByResource($r('app.plural.found_contacts'),
                        this.contactSearchNumber),
                      secondaryTitleModifier: this.isThemeActive ?
                      new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined
                    })
                      .margin({
                        start: this.curBp === 'lg' || this.meetimeCurBp !== 'sm' ? LengthMetrics.vp(-4) :
                        LengthMetrics.resource($r('app.float.Dialog_bottom'))
                      })
                  }
                }
              }
            // 联系人搜索
            LazyForEach(this.presenter.searchContactsSource, (item: LooseObject, index: number) => {
              ListItem() {
                Stack({ alignContent: Alignment.BottomEnd }) {
                  Row() {
                    SearchPhotoView({ item: item, presenter: this.presenter })
                    Column() {
                      ContactSearchInfo({
                        name: item.contact.name.replace(hasComma, COMMA_REPLACE).split(labelMatch),
                        organization: item.contact.organization.replace(hasComma, COMMA_REPLACE).split(labelMatch),
                        phoneNumbers: item.contact.phoneNumbers,
                        inputKeyword: this.presenter.inputKeyword,
                        positions: item.contact.position.replace(hasComma, COMMA_REPLACE).split(labelMatch),
                        emails: this.presenter.processData(item.contact.emails),
                        imInfo: this.presenter.processData(item.contact.imInfo),
                        familyAddress: this.presenter.processData(item.contact.familyAddress),
                        note: item.contact.note.replace(hasComma, COMMA_REPLACE).split(labelMatch),
                        nickname: item.contact.nickname.replace(hasComma, COMMA_REPLACE).split(labelMatch),
                        nameHasHighlightLabel: item.contact.name.includes('em'),
                        organizationRemoveHighlightLabel:
                        item.contact.organization.replace(new RegExp('<\/?.+?>', 'g'), ''),
                        positionRemoveHighlightLabel:
                        item.contact.position.replace(new RegExp('<\/?.+?>', 'g'), ''),
                        nameIsEmpty: StringUtil.isEmpty(item.contact.name)
                      })
                    }
                    .flexShrink(1)
                    .alignItems(HorizontalAlign.Start)
                    .margin({
                      start: this.isPC ? LengthMetrics.vp(0) :
                      LengthMetrics.resource($r('app.float.id_card_margin_xxl'))
                      })
                  }
                  .alignItems(VerticalAlign.Center)
                  .width('100%')
                  .constraintSize({
                    minHeight: this.isPC ? $r('app.float.id_item_height_large') :
                    $r('app.float.id_item_height_max')
                  })
                }
              }
              .padding({
                left: this.isPC ? 8 : this.spaceLR,
                right: this.isPC ? 8 : this.spaceLR
              })
              .stateStyles({
                pressed: this.pressedStyles,
                normal: this.normalStyles
              })
              .id('ContactSearch_.Contacts_SearchResultClick_ListItem')
              .onAreaChange((oldValue: Area, newValue: Area) => {
                this.scaleNum = (Number(newValue.width) - SEARCH_LIST_ITEM_PADDING) / (Number(newValue.width));
                this.itemWidth = Number(newValue.width);
              })
              .bindContextMenu(!this.isFromMeetime && this.longPressIndex === index, this.MenuBuilder, {
                preview: this.MenuPreview(item),
                previewAnimationOptions: { scale: [1.0, this.scaleNum] },
                layoutRegionMargin: { left: 0, right: 0, bottom: 0 },
                placement: Placement.BottomLeft,
                offset: {
                  x: 0,
                  y: $r('sys.float.padding_level4')
                },
                onAppear: () => {
                  this.menuEntityId = item.contact.entityId;
                  // 联系人打点-联系人列表长按某联系人
                  DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.PRESS_CONTACT_EVENT);
                },
                onDisappear: () => {
                  this.longPressIndex = -1;
                },
                backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
                backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined
              })
              .gestureModifier(this.longPressGestureModifier)
              .onTouch(() => {
                if (this.curIndex !== index) {
                  this.curIndex = index;
                }
              })
              .onMouse((event: MouseEvent) => {
                if (event.button == MouseButton.Right && event.action == MouseAction.Release) {
                  VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
                  this.longPressIndex = index;
                  this.curIndex = index;
                }
              })
              .onClick(() => {
                // 联系人打点--点击联系人列表搜索结果
                DotUtil.getInstance().contactDot(this.customizedParams, CLICK_SEARCH_RESULT_EVENT);
                AppStorage.setOrCreate('contactSearchChangeId', item.contact.entityId);
                const params: Record<string, boolean | string> = {
                  'sourceHasId': true,
                  'contactId': item.contact.entityId,
                };
                if (this.pathInfos.size() > 0 &&
                  this.pathInfos.getAllPathName()[this.pathInfos.size() - 1] === 'ContactDetail') {
                  this.pathInfos.replacePathByName('ContactDetail', params);
                } else {
                  DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
                    if (this.curBp === 'md') {
                      this.pathInfos.replacePathByName('ContactDetail', params);
                    } else {
                      this.pathInfos.pushPathByName('ContactDetail', params);
                    }
                  });
                }
                if (this.curBp !== 'sm') {
                  AppStorage.setOrCreate<number>(AppStorageConstant.NEW_CONTACT_ID,
                    Number(item.contact.entityId));
                  ContactListPresenter.getInstance().refreshContactListDataSourceAndPhotoByIds(
                    item.contact.entityId);
                }
              })
              .borderRadius(this.isPC ? $r('sys.float.padding_level4') : 0)
              .focusBox({ margin: LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) })
            }, (item: LooseObject) => JSON.stringify(item))

          }
          .onScrollIndex((firstIndex: number, lastIndex: number) => {
            let difference = this.presenter.searchContactsSource.contactList.length - (lastIndex + 1);
            // 缓存范围为页面可见区域及前后各2个元素
            this.firstItemIndex = Math.max(0, firstIndex - 2);
            this.lastItemIndex = Math.min(this.presenter.searchContactsSource.contactList.length,
              lastIndex + (difference >= 2 ? 2 : difference === 1 ? 1 : 0));
            AppStorage.setOrCreate('firstItemIndex', this.firstItemIndex);
            AppStorage.setOrCreate('lastItemIndex', this.lastItemIndex);

            // 页面首次进入后缓存首页展示数据
            if (!this.firstCacheSearchPhotoEnd) {
              let contactSearchList =
                this.presenter.searchContactsSource.contactList.slice(this.firstItemIndex, this.lastItemIndex + 1);
              contactSearchList.forEach(item => {
                PixelMapManager.getInstance()
                  .cachedContactListIdMiniPixelMap(item, CachedContactsPixelMapType.CONTACT_SEARCH_LIST);
              })
              this.firstCacheSearchPhotoEnd = true;
              AppStorage.setOrCreate('firstCacheSearchPhotoEnd', true);
            }
          })
          // 滚动开始触发
          .onScrollStart(() => {
            PixelMapManager.getInstance().releaseContactListAllPixelMap(false, true);
          })
          // 滚动结束触发
          .onScrollStop(() => {
            HiLog.w(TAG, 'onScrollStop...');
            let contactSearchList =
              this.presenter.searchContactsSource.contactList.slice(this.firstItemIndex, this.lastItemIndex + 1);
            contactSearchList.forEach(item => {
              PixelMapManager.getInstance()
                .cachedContactListIdMiniPixelMap(item, CachedContactsPixelMapType.CONTACT_SEARCH_LIST);
            })
          })
          .divider({
            strokeWidth: '1px',
            color: $r('app.color.skin_comp_divider'),
            startMargin: $r('app.float.account_listItem_text_common_width'),
            endMargin: this.spaceLR
          })
          .onTouch(() => {
            // 焦点转移 收起键盘
            focusControl.requestFocus('ContactSearch_.Contacts_SearchResultClick_ListItem');
          })
          .padding({
            start: this.isPC ? LengthMetrics.vp(16) : undefined,
            end: this.isPC ? LengthMetrics.vp(16) : undefined,
            bottom: LengthMetrics.vp(px2vp(this.fullScreenPadding.bottom as number * 2))
          })
          .scrollBar(BarState.Off)
          // .height('100%')
          .width('100%')
          .listDirection(Axis.Vertical)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .flexShrink(1)
          .layoutWeight(1)
        }
        .offset(this.isVerde ? { top: -20 } : null)
        // .height('100%')
        .width('100%')
        .layoutWeight(1)

      }

      if (!this.isSearchBackgroundColor && this.contactSearchNumber == 0) {
        ContactSearchEmptyPage({ offSetY: $offSetY })
          .onTouch(() => {
            // 焦点转移 收起键盘
            let inputMethodController = inputMethod.getController();
            inputMethodController.hideTextInput();
          })
      }
    }
    .height(StringUtil.isEmpty(this.presenter.inputKeyword) ? 0 : '100%')
    .width('100%')
    .backgroundColor(this.getBackgroundColor())
    .id('ContactSearch_.Contacts_SearchResultTouch_Stack')
  }
  // .bindToScrollable([this.scroller])
  .backgroundColor(this.getBackgroundColor())
  .hideBackButton(true)
   .hideTitleBar(true)
  // .titleBar({
  //   style: this.isPC ? {
  //     scrollEffectOpts: {
  //       enableScrollEffect: false
  //     }
  //  } : undefined,
  //   enableComponentSafeArea: true,
  //   avoidLayoutSafeArea: true })
  .titleMode(NavigationTitleMode.Mini)
  }
}

@Component
export struct ContactSearchEmptyPage {
  // window avoidance
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @Link offSetY: number
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;

  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;

  private getBackgroundColor(): Resource | Color {
    let backgroundColor: Resource | Color = $r('app.color.skin_background_primary');
    if (this.isFromMeetime) {
      backgroundColor = $r('app.color.skin_background_secondary');
    } else if (this.isThemeActive) {
      backgroundColor = Color.Transparent;
    }
    return backgroundColor;
  }

  build() {
    Column() {
      // PafEmptyPage({
      //   icon: $r('app.media.no_result'),
      //   emptyDescription: $r('app.string.contact_search_result_empty'),
      //   descriptionFontColor: this.isThemeActive ? $r('app.color.skin_font_tertiary') : undefined,
      //   fullPage: true,
      //   customBackgroundColor: this.getBackgroundColor(),
      // })

      Image($r('app.media.no_contacts_illustration'))
        .objectFit(ImageFit.Contain)
        .width($r('app.float.id_card_image_large'))
        .height($r('app.float.id_card_image_large'))
        .margin({ bottom: $r('app.float.id_card_margin_large') })

      Text($r('app.string.contact_search_result_empty'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: $r('app.float.dialer_calllog_item_height') })
    }
    .padding(this.isVerde ? 0 : { bottom: this.offSetY > TITLE_HEIGHT ? this.offSetY : $r('app.float.id_height_84') })
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }
}

@Component
export struct SearchPhotoView {
  @Link presenter: ContactListPresenter;
  @Prop item: LooseObject = {};
  @State photoPixelMap: PixelMap | null = null;
  @StorageProp('contactsWithModifiedPhoto') @Watch('change') changedId: string = '';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  aboutToAppear() {
    let isCache = PixelMapManager.getInstance().contactSearchListMiniPixelMap.has(this.item.contact.entityId);
    let cachePixelMap = PixelMapManager.getInstance().contactSearchListMiniPixelMap.get(this.item.contact.entityId);
    if (this.photoPixelMap) {
      this.photoPixelMap.release(() => {
        if (isCache && cachePixelMap?.getImageInfo()) {
          this.photoPixelMap = cachePixelMap;
        }
      })
    } else {
      // 获取缓存头像
      if (isCache && cachePixelMap?.getImageInfo()) {
        this.photoPixelMap = cachePixelMap;
      } else {
        getPixelMapFromFile(this.item.contact.entityId, (res: PixelMap | null) => {
          this.photoPixelMap = res;
        })
      }
    }
  }

  change() {
    const id: string = this.changedId.split('-')[0]
    if (this.item.contact.entityId === id) {
      getPixelMapFromFile(id, (res: PixelMap | null) => {
        this.photoPixelMap = res;
      })
    }
  }

  // SearchResultPhoto
  build() {
    Row() {
      if (this.photoPixelMap) {
        Image(this.photoPixelMap)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Auto)
          .borderRadius($r('app.float.id_card_image_mid'))
          .draggable(false)
          .syncLoad(true)
          .onError(() => {
            this.photoPixelMap = null
          })
      } else if (StringUtil.isEmpty(getHeadChar(this.item?.contact?.name))) {
        Image($r('app.media.ic_user_portrait'))
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Auto)
          .borderRadius($r('app.float.id_card_image_mid'))
          .draggable(false)
          .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
      } else {
        Text(getHeadChar(this.item?.contact?.name.replace(new RegExp('<\/?.+?>', 'g'), '')))
          .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ? $r('sys.float.Body_L') : '16vp')
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary_contrary') : Color.White)
          .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
          .height($r('app.float.id_card_image_mid'))
          .width($r('app.float.id_card_image_mid'))
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.float.id_card_image_mid'))
          .accessibilityLevel('no')
      }
    }
    .height($r('app.float.id_card_image_mid'))
    .width($r('app.float.id_card_image_mid'))
  }
}

@Component
export struct ContactSearchInfo {
  @State name: string[] = [];
  @State organization: string[] = [];
  @State phoneNumbers: object[] = [];
  @State inputKeyword: string = '';
  @State positions: string[] = [];
  @State emails: string[] = [];
  @State imInfo: string[] = [];
  @State familyAddress: string[] = [];
  @State note: string[] = [];
  @State nickname: string[] = [];
  @State nameHasHighlightLabel: boolean = false;
  @State phoneNumber: string = '';
  @State organizationRemoveHighlightLabel: string = '';
  @State positionRemoveHighlightLabel: string = '';
  @State nameIsEmpty: boolean = false;

  aboutToAppear() {
    if (!ArrayUtil.isEmpty(this.phoneNumbers)) {
      for (let item of this.phoneNumbers as Array<PhoneNum>) {
        if (item.value.includes('<em>')) {
          this.phoneNumber = item.value;
          break;
        }
      }
    }
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        if (!this.nameIsEmpty) {
          Text() {
            ForEach(NameDisposal.charEscape(this.name), (items: string, index: number) => {
              if (!(items === 'em' || items === '/em')) {
                if (index != 0) {
                  if (this.name[index - 1] === 'em') {
                    Span(items)
                      .fontColor($r('app.color.skin_font_emphasize'))
                  } else {
                    Span(items)
                      .fontColor($r('app.color.skin_ohos_fa_text_primary'))
                  }
                } else {
                  Span(items)
                    .fontColor($r('app.color.skin_ohos_fa_text_primary'))
                }
              }
            })
          }
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        } else {
          Text($r('app.string.noName'))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
        }
      }
      .width('100%')
      .flexShrink(1)

      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Center,
        wrap: FlexWrap.Wrap
      }) {
        // 姓名不匹配，按优先级顺序高亮展示匹配字段（匹配字段优先级：电话>职位>单位>昵称>邮箱>地址>备注>IM>群组(×)）
        if (!this.nameHasHighlightLabel) {
          if (!StringUtil.isEmpty(this.phoneNumber) && hasNumber.test(this.inputKeyword)) {
            FormatNumberText({
              phoneNumber: this.phoneNumber,
              inputKeyword: this.inputKeyword,
              organizationRemoveHighlightLabel: this.organizationRemoveHighlightLabel
            })
          } else if (this.positions.length > 0 && this.positions.includes('em')) {
            Text() {
              ForEach(NameDisposal.charEscape(this.positions), (items: string, index: number) => {
                if (!(items === 'em' || items === '/em')) {
                  if (index != 0) {
                    if (this.positions[index - 1] === 'em') {
                      Span(items)
                        .fontColor($r('app.color.skin_font_emphasize'))
                    } else {
                      Span(items)
                        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                    }
                  } else {
                    Span(items)
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  }
                }
              })
              if (!StringUtil.isEmpty(this.organizationRemoveHighlightLabel)) {
                Span('.')
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                Span(this.organizationRemoveHighlightLabel)
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              }
            }
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else if (this.organization.length > 0 && this.organization.includes('em')) {
            Text() {
              if (!StringUtil.isEmpty(this.positionRemoveHighlightLabel)) {
                Span(this.positionRemoveHighlightLabel)
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                Span('.')
                  .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              }
              ForEach(NameDisposal.charEscape(this.organization), (items: string, index: number) => {
                if (!(items === 'em' || items === '/em')) {
                  if (index != 0) {
                    if (this.organization[index - 1] === 'em') {
                      Span(items)
                        .fontColor($r('app.color.skin_font_emphasize'))
                    } else {
                      Span(items)
                        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                    }
                  } else {
                    Span(items)
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  }
                }
              })
            }
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else if (this.nickname.length > 0 && this.nickname.includes('em')) {
            Text() {
              ForEach(NameDisposal.charEscape(this.nickname), (items: string, index: number) => {
                if (!(items === 'em' || items === '/em')) {
                  if (index != 0) {
                    if (this.nickname[index - 1] === 'em') {
                      Span(items)
                        .fontColor($r('app.color.skin_font_emphasize'))
                    } else {
                      Span(items)
                        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                    }
                  } else {
                    Span(items)
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  }
                }
              })
              Span('\xa0')
              Span(this.organizationRemoveHighlightLabel)
                .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            }
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else if (this.emails.length > 0) {
            Text() {
              ForEach(NameDisposal.charEscape(this.emails), (items: string, index: number) => {
                if (!(items === 'em' || items === '/em')) {
                  if (index != 0) {
                    if (this.emails[index - 1] === 'em') {
                      Span(items)
                        .fontColor($r('app.color.skin_font_emphasize'))
                    } else {
                      Span(items)
                        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                    }
                  } else {
                    Span(items)
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  }
                }
              })
              Span('\xa0')
              Span(this.organizationRemoveHighlightLabel)
                .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            }
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else if (this.familyAddress.length > 0) {
            Text() {
              ForEach(NameDisposal.charEscape(this.familyAddress), (items: string, index: number) => {
                if (!(items === 'em' || items === '/em')) {
                  if (index != 0) {
                    if (this.familyAddress[index - 1] === 'em') {
                      Span(items)
                        .fontColor($r('app.color.skin_font_emphasize'))
                    } else {
                      Span(items)
                        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                    }
                  } else {
                    Span(items)
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  }
                }
              })
              Span('\xa0')
              Span(this.organizationRemoveHighlightLabel)
                .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            }
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else if (this.note.length > 0 && this.note.includes('em')) {
            Text() {
              ForEach(NameDisposal.charEscape(this.note), (items: string, index: number) => {
                if (!(items === 'em' || items === '/em')) {
                  if (index != 0) {
                    if (this.note[index - 1] === 'em') {
                      Span(items)
                        .fontColor($r('app.color.skin_font_emphasize'))
                    } else {
                      Span(items)
                        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                    }
                  } else {
                    Span(items)
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  }
                }
              })
              Span('\xa0')
              Span(this.organizationRemoveHighlightLabel)
                .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            }
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else if (this.imInfo.length > 0) {
            Text() {
              ForEach(NameDisposal.charEscape(this.imInfo), (items: string, index: number) => {
                if (!(items === 'em' || items === '/em')) {
                  if (index != 0) {
                    if (this.imInfo[index - 1] === 'em') {
                      Span(items)
                        .fontColor($r('app.color.skin_font_emphasize'))
                    } else {
                      Span(items)
                        .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                    }
                  } else {
                    Span(items)
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                  }
                }
              })
              Span('\xa0')
              Span(this.organizationRemoveHighlightLabel)
                .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
            }
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else if (!StringUtil.isEmpty(this.organizationRemoveHighlightLabel)) {
            // 所有字段都不匹配（无高亮标签）且搜索存在返回结果，为模糊匹配，不高亮展示单位
            Text(this.organizationRemoveHighlightLabel)
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        } else if (!StringUtil.isEmpty(this.organizationRemoveHighlightLabel)) {
          // 姓名匹配，不高亮展示单位
          Text(this.organizationRemoveHighlightLabel)
            .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width('100%')
      .flexShrink(1)
      .margin({ top: $r('app.float.id_card_margin_sm') })
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct FormatNumberText {
  private phoneNumber: string = '';
  private inputKeyword: string = '';
  @State formatNumber: string = '';
  @State highlight: number[] = [-1, -1];
  @State organizationRemoveHighlightLabel: string = '';

  aboutToAppear() {
    if (!StringUtil.isEmpty(this.phoneNumber)) {
      this.phoneNumber = this.phoneNumber.replace(new RegExp('<\/?.+?>', 'g'), '');
      this.formatNumber = PhoneNumber.fromString(this.phoneNumber).dynamicPhoneFormat();
      this.highlight = PhoneNumber.formatDisplayPhoneNumber(this.formatNumber, this.inputKeyword);
    }
  }

  build() {
    Stack() {
      Text() {
        ForEach(Array.from(this.formatNumber), (item: string, index: number) => {
          if (index >= this.highlight[0] && index <= this.highlight[1]) {
            Span(item)
              .fontColor($r('app.color.skin_font_emphasize'))
          } else {
            Span(item)
              .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
          }
        })
        Span('\xa0')
        Span(this.organizationRemoveHighlightLabel)
          .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
      }
      .direction(Direction.Ltr)
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Regular)
      .margin({ bottom: $r('app.float.id_card_margin_sm') })
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(2)
    }
  }
}
