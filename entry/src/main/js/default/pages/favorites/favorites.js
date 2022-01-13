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
import prompt from '@system.prompt';
import router from '@system.router';
import favoritesModel from '../../../default/model/FavoritesModel.js';
import LOG from '../../utils/ContactsLog.js';
import Constants from '../../../default/common/constants/Constants.js';
var TAG = 'favorite';


const GET_OFTEN_CONTACT = 3002 // Get a list of common uses

const NUMBERS_MEANING = {
    HEADER_MIN_HEIGHT: 70,
    HEADER_MAX_HEIGHT: 220,
    HEADER_MIN_FONT_SIZE: 50,
    HEADER_MAX_FONT_SIZE: 60,
    HEADER_MIN_TO_MAX_FONT_SIZE: 10,
    HEADER_MIN_TO_MAX_HEIGHT_SIZE: 150,
};
// On behalf of the synchronization
const ACTION_SYNC = 0;
// 1 represents InternalAbility without interface jump
const ABILITY_TYPE_INTERNAL = 1;
const SET_DEFAULT = 1;

export default {
    data: {
        props: ['isInitFavorite', 'favoritesList'],
        favoritesList: [],
        todoList: [],
        numRecords: [],
        simCardInfo: '',
        dialoglist: '',
        layoutState: true,
        favorites_dialog_title: '',
        dialogEditNumbers: [],
        showEditNumbers: '',
        isChecked: false,
        settingDivClass: 'todo-setting-div',
        isShow: true,
        defaultPhoneNumberChecked: false,
        favoritesIndex: '',
        todoIndex: '',
        ic_free_space: '/res/image/ic_contacts_favorite_me_36.svg',
        ic_avatar_normal_light: '/res/image/ic_contacts_name_m.svg',
        ic_phonecall_m_block: '/res/image/ic_phonecall_m_block.svg',
        simpleDialogContactId: '',
        globalX: 0,
        globalY: 0,
        pYMove: 0,
        headerFavoriteHeight: NUMBERS_MEANING.HEADER_MAX_HEIGHT,
        headerFavoriteFontSize: NUMBERS_MEANING.HEADER_MAX_FONT_SIZE,
        isScrollTopPosition: false,
        onScrollTopNum: 0,
        dialogheight: 0,
    },
    onInit() {
        this.favorites_dialog_title = this.$t('value.favorites.page.dialog.title');
        this.settingDivClass = 'todo-setting-div';
    },
    onShow() {
    },
    onRefreshFavorite: function () {
        this.conciseLayoutInit();
        this.getFavoritesContacts();
    },

    conciseLayoutInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_concise_layout_switch', 'false');
        this.layoutState = data == 'true' ? false : true;
    },
    showRecordDetails: function (contactId) {
        this.$app.$def.setRefreshFavorite();
        router.push({
            uri: 'pages/contacts/contactDetail/contactDetail',
            params: {
                contactId: contactId,
                isNewSource: true,
            }
        });
    },
    showFavoriteDialog: function (contactId) {
        var phoneNumberLabelNames = [this.$t('accountants.house'), this.$t('accountants.phone'), this.$t('accountants.unit'), this.$t('accountants.unit fax'), this.$t('accountants.home fax'), this.$t('accountants.pager'), this.$t('accountants.others'), '', '', '', '', this.$t('accountants.switchboard')];
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.queryPhoneNumByContactId(DAHelper, contactId, phoneNumberLabelNames, result => {
            if (result.code == 0 && result.data) {
                if (result.data.phoneNumbers == undefined || result.data.phoneNumbers.length == 0) {
                    prompt.showToast({
                        message: this.$t('value.favorites.page.dialog.noAvailablePhoneNumber')
                    });
                } else if (result.data.phoneNumbers.length == 1) {

                    this.showEditNumbers = result.data.phoneNumbers[0].phoneNumber;

                    this.callOut(this.showEditNumbers);
                } else {
                    var setDefaultNum = false;
                    for (var i = 0; i < result.data.phoneNumbers.length; i++) {
                        if (SET_DEFAULT == result.data.phoneNumbers[i].isPrimary) {
                            this.showEditNumbers = result.data.phoneNumbers[i].phoneNumber;
                            setDefaultNum = true;
                            break;
                        }
                    }
                    if (setDefaultNum) {
                        this.$element('simpledialog').close();
                        this.callOut(this.showEditNumbers);
                    } else {
                        this.dialogEditNumbers = result.data.phoneNumbers;
                        if (this.dialogEditNumbers.length >= 6) {
                            this.dialogheight = 720;
                        } else {
                            this.dialogheight = this.dialogEditNumbers.length * 120
                        }
                        this.simpleDialogContactId = contactId;
                        this.$element('simpledialog').show();
                    }
                }
            } else {
                prompt.showToast({
                    message: 'No data available!'
                });
            }
        });
    },
    cancelSimpleSchedule: function (event) {
        this.$element('simpledialog').close();
    },

    dialogFavoriteClick: function (phoneNumber) {
        this.showEditNumbers = phoneNumber;
        this.$element('simpledialog').close();
        if (this.defaultPhoneNumberChecked) {
            this.defaultPhoneNumberChecked = false;
            var actionData = {};
            actionData.contactId = this.simpleDialogContactId;
            actionData.phoneNumber = this.showEditNumbers.replace(/\s+/g, '');
            actionData.isPrimary = SET_DEFAULT;
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
            favoritesModel.setOrCancelDefaultPhoneNumber(DAHelper, actionData, result => {
            });
        }

        this.callOut(this.showEditNumbers);
    },

    checkboxClick: function (event) {
        this.isChecked = !this.isChecked;
    },
    settingSelected: function (event) {
        if ('editor' == event.value) {
            this.isShow = false;
            this.$emit('eventType', {
                menuShow: false
            });
        }
    },
    longFavoritesPress: function (contactId, pressIndex) {
        var title = this.$t('value.contacts.groupsPage.alreadySelect').replace('num', '1');
        router.push({
            uri: 'pages/contacts/selectContactsList/selectContactsList',
            params: {
                type: 'editFavorites',
                contactId: contactId,
                pressIndex: pressIndex,
                title: title
            },
        })
    },
    longTodoPress: function (index) {
        this.$emit('eventType', {
            menuShow: false
        });
        this.isShow = false;
        this.favoritesIndex = '';
        this.todoIndex = index;
    },

    favoritesDeleteBack: function (e) {
        this.isShow = e.detail.isShow;
        this.favoritesList = e.detail.collection;
        this.todoList = e.detail.frequent;
        this.$emit('eventType', {
            menuShow: true
        });
    },


    addTouchEnd: function (event) {
        router.push({
            uri: 'pages/contacts/selectContactsList/selectContactsList',
            params: {
                type: 'getContactsListFavorites'
            },
        })
    },

    getFavoritesContacts() {
        var actionData = {
            limit: 2000,
            page: 0,
            star: 1
        }
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.queryFavoritesContacts(DAHelper, actionData, result => {
            if (result.code == 0) {
                if (result.resultList.length > 0) {
                    this.favoritesList = result.resultList;
                } else {
                    this.favoritesList = [];
                }
                if (result.todoList.length > 0) {
                    this.todoList = result.todoList;
                } else {
                    this.todoList = [];
                }
            } else {
                this.favoritesList = [];
                this.todoList = [];
                LOG.info(TAG + 'getFavoritesContacts' + 'plus result is error:');
            }
        });


    },
    getToDoContacts() {
        var actionData = {
            limit: 2000,
            page: 0,
            star: 1
        }
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.queryFrequentlyContact(DAHelper, actionData, result => {
            if (result.code == 0 && result.todoList.length > 0) {
                LOG.error(TAG + 'getToDoContacts' + 'result.todoList: ');
                this.todoList = result.todoList;
            } else {
                this.todoList = [];
                LOG.info(TAG + 'getToDoContacts' + 'plus result is erro:');
            }
        });
    },

    editOnSelected: function (event) {
        var title = this.$t('value.contacts.groupsPage.noSelect');
        if (event.value == 'edit') {
            router.push({
                uri: 'pages/contacts/selectContactsList/selectContactsList',
                params: {
                    type: 'editFavorites',
                    title: title
                },
            })
        }
    },

    callOut(phoneNumber) {
        this.$app.$def.call(phoneNumber);
    },

    simpleDialogItemClick: function (status) {
        this.defaultPhoneNumberChecked = !status;
    },

    onTouchStartList: function (e) {
        this.globalX = e.touches[0].globalX;
        this.globalY = e.touches[0].globalY;
        this.pYStart = e.touches[0].globalY;
    },

    onTouchListMove: function (e) {
        this.pYMove = this.pYStart - e.touches[0].globalY;
        if (this.pYMove != 0 && this.pYMove > 0) {
            if (this.headerFavoriteHeight <= NUMBERS_MEANING.HEADER_MIN_HEIGHT) {
                this.isScrollTopPosition = true;
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE;
                this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MIN_HEIGHT;
            } else {
                this.headerFavoriteHeight = this.headerFavoriteHeight - this.pYMove;
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE + NUMBERS_MEANING.HEADER_MIN_TO_MAX_FONT_SIZE * ((this.headerFavoriteHeight - NUMBERS_MEANING.HEADER_MIN_HEIGHT) / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE);
            }
        } else if (this.pYMove != 0 && this.pYMove < 0) {
            if (this.headerFavoriteHeight >= NUMBERS_MEANING.HEADER_MAX_HEIGHT) {
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;
                this.isScrollTopPosition = false;
            } else {
                this.headerFavoriteHeight = this.headerFavoriteHeight - this.pYMove;
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE + NUMBERS_MEANING.HEADER_MIN_TO_MAX_FONT_SIZE * ((this.headerFavoriteHeight - NUMBERS_MEANING.HEADER_MIN_HEIGHT) / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE);
            }
        } else {
        }
    },

    onTouchFavoriteEnd: function (e) {
        if (this.pYMove != 0 && this.pYMove > 0 && this.headerFavoriteHeight <= NUMBERS_MEANING.HEADER_MIN_HEIGHT) {

            this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MIN_HEIGHT;
            this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE;
        } else if (this.pYMove != 0 && this.pYMove < 0 && this.headerFavoriteHeight >= NUMBERS_MEANING.HEADER_MAX_HEIGHT && this.isScrollTopPosition == true) {

            this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MAX_HEIGHT;
            this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;
        } else if (this.pYMove != 0 && this.pYMove < 0 && this.onScrollTopNum == 0) {

            this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MAX_HEIGHT;
            this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;
        } else {
            this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE + NUMBERS_MEANING.HEADER_MIN_TO_MAX_FONT_SIZE * ((this.headerFavoriteHeight - NUMBERS_MEANING.HEADER_MIN_HEIGHT) / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE);
        }
        if (this.headerFavoriteHeight > NUMBERS_MEANING.HEADER_MAX_HEIGHT) {
            this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MAX_HEIGHT;
        }
        if (this.headerFavoriteFontSize > NUMBERS_MEANING.HEADER_MAX_FONT_SIZE) {
            this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;
        }
        this.pYMove = 0;
        this.pYStart = 0;
    },

    onScrollFavoriteTop: function (e) {
        this.isScrollTopPosition = true;
        this.onScrollTopNum = this.onScrollTopNum + 1;
    },
}

