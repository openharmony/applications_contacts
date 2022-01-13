/**
 * @file Custom view
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
import contactsService from '../../../../../../default/model/CustomizeModel.js';
import LOG from '../../../../../utils/ContactsLog.js';
import Constants from '../../../../../../default/common/constants/Constants.js';

var TAG = 'Customize...:';

export default {
    data: {
        isUnfold: false,
        arrowFoldImage: {
            fold: '/res/image/ic_contacts_arrow_unfold_s.svg',
            unFold: '/res/image/ic_contacts_arrow_unfold.svg'
        },
        customizeArrowImage: '',
        isCheckedCustomize: false,
        isCheckedOtherCustomize: false,
        storageValue: '',
        customizeId: '',
        timeoutId: '',
        groupList: []
    },

    onInit() {
        this.customizeArrowImage = this.arrowFoldImage.fold;
        var defaultData = {
            'isCheckedCustomize': false,
            'isCheckedOtherCustomize': false
        };
        let ret = this.$app.$def.globalData.storage.getSync('contacts_settings_customize_view_input', 'false');
        this.storageValue = ret == 'false' ? defaultData : JSON.parse(ret);
        this.isCheckedCustomize = this.storageValue.isCheckedCustomize;
        this.isCheckedOtherCustomize = this.storageValue.isCheckedOtherCustomize;
        LOG.info(TAG + 'Customize onInit --------------end');
    },
    onShow() {
        this.initGroupData();
        LOG.info(TAG + 'Customize onShow --------------end');
    },

    checkboxOnChange: function (event) {
        LOG.info(TAG + 'checkboxOnChange event');
        this.isCheckedCustomize = !this.isCheckedCustomize;
        if (this.isCheckedCustomize) {
            this.isCheckedOtherCustomize = true;
            this.groupList.forEach(element => {
                element.checked = true;
            });
        } else {
            this.isCheckedOtherCustomize = false;
            this.groupList.forEach(element => {
                element.checked = false;
            });
        }
    },

    onClickChange: function () {
        this.isCheckedCustomize = !this.isCheckedCustomize;
    },

    onClickGroupChange: function (index) {
        LOG.info(TAG + 'onClickGroupChange index' + index);
        switch (index) {
            case -1:
                this.isCheckedOtherCustomize = !this.isCheckedOtherCustomize;
                break;
            default:
                this.groupList[index].checked = !this.groupList[index].checked;
                break;
        }
        var isCheckedGroup = true;
        this.groupList.forEach(element => {
            if (!element.checked) {
                isCheckedGroup = false;
            }
        });
        this.isCheckedCustomize = isCheckedGroup ? this.isCheckedOtherCustomize ? true : false : false;
    },

    unfoldClicked: function () {
        this.isUnfold = !this.isUnfold;
        this.customizeArrowImage = this.customizeArrowImage == this.arrowFoldImage.fold
            ? this.arrowFoldImage.unFold : this.arrowFoldImage.fold;
    },

    back: function () {
        router.back();
    },

    saveCustomize: function () {
        var checkedList = [];
        this.groupList.forEach(element => {
            if (element.checked) {
                checkedList.push(element.id);
            }
        });
        var value = {
            'isCheckedCustomize': this.isCheckedCustomize,
            'isCheckedOtherCustomize': this.isCheckedOtherCustomize,
            'checkedList': checkedList
        };
        clearTimeout(this.customizeId);
        this.customizeId = setTimeout(() => {
            this.$app.$def.globalData.storage.putSync('contacts_settings_customize_view_input', JSON.stringify(value));
            this.$app.$def.globalData.storage.flushSync();
        }, 0);
        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(() => {
            this.$app.$def.globalData.storage.putSync('contacts_settings_display_account_radio', 'customize');
            this.$app.$def.globalData.storage.flushSync();
        }, 0);
        router.back({
            path: 'pages/contacts/settings/settings'
        });
    },

    /**
     * Get group list data
     *
     * @param {number} code 2005 FA and PA access protocol code
     * @param {number} data contactId The contact ID
     */
    initGroupData: function () {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactsService.queryGroups(DAHelper, (result) => {
            LOG.info(TAG + 'initGroupData result');
            if (result.code == 0) {
                this.groupList = result.resultList;
                if (this.storageValue.hasOwnProperty('checkedList')) {
                    this.groupList.forEach(element => {
                        if (this.storageValue.checkedList.indexOf(element.id) != -1) {
                            element.checked = true;
                        }
                    });
                }
            } else {
                prompt.showToast({
                    message: 'Failed to init customize view data.'
                });
            }
        });
    }
};