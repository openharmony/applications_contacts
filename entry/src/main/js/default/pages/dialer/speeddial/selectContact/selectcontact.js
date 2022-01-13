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
import router from '@system.router';
import Utils from '../../../../../default/utils/utils.js'
import selectContactsAbility from '../../../../../default/model/SelectcontactsModel.js';
import Constants from '../../../../../default/common/constants/Constants.js';
import httpcontact from '../../../../../default/model/ContactModel.js';
import LOG from '../../../../utils/ContactsLog.js';
import groupReq from '../../../../model/GroupsModel.js';

var TAG = 'selectContact';

export default {
    data: {
        searchText: '',
        contactList: [],
        emptyText: '',
        searchContactList: [],
        showEmpty: false,
    //Show content layout
        contentShow: false,
    //Show search title
        searchTitleLayout: true,
    //Show search list
        searchLayoutShow: false,
        searchPhoneNum: 0,
        searchDefaultName: '',
        phoneCheckShow: false,
        childPhoneCheckShow: false,
        showNumberList: true,
        showDefaultNumber: true,
        page: 0,
        contactCount: 0,
        limit: 200,
        routerParamsSpeedDialIndex: -1,
        defaultHead: '',
        searchRequestCode: 2012
    },
    onInit() {
        this.emptyText = this.$t('value.selectContact.page.empty');
        if (Utils.isEmpty(this.searchDefaultName)) {
            //Initialize contact data
            this.initData();
        } else {
            this.searchText = this.searchDefaultName;
            this.onSearchTextChange(this.searchText);
        }
    },
    initData() {
        this.page = 0;
        var requestData = {
            page: this.page,
            limit: this.limit
        };
        this.requestInit(requestData);
    },
    back() {
        router.back();
    },
    onTextChange(text) {
        if (Utils.isEmpty(text.text)) {
            this.emptyText = this.$t('value.selectContact.page.empty');
            this.refreshLayout();
        } else {
            this.searchText = text.text;
            this.onSearchTextChange(this.searchText);
        }
    },
    touchStartSearch: function () {
        this.$element('search').focus({
            focus: true
        })
    },
    editContactsInfo(e) {
        if (!e.detail.contacts.isPushed) {
            e.detail.contacts.phoneNumbers.push({
                'labelId': 2,
                'labelName': this.$t('accountants.phone'),
                'phoneNumber': this.number,
                'phoneAddress': 'N',
                'showP': false,
                'blueStyle': true
            });
            e.detail.contacts.isPushed = true;
        }
        LOG.info(TAG + 'editContactsInfo' + 'logMessage phoneNumbers = ' + e.detail.contacts.phoneNumbers);
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
                    contactForm: e.detail.contacts
                }
            });
    },

    requestItem: function () {
        this.page++;
        var requestData = {
            page: this.page,
            limit: this.limit
        };
        this.requestInit(requestData);
    },

    requestInit: function (data) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        selectContactsAbility.queryContacts(DAHelper, resultList=>{
            if(Utils.isEmptyList(resultList)) {
                LOG.info(TAG + 'requestInit' + 'logMessage select contact list is empty!!');
            } else {
                var listTemp = [];
                var speedNumberMap = new Map();
                if (this.type == 'saveSpeedDial') {
                    for(let i = 1; i <=9; i++) {
                        var speedItemString = this.$app.$def.globalData.storage.getSync('speedDial'+i,'');
                        if (!Utils.isEmpty(speedItemString)) {
                            var speedItem = JSON.parse(speedItemString);
                            speedNumberMap.set(speedItem.speedNumber,null);
                        }
                    }
                }
                if (resultList.length > 0) {
                    resultList.forEach(element => {
                        element.name = {};
                        element.name.fullName = element.emptyNameData;
                        element.name.namePrefix = element.namePrefix;
                        element.name.nameSuffix = element.nameSuffix;
                        element.portraitPath = false;
                        if (!Utils.isEmpty(element.phoneNumbers) && element.phoneNumbers.length > 0) {
                            var phoneNumbersTemp = []; //Create filtered phone number container
                            element.phoneNumbers.forEach(childEle => {
                                childEle.checked = false;
                                childEle.labelName = this.getPhoneLabelNameById(childEle.labelId);
                                this.initVariableSpan(element);
                    // When speed dialing jumps to this page, if speed dialing has been set, no container will be added
                                if (!speedNumberMap.has(Utils.removeSpace(childEle.phoneNumber))) {
                                    phoneNumbersTemp.push(childEle);
                                }
                            })
                            if (phoneNumbersTemp.length > 0) {
                    // Displayed in the contact list only if there are phone numbers that are not set to speed dial.
                                element.phoneNumbers = phoneNumbersTemp;
                                listTemp.push(element);
                            }
                        }
                    });
                    this.contactList = listTemp;
                }
            }
            this.refreshLayout();
        });
    },

    getPhoneLabelNameById: function(phoneLabelId) {
        var labelName = '';
        switch (parseInt(phoneLabelId)) {
            case 1:
            labelName = this.$t('accountants.house');
            break;
            case 2:
            labelName = this.$t('accountants.phone');
            break;
            case 3:
            labelName = this.$t('accountants.unit');
            break;
            case 4:
            labelName = this.$t('accountants.unit fax');
            break;
            case 5:
            labelName = this.$t('accountants.home fax');
            break;
            case 6:
            labelName = this.$t('accountants.pager');
            break;
            case 7:
            labelName = this.$t('accountants.others');
            break;
            case 12:
            labelName = this.$t('accountants.switchboard');
            break;
            case 99:
            labelName = this.$t('accountants.customize');
            break;
            default:
                break;
        }
        return labelName;
    },


    initVariableSpan: function (item) {
        //Initialize variable name
        var matchString = Utils.getMatchedString(item.emptyNameData, this.searchText);
        if (Utils.isEmpty(matchString) || Utils.isEmpty(this.searchText.trim())) {
            item.name.searchTextStart = '';
            item.name.searchTextMiddle = '';
            item.name.searchTextEnd = item.emptyNameData
        } else {
            var name = item.emptyNameData;
            var index = name.indexOf(matchString);
            item.name.searchTextStart = name.substr(0, index);
            item.name.searchTextMiddle = name.substr(index, matchString.length);
            item.name.searchTextEnd = name.substr(index + matchString.length);
        }
        //Initialize variable phone number
        for (var i = 0; i < item.phoneNumbers.length; i++) {
            var phoneNumber = item.phoneNumbers[i].phoneNumber;
            var matchStringPhone = Utils.getMatchedString(phoneNumber, this.searchText);
            if (Utils.isEmpty(matchStringPhone) || Utils.isEmpty(this.searchText.trim())) {
                item.phoneNumbers[i].startPhone = ''
                item.phoneNumbers[i].middlePhone = ''
                item.phoneNumbers[i].endPhone = phoneNumber;
            } else {
                var phoneIndex = phoneNumber.indexOf(matchStringPhone);
                item.phoneNumbers[i].startPhone = phoneNumber.substr(0, phoneIndex);
                item.phoneNumbers[i].middlePhone = phoneNumber.substr(phoneIndex, matchStringPhone.length);
                item.phoneNumbers[i].endPhone = phoneNumber.substr(phoneIndex + matchStringPhone.length);
            }
        }
    },


    duplicateRemoval: function (result) {
        if (Utils.isEmptyList(result.data)) {
            return result;
        }
        var resultList = result.data;
        for (var i = 0; i < resultList.length; i++) {
            var item = resultList[i];
            var phoneNumbersList = [];
            //Sort in reverse order to repeat the last addition
            for (var j = item.phoneNumbers.length - 1; j >= 0; j--) {
                var indexOf = this.indexOf(item.phoneNumbers[j], phoneNumbersList);
                //Add if it does not exist
                if (indexOf == -1) {
                    phoneNumbersList.push(item.phoneNumbers[j]);
                }
            }
            this.initVariableSpan(item);
            item.phoneNumbers = phoneNumbersList;
        }
        return result;
    },

    indexOf: function (item, phoneNumbersList) {
        var index = -1;
        if (Utils.isEmptyList(phoneNumbersList)) {
            return index;
        }
        for (var i = 0; i < phoneNumbersList.length; i++) {
            LOG.info(TAG + 'indexOf' + 'select contact indexOf==>success');
            if (item.phoneNumber == phoneNumbersList[i].phoneNumber) {
                index = i;
                break;
            }
        }
        return index;
    },


    filterContact: function (contactData, result) {
        if (Utils.isEmptyList(contactData)) {
            return result;
        }
        var resultList = [];
        var resultDataList = result.data;
        for (var i = 0; i < resultDataList.length; i++) {
            var resultItem = resultDataList[i];
            for (var index = 0; index < contactData.length; index++) {
                var routerItem = contactData[index];
                var tempNumber;
                if (routerItem.contactId == resultItem.contactId) {
                    var phoneNumbers = resultItem.phoneNumbers;
                    tempNumber = [];
                    for (var j = 0; j < phoneNumbers.length; j++) {
                        //Filter by phone number and phone type
                        if (!((phoneNumbers[j].phoneNumber == routerItem.selectNumber)
                        && (phoneNumbers[j].labelId == routerItem.selectLabelId))) {
                            tempNumber.push(phoneNumbers[j]);
                        }
                    }
                    resultItem.phoneNumbers = tempNumber;
                }
            }
            //If there is no element in the phone list
            if (resultItem.phoneNumbers.length <= 0) {
                continue;
            }
            resultList.push(resultItem);
        }
        result.data = resultList;
        return result;
    },


    refreshLayout() {
        if (Utils.isEmptyList(this.contactList)) {
            //Contact data is empty
            this.searchTitleLayout = false;
            this.showEmpty = true;
            this.contentShow = false;
        } else {
            //Contact data is not empty
            this.searchTitleLayout = true;
            this.showEmpty = false;
            this.contentShow = true;
            this.searchLayoutShow = false;
        }
    },


    selectClick: function (params) {
        if (Utils.isEmpty(this.searchDefaultName)) {
            LOG.info(TAG + 'selectClick' + 'logMessage select=====>selectClick index:' + params.detail.index + '  indexChild:');
            var item = {};
            if (this.searchLayoutShow) {
                item = this.searchContactList[params.detail.index];
            } else {
                item = this.contactList[params.detail.index];
            }
            LOG.info(TAG + 'selectClick' + 'logMessage item = '+item);
            var indexChild = params.detail.indexChild;
            if (this.type == 'saveVoicemail') { //Voice mailbox select contact number
                var voicemailNumber = item.phoneNumbers[indexChild].phoneNumber;
                this.$app.$def.globalData.voicemailNumber = voicemailNumber;
            } else if (this.type == 'saveSpeedDial') {//Speed dial select contact
                var speedNumber = item.phoneNumbers[indexChild].phoneNumber
                var speedItem = {}; //Generate speed dial data based on the selected contact
                speedItem.emptyNameData = item.emptyNameData;
                speedItem.routerIndex = this.speedDialIndex + 1;
                speedItem.contactId = item.contactId;
                speedItem.nameSuffix = item.nameSuffix;
                speedItem.portraitColor = item.portraitColor;
                speedItem.portraitPath = Utils.isEmpty(item.portraitPath)? '': item.portraitPath;
                speedItem.speedNumber = Utils.removeSpace(speedNumber);
                this.$app.$def.globalData.storage.putSync('speedDial'+this.speedDialIndex,JSON.stringify(speedItem));
                this.$app.$def.globalData.storage.flushSync();
            }
            this.$app.$def.globalData.dialogShow = true;
            router.back();
        } else {
            var contactId = this.searchContactList[params.detail.index].contactId;
            router.push({
                uri: 'pages/contacts/contactDetail/contactDetail',
                params: {
                    contactId: contactId,
                    isNewSource: true,
                }
            });
        }
    },
    onSearchTextChange: function (text) {
        this.searchRequest(this.searchRequestCode, text);
    },


    searchRequest: function (code, keyText) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        var data = {};
        data.likeValue = keyText;
        groupReq.searchContacts(DAHelper, data, result => {
            if (result.code == 0 && result.contactCount > 0) {
                var resultData = this.duplicateRemoval(this.filterContact(this.contactData, result));
                this.searchContactList = resultData.data;
                this.searchPhoneNum = this.searchContactList.length;
            } else {
                this.searchContactList = [];
                LOG.error(TAG + 'searchRequest' + 'select contact request error');
            }
            this.searchPhoneNum = this.searchContactList.length;
            LOG.info(TAG + 'searchRequest' + 'select search request  result');
            this.refreshSearchList(keyText, this.searchContactList);
        });
    },


    refreshSearchList: function (keyText, searchContactList) {
        if (Utils.isEmpty(keyText)) {
            this.searchLayoutShow = false;
            this.emptyText = this.$t('value.selectContact.page.empty');
            this.showEmpty = true;
            this.contentShow = false;
            this.searchLayoutShow = false;
        } else {
            if (Utils.isEmptyList(searchContactList)) {
                //The search list is empty. Update the search text description
                this.emptyText = this.$t('value.selectContact.page.emptyText');
                this.showEmpty = true;
                this.contentShow = false;
                this.searchLayoutShow = false;
            } else {
                this.searchLayoutShow = true;
                this.contentShow = true;
                this.showEmpty = false;
                this.emptyText = this.$t('value.selectContact.page.empty');
            }
        }
    },


    searchIndexOf: function (keyText, source) {
        return source.indexOf(keyText);
    }
}
