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
import { fileIo as fs, WriteOptions } from '@kit.CoreFileKit';
import hilog from '@ohos.hilog';
import { zlib } from '@kit.BasicServicesKit';

import { buffer } from '@kit.ArkTS';
import cryptoFramework from '@ohos.security.cryptoFramework';
import util from '@ohos.util';
import { HiLog } from '../../../../index';

import { ContactRepository } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';

import { CountAlphabetIndex } from '../../../../../entry/src/main/ets//model/type/ContactParams'
import LooseObject from '../../../../../entry/src/main/ets//model/type/LooseObject'

import ContactListItem from '../../../../../feature/contact/src/main/ets/repo/ContactListItem.ets'

import ContactListActItem from '../../../../../feature/contact/src/main/ets/repo/ContactListActItem.ets'

import { LogAccount } from '../../../../../feature/contact/src/main/ets/repo/ContactRepository';

/**
 * 1、确定写的路径, hap写到共享内存/data/storage/el2/log/audit, sa直接写到 data/log
 * 2、创建 x个log文件, 一个写满, 再写另一个, 依次循环交替写
 * 3、应用写审计日志时, 可能存在1200条/s极限速度, 可以先缓存到某个列表里, 满了后再写到文件里
 * 4、落盘的日志是.csv格式, 内容是按字段写, 以逗号区分, 便于后续的展示
 * 5、限制条件：写到缓存string最大1200条; 一个应用日志限额总默认10M, 2个文件; 每条数据平均200~300字节;
 * 6、文件满后重命名, 然后压缩
 *
 */

/**
 * 增删改操作类型
 */
export enum OperationType {
  OPERATION_DELETE = 'DEL',
  OPERATION_ADD = 'ADD',
  OPERATION_MOVE = 'MOV',
  OPERATION_RENAME = 'RNAME',
  OPERATION_COPY = 'CP'
}

/**
 * 可能原因
 */
export enum Cause {
  USER_BEHAVIOR = 'USER BEHAVIOR',
  DB_CORRUPTION = 'DB CORRUPTION',
  FAILED_TO_READ_FILE = 'FAILED TO READ FILE',
  HWID_LOGOUT = 'HWID LOGOUT',
  FAILED_TO_MOUNT_USER = 'FAILED TO MOUNT USER',
  ACCOUNT = 'ACCOUNT'
}

/**
 * 数据库状态
 */
export enum DataBaseStatus {
  CORRUPTED = 'CORRUPTED',
  NORMAL = 'NORMAL'
}

/**
 * 文件类型, 如音乐/图片/视频等
 */
export enum FileType {
  PICTURE = 'PIC',
  VIDEO = 'VID',
  AUDIO = 'AUD',
  PDF = 'PDF',
  EXE = 'EXE',
  TEXT = 'TXT',
  XLS = 'XLS',
  DOC = 'DOC',
  PPT = 'PPT',
  COMPRESSED = 'ZIP/TAR',
  UNKNOWN = 'UNKNOWN'
}

const TAG = 'AuditLog';
const DOMAIN = 0x0000;
const ONE_DIGITS = 10;
const TWO_DIGITS = 100;

export class AuditLogUtils {
  private static readonly MAX_DISK_LOG_SIZE = 6 * 1024 * 1024; // 一个应用审计日志可存储的最大限额 6M
  private static readonly MAX_SINGLE_FILE_LOG_SIZE = 3 * 1024 * 1024; // 一个日志文件最大限额3M, 存满则进行压缩(约10:1压缩比)
  private static readonly MAX_AUDIT_LOG_SIZE = 2 * 1024; // 一条审计日志最大为 2kb
  private static readonly MAX_LOG_FILE_COUNT = 10; // 落盘日志文件个数, 10个300k约3M
  private static readonly MAX_MEMORY_LOG_COUNT = 1200; // 1200 lines 批量写最大1200条

  private static readonly LOG_PATH_DIR_SANDBOX = '/data/storage/el2/log/audit'; // hap 日志落盘路径
  private static readonly LOG_PATH_DIR_DATA_LOG = '/data/log/hiaudit'; // sa 日志落盘路径

