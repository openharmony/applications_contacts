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
 * See the License for the specific language governing permissions andIconStyleMode
 * limitations under the License.
 */

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import AlphabetIndexerPresenter from '../../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';
import { AlphabetIndexerPage } from '../alphabetindex/AlphabetIndexerPage';
import { BatchSelectContact, PhoneNumberInterface, SingleSelectContact } from '../../../model/type';
import emitter from '@ohos.events.emitter';
// import { PafEmptyPage, PafLoading } from '@hms-paf/ui-widget-emptypage';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import { JSON, taskpool } from '@kit.ArkTS';
import curves from '@ohos.curves';
import {
  ContactsGlobalThisHelper
} from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/ContactsGlobalThisHelper'
import {
  UiExtentionParam,
} from '../../../uiExtentionAbility/ContactUiExtentionAbility';
import { inputMethod } from '@kit.IMEKit';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { ArrowBack } from '../../../component/contact/contactlist/ArrowBack';
import { ContactPickerListItem, PickerShowSubData, ContactPickerParam } from '../../../model/type/ContactParams';
import EmitterConstant from '../../../data/EmitterConstant';
import { initFusionSearchService } from '../../../component/contact/contactlist/ContactContent';
import { FontScaleState } from '../../../util/fontScaleState';
import LooseObject from '../../../model/type/LooseObject';
import { SearchUtil } from '../../../util/SearchUtil';
import { LengthMetrics, SymbolGlyphModifier, TextModifier } from '@kit.ArkUI';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import { i18n } from '@kit.LocalizationKit';
import { getPixelMapFromFile, getPixelMapFromFileForContactPicker } from '../../../util/UserPhoto';
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import NameDisposal from '../../../feature/NameDisposal';
import { PhoneNumber } from '../../../../../../../feature/phonenumber/src/main/ets/PhoneNumber';
import { ContactVo } from '../../../model/bean/ContactVo';
import ContactsPickerPresenter from '../../../presenter/contact/batchselectcontacts/ContactsPickerPresenter';
import { BusinessError, commonEventManager, osAccount } from '@kit.BasicServicesKit';
import IndexPresenter from '../../../presenter/IndexPresenter';
import CallRecordPresenter from '../../../presenter/dialer/callRecord/CallRecordPresenter';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { KeyCode } from '@kit.InputKit';
// import { PickerMaskLayer, PickerSheet, PickerType, PickerShieldAnimate, AnimateState } from '@hw-hmos/pickersheet';
import { SlidingMultipleSelectionsUtil } from '../../../util/SlidingMultipleSelectionsUtil';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
// import {
//   HdsNavDestination,
//   HdsNavDestinationAttribute,
//   HdsNavDestinationTitleMode,
//   HdsNavigationBadgeIconOptions,
//   // IconStyleMode
// } from '@kit.UIDesignKit'
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';
import { accessibility } from '@kit.AccessibilityKit';
import { Constants } from '../../../data/Constants';
import { ContactEmptyPage } from './ContactEmptyPage';
import FavoriteListPresenter from '../../../presenter/favorite/FavoriteListPresenter';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'ContactsPickerPage';

const pickerMaxFontScale = 1.3;
const hasComma: RegExp = new RegExp(',', 'g');
const COMMA_REPLACE: string = '&comma;';
const labelMatch: RegExp = new RegExp('<|>', 'gi');

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}
PersistentStorage.persistProp('showAccessedList', []);

@Builder
export function ContactsPickerPageLoader($$: Params): void {
  ContactsPickerPage();
}

@Builder
export function ContactsPickerSinglePageLoader($$: Params): void {
  ContactsPickerPage({ isContactMultiSelect: false });
}

let subscriber: commonEventManager.CommonEventSubscriber;

let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: ['event.custom.contacts.VCARD_SHARE']
};

/**
 * 联系人选择器页面组件
 * 
 * 该组件提供了联系人的批量选择和单选择功能，支持以下特性：
 * 1. 联系人列表展示与搜索
 * 2. 支持单选/多选模式切换
 * 3. 联系人字母索引导航
 * 4. 已选联系人查看与管理
 * 5. 支持不同设备类型(手机/平板/PC)的适配
 * 6. 支持分屏模式
 * 7. 集成搜索功能和空状态处理
 * 8. 支持无障碍访问
 * 
 * 应用场景：短信发送、邮件发送、分享等需要选择联系人的功能
 */
@Component
export default struct ContactsPickerPage {
  // 启动能力的调用者包名
  private startAbilityCallerBundleName =  AppStorage.get('startAbilityCallerBundleName') || '';
  // 调用者进程ID
  private callerPid =  AppStorage.get('callerPid') || '';
  // UI扩展参数，用于获取扩展能力相关信息
  private uiExtentionParam = ContactsGlobalThisHelper.GetGlobalThis()
    .getValue<UiExtentionParam>(ContactsGlobalThisHelper.UiExtentionAbilityParams);
  // UI扩展内容会话，用于与扩展能力通信
  private session: UIExtensionContentSession = ContactsGlobalThisHelper.GetGlobalThis().getUIExtensionContentSession();
  // 是否为多选模式
  private isContactMultiSelect: boolean = true;
  // 是否按名称显示联系人
  private isDisplayByName: boolean = false;
  // 是否保存已存在的联系人
  private isSaveExistContact: boolean = false;
  // 搜索控制器，用于管理搜索功能
  private controller: SearchController = new SearchController()
  // 用户ID，用于区分不同用户的联系人数据
  private userId: number = -1;
  // 来源标识，用于记录联系人选择器的调用来源
  private source: string = '';
  // 智能组名称
  private intelliGroupName: string = '';
  // 本地ID
  private localId: number = -1;
  // 是否为联系人选择器模式
  private isContactsPicker: boolean = false;

  // 联系人选择器的presenter，负责数据处理和业务逻辑
  @State mPresenter: ContactsPickerPresenter = ContactsPickerPresenter.getInstance();
  // 路径信息栈，用于页面导航管理
  @Consume('pathInfos') pathInfos: NavPathStack;
  // 全屏内边距，适配不同设备的屏幕尺寸
  @StorageProp('fullScreenPadding') fullScreenPadding: Padding = {};
  // 当前断点，用于响应式布局
  @StorageProp('breakpoint') curBp: string = 'sm';
  // 左右间距，根据设备类型动态调整
  @StorageLink('spaceLR') spaceLR: Resource =
    EnvironmentProp.isPC() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8');
  // 字体大小缩放比例
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启用主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主标题文本修饰符，用于主题定制
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  // 是否启用无障碍功能
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  // 分屏默认状态
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;

  // 是否已选联系人视图显示状态
  @State selectedViewShow: boolean = false;
  // 已选联系人视图的Y轴偏移量
  @State selectedViewOffsetY: Length = '100%';

