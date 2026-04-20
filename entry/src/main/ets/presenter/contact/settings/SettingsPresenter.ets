/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';
import fileIo from '@ohos.file.fs';
import fs from '@ohos.file.fs';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import StringFormatUtil from '../../../util/StringFormatUtil';
import ArrayList from '@ohos.util.ArrayList';
import { BusinessError } from '@ohos.base';
import VCardUtil from '../../../util/VCardUtil';
import { transWordsInVCard } from '../../../util/VcardParseUtil';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import emitter from '@ohos.events.emitter';
import { SetConstants } from '../../../../../../../common/src/main/ets/SetConstants';
import LooseObject from '../../../model/type/LooseObject';
import { DynamicLoader, sharedPreferencesUtils } from '../../../../../../../feature/call/oh_modules/common';
import { mergeDuplicateContactsByUrl } from '../../../task/TaskService';
import { PrivacyStatementContentTag } from './PrivacyStatementPresenter';
import { ability } from '@kit.AbilityKit';
import EmitterConstant from '../../../data/EmitterConstant';
import { taskpool } from '@kit.ArkTS';
import { ExportContactPickerUtil } from '../../../pages/contacts/settings/ImportVcardBindSheet';
import { common } from '@kit.AbilityKit';

const TAG = 'SettingsPresenter  ';

const FILEPATH = '/data/storage/el4/base/files';
const TMPFILEFOLDER = 'importTmp'
const TMPFILENAME = 'importTmpFile.vcf'

export default class SettingsPresenter {
  public pathInfos?: NavPathStack;
  private static sInstance: SettingsPresenter;
  public total: number = 0;
  private importFlag = true;
  private no4VCF: string = 'no4VCF';

  private constructor() {
  }

  public static getInstance(): SettingsPresenter {
    if (SettingsPresenter.sInstance == null) {
      HiLog.i(TAG, 'SettingsPresenter getInstance!');
      SettingsPresenter.sInstance = new SettingsPresenter();
    }
    return SettingsPresenter.sInstance;
  }

  initNavPaths(pageInfos: NavPathStack) {
    this.pathInfos = pageInfos;
    return this;
  }