  // 需应用修改
  private static readonly LOG_NAME = 'contacts'; //落盘日志文件名称
  private static readonly LOG_PATH_DIR = AuditLogUtils.LOG_PATH_DIR_SANDBOX; //hap用沙箱, 有system权限的sa直接用/data/log
  private static readonly LOG_FILE_PATH = AuditLogUtils.LOG_PATH_DIR + '/' + AuditLogUtils.LOG_NAME + '_audit.csv';
  private static instance: AuditLogUtils;

  private constructor() {
    this.mkdirSync(AuditLogUtils.LOG_PATH_DIR);
  }

  public auditlog: UtilAuditLog = {
    happenTime: AuditLogUtils.getFormatTime(),
    packageName: 'com.ohos.contacts',
    isForeground: true,
    isUserBehavior: true,
    cause: '',
    operationType: '',
    operationScenario: '',
    operationCount: 0,
    operationStatus: '',
    extend: '',
    key1: '', // 联系人名称的前120bit
    key2: '', // 联系人名称加手机号后6位的前120bit
    contactId: '', // 影响的 contactId
    preContactCount: -1, // 修改前本端联系人总数
    postContactCount: -1, // 修改后联系人总数

    affectedAccount: '', // 影响的账户（原生联系人账户或具体的某个三方联系人账户）
    otherInfo: ''
  };

  public static getInstance(): AuditLogUtils {
    if (!AuditLogUtils.instance) {
      AuditLogUtils.instance = new AuditLogUtils();
    }
    return AuditLogUtils.instance;
  }

  /**
   * 写单条审计日志
   * @param 字段封装类AuditLog
   * @returns true 为写成功
   */
  public writeAuditEvent(log: AuditLog): boolean {
    if (log == null) {
      hilog.error(DOMAIN, TAG, 'audit log is null.');
      return false;
    }

    let auditLogs: string = '';
    let fileSize: number = this.getFileSize(AuditLogUtils.LOG_FILE_PATH);
    if (fileSize === 0) {
      auditLogs = this.getAuditLogKeys(log); // 写title 字段
    }
    auditLogs += this.getAuditLogValues(log); // 日志转化成文本

    // 如果文件满了, 写不下, 需要另存为1个文件, 清空再写新的
    if (((fileSize + auditLogs.length) >= AuditLogUtils.MAX_SINGLE_FILE_LOG_SIZE)) {
      let time: string = AuditLogUtils.getFormatTime();
      let dstFilePath = AuditLogUtils.LOG_PATH_DIR + '/' + AuditLogUtils.LOG_NAME + '_audit_' + time;
      this.cleanUpLogFilePath(AuditLogUtils.LOG_FILE_PATH, dstFilePath, AuditLogUtils.LOG_PATH_DIR);

      fileSize = 0; // 文件清空, 重建一个
      auditLogs = this.getAuditLogKeys(log) + auditLogs; // 文件满了后, 新写文件需要把title也写上
    }

    let writeLen = this.writeToFile(AuditLogUtils.LOG_FILE_PATH, auditLogs);
    return writeLen > 0;
  }

