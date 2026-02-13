/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import ArrayList from '@ohos.util.ArrayList';
import { BusinessError } from '@ohos.base';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';

import { FileInfo } from '../../../presenter/contact/settings/SettingsPresenter';
import { FontScaleState } from '../../../util/fontScaleState';
import { OperationType, SubHeader } from '@ohos.arkui.advanced.SubHeader';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog'
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper'
import { StringUtil } from '../../../../../../../common/src/main/ets/util/StringUtil';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { LengthMetrics } from '@kit.ArkUI';
import prompt from '@ohos.promptAction';
import { sharedPreferencesUtils } from '../../../../../../../feature/call/oh_modules/common';
import EnvironmentProp from '../../../feature/EnvironmentProp';

const TAG: string = 'ImportVcardBindSheetContent'
const saveDefaultPath: string = 'file://docs/storage/Users/currentUser/Documents'

@Component
export default struct importVcardBindSheetContent {
  @Link builder: ImportVcardBindSheetBuilder;
  @Link filesFromPicker: ArrayList<string>;
  @State selectInfoFromPicker: string = '';
  @Link fileNamesInSandBox: ArrayList<string>;
  @State private selectItems: boolean[] = [];
  private allSelect: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageLink('breakpoint') curBp: string = 'sm';
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  itemPadding(): Padding {
    return {
      left: $r('app.float.id_card_margin_large'),
      right: $r('app.float.id_card_margin_large'),
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        0, $r('app.float.id_card_item_margin_top')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        0, $r('app.float.id_card_item_margin_top'))
    }
  }

  @Builder
  selectFromPickerView() {
    ListItemGroup({ style: ListItemGroupStyle.CARD }) {
      ListItem() {
        this.selectFromPickerViewItem();
      }
    }
  }

  @Builder
  selectFromPickerViewItem() {
    Row() {
      Column() {
        Text(ResourceUtil.getStringByResource($r('app.string.select_from_storage_device')))
          .constraintSize({ minHeight: '21vp' })
          .textAlign(TextAlign.Start)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('app.color.skin_font_primary'))
          .fontWeight(FontWeight.Medium)

        Text(this.selectInfoFromPicker)
          .textAlign(TextAlign.Start)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontColor($r('app.color.skin_font_secondary'))
          .fontWeight(FontWeight.Regular)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize($r('app.float.id_card_image_small'))
        .fontColor([$r('app.color.skin_icon_fourth')])
        .flexShrink(0)
        .margin({
          start: LengthMetrics.resource($r('app.float.id_card_margin_large'))
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .constraintSize({ minHeight: 64 })
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .padding({
      left: $r('app.float.id_card_margin_large'),
      right: $r('app.float.id_card_margin_large'),
      top: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        0, $r('app.float.id_card_item_margin_top')),
      bottom: FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
        0, $r('app.float.id_card_item_margin_top'))
    })
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .padding(this.itemPadding())
    .onClick(() => {
      HiLog.i(TAG, `import from picker clicked`);
      ImportPickerUtil.importFromPicker(this.filesFromPicker, () => {
        HiLog.i(TAG, 'importFromPicker');
        this.selectInfoFromPicker = this.getPickerSelectInfo();
      });
    })
    .constraintSize({
      minHeight: StringUtil.isEmpty(this.selectInfoFromPicker) ?
      $r('app.float.id_item_height_mid') :
      $r('app.float.id_item_height_max')
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
  }

  @Builder
  selectFromSandBoxView() {
    SubHeader({
      secondaryTitle: $r('app.string.vcard_files_in_app'),
      operationType: OperationType.BUTTON,
      operationItem: [{
        value: $r('app.string.select_all'), action: () => {
          this.selectAllSandBox();
        }
      }]
    })
      .onClick(() => {
        HiLog.i(TAG, 'select all clicked');
        this.selectAllSandBox();
      })
    ListItemGroup({ style: ListItemGroupStyle.CARD }) {
      ForEach(this.builder.vcardItems.convertToArray(), (item: FileInfo, index: number) => {
        this.selectFromSandBoxViewItem(item, index)
      })
    }
  }

  @Builder
  selectFromSandBoxViewItem(item: FileInfo, index: number) {
    Row() {
      Column() {
        Text(item.filename)
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('app.color.skin_font_primary'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: $r('sys.float.padding_level1') })

        Text(item.date)
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontColor($r('app.color.skin_font_secondary'))
          .fontWeight(FontWeight.Regular)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .flexShrink(1)

      Column() {
        Checkbox({ name: 'checkbox' + index })
          .select(this.selectItems[index])
          .width('24vp')
          .height('24vp')
          .selectedColor($r('app.color.skin_comp_background_emphasize'))
          .margin($r('sys.float.padding_level0'))
          .padding($r('sys.float.padding_level1'))
          .onChange((value: boolean) => {
            this.sandboxFileOnSelect(item, index, value);
          })
      }
      .padding({ left: $r('sys.float.padding_level4') })
      .flexShrink(0)
    }
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .padding(this.itemPadding())
    .constraintSize({
      minHeight: $r('app.float.id_item_height_max')
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .onClick(() => {
      this.selectItems[index] = !this.selectItems[index];
      this.allSelect = true;
      for (let i = 0; i < this.builder.vcardItems.length; i++) {
        this.allSelect = this.allSelect && this.selectItems[i];
        if (!this.allSelect) {
          break;
        }
      }
    })
  }

  @Builder
  confirmBtn() {
    Column() {
      Button($r('app.string.confirm'))
        .onClick(() => {
          HiLog.i(TAG, 'Import Confirmed');
          this.builder.onConfirm?.();
        })
        .height($r('sys.float.ohos_id_button_height'))
        .width('100%')
        .backgroundColor(this.isThemeActive ? $r('app.color.skin_ohos_id_color_button_normal') : $r('sys.color.comp_background_tertiary'))
        .fontColor($r('app.color.skin_font_emphasize'))
    }.height('100%')
    .padding({ top: this.curBp === 'sm' ? 8 : 36, left: 16, right: 16 })
  }

  build() {
    Column() {
      List() {
        this.selectFromPickerView()

        this.selectFromSandBoxView()
      }
      .height(`calc(100% - 92vp)`)

      this.confirmBtn()
    }.height('100%')
  }

  getPickerSelectInfo(): string {
    HiLog.i(TAG, 'getPickerSelectInfo');
    if (!this.filesFromPicker.length) {
      return '';
    }
    let firstFile: fs.File = fs.openSync(this.filesFromPicker[0], fs.OpenMode.READ_ONLY);
    let firstFileName: string = '';
    try {
      firstFileName = firstFile.name;
    } catch (e) {
      HiLog.e(TAG, 'getFileName error');
    } finally {
      fs.closeSync(firstFile);
    }
    if (this.filesFromPicker.length == 1) {
      return ResourceUtil.getStringByResource($r('app.string.have_select_sth'), firstFileName);
    } else {
      const nFiles = ResourceUtil.getPluralStringByResource($r('app.plural.n_files'), this.filesFromPicker.length);
      return nFiles;
    }
  }

  selectAllSandBox() {
    this.allSelect = !this.allSelect;
    for (let i = 0; i < this.builder.vcardItems.length; i++) {
      this.selectItems[i] = this.allSelect;
    }
  }

  sandboxFileOnSelect(item: FileInfo, index: number, value: boolean) {
    this.selectItems[index] = value;
    if (value) {
      this.fileNamesInSandBox.add(item.filename)
    } else {
      this.fileNamesInSandBox.remove(item.filename)
      this.allSelect = false;
    }
  }
}

export class ImportVcardBindSheetBuilder {
  public vcardItems: ArrayList<FileInfo> = new ArrayList();
  public accountId: number = -1;
  public onConfirm: () => void = () => {};
}

export class ImportPickerUtil {
  static importFromPicker(filesFromPicker: ArrayList<string>, callBack?: Function) {
    let documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.defaultFilePathUri = saveDefaultPath;
    documentSelectOptions.fileSuffixFilters = ['vcf']
    let docPicker: picker.DocumentViewPicker =
      new picker.DocumentViewPicker(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    docPicker.select(documentSelectOptions).then((documentSelectResult: string[]) => {
      filesFromPicker.clear();
      documentSelectResult.forEach(element => {
        filesFromPicker.add(element);
      });
      callBack?.();
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'document select error: ' + err?.message + ', stack: ' + err?.stack);
      callBack?.();
    })
  }
}

// 导出vCard保存至文件管理
export class ExportContactPickerUtil {
  static saveToFileManager(path: string, newFileName: string, no4VCF: string, curNo4VCF: number) {
    let documentSelectOptions = new picker.DocumentSaveOptions();
    let newFilenameList: string[] = []
    newFilenameList.push(newFileName)
    documentSelectOptions.newFileNames = newFilenameList
    documentSelectOptions.defaultFilePathUri = saveDefaultPath
    let docPicker: picker.DocumentViewPicker =
      new picker.DocumentViewPicker(ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext());
    let dstFd: number = -1;
    let srcFd: number = -1;
    docPicker.save(documentSelectOptions).then(async (data: string[]) => {
      HiLog.w(TAG, `saveToFileManager success`)
      if (data.length === 0) {
        HiLog.e(TAG, `saveToFileManager error: filePicker returned empty data, user may have cancelled`);
        return;
      }
      if (data[0].length === 0) {
        HiLog.e(TAG, `saveToFileManager error: data is invalid`);
        return;
      }
      dstFd = (await fs.open(data[0], fs.OpenMode.READ_WRITE)).fd;
      srcFd = (await fs.open(path)).fd;
      HiLog.w(TAG, `saveToFileManager, open file: ${dstFd}, ${srcFd}`);
      await fs.copyFile(srcFd, dstFd);
      prompt.showToast({
        message: $r('app.string.export_succeed'),
        duration: 1000,
        bottom: EnvironmentProp.isPC() ? 120 : 80
      });
      sharedPreferencesUtils.saveToPreferences(no4VCF, curNo4VCF + 1);
    })
      .catch((err: BusinessError) => {
        HiLog.e(TAG, `saveToFileManager error ${err?.message}`)
      })
      .finally(async () => {
        if (dstFd > 0) {
          fs.close(await dstFd);
        } else {
          HiLog.e(TAG, `saveToFileManager dstFd: ${dstFd} is invalid`);
        }
        if (srcFd > 0) {
          fs.close(await srcFd);
        } else {
          HiLog.e(TAG, `saveToFileManager srcFd: ${srcFd} is invalid`);
        }
      })
  }
}