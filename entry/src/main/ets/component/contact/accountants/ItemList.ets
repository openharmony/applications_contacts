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
import AccountantsPresenter, { SelectInfoModel } from '../../../presenter/contact/accountants/AccountantsPresenter';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import EditType from '../../../../../../../feature/account/src/main/ets/type/EditType';
import { StringUtil } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/util/StringUtil';
import { CaretPositionUtil } from '../../../util/CaretPositionUtil';
import PhoneAccountType from '../../../../../../../feature/account/src/main/ets/type/PhoneAccountType';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog'
import CustomTextInputContent from '../../../pages/dialog/CustomTextInputContent';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { common } from '@kit.AbilityKit';
import { FontScaleState } from '../../../util/fontScaleState';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../../data/EmitterConstant';
import AccessibilityUtil from '../../../util/AccessibilityUtil';
import { LengthMetrics } from '@kit.ArkUI';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import { i18n } from '@kit.LocalizationKit';
import EnvironmentProp from '../../../feature/EnvironmentProp';

const TAG = 'ItemList';

const context = getContext(this);

class SelectItemModifier implements ContentModifier<MenuItemConfiguration> {
  applyContent(): WrappedBuilder<[MenuItemConfiguration]> {
    return wrapBuilder(selectItem);
  }
}

@Builder
function selectItem(itemConfig: MenuItemConfiguration): void {
  Row() {
    Text(itemConfig.value)
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))

    SymbolGlyph($r('sys.symbol.checkmark'))
      .fontSize($r('app.float.id_card_margin_max'))
      .fontColor([$r('app.color.skin_ohos_id_color_primary')])
      .visibility(itemConfig.selected ? Visibility.Visible : Visibility.None)
  }
  .height($r('app.float.id_item_height_sm'))
  .margin({ bottom: $r('sys.float.padding_level1') })
  .justifyContent(FlexAlign.SpaceBetween)
  .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  .width('100%')
  .onClick(() => {
    itemConfig.triggerSelect(itemConfig.index, itemConfig.value.valueOf().toString());
  })
}

@Component
export struct ItemList {
  @Consume('updataShow') updataShow: boolean;
  @Link isShowAdd: boolean;
  @Prop inputType?: InputType = InputType.Normal;
  @Link @Watch('refresh') mPresent: AccountantsPresenter;
  @State mTextInputValue: string = '';
  // 比如电话信息，可能有多个电话信息，存到一个数组，index表示第几个
  private index: number = 0;
  // 类型，比如电话，email，。。。
  private typeName: string = '';
  @Prop placeholder?: Resource | string;
  @StorageLink('breakpoint') curBp: string = 'sm';
  private textInputKey: string = '';
  @State selectList: SelectOption[] = [];
  @State selectedIndex: number = -1;
  @State selectedValue: string | Resource = '';
  private highlighting: boolean = false;
  @Prop isWebSite?: boolean;
  // 焦点状态
  @State focusState: number = -1;
  @State focusIndex: number = -1;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @Link isEnableKeyboardOnFocus: boolean;
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @State teleNumberNoFormatChar: string = '';
  @State lastCaretPosition: number = 0;
  @State lastCaretPositionEnd: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  controller: TextInputController = new TextInputController();
  public mDialerPresent: DialerPresenter = DialerPresenter.getInstance();
  private defaultTextAreaHeight: number = 0;
  private isPC: boolean = EnvironmentProp.isPC();

  /**
   * 取消自定义，需要将选择框回退到上一次自定义前的选择框
   */
  onCancel() {
    let selectInfoModel = this.mPresent.getSelectInfoModel(this.typeName, this.index - 1)
    this.mPresent.menuChangeByCustomDialogClose(this.typeName, this.index - 1,
      selectInfoModel.selectInfoArr[0].rawValue.toString(), selectInfoModel.selectInfoArr[0].labelRes)
  }

  /**
   * 确定自定义，需要将下拉框内容变为自定义的内容;  下拉框的值改为了自定义内容
   */
  onAccept() {
    let selectInfoModel = this.mPresent.getSelectInfoModel(this.typeName, this.index - 1)
    if (selectInfoModel && selectInfoModel.editTypeCustomArr[0] != undefined) {
      this.mPresent.menuChangeByCustomDialogClose(this.typeName, this.index - 1,
        selectInfoModel.editTypeCustomArr[0].rawValue.toString(), selectInfoModel.editTypeCustomArr[0].labelRes)
    }
  }

