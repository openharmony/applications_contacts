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

import { HiLog } from './HiLog';

const TAG = 'Contacts TextUtils ';
// 表情肤色罩层5种颜色
const EMOJI_COLOR_REGEX: RegExp =
  new RegExp('[\\uD83C\\uDFFB|\\uD83C\\uDFFC|\\uD83C\\uDFFD|\\uD83C\\uDFFE|\\uD83C\\uDFFF]');

/**
 * Text utils 工具类
 *
 * @since 2025-08-23
 */
export default class TextUtils {
  /**
   * ASCii 编码中，最长的单字节编码长度，大于此字节的字符都是双字节
   */
  private static readonly MAX_SINGLE_CHAR = 255;

  /**
   * 空字符串
   */
  public static readonly EMPTY_STRING: string = '';

  /**
   * 号码前缀
   */
  public static readonly PHONE_PREFIX = '+86';

  /**
   * 判断待校验值是否为空，默认用于字符串判空
   *
   * @template T
   * @param object 待校验对象
   * @return boolean 是否为空
   */
  public static isEmpty<T extends unknown>(object: T): boolean {
    if (typeof object === 'undefined' || object === null || object === '') {
      return true;
    } else {
      return false;
    }
  }

  /**
   * 判断待校验值是否是一个十一位电话号码
   *
   * @param phoneNumber 待校验值
   * @return boolean 校验结果
   */
  public static isPhoneNumber(phoneNumber: string): boolean {
    if (TextUtils.isEmpty(phoneNumber)) {
      return false;
    }

    /* 十一位数电话号码正则表达式 */
    const REG = /^(\+86)*[0-9]{11}$/;
    return REG.test(phoneNumber) ? true : false;
  }

  /**
   * 系统语言切换为镜像语言时，电话号码文字顺序不符合预期，插入控制字符'\u202A' +'\u202C'
   *
   * @param value
   * @return string
   */
  public static getTextValue(value: string): string {
    if (!value || typeof value !== 'string') {
      return value;
    }
    return `\u202A${value}\u202C`;
  }

  /**
   * 判断待校验值是否是一个十一位并且没有特殊字符的电话号码
   *
   * @param phoneNumber 待校验值
   * @return boolean 校验结果
   */
  public static isStandardPhoneNumber(phoneNumber: string): boolean {
    if (TextUtils.isEmpty(phoneNumber)) {
      return false;
    }

    /* 十一位数电话号码正则表达式 */
    const REG = /^((\+)?86|((\+)?86)?)0?1[3456789]\d{9}$/;
    return REG.test(phoneNumber) ? true : false;
  }

  /**
   * 将字符串按照指定字节长度截断
   *
   * @param value 字符串
   * @param length 字节长度
   * @returns 前length个字节长度的字符
   */
  static cutString(value: string, length: number): string {
    if (TextUtils.isEmpty(value)) {
      HiLog.w(TAG, ` [cutString]warning: value is null! `);
      return '';
    }
    let endIndex: number = value.length;
    let byteLen: number = 0;
    for (let index = 0; index < value.length; index++) {
      const element: number = value.charCodeAt(index);
      if (element > TextUtils.MAX_SINGLE_CHAR) {
        byteLen++;
      }
      byteLen++;
      if (byteLen === length) {
        endIndex = index + 1;
        break;
      }
      if (byteLen > length) {
        endIndex = index;
        break;
      }
    }
    return value.substring(0, endIndex);
  }

  /**
   * 将一个电话号码变换成掩码形式
   *
   * @param phoneNumber 待操作对象
   * @return string 结果
   */
  static getMaskString(phoneNumber: string): string {
    if (TextUtils.isEmpty(phoneNumber)) {
      HiLog.e(TAG, `getMaskString param is empty.}`);
      return '*';
    }
    return phoneNumber.length.toString();
  }

  /**
   * 在字符串中指定位置添加空格
   *
   * @param src 待操作值
   * @param stepArray 间隔集合
   * @return string 转换后的结果
   */
  static insertBlankOnString(srcString: string, stepArray: number[]): string {
    let res = [];
    let pre = 0;
    let elementList = srcString.split('');
    for (let elem of stepArray) {
      res.push(elementList.slice(pre, elem).join(''));
      pre = elem;
    }
    return res.join(' ');
  }

  /**
   * 删除字符串中的空格
   *
   * @param str 待处理的字符串
   * @return 去空格后的字符串
   */
  static removeSpace(str: string): string {
    if (TextUtils.isEmpty(str)) {
      return '';
    }
    return str.replace(/[\s]/g, '');
  }

  /**
   * textOverflow缩略用法，默认按照单词分割缩进，想要数字或者字母单个分割缩进，需要加零宽空格(u/200B)
   *
   * @parm str 待处理的字符串
   * @return 添加了零宽空格后的字符串
   */
  static addZeroWidthSpace(str: string): string {
    if (TextUtils.isEmpty(str)) {
      return '';
    }
    /* 零宽空格 */
    const ZERO_WIDTH_SPACE = '\u200B';
    return str.split('').join(ZERO_WIDTH_SPACE);
  }

  /**
   * 空格优化，保留单空格
   * @param src 数据源
   * @returns 返回优化后字符串
   */
  static trimBlanks(src: string): string {
    if (TextUtils.isEmpty(src)) {
      return '';
    }
    return src.replace(/\s+/g, ' ');
  }