  private writeToFile(filePath: string, logStr: string): number {
    let writeLen = 0;
    let file: fs.File | null = null;

    try {
      file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let size: number = this.getFileSize(filePath);
      let options: WriteOptions = { offset: size, encoding: 'utf-8' };
      writeLen = fs.writeSync(file.fd, logStr, options);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `writrToFile error: code: ${e?.code} message ${e?.message} `);
    } finally {
      if (file != null) {
        fs.closeSync(file);
      }
    }
    return writeLen;
  }

  private writeToFileStream(filePath: string, logStr: string): number {
    let writeLen = 0;
    let writeStreamSync: fs.Stream | undefined;

    try {
      let size: number = this.getFileSize(filePath);
      let options: WriteOptions = { offset: size, length: logStr.length, encoding: 'utf-8' };
      writeStreamSync = fs.createStreamSync(filePath, 'w+');
      writeLen = writeStreamSync.writeSync(logStr, options);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `writrToFile error: code: ${e?.code} message ${e?.message} `);
    } finally {
      if (writeStreamSync != undefined) {
        writeStreamSync.flushSync();
        writeStreamSync.closeSync();
      }
    }
    return writeLen;
  }

  /**
   * 文件写满, 重命名新文件, 个数达到上限时老化最早的一个文件
   * @param srcFilePath
   * @param dstFilePath
   * @param logFileDir
   */
  private cleanUpLogFilePath(srcFilePath: string, dstFilePath: string, logFileDir: string): void {
    try {
      let tmpFilePath: string = dstFilePath + '.csv';
      // 重命名文件
      fs.renameSync(srcFilePath, tmpFilePath);
      // 异步把已满文件压缩File
      this.zipFile(tmpFilePath, dstFilePath + '.zip').then(
        () => {
          // 压缩完把原来文件删除
          fs.unlink(tmpFilePath);
        }
      );

      let logFileList = this.getFileListByOrder(logFileDir);
      while (logFileList.length >= AuditLogUtils.MAX_LOG_FILE_COUNT) {
        let oldestFile = logFileList.pop();
        fs.unlinkSync(oldestFile);
      }

    } catch (e) {
      hilog.error(DOMAIN, TAG, `renameSync or cleanOldestFile error: ${e?.message}`);
    }
  }

  private mkdirSync(dirPath: string): boolean {
    if (this.isFileExist(dirPath) && this.isDirectory(dirPath)) {
      return true;

    }

    try {
      fs.mkdirSync(dirPath);
      return true;
    } catch (e) {
      hilog.error(DOMAIN, TAG, `mkdirSync error: ${e?.message}`);
      return false;
    }
  }

  private isFileExist(filePath: string): boolean {
    let isFileExist: boolean = false;
    try {
      isFileExist = fs.accessSync(filePath);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `file not exist: '${e.code}, ${e.message}`);
    }
    return isFileExist;
  }

  private isFile(filePath: string): boolean {
    let isFile: boolean = false;
    if (this.isFileExist(filePath)) {
      try {
        isFile = fs.statSync(filePath).isFile();
      } catch (e) {
        hilog.error(DOMAIN, TAG, `'isFile error:'${e.code}, ${e.message}`);
      }
    }
    return isFile;
  }

  private isDirectory(filePath: string): boolean {
    let isDir: boolean = false;
    if (this.isFileExist(filePath)) {
      try {
        isDir = fs.statSync(filePath).isDirectory();
      } catch (e) {
        hilog.error(DOMAIN, TAG, `'isDirectory error:'${e.code}, ${e.message}`);
      }
    }
    return isDir;
  }

  private getFileSize(filePath: string): number {
    let size: number = 0;
    try {
      size = fs.statSync(filePath).size;
    } catch (e) {
      hilog.error(DOMAIN, TAG, `getFileSize error: ${e.code}, ${e.message}`);
    }
    return size;
  }

  private getFileLastModifyTime(filePath: string): number {
    let time: number = 0;

    try {
      time = fs.statSync(filePath).mtime;
    } catch (e) {
      hilog.error(DOMAIN, TAG, `getFileLastModifyTime error: ${e?.message}`);
    }
    return time;
  }

  private getFilesInDir(dirPath: string, recursive: boolean = false, relativePath: boolean = false): string[] {
    let result: string[] = [];
    if (!this.isDirectory(dirPath)) {
      hilog.info(DOMAIN, TAG, `The file is not directory`);
      return result;
    }

    let fileList: string[] = [];
    try {
      fileList = fs.listFileSync(dirPath, {
        recursion: recursive
      }).filter(file => this.isFile(`${dirPath}/${file}`));
      if (relativePath) {
        return fileList;
      }
    } catch (e) {
      hilog.info(DOMAIN, TAG, `get files error: ${e.code}, ${e.message}`);
      return result;
    }

    for (let fileName of fileList) {
      let filePath = `${dirPath}/${fileName}`;
      result.push(filePath);
    }

    return result;
  }

  private getFileListByOrder(dirPath: string): string[] {
    let fileList: string[] =
      this.getFilesInDir(dirPath).filter((logPath) => logPath.includes('_audit_') && logPath.includes('.zip'));
    if (fileList.length > 1) {
      fileList.sort((file1, file2) => this.getFileLastModifyTime(file2) - this.getFileLastModifyTime(file1));
    }
    return fileList;
  }

  /**
   * 将日志内容由 AuditLog封装类转换成以逗号相隔的字符串
   * @param obj
   * @returns
   */
  private getAuditLogValues(obj: AuditLog): string {
    let auditLog = Object.values(obj).join(', ') + '\n';
    if (auditLog.length >= AuditLogUtils.MAX_AUDIT_LOG_SIZE) {
      // 单条日志大于2kb则截断
      auditLog = auditLog.substring(0, AuditLogUtils.MAX_AUDIT_LOG_SIZE) + '\n';
      hilog.error(DOMAIN, TAG, 'The log size exceeds 2 KB, length: ' + auditLog.length);
    }
    return auditLog;
  }

  /**
   * 日志文件首行title字段
   * @param obj
   * @returns
   */
  private getAuditLogKeys(obj: AuditLog): string {
    return Object.keys(obj).join(', ') + '\n';
  }

  private async zipFile(srcPath: string, zipPath: string): Promise<boolean> {
    if (!this.isFileExist(srcPath)) {
      return false;
    }
    let options: zlib.Options = {
      level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION,
      memLevel: zlib.MemLevel.MEM_LEVEL_DEFAULT,
      strategy: zlib.CompressStrategy.COMPRESS_STRATEGY_DEFAULT_STRATEGY
    };

    try {
      let errData = await zlib.compressFile(srcPath, zipPath, options);
      if (errData != null) {
        hilog.error(DOMAIN, TAG, `zip file error: ${errData}`);
        return false;
      }
      hilog.info(DOMAIN, TAG, `zip file success`);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `zip file error, errCode:${error?.code}, message:${error?.message}`);
    }
    return false;
  }

  /**
   * 格式化时间 from yyyy-MM-dd HH:mm:ss:SSS to yyyyMMddHHmmssSSS
   * @returns
   */
  public static getFormatTime(): string {
    let date = new Date();
    let time = date.getFullYear().toString() + AuditLogUtils.addZero(date.getMonth() + 1) +
    AuditLogUtils.addZero(date.getDate()) + AuditLogUtils.addZero(date.getHours()) +
    AuditLogUtils.addZero(date.getMinutes()) + AuditLogUtils.addZero(date.getSeconds()) +
    AuditLogUtils.addZero(date.getMilliseconds(), true);
    return time;
  }

  /**
   * 格式化数字
   * @param base
   * @param flag
   * @returns
   */
  private static addZero(base: number, flag?: boolean): string {
    if (!flag && base < ONE_DIGITS) {
      return `0${base}`;
    } else if (flag && base < ONE_DIGITS) {
      return `00${base}`;
    } else if (flag && base < TWO_DIGITS) {
      return `0${base}`;
    } else {
      return base.toString();
    }
  }

  public cleanLog() {
    this.auditlog.happenTime = AuditLogUtils.getFormatTime();
    this.auditlog.packageName = 'com.ohos.contacts';
    this.auditlog.isForeground = true;
    this.auditlog.isUserBehavior = true;
    this.auditlog.cause = '';
    this.auditlog.operationType = '';
    this.auditlog.operationScenario = '';
    this.auditlog.operationCount = 0;
    this.auditlog.operationStatus = '';
    this.auditlog.extend = '';
  }
}

