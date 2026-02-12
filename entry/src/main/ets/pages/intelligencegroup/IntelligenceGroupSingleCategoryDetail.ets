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
import { CustomizedParams } from '../../model/type';
// import { PafEmptyPage } from '@hms-paf/ui-widget-emptypage';
import { LengthMetrics } from '@kit.ArkUI';
import { SymbolGlyphModifier, TextModifier } from '@ohos.arkui.modifier';
import { Params } from '../../../../../../common/src/main/ets/Constants';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { SplitStatus } from '../../util/DisplaySplitUtil';
import EnvironmentProp from '../../feature/EnvironmentProp';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import IntelligenceGroupListPresenter from '../../presenter/intelligencegroup/IntelligenceGroupListPresenter';
import IntelligenceGroupSingleCategoryDetailPresenter, {
  IntelligenceGroupListInterface
} from '../../presenter/intelligencegroup/IntelligenceGroupSingleCategoryDetailPresenter';
import IntelligenceGroupSingleCategoryItem from '../../component/intelligencegroup/IntelligenceGroupSingleCategoryItem';
import { GroupInfo, IntelligenceGroupInfo } from '../../model/bean/GroupBean';
import LooseObject from '../../model/type/LooseObject';
import { ObjectUtil } from '../../../../../../feature/call/oh_modules/common';
import { Constants } from '../../data/Constants';
// import TitleBarUtil, { TitleBarParams } from '../../util/TitleBarUtil';

const TAG = 'IntelligenceGroupSingleCategoryDetail';

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

@Builder
export function IntelligenceGroupSingleCategoryDetailLoader($$: Params): void {
  IntelligenceGroupSingleCategoryDetail();
}

/**
 * Group List Detail
 */
@Component
export default struct IntelligenceGroupSingleCategoryDetail {
  @State singleCategoryGroupPresenter: IntelligenceGroupSingleCategoryDetailPresenter =
    new IntelligenceGroupSingleCategoryDetailPresenter();
  @State otherIntelligencePresenter: IntelligenceGroupListPresenter = IntelligenceGroupListPresenter.getInstance();
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  // 分类数量
  @State categoryListLen: number = 0;
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
  @State title: Resource | string = Constants.EMTPY_STR;
  @State categoryName: string = Constants.EMTPY_STR;
  @State categoryGroupType: string = '0';
  private isPC: boolean = EnvironmentProp.isPC();
  private scroller: Scroller = new Scroller();
  groupMoreParams: CustomizedParams = {
    ITEM: 0
  };
  // 分类数量更新
  @State updateIntelligenceGroupList: IntelligenceGroupListInterface = {
    updateIntelligenceGroupList: (): void => {
      HiLog.w(TAG, `updateIntelligenceGroupList: ${this.singleCategoryGroupPresenter.groupMemberListLen}`);
      this.categoryListLen = this.singleCategoryGroupPresenter.groupMemberListLen;
    }
  };

  updateGroupListDetail() {
    HiLog.w(TAG, `refresh contactCount: ${this.contactCount}`);
    this.singleCategoryGroupPresenter.aboutToAppear(this.categoryGroupType);
  }

