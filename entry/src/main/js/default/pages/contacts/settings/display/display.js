/**
 * @file Show Contacts
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
import contactsService from '../../../../../default/model/ContactModel.js';
import LOG from '../../../../utils/ContactsLog.js';
import Constants from '../../../../../default/common/constants/Constants.js';

var TAG = 'Display...:';

export default {
    data: {
        contactsCount: 0,
        mergeCount: 0,
        phoneCount: 0,
        mergePhoneCount: 0,
        language: '',
        phoneAllInstruction: '',
        displayContactsInstruction: '',
        layoutState: false,
        timeoutId: '',
        radio: {
            allContactsState: false,
            phoneContactsState: false,
            customizeState: false
        }
    },

    onInit() {
        LOG.info(TAG + 'Display onInit --------------start');
    },

    radioInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_display_account_radio', 'allContacts');
        LOG.info(TAG + 'radioInit data');
        switch (data) {
            case 'allContacts':
                this.radio.allContactsState = true;
                this.radio.phoneContactsState = false;
                this.radio.customizeState = false;
                this.displayContactsInstruction = 'zh' == this.language
                    ? this.$t('value.contacts.displayPage.total') + this.contactsCount + this.$t('value.contacts'
                    + '.displayPage.number')
                    + this.$t('value.contacts.displayPage.displayContactsInstruction') + this.mergeCount
                    + this.$t('value.contacts.displayPage.number') : this.$t('value.contacts.displayPage.all')
                    + this.contactsCount + this.$t('value.contacts.displayPage.prefixSign')
                    + this.$t('value.contacts.displayPage' + '.displayContactsInstruction')
                    + this.mergeCount + this.$t('value.contacts.displayPage.suffixSign');
                this.phoneAllInstruction = this.$t('value.contacts.displayPage.all') + this.phoneCount;
                break;
            case 'phoneContacts':
                this.radio.allContactsState = false;
                this.radio.phoneContactsState = true;
                this.radio.customizeState = false;
                this.displayContactsInstruction = this.$t('value.contacts.displayPage.all') + this.contactsCount;
                this.phoneAllInstruction = 'zh' == this.language
                    ? this.$t('value.contacts.displayPage.total') + this.phoneCount + this.$t('value.contacts'
                    + '.displayPage.number')
                    + this.$t('value.contacts.displayPage.displayContactsInstruction')
                    + this.mergePhoneCount + this.$t('value.contacts.displayPage.number')
                    : this.$t('value.contacts.displayPage.all') + this.phoneCount
                    + this.$t('value.contacts.displayPage' + '.prefixSign')
                    + this.$t('value.contacts.displayPage.displayContactsInstruction') + this.mergePhoneCount
                    + this.$t('value.contacts.displayPage.suffixSign');
                break;
            case 'customize':
                this.radio.allContactsState = false;
                this.radio.phoneContactsState = false;
                this.radio.customizeState = true;
                this.displayContactsInstruction = this.$t('value.contacts.displayPage.all') + this.contactsCount;
                this.phoneAllInstruction = this.$t('value.contacts.displayPage.all') + this.phoneCount;
                break;
            default:
                break;
        }
    },

    conciseLayoutInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_concise_layout_switch', 'false');
        this.layoutState = data == 'true' ? true : false;
    },

    getDisplayCount: function () {
        var resultSet = {};
        var data = {};
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactsService.queryContactsCount(DAHelper, data, resultSet, (result) => {
            result.contactsCount = result.contactCount;
            result.contactsCountMerge = result.contactCount;
            this.contactsCount = result.contactsCount;
            this.mergeCount = result.contactsCountMerge;
            this.mergePhoneCount = result.contactsCountMerge;
            this.phoneCount = result.contactsCount;
            this.radioInit();
            this.conciseLayoutInit();
        });
    },
    onReady() {
        LOG.info(TAG + 'Display onReady --------------end');
    },
    onShow() {
        this.language = 'zh';
        this.getDisplayCount();
        LOG.info(TAG + 'Display onShow --------------end');
    },
    onHide() {
        LOG.info(TAG + 'Display onHide --------------end');
    },
    onDestroy() {
        LOG.info(TAG + 'Display onDestroy --------------end');
    },

    /**
     * Simple layout button
     *
     * @param {Object} event event
     */
    isCheckedConciseLayout: function (event) {
        LOG.info(TAG + 'isCheckedConciseLayout event');
        clearTimeout(conciseLayoutId);
        var conciseLayoutId = setTimeout(() => {
            this.$app.$def.globalData.storage.putSync('contacts_settings_concise_layout_switch',
                event.checked.toString());
            this.$app.$def.globalData.storage.flushSync();
        }, 0);
    },

    radioChange: function (inputValue, e) {
        LOG.info(TAG + 'radioChange inputValue...:');
        switch (inputValue) {
            case 'allContacts':
                clearTimeout(this.timeoutId);
                this.timeoutId = setTimeout(() => {
                    this.$app.$def.globalData.storage.putSync('contacts_settings_display_account_radio', inputValue);
                    this.$app.$def.globalData.storage.flushSync();
                }, 0);
                this.radio.phoneContactsState = false;
                this.radio.customizeState = false;
                this.back();
                break;
            case 'phoneContacts':
                clearTimeout(this.timeoutId);
                this.timeoutId = setTimeout(() => {
                    this.$app.$def.globalData.storage.putSync('contacts_settings_display_account_radio', inputValue);
                    this.$app.$def.globalData.storage.flushSync();
                }, 0);
                this.radio.allContactsState = false;
                this.radio.customizeState = false;
                this.back();
                break;
            case 'customize':
                router.push({
                    uri: 'pages/contacts/settings/display/customize/customize',
                    params: {},
                });
                break;
            default:
                break;
        }
    },

    onRadioChange: function (inputValue) {
        LOG.info(TAG + 'onRadioChange inputValue');
        switch (inputValue) {
            case 'allContacts':
            case 'phoneContacts':
                clearTimeout(this.timeoutId);
                this.timeoutId = setTimeout(() => {
                    this.$app.$def.globalData.storage.putSync('contacts_settings_display_account_radio', inputValue);
                    this.$app.$def.globalData.storage.flushSync();
                }, 0);
                this.back();
                break;
            case 'customize':
                router.replace({
                    uri: 'pages/contacts/settings/display/customize/customize',
                    params: {},
                });
                break;
            default:
                break;
        }
    },

    back: function () {
        router.back();
    }
};