/**
 * 日志字段封装类
 */
export interface AuditLog {
  happenTime: string;
  packageName: string;
  isForeground: boolean;
  isUserBehavior: boolean;
  cause: string;
  operationType: string;
  operationScenario: string;
  operationCount: number;
  operationStatus: string;
  extend: string;
}

export interface IAuditLog extends AuditLog {

  key1: string; // 联系人名称的前120bit
  key2: string; // 联系人名称加手机号后6位的前120bit
  contactId: string; // 影响的 contactId
  preContactCount: number; // 修改前本端联系人总数
  postContactCount: number; // 修改后联系人总数
  affectedAccount: string; // 影响的账户（原生联系人账户或具体的某个三方联系人账户）
  otherInfo: string;
}

export class UtilAuditLog implements IAuditLog {
  public happenTime: string = '';
  public packageName: string = '';
  public isForeground: boolean = true;
  public isUserBehavior: boolean = true;
  public cause: string = '';
  public operationType: string = '';
  public operationScenario: string = '';
  public operationCount: number = -1;
  public operationStatus: string = '';
  public extend: string = '';
  public key1: string = ''; // 联系人名称的前120bit
  public key2: string = ''; // 联系人名称加手机号后6位的前120bit
  public contactId: string = ''; // 影响的 contactId
  public preContactCount: number = -1; // 修改前本端联系人总数
  public postContactCount: number = -1; // 修改后联系人总数
  public affectedAccount: string = ''; // 影响的账户（原生联系人账户或具体的某个三方联系人账户）
  public otherInfo: string = '';
}

