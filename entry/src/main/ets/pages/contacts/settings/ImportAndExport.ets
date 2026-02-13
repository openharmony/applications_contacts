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

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import SettingsPresenter, { FileInfo } from '../../../presenter/contact/settings/SettingsPresenter';
import { Params } from '../../../../../../../feature/call/oh_modules/common/src/main/ets/Constants';
import ArrayList from '@ohos.util.ArrayList';
import emitter from '@ohos.events.emitter';
import prompt from '@ohos.promptAction';
import SelectAccountDialog from '../../dialog/SelectAccountDialog';
import ArrangeContactsPresenter from '../../../presenter/contact/settings/ArrangeContactsPresenter';
import { sharedPreferencesUtils } from '../../../../../../../feature/call/oh_modules/common';
import CopyContactDialog from '../../dialog/CopyContactDialog';
import { CustomizedParams } from '../../../model/type';
import { CustomContentDialog, LoadingDialog } from '@ohos.arkui.advanced.Dialog';
import DotUtil from '../../../util/DotUtil';
import CustomProgressContent from '../../dialog/CustomProgressContent';
import { AccountVo } from '../../../model/bean/AccountVo';
import fs from '@ohos.file.fs';
import { ResourceUtil } from '../../../util/ResourceUtil';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader';
import LooseObject from '../../../model/type/LooseObject';
import { FontScaleState } from '../../../util/fontScaleState';
import { SymbolGlyphModifier, TextModifier } from '@ohos.arkui.modifier';
import { defaultCustomTheme } from '../../../data/ThemeColorConstant';
import dotCommon, { customParams, exportContactParams, importContactParams } from '../../../util/DotCommon';
import VCardUtil from '../../../util/VCardUtil'
import importVcardBindSheetContent, { ImportVcardBindSheetBuilder, ImportPickerUtil } from './ImportVcardBindSheet'
import EmitterConstant from '../../../data/EmitterConstant';
import { LengthMetrics } from '@kit.ArkUI';
import { DialogControllerManager } from '../../../MainAbility/ControllerManager';
import simIccDiallingNumbers from '../../../feature/sim/SimIccDiallingNumbers';
import telephonySim from '@ohos.telephony.sim';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import promptAction from '@ohos.promptAction';
import { contextConstant } from '@kit.AbilityKit';
import EnvironmentProp from '../../../feature/EnvironmentProp';
// import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit'
// import { HdsNavDestinationTitleMode } from '@hms.hds.hdsBaseComponent';
// import TitleBarUtil, { TitleBarParams } from '../../../util/TitleBarUtil';

const TAG = 'ImportAndExport  ';
const ORGANIZE_AUTOMERGE_DIALOG_EVENT = 'ORGANIZE_AUTOMERGE_DIALOG_EVENT';
const NEW_FILEPATH = '/data/storage/el4/base/files/';

class MainTitleTextModfier extends TextModifier {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor($r('app.color.skin_ohos_id_color_text_primary'))
  }
}

enum ImportCompleteFlag {
  COMPLETE_FLAG_SANDBOX = 1,
  COMPLETE_FLAG_DOCMANER = 1 << 1,
  COMPLETE_FLAG_ALL = 1 << 1 | 1,
  COMPLETE_FLAG_NONE = 0
}

/*
 * Methods of exposure to the outside world, used to dynamic load page
 */
@Builder
export function ImportAndExportLoader($$: Params): void {
  ImportAndExport();
}

/*
 * import/export page component statement
 */
