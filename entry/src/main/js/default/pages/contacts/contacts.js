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
import Utils from '../../../default/utils/utils.js';
import prompt from '@system.prompt';
import contactsService from '../../../default/model/ContactModel.js';
import groupReq from '../../../default/model/GroupsModel.js'
import cardModel from '../../../default/model/AccountantsModel.js'
import LOG from '../../utils/ContactsLog.js';
import Constants from '../../../default/common/constants/Constants.js';
import sim from '@ohos.telephony.sim';
import backgroundColor from '../../common/constants/color.js';

var TAG = 'Contacts...:';

export default {
    props: ['isInit', 'cancelMaskLayer'],
    data: {
        contactsList: [],
        shareList: [],
        importList: [],
        fileName: '00001.vcf',
        lastIndex: '#',
        position: {
            X: 0,
            Y: 0
        },
        myCardInfo: {
            cardId: '',
            cardName: '',
            hasMyCard: false,
        },
        nameSuffix: '',
        portraitPath: '',
        portraitColor: '',
        contactsName: '',
        menuTimeOutId: '',
        deleteIndex: '',
        indexer: -1,
        ic_free_space: '/res/image/ic_contacts_favorite_me_36.svg',
        language: '',
        buttonWidths: '350px',
        contactLengthText: '',
        page: 0,
        isShow: false,
        isExist: false,
        layoutState: true,
        contactCount: 0,
        contacts: [],
        numberList: [],
        index: ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '…'],
        isShowName: 'true',
        searchTimeOutId: '',
        animation: {
            title: '',
            backBut: '',
            setting: '',
            contactTitle: '',
            search: '',
            list: '',
            isHidden: false,
            isAddShow: true,
            isSearch: false
        },
        queryContactsType: 'all',
        isEmptyGroup: true,
        marginTop: '195px',
        listHeight: '72%',
        isSearchList: false,
        searchList: [],
        isFirstChange: true,
        searchContactsNumber: '',
        backgroundColor: backgroundColor.Color,
        limit: 20
    },
    onInit() {
        LOG.info(TAG + 'onInit contacts page.');
    },
    onReady: function () {
        LOG.info(TAG + 'onReady contacts page.');
    },
    onHide: function () {
        LOG.info(TAG + 'onHide contacts page.');
    },
    onShow: function () {
        LOG.info(TAG + 'onShow contacts page.');
    },
    onDestroy: function () {
        LOG.info(TAG + 'onDestroy contacts page.');
    },
    onBackPress: function () {
        LOG.info(TAG + 'onBackPress contacts page.');
    },

    onRefresh: function () {
        LOG.info(TAG + 'Contacts onRefresh --------------start');
        this.contactCount = 0;
        this.contactsList = [];
        this.isShow = false;
        this.radioInit();
        while (this.contactsList.length < this.contactCount) {
            this.requestItem();
        }
        this.language = 'zh';
        this.buttonWidths = 'zh' == this.language ? this.buttonWidths : '650px';
        this.contactLengthText = 'zh' == this.language ? this.$t('value.contacts.page.contactsLength') : this.$tc('value.contacts.page.contactsLength', this.contactsList.length);
        this.shareList = [{
                              text: this.$t('value.contacts.page.menu.shareInfo.content.qrCode')
                          },
                          {
                              text: this.$t('value.contacts.page.menu.shareInfo.content.vCard')
                          },
                          {
                              text: this.$t('value.contacts.page.menu.shareInfo.content.text')
                          }];

        this.animation.isSearch = this.$app.$def.globalData.contactsAnimation.isSearch;
        this.animation.title = this.$app.$def.globalData.contactsAnimation.title;
        this.animation.setting = this.$app.$def.globalData.contactsAnimation.setting;
        this.animation.contactTitle = this.$app.$def.globalData.contactsAnimation.contactTitle;
        this.animation.search = this.$app.$def.globalData.contactsAnimation.search;
        this.animation.isHidden = this.$app.$def.globalData.contactsAnimation.isHidden;
        this.animation.backBut = this.$app.$def.globalData.contactsAnimation.backBut;
        this.isSearchList = this.$app.$def.globalData.isSearchList;

        if (this.$app.$def.globalData.searchValue) {
            this.touchStartSearch();
            this.changeSearch({
                text: this.$app.$def.globalData.searchValue
            });
        }

        LOG.info(TAG + 'Contacts onRefresh --------------end');
    },

    radioInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_display_account_radio', 'allContacts');
        switch (data) {
            case 'allContacts':
                this.queryContactsType = 'all';
                this.marginTop = '195px';
                this.isEmptyGroup = true;
                break;
            case 'phoneContacts':
                this.queryContactsType = 'phone';
                this.isEmptyGroup = false;
                this.marginTop = '-205px';
                break;
            case 'customize':
                this.queryContactsType = 'custom';
                this.isEmptyGroup = false;
                this.marginTop = '-205px';
                break;
            default:
                break;
        }
        this.page = 0;
        var requestData = {
            page: this.page,
            limit: this.limit,
            queryContactsType: this.queryContactsType
        };

        this.requestInit(2001, requestData);
        this.conciseLayoutInit();
    },

    requestItem: function () {
        if (this.contactsList.length < this.contactCount) {
            this.page++;
            var requestData = {
                page: this.page,
                limit: this.limit,
                queryContactsType: this.queryContactsType
            };
            this.requestPage(2001, requestData);
        }
    },

    requestInit: function (code, data) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        LOG.info(TAG + 'requestInit get DAHelper --------------');
        if (data.queryContactsType == 'custom') {
            let ret = this.$app.$def.globalData.storage.getSync('contacts_settings_customize_view_input', 'false');
            data.ret = ret;
            contactsService.queryCustomizeGroups(DAHelper, data, (result) => {
                if (result.code == 0 && result.contactCount > 0) {
                    this.contactsList = result.resultList;
                    this.contactCount = result.contactCount;
                    this.$app.$def.globalData.contactCount = this.contactCount;
                    this.isExist = false;
                } else {
                    this.$app.$def.globalData.contactCount = result.contactCount;
                    if (result.code != 0) {
                        prompt.showToast({
                            message: 'Failed to init data.'
                        });
                    }
                    this.isExist = true;
                    this.isShow = false;
                }
                this.initMyCard();
            });
        } else {
            contactsService.queryContacts(DAHelper, data, (result) => {
                if (result.code == 0 && result.contactCount > 0) {
                    this.contactsList = result.resultList;
                    this.contactCount = result.contactCount;
                    this.$app.$def.globalData.contactCount = this.contactCount;
                    this.isExist = false;
                } else {
                    this.$app.$def.globalData.contactCount = result.contactCount;
                    if (result.code != 0) {
                        prompt.showToast({
                            message: 'Failed to init data.'
                        });
                    }
                    this.isExist = true;
                    this.isShow = false;
                }
                this.initMyCard();
            });
        }
    },

    requestRefresh: function (code, data) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        LOG.info(TAG + 'Contacts requestRefresh get DAHelper --------------');
        if (data.queryContactsType == 'custom') {
            let ret = this.$app.$def.globalData.storage.getSync('contacts_settings_customize_view_input', 'false');
            data.ret = ret;
            contactsService.queryCustomizeGroups(DAHelper, data, (result) => {
                if (result.code == 0 && result.contactCount > 0) {
                    this.contactsList = result.resultList;
                    this.contactCount = result.contactCount;
                    this.isExist = false;
                } else {
                    if (result.code != 0) {
                        prompt.showToast({
                            message: 'Failed to init data.'
                        });
                    }
                    this.isExist = true;
                    this.isShow = false;
                }
            });
        } else {
            contactsService.queryContacts(DAHelper, data, (result) => {
                if (result.code == 0 && result.contactCount > 0) {
                    this.contactsList = result.resultList;
                    this.contactCount = result.contactCount;
                    this.isExist = false;
                } else {
                    if (result.code != 0) {
                        prompt.showToast({
                            message: 'Failed to init data.'
                        });
                    }
                    this.isExist = true;
                    this.isShow = false;
                }
            });
        }
    },

    conciseLayoutInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_concise_layout_switch', 'false');
        this.layoutState = data == 'true' ? false : true;
    },

    sleep: function (milliSeconds) {
        var startTime = new Date().getTime();
        while (new Date().getTime() < startTime + milliSeconds) {
            LOG.info(TAG + 'wait...');
        }
    },

    requestPage: function (code, data) {
        LOG.info(TAG + 'requestPage code' + 'data')
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        if (data.queryContactsType == 'custom') {
            let ret = this.$app.$def.globalData.storage.getSync('contacts_settings_customize_view_input', 'false');
            data.ret = ret;
            contactsService.queryCustomizeGroups(DAHelper, data, (result) => {
                if (result.code == 0) {
                    this.contactsList = this.contactsList.concat(result.resultList);
                    if (result.resultList.length == 0) {
                        this.contactsList.map(item => {
                            if (item.namePrefix > this.lastIndex) {
                                this.lastIndex = item.namePrefix;
                            }
                            return item;
                        });
                        this.isShow = false;
                    }
                } else {
                    prompt.showToast({
                        message: 'Failed to paging data.'
                    });
                }
            });
        } else {
            contactsService.queryContacts(DAHelper, data, (result) => {
                if (result.code == 0) {
                    this.contactsList = this.contactsList.concat(result.resultList);
                    if (result.resultList.length == 0) {
                        this.contactsList.map(item => {
                            if (item.namePrefix > this.lastIndex) {
                                this.lastIndex = item.namePrefix;
                            }
                            return item;
                        });
                        this.isShow = false;
                    }
                } else {
                    prompt.showToast({
                        message: 'Failed to paging data.'
                    });
                }
            });
        }
    },

    scrollBottom: function () {
    },

    /**
     * Delete contact list data
     *
     * @param code
     * @param data  contactId The contact ID
     */
    deleteContactData: function (code, data) {
        LOG.info(TAG + 'deleteContactData code' + 'data')
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactsService.deleteContacts(DAHelper, data, (result) => {
            if (result == 0) {
                if (this.indexer > -1) {
                    this.contactsList.splice(this.indexer, 1);
                }
                this.contactCount > 0 ? this.contactCount-- : this.contactCount;
                if (this.isSearchList && this.searchList.length > 0) {
                    this.searchList.splice(this.indexer, 1);
                }
                this.indexer = -1;
                this.deleteIndex = '';
                this.contactsName = '';
                this.isExist = this.contactCount > 0 ? this.isExist : true;
                this.onRefresh();
            } else {
                prompt.showToast({
                    message: 'Failed to delete data.'
                });
            }
        });
    },
    shareClick: function (idx) {
        LOG.info(TAG + 'shareClick idx' + idx)
        switch (idx) {
            case 0:
                prompt.showToast({
                    message: 'Call share qr code three parties'
                });
                break;
            case 1:
                prompt.showToast({
                    message: 'Call share vCard three parties'
                });
                break;
            case 2:
                prompt.showToast({
                    message: 'Call text tripartite'
                });
                break;
            default:
                break;
        }
    },
    shareCancelClick: function () {
        this.$element('shareDialog').close();
    },
    cancelClick: function () {
        this.$element('deleteDialog').close();
        this.indexer = -1;
        this.deleteIndex = '';
        this.contactsName = '';
    },
    deleteClick: function () {
        this.$element('deleteDialog').close();
        if (this.indexer == -1 || Utils.isEmpty(this.deleteIndex)) {
            return;
        }
        var requestData = {
            contactId: this.deleteIndex
        };
        this.deleteContactData(2003, requestData);
    },

    importContactClicked: function () {
        this.$element('importContactsDialog').show();
    },

    importCancelClick: function () {
        this.$element('importContactsDialog').close();
    },

    importClick: function (idx) {
        LOG.info(TAG + 'shareClick idx' + idx)
        switch (idx) {
            case 0:

                this.$element('ImportDialog').show();
                break;
        }
    },
    closeImportDialog: function () {
        this.$element('ImportDialog').close();
    },

    newContactClicked: function () {
        router.push({
            uri: 'pages/contacts/accountants/accountants',
            params: {},
        });
    },

    addContactClicked: function () {
        router.push({
            uri: 'pages/contacts/accountants/accountants',
            params: {},
        });
    },
    listItemTouchStart: function (event) {
        LOG.info(TAG + 'listItemTouchStart event')
        this.position.X = Math.round(event.touches[0].globalX);
        this.position.Y = Math.round(event.touches[0].globalY);
    },
    listItemOnLongPress: function (index, event) {
        LOG.info(TAG + 'listItemOnLongPress index' + index + 'event')
        this.contactsName = event.emptyNameData == undefined || event.emptyNameData == '' ? '' : this.slice(event.emptyNameData, 9);
        this.isShowName = event.emptyNameData == '' || event.emptyNameData == undefined ? false : true;
        this.deleteIndex = event.contactId;
        this.indexer = index;
        var tempX = this.position.X;
        var tempY = this.position.Y;
        clearTimeout(this.menuTimeOutId);
        this.menuTimeOutId = setTimeout(() => {
            this.$element('itemMenu').show({
                x: tempX,
                y: tempY
            });
        }, 1);
    },

    slice: function (str, maxLength) {
        LOG.info(TAG + 'slice str' + str + 'maxLength' + maxLength)
        var result = '';
        var flag = false;
        var len = 0;
        var length = 0;
        var length2 = 0;
        for (var i = 0; i < str.length; i++) {
            var code = str.codePointAt(i).toString(16);
            if (code.length > 4) {
                i++;
                if ((i + 1) < str.length) {
                    flag = str.codePointAt(i + 1).toString(16) == '200d';
                }
            }
            if (flag) {
                len += this.getByteByHex(code);
                if (i == str.length - 1) {
                    length += len;
                    if (length <= maxLength) {
                        result += str.substr(length2, i - length2 + 1);
                    } else {
                        break
                    }
                }
            } else {
                if (len != 0) {
                    length += len;
                    length += this.getByteByHex(code);
                    if (length <= maxLength) {
                        result += str.substr(length2, i - length2 + 1);
                        length2 = i + 1;
                    } else {
                        break
                    }
                    len = 0;
                    continue;
                }
                length += this.getByteByHex(code);
                if (length <= maxLength) {
                    if (code.length <= 4) {
                        result += str[i]
                    } else {
                        result += str[i - 1] + str[i]
                    }
                    length2 = i + 1;
                } else {
                    break;
                }
            }
        }
        if (length > 9) {
            result = result + '..';
        }
        return result;
    },

    getByteByBinary: function (binaryCode) {
        LOG.info(TAG + 'getByteByBinary binaryCode' + binaryCode)
        var byteLengthDatas = [0, 1, 2, 3, 4];
        var len = byteLengthDatas[Math.ceil(binaryCode.length / 8)];
        return len;
    },

    getByteByHex: function (hexCode) {
        LOG.info(TAG + 'getByteByHex hexCode' + hexCode)
        return this.getByteByBinary(parseInt(hexCode, 16).toString(2));
    },


    todoSelected: function (event) {
        LOG.info(TAG + 'todoSelected event' + event)
        if (event.value == 'delete') {
            this.$element('deleteDialog').show();
        }
        if (event.value == 'shareContact') {
            this.$element('shareDialog').show();
        }
    },
    cancelSelected: function () {
        this.contactsName = '';
        this.indexer = -1;
        this.deleteIndex = '';
    },

    focusSearch: function (e) {
        LOG.info(TAG + 'focusSearch e' + e);
    },
    todoSearch: function () {
        LOG.info(TAG + 'todoSearch');
    },
    submitSearch: function () {
        LOG.info(TAG + 'submitSearch');
    },
    clickSearch: function () {
        this.$element('search').focus({
            focus: true
        });
        LOG.info(TAG + 'clickSearch');
    },
    back: function () {
        if (this.animation.isHidden) {
            this.$element('searchDoing').focus({
                focus: false
            });
            this.animation.isSearch = false;
            this.$app.$def.setIsSearch(this.animation.isSearch);
            this.isSearchList = false;
            this.$app.$def.setIsSearchList(this.isSearchList);
            this.listHeight = '72%';
            this.animation.title = 'show-title';
            this.animation.setting = 'show-setting';
            this.animation.contactTitle = 'show-contact-title';
            this.animation.backBut = 'hidden-back';
            this.animation.search = 'search-recover';
            this.animation.isHidden = false;
            this.$app.$def.setContactsAnimation('', 'hidden-init', '', '', '', this.animation.isHidden);
            this.$emit('eventType', {
                menuShow: true,
                isMaskLayer: false,
                contentHeight: '92%'
            });
            this.animation.isAddShow = true;
            LOG.info(TAG + 'back isAddShow' + this.animation.isAddShow);
        }
    },
    touchStartSearch: function () {
        LOG.info(TAG + 'search is touchStartSearch');
        this.animation.contactTitle = '';
        this.animation.setting = '';
        this.animation.backBut = '';
        this.animation.contactTitle = 'hidden-contact-title';
        this.animation.setting = 'hidden-setting';
        this.animation.backBut = 'show-back';
        this.animation.title = '';
        this.animation.title = 'hidden-title';
        this.animation.search = '';
        this.animation.search = 'search-translation';
        this.animation.isHidden = true;
        this.$app.$def.setContactsAnimation(this.animation.title, 'show-back-init', this.animation.setting,
            this.animation.contactTitle, 'search-init-action', this.animation.isHidden);
        this.animation.isAddShow = false;
        this.$emit('eventType', {
            menuShow: false,
            isMaskLayer: true,
            contentHeight: '100%'
        });
        clearTimeout(this.searchTimeOutId);
        this.searchTimeOutId = setTimeout(() => {
            this.animation.isSearch = true;
            this.$app.$def.setIsSearch(this.animation.isSearch);
            this.listHeight = '100%';
            this.touchStart();
        }, 400);
    },
    touchStart: function () {
        this.$element('searchDoing').focus({
            focus: true
        })
    },
    changeSearch: function (e) {
        LOG.info(TAG + 'changeSearch e.text');
        if (e.text == '') {
            this.$emit('eventType', {
                menuShow: false,
                isMaskLayer: true
            });
            this.isSearchList = false;
            this.$app.$def.setIsSearchList(this.isSearchList);
        } else {
            this.searchList = [];
            this.$emit('eventType', {
                menuShow: false,
                isMaskLayer: false
            });
            this.isSearchList = true;
            this.$app.$def.setIsSearchList(this.isSearchList);
            var data = {};
            data.likeValue = e.text;
            this.searchResult(data);
        }
    },

    searchResult: function (data) {
        LOG.info(TAG + 'searchResult data' + data);
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.searchContacts(DAHelper, data, result => {
            LOG.log(TAG + 'searchList=' + result);
            if (result.code == 0 && result.contactCount > 0) {
                this.processHighLight(result.data, data.likeValue);
                this.searchList = result.data;
                LOG.log(TAG + 'process searchList=' + this.searchList);
            } else if (result.code != 0) {
                prompt.showToast({
                    message: 'Failed to init data.'
                });
            }
            this.$app.$def.globalData.searchValue = '';
        });
    },

    processHighLight: function (searchList, likeValue) {
        LOG.info(TAG + 'processHighLight searchList' + 'likeValue' + likeValue);
        searchList.forEach((element) => {
            if (element.searchMimetype[0].search('/name') != -1) {

                this.conditionOne(element, likeValue)

            } else if (element.searchMimetype[0].search('/organization') != -1) {

                this.conditionTwo(element, likeValue)

                this.conditionThree(element, likeValue)

            } else if (element.searchMimetype[0].search('/phone') != -1) {

                this.conditionFour(element, likeValue)

            } else if (element.searchMimetype[0].search('/email') != -1) {

                this.conditionFive(element, likeValue)

            } else if (element.searchMimetype[0].search('/im') != -1) {

                this.conditionSix(element, likeValue)

            } else if (element.searchMimetype[0].search('/postal-address_v2') != -1) {

                this.conditionSeven(element, likeValue)
            }
            else if (element.searchMimetype[0].search('/note') != -1) {

                this.conditionEight(element, likeValue)

            } else if (element.searchMimetype[0].search('/nickname') != -1) {

                this.conditionNine(element, likeValue)

            }
        });
    },

    conditionOne: function (element, likeValue) {
        LOG.info(TAG + 'conditionOne element' + 'likeValue' + likeValue);
        var emptyName = element.emptyNameData;
        var emptyNameMatch = this.highLightChars(emptyName, likeValue);
        var emptyNamePre = '';
        var emptyNameSuf = '';
        if (this.isEmpty(emptyNameMatch)) {
            emptyNamePre = '';
            emptyNameMatch = '';
            emptyNameSuf = emptyName;
        } else {
            emptyNamePre = emptyName.substring(0, emptyName.indexOf(emptyNameMatch));
            emptyNameSuf = emptyName.substring(emptyName.indexOf(emptyNameMatch) + emptyNameMatch.length);
        }

        element.emptyNamePre = emptyNamePre;
        element.emptyNameMatch = emptyNameMatch;
        element.emptyNameSuf = emptyNameSuf;
    },

    conditionTwo: function (element, likeValue) {
        LOG.info(TAG + 'conditionTwo element' + 'likeValue' + likeValue);
        var organizationTitle = element.organization.title;
        if (this.isEmpty(organizationTitle)) {
            organizationTitlePre = '';
            organizationTitleMatch = '';
            organizationTitleSuf = '';
        } else {
            var organizationTitleMatch = this.highLightChars(organizationTitle, likeValue);
            var organizationTitlePre = '';
            var organizationTitleSuf = '';
            if (this.isEmpty(organizationTitleMatch)) {
                organizationTitlePre = '';
                organizationTitleMatch = '';
                organizationTitleSuf = organizationTitle;
            } else {
                organizationTitlePre = organizationTitle.substring(0, organizationTitle.indexOf(organizationTitleMatch));
                organizationTitleSuf = organizationTitle.substring(organizationTitle.indexOf(organizationTitleMatch)
                + organizationTitleMatch.length);
            }
        }
        element.organization.organizationTitlePre = organizationTitlePre;
        element.organization.organizationTitleMatch = organizationTitleMatch;
        element.organization.organizationTitleSuf = organizationTitleSuf;
    },

    conditionThree: function (element, likeValue) {
        LOG.info(TAG + 'conditionThree element' + 'likeValue' + likeValue);
        var organizationName = element.organization.name;
        if (this.isEmpty(organizationName)) {
            organizationNamePre = '';
            organizationNameMatch = '';
            organizationNameSuf = '';
        } else {
            var organizationNameMatch = this.highLightChars(organizationName, likeValue);
            var organizationNamePre = '';
            var organizationNameSuf = '';
            if (this.isEmpty(organizationNameMatch)) {
                organizationNamePre = '';
                organizationNameMatch = '';
                organizationNameSuf = organizationName;
            } else {
                organizationNamePre = organizationName.substring(0, organizationName.indexOf(organizationNameMatch));
                organizationNameSuf = organizationName.substring(organizationName.indexOf(organizationNameMatch) + organizationNameMatch.length);
            }
        }
        element.organization.organizationNamePre = organizationNamePre;
        element.organization.organizationNameMatch = organizationNameMatch;
        element.organization.organizationNameSuf = organizationNameSuf;
    },

    conditionFour: function (element, likeValue) {
        LOG.info(TAG + 'conditionFour element' + 'likeValue' + likeValue);
        var phoneNumber = element.phoneNumbers[0].phoneNumber;
        var phoneNumberMatch = this.highLightChars(phoneNumber, likeValue);
        var phoneNumberPre = '';
        var phoneNumberSuf = '';
        if (this.isEmpty(phoneNumberMatch)) {
            phoneNumberPre = '';
            phoneNumberMatch = '';
            phoneNumberSuf = phoneNumber;
        } else {
            phoneNumberPre = phoneNumber.substring(0, phoneNumber.indexOf(phoneNumberMatch));
            phoneNumberSuf = phoneNumber.substring(phoneNumber.indexOf(phoneNumberMatch) + phoneNumberMatch.length);
        }
        element.phoneNumbers[0].phoneNumberPre = phoneNumberPre;
        element.phoneNumbers[0].phoneNumberMatch = phoneNumberMatch;
        element.phoneNumbers[0].phoneNumberSuf = phoneNumberSuf;
    },

    conditionFive: function (element, likeValue) {
        LOG.info(TAG + 'conditionFive element' + 'likeValue' + likeValue);
        var email = element.emails[0].email;
        var emailMatch = this.highLightChars(email, likeValue);
        var emailPre = '';
        var emailSuf = '';
        if (this.isEmpty(emailMatch)) {
            emailPre = '';
            emailMatch = '';
            emailSuf = email;
        } else {
            emailPre = email.substring(0, email.indexOf(emailMatch));
            emailSuf = email.substring(email.indexOf(emailMatch) + emailMatch.length);
        }
        element.emails[0].emailPre = emailPre;
        element.emails[0].emailMatch = emailMatch;
        element.emails[0].emailSuf = emailSuf;
    },

    conditionSix: function (element, likeValue) {
        LOG.info(TAG + 'conditionSix element' + 'likeValue' + likeValue);
        var imAddress = element.imAddresses[0].imAddress;
        var imAddressMatch = this.highLightChars(imAddress, likeValue);
        var imAddressPre = '';
        var imAddressSuf = '';
        if (this.isEmpty(imAddressMatch)) {
            imAddressPre = '';
            imAddressMatch = '';
            imAddressSuf = imAddress;
        } else {
            imAddressPre = imAddress.substring(0, imAddress.indexOf(imAddressMatch));
            imAddressSuf = imAddress.substring(imAddress.indexOf(imAddressMatch) + imAddressMatch.length);
        }
        element.imAddresses[0].imAddressPre = imAddressPre;
        element.imAddresses[0].imAddressMatch = imAddressMatch;
        element.imAddresses[0].imAddressSuf = imAddressSuf;
    },

    conditionSeven: function (element, likeValue) {
        LOG.info(TAG + 'conditionSeven element' + 'likeValue' + likeValue);
        var postalAddress = element.postalAddresses[0].postalAddress;
        var postalAddressMatch = this.highLightChars(postalAddress, likeValue);
        var postalAddressPre = '';
        var postalAddressSuf = '';
        if (this.isEmpty(postalAddressMatch)) {
            postalAddressPre = '';
            postalAddressMatch = '';
            postalAddressSuf = postalAddress;
        } else {
            postalAddressPre = postalAddress.substring(0, postalAddress.indexOf(postalAddressMatch));
            postalAddressSuf = postalAddress.substring(postalAddress.indexOf(postalAddressMatch) + postalAddressMatch.length);
        }
        element.postalAddresses[0].postalAddressPre = postalAddressPre;
        element.postalAddresses[0].postalAddressMatch = postalAddressMatch;
        element.postalAddresses[0].postalAddressSuf = postalAddressSuf;
    },

    conditionEight: function (element, likeValue) {
        LOG.info(TAG + 'conditionEight element' + 'likeValue' + likeValue);
        var note = element.note.noteContent;
        var noteMatch = this.highLightChars(note, likeValue);
        var notePre = '';
        var noteSuf = '';
        if (this.isEmpty(noteMatch)) {
            notePre = '';
            noteMatch = '';
            noteSuf = note;
        } else {
            notePre = note.substring(0, note.indexOf(noteMatch));
            noteSuf = note.substring(note.indexOf(noteMatch) + noteMatch.length);
        }
        element.note.notePre = notePre;
        element.note.noteMatch = noteMatch;
        element.note.noteSuf = noteSuf;
    },

    conditionNine: function (element, likeValue) {
        LOG.info(TAG + 'conditionEight element' + 'likeValue' + likeValue);
        var nickName = element.nickName.nickName;
        var nickNameMatch = this.highLightChars(nickName, likeValue);
        var nickNamePre = '';
        var nickNameSuf = '';
        if (this.isEmpty(nickNameMatch)) {
            nickNamePre = '';
            nickNameMatch = '';
            nickNameSuf = nickName;
        } else {
            nickNamePre = nickName.substring(0, nickName.indexOf(nickNameMatch));
            nickNameSuf = nickName.substring(nickName.indexOf(nickNameMatch) + nickNameMatch.length);
        }
        element.nickName.nickNamePre = nickNamePre;
        element.nickName.nickNameMatch = nickNameMatch;
        element.nickName.nickNameSuf = nickNameSuf;
    },

    highLightChars: function (targetStr, matchStr) {
        LOG.info(TAG + 'highLightChars targetStr' + 'matchStr');
        if (this.isEmpty(targetStr) || this.isEmpty(matchStr)) {
            return '';
        }
        var noSpaceMatch = matchStr.replace(/\s/g, '');
        var result = '';
        var spaceNum = 0;
        for (var i = 0; i < targetStr.length; i++) {
            if (targetStr.charAt(i) == noSpaceMatch.charAt(0)) {
                for (var r = 0; r < noSpaceMatch.length; r++) {
                    if (targetStr.charAt(i + r + spaceNum) == ' ') {
                        result = result + targetStr.charAt(i + r + spaceNum);
                        spaceNum++;
                        r--;
                        continue;
                    }
                    if (targetStr.charAt(i + r + spaceNum) == noSpaceMatch.charAt(r)) {
                        result = result + targetStr.charAt(i + r + spaceNum);
                        if (r == noSpaceMatch.length - 1) {
                            return result;
                        }
                    } else {
                        result = '';
                        spaceNum = 0;
                        break;
                    }
                }
            }
        }
        return result;
    },
    isEmpty: function (str) {
        LOG.info(TAG + 'isEmpty str');
        return str == undefined || str == null || str == '';
    },
    enterKeyClick: function (e) {
        LOG.info(TAG + 'enterKeyClick' + e);
    },
    cancelSearchDialog: function () {
        LOG.log(TAG + 'cancelSearchDialog');
    },

    onClickGroups: function () {
        LOG.log(TAG + 'click groups');
        router.push({
            uri: 'pages/contacts/groups/groups',
            params: {},
        });
    },

    redirectCard: function () {
        LOG.info(TAG + 'onclick card ');
        if (this.myCardInfo.hasMyCard) {
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
            cardModel.getCardDetails(DAHelper, this.myCardInfo.cardId, (result) => {
                var contactForm = result.data;
                router.push({
                    uri: 'pages/contacts/card/card',
                    params: {
                        contactForm: contactForm,
                    },
                });
            });
        } else {
            this.getDefaultSimNumber((defaultSimNumber) => {
                if (Utils.isEmpty(defaultSimNumber)) {
                    router.push({
                        uri: 'pages/contacts/accountants/accountants',
                        params: {
                            carteFlag: true,
                            addShow: false,
                            updateShow: false
                        },
                    })
                } else {
                    router.push({
                        uri: 'pages/contacts/accountants/accountants',
                        params: {
                            carteFlag: true,
                            addShow: false,
                            updateShow: false,
                            phoneNumbers: [
                                {
                                    'labelId': 2,
                                    'labelName': this.$t('accountants.phone'),
                                    'phoneNumber': defaultSimNumber,
                                    'phoneAddress': 'N',
                                    'showP': true,
                                    'blueStyle': true
                                }
                            ]
                        },
                    });
                }
            })
        }
    },

    async getDefaultSimNumber(callBack) {
        var defaultSimSlot = 0;
        var defaultSimNumber = '';
        try {
            defaultSimSlot = await sim.getDefaultVoiceSlotId();
        } catch {
            defaultSimSlot = 0;
            LOG.error(TAG + 'get default sim slot error!');
        }
        try {
            defaultSimNumber = await sim.getSimTelephoneNumber(defaultSimSlot);
        } catch {
            defaultSimNumber = '';
            LOG.error(TAG + 'get default sim telephoneNumber error!');
        }
        callBack(defaultSimNumber);
    },
    initMyCard: function () {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        cardModel.getMyCardId(DAHelper, (cardMainInfo) => {
            LOG.error(TAG + 'initMyCard cardMainInfo');
            if (Utils.isEmpty(cardMainInfo)) {
                this.myCardInfo.hasMyCard = false;
            } else {
                this.myCardInfo.hasMyCard = true;
                this.myCardInfo.cardName = cardMainInfo.cardName;
                this.myCardInfo.cardId = cardMainInfo.cardId;
            }
        })
    },

    showRecordDetails: function (index, type) {
        LOG.error(TAG + 'showRecordDetails index' + index);
        var contactId = type == 'search' ? this.searchList[index].contactId : this.contactsList[index].contactId;
        router.push({
            uri: 'pages/contacts/contactDetail/contactDetail',
            params: {
                contactId: contactId,
                isNewSource: true,
            }
        });
    },

    settingOnSelected: function (event) {
        if (event.value == 'settings') {
            router.push({
                uri: 'pages/contacts/settings/settings',
                params: {},
            });
        }
    },
}

