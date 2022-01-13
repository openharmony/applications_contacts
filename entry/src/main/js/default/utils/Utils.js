/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
export default {
    isEmpty: function (string) {
        return string == undefined || string == null || string == '';
    },
    isEmptyList: function (list) {
        return list == undefined || list == null || list.length == 0;
    },
    isEmptyObject: function (object) {
        return object == undefined || object == null || object == {};
    },
    copy(obj) {
        return JSON.parse(JSON.stringify(obj));
    },

    checkDialerNumberString(numText) {
        if (this.isEmpty(numText)) {
            return false;
        }
        var regExp = /[^0123456789\+\s;,\-#\*]/;
        return!regExp.test(numText);
    },

    getNumberString(numText) {
        if (this.isEmpty(numText)) {
            return '';
        }
        return numText.replace(/[^0123456789\+;,#\*]/g, '');
    },

    removeSpace(textContent) {
        if (this.isEmpty(textContent)) {
            return '';
        }
        return textContent.replace(/[\s]/g, '');
    },

    getMatchedString(textValue, regString) {
        if (this.isEmpty(textValue) || this.isEmpty(regString)) {
            return '';
        }
        regString = this.removeSpace(regString);
        var matchedTemp = '';
        var k = 0;
        for (var i = 0; i < textValue.length; i++) {
            if (textValue.charAt(i) == regString.charAt(0)) {
                for (var j = 0; j < regString.length; j++) {
                    if (textValue.charAt(i + k + j) == regString.charAt(j) || textValue.charAt(i + k + j) == ' ') {
                        matchedTemp = matchedTemp + textValue.charAt(i + k + j);
                        if (textValue.charAt(i + k + j) == ' ') {
                            k++;
                            j--;
                        }
                    } else {
                        k = 0;
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