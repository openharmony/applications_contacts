/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import DialerPresenter, {
  QUERY_LOCATION_PHONE_NUMBER_MAX_LEN,
  QUERY_LOCATION_PHONE_NUMBER_MIN_LEN
} from '../../presenter/dialer/DialerPresenter';
import GetNumberLocation from '../../util/GetNumberLocation';
import { HiLog } from '../../../../../../common/src/main/ets/util/HiLog';
import { StringUtil } from '../../../../../../common/src/main/ets/util/StringUtil';
import DialerConstant from '../../data/DialerConstant';
import UDC from '@ohos.data.unifiedDataChannel';
import UTD from '@ohos.data.uniformTypeDescriptor';
import { DialBindSheetBuilder } from './DialBindSheetBuilder';
import { TelNumberModel } from '../../model/TelNumberModel';
import { DisplaySplitUtil, SplitStatus } from '../../util/DisplaySplitUtil';
import { i18n } from '@kit.LocalizationKit';
import { numFormat } from '../../util/NumFormat';

const TAG = 'TelNumber';
const SECRET_CODE_MMI_IMEI_DISPLAY: string = '*#06#';
const regex = /^[0-9*#+,;]+$/;
const NUM_REGEX = /^[0-9]+$/;
const DOUBLE_INPUT_INTERVAL_TIME = 50; // 两次键盘输入间隔50ms

@Component
export struct TelNumber {
  readonly NUM_TEXT_MAX_LENGTH = 20;
  readonly NUM_TEXT_FONT_SIZE_MAX = 38;
  readonly NUM_TEXT_FONT_SIZE_MIN = 24;
  private telNumberModel: TelNumberModel = new TelNumberModel();
  @StorageLink(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) @Watch('telNumberChange') telNumberWithSpace: string = '';
  // 显示拨号页面
  @StorageLink('showTelNumber') showTelNumber: boolean = true;
  @StorageLink('isPasteShowCursor') isPasteShowCursor: boolean = false;
  mPresenter: DialerPresenter = DialerPresenter.getInstance();
  @State textInputFocusable: boolean = false;
  textInputController: TextInputController = new TextInputController();
  @Link numberLocation: string;
  @State telNumSize: number = this.NUM_TEXT_FONT_SIZE_MAX;
  @State telNumSizeVp: string = '38vp';
  @StorageLink('isDialerShowImeiPanel') isShowImeiPanel: boolean = false;
  private timerId: number = -1;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  @StorageProp('isVerde') isVerde: boolean = false;
  @StorageProp('splitStatus') splitStatus: SplitStatus = SplitStatus.DEFAULT;
  private lastInputTime: number = -1; // 用来减少键盘快速输入问题
  private textValue: string = '';
  @StorageProp('languageConfig') private language: string = '';

  aboutToAppear() {
    HiLog.w(TAG, 'aboutToAppear TelNumber ');
    this.isShowImeiPanel = false;
    this.telNumberChange();
  }

  aboutToDisappear() {
    HiLog.w(TAG, 'aboutToDisappear TelNumber ');
    clearInterval(this.timerId);
  }

  getLocation(number: string) {
    let newNumber = number.replace(new RegExp('\\s+', 'g'), '');
    if (StringUtil.isEmpty(newNumber)) {
      // 号码为空归属地变量置为空，用于下一次查询使用
      HiLog.w(TAG, 'Number is Empty, The location is not displayed.');
      this.numberLocation = '';
      return;
    }
    // 号码长度小于2，不需要查询归属地
    // 超过最大长度，不需要查询归属地，ip前缀(17900)+11位手机号，有归属地；
    // 大于20位不在查询归属地
    if (newNumber.length <= QUERY_LOCATION_PHONE_NUMBER_MIN_LEN ||
      newNumber.length > QUERY_LOCATION_PHONE_NUMBER_MAX_LEN) {
      HiLog.w(TAG, 'The location is not queried.');
      this.numberLocation = '';
      return;
    }
    GetNumberLocation.getNumberLocation(newNumber, (location: string) => {
      this.numberLocation = location;
    }, false)
  }

  telNumberChange() {
    HiLog.w(TAG, 'telNumberChange');
    let newTelNumSize = this.telNumberModel.telNumberChange(this.NUM_TEXT_FONT_SIZE_MAX, this.NUM_TEXT_FONT_SIZE_MIN,
      this.telNumberWithSpace);
    if (this.telNumSize != newTelNumSize) {
      this.telNumSize = newTelNumSize;
      this.telNumSizeVp = this.telNumSize.toString() + 'vp';
    }
  }

  getFormatNumber(number: string) {
    HiLog.w(TAG, 'getFormatNumber');
    let formatNum: string = '';
    this.textValue = number;
    // 只有阿拉伯语才需要格式化
    if (this.language !== 'ar-CN') {
      return number;
    }
    for (let i = 0; i < number.length; i++) {
      if (number[i].match(NUM_REGEX)) {
        formatNum += numFormat(Number(number[i]))
      } else {
        formatNum += number[i];
      }
    }
    return formatNum;
  }

  @Builder
  CustomKeyboardBuilder() {
    Column() {
    }
  }

  build() {
    Row() {
        TextInput({
          text: this.getFormatNumber(this.telNumberWithSpace),
          controller: this.mPresenter.textController
        })
          .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
          .direction(Direction.Ltr)
          .id('dialer_contacts_telNumberInput_textInput')
          .padding(this.isVerde ? 0 : (DisplaySplitUtil.isFoldStatus()) ? undefined :
            this.splitStatus === SplitStatus.DEFAULT ? undefined : 0)
          .fontSize(this.isVerde ? '20vp' : DisplaySplitUtil.isHorizonSplit(this.splitStatus) ||
            DisplaySplitUtil.isVerticalSplit(this.splitStatus) ? '38vp' : this.telNumSizeVp)
          .lineHeight(this.isVerde ? '26vp' : null)
          .key('telNumberInput')
          .caretColor(this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined)
          .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(600)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .backgroundColor(this.isThemeActive ? Color.Transparent : $r('app.color.skin_background_primary'))
          .enableKeyboardOnFocus(false)
          .focusable(this.textInputFocusable)
          .enablePreviewText(false) // 关闭预上屏输入模式，使用onWillInsert/onWillDelete实现键盘输入
          .copyOption(CopyOptions.CROSS_DEVICE)
          .customKeyboard(this.CustomKeyboardBuilder())
          .onTextSelectionChange((selectStart: number, selectEnd: number) => {
            HiLog.w(TAG,
              `selectStart: ${selectStart}, selectEnd: ${selectEnd}, telNumberWithSpace length: ${this.telNumberWithSpace?.length} `);
            this.mPresenter.setTextSelectStatus(selectStart, selectEnd);
            if (this.telNumberWithSpace.length !== selectStart) {
              // 如果光标起始位不等于号码的长度，代表光标在号码的其中某一个位置 让光标显示
              this.textInputFocusable = true;
            }
          })
          .onChange((value: string) => {
            HiLog.w(TAG, `dialer_contacts_telNumberInput_textInput onchange value length: ${value.length}`);
            // Sets the position of the cursor.
            focusControl.requestFocus('telNumberInput');
            if (this.textValue === SECRET_CODE_MMI_IMEI_DISPLAY) {
              clearInterval(this.timerId)
              this.timerId = setInterval(() => {
                if (DialerPresenter.getInstance().isShowImeiPanel) {
                  this.isShowImeiPanel = true;
                  clearInterval(this.timerId)
                }
              }, 50)
            }
            this.textInputFocusable = this.telNumberModel.setCursor(this.textValue, this.isPasteShowCursor,
              this.textInputController, this.textInputFocusable, this.telNumberWithSpace);
            this.getLocation(this.telNumberWithSpace)
          })
          .onTouch(() => {
            this.textInputFocusable = true;
          })
          .onDrop((dragEvent?: DragEvent) => {
            if (dragEvent) {
              let records: UDC.UnifiedRecord[] = dragEvent.getData().getRecords();
              HiLog.w(TAG, `onDrop records length: ${records?.length}`);
              // records 获取统一数据即所有数据
              let str: string = '';
              for (let i = 0; i < records.length; i++) {
                let record = records[i];
                HiLog.w(TAG, `type: ${record.getType()}`);
                if (record.getType() == UTD.UniformDataType.PLAIN_TEXT) {
                  let plainText = record as UDC.PlainText;
                  let value: string = plainText.textContent;
                  if (!StringUtil.isEmpty(value)) {
                    str += value;
                  }
                } else if (record.getType() == UTD.UniformDataType.TEXT) {
                  let text = record as UDC.Text;
                  let value: string | undefined = text.details?.content;
                  if (!StringUtil.isEmpty(value)) {
                    str += value;
                  }
                }
              }
              HiLog.w(TAG, `str length is: ${str?.length} `);
              let data: UDC.PlainText = new UDC.PlainText();
              // Replace illegal symbols
              const filterResult = str.replace(new RegExp('[^0-9*#＊＃+\\-,;]', 'g'), '')
                .replace(new RegExp('[＊]', 'g'), '*')
                .replace(new RegExp('[＃]', 'g'), '#');
              this.mPresenter.replaceSelectedStr(this.telNumberWithSpace, filterResult); //设置光标
              data.textContent = filterResult;
              dragEvent.setData(new UDC.UnifiedData(data));
            }
            focusControl.requestFocus('telNumberInput');
          })
          .onCut((value: string) => {
            // 点击剪切板剪切按钮，触发该回调
            HiLog.w(TAG, `onCut!`);
            AppStorage.SetOrCreate('isDialerInputCut', true);
          })
          .onPaste((value: string, event?: PasteEvent) => {
            this.telNumberModel.paste(value, this.telNumberWithSpace, event);
          })
          .onClick(() => {
            AppStorage.setOrCreate('showDialBtn', true);
            this.textInputFocusable = true;
          })
          .onWillInsert((value: InsertValue) => { // 拦截键盘输入
            let curTime: number = new Date().getTime();
            if (curTime - this.lastInputTime <= DOUBLE_INPUT_INTERVAL_TIME) {
              HiLog.e(TAG, `onWillInsert double input: ${value.insertValue}`);
              return false;
            }
            this.lastInputTime = curTime;
            if (regex.test(value.insertValue)) {
              this.mPresenter.isKeyboardInput = true;
              const newVal = this.mPresenter.getInsertStr(this.telNumberWithSpace, value.insertValue);
              this.mPresenter.textSelectStart++;
              this.mPresenter.textSelectEnd++;
              //不带空格 用于搜索通话记录 1.先去除空格 再存入tele_number中
              AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, newVal);
            }
            return false;
          })
          .onWillDelete((value: DeleteValue) => { // 拦截键盘删除
            let number: string = AppStorage.has(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) ?
              AppStorage.get(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE) as string : '';
            number = this.mPresenter.deleteStr(number); //删除之后的号码
            AppStorage.SetOrCreate(DialerConstant.DIALER_TEL_NUMBER_WITH_SPACE, number);
            return false;
          })
    }
    .width('100%')
    .height('auto')
  }
}