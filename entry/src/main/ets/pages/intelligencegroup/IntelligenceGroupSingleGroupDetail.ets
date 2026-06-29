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
import { HiLog } from '../../../../../../common';
import GroupListDetailPresenter from '../../presenter/group/GroupListDetailPresenter';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import { DynamicLoader } from '../../../../../../common/src/main/ets/util/DynamicLoader';
import GroupListPresenter from '../../presenter/group/GroupListPresenter';
import { CustomizedParams, GroupParams } from '../../model/type';
import { GroupMemberListBean } from '../../model/bean/GroupMemberListBean';
import { getPixelMapFromFile } from '../../util/UserPhoto';
import DotUtil from '../../util/DotUtil';
import call from '@ohos.telephony.call';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { LengthMetrics, SubHeader, ToolBar, ToolBarModifier, ToolBarOptions } from '@kit.ArkUI';
import { DividerModifier, SymbolGlyphModifier, TextModifier } from '@ohos.arkui.modifier';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import { VibrationEffect } from '../../model/type/EnumUtil';
import VibrationUtils from '../../util/VibrationUtils';
import { FontScaleState } from '../../util/fontScaleState';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { defaultCustomTheme } from '../../data/ThemeColorConstant';
import { i18n } from '@kit.LocalizationKit';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { deviceInfo } from '@kit.BasicServicesKit';
import { PCDeviceConstant } from '../../data/PCDeviceConstant';
import EnvironmentProp from '../../feature/EnvironmentProp';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import {
  IntelligenceGroupSingeGroupContactList
} from '../../component/intelligencegroup/IntelligenceGroupSingeGroupContactList';
import { ObjectUtil } from '../../../../../../feature/call/oh_modules/common';
import LooseObject from '../../model/type/LooseObject';
import { contact } from '@kit.ContactsKit'
import IntelligenceGroupSingleGroupDetailPresenter
  from '../../presenter/intelligencegroup/IntelligenceGroupSingleGroupDetailPresenter';
import { Constants } from '../../data/Constants';
import {
  AddSelectMemSendMsgUpdateToolbar
} from '../../presenter/intelligencegroup/IntelligenceGroupSelectMemSendMsgPresenter';
import { numFormat } from '../../util/NumFormat';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
import TextUtils from '../../../../../../common/src/main/ets/util/TextUtils';

const TAG = 'IntelligenceGroupSingleGroupDetail';
const INTELLIGENCE_GROUP_ADD_CLICK_EVENT = 'SMART_GROUP_ADD_EVENT';
const INTELLIGENCE_GROUP_SEND_MESSAGE_CLICK_EVENT = 'SMART_GROUP_SEND_MESSAGE_EVENT';

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function IntelligenceGroupSingleGroupDetailLoader($$: Params): void {
  IntelligenceGroupSingleGroupDetail();
}

/**
 * Group List Detail
 */
@Component
export default struct IntelligenceGroupSingleGroupDetail {
  @State singleGroupDetailPresenter: IntelligenceGroupSingleGroupDetailPresenter =
    new IntelligenceGroupSingleGroupDetailPresenter();
  @State mPresenter: GroupListPresenter = GroupListPresenter.getInstance();
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @State contactListListLen: number = 1;
  @State navigationMenusOpacity: number = 1;
  @State categoryGroupType: string = '0';
  @State intelliGroupName: string = Constants.EMTPY_STR;
  @State categoryIndex: string = Constants.EMTPY_STR;
  @State memberCount: number = 0;
  @State title: Resource | string = Constants.EMTPY_STR;
  @State isShowSheet: boolean = false;
  // 成员数量
  @StorageLink(Constants.INTELLIGENCE_GROUP_MEMBER_COUNT) groupMemberListLen: number = 0;
  @StorageLink(Constants.INTELLIGENCE_GROUP_USER_ID) accountUserId: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 路径信息
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('contactCount') @Watch('updateGroupListDetail') contactCount: number = -1;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @State isMore: boolean = false;
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @State groupToolbarList: ToolBarOptions = new ToolBarOptions();
  intelligenceGroupDetailCustomParams: CustomizedParams = {};
  // 判断是否数据查询完成,查询完再渲染
  @State isFinish: boolean = false;
  private scroller: Scroller = new Scroller();
  //底部按钮回调
  @State updateToolbarInterfaceForIntelligence: AddSelectMemSendMsgUpdateToolbar = {
    updateToolbar: (): void => {
      this.updateToolbar();
      this.isFinish = true;
    }
  };
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');

