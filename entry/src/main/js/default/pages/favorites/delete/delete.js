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
import httpcontact from '../../../../default/model/FavoritesModel.js'
import configuration from '@system.configuration';
import LOG from '../../../utils/ContactsLog.js';

var TAG = 'favoritesdelete';

export default {
    data: {
        favoriteslist: [],
        todolist: [],
        svgFavoritesDeleteMove: '/res/image/star_moves.png',
        ic_cancle_m: '/res/image/ic_cancel_m.svg',
        ic_delete_m: '/res/image/ic_delete_m.svg',
        ic_select_all: '/res/image/ic_select all_m.svg',
        titleMessage: '',
        allSelectMessage: '',
        isSelectAll: false,
        deleteDisabled: true,
        selectCount: 0,
        favoritesTitle: true,
        todoTitle: true,
        localeInfo: '',
        props: {
            favoritesIndex: {
                default: ''
            },
            todoIndex: {
                default: ''
            }
        }
    },
    onInit() {
        this.titleMessage = this.$t('value.favorites.page.delete.titleMessageNoSelect');
        this.allSelectMessage = this.$t('value.favorites.page.delete.selectAll');
        this.localeInfo = configuration.getLocale();
        if (this.favoriteslist.length == 0) {
            this.favoritesTitle = false;
        }
        if (this.todolist.length == 0) {
            this.todoTitle = false;
        }
        this.favoritesIndex;
        if (this.favoritesIndex !== '') {
            this.favoriteslist[this.favoritesIndex].checked = true;
            this.selectCount++;
            this.refreshPageTabs();
        }
        if (this.todoIndex !== '') {
            this.todolist[this.todoIndex].checked = true;
            this.selectCount++;
            this.refreshPageTabs();
        }
    },
    defaultChecked: function () {
    },
    clickSelectAll: function (e) {
        LOG.info(TAG + 'clickSelectAll' + 'logMessage selectAll:' + e.target);
        if (!this.isSelectAll) {
            this.selectAll();
        } else {
            this.unSelectAll();
        }
        this.refreshPageTabs();
    },

    selectAll: function () {
        this.selectCount = 0;
        this.favoriteslist.forEach(element => {
            element.checked = true;
            this.selectCount++;
        });
        this.todolist.forEach(element => {
            element.checked = true;
            this.selectCount++;
        });
    },


    unSelectAll: function () {
        this.favoriteslist.forEach(element => {
            element.checked = false;
            if (this.selectCount > 0) {
                this.selectCount--;
            }
        });
        this.todolist.forEach(element => {
            element.checked = false;
            if (this.selectCount > 0) {
                this.selectCount--;
            }
        });
    },
    collectChecked: function (index) {
        this.favoriteslist[index].checked = !this.favoriteslist[index].checked;
        this.favoriteslist[index].checked ? this.selectCount++ : this.selectCount--;
        this.refreshPageTabs();
    },
    frequentChecked: function (index) {
        this.todolist[index].checked = !this.todolist[index].checked;
        this.todolist[index].checked ? this.selectCount++ : this.selectCount--;
        this.refreshPageTabs();
    },
    collectChangeChecked: function (index, e) {
        this.favoriteslist[index].checked = e.checked;
        e.checked ? this.selectCount++ : this.selectCount--;
        this.refreshPageTabs();
    },
    changeCheckState: function (index, e) {
        this.todolist[index].checked = e.checked;
        e.checked ? this.selectCount++ : this.selectCount--;
        this.refreshPageTabs();
    },


    refreshPageTabs: function () {
        if (this.selectCount > 0) {
            switch (this.localeInfo.language) {
                case 'zh':
                    this.titleMessage = this.$t('value.favorites.page.delete.titleMessageSelect') + this.selectCount + this.$t('value.favorites.page.delete.titleMessageUnit');
                    break;
                case 'en':
                    this.titleMessage = this.selectCount + this.$tc('value.favorites.page.delete.titleMessageSelect', this.selectCount);
                    break;
                default:
                    this.titleMessage = '';
                    break;
            }
            this.deleteDisabled = false;
            if (this.selectCount == this.favoriteslist.length + this.todolist.length) {
                this.ic_select_all = '/res/image/ic_select all_filled_m.svg';
                this.allSelectMessage = this.$t('value.favorites.page.delete.unSelectAll');
                this.isSelectAll = true;
            } else {
                this.ic_select_all = '/res/image/ic_select all_m.svg';
                this.allSelectMessage = this.$t('value.favorites.page.delete.selectAll');
                this.isSelectAll = false;
            }
        } else {
            this.selectCount = 0;
            this.ic_select_all = '/res/image/ic_select all_m.svg';
            this.allSelectMessage = this.$t('value.favorites.page.delete.selectAll');
            this.titleMessage = this.$t('value.favorites.page.delete.titleMessageNoSelect');
            this.deleteDisabled = true;
            this.isSelectAll = false;
        }
    },
    backFavorites: function () {
        this.$emit('eventType', {
            isShow: true,
            collection: this.favoriteslist,
            frequent: this.todolist
        });
    },
    doDelete: function () {
        if (this.isSelectAll) {
            this.favoriteslist = [];
            this.todolist = [];
        } else {
            var unCheckedStarList = [];
            var checkedStarList = [];
            this.favoriteslist.forEach(element => {
                if (element.checked) {
                    checkedStarList.push(element);
                } else {
                    unCheckedStarList.push(element);
                }
            });
            this.favoriteslist = unCheckedStarList;
            var unCheckedList = [];
            var checkedList = [];
            this.todolist.forEach(element => {
                if (element.checked) {
                    checkedList.push(element);
                } else {
                    unCheckedList.push(element);
                }
            });
            this.todolist = unCheckedList;
        }
        if (this.favoriteslist.length == 0) {
            this.favoritesTitle = false;
        }
        if (this.todolist.length == 0) {
            this.todoTitle = false;
        }
        this.selectCount = 0;
        this.refreshPageTabs();
        this.backFavorites();
    },
    itemMove: function () {
        LOG.info(TAG + 'itemMove' + 'IT ok');
    },
    async getFavoritesContacts() {
        var internal = 1;
        var sync = 0;
        var messageCode = 3001;
        var actionData = {};
        httpcontact.contactHttp(internal, sync, messageCode, actionData, (result) => {
            if (result.code == 0) {
                LOG.error(TAG + 'getFavoritesContacts' + 'result.favoriteslist: ');
                this.favoriteslist = result.favoriteslist;
            } else {
                LOG.info(TAG + 'getFavoritesContacts' + 'plus result is erro:');
            }
        });
    },
    async getToDoContacts() {
        var internal = 1;
        var sync = 0;
        var messageCode = 3002;
        var actionData = {};
        httpcontact.contactHttp(internal, sync, messageCode, actionData, (result) => {
            if (result.code == 0) {
                LOG.error(TAG + 'getToDoContacts' + 'result.oftenContacts: ');
                this.todolist = result.oftenContacts;
            } else {
                LOG.info(TAG + 'getToDoContacts' + 'plus result is erro:');
            }
        });
    },
}

