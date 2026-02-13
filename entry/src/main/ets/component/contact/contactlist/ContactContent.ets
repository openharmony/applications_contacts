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

import { CachedContactsPixelMapType, CustomizedParams } from '../../../model/type';
import AlphabetIndexerPresenter from '../../../presenter/contact/alphabetindex/AlphabetIndexerPresenter';
import ContactListPresenter from '../../../presenter/contact/ContactListPresenter';
import { taskpool } from '@kit.ArkTS';
// import SearchClient from '../../../search/search';
import { HiLog, StringUtil } from '../../../../../../../common';
import { curves, LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import DotUtil from '../../../util/DotUtil';
import { AlphabetIndexerPage } from '../../../pages/contacts/alphabetindex/AlphabetIndexerPage';
import { ContactSearch } from '../../../pages/contacts/search/ContactSearch';
import ContactListItemView from '../ContactListItemView';
import { emitter } from '@kit.BasicServicesKit';
import { ContactListBoModel } from '../../../model/ContactListBoModel';
import ContactListShowInfo from '../../../model/bean/ContactListShowInfo';
import { ArrowBack } from './ArrowBack';
import EmitterConstant from '../../../data/EmitterConstant';
import IndexPresenter from '../../../presenter/IndexPresenter';
import { SearchUtil } from '../../../util/SearchUtil';
import { dataSharePredicates, unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import dataShare from '@ohos.data.dataShare';
import { ContactRepository } from '../../../../../../../feature/contact/src/main/ets/repo/ContactRepository'
import { Contacts } from '../../../../../../../feature/contact/src/main/ets/contract/Contacts';
import ContactListItem from '../../../../../../../feature/contact/src/main/ets/repo/ContactListItem';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { DisplaySplitUtil, SplitStatus } from '../../../util/DisplaySplitUtil';
import { Popup, PopupTextOptions, PopupButtonOptions } from '@kit.ArkUI';
import { sharedPreferencesUtils } from '../../../../../../../common';
import { i18n } from '@kit.LocalizationKit';
import EnvironmentProp from '../../../feature/EnvironmentProp';
import { PixelMapManager } from '../../../util/UserPhoto';
import { SystemModeController } from '../../../util/SystemModeController';

const TAG = 'ContactContent  ';
const NUMBER_ZERO: number = 0;
const NUMBER_ONE: number = 1;
const NUMBER_TWO: number = 2;
const TITLE_HEIGHT: number = 56;
const NUMBER_FIFTY_EIGHT: number = 56;
const NUMBER_TWENTY_EIGHT: number = 28;
const NUMBER_TEN: number = 10;
const CLICK_SEARCH_BAR_EVENT: string = 'CLICK_SEARCH_BAR_EVENT';
const CONTACT_CONTENT: string = 'CONTACT_CONTENT';
// 生日横幅和云空间卡片占位，导致list计算index会把占位数量加上，应该去掉占位数量；层叠布局，搜索框消失后，多去掉一个占位数量，让列表再上移一位
const SEARCH_LIST_PLACEHOLDER_NUMBER: number = 2;
const NO_SEARCH_LIST_PLACEHOLDER_NUMBER: number = 3;
// 状态栏+MINI模式标题栏
const NUMBER_NINETY_FOUR_EIGHT: number = 94;

/**
 * 联系人tab内容页面
 */
@Component
export struct ContactContent {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State private showSubHeaderIndex: Number = 0;
  @Link presenter: ContactListPresenter;
  @Link private contactListListLen: number;
  // 是否查找联系人
  @StorageLink('isContactSearch') isContactSearch: boolean = false;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 刷新
  @StorageLink('refreshing') refreshing: boolean = false;
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  // 监听搜索框是否显示
  @StorageLink('isShowSearch') isShowSearch: boolean = true;
  @Link private navigationMenusOpacity: number;
  @State isPull: boolean = false;
  private scroller: Scroller = new Scroller();
  @StorageLink('mainTabsIndex') mainTabsIndex: number = 0;

  // 滑动列表，页面首个联系人变化，选中的二级索引需要变化
  @Link alphabetSelected: number;
  // 是否点击了二级索引
  @Link isAlphabetClicked: boolean;
  @Link searchValueLength: number;
  alphabetIndexPresenter: AlphabetIndexerPresenter = this.presenter.alphabetIndexPresenter;
  private isPC: boolean = EnvironmentProp.isPC();
  downY: number = 0;
  lastMoveY: number = 0;
  isFirstListItem = true;
  private lastFirstIndex: number = -1;
  private lastLastIndex: number = -1;
  @StorageLink('selectContactId') selectContactId: string = '';
  @StorageLink('contactsList_y') @Watch('contactsListyChange') contactsListY: number = 0;
  customParams: CustomizedParams = {};

  @Link stages:number;
  @Link searchOffsetY: number;
  prevSearchOffsetY: number = 0;
  scrollReachEnd: boolean = false;
  hasCard: boolean = false;
  @State myCardEmptyShowInfo: ContactListShowInfo = new ContactListShowInfo(false, true, '', '', '', '', '', '', '');

  // 联系人读取日历弹框及横幅
  @State inShowCalendar: boolean = false;
  @State showBirthdayBanners: boolean = false;
  @State isSelectSearchShow: boolean = true;
  @State isPopupSelectSearchShow: boolean = false;
  @StorageProp('currentColorMode') currentColorMode: number = 1;
  // 缓存的联系人下标
  @State cachedIndex: Array<number> = [0, 0];
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageLink('hideIndexTitleTabBar') hideIndexTitleTabBar: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  @State preListItemNum: number = 0;
  @StorageProp('contactSearchNumber') contactSearchNumber: number = 0;

  // 畅连
  @StorageProp('isFromMeetime') isFromMeetime: boolean = false;
  @StorageProp('isMeetimePC') isMeetimePC: boolean = false;
  @StorageLink('displaySyncCard') displaySyncCard: Visibility = Visibility.None;
  // 键盘高度
  @LocalStorageProp('keyBoardHeightPx') @Watch('updateListHeight') keyBoardHeight: number = 0;
  @State offSetY: number = 0;
  @StorageLink('isShowSmartWindow') isShowSmartWindow: boolean = false;

  // 点击搜索按钮 和 返回按钮时 校准索引
  @StorageLink('calibrationAlphabetIndex') @Watch('onCalibrationAlphabetIndex') calibrationAlphabetIndex: number = -1;
  @State calibrationHeight: number = 0;
  @Link isReBindScroll: boolean;

  onCalibrationAlphabetIndex() {
    HiLog.w(TAG, 'onCalibrationAlphabetIndex is:' + this.calibrationAlphabetIndex)
    if (this.calibrationAlphabetIndex == 0 || this.calibrationAlphabetIndex == 2) {
      this.calibrationHeight = this.isPC ? 0 : 94;
    } else if (this.calibrationAlphabetIndex == 1 || this.calibrationAlphabetIndex == 3) {
      this.calibrationHeight = 0;
    } else {
      this.calibrationHeight = 0;
    }
  }

  aboutToAppear() {
    HiLog.w(TAG, `aboutToAppear ${this.isFromMeetime},${this.isReBindScroll}`);
    this.isReBindScroll = !this.isReBindScroll;
    this.presenter.onNewContactToIndex = (newContactId: string, newContactIndex: number) => {
      if (this.curBp != 'sm') {
        this.selectContactId = newContactId;
        this.scroller.scrollToIndex(newContactIndex, false, ScrollAlign.CENTER);
      }
    }
    if (this.mainTabsIndex === IndexPresenter.getInstance().contactIndex) {
      IndexPresenter.getInstance().emitDefaultSelectedContact();
    }

    const strMyCard = ResourceUtil.getStringByResource($r('app.string.my_card'));
    const strClickToEdit = ResourceUtil.getStringByResource($r('app.string.click_to_edit_card'));
    this.myCardEmptyShowInfo =
      new ContactListShowInfo(false, true, '', '', '', '', '', strMyCard, strClickToEdit)
    this.checkCalendarPermission();
    emitter.on(EmitterConstant.UPDATE_SHOW_BIRTHDAY_BANNERS_EMITTER_ID, async () => {
      HiLog.i(TAG, 'emitter on, update showBirthdayBanners!');
      this.showBirthdayBanners = await sharedPreferencesUtils.getFromPreferences('showBirthdayBanners', false) as boolean;
    });

    if (this.isFromMeetime) {
      sharedPreferencesUtils.saveToPreferences('showBirthdayBanners', false);
    }
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.CONTACT_LIST_CACHE_UPDATE,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(innerEvent, () => {
      this.cacheCurrentPageAvatars();
    });
    this.cacheCurrentPageAvatars();
  }

  isNeedAutoCollapse() {
    if (this.isVerde) {
      return true;
    }
    if (this.splitStatus === SplitStatus.TWO_THREE_SPLIT) {
      return true;
    }
    if (this.isShowSmartWindow) {
      return true;
    }
    return false;
  }

  aboutToDisappear() {
    if (this.isPC) {
      this.presenter.inputKeyword = '';
      // this.presenter.getSearchContactResult(this.presenter.inputKeyword);
      this.presenter.getSearchContactResultFromDb(this.presenter.inputKeyword);
    }
    emitter.off(EmitterConstant.EMITTER_CONTACTS_DEFAULT_SELECTED_EVENT_ID);
    emitter.off(EmitterConstant.UPDATE_SHOW_BIRTHDAY_BANNERS_EMITTER_ID);
    emitter.off(EmitterConstant.CONTACT_LIST_CACHE_UPDATE);
  }

  async checkCalendarPermission() {
    this.showBirthdayBanners = await sharedPreferencesUtils.getFromPreferences('showBirthdayBanners', true) as boolean;
  }

  contactsListyChange() {
    if (this.contactsListY === 0) {
      this.navigationAnimate();
    }
  }
  // 更新键盘避让高度
  updateListHeight() {
    if (this.isContactSearch) {
      let calculatedOffsetY = px2vp(this.keyBoardHeight) + TITLE_HEIGHT;
      animateTo({
        duration: 550,
        curve: curves.interpolatingSpring(0, 1, 342, 37),
      }, () => this.offSetY = calculatedOffsetY)
    }
  }

  navigationAnimate() {
    this.navigationMenusOpacity = 0.1;
    animateTo({
      duration: this.isPull ? 150 : 400, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), onFinish: () => {
        this.navigationMenusOpacity = 1;
      }
    }, () => {
      this.navigationMenusOpacity = 0.9;
    })
  }

  handleContactSearchVisibility(isContactSearch: boolean) {
    if (this.stages <= 1) {
      HiLog.w(TAG, 'handleContactSearchVisibility stages: ' + this.stages);
    }
    return true;
  }

  handleContactElementVisibility(type: string, isContactSearch: boolean) {
    if (type == 'positive') {
      return isContactSearch ? Visibility.Visible : Visibility.None;
    } else {
      return isContactSearch ? Visibility.Hidden : Visibility.Visible;
    }
  }

  onSearchClicked(): void {
    if (this.presenter.searchSerInitStatus != 0) {
      HiLog.w(TAG, 'initFusionSearchService');
      let task = new taskpool.Task(initFusionSearchService);
      taskpool.execute(task).then((res: Object) => {
        HiLog.w(TAG, `init fusionSearchService res: ${res}`)
        this.presenter.searchSerInitStatus = Number(res.toString());
      });
    }
    HiLog.w(TAG, 'onSearchClicked ');
    animateTo({
      curve: curves.interpolatingSpring(0, 1, 342, 38)
    }, () => {
      HiLog.w(TAG, 'isContactSearch value change: contactContent/onSearchClicked');
      this.isContactSearch = true;
      this.contactsListY = this.presenter.isFullTitle ? -138 : -56;
      //联系人打点--点击搜索框
      DotUtil.getInstance().contactDot(this.customParams, CLICK_SEARCH_BAR_EVENT);
    });
  }

  onArrowClicked(): void {
    HiLog.w(TAG, 'onArrowClicked ');
    if (this.isVerde) {
      HiLog.w(TAG, 'v isContactSearch value change: contactContent/onArrowClicked');
      this.isContactSearch = false;
      this.contactsListY = 0;
    } else {
      animateTo({
        curve: curves.interpolatingSpring(0, 1, 342, 38)
      }, () => {
        HiLog.w(TAG, 'isContactSearch value change: contactContent/onArrowClicked');
        this.isContactSearch = false;
        this.contactsListY = 0;
      });
    }
  }

  // 获取拖拽文本
  onSearchDrop(dragData: UnifiedData) {
    let textDrop: string = '';
    let textDropTotal: number = 0;
    let records: unifiedDataChannel.UnifiedRecord[] = dragData.getRecords();
    HiLog.w(TAG, 'onSearchDrop records length: ' + records.length);
    for (let record of records) {
      // 搜索框匹配-纯文本类型
      if (record.getType() === uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
        let plainText = record as unifiedDataChannel.PlainText;
        if (!StringUtil.isEmpty(plainText.textContent)) {
          textDrop += plainText.textContent;
          textDropTotal++;
        }
      }
    }
    HiLog.w(TAG, 'onSearchDrop textDropTotal: ' + textDropTotal);
    this.presenter.inputKeyword = textDrop;
  }

  onBackPress() {
    if (this.isVerde) {
      this.isContactSearch = false;
      this.contactsListY = 0;
      let exportData: emitter.EventData = {
        data: {
          'isPop': true
        }
      }
      emitter.emit(AlphabetIndexerPage.innerEvent, exportData);
    } else {
      this.isContactSearch = false;
      animateTo({
        curve: curves.interpolatingSpring(0, 1, 342, 38)
      }, () => {
        this.contactsListY = 0;
        let exportData: emitter.EventData = {
          data: {
            'isPop': true
          }
        }
        emitter.emit(AlphabetIndexerPage.innerEvent, exportData);
      });
    }
  }

  cacheCurrentPageAvatars() {
    // 滑动结束添加一页缓存
    let difference = this.presenter.contactListDataSource.contactList.length - this.lastLastIndex;
    if (this.lastFirstIndex >= 2) {
      this.cachedIndex[0] = this.lastFirstIndex - 2;
    } else if (this.lastFirstIndex == 1) {
      this.cachedIndex[0] = this.lastFirstIndex - 1;
    } else {
      this.cachedIndex[0] = this.lastFirstIndex;
    }
    if (difference >= 2) {
      this.cachedIndex[1] = this.lastLastIndex + 3;
    } else if (difference >= 1) {
      this.cachedIndex[1] = this.lastLastIndex + 2;
    } else {
      this.cachedIndex[1] = this.lastLastIndex + 1;
    }
    let contactList = this.presenter.contactListDataSource.contactList.slice(this.cachedIndex[0], this.cachedIndex[1]);
    contactList.forEach(item => {
      PixelMapManager.getInstance().cachedContactListIdMiniPixelMap(item, CachedContactsPixelMapType.CONTACT_LIST);
    })
  }

  private getBackgroundColor(): Resource | undefined {
    let backgroundColor: Resource | undefined = $r('app.color.skin_background_primary');
    if (this.isFromMeetime) {
      backgroundColor = $r('app.color.skin_background_secondary');
    } else if (this.isThemeActive) {
      backgroundColor = undefined;
    }
    return backgroundColor;
  }

  @Builder
  sheetComponentBuilder() {
    UIExtensionComponent(
      {
        bundleName: 'com.ohos.contactsdataability',
        abilityName: 'PermissionExtAbility',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI'
        }
      }
    )

      .onReceive(async (data) => {
        this.inShowCalendar = false;
        sharedPreferencesUtils.saveToPreferences('showBirthdayBanners', false);
        this.showBirthdayBanners =
          await sharedPreferencesUtils.getFromPreferences('showBirthdayBanners', false) as boolean;
        if (Number(data['result']) === 1) {
          let conditionArgs = new dataSharePredicates.DataSharePredicates();
          ContactRepository.getInstance()
            .getDataAbilityHelper()
            .then((dataAbilityHelper: dataShare.DataShareHelper) => {
              dataAbilityHelper.query(Contacts.CONTACT_SYNC_CALENDER_URI, conditionArgs, ContactListItem.COLUMNS)
            })
        }
      })
      .width(0)
      .height(0)
  }

  onVerdeChange() {

  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Stack({ alignContent: Alignment.Top }) {
        if (this.isPC && this.handleContactSearchVisibility(this.isContactSearch) && this.stages > 1) {
          this.SearchContact()
        }

        List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
          if (this.stages > 1) {
            if (SystemModeController.getInstance().getIsCurrentModeSupportCalendar()) {
              ListItem() {
                Row() {
                  Popup({
                    showClose: false,
                    direction: i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr,
                    message: {
                      text: $r('app.string.contact_pass_birthday_to_calendar_new'),
                      fontSize: 14,
                      fontColor: $r('app.color.skin_font_primary'),
                      fontWeight: FontWeight.Medium
                    } as PopupTextOptions,
                    buttons: [{
                        text: $r('app.string.cancel_pass_birthday_to_calendar'),
                        action: async () => {
                        HiLog.w(TAG, 'Sync birthday to calendar no allow')
                        this.inShowCalendar = false;
                        sharedPreferencesUtils.saveToPreferences('showBirthdayBanners', false);
                        this.showBirthdayBanners =
                            await sharedPreferencesUtils.getFromPreferences('showBirthdayBanners', false) as boolean;
                        AppStorage.setOrCreate('isShowBanners', false);
                        },
                        fontSize: 14,
                        fontColor: $r('app.color.skin_font_emphasize'),
                    },
                      {
                        text: $r('app.string.allow'),
                        action: () => {
                          HiLog.w(TAG, 'Sync birthday to calendar allow')
                          this.inShowCalendar = true;
                          AppStorage.setOrCreate('isShowBanners', false);
                        },
                        fontSize: 14,
                        fontColor: $r('app.color.skin_font_emphasize')
                      }] as [PopupButtonOptions?, PopupButtonOptions?]
                  })

                }
                .visibility(!this.isFromMeetime && this.showBirthdayBanners ? Visibility.Visible : Visibility.None)
                .width('100%')
                .borderRadius(this.isPC ? $r('sys.float.corner_radius_level4') : $r('app.float.radio_button_width_20'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .margin({
                  top: $r('app.float.id_dialog_button_top_margin'),
                  bottom: ((this.displaySyncCard === Visibility.Visible && !this.isVerde)) ? '0vp' :
                    $r('app.float.id_dialog_button_top_margin')
                })
              }
              .height('auto')
              .width(`calc(100% - 48vp)`)
              .margin({
                start: LengthMetrics.resource($r('app.float.id_card_margin_xxl')),
              })
            }

            // 联系人列表
            LazyForEach(this.presenter.contactListDataSource, (item: ContactListShowInfo, index: number) => {
              ListItem() {
                ContactListItemView({
                  showSubHeaderIndex: this.showSubHeaderIndex,
                  showInfo: item,
                  index: index
                })
              }
            }, (item: ContactListShowInfo, index: number) => item.getItemKey() + index)
          }
        }
        .contentStartOffset(this.isPC ? NUMBER_FIFTY_EIGHT : 0)
        // 滑动到底避让底部tabs高度
        .contentEndOffset(48)
        .cachedCount(3)
        .width('100%')
        .height('100%')
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
        .clipContent(ContentClipMode.SAFE_AREA)
        .scrollBar(BarState.Off)
        .id('contactList_contacts_touch_list')
        // 滑动过程中频繁触发
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          this.scrollReachEnd = false;
          if (firstIndex === this.lastFirstIndex && lastIndex === this.lastLastIndex) {
            return
          }
          this.lastFirstIndex = firstIndex;
          this.lastLastIndex = lastIndex;
          this.isFirstListItem = firstIndex === 0 ? true : false;
          const contactFirstIndex = firstIndex;
          const contactLastIndex = lastIndex;

          this.presenter.contactListDataSource.setCurrentIndex(contactFirstIndex, contactLastIndex);
          let curIndex: number = 0;
          if (this.isShowSearch || this.isVerde) {
            curIndex =
              this.alphabetIndexPresenter.getAlphabetSelected(contactFirstIndex - SEARCH_LIST_PLACEHOLDER_NUMBER);
          } else {
            curIndex =
              this.alphabetIndexPresenter.getAlphabetSelected(contactFirstIndex - NO_SEARCH_LIST_PLACEHOLDER_NUMBER);
          }
          PixelMapManager.getInstance().releaseContactListAllPixelMap(true, false);
          if (this.alphabetSelected !== curIndex) {
            this.alphabetSelected = curIndex;
          }
          // 点击索引到达列表顶部
          if (this.isFirstListItem && this.searchOffsetY !== 0 && this.isAlphabetClicked) {
            animateTo({ curve: curves.responsiveSpringMotion()}, () => {
              HiLog.i(TAG, 'JumpToListTop');
              this.searchOffsetY = 0;
            });
          }
        })
        .onReachEnd(() => {
          this.scrollReachEnd = true;
        })
        // 滚动开始触发
        .onScrollStart(() => {
          HiLog.w(TAG, 'onScrollStart...')
          emitter.emit(AlphabetIndexerPage.contactContentEvent);
          this.isAlphabetClicked = false;
          ContactListBoModel.getInstance().setToSearchPage(false);
          this.isSelectSearchShow = true;
          this.isPopupSelectSearchShow = false;
          PixelMapManager.getInstance().releaseContactListAllPixelMap(true, false);
        })
        // 滚动结束触发
        .onScrollStop(() => {
          HiLog.w(TAG, 'onScrollStop...')
          let exportData: emitter.EventData = {
            data: {
              'isPop': true
            }
          }
          emitter.emit(AlphabetIndexerPage.contactContentEvent, exportData);
          this.isAlphabetClicked = true;
          this.presenter.setCurrentPage();
          ContactListBoModel.getInstance().setToSearchPage(true);
          this.isSelectSearchShow = true;
          this.isPopupSelectSearchShow = false;
          this.cacheCurrentPageAvatars();
        })
        .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
          if (this.isContactSearch) {
            HiLog.i(TAG, `ContactList do not scroll`);
            return;
          }
          if (scrollState === ScrollState.Scroll) {
            if (scrollOffset > 0 && !this.hideIndexTitleTabBar) {
              this.hideIndexTitleTabBar = true;
            } else if (scrollOffset < 0 && this.hideIndexTitleTabBar) {
              this.hideIndexTitleTabBar = false;
            }
          }
          let scrollOffsetY: number = this.scroller.currentOffset().yOffset;
          // 向下滑动
          if (scrollOffset < 0 && this.searchOffsetY !== 0) {
            if (this.scrollReachEnd && scrollState === ScrollState.Idle) {
              return;
            }
            let distance = -this.searchOffsetY - (this.prevSearchOffsetY - scrollOffsetY);
            let searchOffsetY = distance >= 0 && distance <= NUMBER_FIFTY_EIGHT ? -distance :
              (distance < 0 && -distance < NUMBER_FIFTY_EIGHT ? 0 : this.searchOffsetY);
            if (searchOffsetY > 0) {
              searchOffsetY = 0;
            }
            animateTo({ curve: curves.responsiveSpringMotion() }, () => {
              this.searchOffsetY = searchOffsetY;
            });
          }

          // 向上滑动
          if (scrollOffset > 0 && Math.ceil(-this.searchOffsetY) !== NUMBER_FIFTY_EIGHT) {
            let searchOffsetY: number = 0;
            if (scrollOffsetY > 0) {
              // 滑动距离
              if (scrollOffsetY > NUMBER_FIFTY_EIGHT) {
                if (this.searchOffsetY !== -NUMBER_FIFTY_EIGHT) {
                  let distance = -this.searchOffsetY + (scrollOffsetY - this.prevSearchOffsetY);
                  searchOffsetY = distance > 0 && distance <= NUMBER_FIFTY_EIGHT ? -distance :
                    distance < NUMBER_FIFTY_EIGHT + NUMBER_TEN ? -NUMBER_FIFTY_EIGHT : this.searchOffsetY;
                } else {
                  searchOffsetY = -NUMBER_FIFTY_EIGHT
                }
              } else {
                searchOffsetY = -scrollOffsetY;
              }
            } else {
              searchOffsetY = 0;
            }
            animateTo({ curve: curves.responsiveSpringMotion() }, () => {
              this.searchOffsetY = searchOffsetY;
            });
          }

          if (scrollState === ScrollState.Idle) {
            if (this.isFirstListItem) {
              animateTo({ curve: curves.responsiveSpringMotion() }, () => {
                this.searchOffsetY = 0;
              });
            } else {
              animateTo({ curve: curves.responsiveSpringMotion() }, () => {
                this.searchOffsetY = -this.searchOffsetY >= NUMBER_TWENTY_EIGHT ? -NUMBER_FIFTY_EIGHT : 0;
              });
            }
          }
          this.prevSearchOffsetY = scrollOffsetY;
        })
        // 联动效果跳过refresh，使用上层父组件联动
        .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
        .friction(0.75)
        .onTouch(() => {
          if (this.isContactSearch && StringUtil.isEmpty(this.presenter.inputKeyword)) {
            SearchUtil.getInstance().disconnectSearchSession();
            this.onBackPress();
          }
        })
        .accessibilityLevel((this.isContactSearch && this.searchValueLength > 0) ? 'no' : 'auto')
        .accessibilityGroup((this.isContactSearch && this.searchValueLength > 0) ? true : false)
        .visibility((this.isContactSearch && this.presenter.inputKeyword.length > 0) ?
          Visibility.Hidden : Visibility.Visible)
      }
      .height('100%')
      .width('100%')

      Column(){
        if (this.isPC && this.handleContactSearchVisibility(this.isContactSearch) && this.stages > 1) {
        this.SearchContact()
        }

        if (this.isContactSearch && !StringUtil.isEmpty(this.presenter.inputKeyword)) {
          ContactSearch({ presenter: $presenter, offSetY: $offSetY })
          // .offset({ x: NUMBER_ZERO, y: this.isPC ? NUMBER_FIFTY_EIGHT : this.isVerde ?
          //   - NUMBER_FIFTY_EIGHT : - NUMBER_NINETY_FOUR_EIGHT })
            .transition(TransitionEffect.OPACITY.animation({
              duration: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
            }))
            .layoutWeight(1)
          // .height(this.isVerde ? `calc(100% + ${NUMBER_FIFTY_EIGHT}vp)` : this.isPC ?
          //   `calc(100% - ${NUMBER_FIFTY_EIGHT}vp)` : `calc(100% + ${NUMBER_NINETY_FOUR_EIGHT * 2 }vp)`)
        }
      }

      if (this.isPC && this.stages > 0 && DisplaySplitUtil.isShowIndex(this.splitStatus)) {
        if (this.searchValueLength === 0) {
          AlphabetIndexerPage({
            scroller: this.scroller,
            selected: this.alphabetSelected,
            isClicked: $isAlphabetClicked,
            isAutoCollapse: this.isNeedAutoCollapse(),
            preIndexNum: this.preListItemNum,
            useSources: CONTACT_CONTENT
          })
            .id('contactList_contacts_alphabetIndexer_alphabetIndexerPage')
            .margin({ top: this.isVerde && !this.isContactSearch ? '16vp' : this.isPC ? '72vp' : '110vp' })
        }
      }

      Column() {
        if (this.inShowCalendar) {
          Row() {
            this.sheetComponentBuilder();
          }
          .width(0)
          .height(0)
        }
      }
    }
  }

  private getSearchWidth(isContactSearch: boolean): string {
    if (isContactSearch || this.isVerde) {
      if (this.isPC) {
        return 'calc(100% - 96vp)';
      } else {
        return 'calc(100% - 80vp)';
      }
    }
    return this.isPC ? 'calc(100% - 48vp)' : 'calc(100% - 32vp)';
  }

  @Builder
  SearchContact() {
    Row() {
      ArrowBack({
        isTransition: !this.isVerde,
        onBackButtonClick: () => {
          HiLog.w(TAG, 'onBackButtonClick');
          AppStorage.setOrCreate('calibrationAlphabetIndex', 1);
          SearchUtil.getInstance().disconnectSearchSession();
          this.onArrowClicked();
          this.presenter.inputKeyword = '';
          // this.presenter.getSearchContactResult(this.presenter.inputKeyword);
          this.presenter.getSearchContactResultFromDb(this.presenter.inputKeyword);
        }
      })
        .visibility(this.isContactSearch || this.isVerde ? Visibility.Visible : Visibility.None)
        .zIndex(2)

      //搜索框
      WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
        Search({
          value: this.isContactSearch ? this.presenter.inputKeyword : '',
          placeholder: ResourceUtil.getPluralStringByResource($r('app.plural.search_new'), this.contactListListLen)
        })
          .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
          .visibility(this.splitStatus === SplitStatus.ONE_THREE_SPLIT ? Visibility.None : Visibility.Visible)
          .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass'))
            .fontColor([$r('app.color.skin_ohos_id_color_secondary')]))
          .cancelButton({ icon: new SymbolGlyphModifier($r('sys.symbol.xmark'))
            .fontColor([$r('app.color.skin_ohos_id_color_primary')]) })
          .width(this.getSearchWidth(this.isContactSearch))
          .margin({
            left: this.isContactSearch || this.isVerde ? $r('sys.float.padding_level4') :
              this.isPC ? this.spaceLR : $r('app.float.id_card_margin_xxl'),
            right: this.spaceLR,
          })
          .placeholderColor($r('app.color.skin_font_secondary'))
          .id('search_box_bnt')
          .placeholderFont({
            size: ($r('sys.float.Body_L')),
            weight: FontWeight.Regular
          })
            // .backgroundColor(this.isThemeActive ? $r('app.color.skin_comp_background_tertiary') : undefined)
          .textFont({ size: $r('sys.float.Body_L'), weight: 400 })// extra options
          .focusable(this.isPC ? true : this.isContactSearch ? true : false)
          .onChange((value: string) => {
            if (this.isPC && !this.isContactSearch && value.length > 0) {
              if (ContactListBoModel.getInstance().getToSearchPage() && this.searchOffsetY === 0) {
                this.onSearchClicked();
              }
              focusControl.requestFocus('contactList_contacts_valueChange_search');
            }
            this.searchValueLength = value.replace(/\s*/g, '').length;
            this.presenter.inputKeyword = value;
            // this.presenter.getSearchContactResult(this.presenter.inputKeyword);
            this.presenter.getSearchContactResultFromDb(this.presenter.inputKeyword);
          })
          .id('contactList_contacts_valueChange_search')
          .zIndex(1)
          .onClick(() => {
            if (this.isContactSearch) {
              return;
            }
            if (ContactListBoModel.getInstance().getToSearchPage() && this.searchOffsetY === 0) {
              this.onSearchClicked();
            }
            focusControl.requestFocus('contactList_contacts_valueChange_search');
          })
          .onDrop((event: DragEvent) => {
            // 搜索框未获焦时进行拖拽触发
            if (this.isContactSearch) {
              return;
            }
            if (ContactListBoModel.getInstance().getToSearchPage()) {
              this.onSearchClicked();
            }
            focusControl.requestFocus('contactList_contacts_valueChange_search');
            this.onSearchDrop(event.getData());
          })
          .onFocus(() => {
            SearchUtil.getInstance().initSearchSession();
          })
      }
    }
    .backgroundColor(this.getBackgroundColor())
    .height($r('app.float.id_item_height_large'))
    .position(this.isVerde || this.isPC || this.isContactSearch ? null : { top: this.searchOffsetY })
    .margin({ end: this.isContactSearch && this.isMeetimePC ? LengthMetrics.vp(128) : LengthMetrics.vp(0) })
    .zIndex(NUMBER_TWO)
    .visibility(!this.isVerde || this.isContactSearch ? Visibility.Visible : Visibility.Hidden)
  }
}

@Concurrent
export async function initFusionSearchService(): Promise<number> {
  // 拉起全搜服务，需要使用新的方式了，原来的createService过期了，不能用了
  // let searchSession: SearchClient.SearchSession = await SearchClient.beginSearch([]);
  return 0;
}