  private contactFilter: contact.ContactSelectionFilter = {
    filterClause: {
      dataItem: {
        field: contact.DataField.ORGANIZATION,
        options: [{
          filterCondition: contact.FilterCondition.IS_NOT_NULL,
        }]
      }
    },
    filterType: contact.FilterType.SHOW_FILTER
  };
  private isPC: boolean = EnvironmentProp.isPC();
  groupMoreParams: CustomizedParams = {
    ITEM: 0
  };

  updateGroupListDetail() {
    HiLog.w(TAG, `refresh contactCount: ${this.contactCount}`);
    this.groupMemberListLen = this.contactCount;
    this.singleGroupDetailPresenter.aboutToAppear();
  }

  destinationPageShow() {
    HiLog.w(TAG, 'destinationPageShow');
    this.singleGroupDetailPresenter.setPageShow();
  }

  /**
   * 底部toolbar显示
   */
  updateToolbar() {
    this.groupToolbarList = new ToolBarOptions();
    HiLog.w(TAG, `refresh groupMemberListLen : ${this.groupMemberListLen},${this.categoryGroupType}`);
    if (this.categoryGroupType === '0') {
      this.groupToolbarList.push({
        content: $r('app.string.add_member'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.plus')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        action: () => {
          // 联系人打点-进入单位分类后-添加其它单位的联系人到本单位
          DotUtil.getInstance()
            .contactDot(this.intelligenceGroupDetailCustomParams, INTELLIGENCE_GROUP_ADD_CLICK_EVENT);
          this.isShowSheet = true;
        }
      })
    }
    if (call.hasVoiceCapability() && this.groupMemberListLen) {
      this.groupToolbarList.push({
        content: $r('app.string.send_information'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.message')).fontColor([$r('app.color.skin_icon_primary')]),
        },
        action: () => {
          HiLog.w(TAG, `toSendMessage:${TextUtils.getMaskString(this.intelliGroupName)},${this.categoryGroupType},${this.categoryIndex}`);
          // 联系人打点-进入单位分类后-点击进入发送消息页面
          DotUtil.getInstance()
            .contactDot(this.intelligenceGroupDetailCustomParams, INTELLIGENCE_GROUP_SEND_MESSAGE_CLICK_EVENT);
          this.singleGroupDetailPresenter.toSendMessage(this.categoryGroupType, this.intelliGroupName,
            this.categoryIndex)
        }
      })
    }
  }