/**
 * 实体文件日志字段封装类
 */
export interface FileAuditLog extends AuditLog {
  fileType: string;
  filePath: string;
  fileTargetPath: string;
  fileName: string;
  fileCreateTime: string;
  fileSize: number;
}


@Concurrent
export async function generateKey1(name: string): Promise<string> {
  try {
    // Step 1: Compute the SHA-256 hash of the name
    let md = cryptoFramework.createMd('SHA256');
    let messageData = new Uint8Array(buffer.from(name, 'utf-8').buffer);

    // Step 2: Take the first 120 bits (15 bytes) of the hash
    let updateLength = 15; // 取前120比特即为取前15字节
    for (let i = 0; i < messageData.length; i += updateLength) {
      let updateMessage = messageData.subarray(i, i + updateLength);
      let updateMessageBlob: cryptoFramework.DataBlob = { data: updateMessage };
      await md.update(updateMessageBlob);
    }
    let mdOutput = await md.digest();

    // Step 3: Convert the 120 bits to Base64 encoding
    let key1Base64 = new util.Base64Helper();
    let base64String = key1Base64.encodeToStringSync(mdOutput.data);

    // Step 4: Ensure the result is 20 characters long
    let key1 = base64String.substring(0, 20);
    if (key1.length < 20) {
      key1 = key1.padEnd(20, '=');
    }
    let desensitizedName: string = '';
    if (name.length <= 1) {
      desensitizedName = '*';
    } else {
      desensitizedName = name[0] + '*'.repeat(name.length - 1);
    }

    key1 = `${desensitizedName}|${key1}`;
    return key1;
  } catch (error) {
    HiLog.e('Error generating key1:', error);
    return 'error';
  }
}

@Concurrent
export async function generateKey2(name: string, phoneNumbers: string): Promise<string> {
  try {
    // Step 1: Compute the SHA-256 hash of the name + last 6 digits of phone number
    let md = cryptoFramework.createMd('SHA256');
    let messageData = new Uint8Array(buffer.from(name + phoneNumbers.slice(-6), 'utf-8').buffer);

    // Step 2: Take the first 120 bits (15 bytes) of the hash
    let updateLength = 15; // 取前120比特即为取前15字节
    for (let i = 0; i < messageData.length; i += updateLength) {
      let updateMessage = messageData.subarray(i, i + updateLength);
      let updateMessageBlob: cryptoFramework.DataBlob = { data: updateMessage };
      await md.update(updateMessageBlob);
    }
    let mdOutput = await md.digest();

    // Step 3: Convert the 120 bits to Base64 encoding
    let key2Base64 = new util.Base64Helper();
    let base64String = key2Base64.encodeToStringSync(mdOutput.data);

    // Step 4: Ensure the result is 20 characters long
    let key2 = base64String.substring(0, 20);
    if (key2.length < 20) {
      key2 = key2.padEnd(20, '=');
    }
    let desensitizedNumber: string = '';
    let numLength: number = phoneNumbers.length;
    if (numLength >= 8) {
      // 超过8位，打印前三位和后四位，中间的用*代替
      desensitizedNumber = phoneNumbers.substring(0, 3) + '*'.repeat(numLength - 7) +
      phoneNumbers.substring(numLength - 4);
    } else if (numLength >= 3 && numLength <= 7) {
      // 超过3位但小于7位，打印前一位和后一位，中间的用*代替
      desensitizedNumber = phoneNumbers.charAt(0) + '*'.repeat(numLength - 2) + phoneNumbers.charAt(numLength - 1);
    } else {
      // 小于3位，全部用*代替
      desensitizedNumber = '*'.repeat(numLength);
    }
    key2 = `${desensitizedNumber}|${key2}`;
    return key2;
  } catch (error) {
    HiLog.e('Error generating key2:', error);
    return 'error';
  }
}

export interface ILogInfo {
  displayName: string;
  phoneNumbers: string[];
  id: number;
  idList: string[];
  request: string;
  operationScenario: string;
  accountId: string;
  preContactCount: number
}

