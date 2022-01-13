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
import LOG from '../../../../utils/ContactsLog.js';
import Constants from '../../../../common/constants/Constants.js';
import greetingService from '../../../../../default/model/GreetingModel.js';
import prompt from '@system.prompt';

var TAG = 'delete';

export default {
    data: {
        props: ['defaultGreetingList'],
        greetingList: [],
        isSelectAll: false,
        deleteDisabled: true,
        checkedCount: 0,
        language: 'zh',
        greetingTitle: '',
    },

    onInit() {
        this.greetingList = this.defaultGreetingList;
        this.refreshPageTabs();
    },

    onCheckedChange: function (index) {
        this.greetingList[index].checked = !this.greetingList[index].checked;
        this.greetingList[index].checked == true ? this.checkedCount++ : this.checkedCount--;
        this.refreshPageTabs();
    },

    back: function () {
        this.$emit('eventType', {
            isDelete: true,
            greetingList: this.greetingList
        });
    },

    clickCheckedAll: function () {
        if (!this.isSelectAll) {
            this.selectAll();
        } else {
            this.unSelectAll();
        }
        this.refreshPageTabs();
    },

    selectAll: function () {
        this.checkedCount = 0; //Clear the selected count and increase it again
        this.greetingList.forEach((element, index) => {
            if (index == 0) {
                return;
            }
            element.checked = true;
            this.checkedCount++;
        });
    },

    unSelectAll: function () {
        this.greetingList.forEach((element, index) => {
            if (index == 0) {
                return;
            }
            element.checked = false;
            if (this.checkedCount > 0) {
                this.checkedCount--;
            }
        });
    },

    refreshPageTabs: function () {
        if (this.checkedCount > 0) {
            switch (this.language) {
                case 'zh':
                    this.greetingTitle = this.$t('value.contacts.managePage.recentlyPage.select') + this.checkedCount + this.$t('value.contacts.managePage.recentlyPage.count');
                    break;
                case 'en':
                    this.greetingTitle = this.checkedCount + this.$tc('value.contacts.managePage.recentlyPage.titleMessageSelect', this.checkedCount);
                    break;
                default:
                    this.greetingTitle = '';
                    break;
            }
            this.deleteDisabled = false;
            this.isSelectAll = this.checkedCount == this.greetingList.length - 1 ? true : false;
        } else {
            this.checkedCount = 0;
            this.greetingTitle = this.$t('value.contacts.managePage.recentlyPage.noSelect');
            this.deleteDisabled = true;
            this.isSelectAll = false;
        }
    },
    deleteGreeting: function () {
        var uncheckedList = [];
        var checkedIds = [];
        this.greetingList.forEach((element, index) => {
            if (index == 0) {
                element.radio = true;
                uncheckedList.push(element);
                return;
            }
            LOG.info(TAG + 'deleteGreeting---------');
            if (element.checked) {
                checkedIds.push(element.id);
            } else {
                uncheckedList.push(element);
            }
        });
        var data = {
            ids: checkedIds
        }
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
        greetingService.deleteGreeting(DAHelper, data, result => {
            if (result == 0) {
                this.greetingList = uncheckedList;
                this.greetingId = setTimeout(() => {
                    this.$app.$def.globalData.storage.putSync('phone_setting_greeting_data', JSON.stringify(this.greetingList));
                    this.$app.$def.globalData.storage.flushSync();
                }, 0);
                this.back();
            } else {
                prompt.showToast({
                    message: 'Failed to delete greeting data.'
                });
            }
        });
    }
}