  // 是否显示账号列表
  @StorageLink('isShowAccountants') isShowAccountants: boolean = false;
  // 是否显示绑定表单
  @StorageLink('isShowBindSheet') isShowBindSheet: boolean = false;
  // 搜索框输入值
  @State changeValue: string = '';
  // 是否正在进行搜索
  @StorageLink('isPickerSearch') isSearching: boolean = false;
  // 已选联系人数量
  @State selectedCount: number = 0;
  // 联系人总数
  @State contactsTotal: number = -1;
  // 联系人列表是否已初始化
  @State contactsListInited: boolean = false;
  // 是否只显示已访问的联系人提醒
  @State isShowOnlyAccessedAlert: boolean = true;
  // 是否启用加载视图
  @State loadingViewEnabled: boolean = false;
  // 是否正在获取选择器数据
  @StorageProp('isGettingPickerData') isGettingPickerData: boolean = false;
  // 是否为PC设备
  private isPC: boolean = EnvironmentProp.isPC();
  // 是否为Verde设备
  @StorageProp('isVerde') isVerde: boolean = false;
  // 是否显示"了解更多"提示
  @State isShowLearnMore: boolean = false;
  // 是否显示选择器遮罩层
  @StorageLink('isShowPickerMaskLayer') isShowPickerMaskLayer: boolean = false;
  // Verde安全盾高度
  @State verdeSecurityShieldHeight: number = 0;
  // 搜索框是否聚焦
  @State isSearchFocus: boolean = false;
  // 是否删除联系人
  @State deleteContact: boolean = false;
  // 全屏顶部内边距
  @State fullScreenPaddingTop: number = px2vp(this.fullScreenPadding.top as number);
  private scroller: Scroller = new Scroller();
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);

  /**
   * 菜单栏配置
   * 包含关闭按钮的配置，点击时调用closeOnClick方法关闭页面
   */
  // private menuBar: HdsNavigationBadgeIconOptions[] = [
  //   {
  //     content: {
  //       label: $r('app.string.shut_down'),//关闭or返回
  //       // type: IconStyleMode.SMALL,
  //       isEnabled: !this.isGettingPickerData,//返回按钮是否可用
  //       action: () => {
  //         titleMethodClass.closeOnClick();//关闭页面
  //       }
  //     }
  //   }
  // ]

  @Builder
  TitleGuide() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize($r('app.float.id_card_image_small'))
          .fontColor([$r('app.color.skin_icon_primary')])
      }
      .type(ButtonType.Circle)
      .borderRadius(0)
      .width($r('app.float.id_card_image_mid'))
      .height($r('app.float.id_card_image_mid'))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .stateEffect(true)
      .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
      .id('Settings_close_btn')
      .onClick(() => {
        titleMethodClass.closeOnClick();
      })
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .height($r('app.float.id_item_height_large'))
    .padding({
      end: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource(this.spaceLR),
    })
    .margin({
      left: this.isPC ? '8vp' : ((this.curBp === 'lg') ? '24vp' : undefined)
    })
  }

  /**
   * 订阅公共事件回调函数
   * 处理VCARD_SHARE事件，当接收到联系人分享事件时关闭当前页面
   * @param err - 事件订阅过程中可能出现的错误
   * @param data - 公共事件数据，包含事件类型、bundle名称、事件代码等信息
   */
  private handleVcardShareSubscribeCB: (err: BusinessError, data: commonEventManager.CommonEventData) => void =
    (err: BusinessError, data: commonEventManager.CommonEventData) => {
      HiLog.i(TAG, `commonEvent subscribe event: ${data?.event}, bundleName: ${data?.bundleName}, code: ${data?.code}`);
      if (data) {
        titleMethodClass.closeOnClick();
      } else {
        HiLog.i(TAG, 'commonEvent subscribe err:' + err?.message + ', stack: ' + err?.stack);
      }
    }

  /**
   * 创建订阅者回调函数
   * 用于创建公共事件订阅者并完成订阅
   * @param err - 创建订阅者过程中可能出现的错误
   * @param commonEventSubscriber - 创建成功的公共事件订阅者实例
   */
  private createCB: (err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) => void =
    (err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
      if (!err) {
        subscriber = commonEventSubscriber;
        try {
          commonEventManager.subscribe(subscriber, this.handleVcardShareSubscribeCB);
        } catch (error) {
          HiLog.e(TAG, `Failed to subscribe. Code is ${error?.code}, message is ${error?.message}`);
        }
      } else {
        HiLog.e(TAG, `Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
      }
    }

  /**
   * 注册公共事件订阅者
   * 用于订阅VCARD_SHARE事件，处理联系人分享功能
   */
  public async registerSubscriber() {
    try {
      commonEventManager.createSubscriber(subscribeInfo, this.createCB);
    } catch (error) {
      HiLog.e(TAG, `Failed to create subscriber. Code is ${error?.code}, message is ${error?.message}`);
    }
  }

  /**
   * 初始化方法
   * 页面加载时调用，用于完成订阅者注册等初始化工作
   */
  async init() {
    await this.registerSubscriber();
  }

  /**
   * 取消订阅公共事件回调
   * @param err - 取消订阅过程中可能出现的错误
   */
  private unsubscribeCB(err: BusinessError) {
    if (err) {
      HiLog.e(TAG, `Failed to unsubscribe. Code is ${err.code}, message is ${err.message}`);
    } else {
      HiLog.i(TAG, `Succeeded in unsubscribing.`);
    }
  }

  /**
   * 取消公共事件订阅
   * 用于在页面销毁或不需要时停止接收VCARD_SHARE事件
   */
  public unsubscribe() {
    try {
      commonEventManager.unsubscribe(subscriber, this.unsubscribeCB);
    } catch (error) {
      HiLog.e(TAG, `Failed to unsubscribe. Code is ${error?.code}, message is ${error?.message}`);
    }
  }

  /**
   * 反初始化方法
   * 页面销毁时调用，用于完成取消订阅等清理工作
   */
  unInit() {
    this.unsubscribe();
  }

  /**
   * 页面即将出现时调用的生命周期方法
   * 完成初始化工作，包括：
   * 1. 注册公共事件订阅者
   * 2. 控制加载视图显示
   * 3. 获取本地账户信息
   * 4. 处理不同方式传入的参数（UiExtentionAbility或pathInfos）
   * 5. 设置UI刷新回调
   * 6. 初始化Presenter
   * 7. 显示隐私权限提示
   * 8. 设置标题栏事件处理
   * 9. 配置滑动多选工具
   */
  async aboutToAppear() {
    this.init();
    // 控制loading 页面闪屏
    setTimeout(() => {
      this.loadingViewEnabled = true;
      AccessibilityUtil.getInstance()
        .sendAccessibilityEvent(this.isOpenAccessibility, 'select_contact_title', 100);
    }, 2);
    this.localId = await osAccount.getAccountManager().getOsAccountLocalId();
    HiLog.w(TAG, `localId: ${this.localId}`);

    // 参数处理逻辑：根据不同的调用方式初始化页面参数
    if (this.uiExtentionParam) {
      // UiExtentionAbility 调用方式：从扩展能力参数中获取配置
      HiLog.w(TAG, `aboutToAppear UiExtentionAbility`);
      this.isContactMultiSelect = this.uiExtentionParam.isContactMultiSelect;
      this.isDisplayByName = this.uiExtentionParam.isDisplayByName;
      this.isSaveExistContact = this.uiExtentionParam.isSaveExistContact;
      this.isContactsPicker = this.uiExtentionParam.isContactsPicker;
      this.userId = this.uiExtentionParam.userId;
      this.source = this.uiExtentionParam?.source ?? '';
      this.intelliGroupName = this.uiExtentionParam?.intelliGroupName ?? '';
      if (this.uiExtentionParam.contact) {
        this.mPresenter.contactFromPicker = this.uiExtentionParam.contact;
      }
    } else if (this.pathInfos && this.pathInfos.size() > 0) {
      // pathInfos 调用方式：从导航路径参数中获取配置
      HiLog.w(TAG, 'aboutToAppear pathInfo');
      this.mPresenter.initNavPaths(this.pathInfos);
      let param = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as ContactPickerParam;
      this.isDisplayByName = param.isDisplayByName;
      this.isSaveExistContact = param.isSaveExistContact;
      this.isContactsPicker = false;
    } else {
      // 根页面直接展示：使用默认配置
      HiLog.w(TAG, 'aboutToAppear entry');
    }
    // UI刷新回调配置：设置Presenter的UI刷新回调函数
    // 当数据发生变化时，Presenter会调用此回调更新页面UI
    this.mPresenter.refreshUI = () => {
      this.contactsListInited = this.mPresenter.contactsListInited;
      this.contactsTotal = this.mPresenter.totalCount;
      this.selectedCount = this.mPresenter.selectedCount;
      // 如果没有选中项但已选列表可见，则隐藏已选列表
      if (this.mPresenter.selectedSource.totalCount() <= 0 && this.selectedViewShow) {
        this.reloadSelectedViewVisibility();
      }
      // 处理会计师视图显示逻辑
      this.isShowAccountants = this.mPresenter.isShowAccountants;
      if (this.isShowAccountants) {
        AppStorage.setOrCreate('accountantParams', this.mPresenter.myAccountantsModel);
      }
      HiLog.i(TAG, `refreshUI, selectedCount: ${this.selectedCount}, contactsTotal: ${this.contactsTotal}`);
    }
    this.mPresenter.aboutToAppear(this.isContactMultiSelect);
    this.showOnlyAccessedAlert();

    titleMethodClass.backOnClick = () => {
      this.backToListView();
    }
    // 标题栏关闭按钮点击事件处理
    titleMethodClass.closeOnClick = () => {
      HiLog.w(TAG, `close button click, isGettingPickerData: ${this.isGettingPickerData}
        , isSaveExistContact: ${this.isSaveExistContact}, isShowBindSheet = ${this.isShowBindSheet}`);
      // 确保没有正在获取数据的操作
      if (!this.isGettingPickerData) {
        if (this.isSaveExistContact) {
          // 保存现有联系人模式：直接关闭并返回结果
          this.session?.terminateSelfWithResult({ resultCode: 1 }).then(() => {
            HiLog.i(TAG, 'terminateSelfWithResult Operation succeeded ');
          }).catch((error: BusinessError) => {
            HiLog.e(TAG, `Operation failed. Cause: ${error?.message}`);
          });
        } else {
          // 联系人选择器模式：返回默认选中的数据
          this.isShowBindSheet = false;
          setTimeout(() => {
            this.mPresenter.returnDefaultSelectContactData();
          }, 100);
        }
      }
    }

    this.slidingMultipleSelectionsUtil.isSliding = this.isContactMultiSelect;
    // if (this.mPresenter.filter?.filterClause && this.filter?.filterClause) {
    //   this.mPresenter.filter.filterClause.id = this.filter.filterClause.id;
    //   this.mPresenter.filter.filterType = contact.FilterType.SHOW_FILTER_AND_DEFAULT_SELECT// 显示过滤和默认选择
    // }
  }

  /**
   * 智能群组添加联系人对话框内容构建器
   * 用于显示添加联系人到智能群组的确认信息
   */
  @Builder
  SelectContactsDialogBuilder(){
    Column() {
      Text($r('app.string.intelligence_group_add_contact_dialog_content',
        this.intelliGroupName ? this.intelliGroupName : $r('app.string.intelligence_group_no_company')))
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
  }

  /**
   * 智能群组添加联系人自定义弹窗控制器
   * 用于管理添加联系人到智能群组的确认对话框
   */
  intelligenceGroupAddContactDialogControler: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: $r('app.plural.intelligence_group_add_contact_dialog_title', this.mPresenter.selectedCount,
        this.mPresenter.selectedCount),
      contentBuilder: () => {
        this.SelectContactsDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {

            this.intelligenceGroupAddContactDialogControler?.close();
          }
        },
        {
          value: $r('app.string.add'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.mPresenter.selectBatchContact();
          },
        }
      ]
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    cornerRadius: {
      topLeft: this.isPC ? '16vp' : $r('app.float.rounded_corners_width_32'),
      topRight: this.isPC ? '16vp' : $r('app.float.rounded_corners_width_32'),
      bottomLeft: this.isPC ? '16vp' : $r('app.float.rounded_corners_width_32'),
      bottomRight: this.isPC ? '16vp' : $r('app.float.rounded_corners_width_32')
    }
  })

  /**
   * 页面即将消失时调用的生命周期方法
   * 完成清理工作，包括：
   * 1. 取消公共事件订阅
   * 2. 取消事件发射器订阅
   */
  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear')
    this.unInit();
    emitter.off(ContactsPickerPresenter.BATCH_SELECT_ITEM_CHECKED);
  }

  showOnlyAccessedAlert() {
    let list: string[] = AppStorage.get('showAccessedList') as string[];
    // 优先使用uiExtentionParam中的callerBundleName，如果为空则使用AppStorage中的startAbilityCallerBundleName
    let name: string = this.uiExtentionParam?.callerBundleName ?? this.startAbilityCallerBundleName as string ?? '';
    // let name: string = this.uiExtentionParam?.callerBundleName ?? '';
    HiLog.w(TAG, `showOnlyAccessedAlert name: ${name}, list: ${list}`);
    if (!StringUtil.isEmpty(name) && name !== 'com.ohos.contacts' && list.length === 0) {
      this.isShowOnlyAccessedAlert = true;
    } else {
      this.isShowOnlyAccessedAlert = false;
    }
  }

  /**
   * 从搜索列表返回联系人列表
   * 断开搜索会话，隐藏输入法，停止编辑状态，重置搜索相关状态
   */
  backToListView() {
    HiLog.w(TAG, 'backToListView');
    SearchUtil.getInstance().disconnectSearchSession();
    inputMethod.getController().hideTextInput();
    this.controller.stopEditing();
    this.isSearching = false;
    this.changeValue = '';
    this.mPresenter.contactSearchCount = -1;
  }

  /**
   * 控制已选联系人列表的显示/隐藏状态
   * 使用动画效果切换列表的显示位置，并发送无障碍事件通知状态变化
   */
  reloadSelectedViewVisibility() {
    if (this.selectedViewShow === true) {
      this.selectedViewShow = false;
      animateTo({ curve: curves.interpolatingSpring(4, 1, 342, 37), duration: 400 }, () => {
        this.selectedViewOffsetY = '100%';
      })
    } else {
      this.mPresenter.initSelectedDataSource();
      this.selectedViewShow = true;
      animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37), duration: 400 }, () => {
        this.selectedViewOffsetY = 0;
      })
    }
    accessibility.sendAccessibilityEvent(({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.contacts',
      triggerAction: 'common',
      textAnnouncedForAccessibility: this.selectedViewShow ? ResourceUtil.getStringByResource($r('app.string.accessibility_expanded')) :
        ResourceUtil.getStringByResource($r('app.string.accessibility_collapsed'))
    })).then(() => {
    })
  }

  /**
   * 搜索栏点击事件处理函数
   * 初始化搜索服务（如果未初始化），并将焦点设置到搜索框
   */
  searchBarClicked() {
    HiLog.w(TAG, 'searchBarClicked');
    if (this.mPresenter.searchSerInitStatus != 0) {
      let task = new taskpool.Task(initFusionSearchService);
      taskpool.execute(task).then((res: Object) => {
        this.mPresenter.searchSerInitStatus = Number(res.toString());
      });
    }
    if (this.isSearching) {
      return;
    }
    this.mPresenter.contactSearchCount = -1;
    focusControl.requestFocus('picker_contacts_searchClick_search')
  }


  /**
   * 已选联系人视图构建器
   * 显示用户已选择的联系人列表，并支持滑动多选操作
   */
  @Builder
  selectedView(): void {
    Stack() {
      Column() {
      }
      .backgroundColor($r('app.color.mask_custom'))
      .height('100%')
      .width('100%')
      .accessibilityLevel('no')
      .onClick(() => {
        this.reloadSelectedViewVisibility();//
      })

      Column() {
        List({ initialIndex: 0, scroller: this.scroller }) {
          LazyForEach(this.mPresenter.selectedSource, (item: ContactPickerListItem, index: number) => {
            ListItem() {
              // 已选联系人列表项
              ContactsPickerListItem({
                presenter: this.mPresenter,
                userId: this.userId,
                localId: this.localId,
                item: item,
                index: index,
                isMultiSelect: this.isContactMultiSelect,
                isDisplayByName: this.isDisplayByName,
                isSaveExistContact: this.isSaveExistContact,
                maxFontScale: pickerMaxFontScale,
                customIndexTitle: '',
                onlyShowChecked: true,
              })
            }
          }, (item: ContactPickerListItem, index: number) => JSON.stringify(item) + JSON.stringify(index))
        }
        .width('100%')
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          this.slidingMultipleSelectionsUtil.scrollStartIndex = firstIndex;
          this.slidingMultipleSelectionsUtil.scrollEndIndex = lastIndex;
        })
        .gesture(PanGesture({ direction: PanDirection.Vertical })
          .onActionStart((event: GestureEvent) => {
            for (let i = 0; i < this.mPresenter.selectedSource.totalCount(); ++i) {
              let item = this.mPresenter.selectedSource.getData(i);
              let selectStatus = this.mPresenter.selectedContactsMap.get(item?.contactId)?.has(
                item?.pickerShowSubData.keyValue) ?? false;
              this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
              this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
            }
            this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
          })
          .onActionUpdate((event: GestureEvent) => {
            let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
              let curSelectStatus = false;
              if (index >= 0) {
                let item = this.mPresenter.selectedSource.getData(index);
                curSelectStatus = this.mPresenter.selectedContactsMap.get(item?.contactId)?.has(
                  item?.pickerShowSubData.keyValue) ?? false;
              }
              return curSelectStatus;
            });
            updateIndexes.forEach((index) => {
              if (index >= 0) {
                let item = this.mPresenter.selectedSource.getData(index);
                this.mPresenter.itemOnClick(
                  item?.contactId, item?.pickerShowSubData.keyValue, item?.pickerShowSubData.dataId);
              }
            })
          })
          .onActionEnd(() => {
            this.slidingMultipleSelectionsUtil.onActionEnd();
            this.mPresenter.initSelectedDataSource();
            if (this.mPresenter.selectedSource.totalCount() <= 0 && this.selectedViewShow) {
              this.reloadSelectedViewVisibility();
            }
          })
          .onActionCancel(() => {
            this.slidingMultipleSelectionsUtil.onActionEnd();
            this.mPresenter.initSelectedDataSource();
            if (this.mPresenter.selectedSource.totalCount() <= 0 && this.selectedViewShow) {
              this.reloadSelectedViewVisibility();
            }
          }),
          GestureMask.Normal
        )
        .onGestureRecognizerJudgeBegin(
          (event: BaseGestureEvent, current: GestureRecognizer, recognizers: Array<GestureRecognizer>) => {
            return this.slidingMultipleSelectionsUtil.onGestureRecognizerJudgeBegin(event.fingerList[0], current);
          })
        .onAreaChange((oldValue: Area, newValue: Area)=>{
          this.slidingMultipleSelectionsUtil.listWidth = newValue.width as number
          this.slidingMultipleSelectionsUtil.areaY = newValue.globalPosition.y as number;
          this.slidingMultipleSelectionsUtil.contentHeight = newValue.height as number;
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .constraintSize({ maxHeight: '60%' })
      .clip(true)
      .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
      .padding({
        top: $r('sys.float.padding_level2'),
      })
      .borderRadius({
        topLeft: 32,
        topRight: 32
      })
      .offset({ y: this.selectedViewOffsetY })
    }
    .alignContent(Alignment.Bottom)
    .height('100%')
    .width('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }

  /**
   * 工具栏视图构建器
   * 显示已选联系人数量和完成按钮，支持切换已选联系人列表的显示/隐藏
   */
  @Builder
  toolBarView() {
    Column() {
      RelativeContainer() {
        if (!this.isSaveExistContact) {
          Text(this.isContactMultiSelect ? ResourceUtil.getStringByResource($r('app.string.selected'),
            `${this.selectedCount.toString()}/${this.mPresenter.selectLimit}`)
            : ResourceUtil.getStringByResource($r('app.string.selected'), `${this.selectedCount.toString()}/1`))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.selectedCount > 0 ? $r('app.color.skin_font_emphasize') : $r('app.color.skin_font_secondary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
            .maxFontScale(pickerMaxFontScale)
            .accessibilityText((this.isContactMultiSelect ? ResourceUtil.getStringByResource($r('app.string.selected'),
              `${this.selectedCount.toString()}/${this.mPresenter.selectLimit}`)
              : ResourceUtil.getStringByResource($r('app.string.selected'), `${this.selectedCount.toString()}/1`)) +
              (this.selectedViewShow ? ResourceUtil.getStringByResource($r('app.string.accessibility_expanded')) :
                ResourceUtil.getStringByResource($r('app.string.accessibility_collapsed'))))
            .alignRules({
              left: { anchor: '__container__', align: HorizontalAlign.Start },
              center: { anchor: 'doneButton', align: VerticalAlign.Center }
            })
            .enabled(this.selectedCount > 0)
            .id('selectedText')
            .onClick(() => {0
              if (this.selectedCount > 0) {
                this.mPresenter.initSelectedDataSource();//重置已选数据源
                this.reloadSelectedViewVisibility();//显示已选联系人列表
              }
            })

          WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
            // Column 增加按键热区
            Column() {
              Button({ buttonStyle: ButtonStyleMode.EMPHASIZED }) {
                Text($r('app.string.done'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .maxFontScale(pickerMaxFontScale)
                  .fontColor(Color.White)
              }
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .width(72)
              .height(28)
              .enabled(!this.isGettingPickerData)
            }
            .height(48)
            .justifyContent(FlexAlign.Center)
            .margin({ top: -10, bottom: -10 })
            .enabled(!this.isGettingPickerData)
            .onClick(() => {
              HiLog.w(TAG, 'click done button!')
              // 添加联系人
              if (this.source === 'contactIntelligenceGroup') {
                 this.intelligenceGroupAddContactDialogControler?.open();
                this.mPresenter.selectedContactsMap.forEach((value: Set<string>) => {
                  let contactId = Array.from(value).toString()
                  HiLog.i(TAG, 'contactId: ' + contactId)
                  FavoriteListPresenter.getInstance().favoriteDataSource.favoriteContactIdList.push(contactId);
                })
               } else {
                this.isShowBindSheet = false;
                setTimeout(() => {
                  this.mPresenter.selectBatchContact();
                }, 100);
              }
            })
            .alignRules({
              right: { anchor: '__container__', align: HorizontalAlign.End },
              top: { anchor: '__container__', align: VerticalAlign.Top }
            })
            .id('doneButton')
            .accessibilityRole(AccessibilityRoleType.BUTTON)
          }
        }

        if (!this.isVerde) {
          Row({ space: 4 }) {
            // PickerShieldAnimate({
            //   pickerType:PickerType.CONTACTS_PICKER,
            //   callerBundleName:String(this.startAbilityCallerBundleName),
            //   callerPid:String(this.callerPid),
            //   onAnimateStateChange: (animateState) => {
            //     HiLog.i(TAG, 'animateState: ' + animateState);
            //   }
            // })
          }
          .alignItems(VerticalAlign.Center)
          .height(28)
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })
          .id('bottomPrompt')
        }
      }
      .width('100%')
      .height(this.isSaveExistContact ? '40vp' : this.isVerde ? '52vp' : '80vp')
      .backgroundColor(this.isSaveExistContact ? Color.Transparent : $r('app.color.skin_ohos_id_color_card_bg'))
      .padding({
        left: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
        right: this.isPC ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
        top: $r('sys.float.padding_level6'),
        bottom: this.isPC ? $r('sys.float.padding_level8') : $r('sys.float.padding_level0')
      })
    }
    .width('100%')
    .backgroundColor(this.isSaveExistContact ? Color.Transparent : $r('app.color.skin_ohos_id_color_card_bg'))
    .padding({ bottom:  this.curBp === 'sm' ? px2vp(this.fullScreenPadding.bottom as number) : '16vp' })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .flexShrink(0)
  }


  build() {
    NavDestination() {
      Navigation(){
        this.ContactPickerBuilder()
      }
      // 应用锁
      if (this.isShowPickerMaskLayer) {
        // PickerMaskLayer({
        //   onclose: () => {
        //     HiLog.w(TAG, `PickerMaskLayer onclose`);
        //   },
        //   appInfos: [{ bundleName: Constants.CONTACT_BUNDLE_NAME, appIndex: 0 }],
        //   unlockProxy: true,
        //   maskShow: this.isShowPickerMaskLayer
        // })
      }
    }
    // .titleBar(TitleBarUtil.getTitleBar(
    //   this.getTitleParam(),
    //   this.session !== undefined ? this.menuBar : undefined,
    //   () => {
    //     this.onBack();
    //   })
    // )
    .menus(this.uiExtentionParam.isContactsPicker === false  &&
      this.uiExtentionParam.isContactMultiSelect === false ? undefined : this.TitleGuide())
    // .titleMode(this.session !== undefined ? HdsNavDestinationTitleMode.MODAL : HdsNavDestinationTitleMode.MINI)
    .title(
      ResourceUtil.getStringByResource($r('app.string.select_contact'))
    )

    .padding({ top: this.fullScreenPaddingTop })
    .hideBackButton(this.session !== undefined && !this.isSearching)
    .backgroundColor($r('app.color.skin_ohos_id_color_panel_bg'))
    .onShown(() => {
      HiLog.i(TAG, 'onPageShow')
    })
    .onBackPressed(() => {
      HiLog.w(TAG, 'click back button!');
      return this.onBack();
    })
    .onHidden(() => {
      HiLog.i(TAG, 'onPageCover')
    })
  }
    // HdsNavDestination() {
    //   Stack() {
    //     this.ContactPickerBuilder()
    //
    //     // 应用锁
    //     if (this.isShowPickerMaskLayer) {
    //       PickerMaskLayer({
    //         onclose: () => {
    //           HiLog.w(TAG, `PickerMaskLayer onclose`);
    //         },
    //         appInfos: [{ bundleName: Constants.CONTACT_BUNDLE_NAME, appIndex: 0 }],
    //         unlockProxy: true,
    //         maskShow: this.isShowPickerMaskLayer
    //       })
    //     }
    //   }
    // }
    // .titleBar(TitleBarUtil.getTitleBar(
    //   this.getTitleParam(),
    //   this.session !== undefined ? this.menuBar : undefined,
    //   () => {
    //     this.onBack();
    //   })
    // )
    // .titleMode(this.session !== undefined ? HdsNavDestinationTitleMode.MODAL : HdsNavDestinationTitleMode.MINI)
    // .hideBackButton(this.session !== undefined && !this.isSearching)
    // .backgroundColor($r('app.color.skin_ohos_id_color_panel_bg'))
    // .onShown(() => {
    //   HiLog.i(TAG, 'onPageShow')
    // })
    // .onHidden(() => {
    //   HiLog.i(TAG, 'onPageCover')
    // })
  // }

  /**
   * 联系人选择器主视图构建器
   * 构建联系人选择器的完整界面，包括搜索栏、联系人列表和空页面
   */
  @Builder
  ContactPickerBuilder() {
    Stack() {
      Column() {
        if (!this.contactsListInited && this.loadingViewEnabled) {
          //todo：这里需要添加联系人列表刷新的Lodging。
          // PafLoading({
          //   descriptionFontColor: $r('app.color.skin_font_secondary'),
          //   customBackgroundColor: $r('app.color.skin_ohos_id_color_panel_bg'),
          //   alwaysDarkMode: false,
          //   fullPage: true,
          // })
          //   .layoutWeight(1);
        } else if (this.contactsListInited) {
          Stack({ alignContent: Alignment.Bottom }) {
            Scroll() {
              Flex({ direction: FlexDirection.Column }) {
                // 搜索栏，访问非本地userId 时，不显示搜索框
                if (!(this.userId > 0 && this.userId !== this.localId)) {
                  WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
                    Search({
                      value: $$this.changeValue,
                      placeholder: $r('app.string.search'),
                      controller: this.controller
                    })
                      .visibility(this.splitStatus === SplitStatus.ONE_THREE_SPLIT ? Visibility.None :
                      Visibility.Visible)
                      .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass'))
                        .fontColor([$r('app.color.skin_ohos_id_color_secondary')]))
                      .cancelButton({
                        icon: new SymbolGlyphModifier($r('sys.symbol.xmark'))
                          .fontColor([$r('app.color.skin_font_tertiary')])
                      })
                      .margin({
                        left: this.spaceLR,
                        right: this.spaceLR,
                        top: $r('sys.float.padding_level4'),
                        bottom: $r('sys.float.padding_level4')
                      })
                      .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
                      .direction(Direction.Ltr)
                      .placeholderColor($r('app.color.skin_font_secondary'))
                      .placeholderFont({
                        size: ($r('sys.float.Body_L')),
                        weight: FontWeight.Regular
                      })
                      .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
                      .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                      // .backgroundColor($r('app.color.skin_comp_background_tertiary'))
                      .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
                      .type(SearchType.NORMAL)
                      .id('picker_contacts_searchClick_search')
                      .onChange((value: string) => {
                        this.isSearching = value.replace(/\s*/g, '') !== '';
                        this.mPresenter.inputKeyword = value;
                        // this.mPresenter.getSearchContactResult(this.mPresenter.inputKeyword);
                        this.mPresenter.getSearchContactResultFromDb(this.mPresenter.inputKeyword);
                        if (!this.isSearching) {
                          this.mPresenter.contactSearchCount = -1;
                        }
                      })
                      .onClick(() => {
                        this.searchBarClicked();
                      })
                      .enabled(!this.selectedViewShow && !this.isGettingPickerData)
                      .onFocus(() => {
                        this.isSearchFocus = true;
                        SearchUtil.getInstance().initSearchSession();
                      })
                      .onBlur(() => {
                        this.isSearchFocus = false;
                      });
                  };
                }

                if (this.isSearching && this.mPresenter.contactSearchCount > 0) {
                  // 搜索页面
                  ContactsPickerSearch({
                    presenter: this.mPresenter,
                    userId: this.userId,
                    localId: this.localId,
                    isMultiSelect: this.isContactMultiSelect,
                    isDisplayByName: this.isDisplayByName,
                    isShowOnlyAccessedAlert: this.isShowOnlyAccessedAlert,
                    isShowLearnMore: this.isShowLearnMore,
                    verdeSecurityShieldHeight: this.verdeSecurityShieldHeight,
                    isSaveExistContact: this.isSaveExistContact,
                    selectedCount: this.selectedCount,
                    selectedViewShow: this.selectedViewShow,
                  })
                    .height('100%')
                    .enabled(!this.selectedViewShow)
                    .transition(TransitionEffect.OPACITY.animation({
                      duration: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
                    }))
                    .onTouch(() => {
                      if (this.isSearchFocus) {
                        inputMethod.getController().stopInputSession().then((result) => {
                          HiLog.w(TAG, `stopInputSession result: ${result}`);
                        }).catch((err: BusinessError) => {
                          HiLog.e(TAG, `stopInputSession err: ${err.message}`);
                        });
                      }
                    });
                } else if (!this.isSearching && this.contactsTotal > 0) {
                  //选择列表
                  ContactsList({
                    presenter: $mPresenter,
                    isContactMultiSelect: this.isContactMultiSelect,
                    isDisplayByName: this.isDisplayByName,
                    selectedViewShow: this.selectedViewShow,
                    userId: this.userId,
                    localId: this.localId,
                    isShowOnlyAccessedAlert: this.isShowOnlyAccessedAlert,
                    isShowLearnMore: this.isShowLearnMore,
                    verdeSecurityShieldHeight: this.verdeSecurityShieldHeight,
                    isSaveExistContact: this.isSaveExistContact,
                    selectedCount: this.selectedCount,
                  })
                    .accessibilityLevel('no')
                    .height('100%')
                    .enabled(!this.selectedViewShow)
                    .onTouch(() => {
                      if (this.isSearchFocus) {
                        inputMethod.getController().stopInputSession().then((result) => {
                          HiLog.w(TAG, `stopInputSession result: ${result}`);
                        }).catch((err: BusinessError) => {
                          HiLog.e(TAG, `stopInputSession err: ${err.message}`);
                        });
                      }
                    });
                } else if ((this.isSearching && this.mPresenter.contactSearchCount === 0) || !this.isSearching) {
                  // 空列表
                  ContactsPickerEmptyPage({
                    isShowOnlyAccessedAlert: this.isShowOnlyAccessedAlert,
                    isShowLearnMore: this.isShowLearnMore,
                    verdeSecurityShieldHeight: this.verdeSecurityShieldHeight,
                    isSearch: this.isSearching
                  });
                } else {
                  Blank().layoutWeight(1);
                }
              }
              .width('100%');
            }
            .edgeEffect((this.isSearching && this.mPresenter.contactSearchCount > 0) ||
              (!this.isSearching && this.contactsTotal > 0) ? EdgeEffect.Spring : EdgeEffect.None)
            .scrollBar(BarState.Off)
            .width('100%')
            .height('100%');

            if (this.isVerde) {
              Row({ space: 4 }) {
                // PickerShieldAnimate({
                //   pickerType: PickerType.CONTACTS_PICKER,
                //   callerBundleName:String(this.startAbilityCallerBundleName),
                //   callerPid:String(this.callerPid),
                //   onAnimateStateChange: (animateState) => {
                //     HiLog.i(TAG, 'animateState isVerde: ' + animateState);
                //   }
                // });
              }
              .borderRadius(4)
              .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
              .padding({ left: $r('sys.float.padding_level3'), right: $r('sys.float.padding_level3') })
              .justifyContent(FlexAlign.Center)
              .constraintSize({ minHeight: '20vp' })
              .margin({ bottom: '8vp' })
              .onAreaChange((oldValue: Area, newValue: Area) => {
                let height = newValue.height as number;
                if (this.verdeSecurityShieldHeight !== height) {
                  this.verdeSecurityShieldHeight = height + 8;
                }
              });
            }

            // 查看所选择的联系人
            if (this.selectedViewShow) {
              this.selectedView();
            }
          }
          .flexShrink(1);

          // 底部工具栏区域
          this.toolBarView();
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Transparent);

      if (this.isShowLearnMore) {
        // PickerSheet({
        //   appIcon: $r('app.media.ic_public_contact_logo'),
        //   curPickerKey: PickerType.CONTACTS_PICKER,
        //   onClose: () => {
        //     this.isShowLearnMore = false;
        //   }
        // });
      }
    }
    .width('100%')
    .height('100%')
    .accessibilityLevel('no')
    .backgroundColor(Color.Transparent)
  }


  /**
   * 返回按钮点击事件处理方法
   * @returns boolean - 是否消费了返回事件
   * - 搜索状态下返回联系人列表
   * - 非UI扩展模式下处理导航栈
   * - 分屏模式下处理通话记录页面切换
   */
  private onBack(): boolean {
    this.printNavPathStackInfo(this.pathInfos)
    HiLog.w(TAG, 'onBackPress');
    if (this.isSearching) {
      this.backToListView();
      return true;
    } else if (!this.uiExtentionParam) {
      HiLog.w(TAG, 'UiExtentionParam The value is false');
      if (!this.isPC) {

        this.pathInfos?.pop();
      }
      if (AppStorage.get('isNavigationModeSplit') &&
        (AppStorage.get('mainTabsIndex') === IndexPresenter.getInstance().callIndex)) {
        HiLog.w(TAG, 'isNavigationModeSplit is true and mainTabIndex equal values callIndex');
        CallRecordPresenter.getInstance().toDefaultPage();
        return true;
      }
      return false;
    }
    return false;
  }

  private printNavPathStackInfo(navPathStack: NavPathStack): void {
  // 1. 获取栈内所有 NavPath 节点列表（入栈顺序：第一个元素是栈底，最后一个是栈顶）
  const navPathList: Array<string> = navPathStack.getAllPathName();
  // 3. 遍历栈节点（倒序输出：栈顶在前，符合直觉）
  navPathList.forEach((name: string) => {
    console.log(`- 路由路径（path）：${name}`);
  });
  console.log(`================================\n`);
}

  /**
   * 获取标题栏参数配置
   * @returns TitleBarParams - 标题栏配置参数
   * 包含样式、安全区域、标题内容和返回/关闭图标配置
   */
  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: {
  //       scrollEffectOpts: {
  //         enableScrollEffect: false
  //       },
  //       originalStyle: {
  //         backgroundStyle: {
  //           backgroundColor: $r('app.color.skin_ohos_id_color_panel_bg')
  //         }
  //       }
  //     },
  //     enableComponentSafeArea: true,
  //     avoidLayoutSafeArea: this.session === undefined,
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.select_contact')) },
  //     backIcon: this.isSearching ? { isThemeActive: this.isThemeActive, backIcon: true } :
  //       { isThemeActive: this.isThemeActive, closeIcon: true }
  //   };
  // }
}


/**
 * 联系人列表内部组件
 * 实现联系人列表的展示、字母索引、滑动多选等功能
 */
@Component
struct ContactsList {
  @Link presenter: ContactsPickerPresenter;
  @Link isShowLearnMore: boolean
  private scroller: Scroller = new Scroller();
  @State alphabetSelected: number = 0;
  @State isAlphabetClicked: boolean = false;
  @State dragList: boolean = false;
  @State alphabetIndexPresenter: AlphabetIndexerPresenter = this.presenter.alphabetIndexPresenter;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;
  @StorageLink('speedDialContact') speedDialContact: string = '';
  @State pageType: string = 'contactsListPage';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  isContactMultiSelect: boolean = true;
  // lastFirstIndex
  private lastFirstIndex: number = -1;
  // lastLastIndex
  private lastLastIndex: number = -1;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @Prop selectedCount: number = 0;
  @Prop selectedViewShow: boolean;
  @Prop isDisplayByName: boolean;
  @Prop userId: number;
  @Prop localId: number;
  @Prop verdeSecurityShieldHeight: number
  @Prop isSaveExistContact: boolean;
  @Link @Watch('alertOnChange') isShowOnlyAccessedAlert: boolean;
  @State preListItemNum: number = 1;
  @State deleteContact: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  private isPC: boolean = EnvironmentProp.isPC();
  @StorageProp('isVerde') isVerde: boolean = false;
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);


  aboutToAppear(): void {
    HiLog.w(TAG, 'aboutToAppear123');
    this.alertOnChange();
    this.slidingMultipleSelectionsUtil.isSliding = this.isContactMultiSelect;
  }

  alertOnChange() {
    if (this.isShowOnlyAccessedAlert) {
      this.preListItemNum = 2;
    } else {
      this.preListItemNum = 1;
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) { //右侧字母排序位置
      List({ initialIndex: 0, scroller: this.scroller }) {
        if (this.isShowOnlyAccessedAlert && !this.isVerde) {
          ListItem() {
            SecureAccessPopupTip({
              isShowOnlyAccessedAlert: this.isShowOnlyAccessedAlert,
              isShowLearnMore: this.isShowLearnMore
            });
          }
        }

        ListItem() {
          Row() {
            Text($r('app.string.all_contacts2'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.skin_font_secondary'))
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
              .maxFontScale(pickerMaxFontScale)

            if (this.isContactMultiSelect) {
              Text(this.presenter.allSelectMessage)
                .id('all_select_message')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.skin_font_emphasize'))
                .width('30%')
                .textAlign(TextAlign.End)
                .maxFontScale(pickerMaxFontScale)
                .accessibilityRole(AccessibilityRoleType.BUTTON)
                .layoutWeight(1)
                .onClick(() => {
                  this.presenter.selectAllOnClick();
                })
            }
          }
          .visibility((this.splitStatus === SplitStatus.ONE_THREE_SPLIT ) ||
            (this.splitStatus === SplitStatus.HALF_SPLIT) ? Visibility.None : Visibility.Visible)
          .width('100%')
          .constraintSize({
            minHeight: this.isPC ? $r('app.float.id_item_height_sm') : 56
          })
          .padding({
            left: this.isPC ? $r('sys.float.padding_level12') : this.mirrorLanguageCheck(),
            top: $r('sys.float.padding_level4'),
            right: $r('sys.float.padding_level16'),
          })
          .enabled(!this.selectedViewShow)
        }

        LazyForEach(this.presenter.favoriteSource, (item: ContactPickerListItem, index: number) => {
          ListItem() {
            ContactsPickerListItem({
              presenter: this.presenter,
              userId: this.userId,
              localId: this.localId,
              item: item,
              index: index,
              isMultiSelect: this.isContactMultiSelect,
              isDisplayByName: this.isDisplayByName,
              isSaveExistContact: this.isSaveExistContact,
              maxFontScale: pickerMaxFontScale,
              customIndexTitle: $r('app.string.favorite'),
            })
          }
        }, (item: ContactPickerListItem, index: number) => JSON.stringify(item) + JSON.stringify(index))

        //遍历位置
        LazyForEach(this.presenter.contactsSource, (item: ContactPickerListItem, index: number) => {
          ListItem() {
            ContactsPickerListItem({
              presenter: this.presenter,
              userId: this.userId,
              localId: this.localId,
              item: item,
              index: index,
              isMultiSelect: this.isContactMultiSelect,
              isDisplayByName: this.isDisplayByName,
              isSaveExistContact: this.isSaveExistContact,
              maxFontScale: pickerMaxFontScale,
            })
          }
        }, (item: ContactPickerListItem, index: number) => JSON.stringify(item) + JSON.stringify(index))
      }
      .accessibilityLevel('no')
      .width('100%')
      .height('100%')
      .contentEndOffset(this.isVerde ? this.verdeSecurityShieldHeight : 0)
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .onScrollIndex((firstIndex: number, lastIndex: number) => {
        this.slidingMultipleSelectionsUtil.scrollStartIndex = firstIndex;
        this.slidingMultipleSelectionsUtil.scrollEndIndex = lastIndex;

        if (firstIndex === this.lastFirstIndex && lastIndex === this.lastLastIndex) {
          return
        }
        this.lastFirstIndex = firstIndex;
        this.lastLastIndex = lastIndex;
        const contactFirstIndex = firstIndex <= this.preListItemNum ? 0 : firstIndex - this.preListItemNum;
        const contactLastIndex = lastIndex <= this.preListItemNum ? 0 : lastIndex - this.preListItemNum;
        let curIndex = this.alphabetIndexPresenter.getAlphabetSelected(contactFirstIndex);
        if (this.alphabetSelected !== curIndex) {
          this.alphabetSelected = curIndex;
        }
      })
      .onScrollStart(() => {
        emitter.emit(AlphabetIndexerPage.innerEvent);
        this.dragList = true;
        this.isAlphabetClicked = false;
      })
      .onScrollStop(() => {
        this.isAlphabetClicked = true;
        this.dragList = false;
      })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARALLEL,
        scrollBackward: NestedScrollMode.PARALLEL
      })
      .gesture(PanGesture({ direction: PanDirection.Vertical })
        .onActionStart((event: GestureEvent) => {
          for (let i = 0; i < this.preListItemNum; ++i) {
            this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = false;
            this.slidingMultipleSelectionsUtil.curSelectStatus[i] = false;
          }

          for (let i = 0; i < this.presenter.favoriteSource.totalCount(); ++i) {
            let index = i + this.preListItemNum;
            let item = this.presenter.favoriteSource.getData(i);
            let selectStatus = this.presenter.selectedContactsMap.get(item?.contactId)?.has(
              item?.pickerShowSubData.keyValue) ?? false;
            this.slidingMultipleSelectionsUtil.oldSelectStatus[index] = selectStatus;
            this.slidingMultipleSelectionsUtil.curSelectStatus[index] = selectStatus;
          }

          for (let i = 0; i < this.presenter.contactsSource.totalCount(); ++i) {
            let index = i + this.preListItemNum + this.presenter.favoriteSource.totalCount();
            let item = this.presenter.contactsSource.getData(i);
            let selectStatus = this.presenter.selectedContactsMap.get(item?.contactId)?.has(
              item?.pickerShowSubData.keyValue) ?? false;
            this.slidingMultipleSelectionsUtil.oldSelectStatus[index] = selectStatus;
            this.slidingMultipleSelectionsUtil.curSelectStatus[index] = selectStatus;
          }

          this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
        })
        .onActionUpdate((event: GestureEvent) => {
          if (this.selectedCount >= this.presenter.selectLimit) {
            this.slidingMultipleSelectionsUtil.isStopScroll = true;
            this.slidingMultipleSelectionsUtil.stopScroll();
          } else {
            this.slidingMultipleSelectionsUtil.isStopScroll = false;
          }

          let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
            let curSelectStatus = false;
            if (index >= this.preListItemNum) {
              index -= this.preListItemNum;
              if (index >= this.presenter.favoriteSource.totalCount()) {
                index -= this.presenter.favoriteSource.totalCount();
                let item = this.presenter.contactsSource.getData(index);
                curSelectStatus = this.presenter.selectedContactsMap.get(item?.contactId)?.has(
                  item?.pickerShowSubData.keyValue) ?? false;
              } else {
                let item = this.presenter.favoriteSource.getData(index);
                curSelectStatus = this.presenter.selectedContactsMap.get(item?.contactId)?.has(
                  item?.pickerShowSubData.keyValue) ?? false;
              }
            }
            return curSelectStatus;
          });
          updateIndexes.forEach((index) => {
            if (index >= this.preListItemNum) {
              index -= this.preListItemNum;
              if (index >= this.presenter.favoriteSource.totalCount()) {
                index -= this.presenter.favoriteSource.totalCount();
                let item = this.presenter.contactsSource.getData(index);
                this.presenter.itemOnClick(
                  item?.contactId, item?.pickerShowSubData.keyValue, item?.pickerShowSubData.dataId);
              } else {
                let item = this.presenter.favoriteSource.getData(index);
                this.presenter.itemOnClick(
                  item?.contactId, item?.pickerShowSubData.keyValue, item?.pickerShowSubData.dataId);
              }
            }
          })
        })
        .onActionEnd(() => {
          this.slidingMultipleSelectionsUtil.onActionEnd();
        })
        .onActionCancel(() => {
          this.slidingMultipleSelectionsUtil.onActionEnd();
        }),
        GestureMask.Normal
      )
      .onGestureRecognizerJudgeBegin(
        (event: BaseGestureEvent, current: GestureRecognizer, recognizers: Array<GestureRecognizer>) => {
          return this.slidingMultipleSelectionsUtil.onGestureRecognizerJudgeBegin(event.fingerList[0], current);
        })
      .onAreaChange((oldValue: Area, newValue: Area)=>{
        this.slidingMultipleSelectionsUtil.listWidth = newValue.width as number
        this.slidingMultipleSelectionsUtil.areaY = newValue.globalPosition.y as number;
        this.slidingMultipleSelectionsUtil.contentHeight = newValue.height as number;
      })

      if (DisplaySplitUtil.isShowIndex(this.splitStatus)){
        AlphabetIndexerPage({
          scroller: this.scroller,
          needPop: !this.isVerde,
          favoriteIndexerPresenter: this.alphabetIndexPresenter,
          selected: this.alphabetSelected,
          isClicked: $isAlphabetClicked,
          isAutoCollapse: true,
          preIndexNum: this.preListItemNum,
          scrollIndexOffset: false,
          hasFavorite: true,
        })
          .id('picker_contacts_alphabetIndexer_alphabetIndexerPage')
          .width('24vp')
          .margin({
            top: $r('sys.float.padding_level8'),
            left: $r('sys.float.padding_level2'),
            right: $r('sys.float.padding_level2'),
          })
      }
    }
    .width('100%')
  }

  private mirrorLanguageCheck(): Length | undefined {
    if (i18n.System.getSystemLanguage() === 'ug' || i18n.System.getSystemLanguage() === 'ar') {
      return $r('sys.float.padding_level12');
    } else {
      return $r('sys.float.padding_level8');
    }
  }
}


@Component
struct ContactsPickerEmptyPage {
  @Link isShowOnlyAccessedAlert: boolean;
  @Link isShowLearnMore: boolean
  @Prop verdeSecurityShieldHeight: number
  @Prop isSearch: boolean = false
  @StorageProp('isVerde') isVerde: boolean = false;

  build() {
    Column() {
      // if (!this.isSearch && this.isShowOnlyAccessedAlert && !this.isVerde) {
      //   SecureAccessPopupTip({
      //     isShowOnlyAccessedAlert: this.isShowOnlyAccessedAlert,
      //     isShowLearnMore: this.isShowLearnMore
      //   })
      // }
      ContactEmptyPage()
      // PafEmptyPage({
      //   icon: this.isSearch ? $r('app.media.no_result') : $r('app.media.ic_empty_page_no_contacts'),
      //   emptyDescription: this.isSearch ? $r('app.string.contact_search_result_empty') : $r('app.string.no_contacts'),
      //   descriptionFontColor: ($r('app.color.skin_font_tertiary')),
      //   fullPage: true,
      //   customBackgroundColor: Color.Transparent,
      // })
      //   .layoutWeight(1)
      //   .margin(this.isVerde ? { bottom: this.verdeSecurityShieldHeight } : null)
    }
    .layoutWeight(1)
    .width('100%')
  }
}


@Component
struct SecureAccessPopupTip {
  @Link isShowLearnMore: boolean
  private uiExtentionParam = ContactsGlobalThisHelper.GetGlobalThis()
    .getValue<UiExtentionParam>(ContactsGlobalThisHelper.UiExtentionAbilityParams);
  @Link isShowOnlyAccessedAlert: boolean;
  private isPC: boolean = EnvironmentProp.isPC();
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Start,
      justifyContent: FlexAlign.SpaceBetween
    }) {

      Stack({ alignContent: Alignment.BottomEnd }) {
        Image($r('app.media.ic_contact_shield'))
          .width('app.float.rounded_corners_width_32')
          .height('app.float.rounded_corners_width_32')
          .draggable(false)
          .zIndex(1)

        Image($r('app.media.ic_contact_icon'))
          .width(14)
          .height(14)
          .objectFit(ImageFit.Contain)
          .zIndex(2)
      }
      .flexShrink(0)
      .width(32)
      .height(32)
      .margin({
        end: LengthMetrics.resource($r('sys.float.padding_level6'))
       })

      Column() {
        Flex({
          direction: FlexDirection.Row,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text($r('app.string.secure_access_title'))
            .lineHeight(19)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontColor($r('app.color.skin_font_primary'))
            .fontWeight(FontWeight.Medium)
            .flexShrink(1)
            .maxLines(2)
            .textAlign(TextAlign.Start)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxFontScale(pickerMaxFontScale)

          Button() {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize('18vp')
              .fontColor([$r('sys.color.ohos_id_color_titlebar_icon')])
          }
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .width(18)
          .height(18)
          .onClick(() => {
            let list: string[] = AppStorage.get('showAccessedList') as string[];
            let name: string = this.uiExtentionParam?.callerBundleName ?? '';
            HiLog.w(TAG, `SecureAccessPopupTip xmark onClick, name: ${name}`);
            if (!StringUtil.isEmpty(name) && name !== 'com.ohos.contacts') {
              list.push(name);
              AppStorage.setOrCreate('showAccessedList', list);
              this.isShowOnlyAccessedAlert = false;
            }
          })
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.shut_down')))
        }

        Text() {
          Span($r('app.string.contacts_picker_banner', ''))
          Span($r('app.string.learn_more'))
            .fontColor($r('sys.color.ohos_id_text_color_active'))
            .onClick(() => {
              HiLog.w(TAG, `showMoreInfoDialog onClick!`);
              this.isShowLearnMore = true;
            })
        }
          .alignSelf(ItemAlign.Stretch)
          .lineHeight(19)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('app.color.skin_font_secondary'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: $r('sys.float.padding_level1') })
          .textAlign(TextAlign.Start)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxFontScale(pickerMaxFontScale)
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .alignSelf(ItemAlign.Stretch)
    .flexShrink(1)
    .constraintSize({ minHeight: 84 })
    .margin({
      start: this.isPC ? LengthMetrics.resource($r('sys.float.padding_level12')) :
      LengthMetrics.resource($r('sys.float.padding_level8')),
      end: LengthMetrics.resource($r('sys.float.padding_level12')),
      top: LengthMetrics.resource($r('sys.float.padding_level4')),
      bottom: LengthMetrics.resource($r('sys.float.padding_level6'))
    })
    .padding($r('sys.float.padding_level6'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }
}


@Component
struct ContactsPickerSearch {
  @Link presenter: ContactsPickerPresenter;
  @Prop userId: number;
  @Prop localId: number;
  @Prop maxFontScale: number | null = null;
  @Prop isMultiSelect: boolean;
  @Prop isDisplayByName: boolean;
  @Prop selectedCount: number = 0;
  @Prop verdeSecurityShieldHeight: number
  @Prop isSaveExistContact: boolean;
  @Prop selectedViewShow: boolean;
  @State deleteContact: boolean = false;
  @Link isShowOnlyAccessedAlert: boolean;
  @Link isShowLearnMore: boolean
  @StorageProp('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isVerde') isVerde: boolean = false;
  private scroller: Scroller = new Scroller();
  private slidingMultipleSelectionsUtil: SlidingMultipleSelectionsUtil =
    new SlidingMultipleSelectionsUtil(this.scroller, 56);

  aboutToAppear() {
    HiLog.w(TAG, `ContactsPickerSearch aboutToAppear`);
    this.slidingMultipleSelectionsUtil.isSliding = this.isMultiSelect;
  }

  aboutToDisappear() {
    HiLog.w(TAG, `ContactsPickerSearch aboutToDisappear`);
  }


  build() {
    Flex({ direction: FlexDirection.Column }) {
      List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
        LazyForEach(this.presenter.searchContactsSource, (item: ContactPickerListItem, index: number) => {
          ListItem() {
            ContactsPickerListItem({
              presenter: this.presenter,
              userId: this.userId,
              localId: this.localId,
              item: item,
              index: index,
              isMultiSelect: this.isMultiSelect,
              isDisplayByName: this.isDisplayByName,
              isSaveExistContact: this.isSaveExistContact,
              maxFontScale: pickerMaxFontScale,
              customIndexTitle: $r('app.string.contact'),
              isSearch: true,
            })
          }
          .id('ContactSearch_.Contacts_SearchResultClick_ListItem')
        }, (item: ContactPickerListItem, index: number) => JSON.stringify(item) + JSON.stringify(index))
      }
      .divider({
        color: $r('app.color.skin_comp_divider'),
        strokeWidth: '1px',
        startMargin: $r('app.float.id_records_divider_margin_left'),
        endMargin: $r('sys.float.padding_level16')
      })
      .scrollBar(BarState.Off)
      .height('100%')
      .width('100%')
      .listDirection(Axis.Vertical)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARALLEL,
        scrollBackward: NestedScrollMode.PARALLEL
      })
      .contentEndOffset(this.isVerde ? this.verdeSecurityShieldHeight : 0)
      .onScrollIndex((firstIndex: number, lastIndex: number) => {
        this.slidingMultipleSelectionsUtil.scrollStartIndex = firstIndex;
        this.slidingMultipleSelectionsUtil.scrollEndIndex = lastIndex;
      })
      .gesture(PanGesture({ direction: PanDirection.Vertical })
        .onActionStart((event: GestureEvent) => {
          for (let i = 0; i < this.presenter.searchContactsSource.totalCount(); ++i) {
            let item = this.presenter.searchContactsSource.getData(i);
            let selectStatus = this.presenter.selectedContactsMap.get(item?.contactId)?.has(
              item?.pickerShowSubData.keyValue) ?? false;
            this.slidingMultipleSelectionsUtil.oldSelectStatus[i] = selectStatus;
            this.slidingMultipleSelectionsUtil.curSelectStatus[i] = selectStatus;
          }
          this.slidingMultipleSelectionsUtil.onActionStart(event.fingerList[0]);
        })
        .onActionUpdate((event: GestureEvent) => {
          if (this.selectedCount >= this.presenter.selectLimit) {
            this.slidingMultipleSelectionsUtil.isStopScroll = true;
            this.slidingMultipleSelectionsUtil.stopScroll();
          } else {
            this.slidingMultipleSelectionsUtil.isStopScroll = false;
          }

          let updateIndexes = this.slidingMultipleSelectionsUtil.onActionUpdate(event.fingerList[0], (index) => {
            let curSelectStatus = false;
            if (index >= 0) {
              let item = this.presenter.searchContactsSource.getData(index);
              curSelectStatus = this.presenter.selectedContactsMap.get(item?.contactId)?.has(
                item?.pickerShowSubData.keyValue) ?? false;
            }
            return curSelectStatus;
          });
          updateIndexes.forEach((index) => {
            if (index >= 0) {
              let item = this.presenter.searchContactsSource.getData(index);
              this.presenter.itemOnClick(
                item?.contactId, item?.pickerShowSubData.keyValue, item?.pickerShowSubData.dataId);
            }
          })
        })
        .onActionEnd(() => {
          this.slidingMultipleSelectionsUtil.onActionEnd();
        })
        .onActionCancel(() => {
          this.slidingMultipleSelectionsUtil.onActionEnd();
        }),
        GestureMask.Normal
      )
      .onGestureRecognizerJudgeBegin(
        (event: BaseGestureEvent, current: GestureRecognizer, recognizers: Array<GestureRecognizer>) => {
          return this.slidingMultipleSelectionsUtil.onGestureRecognizerJudgeBegin(event.fingerList[0], current);
        })
      .onAreaChange((oldValue: Area, newValue: Area)=>{
        this.slidingMultipleSelectionsUtil.listWidth = newValue.width as number
        this.slidingMultipleSelectionsUtil.areaY = newValue.globalPosition.y as number;
        this.slidingMultipleSelectionsUtil.contentHeight = newValue.height as number;
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.skin_ohos_id_color_panel_bg'))
  }
}


@Component
@Reusable
struct ContactsPickerListItem {
  @Link presenter: ContactsPickerPresenter;
  @Prop userId: number;
  @Prop localId: number;
  @Prop item: ContactPickerListItem;
  @Prop index: number;
  @Prop isMultiSelect: boolean;
  @Prop isDisplayByName: boolean;
  @Prop isSaveExistContact: boolean;
  @Prop maxFontScale: number | null = null;
  @Prop customIndexTitle: string | Resource | null = null;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State checkedSet: Set<string> = new Set();
  @State photoPixelMap: PixelMap | null = null;
  @State isSearch: boolean = false;
  @State onlyShowChecked: boolean = false;
  @State hoverBackgroundColor: ResourceColor = Color.Transparent;
  // @Link deleteContact: boolean;
  private isPc: boolean = EnvironmentProp.isPC();

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .width('100%')
    .opacity(1)
  }

  updateInfo() {
    this.checkedSet = this.presenter.selectedContactsMap.get(this.item.contactId) ?? new Set();
    getPixelMapFromFileForContactPicker(this.item.contactId.toString(), this.localId, this.userId,
      (res: PixelMap | null) => {
        this.photoPixelMap = res;
      }, ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext(), false)
  }

  aboutToAppear() {
    emitter.on(ContactsPickerPresenter.BATCH_SELECT_ITEM_CHECKED, (eventData: emitter.EventData) => {
      let contactId = eventData.data?.contactId as number;

      if (!this.isMultiSelect || !contactId || this.item.contactId === contactId) {
        this.checkedSet = this.presenter.selectedContactsMap.get(this.item.contactId) ?? new Set();
      }
    })
    this.updateInfo();
    HiLog.i(TAG,`ContactsPickerListItem headChar:${this.item.headChar}, namePrefix:${this.item.namePrefix}
    ,isSearch:${this.isSearch}`)
  }

  aboutToReuse(): void {
    this.updateInfo();
  }

  aboutToRecycle(): void {
  }

  aboutToDisappear(): void {
  }


  build() {
    Column(){
      if (this.customIndexTitle !== '' &&
        ((this.customIndexTitle !== null && this.index === 0) ||
          (this.customIndexTitle === null && this.item.showIndex))) {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.End,
          alignItems: ItemAlign.Start
        }) {
          Text(this.customIndexTitle === null ? this.item.namePrefix : this.customIndexTitle)
            .fontColor($r('app.color.skin_ohos_fa_text_secondary'))
            .fontSize($r('sys.float.Subtitle_S'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .maxFontScale(pickerMaxFontScale)
        }
        .padding({ left: this.spaceLR, right: this.spaceLR, bottom: $r('app.float.id_card_margin_large') })
        .width('100%')
        .height(this.isPc ? $r('app.float.id_item_height_sm' ) : $r('app.float.id_item_height_large'))
      }

      Row() {
        Row() {
          if (this.photoPixelMap) {
            Image(this.photoPixelMap)
              .width($r('app.float.id_card_image_mid'))
              .height($r('app.float.id_card_image_mid'))
              .objectFit(ImageFit.Auto)
              .borderRadius($r('app.float.id_card_image_mid'))
              .draggable(false)
              .onError(() => {
                this.photoPixelMap?.release();
                this.photoPixelMap = null
              })
          } else if (StringUtil.isEmpty(this.item.headChar)) {
            Image($r('app.media.ic_user_portrait'))
              .width($r('app.float.id_card_image_mid'))
              .height($r('app.float.id_card_image_mid'))
              .objectFit(ImageFit.Auto)
              .borderRadius($r('app.float.id_card_image_mid'))
              .fillColor($r('app.color.skin_ohos_id_color_text_primary_contrary'))
              .backgroundColor($r('app.color.skin_ohos_id_color_fourth'))
              .draggable(false)
          } else {
            Text(this.item.headChar)
              .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ?
              $r('sys.float.Body_L') : $r('app.float.id_width_16'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.skin_font_on_primary'))
              .backgroundColor($r('app.color.skin_icon_fourth'))
              .height($r('app.float.id_card_image_mid'))
              .width($r('app.float.id_card_image_mid'))
              .textAlign(TextAlign.Center)
              .borderRadius($r('app.float.id_card_image_mid'))
              .maxFontScale(this.maxFontScale)
              .accessibilityLevel('no')
          }
        }
        .width($r('app.float.id_card_image_mid'))
        .height($r('app.float.id_card_image_mid'))
        .id('portrait')
        .visibility(this.item.isFirst ? Visibility.Visible : Visibility.Hidden)

        Column({ space: 2 }) {
          if (this.item.isFirst) {
            Text(this.isSearch ? '' : this.item.displayName) {
              if (this.isSearch) {
                ForEach(NameDisposal.charEscape(this.item.displayName.replace(hasComma, COMMA_REPLACE).
                split(labelMatch)), (items: string, index: number) => {
                    if (!(items === 'em' || items === '/em')) {
                      if (index != 0) {
                        if (this.item.displayName.split(labelMatch)[index - 1] === 'em') {
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
                  }, (item: string, index: number) => JSON.stringify(item) + JSON.stringify(index))
              }
            }
            .fontColor($r('app.color.skin_font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            .id('name')
            .maxFontScale(this.maxFontScale)
            .wordBreak(WordBreak.BREAK_ALL)
            .constraintSize({ minHeight: '21vp' })
          }

          if (this.isDisplayByName || StringUtil.isEmpty(this.item.pickerShowSubData.keyValue)) {

          } else if (this.isSearch) {
            Text() {
              ForEach(Array.from(this.item.pickerShowSubData.showValue as string), (item: string, index: number) => {
                if (this.item.highLight && index >= this.item.highLight[0] && index <= this.item.highLight[1]) {
                  Span(item)
                    .fontColor($r('app.color.skin_font_emphasize'))
                } else {
                  Span(item)
                    .fontColor($r('app.color.skin_ohos_fa_text_primary'))
                }
              }, (item: string, index: number) => JSON.stringify(this.item.pickerShowSubData.showValue as string) +
              JSON.stringify(index) + this.item.highLight?.toString())
            }
            .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
            .direction(Direction.Ltr)
            .fontColor($r('app.color.skin_font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
            .id('phone')
            .maxFontScale(this.maxFontScale)
          } else {
            Text() {
              Span(this.item.pickerShowSubData.showValue)
              Span('  ' + this.item.pickerShowSubData.keyValue)
            }
              .fontColor($r('app.color.skin_font_secondary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 2 : 10)
              .id('phone')
              .maxFontScale(this.maxFontScale)
              .constraintSize({ minHeight: '19vp' })
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .margin(this.isPc ? {
          top: 0,
          bottom: 0
        } : {
          top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
            0, $r('app.float.dialer_button_text_font_size')),
          bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
            0, $r('app.float.dialer_button_text_font_size')),
          right: $r('sys.float.padding_level4')
        })
        .padding({ start: LengthMetrics.resource($r('sys.float.padding_level8')) })

        if (!this.isSaveExistContact) {
          Toggle({
            type: ToggleType.Checkbox,
            isOn: this.checkedSet.has(this.item.pickerShowSubData.keyValue)
          })
            .width(20)
            .height(20)
            .accessibilityLevel('no')
            .margin($r('sys.float.padding_level1'))
            .hitTestBehavior(HitTestMode.None)
            .visibility((!this.isMultiSelect && this.checkedSet.has(this.item.pickerShowSubData.keyValue) ||
            this.isMultiSelect) ? Visibility.Visible : Visibility.Hidden)
            .selectedColor($r('app.color.skin_comp_background_emphasize'))
            .id('toggle')
            .onKeyEvent((event: KeyEvent) => {
              if (event.keyCode === KeyCode.KEYCODE_ENTER && event.type === KeyType.Down) {
                this.presenter.itemOnClick(
                  this.item.contactId, this.item.pickerShowSubData.keyValue, this.item.pickerShowSubData.dataId);
                if (this.onlyShowChecked) {
                  this.presenter.initSelectedDataSource();
                }
              }
            })
            .onClick(() => {
              this.presenter.itemOnClick(
                this.item.contactId, this.item.pickerShowSubData.keyValue, this.item.pickerShowSubData.dataId);
              if (this.onlyShowChecked) {
                this.presenter.initSelectedDataSource();
              }
            })
        }
      }
      .width('100%')
      .height(this.isPc ? (this.item.isFirst ? $r('app.float.id_item_height_large') :
        $r('app.float.id_item_height_sm')) : undefined)
      .constraintSize({
        minHeight: this.isPc ? (this.item.isFirst ? $r('app.float.id_item_height_large') :
          $r('app.float.id_item_height_sm')) :
          (this.item.isFirst ? $r('app.float.id_item_height_max') :
          $r('app.float.id_item_height_mid'))
      })
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles
      })
      .padding({
        end: LengthMetrics.resource($r('sys.float.padding_level16')),
        start: LengthMetrics.resource(this.spaceLR)
      })
      .accessibilityDescription((!this.isMultiSelect && this.checkedSet.has(this.item.pickerShowSubData.keyValue)) ? ' ' : '')
      .accessibilityRole((!this.isMultiSelect && this.checkedSet.has(this.item.pickerShowSubData.keyValue) ||
      this.isMultiSelect) ? AccessibilityRoleType.CHECKBOX : undefined)
      .accessibilityChecked(this.isMultiSelect ? this.checkedSet.has(this.item.pickerShowSubData.keyValue):
        this.checkedSet.has(this.item.pickerShowSubData.keyValue) ? true: undefined)
      .onClick(() => {
        HiLog.i(TAG, 'itemOnClick这里点击了选择联系人列表中的项');
        this.presenter.itemOnClick(
          this.item.contactId, this.item.pickerShowSubData.keyValue, this.item.pickerShowSubData.dataId);
        if (this.onlyShowChecked) {
          this.presenter.initSelectedDataSource();
        }
      })
      .backgroundColor(this.hoverBackgroundColor)
      .onHover((isHover: boolean) => {
        if (isHover) {
          this.hoverBackgroundColor = $r('app.color.skin_interactive_click');
        } else {
          this.hoverBackgroundColor = Color.Transparent;
        }
      })

      if (this.item.showDivifer) {
        Divider()
          .color($r('app.color.skin_comp_divider'))
          .strokeWidth('1px')
          .margin({
            left: $r('app.float.id_records_divider_margin_left'),
            right: $r('sys.float.padding_level16')
          })
      }
    }
  }
}

//标题需要的变量类
class TitleVariableClass {
  // 是否启动主题
  public isThemeActive: boolean = false;
  // 是否启动无障碍
  public isOpenAccessibility: boolean = false;
  public fontSizeScale: number = 0;
  public isSearching: boolean = false;
  public isGettingPickerData: boolean = false;
  public isUEC: boolean = false;
}

//标题需要的方法类
class TitleMethodClass {
  //返回按钮操作
  public backOnClick = () => {
  }
  //关闭按钮操作
  public closeOnClick = () => {
  }
}

let titleMethodClass = new TitleMethodClass()

@Builder
export function PickerTitleView($$: TitleVariableClass) {
  Row() {
    Row({ space: 8 }) {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize($r('app.float.id_card_margin_max'))
          .fontColor([$r('app.color.skin_ohos_id_color_primary')])
          .draggable(false)
          .visibility($$.isSearching ? Visibility.Visible : Visibility.None)
      }
      .onClick(() => {
        HiLog.w(TAG, 'onBackButtonClick');
        titleMethodClass.backOnClick();
      })
      .accessibilityText(ContactsGlobalThisHelper.GetGlobalThis()
        .getDefaultUIContext()
        .resourceManager
        .getStringSync($r('app.string.accessibility_back').id))
      .width(40)
      .height(40)
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
      .transition(TransitionEffect.asymmetric(
        TransitionEffect.OPACITY.animation({
          duration: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), delay: 100
        }),
        TransitionEffect.OPACITY.animation({
          duration: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
        })
      ))
      .id('contactList_contacts_back_arrowBack')
      .visibility($$.isSearching ? Visibility.Visible : Visibility.None)

      Text($r('app.string.select_contact'))
        .fontSize(FontScaleState.isStandardGeer($$.fontSizeScale) ?
        $r('sys.float.Title_S') : $r('app.float.id_card_image_s'))
        .fontColor($r('app.color.skin_font_primary'))
        .fontWeight(FontWeight.Bold)
        .id('select_contact_title')
        .margin({
          right: EnvironmentProp.isPC() ? '24vp' : undefined,
          left: EnvironmentProp.isPC() ? '8vp' : undefined
        })
    }

    WithTheme($$.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(EnvironmentProp.isPC() ? '24vp' : '18vp')
          .fontColor([$r('app.color.skin_ohos_id_color_primary')])
      }
      .id('close_click_btn')
      .width(40)
      .height(40)
      .backgroundColor(EnvironmentProp.isPC() ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal'))
      .draggable(false)
      .onClick(() => {
        titleMethodClass.closeOnClick();
      })
      .enabled(!$$.isGettingPickerData)
      .accessibilityText(AccessibilityUtil.getInstance()
        .setAccessibilityText($$.isOpenAccessibility, $r('app.string.shut_down')))
    }
  }
  .padding($$.isUEC ? { left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') } : null)
  .justifyContent(FlexAlign.SpaceBetween)
  .alignItems(VerticalAlign.Center)
  .constraintSize({
    minHeight: $r('app.float.id_item_height_large')
  })
  .flexShrink(0)
  .width('100%')
  .margin({ top: $$.isUEC ? $r('sys.float.padding_level4') : $r('sys.float.padding_level0')})
}