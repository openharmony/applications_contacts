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

import { StringUtil, HiLog, ArrayUtil } from '../../../../../../../common';
import AccountantsPresenter from '../../../presenter/contact/accountants/AccountantsPresenter';
import StringFormatUtil from '../../../util/StringFormatUtil';
import { Birthday } from '../../../../../../../feature/contact/src/main/ets/contract/Birthday';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CalendarUtil from '../../../util/CalendarUtil';
import LunarUtils from '../../../util/LunarUtils';
import { EventBean } from '../../../model/bean/EventBean';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { common } from '@kit.AbilityKit';
import { FontScaleState } from '../../../util/fontScaleState';
import { i18n, intl } from '@kit.LocalizationKit';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { LunarDateUtil } from '../../../../../../../common/src/main/ets/date/LunarDateUtil';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { MeasureText, TextModifier } from '@kit.ArkUI';
import { LengthMetrics } from '@kit.ArkUI';

const TAG = 'ItemEvent'

@Component
export struct ItemEvent {
  @Link isShowAdd: boolean;
  @Prop length: number;
  @Link @Watch('refresh') mPresent: AccountantsPresenter;
  private index: number = -1;
  private typeName: string = '';
  private textInputKey: string = '';
  private dateNoYearFormatlong = new intl.DateTimeFormat('', { month: 'long', day: 'long' });
  private dateFormatlong = new intl.DateTimeFormat('', { dateStyle: 'long' });
  private dateWeekFormatlong = new intl.DateTimeFormat('', { weekday: 'long' });
  @StorageLink('breakpoint') curBp: string = 'sm';
  @State selectList: SelectOption[] = [];
  @State selectedIndex: number = -1;
  @State selectedValue: string | Resource = '';
  @State selectedDate: Date = new Date();
  @State selectedDateTmp: Date = new Date();
  @State selectedShowDate: Date = new Date();
  @State finalDate: string = StringFormatUtil.numberFormatDateString(this.selectedDate.getFullYear(),
    (this.selectedDate.getMonth() + 1), this.selectedDate.getDate() + 1);
  @State isNoYearDate: boolean = false;
  @State datePickerEnd: string = '';
  @State lunarDateEnd: string = '';
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @State isAutoAdapting: boolean = false;
  @Consume('enableKeyboardOnFocus') enableKeyboardOnFocus: boolean;
  @Consume inShowCalendar: boolean;
  openOptionTextModifier: TextModifier = new TextModifier();
  selectedOptionTextModifier: TextModifier = new TextModifier();
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  @StorageProp('languageConfig') @Watch('languageConfigUpdate') private language: string = 'en-us';

  private filterSelectArr: number[] = [0, 1, 2, 3];

  languageConfigUpdate() {
    this.dateNoYearFormatlong = new intl.DateTimeFormat('', { month: 'long', day: 'long' });
    this.dateFormatlong = new intl.DateTimeFormat('', { dateStyle: 'long' });
    this.dateWeekFormatlong = new intl.DateTimeFormat('', { weekday: 'long' });
  }

  isDatePickerEmpty(): boolean {
    return StringUtil.isEmpty(this.mPresent.getTextDisplay(this.typeName,
      this.mPresent.getData(this.typeName, this.index - 1)));
  }

  getText(): Resource | string {
    let showText = this.mPresent.menuSelect(this.typeName,
      this.mPresent.getData(this.typeName, this.index - 1));
    return showText;
  }

  refresh() {
    this.textInputKey = this.typeName + this.index;
    this.updateSelectedInfo();
  }

  filterSelectedEvent(selectList: SelectOption[]) {
    this.filterSelectArr = [0, 1, 2, 3];
    if (this.selectList != null && this.typeName === 'events' &&
      this.mPresent.contactInfoAfter.events != null && this.mPresent.contactInfoAfter.events.length > 1) {
      let selectedValueStr = ResourceUtil.resourceToStringById(this.selectedValue);
      let typeAnniversariesStr =
        ResourceUtil.resourceToStringById(Birthday.getTypeLabelResource(Birthday.TYPE_ANNIVERSARIES));
      let typeOtherStr = ResourceUtil.resourceToStringById(Birthday.getTypeLabelResource(Birthday.TYPE_OTHER));
      // 过滤生日||农历生日
      let selectListNew = this.filterSelectedItem();
      // 根据目前过滤之后的判断条件，需要将当前行已选中的下拉元素再次封装至下拉框中
      let selectListNewByFilter: SelectOption[] = [];
      if (selectListNew && selectListNew.length < 4) {
        let flag = true;
        selectListNew.forEach((i) => {
          if (ResourceUtil.resourceToStringById(i.value) === selectedValueStr &&
            (typeAnniversariesStr != selectedValueStr || typeOtherStr != selectedValueStr)) {
            flag = false;
          }
        })
        if (flag) {
          selectListNewByFilter = this.putItemByFilter(selectListNew, selectList);
        }
      }
      if (selectListNewByFilter && selectListNewByFilter.length > 0) {
        this.selectList = selectListNewByFilter;
      } else {
        this.selectList = selectListNew;
      }
    }
  }