  destinationPageShow() {
    HiLog.w(TAG, 'destinationPageShow');
    this.singleCategoryGroupPresenter.setPageShow();
  }

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear');
    let navParam: LooseObject = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as LooseObject;
    if (!ObjectUtil.isEmpty(navParam)) {
      this.categoryName = navParam.groupName ?? Constants.EMTPY_STR;
      this.categoryGroupType = navParam.categoryGroupType;
      this.singleCategoryGroupPresenter.categoryGroupType = this.categoryGroupType;
      if (this.categoryName === 'origanization') {
        this.title = $r('app.string.intelligence_group_company');
      } else if (this.categoryName === 'city') {
        this.title = $r('app.string.intelligence_group_city');
      } else if (this.categoryName === 'latestcontact') {
        this.title = $r('app.string.intelligence_group_latest_contact');
      } else {
        HiLog.e(TAG, `aboutToAppear categoryName invalid,${this.categoryName}`);
      }
    }
    this.singleCategoryGroupPresenter.updateIntelligenceGroupList = this.updateIntelligenceGroupList;
    this.singleCategoryGroupPresenter.initNavPaths(this.pathInfos);
    this.otherIntelligencePresenter.initNavPaths(this.pathInfos);
    this.singleCategoryGroupPresenter.aboutToAppear(this.categoryGroupType);
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear');
    this.singleCategoryGroupPresenter.resetData();
  }

  build() {
    if (this.isPC) {
      NavDestination() {
        Column() {
          Column() {
            if (this.categoryListLen > 0) {
              IntelligenceDetailContent({
                categoryDetailPresenter: $singleCategoryGroupPresenter,
                categoryGroupType: this.categoryGroupType
              })
            } else {
              ContactEmptyPage()
            }
          }
          .layoutWeight(1)
          .flexShrink(1)
        }
        .flexShrink(1)
        .width('100%')
        .height('100%')
      }
      .title(this.title, {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart: this.isPC ? LengthMetrics.vp(16) : ((this.curBp === 'lg') ? LengthMetrics.vp(24) : undefined)
      })
      .id('IntelligenceGroupSingleCategoryDetail_Navi_onBackPressed_NavDestination')
      .backButtonIcon(this.isThemeActive ?
      new SymbolGlyphModifier($r('sys.symbol.chevron_backward')).fontColor([$r('app.color.skin_icon_primary')])
        : new SymbolGlyphModifier($r('sys.symbol.chevron_backward')))
      .onBackPressed(() => {
        this.singleCategoryGroupPresenter.back();
        return true;
      })
      .onShown(() => {
        this.destinationPageShow();
      })
      .expandSafeArea([SafeAreaType.KEYBOARD])
      .backgroundColor(this.isThemeActive ? undefined : $r('app.color.color_bind_sheet_background'))
      .padding({
        top: px2vp(this.fullScreenPadding.top as number),
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
    } else {
      NavDestination() {
        Column() {
          Column() {
            if (this.categoryListLen > 0) {
              IntelligenceDetailContent({
                categoryDetailPresenter: $singleCategoryGroupPresenter,
                categoryGroupType: this.categoryGroupType,
                scroller: this.scroller
              })
            } else {
              ContactEmptyPage()
            }
          }
          .layoutWeight(1)
          .flexShrink(1)
        }
        .flexShrink(1)
        .width('100%')
        .height('100%')
      }
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), undefined, () => {
      //   this.onBack();
      // }))
      .title(this.title, {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart: this.isPC ? LengthMetrics.vp(16) : ((this.curBp === 'lg') ? LengthMetrics.vp(24) : undefined)
      })
      .id('IntelligenceGroupSingleCategoryDetail_Navi_onBackPressed_hds_NavDestination')
      .onShown(() => {
        this.destinationPageShow();
      })
      .expandSafeArea([SafeAreaType.KEYBOARD])
      .backgroundColor(this.isThemeActive ? undefined : $r('app.color.color_bind_sheet_background'))
      .padding({
        top: !this.isPC ? px2vp(this.fullScreenPadding.top as number) : 0,
        bottom: px2vp(this.fullScreenPadding.bottom as number)
      })
      .bindToScrollable([this.scroller])
    }
  }

  private onBack() {
    this.singleCategoryGroupPresenter.back();
  }

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     avoidLayoutSafeArea: true,
  //     title: { title: this.title as string },
  //     backIcon: { isThemeActive: this.isThemeActive, backIcon: true }
  //   };
  // }
}

@Component
struct IntelligenceDetailContent {
  @State longPressIndex: number = -1;
  @State isMenuShown: boolean = false;
  @State isPressed: boolean = false;
  @State categoryGroupType: string = '0';
  @Link categoryDetailPresenter: IntelligenceGroupSingleCategoryDetailPresenter;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  // 字体大小
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  private scroller: Scroller = new Scroller();
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

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear detail');
  }

  build() {
    GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: { x: 12, y: 0 } }) {
      GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
        List({ scroller: this.scroller }) {
          ListItemGroup({ style: ListItemGroupStyle.CARD }) {
            LazyForEach(this.categoryDetailPresenter.intelligenceGroupListDataSource,
              (item: IntelligenceGroupInfo, index: number) => {
                ListItem() {
                  Flex({
                    direction: FlexDirection.Column,
                    justifyContent: FlexAlign.Center,
                    alignItems: ItemAlign.Start
                  }) {
                    IntelligenceGroupSingleCategoryItem({
                      item: item,
                      categoryDetailPresenter: $categoryDetailPresenter,
                      categoryGroupType: this.categoryGroupType,
                      categoryIndex: index + Constants.EMTPY_STR
                    })
                      .id('IntelligenceGroupCategory_Contacts_LongPressGesture_CategoryGroupItem')
                  }
                  .width('100%')
                }
                .backgroundColor(Color.Transparent)
              }, (item: GroupInfo) => JSON.stringify(item))
          }
          .borderRadius(this.isPC ? '16vp' : $r('sys.float.corner_radius_level10'))
          .margin({
            left: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_left'),
            right: (this.isPC || this.curBp === 'lg') ? '24vp' : $r('sys.float.margin_right'),
            top: '8vp'
          })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .divider({
            strokeWidth: '1px',
            startMargin: '8vp',
            endMargin: '8vp',
            color: $r('app.color.skin_ohos_id_color_list_separator'),
          })
          .width('100%')
        }
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .editMode(true)
        .width('100%')
        .height('100%')
        .backgroundColor(this.isThemeActive ? undefined : $r('app.color.color_bind_sheet_background'))
        .clipContent(ContentClipMode.SAFE_AREA)
        .safeAreaPadding({ top: this.isPC ? 0 : '94vp' })
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

  aboutToAppear() {
  }

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
    .width('100%')
    .height('100%')
  }
}