  aboutToAppear() {
    HiLog.w(TAG, `aboutToAppear`);

    let navParam: LooseObject = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as LooseObject;
    if (!ObjectUtil.isEmpty(navParam)) {
      this.intelliGroupName = navParam.intelliGroupName ?? Constants.EMTPY_STR;
      this.categoryGroupType = navParam.categoryGroupType;
      this.categoryIndex = navParam.categoryIndex;
      this.singleGroupDetailPresenter.categoryIndex = navParam.categoryIndex;
      this.singleGroupDetailPresenter.groupName = this.intelliGroupName;
      this.singleGroupDetailPresenter.categoryGroupType = this.categoryGroupType;
      this.singleGroupDetailPresenter.memberCount = navParam.memberCount;

      if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_COMPANY_CATEGORYTYPE && !this.intelliGroupName) {
        this.title = $r('app.string.intelligence_group_no_company');
      } else if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_CITY_CATEGORYTYPE && !this.intelliGroupName) {
        this.title = $r('app.string.intelligence_group_no_address');
      } else if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_CONTACT_TIME_CATEGORYTYPE) {
        if (this.intelliGroupName === Constants.INTELLIGENCE_GROUP_CONTACT_TIME_TYPE_ONE_WEEK) {
          this.title = $r('app.string.intelligence_group_contact_less_than_one_week');
        } else if (this.intelliGroupName === Constants.INTELLIGENCE_GROUP_CONTACT_TIME_TYPE_ONE_MONTH) {
          this.title = $r('app.string.intelligence_group_contact_less_than_one_month');
        } else if (this.intelliGroupName === Constants.INTELLIGENCE_GROUP_CONTACT_TIME_TYPE_THREE_MONTH) {
          this.title = $r('app.string.intelligence_group_contact_less_than_three_month', numFormat(3));
        } else if (this.intelliGroupName === Constants.INTELLIGENCE_GROUP_CONTACT_TIME_TYPE_MORE_THAN_THREE_MONTH) {
          this.title = $r('app.string.intelligence_group_no_contact_more_than_three_month', numFormat(3));
        }
      } else {
        this.title = this.intelliGroupName;
      }
    }
    HiLog.w(TAG, `one group appear:${this.intelliGroupName?.length},${this.categoryGroupType},${this.categoryIndex},${this.memberCount}`);
    this.initContactPickerParam();
    this.singleGroupDetailPresenter.updateToolbar = this.updateToolbarInterfaceForIntelligence;
    this.mPresenter.initNavPaths(this.pathInfos);
    this.singleGroupDetailPresenter.initNavPaths(this.pathInfos);
    this.singleGroupDetailPresenter.aboutToAppear();
  }

  initContactPickerParam() {
    if (this.categoryGroupType === Constants.INTELLIGENCE_GROUP_COMPANY_CATEGORYTYPE) {
      if (this.intelliGroupName) {
        this.contactFilter = {
          filterClause: {
            dataItem: {
              field: contact.DataField.ORGANIZATION,
              options: [{
                filterCondition: contact.FilterCondition.NOT_EQUAL_TO,
                value: this.intelliGroupName
              }]
            }
          },
          filterType: contact.FilterType.SHOW_FILTER
        };
      } else {
        this.contactFilter = {
          filterClause: {
            dataItem: {
              field: contact.DataField.ORGANIZATION,
              options: [{
                filterCondition: contact.FilterCondition.IS_NOT_NULL,
              }]
            }
          },
          filterType: contact.FilterType.SHOW_FILTER
        };
      }
    }
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear');
    this.singleGroupDetailPresenter.resetData()
    this.groupToolbarList = new ToolBarOptions();
    this.singleGroupDetailPresenter.updateToolbar = {
      updateToolbar: (): void => {
      }
    };
  }

  @Builder
  PCMenu() {
    if (this.singleGroupDetailPresenter.groupMemberListLen != 0) {
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.add_member')))
        .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(true)
        .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
        .margin({
          end: LengthMetrics.resource($r('sys.float.padding_level4'))
        })
        .onClick(() => {
          // 联系人打点-进入单位分类后-添加其它单位的联系人到本单位
          DotUtil.getInstance()
            .contactDot(this.intelligenceGroupDetailCustomParams, INTELLIGENCE_GROUP_ADD_CLICK_EVENT);
          this.isShowSheet = true;
        })

        Button() {
          SymbolGlyph($r('sys.symbol.message'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_icon_primary')])
        }
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.send_message')))
        .type(ButtonType.Normal)
        .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : 0)
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(true)
        .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
        .margin({
          end: LengthMetrics.resource($r('sys.float.padding_level4'))
        })
        .onClick(() => {
          // 联系人打点-进入单位分类后-点击进入发送消息页面
          DotUtil.getInstance()
            .contactDot(this.intelligenceGroupDetailCustomParams, INTELLIGENCE_GROUP_SEND_MESSAGE_CLICK_EVENT);
          this.singleGroupDetailPresenter.toSendMessage(this.categoryGroupType, this.intelliGroupName,
            this.categoryIndex);
        })
      }
      .height($r('app.float.id_item_height_large'))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.End)
      .padding({
        end: this.isPC ? LengthMetrics.vp(136) : LengthMetrics.resource(this.spaceLR),
      })
      .margin({
        left: this.isPC ? '8vp' : undefined
      })
    }
  }

  build() {
    if (this.isPC) {
      NavDestination() {
        Column() {
          Column() {
            if (this.singleGroupDetailPresenter.groupMemberListLen == 0 && this.isFinish) {
              ContactEmptyPage()
            } else if (this.singleGroupDetailPresenter.groupMemberListLen > 0 && this.isFinish) {
              IntelligenceGroupSingeGroupContactList({
                singleGroupDetailPresenter: $singleGroupDetailPresenter,
                contactListListLen: $contactListListLen,
                navigationMenusOpacity: $navigationMenusOpacity,
                categoryGroupType: this.categoryGroupType
              })
            }
          }
          .backgroundColor($r('sys.color.comp_background_gray'))
          .layoutWeight(1)
          .flexShrink(1)
        }
        .bindSheet(this.isShowSheet, this.contactsPicker(), {
          dragBar: false,
          showClose: false,
          height: this.isPC ? 560 : '100%',
          width: this.isPC ? 480 : undefined,
          preferType: SheetType.CENTER,
          onDisappear: () => {
            this.isShowSheet = false;
          },
          shouldDismiss: (sheetDismiss: SheetDismiss) => {
            this.isShowSheet = !this.isShowSheet;
          }
        })
        .flexShrink(1)
        .width('100%')
        .height('100%')
      }
      .title(this.title, {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart: this.isPC ? LengthMetrics.vp(16) : ((this.curBp === 'lg') ? LengthMetrics.vp(24) : undefined)
      })
      .id('GrouoListDetail_Navi_onBackPressed_NavDestination')
      .backButtonIcon(this.isThemeActive ?
      new SymbolGlyphModifier($r('sys.symbol.chevron_backward')).fontColor([$r('app.color.skin_icon_primary')])
        : new SymbolGlyphModifier($r('sys.symbol.chevron_backward')))
      .onBackPressed(() => {
        this.singleGroupDetailPresenter.back();
        return true;
      })
      .menus(this.isPC ? this.PCMenu() : undefined)
      .onShown(() => {
        this.destinationPageShow();
      })
      .backgroundColor($r('sys.color.comp_background_gray'))
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
    } else {
      NavDestination() {
        Column() {
          Column() {
            if (this.singleGroupDetailPresenter.groupMemberListLen == 0 && this.isFinish) {
              ContactEmptyPage()
            } else if (this.singleGroupDetailPresenter.groupMemberListLen > 0 && this.isFinish) {
              IntelligenceGroupSingeGroupContactList({
                singleGroupDetailPresenter: $singleGroupDetailPresenter,
                contactListListLen: $contactListListLen,
                navigationMenusOpacity: $navigationMenusOpacity,
                categoryGroupType: this.categoryGroupType,
                scroller: this.scroller
              })
            }
          }
          .backgroundColor($r('sys.color.comp_background_gray'))
          .layoutWeight(1)
          .flexShrink(1)

          GridRow({ columns: { sm: 4, md: 8, lg: 8 }, gutter: { x: 12, y: 0 } }) {
            GridCol({ span: { sm: 4, md: 8, lg: 6 }, offset: { sm: 0, md: 0, lg: 1 } }) {
              IntelligenceGroupBottomContent({
                categoryGroupType: this.categoryGroupType,
                intelliGroupName: this.intelliGroupName,
                categoryIndex: this.categoryIndex,
                isShowSheet: $isShowSheet,
                toolbarList: $groupToolbarList
              })
                .flexShrink(0)
            }
          }
          .margin({
            left: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_left'),
            right: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_right')
          })
        }
        .bindSheet(this.isShowSheet, this.contactsPicker(), {
          dragBar: false,
          showClose: false,
          height: this.isPC ? 560 : '100%',
          width: this.isPC ? 480 : undefined,
          preferType: SheetType.CENTER,
          onDisappear: () => {
            this.isShowSheet = false;
          },
          shouldDismiss: (sheetDismiss: SheetDismiss) => {
            this.isShowSheet = !this.isShowSheet;
          }
        })
        .flexShrink(1)
        .width('100%')
        .height('100%')
      }
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
      //   this.onBack();
      // }))
      .title(this.title)
      .backButtonIcon(this.isThemeActive ?
        new SymbolGlyphModifier($r('sys.symbol.chevron_backward')).fontColor([$r('app.color.skin_icon_primary')])
        : new SymbolGlyphModifier($r('sys.symbol.chevron_backward')))
      .onBackPressed(() => {
        this.singleGroupDetailPresenter.back();
        return true;
      })
      .id('GrouoListDetail_Navi_onBackPressed_Hds_NavDestination')
      .onShown(() => {
        this.destinationPageShow();
      })
      .backgroundColor($r('sys.color.comp_background_gray'))
      .padding({
        top: !this.isPC ? px2vp(this.fullScreenPadding.top as number) : 0,
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
      .bindToScrollable([this.scroller])
    }
  }

  private onBack() {
    this.singleGroupDetailPresenter.back();
  }

  /**
   * hdsNavigation标题配置获取
   *
   * @returns TitleBarParams
   */
  // private getTitleParam(): TitleBarParams {
  //   return {
  //     // 顶部状态栏避让
  //     avoidLayoutSafeArea: true,
  //     title: { title: this.title as string },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }

  @Builder
  contactsPicker() {
    Column() {
      UIExtensionComponent({
        bundleName: 'com.ohos.contacts',
        abilityName: 'ContactUiExtentionAbility',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'targetUrl': 'BatchSelectContactsPage',
          'isContactMultiSelect': true,
          'selectLimit': 10000,
          'isDisplayByName': false,
          'userId': this.accountUserId,
          'source': 'contactIntelligenceGroup',
          'intelliGroupName': this.intelliGroupName,
          'filter': this.contactFilter
        }
      })
        .accessibilityUseSamePage(AccessibilitySamePageMode.FULL_SILENT)
        .onRelease((code) => {
          HiLog.i(TAG, `onRelease: + ${code}`);
          this.isShowSheet = false;
        })
        .onReceive(async (data) => {
          this.isShowSheet = false;
          if (data && data.want) {
            const want = data.want as Want;
            if (want.parameters && want.parameters.selectContactIds) {
              let ids: number[] = want.parameters?.selectContactIds as number[];
              this.singleGroupDetailPresenter.updateContactsOrganizationInfo(ids, this.intelliGroupName);
              HiLog.i(TAG, `contactsPicker select contactids: ${ids?.length}`);
            }
          }
        })
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.Block)
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct SingleGroupDetailContent {
  @State longPressIndex: number = -1;
  @State isMenuShown: boolean = false;
  @State isPressed: boolean = false;
  @Link private presenter: GroupListDetailPresenter;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // 字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  nameTitle: string = ContactsGlobalThisHelper.GetGlobalThis()
    .getDefaultUIContext()
    .resourceManager
    .getStringSync($r('app.string.noName').id);
  viewContactDetailParams: CustomizedParams = {
    LEVELONE: 3,
    LEVELTWO: -1,
    ISSAVE: 1,
  };
  customParams: CustomizedParams = {};
  private isPC: boolean = EnvironmentProp.isPC();

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
    .opacity(1)
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
  MenuPreview(item: GroupMemberListBean) {
    Scroll() {
      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
        ContactPhotoView({
          item: item
        })

        Text(item.member.member.title !== '' ? item.member.member.title : this.nameTitle)
          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
          .margin({
            start: LengthMetrics.resource($r('app.float.id_card_margin_xxl'))
          })
          .flexShrink(1)
          .flexGrow(1)
          .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
      }
    }
    .padding({
      left: $r('app.float.id_card_margin_xl'),
      right: $r('app.float.id_card_margin_xl'),
      top: $r('app.float.id_card_margin_mid'),
      bottom: $r('app.float.id_card_margin_mid'),
    })
    .align(Alignment.Start)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('app.color.skin_ohos_id_color_list_card_bg'))
    .width(DisplaySplitUtil.isHorizonSplit(this.splitStatus) && deviceInfo.deviceType == 'tablet' ? '40%' : '100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
  }

  @Builder
  MenuBuilder(item: GroupMemberListBean) {
    Menu() {
      MenuItem({ content: $r('app.string.remove_from_group') })
        .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        .borderRadius($r('sys.float.corner_radius_level8'))
        .contentFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
        .contentFontColor($r('app.color.skin_ohos_id_color_text_primary'))
        .id('ContactListView_Contacts_delete_MenuItem')
        .onClick(() => {
          //从群组移除
          if (typeof item.member.member.contactId === 'string' && item.member.member.contactId !== '') {
            this.presenter.removeMemberByContactId(Number(item.member.member.contactId))
          } else {
            HiLog.e(TAG, 'contactId is null or contactId !== string ')
          }
          this.longPressIndex = -1;
        })
    }
    .width($r('app.float.account_MenuBuilder_width_xl'))
    .backgroundBlurStyle(this.isPC ? BlurStyle.COMPONENT_REGULAR : undefined)
    .shadow({
      radius: this.isPC ? $r('sys.float.ohos_id_default_shadow_s') : 0
    })
  }

  build() {
    GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
      GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
        List() {
          ListItemGroup() {
            LazyForEach(this.presenter.groupMemberDataSource,
              (item: GroupMemberListBean, index: number) => {
                ListItem() {
                  Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                    ContactPhotoView({
                      item: item
                    })
                    Text(item.member.member.title !== '' ? item.member.member.title : this.nameTitle)
                      .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontWeight(FontWeight.Medium)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
                      .margin({
                        start: this.isPC ? LengthMetrics.resource($r('app.float.id_card_margin_large')) :
                        LengthMetrics.resource($r('app.float.id_card_margin_xxl')),
                        top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                          0, $r('app.float.dialer_button_text_font_size')),
                        bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                          0, $r('app.float.dialer_button_text_font_size')),
                      })
                      .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
                      .flexShrink(1)
                      .flexGrow(1)
                  }
                  .constraintSize({
                    minHeight: this.isPC ? $r('app.float.id_item_height_large') :
                    $r('app.float.id_item_height_max')
                  })
                  .bindContextMenu(this.isMenuShown && this.longPressIndex === index, this.MenuBuilder(item), {
                    preview: this.MenuPreview(item),
                    previewAnimationOptions: { scale: [1, 1] },
                    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
                    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
                    offset: {
                      x: 0,
                      y: $r('sys.float.padding_level4')
                    },
                    onDisappear: () => {
                      this.longPressIndex = -1;
                      this.isMenuShown = false;
                    },
                    placement: Placement.BottomLeft,
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
                  .onMouse((event: MouseEvent) => {
                    if (event.button === MouseButton.Right && event.action === MouseAction.Release) {
                      this.longPressIndex = index;
                      VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
                    }
                  })
                  .gesture(LongPressGesture({ repeat: false, fingers: 1, duration: 800 })
                    .onAction((event: GestureEvent) => {
                      this.longPressIndex = index;
                      VibrationUtils.onceVibration(VibrationEffect.LongPressLight);
                      this.isMenuShown = true
                    })
                  )
                  .onClick(() => {
                    let params: Record<string, boolean | string> = {
                      'sourceHasId': true,
                      'contactId': item.member.member.contactId,
                      'pageTag': 'groupListDetail'
                    }
                    DynamicLoader.getInstance().fire(DynamicLoader.CONTACT_DETAIL_PAGE).then(() => {
                      this.pathInfos.pushPathByName('ContactDetail', params);
                    });
                  })
                }
                .padding({
                  left: this.spaceLR,
                  right: this.spaceLR,
                })
                .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
                .stateStyles({
                  pressed: this.pressedStyles,
                })
                .id('GrouoListDetail_ListItemGroup_groupListDetail_ListItem')
                .focusBox({
                  margin: this.isPC ? LengthMetrics.vp(PCDeviceConstant.FOCUS_BOX_MARGIN_NEGATIVE_THREE) :
                  LengthMetrics.vp(0)
                })
              }, (item: GroupMemberListBean) => JSON.stringify(item))
          }.divider({
            strokeWidth: '1px',
            color: $r('app.color.skin_ohos_id_color_list_separator'),
            startMargin: this.curBp === 'lg' ? 80 : $r('app.float.account_listItem_text_common_width'),
            endMargin: this.spaceLR
          })

        }
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .editMode(true)
        .width('100%')
        .height('100%')
        .backgroundColor(this.isThemeActive ? undefined : $r('app.color.skin_background_primary'))
      }
    }
    .height('100%')
    .flexShrink(1)
  }
}