  // 生日||农历生日 被选中的情况下，不能再提供生日||农历生日下拉选项
  filterSelectedItem(): SelectOption[] {
    let typeGreBirthdayStr =
      ResourceUtil.resourceToStringById(Birthday.getTypeLabelResource(Birthday.TYPE_GREBIRTHDAY));
    let typeLunarBirthdayStr =
      ResourceUtil.resourceToStringById(Birthday.getTypeLabelResource(Birthday.TYPE_LUNARBIRTHDAY));
    let greBirthdayFlag = false;
    let lunarBirthdayFlag = false;
    this.mPresent.contactInfoAfter.events.forEach((item) => {
      if (item.eventType === Birthday.TYPE_GREBIRTHDAY.toString()) {
        // 生日元素下拉项已被选中
        greBirthdayFlag = true;
        HiLog.i(TAG, `greBirthdayFlag is true`);
      }
      if (item.eventType === Birthday.TYPE_LUNARBIRTHDAY.toString()) {
        // 农历生日元素下拉项已被选中
        lunarBirthdayFlag = true;
        HiLog.i(TAG, `lunarBirthdayFlag is true`);
      }
    })
    let selectListNew: SelectOption[] = [];
    this.selectList.forEach((i) => {
      let selectNowStr = ResourceUtil.resourceToStringById(i.value);
      if (selectNowStr === typeGreBirthdayStr && greBirthdayFlag) {
        // 过滤生日下拉框
        this.filterSelectArr.splice(this.filterSelectArr.indexOf(0), 1);
      } else if (selectNowStr === typeLunarBirthdayStr && lunarBirthdayFlag) {
        // 过滤农历生日下拉框
        this.filterSelectArr.splice(this.filterSelectArr.indexOf(1), 1);
      } else {
        selectListNew.push(i);
      }
    })
    return selectListNew;
  }

  // 根据目前过滤之后的判断条件，需要将当前行已选中的下拉元素再次封装至下拉框中
  putItemByFilter(selectListNew: SelectOption[], allSelectList: SelectOption[]): SelectOption[] {
    let selectedValueStr = ResourceUtil.resourceToStringById(this.selectedValue);
    let selectListNewByFilter: SelectOption[] = [];
    if (selectListNew.length === 2) {
      // 这就代表之前已经过滤掉了生日、农历生日两个选项，但现在判断当前行选中的是生日或者农历生日，因此需要将选中的元素项重新塞回下拉框元素中
      if (ResourceUtil.resourceToStringById(this.mPresent.getMenuList(this.typeName)[0].labelRes) ===
        selectedValueStr) {
        selectListNewByFilter.push({ value: this.mPresent.getMenuList(this.typeName)[0].labelRes }); //生日
        this.filterSelectArr = [0, 2, 3];
      }
      if (ResourceUtil.resourceToStringById(this.mPresent.getMenuList(this.typeName)[1].labelRes) ===
        selectedValueStr) {
        selectListNewByFilter.push({ value: this.mPresent.getMenuList(this.typeName)[1].labelRes }); //农历生日
        this.filterSelectArr = [1, 2, 3];
      }
      // 再将selectListNew中剩余元素push入selectListNewByFilter中（也就是：周年纪念、其他重要日期），保障了生日、农历生日、周年纪念、其他重要日期这四个排列顺序
      selectListNew.forEach((k) => {
        selectListNewByFilter.push(k);
      })
    }
    if (selectListNew.length === 3) {
      // 所有选项都需要
      selectListNewByFilter = allSelectList;
      this.filterSelectArr = [0, 1, 2, 3];
    }
    return selectListNewByFilter;
  }