  /**
   * 默认字符串脱敏，主要用于打印日志
   * 1. 当字符串长度 len：[0~ 0]时, 返回空字符串,  没有*， 是 ''
   * 2. 当字符串长度 len：[1~ 5]时，保留最后1位，  后面加*，如 ******x
   * 3. 当字符串长度 len：[6~15]时, 保留前后各2位，前面加*，如 xx******xx
   * 4. 当字符串长度 len：[16~N]时, 保留前后各4位，前面加*，如 xxxx******xxxx
   *
   * @param value 字符串
   * @returns 脱敏后的字符串
   */
  static defMaskString(value: string): string {
    if (TextUtils.isEmpty(value)) {
      return TextUtils.EMPTY_STRING;
    }
    let mask = '******';
    if (value.length <= 5) {
      return mask + value[value.length - 1];
    }
    if (value.length <= 15) {
      return value.substring(0, 2) + mask +
      value.substring(value.length - 2);
    }
    return value.substring(0, 4) + mask + value.substring(value.length - 4);
  }

  /**
   * 将字符串按照最大行数截取省略展示
   *
   * @param str 字符串
   * @param maxLine 需要展示的最大行数
   * @returns 截取后的字符串
   */
  static stringAbbreviation(str: string, maxLine: number): string {
    if (TextUtils.isEmpty(str) || maxLine <= 1) {
      return str;
    }
    let match = str.match(new RegExp('\n', 'g'));
    if (!match || match.length < maxLine) {
      return str;
    }
    let res: string = '';
    let split = str.split('\n');
    for (let i = 0; i < maxLine; i++) {
      res += split[i];
      if (i !== maxLine - 1) {
        res += '\n';
      } else {
        res += '...';
      }
    }
    return res;
  }

  /**
   * 获取文件的suffix，取从后往前指定字符后的字符串（默认为.）
   * 输入 test.txt
   * 返回 txt
   *
   * @param fileName 需要处理的文件名或路径
   * @param splitPattern 指定分隔字符
   * @returns 从后往前指定字符后的字符串（默认为.）
   */
  public static getFileSuffix(fileName: string, splitPattern?: string): string {
    if (TextUtils.isEmpty(fileName)) {
      HiLog.e(TAG, ' getFileSuffix name is null!');
      return '';
    }
    let suffix: string = '';
    let lastDotIndex: number = fileName.lastIndexOf(splitPattern ? splitPattern : '.');
    if (lastDotIndex === -1) {
      HiLog.w(TAG, ' getFileSuffix wrong file name!');
      return suffix;
    }
    suffix = fileName.slice(lastDotIndex + 1);
    return suffix;
  }

  /**
   * 获取文件的suffix，取从后往前指定字符后的字符串（默认为.），包括指定的字符
   * 输入 test.txt
   * 返回 .txt
   *
   * @param fileName 需要处理的文件名或路径
   * @param splitPattern 指定分隔字符
   * @returns 从后往前指定字符后的字符串（默认为.）
   */
  public static getFileSuffixWithPattern(fileName: string, splitPattern?: string): string {
    if (TextUtils.isEmpty(fileName)) {
      HiLog.e(TAG, ' getFileSuffix name is null!');
      return '';
    }
    let suffix: string = '';
    let lastDotIndex: number = fileName.lastIndexOf(splitPattern ? splitPattern : '.');
    if (lastDotIndex === -1) {
      HiLog.w(TAG, ' getFileSuffix wrong file name!');
      return suffix;
    }
    suffix = fileName.slice(lastDotIndex);
    return suffix;
  }

  /**
   * 从文件路径中获取文件的名称
   * 输入 a/b/c/d.txt
   * 返回 d
   *
   * @param path 文件路径
   * returns 文件的名称
   */
  public static getFileNameByPath(path: string): string {
    if (TextUtils.isEmpty(path)) {
      HiLog.e(TAG, ' getFileNameByPath name is null!');
      return '';
    }
    let suffix: string = '';
    suffix = path.slice(path.lastIndexOf('/') + 1, path.lastIndexOf('.'));
    return suffix;
  }

  /**
   * 字符串解析对象
   *
   * @param jsonStr 要解析的字符串
   * @returns 解析后的json对象
   */
  public static jsonParse<T>(jsonStr: string, tag?: string): T | null {
    if (TextUtils.isEmpty(jsonStr)) {
      HiLog.w(TAG, `can't parse empty string, tag: ${tag}`);
      return null;
    }
    try {
      return JSON.parse(jsonStr);
    } catch (error) {
      HiLog.e(TAG, `json parse error, error msg: ${error?.message},tag: ${tag}`);
      return null;
    }
  }

  /**
   * 获取格式化手机号
   *
   * @param 手机号码
  * returns 格式化手机号码
   */
  public static getFormatterPhoneNumberWithSpace(phoneNumber: string): string {
    if (TextUtils.isEmpty(phoneNumber)) {
      HiLog.e(TAG, 'getFormatterPhoneNumber phoneNum is null!');
      return '';
    }
    const PHONE_REGEX: RegExp = new RegExp(/(^|\s*\+?0?0?86|\D)(1\d{2})[-\s]{0,3}(\d{4})[-\s]{0,3}(\d{4})(?=\D|$)/);
    let result: string = phoneNumber.replace(PHONE_REGEX, '$1 $2 $3 $4');
    return result;
  }
}