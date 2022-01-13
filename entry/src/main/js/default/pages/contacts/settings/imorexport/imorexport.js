/**
 * @file Import or export contacts
 */

/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http:// www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import router from '@system.router';
import prompt from '@system.prompt';
import LOG from '../../../../utils/ContactsLog.js';
import contactDetailReq  from '../../../../../default/model/ContactDetailModel.js';
import contactsService from '../../../../../default/model/ContactModel.js';
import Constants from '../../../../../default/common/constants/Constants.js';
import SIM from '@ohos.telephony.sim';
import contactReq from '../../../../../default/model/AccountantsModel.js';

var TAG = 'imorExport...:';

const INT_4 = 4;
const INT_300 = 300;
const INT_100 = 200;
const INT_1000 = 1000;


export default {
    data: {
        height: 800,
        vcardParams: [],
        fileName: '00001.cvf',
        checkedNum: 0, // Number of files selected
        showSelectAll: false,
        SimState: false,
        isDisabled: false
    },

    onInit() {
    },
    onReady() {
        LOG.log(TAG + '--------------onReady');
    },
    onShow() {
        this.getSimState();
        LOG.log(TAG + '--------------onShow');
    },
    onHide() {
        LOG.log(TAG + '--------------onHide');
    },


    back: function () {
        router.back();
    },

    getSimState: async function () {
        const simState = await SIM.getSimState(0);
        LOG.info(TAG + 'SIM state is=' + simState);
        if (simState  == 4) {
            this.SimState = true;
        }
    },


    SIMClicked: function () {
        this.$element('SIMDialog').show();
    },

    cancelClick: function () {
        this.$element('SIMDialog').close();
    },

    discardClick: function () {
        this.$element('SIMDialog').close();
        this.getSlotIdContacts();
    },


    getSlotIdContacts: async function () {
        var defaultSlotId = await SIM.getDefaultVoiceSlotId();
        LOG.info(TAG + 'defaultSlotId is=' + defaultSlotId);
        var result = await SIM.queryIccDiallingNumbers(defaultSlotId, 1);
        LOG.info(TAG + 'query SIM contacts length = ' + result.length);
        var i = 0;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        result.forEach(value => {
            var addParams = {};
            var phoneNumbers = [];
            var contactInfo = {};
            var name = {};
            name.fullName = value.alphaTag;
            addParams.name = name;
            contactInfo.labelId = 2;
            contactInfo.phoneNumber = value.number;
            phoneNumbers.push(contactInfo);
            addParams.phoneNumbers = phoneNumbers;
            contactReq.addContact(DAHelper, addParams, (contactId) => {
                LOG.info(TAG + 'Import SIM contactId = ' + contactId);
                i++;
                if (i == result.length) {
                    prompt.showToast({
                        message: this.$t('value.contacts.imorexportPage.prompt').replace('num', result.length)
                    });
                }
            });
        });

    },

    timestampToTime: function (timestamp) {
        LOG.info(TAG + 'timestampToTime timestamp = ');
        var date = new Date(timestamp * INT_1000);
        var Y = date.getFullYear() + '-';
        var M = (date.getMonth() + 1 < 10 ? '0' + (date.getMonth() + 1) : date.getMonth() + 1) + '-';
        var D = date.getDate() + ' ';
        var h = date.getHours() + ':';
        var m = date.getMinutes() + ':';
        var s = date.getSeconds();
        return Y + M + D + h + m + s;
    },

    uriToFileName: function (fileName) {
        LOG.info(TAG + 'uriToFileName fileName = ');
        fileName = fileName.replace('internal:// app/', '');
        return fileName;
    },

    itemClick: function (item) {
        LOG.info(TAG + 'itemClick item = ');
        LOG.info(TAG + 'select vcardParams');
        var checkedList = [];
        LOG.info(TAG + 'select vcardParams item');
        item.checked = !item.checked;
        this.vcardParams.forEach((element) => {
            if (element.checked) {
                checkedList.push(element);
            }
        });
        LOG.info(TAG + 'select vcardParams ' + this.vcardParams);
        if (item.checked) {
            this.checkedNum++;
            if (checkedList.length == this.vcardParams.length) {
                this.showSelectAll = true;
            }
        } else {
            this.checkedNum--;
            this.showSelectAll = false;
        }

    },
    itemClickAll: function () {
        if (this.showSelectAll) {
            this.vcardParams.forEach((item) => {
                item.checked = false;
            });
            this.showSelectAll = false;
        } else {
            this.vcardParams.forEach((item) => {
                item.checked = true;
            });
            this.showSelectAll = true;
        }

        LOG.info(TAG + 'select  all vcardParams' + this.vcardParams);
        LOG.info(TAG + 'select status vcardParams' + this.showSelectAll);

    },

    showImportDialog: function () {
        LOG.info(TAG + 'showImportDialog success');
        this.$app.$def.globalData.file.list({
            uri: 'internal:// app/',
            success: (data) => {
                this.vcardParams = data.fileList;
                if (this.vcardParams.length > 0) {
                    this.height = INT_300;
                    var len = this.vcardParams.length;
                    this.vcardParams.forEach((element) => {
                        element.fileModifiedTime = this.timestampToTime(element.lastModifiedTime);
                        element.fileName = this.uriToFileName((element.uri).replace('internal:// app/', ''));
                        element.checked = false;
                    });
                    if (len > INT_4) {
                        len = INT_4;
                    }
                    this.height = this.height + INT_100 * (len - 1);
                    len = len + 1;
                    this.fileName = '0000'.concat(len).concat('.cvf');
                    this.$element('ImportDateDialog').show();
                } else {
                    this.$element('ImportDialog').show();
                }
            },
        });

    },

    showExportDialog: function () {
        this.getName();
    },

    getName() {
        this.$element('ExportDialog').show();

    },
    closeExportDialog: function () {
        this.$element('ExportDialog').close();
    },

    exportContacts() {
        LOG.info(TAG + 'start export contacts');
        var requestData = {
            page: 0,
            limit: 200
        };
        var contactResults = contactsService.queryContacts(requestData);
        let contactDatas = [];
        if (contactResults.resultList.length > 0) {
            contactResults.resultList.forEach((element) => {
                var param = {};
                param.contactId = element.contactId;
                var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
                contactDetailReq.getContactById(DAHelper, param, result => {
                    contactDatas.push(result.data);
                });
            });
        }
        let result = {};
        result.code = 0;
        result.data = contactDatas;

        this.$app.$def.globalData.file.writeText({
            uri: 'internal:// app/'.concat(this.fileName),
            text: JSON.stringify(result),
            success: function () {
                prompt.showToast({
                    message: this.fileName.concat(this.$t('value.contacts.waitExport'))
                });
            },
            fail: function (data, code) {
                prompt.showToast({
                    message: 'call fail callback fail, code: ' + code + ', data: ' + data
                });
            },
        });
        this.$element('ExportDialog').close();
    },

    shareContactsList: function () {
        router.push({
            uri: 'pages/contacts/settings/shareContactsList/shareContactsList'
        });
    }
};