export class LogInfo implements ILogInfo {
  public displayName: string = '';
  public phoneNumbers: string[] = [];
  public id: number = -1;
  public idList: string[] = [];
  public request: string = '';
  public operationScenario: string = '';
  public accountId: string = '';
  public preContactCount: number = -1;
  public postContactCount: number = -1
}


interface Phone {
  num: string;
}

export async function assembleLogUtils(request: string, requestData?: LooseObject) {

  let log: UtilAuditLog = new UtilAuditLog();
  if (requestData && request === 'addContact') {
    // 增加联系人场景
    let numList: string[] = []
    for (let phone of JSON.parse(requestData?.['contactInfoAfter'])?.phones as Phone[]) {
      numList.push(phone.num)
    }
    let displayName: string = JSON.parse(requestData?.['contactInfoAfter']).display_name;
    if (displayName === '' && numList.length > 0) {
      displayName = numList[0]
    }
    let operationScenario: string = requestData?.operationScenario;

    log = await assemble({
      displayName: displayName,
      phoneNumbers: numList,
      request: request,
      operationScenario: operationScenario
    } as LogInfo);
  } else if (requestData && request === 'deleteContactById' || requestData && request === 'Tap and Go') {
    // 删除联系人场景
    let operationScenario: string = requestData?.operationScenario;
    log = await assemble({
      id: requestData['contactId'],
      idList: [requestData['contactId']],
      request: request,
      operationScenario: operationScenario
    } as LogInfo);
  } else if (
    (requestData && request === 'deleteContactByIds') ||
      (requestData && request === 'restoreRecycleContacts') ||
      (requestData && request === 'deleteRecycleContactByIds') ||
      (requestData && request === 'contact_arrange')
  ) {
    // 批量删除联系人场景
    let operationScenario: string = requestData?.operationScenario;

    log = await assemble({
      idList: requestData.ids,
      request: request,
      operationScenario: operationScenario
    } as LogInfo);

  } else if (requestData && request === 'updateContact') {
    // 修改联系人场景
    let numListBefore: string[] = []
    for (let phone of requestData.contactInfoBefore.phones as Phone[]) {
      numListBefore.push(phone.num)
    }
    let numListAfter: string[] = []
    for (let phone of requestData.contactInfoAfter.phones as Phone[]) {
      numListAfter.push(phone.num)
    }
    let strAccountId: string = '-1'
    ContactRepository.getInstance()
      .FindCurrentAccount([requestData?.contactInfoBefore.contactID], async (data: LogAccount[]) => {

        if (data.length > 0 && data[0].primary !== '1') {

          strAccountId = data[0].accountId
          let operationScenario: string = requestData?.operationScenario;
          // 写一条修改前的日志
          log = await assemble({
            id: requestData?.contactInfoBefore.contactID,
            displayName: requestData.contactInfoBefore.display_name,
            phoneNumbers: numListBefore,
            request: request,
            operationScenario: operationScenario,
            accountId: strAccountId,
          } as LogInfo);

          // 写一条修改后的日志
          log = await assemble({
            id: requestData?.contactInfoBefore.contactID,
            displayName: requestData.contactInfoAfter.display_name,
            phoneNumbers: numListAfter,
            request: request,
            operationScenario: operationScenario,
            accountId: strAccountId,
          } as LogInfo);
        }
      });

  }
  return log


}