  updateSelectedInfo() {
    this.selectedValue = this.getText();
    if (typeof this.selectedValue !== 'string' && this.curBp === 'sm') {
      let title: string =
        ResourceUtil.resourceToString(this.selectedValue as Resource, getContext(this) as common.UIAbilityContext);
      this.isAutoAdapting = title.length > 3 || this.fontSizeScale > 3;
    }
    let selectList: SelectOption[] = [];
    for (let item of this.mPresent.getMenuList(this.typeName)) {
      selectList.push({ value: item.labelRes });
    }
    this.selectList = [...selectList];

    this.filterSelectedEvent(selectList);

    for (let index = 0; index < selectList.length; ++index) {
      if (JSON.stringify(selectList[index].value) === JSON.stringify(this.selectedValue)) {
        this.checkSelectIndex(index);
        break;
      }
    }
  }

  checkSelectIndex(index: number) {
    //此处需要判断生日下拉元素是否有被去掉的情况(生日不能多选)
    if (this.filterSelectArr.length === 4) {
      this.selectedIndex = index;
    }
    if (this.filterSelectArr.length === 3 && this.filterSelectArr.includes(0)) {
      // 此时存在生日或者农历生日已经被选中的情况，需要特别处理当前的选中框，使用this.filterSelectArr来做判断
      // 此处代表选择框有生日选项
      switch (index) {
        case 0:
          this.selectedIndex = index;
          break;
        case 1:
          this.selectedIndex = -1;
          break;
        case 2:
          this.selectedIndex = 1;
          break;
        case 3:
          this.selectedIndex = 2;
          break;
        default:
          this.selectedIndex = -1;
          break;
      }
    }
    if (this.filterSelectArr.length === 3 && this.filterSelectArr.includes(1)) {
      // 此时存在生日或者农历生日已经被选中的情况，需要特别处理当前的选中框，使用this.filterSelectArr来做判断
      // 此处代表选择框有农历生日选项
      switch (index) {
        case 0:
          this.selectedIndex = -1;
          break;
        case 1:
          this.selectedIndex = 0;
          break;
        case 2:
          this.selectedIndex = 1;
          break;
        case 3:
          this.selectedIndex = 2;
          break;
        default:
          this.selectedIndex = -1;
          break;
      }
    }
    if (this.filterSelectArr.length === 2) {
      // 此时存在生日或者农历生日已经被选中的情况，需要特别处理当前的选中框，使用this.filterSelectArr来做判断
      // 此处代表选择框生日和农历生日选项都没有
      switch (index) {
        case 0:
          this.selectedIndex = -1;
          break;
        case 1:
          this.selectedIndex = -1;
          break;
        case 2:
          this.selectedIndex = 0;
          break;
        case 3:
          this.selectedIndex = 1;
          break;
        default:
          this.selectedIndex = -1;
          break;
      }
    }
  }

  aboutToAppear() {
    HiLog.i(this.typeName + this.index, 'aboutToAppear!!!');
    if (this.mPresent.contactInfoAfter.events[this.index - 1].data) {
      this.finalDate = this.mPresent.contactInfoAfter.events[this.index - 1].data;
      this.selectedShowDate = new Date(this.finalDate);

      this.isNoYearDate = StringFormatUtil.isUndefinedYearDate(this.finalDate);
      if (this.isNoYearDate) {
        this.finalDate = StringFormatUtil.undefinedYearDate2To1(this.finalDate, this.isLunarDateType());
      }

      this.selectedDate = new Date(this.finalDate);
      HiLog.w(TAG, `selectedShowDate: ${this.selectedShowDate.toDateString()
      }, selectedDate: ${this.selectedDate.toDateString()}, isNoYearDate: ${this.isNoYearDate}`)
    };
    this.dataPickerInit();
    this.refresh();
    this.openOptionTextModifier.maxLines(2);
    this.selectedOptionTextModifier.maxLines(2);
  }

  aboutToDisappear(): void {
    this.dialogController?.close();
    DialogControllerManager.getInstance().dialogControllerSet.clear();
  }

  getShowTime(hasWeek: boolean, hasYear: boolean) {
    let showTime = '';
    if (this.isLunarDateType()) {
      showTime = this.formatLunarShowTime(this.selectedShowDate, hasYear);
    } else if (hasYear) {
      showTime = this.dateFormatlong.format(this.selectedShowDate);
    } else {
      showTime = this.dateNoYearFormatlong.format(this.selectedDate);
    }
    if (hasWeek) {
      showTime += this.dateWeekFormatlong.format(this.selectedShowDate);
    }
    return showTime;
  }