@Component
export default struct ImportAndExport {
  // path parameter
  @Consume('contactsSettingsNavStack') contactsSettingsNavStack: NavPathStack;
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  @StorageProp('simStateUpdated') @Watch('simChange') simStateUpdated: number = 0;
  presenter: SettingsPresenter = SettingsPresenter.getInstance();
  aPresenter: ArrangeContactsPresenter = ArrangeContactsPresenter.getInstance();
  isCancelExportVcardDiaShow: boolean = false;
  isProgressDiaShow: boolean = false;
  // maxExportContactsNum
  private maxExportContactsNum: number = 100;
  private maxImportContactsNum: number = 100;
  private no4VCF: string = 'no4VCF';
  private defNo4VCF: number = 1;
  @State fileNames: ArrayList<string> = new ArrayList();
  @State filesFromPicker: ArrayList<string> = new ArrayList();
  @State accountIds: ArrayList<string> = new ArrayList();
  @State percent: number = 0;
  @State simCount: number = 0;
  @State simNoCount: number = 0;
  @State simCardEmptySlot: number = 0;
  @State simCardExistenceSlot: number = 0;
  percentFloat: number = 0;
  dialogMsg: Resource = $r('app.string.searching_for_vCard_files_in_storage_device');
  organizeAutoDialogParams: CustomizedParams = {
    ISKNOW: 0
  };
  isCancelExportContactsDiaShow: boolean = false;
  @State cacheDialogMsg: Resource = $r('app.string.caching_please_wait');
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('spaceLR') spaceLR: Resource = $r('sys.float.padding_level8');
  @State builder: ImportVcardBindSheetBuilder = {
    vcardItems: new ArrayList<FileInfo>(),
    accountId: -1,
    onConfirm: () => {
      this.importSheetShow = false;
      this.importFiles();
    }
  };
  @State accountItems: AccountVo[] = []
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  // 主题字体颜色
  @State mainTitleModifier: MainTitleTextModfier = new MainTitleTextModfier();
  @StorageProp('isTabletLandscape') isTabletLandscape: boolean = false;
  @State importSheetShow: boolean = false;
  @State exportSheetShow: boolean = false;
  @State isShowSimEntry: boolean = false;
  @State simFlag: boolean = false;
  filePathUri: string = '';
  importCompleteFlag: ImportCompleteFlag = ImportCompleteFlag.COMPLETE_FLAG_NONE;
  private isPC: boolean = EnvironmentProp.isPC();
  private scroller: Scroller = new Scroller();
  private isClickImport = false; // sim导入弹窗点击导入
  private isClickCancel = false; // sim导入弹窗点击暂不导入

  aboutToAppear() {
    HiLog.i(TAG, 'the Page ImportAndExport aboutToAppear Begin !!')
    this.getSetupSimCardState(true);
    this.presenter.pathInfos = this.contactsSettingsNavStack;
    this.aPresenter.pathInfos = this.contactsSettingsNavStack;
    this.aPresenter.getAllAccountAndContactSize();
    let context = getContext(this).getApplicationContext();
    context.area = contextConstant.AreaMode.EL4;
    this.filePathUri = `${context.filesDir}/`;
    let baseDir = this.filePathUri.replace(/files\//g, '');
    HiLog.i(TAG, 'baseDir ' + baseDir + ' filePathUri ' + this.filePathUri)
    if (!this.checkFILESDirExists(baseDir)) {
      HiLog.i(TAG, 'Creating the files file');
      try {
        fs.mkdirSync(this.filePathUri);
      } catch (error) {
        HiLog.e(TAG, `mkdirSync fail msg:${error?.message}, stack: ${error?.stack}`);
      }
    }
    this.addEventListener();
    HiLog.i(TAG, 'the Page ImportAndExport aboutToAppear End');
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'the Page ImportAndExport aboutToDisappear Begin !!')
    this.aPresenter.accountList = [];
    emitter.off(EmitterConstant.SETTING_EXPORT_EMITTER_ID);
    this.simFlag = false;
    HiLog.i(TAG, 'the Page ImportAndExport aboutToDisappear End !!')
  }

  simChange() {
    HiLog.w(TAG, 'the card slot change is detected');
    this.getSetupSimCardState(true);
  }

  progressDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: this.dialogMsg,
      contentBuilder: () => {
        this.ProgressDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.hide'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.progressDialog?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  importVcardDialog: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: this.dialogMsg
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  importCacheDialog: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: this.cacheDialogMsg
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  selectImportAccountDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.import_contacts_to_account'),
      contentBuilder: () => {
        this.SelectImportAccountBuilder();
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            HiLog.w(TAG, 'onShareDialogCancel !!! ');
          }
        }
      ]
    }),
    autoCancel: true,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  })

  importErrDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.unable_import'),
      contentBuilder: () => {
        this.ContentBuilder();
      },
      buttons: [
        {
          value: $r('app.string.got_it'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            // 联系人打点--整理联系人自动合并重复联系人i弹窗点击知道了
            this.organizeAutoDialogParams.ISKNOW = 1;
            DotUtil.getInstance().contactDot(this.organizeAutoDialogParams, ORGANIZE_AUTOMERGE_DIALOG_EVENT);
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  // 拉起文件管理picker
  async startFilePicker() {
    // 联系人打点--联系人设置-点击导入/导出-导出到存储设备-导出
    exportContactParams.ISEXPORT = 1;
    DotUtil.getInstance().contactDot(exportContactParams, dotCommon.eventName.CLICK_EXPORT_CONTACT_EVENT);
    this.accountIds.clear();
    if (this.aPresenter.accountList.length > 0 && SettingsPresenter.getInstance().total > 0) {
      const contactsIsMore: Boolean = SettingsPresenter.getInstance().total > this.maxExportContactsNum;
      const curNo4VCF: number =
        await sharedPreferencesUtils.getFromPreferences(this.no4VCF, this.defNo4VCF) as number;
      this.accountIds.add(this.aPresenter.accountList[0].accountId)
      if (contactsIsMore) {
        this.exportProgress();
        SettingsPresenter.getInstance()
          .exportVCF(this.accountIds.convertToArray(), contactsIsMore, curNo4VCF);
      } else {
        SettingsPresenter.getInstance()
          .exportVCF(this.accountIds.convertToArray(), contactsIsMore, curNo4VCF);
      }
    } else {
    }
  }

  /*
   * Calculate export progress
   */
  exportProgress() {
    this.percent = 0;
    this.percentFloat = 0;
    this.dialogMsg = $r('app.string.exporting_contacts')
    this.progressDialog.open();
    DialogControllerManager.getInstance().addDialogController(this.progressDialog);
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_EXPORT_EVENT_ID
    };

    const exportTotal = SettingsPresenter.getInstance().total;
    const exportTotalTime = 15 * exportTotal - 1000;
    const refreshTime = 500;
    const refreshPercent = refreshTime / exportTotalTime * 100;

    let exportId = setInterval(() => {
      this.percentFloat += refreshPercent;
      if (this.percentFloat < 99) {
        this.percent = Math.min(99, Math.round(this.percentFloat));
      } else {
        if (this.percent != 100) {
          this.percent = 99;
        }
      }
    }, refreshTime);
    emitter.on(innerEvent, (eventData: emitter.EventData) => {
      this.percent = 100;
      this.progressDialog.close();
      DialogControllerManager.getInstance().dialogControllerSet.clear();
      clearInterval(exportId);
      if (!eventData.data?.vCardFlag) {
        prompt.showToast({
          message: $r('app.string.export_failed'),
        });
      }
    });
  }

  checkFILESDirExists(basePath: string): boolean {
    try {
      if (!fs.accessSync(basePath, fs.AccessModeType.EXIST)) {
        HiLog.w(TAG, 'isExist: ' + fs.accessSync(basePath, fs.AccessModeType.EXIST));
        return false;
      }
      let isReadAndWrite = fs.accessSync(basePath, fs.AccessModeType.READ_WRITE);
      HiLog.w(TAG, 'isReadAndWrite: ' + isReadAndWrite);
      if (isReadAndWrite) {
        let dirNames = fs.listFileSync(basePath);
        return dirNames.includes('files');
      } else {
        return false;
      }
    } catch (error) {
      HiLog.e(TAG, `checkFILESDirExists fail msg:${error?.message}`);
      return false;
    }
  }

  /*
   * Calculate export progress
   */
  importProgress(total: number, showDialog: boolean = true) {
    HiLog.w(TAG, 'importProgress total: ' + total);
    this.percent = 0;
    this.percentFloat = 0;
    this.dialogMsg = $r('app.string.importing_contacts')

    const importTotalTime = total * 14.5 - 1000;
    const refreshTime = 500;
    const refreshPercent = refreshTime / importTotalTime * 100;
    let importId: number | null = null;
    if (showDialog) {
      this.progressDialog.open();
      DialogControllerManager.getInstance().addDialogController(this.progressDialog);
      importId = setInterval(() => {
        this.percentFloat += refreshPercent;
        if (this.percentFloat < 99) {
          this.percent = Math.min(99, Math.round(this.percentFloat));
        } else {
          this.percent = 99;
        }
      }, refreshTime);
    }
    let innerEventSandbox: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_IMPORT_SANDBOX_EVENT_ID
    };
    emitter.on(innerEventSandbox, (eventData: emitter.EventData) => {
      HiLog.w(TAG, `innerEventSandbox: ${eventData?.data}`);
      if (eventData.data) {
        this.importCompleteFlag |= ImportCompleteFlag.COMPLETE_FLAG_SANDBOX;
        if (this.importCompleteFlag == ImportCompleteFlag.COMPLETE_FLAG_ALL || !eventData.data.vCardFlag) {
          this.endImportProgress(eventData.data.vCardFlag, eventData.data.fileName);
          if (importId !== null) {
            clearInterval(importId);
          }
        }
      }
    });

    let innerEventPickerBox: emitter.InnerEvent = {
      eventId: EmitterConstant.EMITTER_IMPORT_PICKER_EVENT_ID
    };
    emitter.on(innerEventPickerBox, (eventData: emitter.EventData) => {
      HiLog.w(TAG, `innerEventPickerBox: ${eventData?.data}`);
      if (eventData.data) {
        this.importCompleteFlag |= ImportCompleteFlag.COMPLETE_FLAG_DOCMANER;
        if (this.importCompleteFlag == ImportCompleteFlag.COMPLETE_FLAG_ALL || !eventData.data.vCardFlag) {
          this.endImportProgress(eventData.data.vCardFlag, eventData.data.fileName);
          if (importId !== null) {
            clearInterval(importId);
          }
        }
      }
    })
  }

  endImportProgress(success: boolean, fileName ?: string) {
    this.percent = 100;
    this.progressDialog.close();
    DialogControllerManager.getInstance().dialogControllerSet.clear();
    // 导入完成提示与“导入中”之间增加 1 秒间隔
    setTimeout(() => {
      prompt.showToast({
        message: success ? $r('app.string.import_succeed') :
        $r('app.string.import_failed', fileName),
      });
    }, 1000);
    this.importCompleteFlag = ImportCompleteFlag.COMPLETE_FLAG_NONE;
  }

  async importFiles() {
    if (this.fileNames.length + this.filesFromPicker.length == 0) {
      return;
    }
    let curTotal: number = 0
    if (this.builder.accountId === -1) {
     await sharedPreferencesUtils.getFromPreferences('accountType', 1).then(value => {
       this.builder.accountId = value as number;
     })
    }
    this.fileNames.forEach((fileName, index) => {
      const filePath = NEW_FILEPATH + '/' + fileName;
      const str = fs.readTextSync(filePath);
      curTotal += str.split('END:VCARD').length - 1;
    });
    this.filesFromPicker.forEach((file, index) => {
      curTotal += VCardUtil.getContactCntFromVcard(file);
    });
    const contactsIsMore: Boolean = curTotal > this.maxImportContactsNum;
    if (contactsIsMore) {
      this.importProgress(curTotal);
      SettingsPresenter.getInstance().importVCF(this.filesFromPicker.clone(), true, this.builder.accountId, false);
      SettingsPresenter.getInstance().importVCF(this.fileNames, contactsIsMore, this.builder.accountId);
    } else {
      // 为了在“稍后导入”提示后仍能收到完成提示，这里也监听导入结束事件，但不展示进度弹窗
      this.importProgress(curTotal, false);
      SettingsPresenter.getInstance().importVCF(this.filesFromPicker.clone(), false, this.builder.accountId, false);
      SettingsPresenter.getInstance().importVCF(this.fileNames, contactsIsMore, this.builder.accountId);

      const name = this.filesFromPicker[0].split('/').pop();
      if (name) {
        const curFilename: String = this.filesFromPicker.length === 1 ? decodeURIComponent(name) : 'vCards';
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.will_be_imported_later', curFilename),
          textColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_text_primary') : undefined,
          duration: 1000,
          bottom: this.isPC ? 120 : 80,
          backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_list_card_bg') : undefined,
          backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined
        })
      }
    }
  }

  addEventListener() {
    let exportEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.SETTING_EXPORT_EMITTER_ID,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(exportEvent, (data: emitter.EventData) => {
      if (data.data === undefined || data.data!['percent'] === undefined) {
        if (this.importSimContactsDialogControler) {
          HiLog.w(TAG, 'importSimContactsDialogControler open');
          // 设置 sim 卡导入弹窗
          this.importSimContactsDialogControler?.open();
          DialogControllerManager.getInstance().addDialogController(this.importSimContactsDialogControler);
        }
        this.isProgressDiaShow = false;
        this.simFlag = false;
      } else {
        this.percent = data.data!['percent'];
        if (!this.isProgressDiaShow) {
          this.isProgressDiaShow = true;
          if (this.exportContactsProgressDialogController) {
            this.exportContactsProgressDialogController.open();
            DialogControllerManager.getInstance().addDialogController(this.exportContactsProgressDialogController);
          }
        }
        if (this.percent === 100 || data.data!['cancelImport']) {
          this.isProgressDiaShow = false;
          this.simFlag = false;
          if (this.exportContactsProgressDialogController) {
            this.exportContactsProgressDialogController.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
          if (this.isCancelExportContactsDiaShow) {
            if (this.cancelExportContactsDialogController) {
              this.cancelExportContactsDialogController.close();
              DialogControllerManager.getInstance().dialogControllerSet.clear();
            }
            this.isCancelExportContactsDiaShow = false;
          }
        }
      }
    })
  }

  cancelExportContactsDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      content: $r('app.string.is_stop_import_contact'),
      primaryButton: {
        value: $r('app.string.cancel_stop_import'),
        fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
        action: () => {
          this.isCancelExportContactsDiaShow = false;
        }
      },
      secondaryButton: {
        value: $r('app.string.cancel_stop_import'),
        action: () => {
          simIccDiallingNumbers.sureCancelImport();
          this.isCancelExportContactsDiaShow = false;
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  exportContactsProgressDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      primaryTitle: $r('app.string.importing_contacts'),
      contentBuilder: () => {
        this.ExportContactsProgressDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.hide'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.exportContactsProgressDialogController?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          },
        }
      ]
    }),
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  importSimContactsDialogControler: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      theme: this.isThemeActive ? defaultCustomTheme : undefined,
      contentBuilder: () => {
        this.ImportSimDialogBuilder();
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          fontColor: this.isThemeActive ? $r('app.color.skin_font_emphasize') : undefined,
          action: () => {
            this.isClickCancel = true;
            importContactParams.IMPORT = dotCommon.eventParam.PROMPT_LATER;
            DotUtil.getInstance().contactDot(importContactParams, dotCommon.eventName.SIM_GUIDE_DIALOG_EVENT);
            simIccDiallingNumbers.saveSimContactMark();
            simIccDiallingNumbers.clearContactData();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
            this.simFlag = false;
            this.importSimContactsDialogControler?.close();
          }
        },
        {
          value: $r('app.string.Import'),
          action: () => {
            this.isClickImport = true;
            importContactParams.IMPORT = dotCommon.eventParam.IMPORT;
            DotUtil.getInstance().contactDot(importContactParams, dotCommon.eventName.SIM_GUIDE_DIALOG_EVENT);
            simIccDiallingNumbers.confirmExport(true);
            this.importSimContactsDialogControler?.close();
            DialogControllerManager.getInstance().dialogControllerSet.clear();
          }
        }
      ]
    }),
    onDidDisappear: () => {
      if (!this.isClickImport && !this.isClickCancel) {
        HiLog.w(TAG, `setting SIM dialog onDidDisappear, clear contactData`);
        simIccDiallingNumbers.saveSimContactMark();
        simIccDiallingNumbers.clearContactData();
        DialogControllerManager.getInstance().dialogControllerSet.clear();
        this.isClickImport = false;
        this.isClickCancel = false;
      }
    },
    autoCancel: false,
    backgroundColor: this.isThemeActive ? $r('app.color.skin_ohos_id_color_dialog_bg') : undefined,
    backgroundBlurStyle: this.isThemeActive ? BlurStyle.NONE : undefined,
  });

  private itemGroupArrays: LooseObject[] = [
    {
      headerTitle: $r('app.string.Import'),
      items: [
        {
          title: $r('app.string.import_from_sim_card_title', $r('app.string.str_SIM')),
          index: 0
        },
        {
          title: $r('app.string.import_from_storage_device'),
          subTitle: $r('app.string.import_vCard_files_from_internal_storage'),
          index: 1
        },
      ]
    },
    {
      headerTitle: $r('app.string.Export'),
      items: [
        {
          title: $r('app.string.exporting_data_from_a_storage_device'),
          subTitle: $r('app.string.export_the_vCard_file_to_the_internal_storage'),
          index: 2
        },
      ]
    }
  ]

  private itemGroupIds: string[] = [
    'import_and_export_import_item_list',
    'import_and_export_export_item_list'
  ]

  private getSetupSimCardState(type?: boolean) {
    HiLog.w(TAG, 'getSetupSimCardState start');
    //表示 有联系人信息的 SIM 卡槽数量
    this.simCount = 0;
    //表示 没有联系人信息的 SIM 卡槽数量
    this.simNoCount = 0;
    //表示空的 SIM 卡槽数量，即没有插卡的槽位。
    this.simCardEmptySlot = 0;
    const maxSimCount = telephonySim.getMaxSimCount();
    let processedCount = 0;  // 已处理sim卡数量
    let isEmit = false; // 根据卡中有无联系人，决定是否通知
    let exportEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.SETTING_EXPORT_EMITTER_ID,
      priority: emitter.EventPriority.HIGH
    };
    simIccDiallingNumbers.clearContactData();
    //存在 SIM 卡的槽位数量
    this.simCardExistenceSlot = 0;
    for (let i = 0; i < maxSimCount; i++) {
      telephonySim.isSimActive(i, (err, value) => {
        if (err) {
          HiLog.w(TAG, `isSimActive, ${i} error: ${err?.message}`);
          processedCount++;
          if (processedCount === maxSimCount && isEmit) {
            emitter.emit(exportEvent);
          }
        } else {
          HiLog.w(TAG, `isSimActive, ${i} value: ${value}`);
          if (value) {
            this.simCardExistenceSlot++;
            HiLog.w(TAG, 'simCardExistenceSlot' + this.simCardExistenceSlot);
            if (type) {
              if (this.simCardExistenceSlot) {
                simIccDiallingNumbers.getcontactDataLength(i, (cardSlot?: number) => {
                  if (cardSlot == 0) {
                    this.simCount++;
                    HiLog.w(TAG, 'simState simCount' + this.simCount);
                  } else if (cardSlot == 1) {
                    this.simNoCount++;
                    HiLog.w(TAG, 'simState simNoCount' + this.simNoCount);
                  }
                  if (this.simCount >= 1 || this.simNoCount >= 1) {
                    this.isShowSimEntry = true;
                    HiLog.w(TAG, 'show simCount  ' + this.simCount + ' simNoCount  ' + this.simNoCount);
                  } else {
                    this.isShowSimEntry = false;
                    HiLog.w(TAG, 'not show simCount  ' + this.simCount + 'not simNoCount  ' + this.simNoCount);
                  }
                });
                HiLog.w(TAG, 'getSetupSimCardState Check sim');
              }
            } else {
              this.simFlag = true;
              simIccDiallingNumbers.getNumbersBySlotId(i, 0, (isHasNumbers) => {
                processedCount++;
                if (isHasNumbers) {
                  isEmit = true;
                }
                if (processedCount === maxSimCount && isEmit) {
                  // 所有SIM卡数据处理完毕，触发通知
                  HiLog.i(TAG, 'getNumbers onComplete emitter');
                  emitter.emit(exportEvent);
                } else if (processedCount === maxSimCount) {
                  const msg: Resource = $r('app.string.no_contact_sim_card');
                  promptAction.showToast({
                    message: msg,
                    duration: 2000
                  });
                }
              });
              HiLog.w(TAG, 'getSetupSimCardState import');
            }
          } else {
            this.simCardEmptySlot++;
            HiLog.w(TAG, 'simCardEmptySlot ' + this.simCardEmptySlot);
            processedCount++;
            if (processedCount === maxSimCount && isEmit) {
              emitter.emit(exportEvent);
            }
            if (this.simCardEmptySlot >= 2) {
              this.isShowSimEntry = false;
              HiLog.w(TAG, 'simCardEmptySlot ' + this.isShowSimEntry);
            }
          }
        }
      });
    }
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  @Styles
  normalStyles() {
    .backgroundColor('rgba(255,255,255,0)')
  }

  build() {
    NavDestination() {
      Column() {
        List({ scroller: this.scroller }) {
          ForEach(this.itemGroupArrays, (group: LooseObject, index: number) => {
            SubHeader({
              secondaryTitle: group.headerTitle,
              secondaryTitleModifier: this.isThemeActive ?
              new TextModifier().fontColor($r('app.color.skin_font_secondary')) : undefined,
              contentMargin: {
                start: this.isTabletLandscape ? LengthMetrics.vp(16)
                  : LengthMetrics.resource($r('sys.float.margin_left'))
              }
            })
              .margin({ left: this.curBp === 'lg' ? $r('app.float.id_card_margin_large') : 0 })
              .height(this.isPC ? $r('app.float.id_item_height_sm') : undefined)
            ListItemGroup({ style: ListItemGroupStyle.CARD }) {
              ForEach(group.items, (cardItem: LooseObject) => {
                if (cardItem.index == 0 ? this.isShowSimEntry : true) {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(cardItem.title)
                          .fontSize($r('sys.float.Body_L'))
                          .fontColor($r('app.color.skin_font_primary'))
                          .fontWeight(FontWeight.Medium)
                          .constraintSize({ minHeight: 22 })
                        if (cardItem.subTitle !== undefined) {
                          Text(cardItem.subTitle)
                            .fontSize($r('sys.float.Body_M'))
                            .fontColor($r('app.color.skin_font_secondary'))
                            .fontWeight(FontWeight.Regular)
                            .constraintSize({ minHeight: 19 })
                            .margin({ top: $r('sys.float.padding_level1') })
                        }
                      }
                      .width(`calc(100% - 20vp)`)
                      .constraintSize({
                        minHeight: this.isPC ? $r('app.float.id_item_height_large') :
                        $r('app.float.id_item_height_max')
                      })
                      .alignItems(HorizontalAlign.Start)
                      .justifyContent(FlexAlign.Center)

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
                    .constraintSize({
                      minHeight: this.isPC ? $r('app.float.id_item_height_large') :
                        cardItem.subTitle !== undefined ? $r('app.float.id_item_height_max')
                        : $r('app.float.id_item_height_mid')
                    })
                    .stateStyles({
                      pressed: this.pressedStyles,
                      normal: this.normalStyles
                    })
                    .padding({
                      left: $r('app.float.id_card_margin_large'),
                      right: $r('app.float.id_card_margin_large'),
                      top: cardItem.index == 0 ? this.fontSizeScale > 3 ? $r('app.float.id_card_item_margin_top') : 0 :
                      FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                        0, $r('app.float.id_card_item_margin_top')),
                      bottom: cardItem.index == 0 ?
                        this.fontSizeScale > 3 ? $r('app.float.id_card_item_margin_top') : 0 :
                      FontScaleState.fetchSeniorTopAndBottomSpace(this.fontSizeScale,
                        0, $r('app.float.id_card_item_margin_top'))
                    })
                    .onClick(() => {
                      if (cardItem.index === 0 && index === 0) {
                        if (!this.simFlag) {
                          this.getSetupSimCardState(false);
                          HiLog.w(TAG, 'click sim entry');
                        }
                      } else if (cardItem.index === 1 && index === 0) {
                        ImportPickerUtil.importFromPicker(this.filesFromPicker, () => {
                          this.importFiles();
                        })
                      } else if (cardItem.index === 2 && index === 1) {
                        // 联系人打点--联系人设置-点击导入/导出-从存储设备导入
                        DotUtil.getInstance().contactDot(customParams, dotCommon.eventName.EXPORT_CONTACT_EVENT);
                        this.startFilePicker()
                      }
                    })
                  }
                  .id(this.itemGroupIds[index])
                  .constraintSize({
                    minHeight: cardItem.subTitle !== undefined ? $r('app.float.id_item_height_max')
                      : $r('app.float.id_item_height_mid')
                  })
                }
              }, (item: LooseObject) => JSON.stringify(item))
            }
            .borderRadius(this.isPC ? $r('sys.float.corner_radius_level8') :
            $r('sys.float.corner_radius_level10'))
            .backgroundColor($r('app.color.skin_ohos_id_color_card_bg'))
            .margin({ left: this.spaceLR, right: this.spaceLR })
            .divider({
              strokeWidth: '1px',
              color: $r('app.color.skin_ohos_id_color_list_separator'),
              startMargin: $r('app.float.id_card_margin_large'),
              endMargin: $r('app.float.id_card_margin_large')
            })
          })
        }
        .width('100%')
        .height('100%')
        .flexShrink(1)
        .listDirection(Axis.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .clipContent(ContentClipMode.SAFE_AREA)
        .safeAreaPadding({ top: $r('app.float.id_item_height_max') })
      }
      .flexShrink(1)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.color_bind_sheet_background'))
    }
    // .titleMode(HdsNavDestinationTitleMode.MODAL)
    // .titleBar(TitleBarUtil.getTitleBar(this.getTitleParam(), TitleBarUtil.getBindSheetCloseButton(), () => {
    //   this.contactsSettingsNavStack?.pop();
    // }))
    .title(ResourceUtil.getStringByResource($r('app.string.Import_Export_Contacts')),
      {
        mainTitleModifier: (this.isThemeActive ? this.mainTitleModifier : undefined),
        paddingStart: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource($r('sys.float.margin_left'))
      })
    .menus(this.TitleGuide())
    .onBackPressed(() => {
      this.contactsSettingsNavStack?.pop();
      return true;
    })
    .bindToScrollable([this.scroller])
    .backgroundColor($r('app.color.color_bind_sheet_background'))
    .padding({
      bottom: this.curBp !== 'sm' ? $r('sys.float.padding_level0') : px2vp(this.fullScreenPadding.bottom as number)
    })
  }

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
      .id('ImportAndExport_close_btn')
      .onClick(() => {
        emitter.emit({
          eventId: EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID
        });
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

  // private getTitleParam(): TitleBarParams {
  //   return {
  //     style: this.isPC ? {
  //       scrollEffectOpts: {
  //         enableScrollEffect: false
  //       },
  //       originalStyle: {
  //         backgroundStyle: {
  //           backgroundColor: $r('app.color.color_bind_sheet_background')
  //         }
  //       }
  //     } : undefined,
  //     avoidLayoutSafeArea: false,
  //     padding: { start: this.isPC ? LengthMetrics.vp(16) : LengthMetrics.resource($r('sys.float.margin_left')) },
  //     title: { title: ResourceUtil.getStringByResource($r('app.string.Import_Export_Contacts')) },
  //     backIcon: {isThemeActive: this.isThemeActive, backIcon: true}
  //   };
  // }

  clearTmpFile() {
    this.presenter.clearTmpFile(() => {
      this.importVcard();
    });
  }

  importVcard() {
    let list = SettingsPresenter.queryVCF();
    if (list.length != 0) {
      HiLog.w(TAG, 'VCARD importVcardDialog close');
      this.builder.vcardItems = list;
      if (this.aPresenter.accountList.length == 1) {
        sharedPreferencesUtils.getFromPreferences('accountType', -1).then(value => {
          this.builder.accountId = value as number;
        });
        this.importSheetShow = true;
      } else {
        this.selectImportAccountDialog.open();
        DialogControllerManager.getInstance().addDialogController(this.selectImportAccountDialog);
      }
    } else {
      ImportPickerUtil.importFromPicker(this.filesFromPicker, () => {
        this.importFiles();
      })
    }
  }

  @Builder
  importBindSheet() {
    Column() {
      importVcardBindSheetContent({
        builder: this.builder,
        fileNamesInSandBox: this.fileNames,
        filesFromPicker: this.filesFromPicker,
      }).height('100%')
    }.height('100%').padding({ top: '8vp' })
  }

  @Builder
  exportBindSheet() {
    Column() {
    }
  }

  @Builder
  titleText() {
    Text($r('app.string.Import_Export_Contacts'))
      .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
      .fontWeight(FontWeight.Medium)
      .fontFamily('HarmonyHeiTi')
      .width('100%')
      .height('100%')
  }

  @Builder
  ContentBuilder() {
    Column() {
      Text($r('app.string.no_vcard'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.skin_font_primary'))
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  SelectImportAccountBuilder() {
    Column() {
      CopyContactDialog({
        itemList: this.aPresenter.getAccountNameList(),
        onItemClick: (item: string | Resource) => {
          this.aPresenter.accountList.forEach(accountVo => {
            if (accountVo.accountName == item as string) {
              this.builder.accountId = Number(accountVo.accountId);
            }
          })
          this.builder.vcardItems.length ?
            this.importSheetShow = true :
          ImportPickerUtil.importFromPicker(this.filesFromPicker, () => {
            this.importFiles();
          });
          this.selectImportAccountDialog?.close();
          DialogControllerManager.getInstance().dialogControllerSet.clear();
        }
      })
    }
    .width('100%')
  }

  @Builder
  ProgressDialogBuilder() {
    Column() {
      CustomProgressContent({
        percent: this.percent,
        progressText: this.dialogMsg,
        isShowProgressInfo: false
      })
    }
    .width('100%')
  }

  @Builder
  SelectAccountDialogBuilder() {
    Column() {
      SelectAccountDialog({
        accountItems: this.accountItems,
        accountIds: this.accountIds
      })
    }
    .width('100%')
  }

  @Builder
  ExportDialogBuilder() {
    Column() {
      Scroll() {
        Text($r('app.string.Export_contact_list_to_internal_storage'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.skin_font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
  }

  @Builder
  ImportSimDialogBuilder() {
    Column() {
      Text($r('app.string.contacts_import_from_sim_card_dialog_content'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.skin_font_primary'))
        .textAlign(TextAlign.Start)
    }
    .width('100%')
  }

  @Builder
  ExportContactsProgressDialogBuilder() {
    Column() {
      CustomProgressContent({
        percent: this.percent,
        progressText: $r('app.string.importing_contacts'),
        isShowProgressInfo: false,
      })
    }
    .width('100%')
  }
}