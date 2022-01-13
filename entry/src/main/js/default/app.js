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
import dataStorage from '@ohos.data.storage';
import call from '@ohos.telephony.call';
import file from '@system.file';
import featureAbility from '@ohos.ability.featureAbility';
import LOG from '../default/utils/ContactsLog.js';
var TAG = 'app';

export default {
    featureAbility: featureAbility,
    onCreate() {
        LOG.info(TAG + 'AceApplication onCreate');
        this.initDataStorage();
    },
    onDestroy() {
    },
    async initDataStorage() {
        let context = featureAbility.getContext();
        let path = await context.getFilesDir();
        this.globalData.storage = dataStorage.getStorageSync(path + this.globalData.path);
    },
    globalData: {
        file: file,
        path: '/PREFERENCES_FOR_CONTACTS',
        storage: '',
        addAccount: false,
        editContacts: false,
        refreshContacts: false,
        refreshFavorites: false,
        navigationType: -1,
        menuType: '',
        showClipBoardInit: true,
        isSearchList: false,
        callLogTotalData: {
            callLogList: [],
            missedList: [],
            totalCount: 0,
            missedCount: 0,
        },
        voicemailTotalData: {
            voicemailList: [],
            voicemailCount: 0
        },
        contactsAnimation: {
            title: '',
            backBut: 'hidden-init',
            setting: '',
            contactTitle: '',
            search: '',
            isHidden: false,
            isSearch: false
        },
        voicemailNumber: '',
        refreshFunctions: [],
        navigationBackPressFunctions: [],
        batchSelectContactsRefreshFunction: [],
        isDisplay: true,
        searchValue: '',
        contactCount: 0,
        pushToGroup: false,
        groupParams: null,
        dialogShow: false
    },
    dialerStateData: {
        isEditNumber: false,
        isGoToMissedCalls: false,
        numTextDialer: '',
        showDialer: true,
        copyDisabled: true,
        isCallState: false,
        isNeedShowDialer: true,
        isNeedHideDialer: false,
    },
    groups: {
        group: []
    },
    dialer: {},

    setAddAccount(addAccount) {
        this.globalData.addAccount = addAccount;
    },
    clearAddAccount() {
        this.globalData.addAccount = false;
    },
    setRefreshContacts(refreshContacts) {
        this.globalData.refreshContacts = refreshContacts;
    },
    setRefreshFavorite() {
        this.globalData.refreshFavorites = true;
    },
    clearRefreshFavorite() {
        this.globalData.refreshFavorites = false;
    },
    clearRefreshContacts() {
        this.globalData.refreshContacts = false;
    },
    setEditContacts(editContacts) {
        this.globalData.editContacts = editContacts;
    },
    clearEditContacts() {
        this.globalData.editContacts = false;
    },
    setContactsAnimation(title, backBut, setting, contactTitle, search, isHidden) {
        this.globalData.contactsAnimation.title = title;
        this.globalData.contactsAnimation.backBut = backBut;
        this.globalData.contactsAnimation.setting = setting;
        this.globalData.contactsAnimation.contactTitle = contactTitle;
        this.globalData.contactsAnimation.search = search;
        this.globalData.contactsAnimation.isHidden = isHidden;
    },
    setIsSearch(isSearch) {
        this.globalData.contactsAnimation.isSearch = isSearch;
    },
    setIsSearchList(isSearchList) {
        this.globalData.isSearchList = isSearchList;
    },
    getDAHelper: function (URL) {
        var DAHelper = featureAbility.acquireDataAbilityHelper(URL);
        return DAHelper;
    },

    /**
     * Make a phone call
     *
     * @param {number} phoneNumber
     */
    call(phoneNumber) {
        if (phoneNumber == null || phoneNumber == '') {
            LOG.info(TAG + 'call param is null');
            return;
        }
        LOG.info(TAG + 'callPhone executed phone number = ' + phoneNumber);
        if (phoneNumber.length) {
            call.dial(phoneNumber).then((value) => {
                this.pageState = false;
                LOG.info(TAG + `call dial success : value = ${value}`);
            }).catch((err) => {
                LOG.info(TAG + 'call dial error, ' + err.message);
            });
        }
    },

    sendMessage(params) {
        let actionData = {};
        actionData.contactObjects = JSON.stringify(params);
        actionData.pageFlag = 'conversation';
        this.jumpToContract(actionData);
    },

    jumpToContract(actionData) {
        var str = {
            'want': {
                'bundleName': 'com.ohos.mms',
                'abilityName': 'com.ohos.mms.MainAbility',
                'parameters': actionData,
                'entities': [
                    'entity.system.home'
                ]
            },
        };
        featureAbility.startAbility(str)
            .then((data) => {
            LOG.info(TAG + 'jumpToContract Operation successful. Data: ' + JSON.stringify(data));
        }).catch((error) => {
            LOG.error(TAG + 'jumpToContract Operation failed. Cause: ' + JSON.stringify(error));
        });
    }
};