  dataPickerInit() {
    // calc the datePicker endDate
    let now = new Date();
    let thisYear: number = now.getFullYear();
    let lastMouth: number = 12;
    let lastDay: number = 31;
    this.datePickerEnd = thisYear + '-' + lastMouth + '-' + lastDay;
    // obtain gregorian date for the first day of the next year
    let solarDate: number[] = LunarUtils.toSolar(thisYear + 1, 1, 1);
    if (solarDate.length === 3) {
      this.lunarDateEnd = solarDate[0] + '-' + solarDate[1] + '-' + solarDate[2];
      HiLog.i(TAG, 'lunarDateEnd: ' + this.lunarDateEnd);
    } else {
      HiLog.i(TAG, 'obtain lunarDateEnd error ');
      this.lunarDateEnd = this.datePickerEnd;
    }
    this.lunarDateEnd = CalendarUtil.getLunarCalendarLastDay(this.lunarDateEnd);
  }

  // Check whether it's lunar type?
  isLunarDateType() {
    const value = this.mPresent.contactInfoAfter?.events[this.index - 1]?.eventType as string;
    return value == String(Birthday.TYPE_LUNARBIRTHDAY);
  }

  // Format Lunar ShowTime
  formatLunarShowTime(date: Date, hasYear: boolean) {
    const lunarStr = LunarDateUtil.getLunarDateShow(date, hasYear);
    return lunarStr;
  }

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: this.getShowTime(true, !this.isNoYearDate),
      contentBuilder: () => {
        this.DataPickerBuilder();
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.i(TAG, 'Callback when the first button is clicked');
          }
        },
        {
          value: $r('app.string.confirm'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.selectedDate = this.selectedDateTmp;
            this.selectedShowDate = this.selectedDateTmp;
            this.finalDate = StringFormatUtil.numberFormatDateString(this.selectedDate.getFullYear(),
              (this.selectedDate.getMonth() + 1), this.selectedDate.getDate());
            this.isNoYearDate = StringFormatUtil.isUndefinedYearDate(this.finalDate);

            if (StringUtil.isEmpty(this.mPresent.contactInfoAfter?.events[this.index - 1]?.eventType)) {
              this.mPresent.contactInfoAfter.events[this.index - 1] = new EventBean('', '', '1', '');
            }
            this.mPresent.contactInfoAfter.events[this.index - 1].data = this.finalDate;
            this.mPresent.refresh();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.i(TAG, 'Callback when the second button is clicked');
          }
        }
      ]
    }),
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
    cancel: () => {
      HiLog.i(TAG, 'Click the callback in the blank area');
    }
  })

  build() {
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.Wrap,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center
    }) {
      Row() {
        WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
          Select(this.selectList)
            .selected(this.selectedIndex)
            .value(this.selectedValue)
            .divider(
              {
                color: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_separator') : undefined
              })
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .fontColor($r('app.color.skin_font_primary'))
            .selectedOptionFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
            .selectedOptionFontColor($r('app.color.skin_font_primary'))
            .selectedOptionBgColor(this.isThemeActive ? $r('app.color.skin_comp_emphasize_secondary') : undefined)
            .menuBackgroundColor(this.isThemeActive ? $r('app.color.skin_comp_background_primary') : undefined)
            .optionWidth($r('app.float.account_MenuBuilder_width_x'))
            .optionTextModifier(this.openOptionTextModifier)
            .selectedOptionTextModifier(this.selectedOptionTextModifier)
            .optionFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
            .optionFontColor($r('app.color.skin_font_primary'))
            .optionFont({
              size: $r('app.float.contact_text_size_body1'),
              weight: FontWeight.Medium
            })
            .menuBackgroundBlurStyle(this.isThemeActive ? BlurStyle.NONE : BlurStyle.COMPONENT_ULTRA_THICK)
            .padding({
              left: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level2')
                : $r('sys.float.padding_level4'),
              right: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level4')
                : $r('sys.float.padding_level2')
            })
            .onSelect((index: number) => {
              this.isShowAdd = true;
              let item = this.mPresent.getMenuList(this.typeName)[index];
              // 生日下拉元素选中时,需要判断是否已经隐藏了生日、农历生日元素，需要将下标移动后取值
              if (this.filterSelectArr.length === 2) {
                item = this.mPresent.getMenuList(this.typeName)[index + 2];
              }
              if (this.filterSelectArr.length === 3 && this.filterSelectArr.includes(0)) {
                if (index === 0) {
                  item = this.mPresent.getMenuList(this.typeName)[index];
                } else {
                  item = this.mPresent.getMenuList(this.typeName)[index + 1];
                }
              }
              if (this.filterSelectArr.length === 3 && this.filterSelectArr.includes(1)) {
                item = this.mPresent.getMenuList(this.typeName)[index + 1];
              }
              this.mPresent.menuChange(this.typeName, this.mPresent.getData(this.typeName, this.index - 1), item);
              this.updateSelectedInfo();
            })
            .focusable(true)
            .focusOnTouch(true)
            .flexShrink(0)
            .flexGrow(1)
        }
      }
      .flexShrink(0)
      .constraintSize({
        minWidth: $r('app.float.account_ItemList_menu_select_and_ic_spinner_width'),
      })
      .margin({
        end: LengthMetrics.resource($r('sys.float.padding_level4')),
        bottom: LengthMetrics.resource(FontScaleState.isStandardGeer(this.fontSizeScale)
          ? $r('sys.float.padding_level0') : $r('sys.float.padding_level2'))
      })

      Row({ space: 16 }) {
        WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
          Select([])
            .value(StringUtil.isEmpty(this.mPresent.getTextDisplay(this.typeName,
              this.mPresent.getData(this.typeName, this.index - 1)))
              ? $r('app.string.date')
              : this.getShowTime(false, !this.isNoYearDate))
            .width('auto')
            .constraintSize({
              minHeight: $r('app.float.id_item_height_sm'),
              maxWidth: 'calc(100% - 24vp)'
            })
            .selected(this.selectedIndex)
            .enabled(true)
            .onClick(() => {
              this.selectedDateTmp = this.selectedDate;
              this.dialogController?.open();
              DialogControllerManager.getInstance().addDialogController(this.dialogController);
              this.enableKeyboardOnFocus = false;
            })
            .padding({
              left: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level2')
                : $r('sys.float.padding_level4'),
              right: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level4')
                : $r('sys.float.padding_level2')
            })
            .flexGrow(StringUtil.isEmpty(
              this.mPresent.getTextDisplay(this.typeName, this.mPresent.getData(this.typeName, this.index - 1)))
              ? 1 : 0)
            .key(this.textInputKey)
        }

        Button() {
          SymbolGlyph($r('sys.symbol.minus_circle_fill'))
            .fontSize($r('app.float.id_card_image_small'))
            .fontColor([$r('app.color.skin_ohos_id_color_warning')])
        }
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(false)
        .onClick(() => {
          try {
            let totalIndex = this.mPresent.getDataArray(this.typeName).length;
            HiLog.i(TAG, `${this.typeName}, ${totalIndex}, ${this.index}, ${this.isOpenAccessibility}`);
            this.mPresent.deleteItem(this.typeName, this.index - 1);
            this.inShowCalendar = false;
            AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility,
              this.typeName + (totalIndex === 1 ? 'ItemInitially' : 'AddItem'), 30);
          } catch (err) {
            HiLog.e('deleteItem', ` deleteItem error: err.code: ${err?.code}, err.message: ${err?.message}`);
          }
        })
        .accessibilityText(AccessibilityUtil.getInstance()
          .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_delete')))
      }
      .flexGrow(1)
      .constraintSize({
        minHeight: $r('app.float.id_item_height_mid')
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignSelf(ItemAlign.Stretch)
    }
    .margin({
      end: LengthMetrics.resource($r('sys.float.padding_level6')),
      start: LengthMetrics.resource($r('sys.float.padding_level6')),
      bottom: LengthMetrics.resource(FontScaleState.isStandardGeer(this.fontSizeScale)
        ? $r('sys.float.padding_level0') : $r('sys.float.padding_level2'))
    })
  }

  @Builder
  DataPickerBuilder() {
    Column() {
      DatePicker({
        start: new Date(this.isLunarDateType() ? '1910-2-10' : '1910-1-1'),
        end: new Date(this.isLunarDateType() ? this.lunarDateEnd : this.datePickerEnd),
        selected: this.selectedDate
      })
        .onDateChange((date: Date) => {
          this.selectedDateTmp = date;
        })
        .width('100%')
        .height('200vp')
        .lunar(this.isLunarDateType())
        .selectedTextStyle({
          color: $r('app.color.skin_font_emphasize'),
        })
    }
    .padding({ top: $r('sys.float.padding_level4') })
    .width('100%')
  }
}