  aboutToAppear() {
    HiLog.i(TAG, 'SettingsPresenter aboutToAppear!');
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'SettingsPresenter aboutToDisappear!');
  }

  importAndExport() {
    HiLog.i(TAG, 'ImportAndExport !!');
    DynamicLoader.getInstance().fire(DynamicLoader.IMPORT_AND_EXPORT_PAGE, true).then(() => {
      this.pathInfos?.pushPathByName('ImportAndExport', '');
    });
  }

  arrangeContacts() {
    HiLog.i(TAG, 'ArrangeContacts !!');
    DynamicLoader.getInstance().fire(DynamicLoader.ARRANGE_CONTACTS_PAGE, true).then(() => {
      this.pathInfos?.pushPathByName('ArrangeContacts', '');
    });
  }

  accountList() {
    HiLog.i(TAG, 'AccountList !!');
    DynamicLoader.getInstance().fire(DynamicLoader.ACCOUNT_LIST_PAGE, true).then(() => {
      this.pathInfos?.pushPathByName('AccountList', '');
    });
  }

  recentDelete() {
    HiLog.i(TAG, 'RecentDelete !!');
    DynamicLoader.getInstance().fire(DynamicLoader.RECENT_DELETE_PAGE, true).then(() => {
      this.pathInfos?.pushPathByName(DynamicLoader.RECENT_DELETE_PAGE, '');
    });
  }

  static queryVCF() {
    HiLog.i(TAG, 'queryVCF start!!');
    let fileDetailList: ArrayList<FileInfo> = new ArrayList();
    try {
      let options: LooseObject = {
        'listNum': 0,
        'recursion': false,
        'filter': {
          'suffix': ['.vcf']
        }
      }
      let fileNames = fs.listFileSync(FILEPATH, options)
      fileDetailList = SettingsPresenter.fileInfo(fileNames, FILEPATH)
    } catch (e) {
      HiLog.e(TAG, 'queryVCF error,code is :' + (e as BusinessError).code, ' ,message is :',
        (e as BusinessError).message)
    }

    return fileDetailList;
  }

  static fileInfo(fileNames: string[], filePath: string) {
    let fileDetailList = new ArrayList<FileInfo>();
    fileNames.forEach(filename => {
      let stat = fs.statSync(filePath + '/' + filename)
      if (!stat.isDirectory()) {
        let date = new Date(stat.ctime * 1000);
        let dateString = StringFormatUtil.formatLocaleDateString(date.toLocaleDateString());
        fileDetailList.add(new FileInfo(filename, dateString, stat.ctime));
      }
    });
    return fileDetailList;
  }

  // 清理临时文件
  clearTmpFile(callback: Function) {
    let file = FILEPATH + '/' + TMPFILEFOLDER;
    fs.rmdir(file, () => {
      callback?.();
    });
  }

  importVCF(fileNames: ArrayList<string>, contactsIsMore: Boolean, accountId: number, isInSandbox: Boolean = true) {
    HiLog.w(TAG, `importVCF isInSandBox: ${isInSandbox} fileCount:${fileNames.length}`);
    // 每次导入前重置状态
    this.importFlag = true;
    if (!fileNames.length) {
      this.event(isInSandbox ?
        EmitterConstant.EMITTER_IMPORT_SANDBOX_EVENT_ID :
        EmitterConstant.EMITTER_IMPORT_PICKER_EVENT_ID,
        true);
    }
    fileNames.forEach((fileName, index) => {
      let file: string;
      if (isInSandbox) {
        file = FILEPATH + '/' + fileName;
      } else {
        try {
          const tmpFolderPath = FILEPATH + '/' + TMPFILEFOLDER;
          if (!fileIo.accessSync(tmpFolderPath)) {
            try {
              fileIo.mkdirSync(tmpFolderPath);
            } catch (mkdirError) {
              HiLog.w(TAG, `mkdirSync tmpFolder may already exist: ${mkdirError?.message}`);
            }
          }
          const srcFile = fileIo.openSync(fileName, fileIo.OpenMode.READ_ONLY);
          file = FILEPATH + '/' + TMPFILEFOLDER + '/' + TMPFILENAME + srcFile.name;
          const dstFile = fileIo.openSync(file, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
          try {
            fileIo.copyFileSync(srcFile.fd, dstFile.fd);
          } catch (e) {
            HiLog.e(TAG, `copyFile error:${e?.message}, stack: ${e?.stack}`);
          } finally {
            fileIo.closeSync(srcFile)
            fileIo.closeSync(dstFile)
          }
        } catch (error) {
          HiLog.e(TAG, `importVCF outside sandBox err: ${error?.code}-${error?.message}`);
          return;
        }
      }
      taskpool.execute(transWordsInVCard, file, 0).then((fileAfterTrans) => {
        if (typeof fileAfterTrans !== 'string') {
          return;
        }
        let importExport = getContext(this) as common.UIAbilityContext;
        VCardUtil.importVCard(importExport, fileAfterTrans, accountId, (success: boolean) => {
          HiLog.w(TAG, `importVCard result: ${success}`);
          fs.rmdir(fileAfterTrans);
          if (!isInSandbox) {
            fs.rmdir(file);
          }
          if (contactsIsMore) {
            if (success) {
              HiLog.w(TAG, 'VCARD importVCF success!    index:' + index + '  fileNames.length:' + fileNames.length);
              if (index == fileNames.length - 1) {
                this.importFlag = true;
                const eventId = isInSandbox ?
                EmitterConstant.EMITTER_IMPORT_SANDBOX_EVENT_ID :
                EmitterConstant.EMITTER_IMPORT_PICKER_EVENT_ID;
                this.event(eventId, this.importFlag, index);
              }
            } else {
              this.importFlag = false;
              const eventId = isInSandbox ?
              EmitterConstant.EMITTER_IMPORT_SANDBOX_EVENT_ID :
              EmitterConstant.EMITTER_IMPORT_PICKER_EVENT_ID;
              this.event(eventId, false, index, fileName, fileNames.length);
            }
          } else {
            // 少量导入也要在完成后发事件，便于前端提示“导入完成/失败”
            this.importFlag = this.importFlag && success;
            if (index == fileNames.length - 1) {
              const eventId = isInSandbox ?
              EmitterConstant.EMITTER_IMPORT_SANDBOX_EVENT_ID :
              EmitterConstant.EMITTER_IMPORT_PICKER_EVENT_ID;
              this.event(eventId, this.importFlag, index, fileName, fileNames.length);
            }
          }
          if (index == fileNames.length - 1) {
            // 触发自动合并
            HiLog.w(TAG, 'SettingsPresenter autoMerge');
            SettingsPresenter.getInstance().autoMerge();
          }
        })
      })

    });
  }

  event(eventId: number, vCardFlag: boolean, index?: number, fileName?: string, length?: number) {
    let eventData: emitter.EventData = {
      data: {
        'vCardFlag': vCardFlag,
        'index': index,
        'fileName': fileName,
        'length': length,
      }
    };
    let innerEvent: emitter.InnerEvent = {
      eventId: eventId,
      priority: emitter.EventPriority.HIGH
    };
    emitter.emit(innerEvent, eventData);
  }

  exportVCF(accountIds: string[], contactsIsMore: Boolean, curNo4VCF: number) {
    let predicates = new dataSharePredicates.DataSharePredicates();
    let exportExport = getContext(this) as common.UIAbilityContext;
    predicates.notEqualTo('is_deleted', 1);
    if (accountIds.length > 0) {
      predicates.and().in('account_id', accountIds)
    }

    // 导出所有联系人时，不导出我的名片
    predicates.notEqualTo('primary_contact', '1');

    VCardUtil.exportVCard(exportExport, predicates, async (success: boolean) => {
      await this.changeFileName(curNo4VCF);
      if (contactsIsMore) {
        if (success) {
          this.event(EmitterConstant.EMITTER_EXPORT_EVENT_ID, true);
          HiLog.i(TAG, 'VCARD exportVCF success!');
        } else {
          this.event(EmitterConstant.EMITTER_EXPORT_EVENT_ID, false);
          HiLog.e(TAG, 'VCARD exportVCF error!')
        }
      }
    })
  }

  // 导出vcf文件后修改文件名称
  async changeFileName(curNo4VCF: number) {
    const newFilename = `0000${curNo4VCF}.vcf`;
    const fileList: FileInfo[] = SettingsPresenter.queryVCF().convertToArray()
    fileList.sort((a: FileInfo, b: FileInfo) => a.statCtime - b.statCtime)
    const lastFile = fileList.pop();
    const lastFileName = lastFile?.filename;
    let srcFile = FILEPATH + '/' + lastFileName;
    let dstFile = FILEPATH + '/' + newFilename;
    let transResult = await taskpool.execute(transWordsInVCard, srcFile, 1);
    if (typeof transResult === 'string') {
      fs.renameSync(transResult as string, dstFile);
      ExportContactPickerUtil.saveToFileManager(dstFile, newFilename, this.no4VCF, curNo4VCF)
    }
    fs.rmdir(srcFile);

  }

  getLevel(): number {
    let level = SetConstants.LEVEL_TWO;
    if (this.total <= SetConstants.TOTAL_TEN) {
      level = SetConstants.LEVEL_ZERO;
    } else if (this.total <= SetConstants.TOTAL_ONE_HUNDRED) {
      level = SetConstants.LEVEL_ONE;
    } else if (this.total <= SetConstants.TOTAL_FIVE_HUNDRED) {
      level = SetConstants.LEVEL_TWO;
    } else if (this.total <= SetConstants.TOTAL_ONE_THOUSAND) {
      level = SetConstants.LEVEL_THREE;
    } else {
      level = SetConstants.LEVEL_FOUR;
    }
    return level;
  }

  importProgress(percent: number): number {
    switch (this.getLevel()) {
      case SetConstants.LEVEL_ZERO:
        percent += SetConstants.PERCENT_TEN;
        break
      case SetConstants.LEVEL_ONE:
        percent += SetConstants.PERCENT_EIGHT;
        break
      case SetConstants.LEVEL_TWO:
        percent += SetConstants.PERCENT_SIX;
        break
      case SetConstants.LEVEL_THREE:
        percent += SetConstants.PERCENT_FIVE;
        break
      case SetConstants.LEVEL_FOUR:
        percent += SetConstants.PERCENT_TWO;
        break
      default:
        break
    }
    return percent;
  }

  exportProgress(percent: number): number {
    switch (this.getLevel()) {
      case SetConstants.LEVEL_ZERO:
        percent += SetConstants.PERCENT_ONE_HUNDRED;
        break
      case SetConstants.LEVEL_ONE:
        percent += SetConstants.PERCENT_FIFTY;
        break
      case SetConstants.LEVEL_TWO:
        percent += SetConstants.PERCENT_THIRTY;
        break
      case SetConstants.LEVEL_THREE:
        percent += SetConstants.PERCENT_TWENTY;
        break
      case SetConstants.LEVEL_FOUR:
        percent += SetConstants.PERCENT_TEN;
        break
      default:
        break
    }
    return percent;
  }

  autoMerge() {
    let mergeExport = getContext(this) as common.UIAbilityContext;
    mergeDuplicateContactsByUrl(mergeExport);
  }

  cancel() {
    let parameters: Record<string, string> = {
      'contactObjects': ''
    };
    const wantPara: Record<string, Record<string, string>> = {
      'parameters': parameters
    }
    const result: ability.AbilityResult = {
      'resultCode': 0,
      'want': wantPara
    };

    ContactsGlobalThisHelper.GetGlobalThis().getDefaultUIContext()?.terminateSelfWithResult(result)
      .then(() => {
        HiLog.i(TAG, 'terminateSelfWithResult Operation succeeded: ');
      })
      .catch((error: BusinessError) => {
        HiLog.e(TAG, 'Operation failed. Cause: %s', error?.message);
      });
  }
}

export class FileInfo {
  public filename: string;
  public date: Resource | string;
  public statCtime: number;

  constructor(filename: string, date: Resource | string, statCtime: number) {
    this.filename = filename;
    this.date = date;
    this.statCtime = statCtime;
  }
}