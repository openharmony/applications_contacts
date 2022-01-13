/**
 * @file Recently deleted
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
import LOG from '../../../../../utils/ContactsLog.js';
import recentlyDelService from '../../../../../model/recentlydelModel.js';
import Utils from '../../../../../utils/Utils.js';
import Constants from '../../../../../../default/common/constants/Constants.js';

var TAG = 'Recentlydel...:';

export default {
    data: {
        icDeleteM: '/res/image/ic_delete_m.svg',
        icFreeSpace: '/res/image/ic_contacts_favorite_me_36.svg',
        isFree: false,
        isRecover: true,
        defaultIndex: 0,
        timeOutId: '',
        language: '',
        dialogHeight: '',
        bottom: '',
        marginTop: '0px',
        recentlyList: [],
        page: 0,
        limit: 200
    },

    onInit() {
        LOG.info(TAG + 'onInit success');
        this.language = 'zh';
        switch (this.language) {
            case 'zh':
                this.dialogHeight = '215px';
                this.bottom = '33px';
                this.marginTop = '-2px';
                break;
            case 'en':
                this.dialogHeight = '255px';
                this.bottom = '5px';
                this.marginTop = '15px';
                break;
            default:
                break;
        }
    },
    onReady() {
        LOG.log(TAG + 'onReady');
    },
    onShow() {
        this.queryRecentlyDel();
        LOG.log(TAG + 'onShow');
    },
    onHide() {
        LOG.log(TAG + 'onHide');
    },

    queryRecentlyDel: function () {
        var requestData = {
            page: this.page,
            limit: this.limit
        };
        this.requestInit(requestData);
    },

    requestInit: function (data) {
        LOG.info(TAG + 'requestInit data' );
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        LOG.info(TAG + ' requestInit get DAHelper --------------');
        recentlyDelService.queryRecentlyDelContacts(DAHelper, data, (result) => {
            if (result.code == 0) {
                this.recentlyList = result.recentlyList;
                this.isFree = Utils.isEmptyList(this.recentlyList) ? true : false;
            } else {
                prompt.showToast({
                    message: 'Failed to init data.'
                });
            }
        });
    },

    doDelete: function () {
        this.$element('clearDialog').show();
    },

    cancelClick: function () {
        this.$element('clearDialog').close();
    },

    clearClick: function () {
        var data = {
            contactIds: []
        };
        this.recentlyList.forEach((element) => {
            data.contactIds.push(element.contactId);
        });
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        recentlyDelService.clearRecentlyDelContacts(DAHelper, data, (result) => {
            if (result == 0) {
                this.recentlyList = [];
                this.isFree = true;
                LOG.info(TAG + 'delete recently ok');
                this.$element('clearDialog').close();
            }
        });
    },

    doLongPress: function (index) {
        LOG.log(TAG + 'doLongPress index =' + index);
        this.defaultIndex = index;
        this.isRecover = false;
    },

    changePage: function (e) {
        LOG.info(TAG + 'changePage e');
        switch (e.detail.type) {
            case 'recover':
                this.isRecover = e.detail.isRecover;
                this.recentlyList = e.detail.recentlyList;
                this.isFree = Utils.isEmptyList(this.recentlyList) ? true : false;
                clearTimeout(this.timeOutId);
                this.timeOutId = setTimeout(() => {
                    switch (this.language) {
                        case 'zh':
                            prompt.showToast({
                                message: this.$t('value.contacts.managePage.recentlyPage.restored')
                                + e.detail.checkedCount + this.$t('value.contacts.managePage.recentlyPage.numbers')
                            });
                            break;
                        case 'en':
                            prompt.showToast({
                                message: this.$t('value.contacts.managePage.recentlyPage.restored')
                                + e.detail.checkedCount + this.$tc('value.contacts.managePage.recentlyPage'
                                + '.numbers', e.detail.checkedCount)
                            });
                            break;
                    }
                }, 1000);
                break;
            case 'delete':
                this.isRecover = e.detail.isRecover;
                this.recentlyList = e.detail.recentlyList;
                this.isFree = Utils.isEmptyList(this.recentlyList) ? true : false;
                break;
            default:
                break;
        }

    },

    back: function () {
        router.back();
    }
};