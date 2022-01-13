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
import Utils from '../../../default/utils/utils.js';
import favoritesModel from '../../../default/model/FavoritesModel.js';
import callLogService from '../../../default/model/CalllogModel.js';
import LOG from '../../utils/ContactsLog.js';
import Constants from '../../common/constants/Constants.js';
var TAG = 'navigation';

export default {
    data: {
        phoneShow: true,
        contactsShow: false,
        menus: '',
        cindex: 0,
        menuShow: true,
        isEndCall: false,
        refreshCallLog: false,
        refreshDialerState: false,
        dialerRefreshTimeOut: 0,
        navigationType: '',
        isInitIndex: true,
        isInit: false,
        isInitFavorite: false,
        clipboardDelayId: 0,
        dialer: {
            numTextValue: '',
            copyDisabled: true,
            clipBoardData: '',
            showClipBoard: false,
            recordList: [],
            missedList: [],
            voicemailList: [],
            logPageIndex: 0,
            logPageSize: 10
        },
        isMaskLayer: false,
        cancelMaskLayer: false,
        contentHeight: '92%',
        favoritesList: []
    },
    onInit() {
        this.menus = [{
                          'text': this.$t('value.phone'),
                          'cimg': this.$t('svg.phone.selected'),
                          'ucimg': this.$t('svg.phone.unselected')
                      },
                      {
                          'text': this.$t('value.contacts.tab'),
                          'cimg': this.$t('svg.contacts.selected'),
                          'ucimg': this.$t('svg.contacts.unselected')
                      },
                      {
                          'text': this.$t('value.favorites.tab'),
                          'cimg': this.$t('svg.favorites.selected'),
                          'ucimg': this.$t('svg.favorites.unselected')
                      }
        ];
        if (this.sourceFavorites && this.sourceFavorites == 'favorites') {
            this.changeMenu(2, false);
        } else if (this.navigationType && this.navigationType == 'contacts') {
            this.changeMenu(1, false);
        } else {
            this.changeMenu(0, false);
        }
    },
    changeMenu: function (index, isRefresh) {
        switch (index) {
            case 0:
                this.phoneShow = true;
                this.contactsShow = false;
                if (isRefresh) {
                    this.callLogRefresh();
                }
                break;
            case 1:
                this.phoneShow = false;
                this.contactsShow = true;
                if (isRefresh) {
                    this.refreshContacts();
                }
                break;
            case 2:
                this.phoneShow = false;
                this.contactsShow = false;
                this.$child('selfDefineFavorites').onRefreshFavorite();
                break;
            default:
                break;
        }

        this.cindex = index;
        this.$app.$def.globalData.menuType = this.cindex;
    },
    onReady() {
        LOG.info(TAG + 'onReady' + 'logMessage: onReady index');
    },
    callLogRefresh() {
        var mergeRule = this.$app.$def.globalData.storage.getSync('call_log_merge_rule', 'from_time');
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.getAllCalls(DAHelper, mergeRule, data => {
            this.$app.$def.globalData.callLogTotalData = data;
            this.getCallLog(this.dialer.logPageIndex, this.dialer.logPageSize);
            this.getMissedCalls(this.dialer.logPageIndex, this.dialer.logPageSize);
            this.getVoicemailList();
            for (let i = 0; i < this.$app.$def.globalData.refreshFunctions.length; i++) {
                this.$app.$def.globalData.refreshFunctions[i]();
            }
        });
    },
    getVoicemailList() {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
        callLogService.getVoicemailList(DAHelper, (voicemailList) => {
            this.$app.$def.globalData.voicemailTotalData.voicemailList = voicemailList;
            this.$app.$def.globalData.voicemailTotalData.voicemailCount = voicemailList.length;
            this.dialer.voicemailList = voicemailList;
        });
    },
    onShow() {
        switch (this.$app.$def.globalData.menuType) {
            case 0:
                this.changeMenu(0);
                this.callLogRefresh();
                LOG.info(TAG + 'onShow' + 'logMessage navigationType = ' + this.$app.$def.globalData.navigationType);
                this.$app.$def.showClipBoardInit = true;
                break;
            case 1:
                this.changeMenu(1);
                LOG.info(TAG + 'onShow' + 'navigationType refresh contacts.');
                this.refreshContacts();
                break;
            case 2:
                this.changeMenu(2);
                if (this.$app.$def.globalData.refreshFavorites) {
                    this.isInitFavorite = !this.isInitFavorite;
                    this.$app.$def.clearRefreshFavorite();
                    this.$child('selfDefineFavorites').onRefreshFavorite();
                }
                break;
            default:
                break;
        }
    },
    onHide() {
        LOG.info(TAG + 'onHide' + 'logMessage: onHide index');
    },
    onDestroy() {
        LOG.info(TAG + 'onDestroy' + 'logMessage: onDestroy index');
    },
    hiddenMenu: function (e) {
        this.menuShow = e.detail.menuShow;
        this.isMaskLayer = e.detail.isMaskLayer;
        this.contentHeight = e.detail.contentHeight;
    },
    favoritesLongPressed: function (e) {
        this.menuShow = e.detail.menuShow;
    },
    onBackPress() {
        LOG.info(TAG + 'onBackPress' + 'logMessage onBackPress navigation');
        var isCustom = false;
        if (this.$app.$def.globalData.navigationBackPressFunctions.length > 0) {
            this.$app.$def.globalData.navigationBackPressFunctions.forEach((backPressFunction) => {
                isCustom = backPressFunction()
                LOG.info(TAG + 'onBackPress' + 'logMessage onBackPress navigation b =' + isCustom);
            });
        }
        return isCustom;
    },
    updateContacts: function (e) {
        this.isExist = e.detail.isExist;
        this.dataStatus = e.detail.dataStatus;
        this.contactsList = e.detail.contactsList;
        this.contactCount = e.detail.contactCount;
    },
    updateFavorites: function (e) {
        this.favoritesList = e.detail.favoritesList;
    },

    sleep: function (milliSeconds) {
        var startTime = new Date().getTime();
        while (new Date().getTime() < startTime + milliSeconds) {
        }
    },
    maskLayerChange: function () {
        this.cancelMaskLayer = !this.cancelMaskLayer;
    },
    goToContacts: function () {
        LOG.error(TAG + 'goToContacts' + 'eventData is:+goToContacts');
        this.phoneShow = false;
        this.contactsShow = true;
        this.touchContactsStart();
        this.touchContactsEnd();
        this.clickContacts();
    },

    batchDeleteStart: function () {
        this.$app.$def.dialerStateData.batchDelete = true;
    },
    refreshContacts: async function () {
        this.$child('selfDefineContacts').onRefresh();
    },
    refreshFavorites: async function () {
        this.sleep(600);
        var actionData = {
            limit: 2000,
            page: 0,
            star: 1
        }
        var DAHelper = await this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.queryFavoritesContacts(DAHelper, actionData, result => {
            if (result.code == 0 && result.resultList && result.resultList.length > 0) {
                this.favoritesList = result.resultList;
            } else {
                this.favoritesList = [];
            }
        });
    },

    pasteCheck() {
        let result = {
            'abilityResult': '115 6',
            'code': 0
        };
        if (result != null && result.code == 0) {
            if (Utils.checkDialerNumberString(result.abilityResult)) {
                this.dialer.copyDisabled = false;
            } else {
                this.dialer.copyDisabled = true;
                this.dialer.showClipboard = false;
                this.dialer.clipBoardData = '';
            }
        } else {
            this.dialer.copyDisabled = true;
            this.dialer.showClipboard = false;
            this.dialer.clipBoardData = '';
        }
    },
    hideClipBoard() {
        this.dialer.showClipBoard = false;
    },

    getCallLog: function (pageIndex, pageSize) {
        LOG.info(TAG + 'getCallLog' + 'logMessage getCallLog callLogTotalData length = ' + this.$app.$def.globalData.callLogTotalData.callLogList.length);
        if (pageIndex == 0) {
            this.dialer.recordList = callLogService.getCallLog(pageIndex, pageSize, this.$app.$def.globalData.callLogTotalData.callLogList);
        } else {
            this.dialer.recordList = this.dialer.recordList.concat(callLogService.getCallLog(pageIndex, pageSize, this.$app.$def.globalData.callLogTotalData.callLogList));
        }
    },

    getMissedCalls(pageIndex, pageSize) {
        LOG.info(TAG + 'getMissedCalls' + 'logMessage getMissedCalls callLogTotalData length = ' + this.$app.$def.globalData.callLogTotalData.missedList.length);
        if (pageIndex == 0) {
            this.dialer.missedList = callLogService.getCallLog(pageIndex, pageSize, this.$app.$def.globalData.callLogTotalData.missedList);
        } else {
            this.dialer.missedList = this.dialer.missedList.concat(callLogService.getCallLog(pageIndex, pageSize, this.$app.$def.globalData.callLogTotalData.missedList));
        }
    },

    queryCallLogByPage(e) {
        LOG.info(TAG + 'queryCallLogByPage' + 'logMessage queryCallLogByPage e = ' + e);
        if (e.detail.logIndex == 1) {
            this.getMissedCalls(e.detail.pageIndex, this.dialer.logPageSize);
        } else {
            this.getCallLog(e.detail.pageIndex, this.dialer.logPageSize);
        }
    },
    updateLogList(e) {
        LOG.info(TAG + 'updateLogList' + 'logMessage updateLogList e = ' + e);
        this.dialer.recordList = e.detail.recordList;
        this.dialer.missedList = e.detail.missedList;
        this.dialer.voicemailList = e.detail.voicemailList;
    }
}
