/**
 * @file Selecting a Contact list
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
import ohosDataAbility from '@ohos.data.dataability';
import featureAbility from '@ohos.ability.featureAbility';
import groupReq from '../../../../default/model/GroupsModel.js';
import contactsDataBase from '../../../../default/model/SelectContactsListModel.js';
import favoritesModel from '../../../../default/model/FavoritesModel.js';
import LOG from '../../../utils/ContactsLog.js';
import Constants from '../../../../default/common/constants/Constants.js';

var TAG = 'selectContactsList...:';

const SEARCH_TYPE_FAVORITE = 1; // Search collection
const SEARCH_TYPE_IN_GROUP = 2; // Intra group search
const SEARCH_TYPE_OUTSIDE_GROUP = 3; // Out of group search
// 数字解释
const NUMBERS_MEANING = {
    HEADER_MIN_HEIGHT: 60,
    HEADER_MAX_HEIGHT: 180,
    HEADER_MIN_FONT_SIZE: 50,
    HEADER_MAX_FONT_SIZE: 60,
    HEADER_MIN_MAGIN_LENGTH: 0,
    HEADER_MAX_MAGIN_LENGTH: 75,
    HEADER_MIN_TO_MAX_FONT_SIZE: 10,
    HEADER_MIN_TO_MAX_HEIGHT_SIZE: 120,
};
const IS_FAVORITE = 1;
const IS_NOT_FAVORITE = 0;


export default {
    data: {
        title: '', // title
        type: '',
        groupId: 0,
        page: 0,
        limit: 20, // Number of entries per page
        showEmptyPage: false, // The list page is empty
        noMatchingResults: false, // The displayed search results are empty
        checkedNum: 0, // Number of contacts selected
        contactsList: [], // contact list
        todoList: [], // Favorite contacts
        matchingResults: [], // search result
        showSelectAll: true, // SelectAll
        addMemberDisabled: true,
        layoutState: true,
        showContactList: true,
        showMatchContactsList: false,
        contactId: '',
        pressIndex: 0,
        index: ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
        'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '…'],
        globalX: 0,
        globalY: 0,
        pYMove: 0,
        headerFavoriteHeight: NUMBERS_MEANING.HEADER_MAX_HEIGHT,
        headerFavoriteMaginLeft: NUMBERS_MEANING.HEADER_MIN_MAGIN_LENGTH,
        headerFavoriteFontSize: NUMBERS_MEANING.HEADER_MAX_FONT_SIZE,
        checkedList: [],
        contactCount: 0, // Total contacts
        frequentlyCount: 0, // Total number of favorites
        language: '',
        dialog: {
            dialogHeight: '',
            titleMarginTop: '',
            waringHeight: '',
            diaButPadTop: '',
            warningChecked: false,
            buttonDisable: false,
        },
        isClickSelectAll: false, // whether clicked select all
        checkedContactIds: [], // Selected contact collection
        unCheckedContactIds: [] // Unselect contact collection
    },
    onInit() {
        LOG.info(TAG + 'onInit success');
        this.title = this.$t('value.contacts.groupsPage.noSelect');
        this.language = 'zh';
        this.conciseLayoutInit();
        if (this.type == 'editFavorites') {
            this.getFavoritesContacts(this.contactId);
            return;
        }
        if (this.type == 'addMemberFromGroups') {
            this.getMembersOutSideGroup();
            return;
        }
        if (this.type == 'removeMemberFromGroups') {
            this.getGroupMemberList();
            return;
        }
        if (this.type == 'deleteBatchContacts' || this.type == 'saveContacts' || this.type
        == 'mmsChooseContacts') {
            this.getContactsList();
            return;
        }
        if (this.type == 'getContactsListFavorites') {
            this.getNotFavoritesContacts();
        }
    },

    requestItem: function () {
        this.page++;
        if (this.type == 'editFavorites') {
            return;
        }
        if (this.type == 'addMemberFromGroups') {
            this.getMembersOutSideGroup();
        }
        if (this.type == 'removeMemberFromGroups') {
            this.getGroupMemberList();
        }
        if (this.type == 'deleteBatchContacts' || this.type == 'saveContacts' || this.type
        == 'mmsChooseContacts') {
            this.getContactsList();
        }
        if (this.type == 'getContactsListFavorites') {
            this.getNotFavoritesContacts();
        }
    },
    getNotFavoritesContacts: function () {
        var actionData = {
            page: this.page,
            limit: this.limit,
            star: 0,
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.queryUnFavoritesContacts(DAHelper, actionData, result => {
            if (result.code == 0 && result.resultList.length > 0) {
                if (this.page == 0) {
                    result.resultList.forEach((item) => {
                        item.checked = false;
                    });
                    this.contactsList = result.resultList;
                } else {
                    result.resultList.forEach((item) => {
                        this.updateItemCheckedState(item);
                    });
                    this.contactsList = this.contactsList.concat(result.resultList);
                }
                this.contactCount = this.contactsList.length;
            }
            if (this.contactsList.length == 0) {
                this.showEmptyPage = true;
            }
        });
    },
    getMembersOutSideGroup: function () {
        var actionData = {
            page: this.page,
            limit: this.limit,
            groupId: this.groupId
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.getOutOfGroupMembers(DAHelper, actionData, result => {
            LOG.info(TAG + 'getMembersOutSideGroup result');
            if (result.code == 0 && result.totalCount > 0) {
                if (this.page == 0) {
                    result.resultList.forEach((item) => {
                        item.checked = false;
                    });
                    this.contactsList = result.resultList;
                } else {
                    result.resultList.forEach((item) => {
                        this.updateItemCheckedState(item);
                    });
                    this.contactsList = this.contactsList.concat(result.resultList);
                }
                this.contactCount = this.contactsList.length;
            }
            if (this.contactsList.length == 0) {
                this.showEmptyPage = true;
            }
        });
    },
    getGroupMemberList: function () {
        var actionData = {
            page: this.page,
            limit: this.limit,
            groupId: this.groupId
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryGroupMembers(DAHelper, actionData, result => {
            LOG.info(TAG + 'getGroupMemberList result');
            if (result.code == 0 && result.totalCount > 0) {
                if (this.page == 0) {
                    this.contactsList = result.resultList;
                } else {
                    result.resultList.forEach((item) => {
                        this.updateItemCheckedState(item);
                    });
                    this.contactsList = this.contactsList.concat(result.resultList);
                }
                this.contactCount = this.contactsList.length;
            } else if (result.code != 0) {
                prompt.showToast({
                    message: 'Failed to init data.'
                });
            } else {
                LOG.info(TAG + 'result.totalCount is 0');
            }
            if (this.contactsList.length == 0) {
                this.showEmptyPage = true;
            }
        });
    },
    getContactsList: function () {
        var actionData = {
            page: this.page,
            limit: this.limit
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactsDataBase.queryContactList(DAHelper, actionData, (result) => {
            LOG.info(TAG + 'getContactsList result' + result);
            result.contactCount = result.resultList.length;
            if (result.code == 0) {
                if (this.page == 0) {
                    result.resultList.forEach((item) => {
                        item.checked = false;
                    });
                    this.contactsList = result.resultList;
                } else {
                    result.resultList.forEach((item) => {
                        this.updateItemCheckedState(item);
                    });
                    this.contactsList = this.contactsList.concat(result.resultList);
                }
                this.contactCount = this.contactsList.length;
            } else {
                prompt.showToast({
                    message: 'Failed to init data.'
                });
            }
            if (this.contactsList.length == 0) {
                this.showEmptyPage = true;
            }
        });
    },
    clickSearch: function (e) {
        LOG.info(TAG + 'clickSearch e' + e);
        // Search input box
        if (e.text) {
            this.showContactList = false;
            this.showMatchContactsList = true;
            this.searchRequest(e.text);
        } else {
            if (this.checkedNum == this.contactCount) {
                this.showSelectAll = false;
            } else {
                this.showSelectAll = true;
            }
            this.showContactList = true;
            this.showMatchContactsList = false;
            this.noMatchingResults = false;
        }
    },
    touchStartSearch: function () {
        this.$element('search').focus({
            focus: true
        })
    },
    doSelect() {
        let checkedList = [];
        let contactIds = [];
        this.contactsList.forEach(item => {
            if (item.checked) {
                let contact = {
                    id : item.contactId,
                    name : item.emptyNameData,
                    telePhone : ''
                };
                contactIds.push(item.contactId);
                checkedList.push(contact);
            }
        });
        if(contactIds.length > 0) {
            let actionData = {
                contactIds: contactIds,
            };
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
            contactsDataBase.getTypeId(DAHelper,actionData, result => {
                if (result.resultList.length > 0) {
                    let telePhoneMap = new Map();
                    for(let element of result.resultList) {
                        if(!telePhoneMap.has(element.contactId)) {
                            telePhoneMap.set(element.contactId, element);
                        }
                    }
                    for(let item of checkedList) {
                        if(telePhoneMap.has(item.id)) {
                            item.telePhone = telePhoneMap.get(item.id).detailInfo;
                        }
                    }
                    this.saveSelectedContacts(checkedList);
                }
            });
        }
    },

    saveSelectedContacts(selectedContacts) {
        let contacts = this.dealContactName(selectedContacts);
        let parameters = {
            contactObjects: JSON.stringify(contacts)
        };
        var result = {
            resultCode: 0,
            want: {
                parameters: parameters
            }
        };
        LOG.info('selectedContacts result' + result);
        featureAbility.finishWithResult(result);
        featureAbility.terminateSelf();
        router.back();
    },

    dealContactName(checkedList) {
        let contacts = [];
        for (let item of checkedList) {
            let contact = {
                contactName: item.name,
                telephone: item.telePhone
            };
            contacts.push(contact);
        }
        return contacts;
    },

    /**
     * Search request background
     *
     * @param {string} keyText Input box text content
     */
    searchRequest: function (keyText) {
        LOG.info(TAG + 'searchRequest keyText');
        var requestData = {
            likeValue: keyText
        };
        if (this.type == 'addMemberFromGroups') {
            requestData.searchType = SEARCH_TYPE_OUTSIDE_GROUP;
            requestData.groupId = this.groupId;
        }
        if (this.type == 'removeMemberFromGroups') {
            requestData.searchType = SEARCH_TYPE_IN_GROUP;
            requestData.groupId = this.groupId;
        }
        // No favorite list page search
        if (this.type == 'getContactsListFavorites') {
            requestData.searchType = SEARCH_TYPE_FAVORITE;
            requestData.starred = IS_NOT_FAVORITE;
        }
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.searchContacts(DAHelper, requestData, result => {
            if (result.code == 0 && result.contactCount > 0) {
                let matchCheckedNum = 0;
                // Judge that if it is already selected, it will be initialized to the selected status
                result.data.forEach((item) => {
                    if (this.isClickSelectAll) {
                        if (this.indexOfArray(this.unCheckedContactIds, item.contactId) == -1) {
                            item.checked = true;
                            matchCheckedNum++;
                        } else {
                            item.checked = false;
                        }
                    } else if (this.indexOfArray(this.checkedContactIds, item.contactId) != -1) {
                        item.checked = true;
                        matchCheckedNum++;
                    } else {
                        item.checked = false;
                    }
                });
                this.processHighLight(result.data, keyText);
                this.matchingResults = [];
                this.matchingResults = result.data;
                // If all the search results are selected, select all will be on
                if (matchCheckedNum == this.matchingResults.length) {
                    this.showSelectAll = false;
                } else {
                    this.showSelectAll = true;
                }
            } else {
                this.matchingResults = [];
                this.showSelectAll = true;
                if (result.code != 0) {
                    prompt.showToast({
                        message: 'select contact request error.'
                    });
                }
            }
            if (this.matchingResults && this.matchingResults.length == 0) {
                this.noMatchingResults = true;
            } else {
                this.noMatchingResults = false;
            }
            LOG.info(TAG + 'select search request  result');
        });
    },
    updateItemCheckedState: function (item) {
        LOG.info(TAG + 'updateItemCheckedState item');
        if (this.isClickSelectAll) {
            if (this.indexOfArray(this.unCheckedContactIds, item.contactId) == -1) {
                item.checked = true;
            } else {
                item.checked = false;
            }
        } else if (this.indexOfArray(this.checkedContactIds, item.contactId) != -1) {
            item.checked = true;
        } else {
            item.checked = false;
        }
    },

    processHighLight: function (searchList, likeValue) {
        searchList.forEach((element) => {
            if (element.searchMimetype[0].search('/name') != -1) {

                this.conditionOne(element, likeValue);

            } else if (element.searchMimetype[0].search('/organization') != -1) {

                this.conditionTwo(element, likeValue);

                this.conditionThree(element, likeValue);

            } else if (element.searchMimetype[0].search('/phone') != -1) {

                this.conditionFour(element, likeValue);

            } else if (element.searchMimetype[0].search('/email') != -1) {

                this.conditionFive(element, likeValue);

            } else if (element.searchMimetype[0].search('/im') != -1) {

                this.conditionSix(element, likeValue);

            } else if (element.searchMimetype[0].search('/postal-address_v2') != -1) {

                this.conditionSeven(element, likeValue);
            }
            else if (element.searchMimetype[0].search('/note') != -1) {

                this.conditionEight(element, likeValue);

            } else if (element.searchMimetype[0].search('/nickname') != -1) {

                this.conditionNine(element, likeValue);

            }
        });
    },

    conditionOne: function (element, likeValue) {
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
                organizationTitlePre = organizationTitle.substring(0,
                    organizationTitle.indexOf(organizationTitleMatch));

                organizationTitleSuf = organizationTitle.substring(organizationTitle.indexOf(organizationTitleMatch)
                + organizationTitleMatch.length);
            }
        }
        element.organization.organizationTitlePre = organizationTitlePre;
        element.organization.organizationTitleMatch = organizationTitleMatch;
        element.organization.organizationTitleSuf = organizationTitleSuf;
    },

    conditionThree: function (element, likeValue) {
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

                organizationNameSuf = organizationName.substring(organizationName.indexOf(organizationNameMatch)
                + organizationNameMatch.length);
            }
        }
        element.organization.organizationNamePre = organizationNamePre;
        element.organization.organizationNameMatch = organizationNameMatch;
        element.organization.organizationNameSuf = organizationNameSuf;
    },

    conditionFour: function (element, likeValue) {
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

            postalAddressSuf = postalAddress.substring(postalAddress.indexOf(postalAddressMatch)
            + postalAddressMatch.length);
        }
        element.postalAddresses[0].postalAddressPre = postalAddressPre;
        element.postalAddresses[0].postalAddressMatch = postalAddressMatch;
        element.postalAddresses[0].postalAddressSuf = postalAddressSuf;
    },

    conditionEight: function (element, likeValue) {
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

    itemClick: function (item) {
        LOG.info(TAG + 'itemClick item');
        if (this.type == 'saveContacts') {
            if (!this.isEmpty(this.number)) { // Save new number to contact
                router.push(
                    {
                        uri: 'pages/contacts/accountants/accountants',
                        params: {
                            addShow: false,
                            updataShow: true,
                            showWork: true,
                            upHouseShow: true,
                            upPinShow: true,
                            saveContact: true,
                            contactId: item.contactId,
                            phoneNumber: this.number
                        }
                    });
            }
            return;
        }
        item.checked = !item.checked;
        if (item.checked) {
            if (!this.isClickSelectAll) {
                this.checkedContactIds.push(item.contactId);
            } else {
                this.removeFromArray(this.unCheckedContactIds, item.contactId);
            }
        } else if (this.isClickSelectAll) {
            this.unCheckedContactIds.push(item.contactId);
        } else {
            this.removeFromArray(this.checkedContactIds, item.contactId);
        }
        this.updateCheckedNumAndButtonState();
        this.initTitle();
    },

    toSaveContactsInfo(contacts) {
        LOG.info(TAG + 'toSaveContactsInfo contacts');
        if (!contacts.isPushed) { // Prevent the same contact from adding numbers more than once
            if (contacts.phoneNumbers && contacts.phoneNumbers.length == 0) {
                contacts.phoneNumbers = [];
            }
            contacts.phoneNumbers.push({
                'labelId': 2,
                'labelName': this.$t('accountants.phone'),
                'phoneNumber': this.number,
                'phoneAddress': 'N',
                'showP': false,
                'blueStyle': true
            });
            contacts.isPushed = true;
        }
        router.push(
            {
                uri: 'pages/contacts/accountants/accountants',
                params: {
                    addShow: false,
                    updataShow: true,
                    showWork: true,
                    upHouseShow: true,
                    upPinShow: true,
                    saveContact: true,
                    contactForm: contacts
                }
            });
    },
    searchItemClick: function (item) {
        LOG.info(TAG + 'searchItemClick item');
        item.checked = !item.checked;
        var checkedList = [];
        this.matchingResults.forEach((contact) => {
            if (contact.checked) {
                checkedList.push(contact);
            }
        });

        if (item.checked) {
            if (!this.isClickSelectAll) {
                this.checkedContactIds.push(item.contactId);
            } else {
                this.removeFromArray(this.unCheckedContactIds, item.contactId);
            }
            // If the search result is selected, the contact list follows the selection
            this.contactsList.forEach((contact) => {
                if (item.contactId == Number(contact.contactId)) {
                    contact.checked = true;
                }
            });
            this.checkedNum++;
            if (checkedList.length == this.matchingResults.length) {
                this.showSelectAll = false;
            }
        } else {
            if (this.isClickSelectAll) {
                this.unCheckedContactIds.push(item.contactId);
            } else {
                this.removeFromArray(this.checkedContactIds, item.contactId);
            }
            this.contactsList.forEach((contact) => {
                if (item.contactId == Number(contact.contactId)) {
                    contact.checked = false;
                }
            });
            this.checkedNum--;
            this.showSelectAll = true;
        }

        if (this.checkedNum == 0) {
            this.addMemberDisabled = true;
        } else {
            this.addMemberDisabled = false;
        }
        this.initTitle();
    },
    clickAddMember: function () {
        var actionData = {};
        actionData.groupId = this.groupId.toString();
        actionData.contactBeans = [];
        if (this.isClickSelectAll) {
            actionData.isOperationAll = true;
            this.unCheckedContactIds.forEach((contactId) => {
                var checkItem = {};
                checkItem.contactId = contactId;
                actionData.contactBeans.push(checkItem);
            });
        } else {
            actionData.isOperationAll = false;
            this.checkedContactIds.forEach((contactId) => {
                var checkItem = {};
                checkItem.contactId = contactId;
                actionData.contactBeans.push(checkItem);
            });
        }
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.addGroupMembers(DAHelper, actionData, result => {
            router.back();
        });
    },
    clickDeleteMember: function () {
        var actionData = {};
        actionData.groupId = this.groupId;
        actionData.contactBeans = [];
        if (this.isClickSelectAll) {
            actionData.isOperationAll = true;
            this.unCheckedContactIds.forEach((contactId) => {
                var checkItem = {};
                checkItem.contactId = contactId;
                actionData.contactBeans.push(checkItem);
            });
        } else {
            actionData.isOperationAll = false;
            this.checkedContactIds.forEach((contactId) => {
                var checkItem = {};
                checkItem.contactId = contactId;
                actionData.contactBeans.push(checkItem);
            });
        }
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.deleteGroupMembers(DAHelper, actionData, result => {
            router.back();
        });
    },
    cancelClick: function () {
        this.$element('deleteWarning').close();
        this.dialog.warningChecked = false;
        this.dialog.buttonDisable = false;
    },
    deleteClick: function () {
        var actionData = {};
        actionData.contactIds = [];
        if (this.isClickSelectAll) {
            actionData.isOperationAll = true;
            this.unCheckedContactIds.forEach((contactId) => {
                var checkItem = {};
                checkItem.contactId = contactId;
                actionData.contactIds.push(checkItem);
            });
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
            contactsDataBase.checkedDelete(DAHelper, actionData.isOperationAll, this.unCheckedContactIds, (result) => {
                if (result == 0) {
                    router.back();
                } else {
                    LOG.error(TAG + 'delete contacts code is ');
                }
            });
        } else {
            actionData.isOperationAll = false;
            this.checkedContactIds.forEach((contactId) => {
                var checkItem = {};
                checkItem.contactId = contactId;
                actionData.contactIds.push(checkItem);
            });
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
            contactsDataBase.checkedDelete(DAHelper, actionData.isOperationAll, this.checkedContactIds, (result) => {
                if (result == 0) {
                    router.back();
                } else {
                    LOG.error(TAG + 'delete contacts code is ');
                }
            });
        }
    },
    dialogChecked: function () {
        this.dialog.warningChecked = !this.dialog.warningChecked;
        this.dialog.buttonDisable = this.dialog.warningChecked ? true : false;
    },
    checkedChange: function (e) {
        this.dialog.warningChecked = e.checked;
        this.dialog.buttonDisable = this.dialog.warningChecked ? true : false;
    },
    clickDeleteContacts: function () {
        this.checkedList = [];
        this.contactsList.forEach(item => {
            if (item.checked) {
                this.checkedList.push(item.contactId);
            }
        });
        switch (this.language) {
            case 'zh':
                this.dialog.dialogHeight = '378px';
                this.dialog.titleMarginTop = '30px';
                this.dialog.waringHeight = '76px';
                this.dialog.diaButPadTop = '15px';
                break;
            case 'en':
                this.dialog.dialogHeight = '415px';
                this.dialog.titleMarginTop = '32px';
                this.dialog.waringHeight = '110px';
                this.dialog.diaButPadTop = '15px';
                break;
            default:
                this.dialog.dialogHeight = '378px';
                this.dialog.titleMarginTop = '30px';
                this.dialog.diaButPadTop = '15px';
                break;
        }
        this.$element('deleteWarning').show();
    },
    clickSelectAll: function () {
        if (this.showContactList) {
            this.isClickSelectAll = true;
            this.contactsList.forEach((item) => {
                item.checked = true;
            });
            this.todoList.forEach(item => {
                item.checked = true;
            });
            this.unCheckedContactIds = [];
            this.checkedContactIds = [];
            this.updateCheckedNumAndButtonState();
        }
        if (this.showMatchContactsList) {
            this.matchingResults.forEach((item) => {
                if (!item.checked) {
                    if (this.isClickSelectAll) {
                        this.removeFromArray(this.unCheckedContactIds, item.contactId);
                    } else {
                        this.checkedContactIds.push(item.contactId);
                    }
                    this.checkedNum++;
                }
                item.checked = true;
            });
            this.contactsList.forEach((item) => {
                this.updateItemCheckedState(item);
            });

            this.showSelectAll = false;
            this.addMemberDisabled = false;
        }
        this.initTitle();
    },
    clickCancelSelectAll: function () {
        if (this.showContactList) {
            this.isClickSelectAll = false;
            this.contactsList.forEach((item) => {
                item.checked = false;
            });
            this.todoList.forEach(item => {
                item.checked = false;
            });
            this.unCheckedContactIds = [];
            this.checkedContactIds = [];
            this.updateCheckedNumAndButtonState();
        }
        if (this.showMatchContactsList) {
            this.matchingResults.forEach((item) => {
                if (item.checked) {
                    if (this.isClickSelectAll) {
                        this.unCheckedContactIds.push(item.contactId);
                    } else {
                        this.removeFromArray(this.checkedContactIds, item.contactId);
                    }
                    this.checkedNum--;
                }
                item.checked = false;
            });
            this.contactsList.forEach((item) => {
                this.updateItemCheckedState(item);
            });

            this.showSelectAll = true;
            if (this.checkedNum == 0) {
                this.addMemberDisabled = true;
            } else {
                this.addMemberDisabled = false;
            }
        }
        this.initTitle();
    },
    initTitle: function () {
        if (this.checkedNum != 0) {
            if (!this.showSelectAll && this.isClickSelectAll) {
                this.title = this.$t('value.contacts.groupsPage.alreadySelect').replace('num', (this.contactCount
                + this.frequentlyCount) + '');
            } else {
                this.title = this.$t('value.contacts.groupsPage.alreadySelect').replace('num', this.checkedNum + '');
            }
        } else {
            this.title = this.$t('value.contacts.groupsPage.noSelect');
        }
    },
    updateCheckedNumAndButtonState: function () {
        if (this.isClickSelectAll) {
            if (this.unCheckedContactIds.length == 0) {
                this.showSelectAll = false;
            } else {
                this.showSelectAll = true;
            }
            this.checkedNum = (this.contactCount + this.frequentlyCount) - this.unCheckedContactIds.length;
        } else {
            if (this.checkedContactIds.length == this.contactCount + this.frequentlyCount) {
                this.showSelectAll = false;
            } else {
                this.showSelectAll = true;
            }
            this.checkedNum = this.checkedContactIds.length;
        }
        if (this.checkedNum == 0) {
            this.addMemberDisabled = true;
        } else {
            this.addMemberDisabled = false;
        }
    },

    back: function () {
        router.back();
    },
    clickAddFavorites: function () {
        let timestamp = (new Date()).valueOf();
        var actionData = {
            favorite: '1',
            favorite_order: timestamp
        };
        actionData.ids = [];
        if (this.isClickSelectAll) {
            actionData.isOperationAll = true;
            this.unCheckedContactIds.forEach((contactId) => {
                actionData.ids.push(contactId);
            });
        } else {
            actionData.isOperationAll = false;
            this.checkedContactIds.forEach((contactId) => {
                actionData.ids.push(contactId);
            });
        }
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.updateFavoriteState(DAHelper, actionData, result => {
            if (result == 0) {
                this.$app.$def.setRefreshFavorite();
                router.back();
            } else {
                LOG.info(TAG + 'plus result is error:');
            }
        });
    },
    clickDeleteFavorites: function () {
        var actionData = {
            favorite: '0'
        };
        actionData.ids = [];
        this.checkedContactIds.forEach((contactId) => {
            actionData.ids.push(contactId);
        });
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.removeFavoriteState(DAHelper, actionData, result => {
            if (result == 0) {
                this.$app.$def.setRefreshFavorite();
                router.back();
            } else {
                LOG.info(TAG + 'plus result is error:');
            }
        });
    },
    getFavoritesContacts(contactId) {
        var actionData = {
            page: this.page,
            limit: this.limit,
            star: 1
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.queryFavoritesContacts(DAHelper, actionData, result => {
            LOG.info(TAG + 'query delete star list =' + result);
            if (result.code == 0) {
                LOG.error(TAG + 'result favorites list: ');
                result.resultList.forEach(item => {
                    if (item.contactId == contactId) {
                        item.checked = true;
                        this.checkedContactIds.push(contactId);
                        this.checkedNum++;
                        this.addMemberDisabled = false;
                    } else {
                        item.checked = false;
                    }
                });
                result.todoList.forEach(element => {
                    if (element.contactId == contactId) {
                        element.checked = true;
                        this.checkedContactIds.push(contactId);
                        this.checkedNum++;
                        this.addMemberDisabled = false;
                    } else {
                        element.checked = false;
                    }
                });
                for (var index in result.resultList) {
                    if (result.resultList[index].contactId == contactId) {
                        this.pressIndex = index;
                        break;
                    }
                }
                for (var idx in result.todoList) {
                    if (result.todoList[idx].contactId == contactId) {
                        this.pressIndex = idx;
                        break;
                    }
                }
                this.contactsList = result.resultList;
                this.todoList = result.todoList;
                this.contactCount = result.contactCount;
                this.frequentlyCount = result.frequentlyCount;
                if ((this.contactCount + this.frequentlyCount) == this.checkedNum) {
                    this.showSelectAll = !this.showSelectAll;
                }
            } else {
                this.contactsList = [];
                this.todoList = [];
                this.showEmptyPage = true;
                LOG.info(TAG + 'plus result is error:');
            }
            this.initTitle();
        });
    },

    onTouchStartList: function (e) {
        if (this.type == 'editFavorites') {
            this.globalX = e.touches[0].globalX;
            this.globalY = e.touches[0].globalY;
            this.pYStart = e.touches[0].globalY;
        }
    },
    onTouchListMove: function (e) {
        if (this.type == 'editFavorites') {
            this.pYMove = this.pYStart - e.touches[0].globalY;
            if (this.pYMove != 0 && this.pYMove > 0) {
                // Move up, hidden, no processing required; To move the display status upward, you need to set the hide
                if (this.headerFavoriteHeight <= NUMBERS_MEANING.HEADER_MIN_HEIGHT) {
                    this.isScrollTopPosition = true;
                    this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE;
                    this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH;
                    this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MIN_HEIGHT;
                } else {
                    this.headerFavoriteHeight = this.headerFavoriteHeight - this.pYMove;

                    this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE
                    + NUMBERS_MEANING.HEADER_MIN_TO_MAX_FONT_SIZE * ((this.headerFavoriteHeight
                    - NUMBERS_MEANING.HEADER_MAX_FONT_SIZE) / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE);

                    this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH
                    - NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH * ((this.headerFavoriteHeight
                    - NUMBERS_MEANING.HEADER_MAX_FONT_SIZE) / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE);
                }
            } else if (this.pYMove != 0 && this.pYMove < 0) {
                // Whether the combination is the top. If it is the top, the top should be displayed
                if (this.headerFavoriteHeight >= NUMBERS_MEANING.HEADER_MAX_HEIGHT) {
                    this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;
                    this.isScrollTopPosition = false;
                    this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MIN_MAGIN_LENGTH;
                } else {
                    this.headerFavoriteHeight = this.headerFavoriteHeight - this.pYMove;

                    this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE
                    + NUMBERS_MEANING.HEADER_MIN_TO_MAX_FONT_SIZE * ((this.headerFavoriteHeight
                    - NUMBERS_MEANING.HEADER_MAX_FONT_SIZE) / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE);

                    let fontSize = this.headerFavoriteHeight - NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;

                    let favHeight = fontSize / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE;
                    this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH
                    - (NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH * favHeight);
                }
            }
        }
    },
    onTouchFavoriteEnd: function (e) {
        if (this.type == 'editFavorites') {
            if (this.pYMove != 0 && this.pYMove > 0 && this.headerFavoriteHeight <= NUMBERS_MEANING.HEADER_MIN_HEIGHT) {
                // Move up, hidden, no processing required; To move the display status upward, you need to set the hide
                this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MIN_HEIGHT;
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE;
                this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH;
            } else if (this.pYMove != 0 && this.pYMove < 0 && this.headerFavoriteHeight
            >= NUMBERS_MEANING.HEADER_MAX_HEIGHT && this.isScrollTopPosition == true) {
                // Whether the combination is the top. If it is the top, the top should be displayed
                this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MAX_HEIGHT;
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;
                this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MIN_MAGIN_LENGTH;
            } else if (this.pYMove != 0 && this.pYMove < 0 && this.onScrollTopNum == 0) {
                this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MAX_HEIGHT;
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;
                this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MIN_MAGIN_LENGTH;
            } else {
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MIN_FONT_SIZE
                + NUMBERS_MEANING.HEADER_MIN_TO_MAX_FONT_SIZE * ((this.headerFavoriteHeight
                - NUMBERS_MEANING.HEADER_MIN_HEIGHT) / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE);

                this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH
                - NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH * ((this.headerFavoriteHeight
                - NUMBERS_MEANING.HEADER_MIN_HEIGHT) / NUMBERS_MEANING.HEADER_MIN_TO_MAX_HEIGHT_SIZE);
            }
            if (this.headerFavoriteHeight > NUMBERS_MEANING.HEADER_MAX_HEIGHT) {
                this.headerFavoriteHeight = NUMBERS_MEANING.HEADER_MAX_HEIGHT;
            }
            if (this.headerFavoriteFontSize > NUMBERS_MEANING.HEADER_MIN_HEIGHT) {
                this.headerFavoriteFontSize = NUMBERS_MEANING.HEADER_MAX_FONT_SIZE;
            }
            if (this.headerFavoriteMaginLeft > NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH) {
                this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MAX_MAGIN_LENGTH;
            }
            if (this.headerFavoriteMaginLeft < 0) {
                this.headerFavoriteMaginLeft = NUMBERS_MEANING.HEADER_MIN_MAGIN_LENGTH;
            }
            this.pYMove = 0;
            this.pYStart = 0;
        }
    },
    onScrollFavoriteTop: function (e) {
        if (this.type == 'editFavorites') {
            // If it is judged to be the top, mark it
            this.isScrollTopPosition = true;
            this.onScrollTopNum = this.onScrollTopNum + 1;
        }
    },

    conciseLayoutInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_concise_layout_switch', 'false');
        this.layoutState = data == 'true' ? false : true;
    },
    indexOfArray: function (arr, val) {
        for (var i = 0; i < arr.length; i++) {
            if (arr[i] == val) {
                return i;
            }
        }
        return -1;
    },
    removeFromArray: function (arr, val) {
        var index = arr.indexOf(val);
        if (index > -1) {
            arr.splice(index, 1);
        }
    }
};