@Component
struct ContactEmptyPage {
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  build() {
    Column() {
      Column() {
        Image($r('app.media.ic_empty_page_no_contacts'))
          .objectFit(ImageFit.Contain)
          .width($r('app.float.id_card_image_large'))
          .height($r('app.float.id_card_image_large'))
          .margin({ bottom: $r('app.float.id_card_margin_large') })

        Text($r('app.string.no_contacts'))
          .width($r('app.float.id_card_image_large'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_font_tertiary'))
          .textAlign(TextAlign.Center)
      }
      .flexShrink(1)
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .padding({ top: EnvironmentProp.isPC() ? 0 : $r('app.float.id_hds_title_margin') })
    .width('100%')
    .height('100%')
  }
}

@Component
struct IntelligenceGroupBottomContent {
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @Link isShowSheet: boolean;
  customParams: CustomizedParams = {};
  @State categoryGroupType: string = '';
  @State intelliGroupName: string = '';
  @State categoryIndex: string = '';
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @State isMore: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  private toolBarModifier: ToolBarModifier =
    new ToolBarModifier().height(LengthMetrics.vp(48))
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .padding(LengthMetrics.vp(0));
  @Link toolbarList: ToolBarOptions;

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
        ToolBar({
          toolBarList: this.toolbarList,
          dividerModifier: new DividerModifier().height(0),
          toolBarModifier: this.toolBarModifier
        }).height($r('app.float.id_item_height_mid'))
      }
    }
  }
}

