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
import ArrayUtil from './ArrayUtil';
import StringUtil from './StringUtil';

export default {
    isEmpty: function (string) {
        return StringUtil.isEmpty(string);
    },
    isEmptyList: function (list) {
        return ArrayUtil.isEmpty(list);
    },
    isEmptyObject: function (object) {
        return object == undefined || object == null || object == {};
    },
    copy(obj) {
        return JSON.parse(JSON.stringify(obj));
    },
    /* 拨号盘粘贴字符串规则校验：除了白名单字符：[^0123456789+;,\-#\*] 外，存在任何字符，则不可在拨号盘粘贴 */
    checkDialerNumberString(numText) {
        if (this.isEmpty(numText)) {
            return false;
        }
        let regExp = /[^0123456789\+\s;,\-#\*]/; //匹配非白名单字符，如果匹配到，反回false，匹配不到返回true
        return !regExp.test(numText);
    },
    /* 获取原数据经过过滤后的合法电话号码字符 */
    getNumberString(numText) {
        if (this.isEmpty(numText)) {
            return '';
        }
        return numText.replace(/[^0123456789\+;,#\*]/g, ''); //此处空格和-也需要被过滤
    },
    /* 去除字符串中的空格 */
    removeSpace(textContent) {
        if (this.isEmpty(textContent)) {
            return '';
        }
        return textContent.replace(/[\s]/g, '');
    },
    /* 获取原字符串中与指定子串匹配的结果字符串，只返回第一次匹配成功的结果(匹配规则忽略空格) */
    getMatchedString(textValue, regString) {
        if (this.isEmpty(textValue) || this.isEmpty(regString)) {
            return '';
        }
        regString = this.removeSpace(regString);//去除子串中所有空格
        let matchedTemp = '';
        let k = 0; //空格数量
        for (let i = 0; i < textValue.length; i++) {
            if (textValue.charAt(i) == regString.charAt(0)) {
                for (let j = 0; j < regString.length; j++) {
                    if (textValue.charAt(i+k+j) == regString.charAt(j) || textValue.charAt(i+k+j) == ' ') {
                        matchedTemp = matchedTemp + textValue.charAt(i+k+j);
                        if (textValue.charAt(i+k+j) == ' ') {
                            k++; //空格计数加1；
                            j--; //如果是主串空格，则子串不计入
                        }
                    } else {
                        k = 0; //空格数量清空
                        matchedTemp = '';
                        break;
                    }
                    if (j == regString.length - 1) {
                        return matchedTemp;
                    }
                }
            }
        }
        return '';
    }
}