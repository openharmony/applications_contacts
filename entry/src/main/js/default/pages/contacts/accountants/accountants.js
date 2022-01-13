/**
 * @file Creating a Contact
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
import contactReq from '../../../../default/model/AccountantsModel.js';
import configuration from '@system.configuration';
import contactDetailReq  from '../../../../default/model/ContactDetailModel.js';
import LOG from '../../../utils/ContactsLog.js';
import Constants from '../../../../default/common/constants/Constants.js';
import Prompt from '@system.prompt';

var TAG = ' accountants...: ';

export default {
    data: {
        // New Contact Status
        addShow: true,
        // Editing contact Status
        updataShow: false,
        // Business card
        carteFlag: false,
        // Edit card
        updateCard: false,
        phonShow: false,
        MoreDivStatus: true,
        // State of pinyin
        LetterShow: false,
        // Instant Message Status
        upMessShow: false,
        // The bell state
        upRingShow: false,
        // Residential status
        upHouseShow: false,
        // The nickname status
        upNickShow: false,
        // Site condition
        upWebShow: false,
        // State of birthday
        upBirthShow: false,
        // assistant
        upAssShow: false,
        showWork: false,
        isEmpty: false,

        flexInputStyle: 'const-fisrt',
        flexImageStyle: 'const-image-div',
        flexImageSize: 'fisrt-image',
        flexInputSize: 'font-color-first',
        flexInputFont: 'font-color-note',
        flexCenterSize: 'text-note',
        ringText: '',
        id: 0,
        emailShow: false,
        messShow: false,
        houseShow: false,
        websiteShow: false,
        assisShow: false,
        groups: [],
        saveContact: false,
        phoneNumber: '',
        groupContext: '',
        emails: [
            {
                'id': 1,
                'email': '',
                'labelId': 1,
                'labelName': '',
                'showP': false
            }
        ],
        events: [
            {
                'id': 1,
                'eventDate': '',
                'labelId': 3,
                'showP': false,
                'showF': true,
                'showS': true
            }
        ],
        imAddresses: [
            {
                'id': 1,
                'imAddress': '',
                'labelId': 1,
                'labelName': 'AIM',
                'showP': false
            }
        ],
        phoneNumbers: [
            {
                'id': 1,
                'labelId': 2,
                'labelName': '',
                'phoneNumber': '',
                'phoneAddress': 'N',
                'blueStyle': false,
                'showP': false
            }
        ],
        postalAddresses: [
            {
                'id': 1,
                'labelId': 1,
                'labelName': '',
                'postalAddress': '',
                'showP': false
            }
        ],
        relations: [
            {
                'id': 1,
                'labelId': 1,
                'labelName': '',
                'relationName': '',
                'showP': false
            }
        ],
        websites: [
            {
                'id': 1,
                'website': '',
                'showP': false
            }
        ],
        name: {
            'fullName': '',
            'givenName': '',
            'familyName': '',
            'middleName': '',
            'familyNamePhonetic': '',
            'alphaName': ''
        },
        nickName: {
            'nickName': ''
        },
        note: {
            'noteContent': ''
        },
        organization: {
            'name': '',
            'title': ''
        },
        birthShow: false,
        showF: true,
        showS: true,
        types: ['3', '2', '4', '1'],
        typeShow: false,
        labType: '',
        labId: 0,
        contactForm: {},
        timeOutId: '',
        DialogStatus: true,
        year: '',
        endyear: '',
        customizeInputValue: '', // Customize the value of the input box
        oldCustomizeLabelId: '2',
        oldParam: {},
        isInitFirst: true,
        delCard: false,
        // Whether to add an id to the group
        groupStatus: false,
        contactId: 0,
        contacts: {},
        language: '',
        langStatus: true,
        usStatus: false,
        letter: '',
        givenName: '',
        familyName: '',
        middleName: '',
        familyNamePhonetic: '',
    },

    onInit() {
        LOG.info(TAG + 'onInit......');
        this.events[0].eventDate = this.$t('accountants.date');
        this.language = configuration.getLocale().language;
        this.isInitFirst = true;
        var date = new Date();
        this.letter = this.$t('accountants.letter');
        if (this.language == 'en') {
            this.langStatus = false;
        }
        this.endyear = date.getFullYear() + 1 + '-1-1';
        LOG.info(TAG + 'onInit' + '----' + this.endyear);
        var temp = '';

        if (this.addShow && !this.groupStatus) {
            this.contactForm = {
                'emails': this.emails,
                'events': this.events,
                'favorite': false,
                'imAddresses': this.imAddresses,
                'name': this.name,
                'nickName': this.nickName,
                'note': this.note,
                'organization': this.organization,
                'phoneNumbers': this.phoneNumbers,
                'postalAddresses': this.postalAddresses,
                'relations': this.relations,
                'show': false,
                'websites': this.websites,
                'groups': this.groups
            }
        }
        // Group return value Splicing page display value
        if (!this.contactForm.groups || this.contactForm.groups.length == 0) {
            this.contactForm.groups = this.groups;
        }
        if (this.contactForm.groups.length > 0) {
            if (this.contactForm.groups.length == 1) {
                temp = this.groups[0].title;
            } else {
                this.contactForm.groups.forEach(group => {
                    temp = temp + ',' + group.title
                })
                temp = temp.substring(1, temp.length - 1);
            }
            this.groupContext = temp;
        }
        // Update page initialization
        if (this.updataShow && !this.groupStatus) {
            if (this.saveContact) {
                var requestData = {
                    contactId: this.contactId
                };
                var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
                contactDetailReq.getContactById(DAHelper, requestData, result => {
                    LOG.info(TAG + 'onInit' + 'getContactById .....');
                    this.initUpdateData(result.data)
                    this.contactForm = result.data;
                    if (this.contactForm.phoneNumbers.length == 1 && this.contactForm.phoneNumbers[0].phoneNumber == '') {
                        this.contactForm.phoneNumbers = [];
                    }
                    this.contactForm.phoneNumbers.push({
                        'labelId': 2,
                        'labelName': this.$t('accountants.phone'),
                        'phoneNumber': this.phoneNumber,
                        'phoneAddress': 'N',
                        'showP': false,
                        'blueStyle': true
                    })
                });
            }
            this.initUpdateData(this.contactForm);
            // The number type on the page automatically removes the space for the phone number, resulting in inconsistent data
            if (this.contactForm.phoneNumbers) {
                this.contactForm.phoneNumbers.forEach(element => {
                    element.phoneNumber = element.phoneNumber.replace(/\s+/g, '');
                });
            }
            this.oldParam = this.copy(this.contactForm);
            if (this.contactForm.name.fullName == undefined) {
                this.contactForm.name.fullName = '';
            }
            if (this.contactForm.name.alphaName == '') {
                this.contactForm.name.fullName = '';
            }
            if (this.contactForm.organization.title == undefined) {
                this.contactForm.organization.title = ''
            }
            // The number type on the page automatically removes the space for the phone number, resulting in inconsistent data
            if (this.contactForm.phoneNumbers) {
                this.contactForm.phoneNumbers.forEach(element => {
                    element.phoneNumber = element.phoneNumber.replace(/\s+/g, '');
                });
            }
            this.oldParam = this.copy(this.contactForm);
        }

        if (this.carteFlag) {
            this.isEmpty = false;
            this.contactForm = {
                'emails': this.emails,
                'events': this.events,
                'favorite': false,
                'imAddresses': this.imAddresses,
                'name': this.name,
                'nickName': this.nickName,
                'note': this.note,
                'organization': this.organization,
                'phoneNumbers': this.phoneNumbers,
                'postalAddresses': this.postalAddresses,
                'relations': this.relations,
                'show': false,
                'websites': this.websites
            }
        }

        this.flexInputStyle = 'const-fisrt';
        this.flexImageStyle = 'const-image-div';
        this.flexImageSize = 'fisrt-image';
        this.flexInputSize = 'font-color-first';
        this.flexInputFont = 'font-color-note';
        this.flexCenterSize = 'text-note';
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    onShow() {
        LOG.info(TAG + 'onShow......');
        this.initGroupData();
        if (this.groups.length > 0) {
            var temp = '';
            if (this.groups.length == 1) {
                temp = this.groups[0].title;
            } else {
                this.groups.forEach(group => {
                    temp = temp + ',' + group.title
                })
                temp = temp.substring(1, temp.length - 1);
            }
            this.groupContext = temp;
            this.isEmpty = false;
        }
    },

    initGroupData() {
        if (this.$app.$def.globalData.pushToGroup && this.$app.$def.globalData.groupParams) {
            let params = this.$app.$def.globalData.groupParams;
            this.contactId = params.contactId;
            this.contactForm = params.contactForm;
            this.addShow = params.addShow;
            this.updataShow = params.updataShow;
            this.screenDirection = params.screenDirection;
            this.MoreDivStatus = params.MoreDivStatus;
            this.LetterShow = params.LetterShow;
            this.upMessShow = params.upMessShow;
            this.upRingShow = params.upRingShow;
            this.upHouseShow = params.upHouseShow;
            this.upNickShow = params.upNickShow;
            this.upWebShow = params.upWebShow;
            this.upBirthShow = params.upBirthShow;
            this.upAssShow = params.upAssShow;
            this.groups = params.groups;
            this.groupStatus = params.groupStatus;
            this.$app.$def.globalData.pushToGroup = false;
        }
    },

    /**
     * Update page data during initialization
     *
     * @param {Object} contact Contact data
     */
    initUpdateData(contact) {
        if (!contact.emails || contact.emails.length == 0) {
            contact.emails = this.emails;
        }
        if (!contact.events || contact.events.length == 0) {
            contact.events = this.events;
        } else {
            if (contact.events[0].eventDate != this.events[0].eventDate) {
                this.birthShow = true;
            }
            this.dealBirthTypes(contact.events, contact);
        }
        if (!contact.imAddresses || contact.imAddresses.length == 0) {
            contact.imAddresses = this.imAddresses;
        }
        if (!contact.phoneNumbers || contact.phoneNumbers.length == 0) {
            contact.phoneNumbers = this.phoneNumbers;
        }
        if (!contact.postalAddresses || contact.postalAddresses.length == 0) {
            contact.postalAddresses = this.postalAddresses;
        }
        if (!contact.relations || contact.relations.length == 0) {
            contact.relations = this.relations;
        }
        if (!contact.websites || contact.websites.length == 0) {
            contact.websites = this.websites;
        }
        if (!contact.name) {
            contact.name = this.name;
        }

        this.initUpdateDatas(contact);
    },
    initUpdateDatas(contact) {
        if (!contact.nickName) {
            contact.nickName = this.nickName;
        }
        if (!contact.note) {
            contact.note = this.note;
        }
        if (!contact.organization) {
            contact.organization = this.organization;
        }

        // Group return value Splicing page display value
        if (!contact.groups || contact.groups.length == 0) {
            contact.groups = this.groups;
        }
        if (contact.groups.length > 0) {
            var temp = '';
            if (contact.groups.length == 1) {
                temp = contact.groups[0].title;
            } else {
                contact.groups.forEach(group => {
                    temp = temp + ',' + group.title
                })

                temp = temp.substring(1, temp.length - 1);
            }
            this.groupContext = temp;
            this.groups = contact.groups;
        }
    },

    onBackPress() {
        if (this.isEmpty) {
            return false;
        }
        this.$element('reset').show();
        return true;
    },

    back() {
        if (!this.isEmpty) {
            this.$element('reset').show();
        } else if (this.updataShow) {
            if (this.updateCard || this.carteFlag) {
                this.getCardDetail(21001);
            } else {
                router.replace({
                    uri: 'pages/contacts/contactDetail/contactDetail',
                    params: {
                        isNewSource: true,
                        contactId: this.contactForm.contactId,
                    }
                })
            }
        } else {
            router.back({
                path: 'pages/navigation/navigation'
            })
        }
    },

    takePhotos: function () {
        router.push({
            uri: 'pages/contacts/accountants/takephone/takephone',
            params: {}
        });
    },

    /**
     * Process edit page dates
     *
     * @param {Object} events
     * @param {Object} contact Contact data
     */
    dealBirthTypes(events, contact) {
        var flagF = false;
        var flagS = false;
        var indexF = 0;
        var indexS = 0;
        for (let index = 0; index < events.length; index++) {
            const element = events[index];
            var dexF = 0;
            if (element.labelId == '3') {
                indexF = index;
                var dexF = this.types.indexOf('3');
                this.types.splice(index, 1);
                this.showF = false;
                flagF = true;
            }
            var dexS = 0;
            if (element.labelId == '2') {
                indexS = index;
                dexS = this.types.indexOf('2');
                this.types.splice(dexS, 1);
                this.showS = false;
                flagS = true;
            }
            if (flagS) {
                if (flagF) {
                    contact.events[indexF].showS = false;
                    contact.events[indexS].showF = false;
                }
            }
        }
    },

    onDestroy() {
        LOG.info(TAG + 'onDestroy' + 'execute accountants onDestroy.');
        this.$app.$def.groups.group = ''
    },

    anSave() {
        this.$app.$def.setRefreshContacts(false);
        if (this.saveContact) {
            this.$app.$def.dialerStateData.isEditNumber = false;
            this.$app.$def.globalData.navigationType = 0;
            this.$app.$def.globalData.menuType = 0;
            router.back({
                path: 'pages/navigation/navigation'
            });
        } else {
            router.back();
        }
    },

    childClicked() {
        this.showWork = true;
    },

    showDialog(e) {
        this.DialogStatus = true;
        this.$element('simpledialog').show()
    },

    cancelSchedule(e) {

        if (this.labType == '1') {
            this.contactForm.phoneNumbers[this.labId].labelId = this.oldCustomizeLabelId;
        }
        if (this.labType == '2') {
            this.contactForm.emails[this.labId].labelId = this.oldCustomizeLabelId;
        }
        if (this.labType == '3') {
            this.contactForm.imAddresses[this.labId].labelId = this.oldCustomizeLabelId;
        }
        if (this.labType == '4') {
            this.contactForm.postalAddresses[this.labId].labelId = this.oldCustomizeLabelId;
        }
        if (this.labType == '5') {
            this.contactForm.relations[this.labId].labelId = this.oldCustomizeLabelId;
        }
        this.$element('simpledialog').close()
    },

    setSchedule(id) {
        this.$element('simpledialog').close();

        if (this.labType == '1' && this.customizeInputValue) {
            this.contactForm.phoneNumbers[this.labId].labelId = '0';
            this.contactForm.phoneNumbers[this.labId].labelName = this.customizeInputValue;
        }

        // email
        if (this.labType == '2' && this.customizeInputValue) {
            this.contactForm.emails[this.labId].labelId = '0';
            this.contactForm.emails[this.labId].labelName = this.customizeInputValue;
        }

        // Instant messaging
        if (this.labType == '3' && this.customizeInputValue) {
            this.contactForm.imAddresses[this.labId].labelId = '0';
            this.contactForm.imAddresses[this.labId].labelName = this.customizeInputValue;
        }

        // Custom residential address
        if (this.labType == '4' && this.customizeInputValue) {
            this.contactForm.postalAddresses[this.labId].labelId = '0';
            this.contactForm.postalAddresses[this.labId].labelName = this.customizeInputValue;
        }

        // User-defined association person
        if (this.labType == '5' && this.customizeInputValue) {
            this.contactForm.relations[this.labId].labelId = '0';
            this.contactForm.relations[this.labId].labelName = this.customizeInputValue;
        }
    },

    /**
     * Custom labels
     *
     * @param {Object} e
     */
    getLabel(e) {
        if (e.value) {
            this.DialogStatus = false;
            this.customizeInputValue = e.value;
        } else {
            this.DialogStatus = true;
        }
    },

    /**
     * Get name
     *
     * @param {Object} e
     */
    getName(e) {
        this.contactForm.name.fullName = e.value;
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj)
    },

    /**
     * Obtain only letters ^[a-za-z]+$
     *
     * @param {Object} e
     */
    getLetter(e) {
        var temp = '';
        if (this.langStatus && !this.usStatus) {
            this.contactForm.name.familyNamePhonetic = e.value;
            temp = e.value;
        }
        if (this.usStatus) {
            this.contactForm.name.familyName = e.value;
            this.familyName = e.value;
            temp = this.familyName.concat(this.givenName).concat(this.middleName);
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': temp,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Gets the middle name of the name
     *
     * @param {Object} e
     */
    getMiddleName(e) {
        this.contactForm.name.middleName = e.value;
        this.middleName = e.value;
        var temp = this.middleName.concat(this.givenName).concat(this.familyName);
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': temp,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * First name of first name
     *
     * @param {Object} e
     */
    getGivenName(e) {
        this.contactForm.name.givenName = e.value;
        this.givenName = e.value;
        var temp = this.familyName.concat(this.givenName).concat(this.middleName);
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': temp,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    // FamilyName - familyName, middleName- middleName, givenName- first name
    showEnDiv() {
        if (!this.langStatus) {
            this.letter = this.$t('accountants.surname');
            this.familyNamePhonetic = this.contactForm.name.familyName;
            this.usStatus = true;
        }
    },

    /**
     * The company
     *
     * @param {Object} e
     */
    getComp(e) {
        this.contactForm.organization.name = e.value;
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * position
     *
     * @param {Object} e
     */
    getWork(e) {
        this.contactForm.organization.title = e.value;
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * The phone type
     *
     * @param {string} labType
     * @param {number} id labelId
     * @param {Object} e
     */
    selectChange(labType, id, e) {
        this.labType = labType;
        var customizeLabelId = '99';
        this.labId = id;
        if (e.newValue == customizeLabelId) {
            if (labType == '1') {
                this.contactForm.phoneNumbers[this.labId].labelId = customizeLabelId;
            }
            if (labType == '2') {
                this.contactForm.emails[this.labId].labelId = customizeLabelId;
            }
            if (labType == '3') {
                this.contactForm.imAddresses[this.labId].labelId = customizeLabelId;
            }
            if (labType == '4') {
                this.contactForm.postalAddresses[this.labId].labelId = customizeLabelId;
            }
            if (labType == '5') {
                this.contactForm.relations[this.labId].labelId = customizeLabelId;
            }
            this.showDialog();
        } else {
            if (labType == '1') {
                this.contactForm.phoneNumbers[this.labId].labelId = e.newValue;
            }
            if (labType == '2') {
                this.contactForm.emails[this.labId].labelId = e.newValue;
            }
            if (labType == '3') {
                this.contactForm.imAddresses[this.labId].labelId = e.newValue;
            }
            if (labType == '4') {
                this.contactForm.postalAddresses[this.labId].labelId = e.newValue;
            }
            if (labType == '5') {
                this.contactForm.relations[this.labId].labelId = e.newValue;
            }
            this.oldCustomizeLabelId = e.newValue;
        }
    },

    /**
     * The phone number
     *
     * @param {number} id
     * @param {Object} e
     */
    getPhone: function (id, e) {
        if (e.value) {
            this.phonShow = true;
            this.contactForm.phoneNumbers[id].phoneNumber = e.value;
            this.contactForm.phoneNumbers[id].showP = true;
            if (!this.isInitFirst && this.contactForm.phoneNumbers[id].blueStyle && !this.saveContact) {
                this.contactForm.phoneNumbers[id].blueStyle = false;
            }
            this.isInitFirst = false;
            this.isEmpty = false;
        } else {
            this.contactForm.phoneNumbers[id].showP = false;
            this.contactForm.phoneNumbers[id].phoneNumber = '';
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': e.value,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Reenter the phone
     *
     * @param {number} id
     */
    cleanNum(id) {
        let phones = JSON.parse(JSON.stringify(this.contactForm.phoneNumbers));
        if (this.contactForm.phoneNumbers.length > 1) {
            phones.splice(id, 1);
            this.contactForm.phoneNumbers = [];
            setTimeout(() => {
                this.contactForm.phoneNumbers = phones;
            }, 0);
        } else {
            this.contactForm.phoneNumbers[id].showP = false;
            this.contactForm.phoneNumbers[id].phoneNumber = '';
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        setTimeout(() => {
            this.ListenParam(obj);
        }, 0);
    },

    addNumber: function () {
        var i = this.contactForm.phoneNumbers.length;
        this.contactForm.phoneNumbers.push({
            id: i + 1,
            labelId: '2',
            phoneNumber: '',
            showP: true,
        });
    },

    getMore: function () {
        var l = this.bigsize + 600;
        this.bigsize = l;
        this.divSize = l + 'px';
        this.MoreDivStatus = false;
        this.LetterShow = true;
        this.upMessShow = true;
        this.upRingShow = true;
        this.upHouseShow = true;
        this.upNickShow = true;
        this.upWebShow = true;
        this.upBirthShow = true;
        this.upAssShow = true;
    },

    /**
     * Access to email
     *
     * @param {number} id
     * @param {Object} e
     */
    getEmail: function (id, e) {
        this.contactForm.emails[id].email = '';
        if (e.value) {
            this.isEmpty = false;
            this.emailShow = true;
            this.contactForm.emails[id].email = e.value;
            this.contactForm.emails[id].showP = true;
        } else {
            this.contactForm.emails[id].showP = false;
            this.contactForm.emails[id].email = '';
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': e.value,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Clear current Email
     *
     * @param {number} id
     */
    cleanEmail(id) {
        if (this.contactForm.emails.length > 1) {
            this.contactForm.emails.splice(id, 1);
        } else {
            var param = {
                value: ''
            };
            this.contactForm.emails[id].showP = false;
            this.contactForm.emails[id].email = '';
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    addEmail: function () {
        var i = this.contactForm.emails.length;
        this.contactForm.emails.push({
            id: i + 1,
            labelId: '1',
            email: '',
            showP: false,
        })
    },

    /**
     * Get note
     *
     * @param {Object} e
     */
    getNote(e) {
        this.contactForm.note.noteContent = e.value;
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Clear message
     *
     * @param id
     */
    cleanMessage(id) {
        if (this.contactForm.imAddresses.length > 1) {
            this.contactForm.imAddresses.splice(id, 1);
        } else {
            this.contactForm.imAddresses[id].imAddress = '';
            this.contactForm.imAddresses[id].showP = false;
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Get IMA timely messages
     *
     * @param {number} id
     * @param {Object} e
     */
    getMessage: function (id, e) {
        if (e.value) {
            this.isEmpty = false;
            this.messShow = true;
            this.contactForm.imAddresses[id].imAddress = e.value;
            this.contactForm.imAddresses[id].showP = true;
        } else {
            this.contactForm.imAddresses[id].showP = false;
            this.contactForm.imAddresses[id].imAddress = '';
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': e.value,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    addMess: function () {
        var i = this.contactForm.imAddresses.length;
        this.contactForm.imAddresses.push({
            id: i + 1,
            labelId: '1',
            imAddress: '',
            showP: false,
        })
    },

    /**
     * To get the bell
     *
     * @param {Object} e
     */
    getRing(e) {
        this.ringText = e.value;
        if (this.ringText.length > 0) {
            this.isEmpty = false;
        }
    },

    /**
     * Obtain residential Address
     *
     * @param {number} id
     * @param {Object} e
     */
    getHouText: function (id, e) {
        if (e.value.length > 0) {
            this.isEmpty = false;
            this.houseShow = true;
            this.contactForm.postalAddresses[id].postalAddress = e.value;
            this.contactForm.postalAddresses[id].showP = true;
        } else {
            this.contactForm.postalAddresses[id].showP = false;
            this.contactForm.postalAddresses[id].postalAddress = '';
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': e.value,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Access to email
     *
     * @param {number} id
     */
    cleanHouse(id) {
        if (this.contactForm.postalAddresses.length > 1) {
            this.contactForm.postalAddresses.splice(id, 1);
        } else {
            this.contactForm.postalAddresses[id].postalAddress = '';
            this.contactForm.postalAddresses[id].showP = false;
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    addHouse() {
        var i = this.contactForm.postalAddresses.length;
        this.contactForm.postalAddresses.push({
            id: i + 1,
            labelId: '1',
            postalAddress: '',
            showP: false,
        })
    },

    /**
     * To obtain a nickname
     *
     * @param {Object} e
     */
    getNick(e) {
        this.contactForm.nickName.nickName = e.value;
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Access to the website
     *
     * @param {number} id
     * @param {Object} e
     */
    getWebsite(id, e) {
        if (e.value) {
            this.contactForm.websites[id].website = e.value;
            this.contactForm.websites[id].showP = true;
            this.websiteShow = true;
        } else {
            this.contactForm.websites[id].website = '';
            this.contactForm.websites[id].showP = false;
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': e.value,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Clear current URL
     *
     * @param {number} id
     */
    cleanWebsite(id) {
        if (this.contactForm.websites.length > 1) {
            this.contactForm.websites.splice(id, 1);
        } else {
            this.contactForm.websites[id].showP = false;
            this.contactForm.websites[id].website = '';
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    addWebsite() {
        var i = this.contactForm.events.length;
        this.contactForm.websites.push({
            id: i + 1,
            website: '',
            showP: false
        })
    },

    /**
     * Get date type
     *
     * @param {number} id
     * @param {Object} e
     */
    getBirType(id, e) {
        this.contactForm.events[id].labelId = e.newValue;
        if (this.contactForm.events[id].eventDate != this.$t('accountants.date')) {
            if (this.contactForm.events[id].labelId == '3') {
                for (var index = 0; index < this.contactForm.events.length; index++) {
                    this.contactForm.events[index].showF = false;
                }
                this.contactForm.events[id].showF = true;
            }

            if (this.contactForm.events[id].labelId == '2') {
                for (var index = 0; index < this.contactForm.events.length; index++) {
                    this.contactForm.events[index].showS = false;
                }
                this.contactForm.events[id].showS = true;
            }
        }
    },

    /**
     * For birthday
     *
     * @param {number} id
     * @param {Object} e
     */
    getBirthText(id, e) {
        var year = e.year;
        this.year = year;
        var month = e.month + 1;
        var day = e.day
        var birthText = year + '-' + month + '-' + day;
        if (birthText.length > 0) {
            this.birthShow = true;
            this.isEmpty = false;
            this.contactForm.events[id].showP = true;
            this.contactForm.events[id].eventDate = birthText;
        }
        for (var index = 0; index < this.contactForm.events.length; index++) {
            if (this.contactForm.events[index].eventDate == this.$t('accountants.date')) {
                this.contactForm.events.splice(index, 1);
            }
        }
        for (var index = 0; index < this.contactForm.events.length; index++) {
            if (this.contactForm.events[index].eventDate != this.$t('accountants.date')) {
                if (this.contactForm.events[index].labelId == '3') {
                    this.contactForm.events[index].showF = true;
                    this.showF = false;
                } else {
                    this.contactForm.events[index].showF = false;
                }
                if (this.contactForm.events[index].labelId == '2') {
                    this.contactForm.events[index].showS = true;
                    this.showS = false;
                } else {
                    this.contactForm.events[index].showS = false;
                }
            }
        }
        for (var index = 0; index < this.contactForm.events.length; index++) {
            if (this.contactForm.events[index].eventDate == this.$t('accountants.date')) {
                this.contactForm.events.splice(index, 1);
            }
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': birthText,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    addBirth: function () {
        var id = this.contactForm.events.length;
        id = id + 1;
        this.contactForm.events.push({
            id: id,
            labelId: 4,
            eventDate: this.$t('accountants.date'),
            showF: this.showF,
            showS: this.showS,
            showP: false
        })
    },

    /**
     * Clears the current birthday date
     *
     * @param {number} id
     */
    cleanBirth(id) {
        if (this.contactForm.events.length > 1) {
            if (this.contactForm.events[id].labelId == '3') {
                this.contactForm.events.splice(id, 1);
                for (var index = 0; index < this.contactForm.events.length; index++) {
                    this.contactForm.events[index].showF = true;
                    this.showF = true;
                }
            } else if (this.contactForm.events[id].labelId == '2') {
                this.contactForm.events.splice(id, 1);
                for (var index = 0; index < this.contactForm.events.length; index++) {
                    this.contactForm.events[index].showS = true;
                    this.showS = true;
                }
            } else {
                this.contactForm.events.splice(id, 1);
            }

        } else {
            this.contactForm.events[id].showP = false;
            this.contactForm.events[id].eventDate = this.$t('accountants.date');
        }

        this.year = '';
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Get more relationships
     *
     * @param {number} id
     * @param {Object} e
     */
    getAssText(id, e) {
        if (e.value.length > 0) {
            this.isEmpty = false;
            this.assisShow = true;
            this.contactForm.relations[id].relationName = e.value;
            this.contactForm.relations[id].showP = true;
        } else {
            this.contactForm.relations[id].showP = false;
            this.contactForm.relations[id].relationName = '';
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    /**
     * Clear current relationship
     *
     * @param {number} id
     */
    cleanAss(id) {
        if (this.contactForm.relations.length > 1) {
            this.contactForm.relations.splice(id, 1);
        } else {
            this.contactForm.relations[id].relationName = '';
            this.contactForm.relations[id].showP = false;
        }
        let obj = {
            'name': this.contactForm.name.fullName,
            'Pname': this.contactForm.name.familyNamePhonetic,
            'company': this.contactForm.organization.name,
            'position': this.contactForm.organization.title,
            'phone': this.contactForm.phoneNumbers[0].phoneNumber,
            'email': this.contactForm.emails[0].email,
            'note': this.contactForm.note.noteContent,
            'mess': this.contactForm.imAddresses[0].imAddress,
            'address': this.contactForm.postalAddresses[0].postalAddress,
            'nick': this.contactForm.nickName.nickName,
            'website': this.contactForm.websites[0].website,
            'birth': this.year,
            'assistant': this.contactForm.relations[0].relationName,
            'groupContext': this.groupContext
        }
        this.ListenParam(obj);
    },

    addAss() {
        var id = this.contactForm.relations.length;
        id = id + 1;
        this.contactForm.relations.push({
            id: id,
            labelId: '1',
            relationName: '',
            showP: false,
        })
    },

    // Jumping to a Group
    onGroup() {
        this.$app.$def.globalData.pushToGroup = true;
        router.push({
            uri: 'pages/contacts/groups/deleteGroup/deleteGroup',
            params: {
                addContactStatus: true,
                addShow: this.addShow,
                updataShow: this.updataShow,
                contactForm: this.contactForm,
                contactId: this.contactId,
                editGroup: true,
                MoreDivStatus: this.MoreDivStatus,
                LetterShow: this.LetterShow,
                upMessShow: this.upMessShow,
                upRingShow: this.upRingShow,
                upHouseShow: this.upHouseShow,
                upNickShow: this.upNickShow,
                upWebShow: this.upWebShow,
                upBirthShow: this.upBirthShow,
                upAssShow: this.upAssShow,
                groups: this.groups
            },
        });
    },

    /**
     * Deep copy obJ objects
     *
     * @param {Object} obj Contact's contactForm
     * @return
     */
    copy(obj) {
        return JSON.parse(JSON.stringify(obj));
    },

    /**
     * Monitor whether the data on the edit page has changed
     *
     * @param {Array} existData
     * @param {Array} newData
     * @param {string} type = 'Object' Define the type as 'Object'
     * @return {Boolean}
     */
    isSameData(existData, newData, type = 'Object') {
        if (type == 'Array') {
            if (Object.prototype.toString.call(existData) != '[object Array]' || Object.prototype.toString.call(newData) != '[object Array]') {
                throw new Error('At least one of the inputs not an array');
            }

            if (existData.length != newData.length) {
                return false;
            }
        } else if (!(existData instanceof Object && newData instanceof Object)) {
            throw new Error('At least one of the inputs not an Object');
        } else {
            LOG.info(TAG + 'isSameData' + 'type error.');
        }
        for (const key in existData) {
            if (Object.prototype.hasOwnProperty.call(newData, key)) {
                if (existData[key] instanceof Array && newData[key] instanceof Array) {
                    try {
                        if (!this.isSameData(existData[key], newData[key], 'Array')) {
                            return false;
                        }
                    } catch {
                        return false;
                    }
                } else if (existData[key] instanceof Object && newData[key] instanceof Object) {
                    try {
                        if (!this.isSameData(existData[key], newData[key], 'Object')) {
                            return false;
                        }
                    } catch {
                        return false;
                    }
                } else if (existData[key] != newData[key]) {
                    return false;
                }
            } else {
                return false;
            }
        }
        return true;
    },

    /**
     * Listen for all input parameters
     *
     * @param {string} name
     * @param {string} Pname
     * @param {string} company
     * @param {string} position
     * @param {string} phone
     * @param {string} email
     * @param {string} note
     * @param {string} mess
     * @param {string} address
     * @param {string} nick
     * @param {string} website
     * @param {string} birth
     * @param {string} assistant
     * @param {string} groupContext
     */


    ListenParam(obj) {
        obj.name = obj.name.trim();
        obj.Pname = obj.Pname.trim();
        obj.company = obj.company.trim();
        obj.position = obj.position.trim();
        obj.phone = obj.phone.trim();
        obj.email = obj.email.trim();
        obj.note = obj.note.trim();
        obj.mess = obj.mess.trim();
        obj.address = obj.address.trim();
        obj.nick = obj.nick.trim();
        obj.website = obj.website.trim();
        obj.address = obj.address.trim();
        obj.birth = obj.birth.trim();
        obj.assistant = obj.assistant.trim();
        obj.groupContext = obj.groupContext.trim();
        if (this.updataShow && !(JSON.stringify(this.oldParam) == '{}')) {
            if (this.isSameData(this.oldParam, this.contactForm, 'Object')) {
                this.isEmpty = true;
                return;
            } else {
                this.isEmpty = false;
            }
        }
        obj.birth = this.contactForm.events[0].eventDate;
        if (obj.birth == this.$t('accountants.date')) {
            obj.birth = '';
        }
        if (this.updateCard) {
            this.isEmpty = false;
        }
        if (obj.name || obj.Pname || obj.company || obj.position || obj.phone || obj.email || obj.note || obj.mess ||
        obj.address || obj.nick || obj.website || obj.birth || obj.assistant || obj.groupContext) {
            this.isEmpty = false;
            this.delCard = false;
        } else if (this.updateCard) {
            this.isEmpty = false;
            this.delCard = true;
        } else {
            this.isEmpty = true;
        }
    },


    deleteCard() {
        LOG.info(TAG + 'deleteCard' + 'del contactForm' + this.contactForm);
        var delParams = {};
        delParams.contactId = this.contactForm.contactId;
    },


    addAccountants() {
        LOG.info(TAG + 'addAccountants' + 'logMessage addAccountants is start');

        if (this.updateCard && this.delCard) {
            this.deleteCard();
            return;
        }
        var addParams = this.copy(this.contactForm);
        this.listFieldIsNull(addParams.phoneNumbers);
        this.listFieldIsNull(addParams.imAddresses);
        this.listFieldIsNull(addParams.emails);
        this.listFieldIsNull(addParams.postalAddresses);
        this.listFieldIsNull(addParams.relations);
        this.listFieldIsNull(addParams.events);
        this.listFieldIsNull(addParams.websites);
        var that = this;
        if (this.carteFlag) {
            this.addCard(addParams);
        } else if (this.updateCard) {
            this.editCard(addParams);
        } else {
                that.addShow ? that.$app.$def.setAddAccount(true) : that.$app.$def.setEditContacts(true);
                if (this.addShow) {
                    this.isaddContact(addParams);
                } else {
                    this.updateContact(addParams);
                }
        }
    },
    addCard(addParams) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactReq.addMyCard(DAHelper, addParams, (contactId) => {
            setTimeout(() => {
                this.goToMyCard(contactId);
            }, 500);
        });
    },
    editCard(addParams) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactReq.updateMyCard(DAHelper, addParams, (contactId) => {
            setTimeout(() => {
                this.goToMyCard(contactId);
            }, 500);
        });
    },
    updateContact(addParams) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactReq.updateContact(DAHelper, addParams, (contactId) => {
            LOG.info(TAG + 'addAccountants' + 'logMessage addContact callBack success! contactId = ' + ', route = ' + router);
            router.replace({
                uri: 'pages/contacts/contactDetail/contactDetail',
                params: {
                    isNewSource: true,
                    contactId: contactId,
                }
            });
        });
    },
    addContacts(addParams) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactReq.addContact(DAHelper, addParams, (contactId) => {
            LOG.info(TAG + 'addAccountants' + 'logMessage addContact callBack success! contactId = ' + ', route = ' + router);
            router.replace({
                uri: 'pages/contacts/contactDetail/contactDetail',
                params: {
                    isNewSource: true,
                    contactId: contactId,
                }
            });
        });
    },
    isaddContact(addParams) {
        let emails = addParams.emails == '' ? false : true;
        let events = addParams.events == '' ? false : true;
        let imAddresses = addParams.imAddresses == '' ? false : true;
        let fullName = addParams.name.fullName == '' ? false : true;
        let givenName = addParams.name.givenName == '' ? false : true;
        let familyName = addParams.name.familyName == '' ? false : true;
        let middleName = addParams.name.middleName == '' ? false : true;
        let familyNamePhonetic = addParams.name.familyNamePhonetic == '' ? false : true;
        let nickName = addParams.nickName.nickName == '' ? false : true;
        let note = addParams.note.noteContent == '' ? false : true;
        let organizationName = addParams.organization.name == '' ? false : true;
        let organizationTitle = addParams.organization.title == '' ? false : true;
        let phoneNumbers = addParams.phoneNumbers == '' ? false : true;
        let postalAddresses = addParams.postalAddresses == '' ? false : true;
        let relations = addParams.relations == '' ? false : true;
        let websites = addParams.phoneNumbers == '' ? false : true;
        let groups = addParams.groups == '' ? false : true;

        if (!(emails || events || imAddresses || fullName || givenName || familyName || middleName || familyNamePhonetic ||
        nickName || note || organizationName || organizationTitle || phoneNumbers || postalAddresses || relations || websites) && groups) {
            Prompt.showToast({
                message: this.$t('value.contacts.noInfo'),
                duration: 2000,
                bottom: '150px'
            });
            router.back();
        } else {
            this.addContacts(addParams);
        }
    },

    /**
     * Delete empty data and remove the labelName field
     * 
     * @param {Array} field Data of a contact
     */
    listFieldIsNull: function (field) {
        if (field && field.length > 0) {
            for (var index = field.length - 1;index >= 0; index--) {
                if (!field[index].showP) {
                    field.splice(index, 1);
                }
                if (field[index] && field[index].labelId != '0') {
                    delete field[index].labelName;
                }
            }
        }
    },

    /**
     * Jump to my business card
     * 
     * @param {number} contactId The contact ID
     */
    goToMyCard(contactId) {
        LOG.info(TAG + 'goToMyCard' + 'logMessage goToMyCard start!');
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactReq.getCardDetails(DAHelper, contactId, (result) => {
            var contactForm = result.data;
            LOG.info(TAG + 'goToMyCard' + 'logMessage get card details success!');
            router.replace({
                uri: 'pages/contacts/card/card',
                params: {
                    contactForm: contactForm
                }
            });
        });
    }
}