// export async function assemble (displayName: string, phoneNumbers: string) {
export async function assemble(logInfo: LogInfo): Promise<UtilAuditLog> {

  const contactSizePromise = new Promise<CountAlphabetIndex>((resolve, reject) => {
    ContactRepository.getInstance().getAllContactSize((result: CountAlphabetIndex) => {
      resolve(result);
    }, true);
  });

  // 等待getAllContactSize的回调完成
  const result = await contactSizePromise;
  logInfo.preContactCount = result.count;
  if (logInfo.request == 'addContact') {
    logInfo.postContactCount = logInfo.preContactCount +1
  } else if (logInfo.request == 'updateContact') {
    logInfo.postContactCount = logInfo.preContactCount
    // 如果是增加联系人和修改聯係人，那么无需再查询用户姓名、手机号、账户id
  }else {


    // 通过id查询姓名、手机号、账户
    await new Promise<void>((resolve) => {


      ContactRepository.getInstance().findByIds(logInfo.idList as Array<string>,

        async (contactList: ContactListItem[]) => {

          const seen = new Set<string>();

          for (const contactItem of contactList) {

            logInfo.id = contactItem.id
            logInfo.displayName = contactItem.displayName;
            if (contactItem.phoneNumbers.length !== 0) {
              logInfo.phoneNumbers = contactItem.phoneNumbers.map(item => item.phoneNumber)
            }else {
              logInfo.phoneNumbers = ['']
            }

            logInfo.accountId = contactItem.phoneNumbers[0].accountId ?? ''


            // 如果是批量删除，则减一，批量恢复，则加一，合并，则判断是减一或者不变,批量清空，也不变
            let nextPreCountDiff:number = 0
            if (logInfo.request === 'contact_arrange' && !seen.has(logInfo.displayName)){
              seen.add(logInfo.displayName);
              logInfo.postContactCount = logInfo.preContactCount

            }else if (logInfo.request === 'deleteRecycleContactByIds'){
              logInfo.postContactCount = logInfo.preContactCount
            }else if (logInfo.request === 'restoreRecycleContacts'){
              logInfo.postContactCount = logInfo.preContactCount +1
              nextPreCountDiff += 1
            }else if (logInfo.request === 'Tap and Go'){
              logInfo.postContactCount = logInfo.preContactCount
              logInfo.preContactCount -= 1;
            }else {
              logInfo.postContactCount = logInfo.preContactCount -1
              nextPreCountDiff -= 1
            }

            if (logInfo.request === 'deleteContactById' || logInfo.request === 'Tap and Go') {
              continue
            }
            const logUtils = await creatUtils(logInfo)
            AuditLogUtils.getInstance().writeAuditEvent(logUtils)
            logInfo.preContactCount += nextPreCountDiff

          }
          resolve()
        }, logInfo.request)
    })
  }
  const logUtils = await creatUtils(logInfo)
  if (logInfo.request === 'updateContact' || logInfo.request === 'Tap and Go' || logInfo.request === 'deleteContactById') {
    if (!(logUtils.key1 === '' && logUtils.key2 === '')) {
      AuditLogUtils.getInstance().writeAuditEvent(logUtils);
    }

  }
  return logUtils
}

export async function creatUtils(logInfo: LogInfo): Promise<UtilAuditLog> {

  // 获取key1和key2：
  let key1: string = ''
  let key2Array: string[] = []
  let key2: string = ''
  if (logInfo.displayName && logInfo.phoneNumbers) {

    if (Array.isArray(logInfo.phoneNumbers)) {

      await Promise.all(logInfo.phoneNumbers.map(async (phoneNumber, index: number) => {
        // 生成key2并添加到key2Array
        if (phoneNumber !== '') {
          const generatedKey2 = await generateKey2(logInfo.displayName, phoneNumber);
          key2Array.push(generatedKey2);
        }
      }));

      key1 = await generateKey1(logInfo.displayName);
      key2 = key2Array.join('|');
    }

  }

  // 获取packagename
  let packageName: string | undefined = AppStorage.get('startAbilityCallerBundleName');
  if (packageName == undefined || packageName == '') {
    packageName = 'com.ohos.contacts';
  }

  let utilAuditLog: UtilAuditLog = new UtilAuditLog()

  // 填充utilAuditLog的其他字段
  utilAuditLog.happenTime = AuditLogUtils.getFormatTime();
  utilAuditLog.operationType = logInfo.request;
  utilAuditLog.operationStatus = `${logInfo.request} success`;
  utilAuditLog.operationCount = 1;
  utilAuditLog.key1 = key1;
  utilAuditLog.key2 = key2;
  utilAuditLog.packageName = packageName;
  utilAuditLog.cause = Cause.USER_BEHAVIOR;
  utilAuditLog.preContactCount = logInfo.preContactCount;
  utilAuditLog.operationScenario = logInfo.operationScenario ?? '';
  utilAuditLog.affectedAccount = logInfo.accountId;
  utilAuditLog.contactId = logInfo.id?.toString()
  utilAuditLog.postContactCount = logInfo.postContactCount;

  return utilAuditLog;
}