  existApp() {
    HiLog.i(TAG, 'Click the callback in the blank area');
  }

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.adding_custom_tag'),
      contentBuilder: () => {
        this.TextInputBuilder();
      },
      contentAreaPadding: { left: $r('sys.float.padding_level0'), right: $r('sys.float.padding_level0') }
    }),
    cancel: this.onCancel,
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') :
    $r('app.color.skin_comp_background_primary'),
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  })

  refresh() {
    let mTextInputValue = this.mPresent.getTextDisplay(this.typeName,
      this.mPresent.getData(this.typeName, this.index - 1));
    if (StringUtil.removeFormatChar(this.mTextInputValue) !== StringUtil.removeFormatChar(mTextInputValue)) {
      this.mTextInputValue = mTextInputValue;
    }
    this.textInputKey = this.typeName + this.index;
    this.highlighting = this.mPresent.getData(this.typeName, this.index - 1)?.item.highlighting as boolean;
    this.mPresent.refreshAddState();
    this.updateSelectedInfo();
  }

  aboutToAppear() {
    HiLog.i(this.typeName + this.index, 'aboutToAppear!!!');
    this.refresh();
    this.onFocusEvent();
  }

  aboutToDisappear() {
    this.dialogController = null
    context.eventHub.off('focus');
  }

  onFocusEvent() {
    context.eventHub.on('focus', () => {
      this.isEnableKeyboardOnFocus = true;
      focusControl.requestFocus(this.typeName + this.index);
    })
  }

  getText(): Resource | string {
    if (this.isWebSite) {
      return $r('app.string.website')
    }
    return this.selectChange()
  }

  /**
   * 选择下拉框改变，需要记录当前选则框和上次选择框，计算选择框文本宽度，根据文本宽度计算下拉框组件宽度
   **/
  selectChange() {
    // 当前行，对应的select选择框部分信息
    let selectInfoModel = this.mPresent.getSelectInfoModel(this.typeName, this.index - 1);

    // 当前行对应的值的对象
    let looseObject = this.mPresent.getData(this.typeName, this.index - 1);
    let typeId = this.mPresent.getSelectTypeId(this.typeName, looseObject);

    let curSelectInfo = new EditType(typeId,
      this.mPresent.menuSelectSysAndCustom(this.typeName, looseObject, selectInfoModel?.editTypeCustomArr[0]));

    // 如果是编辑时进入页面，如果是自定义文本的话，此时editTypeCustomArr信息为空，需要从数据库中保存的自定义信息拿到自定义字符串
    if (typeId == PhoneAccountType.TYPE_ID_CUSTOM && selectInfoModel.editTypeCustomArr[0] == undefined) {
      let editTypeInDb = this.mPresent.getSelectType(this.typeName, looseObject);
      selectInfoModel.editTypeCustomArr[0] = editTypeInDb;
      curSelectInfo = editTypeInDb;
    }
    // select框改变了，需要计算
    // 更新-选择的信息
    this.updateSelectInfo(curSelectInfo, selectInfoModel);
    return curSelectInfo.labelRes;
  }

  updateSelectInfo(selectInfo: EditType, selectInfoModel: SelectInfoModel) {
    if (selectInfoModel.selectInfoArr.length == 0) {
      selectInfoModel.selectInfoArr[0] = selectInfo
    } else if (selectInfoModel.selectInfoArr.length == 1) {
      selectInfoModel.selectInfoArr[1] = selectInfo
    } else {
      if (selectInfo.rawValue != selectInfoModel.selectInfoArr[1].rawValue) {
        selectInfoModel.selectInfoArr[0] = selectInfoModel.selectInfoArr[1]
        selectInfoModel.selectInfoArr[1] = selectInfo
      }
    }
  }

  updateSelectedInfo() {
    let selectedValueTemp = this.getText();
    // 有变化，才给状态变量赋值，避免presenter变化，但组件值没有变化，也刷新
    if (this.isResourceChange(selectedValueTemp, this.selectedValue)) {
      this.selectedValue = selectedValueTemp;
    }
    let selectList: SelectOption[] = [];
    for (let item of this.mPresent.getSysAndCustomMenuListByNameAndIndex(this.typeName, this.index - 1)) {
      selectList.push({ value: item.labelRes });
    }
    if (this.isSelectListChange(selectList, this.selectList)) {
      // 判断selectList是否有变化
      this.selectList = [...selectList];
    }

    for (let index = 0; index < selectList.length; ++index) {
      if (JSON.stringify(selectList[index].value) === JSON.stringify(this.selectedValue)) {
        this.selectedIndex = index;
        break;
      }
    }
  }

  isSelectListChange(selectListNew: SelectOption[], selectListOld: SelectOption[]) {
    if (selectListNew.length !== selectListOld.length) {
      return true;
    }

    for (let i = 0; i < selectListNew.length; i++) {
      if (this.isResourceChange(selectListNew[i].value, selectListOld[i].value)) {
        return true;
      }
    }

    return false;
  }

  isResourceChange(sourceNew: Resource | string, sourceOld: Resource | string) {
    let typeNew = typeof sourceNew;
    let typeOld = typeof sourceOld;
    if (typeNew !== typeOld) {
      return true;
    }
    if (typeNew === 'string') {
      return !(sourceNew === sourceOld);
    } else {
      return !((sourceNew as Resource).id === (sourceOld as Resource).id);
    }
  }

  isShowUnderline() {
    return (this.typeName !== 'phone' && this.typeName !== 'AIM' && this.typeName !== 'relationships') ||
      ((this.typeName === 'phone' || this.typeName === 'AIM' || this.typeName === 'relationships') && this.isShowAdd)
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.Wrap,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center
    }) {
      if (this.typeName === 'website') {
        Column() {
          Text($r('app.string.website'))
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
        }
        .constraintSize({
          minHeight: $r('app.float.id_card_image_mid'),
          minWidth: $r('app.float.account_ItemList_menu_select_and_ic_spinner_width')
        })
        .padding({ start: LengthMetrics.resource($r('sys.float.padding_level8')) })
        .backgroundColor($r('app.color.skin_ohos_id_color_button_normal'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .margin({ end: LengthMetrics.resource($r('sys.float.padding_level4')) })
      } else {
        Row() {
          WithTheme(this.isThemeActive ? { theme: defaultCustomTheme } : undefined) {
            Select(this.selectList)
              .selected(this.selectedIndex)
              .value(this.selectedValue)
              .divider(this.isPC ? null :
                {
                  color: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_separator') : undefined
                })
              .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
              .fontColor(this.isThemeActive ? $r('app.color.skin_font_primary') :
              $r('app.color.skin_ohos_id_color_text_primary'))
              .selectedOptionFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
              .selectedOptionFontColor($r('app.color.skin_font_primary'))
              .selectedOptionBgColor(this.isThemeActive ? $r('app.color.skin_comp_emphasize_secondary') : undefined)
              .optionWidth($r('app.float.account_MenuBuilder_width_x'))
              .optionFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
              .optionFontColor($r('app.color.skin_font_primary'))
              .optionFont({
                size: $r('app.float.contact_text_size_body1'),
                weight: FontWeight.Medium
              })
              .menuBackgroundColor(this.isThemeActive ? $r('app.color.skin_comp_background_primary') : undefined)
              .menuBackgroundBlurStyle(this.isThemeActive ? BlurStyle.NONE : BlurStyle.COMPONENT_ULTRA_THICK)
              .constraintSize({ minHeight: $r('app.float.id_item_height_sm') })
              .padding({
                left: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level2')
                  : $r('sys.float.padding_level4'),
                right: i18n.isRTL(i18n.System.getSystemLanguage()) ? $r('sys.float.padding_level4')
                  : $r('sys.float.padding_level2')
              })
              .menuItemContentModifier(this.isPC ? new SelectItemModifier() : undefined)
              .onSelect((index: number) => {
                // 选择下拉后，当前信息
                let item = this.mPresent.getSysAndCustomMenuListByNameAndIndex(this.typeName, this.index - 1)[index];
                // 选择下拉后，当前选择信息
                let selectInfoModel = this.mPresent.getSelectInfoModel(this.typeName, this.index - 1);
                this.mPresent.menuChange(this.typeName, this.mPresent.getData(this.typeName, this.index - 1), item);
                // 如果选择了“自定义”下拉
                if (new PhoneAccountType().CUSTOMER_TYPE_SET.has(item.rawValue)) {
                  this.dialogController?.open();
                  DialogControllerManager.getInstance().addDialogController(this.dialogController);
                } else if (item.rawValue == PhoneAccountType.TYPE_ID_CUSTOM) {
                  // 选择了自定义编辑的信息，即已经自定义好，出现下下拉框的元素，如：typeId=10000，typeName=“自定义啊啊啊啊啊”
                } else {
                  // 选择了系统定义好好的信息，就不需要之前自定义的信息了
                  selectInfoModel.editTypeCustomArr[0] = undefined;
                }
                this.updateSelectedInfo();
              })
              .focusable(true)
              .focusOnTouch(true)
              .flexGrow(1)
          }
        }
        .flexShrink(0)
        .constraintSize({
          minHeight: $r('app.float.id_item_height_large'),
          minWidth: $r('app.float.account_ItemList_menu_select_and_ic_spinner_width')
        })
        .justifyContent(FlexAlign.Center)
        .margin({ end: LengthMetrics.resource($r('sys.float.padding_level4')) })
      }

      Column() {
        Row({ space: 16 }) {
          if (this.typeName === 'house') {
            TextArea({
              placeholder: this.placeholder,
              text: this.mTextInputValue
            })
              .enableKeyboardOnFocus(this.isEnableKeyboardOnFocus)
              .fontColor($r('app.color.skin_font_primary'))
              .placeholderColor($r('app.color.skin_font_secondary'))
              .key(this.textInputKey)
              .fontSize($r('sys.float.Body_L'))
              .caretColor($r('app.color.skin_font_emphasize'))
              .maxLength(256)
              .backgroundColor(Color.Transparent)
              .padding(0)
              .borderRadius(0)
              .align(Alignment.Center)
              .barState(BarState.Off)
              .constraintSize({ minHeight: $r('app.float.id_item_height_mid'), minWidth: $r('app.float.id_width_80') })
              .flexGrow(1)
              .flexShrink(1)
              .onFocus(() => {
                this.focusState = 1;
              })
              .onBlur(() => {
                this.focusState = 0;
              })
              .onChange((arg) => {
                if (this.index > 1 && this.index > this.mPresent.getDataArray(this.typeName).length) {
                  return;
                }
                this.mTextInputValue = arg;
                this.mPresent.listItemChange(
                  this.typeName, this.mPresent.getData(this.typeName, this.index - 1), arg.toString());
                this.mTextInputValue && (this.isShowAdd = true);
              })
              .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
                let newHeight: number = newValue.height as number;
                let oldHeight: number = oldValue.height as number;
                if (this.defaultTextAreaHeight === 0 && newHeight !== 0) {
                  this.defaultTextAreaHeight = newHeight;
                }
                if (this.focusState === 1 && (newValue !== oldValue) && this.defaultTextAreaHeight > 0 &&
                  (newHeight > this.defaultTextAreaHeight || (newValue.width as number) > (oldValue.width as number))) {
                  let height: number = newHeight - oldHeight === 0 ? newHeight : newHeight - oldHeight;
                  let eventData: emitter.EventData = {
                    data: {
                      'height': Math.max(0, height)
                    }
                  }
                  emitter.emit({
                    eventId: EmitterConstant.EMITTER_ACCOUNTANTS_TEXTAREA_ID,
                    priority: emitter.EventPriority.HIGH
                  }, eventData)
                }
              })
          } else {
            TextInput({
              placeholder: this.placeholder,
              text: this.mTextInputValue,
              controller: this.controller
            })
              .id(this.typeName + this.index)
              .key(this.textInputKey)
              .enableKeyboardOnFocus(this.isEnableKeyboardOnFocus)
              .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
              .fontColor(this.highlighting ? $r('app.color.skin_font_emphasize') : $r('app.color.skin_font_primary'))
              .placeholderColor($r('app.color.skin_font_secondary'))
              .fontSize($r('sys.float.Body_L'))
              .caretColor($r('app.color.skin_font_emphasize'))
              .type(this.inputType)
              .maxLength(256)
              .backgroundColor(Color.Transparent)
              .padding(0)
              .barState(BarState.Off)
              .constraintSize({ minHeight: $r('app.float.id_item_height_mid'), minWidth: $r('app.float.id_width_80') })
              .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
              .direction(Direction.Ltr)
              .flexGrow(1)
              .flexShrink(1)
              .inputFilter(this.generateFilterRules(this.typeName), (e) => {
                HiLog.i(TAG, `inputFilter err: ${e}`);
              })
              .onFocus(() => {
                this.focusState = 1;
                this.focusIndex = this.index;
              })
              .onBlur(() => {
                this.focusState = 0;
                this.focusIndex = -1;
              })
              .onChange((arg) => {
                if (this.index > 1 && this.index > this.mPresent.getDataArray(this.typeName).length) {
                  return;
                }
                if (this.typeName === 'phone') {
                  this.teleNumberNoFormatChar = StringUtil.removeFormatChar(arg);
                  // 判断新增字符为 格式化字符（  - ( ) ），则不进行格式化操作
                  if (arg !== this.mTextInputValue &&
                    StringUtil.removeFormatChar(this.mTextInputValue) === this.teleNumberNoFormatChar) {
                    this.mTextInputValue = arg;
                    CaretPositionUtil.nextCaret = -1;
                  } else {
                    let checkNeedNumberSpace: boolean = this.mDialerPresent.checkNeedNumberSpace(arg);
                    this.mTextInputValue = CaretPositionUtil.processingCaret(arg, this.focusState, this.index,
                      this.focusIndex, checkNeedNumberSpace, this.mTextInputValue, this.teleNumberNoFormatChar,
                      this.lastCaretPosition, this.lastCaretPositionEnd, this.controller);
                  }
                } else {
                  this.mTextInputValue = arg;
                }
                // 打印文本框内容发现InputType.PhoneNumber类型，即电话号码信息可能末尾会自动带空格，即使没有输入空格，所以做去空格操作
                this.mPresent.listItemChange(this.typeName, this.mPresent.getData(this.typeName, this.index - 1),
                  this.typeName === 'phone' ? this.teleNumberNoFormatChar.toString() : arg.toString());
                (this.mTextInputValue !== '') && (this.isShowAdd = true);
              })
              .onTextSelectionChange((selectionStart: number, selectionEnd: number) => {
                // 记录光标位置
                this.lastCaretPosition = selectionStart;
                this.lastCaretPositionEnd = selectionEnd;
              })
          }

          if (!StringUtil.isEmpty(this.mTextInputValue) && this.focusState === 1) {
            Button() {
              SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
                .fontSize($r('app.float.id_card_image_small'))
                .fontColor([$r('app.color.skin_font_tertiary')])
            }
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .stateEffect(false)
            .onClick(() => {
              this.mTextInputValue = '';
              AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility,
                this.typeName + this.index, 30)
            })
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, $r('app.string.clear')))
          } else if (this.focusState === 0 || (this.updataShow && !StringUtil.isEmpty(this.mTextInputValue))) {
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
                AccessibilityUtil.getInstance().sendAccessibilityEvent(this.isOpenAccessibility,
                  this.typeName + (totalIndex === 1 ? 'ItemInitially' : 'AddItem'), 30);
              } catch (err) {
                HiLog.e('deleteItem', `deleteItem error: err.code: ${err?.code}, err.message: ${err?.message}`);
              }
            })
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_delete')))
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignSelf(ItemAlign.Stretch)

        if (this.isShowUnderline()) {
          Divider()
            .strokeWidth(this.focusState === 1 ? '2px' : '1px')
            .width(0)
            .alignSelf(ItemAlign.Stretch)
            .color(this.focusState === 1 ? $r('app.color.skin_ohos_id_color_primary', 0.6) :
            $r('app.color.skin_ohos_id_color_list_separator'))
        }
      }
      .constraintSize({
        minHeight: $r('app.float.id_item_height_large')
      })
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)
    }
    .margin({
      end: LengthMetrics.resource($r('sys.float.padding_level6')),
      start: LengthMetrics.resource($r('sys.float.padding_level6'))
    })
  }

  @Builder
  TextInputBuilder() {
    Column() {
      CustomTextInputContent({
        inputValue: '',
        cancelButtonText: $r('app.string.dialog_cancel'),
        confirmButtonText: $r('app.string.confirm'),
        onCancel: () => {
          this.onCancel();
          this.dialogController?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        },
        onConfirm: (value: string) => {
          let selectInfoModel = this.mPresent.getSelectInfoModel(this.typeName, this.index - 1);
          selectInfoModel.editTypeCustomArr[0] = new EditType(PhoneAccountType.TYPE_ID_CUSTOM, value);

          // 确定后，新增了文本框内容对应的select选项
          this.onAccept();
          this.dialogController?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      })
    }
    .width('100%')
  }

  /**
   * 根据输入的类型得到输入框不同的校验规则
   *
   * @param typeName {string} - 输入类型
   * @returns 校验规则
   */
  generateFilterRules(typeName: string): string | undefined {
    switch (typeName) {
      case 'phone':
        return '[\\d\\-\\+\\*\\#\\,\\;\\(\\)\\s]+';
      case 'email':
        return '.';
      default:
        return undefined;
    }
  }
}