@Component
export struct ContactPhotoView {
  @Prop item: GroupMemberListBean;
  @State photoPixelMap: PixelMap | null = null;
  @StorageProp('contactListUpdated') @Watch('updatePixelMap') contactListUpdated: number = 0;

  aboutToAppear() {
    getPixelMapFromFile(this.item.member.member.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  updatePixelMap() {
    getPixelMapFromFile(this.item.member.member.contactId, (res: PixelMap | null) => {
      this.photoPixelMap = res;
    })
  }

  build() {
    Row() {
      if (this.photoPixelMap) {
        Image(this.photoPixelMap)
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Auto)
          .borderRadius($r('app.float.id_card_image_s'))
          .draggable(false)
      } else if (StringUtil.isEmpty(this.item.member.member.headChar)) {
        Image(StringUtil.isEmpty(this.item.member.member.portraitPath) ?
        $r('app.media.ic_user_portrait') : this.item.member.member.portraitPath
        )
          .width($r('app.float.id_card_image_mid'))
          .height($r('app.float.id_card_image_mid'))
          .objectFit(ImageFit.Contain)
          .borderRadius($r('app.float.id_card_image_s'))
          .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
          .backgroundColor(
            StringUtil.isEmpty(this.item.member.member.portraitPath) ?
            $r('app.color.skin_ohos_id_color_fourth') : Color.Transparent
          )
          .draggable(false)
      } else {
        Text(this.item.member.member.headChar)
          .fontSize('16vp')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.skin_font_on_primary'))
          .backgroundColor($r('app.color.skin_icon_fourth'))
          .height($r('app.float.id_card_image_mid'))
          .width($r('app.float.id_card_image_mid'))
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.float.id_card_image_s'))
          .accessibilityLevel('no')
      }
    }
    .height($r('app.float.id_card_image_mid'))
    .width($r('app.float.id_card_image_mid'))
    .flexShrink(0)
  }
}