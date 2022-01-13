/**
 * @file: Contact Details
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

import contactDetailReq  from '../../../../default/model/ContactDetailModel.js';
import contactsService from '../../../../default/model/ContactModel.js';
import callLogService from '../../../../default/model/CalllogModel.js';
import favoritesModel from '../../../../default/model/FavoritesModel.js';
import router from '@system.router';
import prompt from '@system.prompt';
import Utils from '../../../../default/utils/utils.js';
import LOG from '../../../utils/ContactsLog.js';
import Constants from '../../../../default/common/constants/Constants.js';
import backgroundColor from '../../../common/constants/color.js';

var TAG = 'contactDetail...:';

const DELETE_CONTACT = 2003;
const GET_CONTACT_DETAIL = 2005;

// 1 indicates a collected contact. 0 indicates a non-collected contact
const IS_FAVORITE = 1;
const IS_NOT_FAVORITE = 0;
const ACTION_SYNC = 0;
const SET_DEFAULT = 1;
const CLEAR_DEFAULT = 0;

export default {
    data: {
        icPhoneCallMBlock: '/res/image/ic_phonecall_m_block.svg',
        icVideoM: '/res/image/ic_video_m.svg',
        icMassageM: '/res/image/ic_massage_m.svg',
        icContactsCallOut: '/res/image/ic_contacts_callout_mini.svg',
        icContactsCallIn: '/res/image/ic_contacts_call_in_mini.svg',
        icContactsCallMissed: '/res/image/ic_contacts_call_missed_mini.svg',
        icContactsCallRejected: '/res/image/ic_contacts_call_rejected_mini.svg',
        showHeaderFlag: true,
        pYStart: 0,
        pYMove: 0,
        directPoint: 0,
        backgroundColor: backgroundColor.Color,
        backgroundDetailColor: backgroundColor.detailColor,
        directPointTemp: 0,
        touchMoveStartX: 0,
        touchMoveStartY: 0,
        isFavorite: false,
        newNumberContactDetail: {},
        showMenuTimeOutId: '',
        showPhoneNumber: '',
        phoneNumbersLength: 0,
        copyToClipBoardContent: '',
        postalAddressName: '',
        sendNumber: '',
        deleteIndex: '',
        numLongPressIndexIndex: 0,
        globalX: '',
        globalY: '',
        showNameLastMenu: '',
        showNameLast: '',
        qrcodeString: '',
        contactForm: {
            'showLastDividerGroupsP': false,
            'showGroupsP': false,
            'isNewNumber': false,
            'showLastDividerNickNameP': false,
            'showLastDividerNoteP': false,
            'showNickNameP': false,
            'showNoteP': false,
            'showPinYinNameP': false,
            'showLastDividerPinYinNameP': false,
            'showMoreButton': false,
            'phoneNumbers': [],
            'emails': [],
            'imAddresses': [],
            'nickName': '',
            'websites': [],
            'postalAddresses': [],
            'events': [],
            'note': '',
            'relations': [],
            'pinYinName': '',
            'alphaName': '',
            'showGroupsString': '',
            'name': '',
            'emptyNameData': '',
            'namePrefix': '',
            'lastName': '',
            'company': '',
            'position': '',
            'numRecords': [],
            'groups': [],
            'showNewContact': false,
        },
        contacts: {},
        emails: [
            {
                'id': 0,
                'email': '',
                'labelId': 1,
                'labelName': '',
                'showP': false
            }
        ],
        events: [
            {
                'id': 0,
                'eventDate': '',
                'labelId': 3,
                'labelName': '',
                'showP': false,
                'showF': true,
                'showS': true
            }
        ],
        imAddresses: [
            {
                'id': 0,
                'imAddress': '',
                'labelId': 1,
                'labelName': 'AIM',
                'showP': false
            }
        ],
        phoneNumbers: [
            {
                'id': 0,
                'labelId': 2,
                'labelName': '',
                'phoneNumber': '',
                'phoneAddress': 'N',
                'showP': false,
                'blueStyle': false
            }
        ],
        postalAddresses: [
            {
                'id': 0,
                'labelId': 1,
                'labelName': '',
                'postalAddress': '',
                'showP': false
            }
        ],
        relations: [
            {
                'id': 0,
                'labelId': 1,
                'labelName': '',
                'relationName': '',
                'showP': false
            }
        ],
        websites: [
            {
                'id': 0,
                'website': '',
                'showP': false
            }
        ],
        name: {
            'fullName': '',
            'givenName': '',
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
        isNewSource: false,
        containContacts: false,
        showSetDefault: false,
        sourceFromCallRecord: false,
        phoneNumberShow: '',
        contactId: '',
        isNewNumber: false,
    },
    onInit() {
        LOG.info(TAG + ' onInit detail');
    },
    onReady() {
        LOG.info(TAG + ' onReady detail');
    },
    onShow() {
        this.emails[0].labelName = this.$t('accountants.private');
        this.events[0].eventDate = this.$t('accountants.date');
        this.events[0].labelName = this.$t('accountants.birth');
        this.phoneNumbers[0].labelName = this.$t('accountants.phone');
        this.postalAddresses[0].labelName = this.$t('accountants.house');
        this.relations[0].labelName = this.$t('accountants.assistant');
        if (this.isNewSource) {
            let requestData = {
                contactId: this.contactId
            };
            this.getContactDetail(GET_CONTACT_DETAIL, requestData);
        } else if (this.containContacts) {
            this.dealRecordDetailsData();
        } else if (this.sourceFromCallRecord) {
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
            contactDetailReq.getContactIdByNumber(DAHelper, this.phoneNumberShow, (contactId) => {
                if (!Utils.isEmpty(contactId)) {
                    this.isNewNumber = false;
                    let requestData = {
                        contactId: contactId
                    };
                    this.getContactDetail(GET_CONTACT_DETAIL, requestData);
                } else {
                    this.getDetailAsNewNumber();
                }
            });
        }
        LOG.info(TAG + ' onShow detail');
    },

    onHide() {
        LOG.info(TAG + ' onHide detail');
    },

    onDestroy() {
        LOG.info(TAG + ' onDestroy detail');
    },

    getDetailAsNewNumber() {
        var numbers = [this.phoneNumberShow.replace(/\s+/g, '')];
        this.getNewNumRecords(numbers);
    },

    selectFavorite() {
        LOG.info(TAG + 'favorites: onDestroy detail');
        var starred = IS_NOT_FAVORITE;
        if (this.contacts.starred == IS_NOT_FAVORITE) {
            this.contacts.starred = IS_FAVORITE;
            starred = IS_FAVORITE;
        } else {
            this.contacts.starred = IS_NOT_FAVORITE;
            starred = IS_NOT_FAVORITE;
        }
        var timestamp = (new Date()).valueOf();
        var actionData = {
            ids: [this.contacts.contactId],
            favorite: starred,
            isOperationAll: false,
            favorite_order: timestamp
        };
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.updateFavoriteState(DAHelper, actionData, result => {
        });
    },

    clearPhoneRecords() {
        this.$element('clearRecordsDialog').show();
    },

    clearRecords() {
        var id = '';
        var ids = [];
        for (let index = 0; index < this.contactForm.numRecords.length; index++) {
            id = this.contactForm.numRecords[index].id;
            ids.push(id);
        }
        this.contactForm.numRecords = [];
        this.removeCallLog(ids);
        this.$element('clearRecordsDialog').close();
    },

    /**
     * Finger touch begins
     *
     * @param {Object} e
     */
    listItemTouchStart(e) {
        LOG.info(TAG + 'listItemTouchStart e' + e);
        this.globalX = e.touches[0].globalX;
        this.globalY = e.touches[0].globalY;
    },

    /**
     * Single point call records
     *
     * @param {number} index
     */
    callOutRecord(index) {
        LOG.info(TAG + 'callOutRecord index' + index);
        this.callOut(this.contactForm.numRecords[index].phone);
    },

    /**
     * Hold down the call history popup
     *
     * @param {number} index
     */
    listItemOnLongPress: function (index) {
        LOG.info(TAG + 'listItemOnLongPress index' + index);
        this.deleteIndex = index;
        this.sendNumber = this.contactForm.numRecords[index].formatNumber;
        this.$element('itemMenu').show({
            x: this.globalX,
            y: this.globalY
        });
    },

    /**
     * Long press the phone number to pop up
     *
     * @param {number} index
     */
    listItemOnLongPressNumber: function (index) {
        LOG.info(TAG + 'listItemOnLongPressNumber index' + index);
        this.numLongPressIndexIndex = index;
        this.sendNumber = this.contactForm.phoneNumbers[index].phoneNumber;
        this.showSetDefault = (this.contactForm.phoneNumbers[index].isPrimary == 1) ? false : true;
        this.phoneNumbersLength = (this.contactForm.phoneNumbers && this.contactForm.phoneNumbers.length > 0)
            ? this.contactForm.phoneNumbers.length : 0;

        this.showPhoneNumber = (this.contactForm.phoneNumbers && this.contactForm.phoneNumbers[index]
        && this.contactForm.phoneNumbers[index].phoneNumber.length > 0)
            ? (this.contactForm.phoneNumbers[index].phoneNumber.length <= 8
                ? this.contactForm.phoneNumbers[index].phoneNumber
                : this.contactForm.phoneNumbers[index].phoneNumber.substring(0, 7) + '..') : '';

        clearTimeout(this.showMenuTimeOutId);
        this.showMenuTimeOutId = setTimeout(() => {
            this.$element('itemMenuNumber').show({
                x: this.globalX,
                y: this.globalY,
            });
        }, 60);
    },

    /**
     * Hold down the association window
     *
     * @param {string} content
     */
    listItemOnLongPressContent: function (content) {
        LOG.info(TAG + 'listItemOnLongPressContent content' + content);
        this.copyToClipBoardContent = (content && content.length > 7)
            ? this.subStringWithEllipsis(content, 9) : content;

        clearTimeout(this.showMenuTimeOutId);
        this.showMenuTimeOutId = setTimeout(() => {
            this.$element('itemMenuContent').show({
                x: this.globalX,
                y: this.globalY,
            });
        }, 60);
    },

    cancelClearRecordDialog() {
        this.$element('clearRecordsDialog').close();
    },

    updateContact() {
        if (this.contacts.emails) {
            this.addShowPField(this.contacts.emails);
        }
        if (this.contacts.events) {
            this.addShowPField(this.contacts.events);
        }
        if (this.contacts.imAddresses) {
            this.addShowPField(this.contacts.imAddresses);
        }
        if (this.contacts.phoneNumbers) {
            this.addShowPField(this.contactForm.phoneNumbers);
        }
        if (this.contacts.postalAddresses) {
            this.addShowPField(this.contacts.postalAddresses);
        }
        if (this.contacts.relations) {
            this.addShowPField(this.contacts.relations);
        }
        if (this.contacts.websites) {
            this.addShowPField(this.contacts.websites);
        }

        if (!this.contacts.emails || this.contacts.emails.length == 0) {
            this.contacts.emails = this.emails;
        }
        if (!this.contacts.events || this.contacts.events.length == 0) {
            this.contacts.events = this.events;
        }
        if (!this.contacts.imAddresses || this.contacts.imAddresses.length == 0) {
            this.contacts.imAddresses = this.imAddresses;
        }
        if (!this.contacts.phoneNumbers || this.contacts.phoneNumbers.length == 0) {
            this.contacts.phoneNumbers = this.phoneNumbers;
        }

        this.updateContacts();
    },
    updateContacts() {
        if (!this.contacts.postalAddresses || this.contacts.postalAddresses.length === 0) {
            this.contacts.postalAddresses = this.postalAddresses;
        }
        if (!this.contacts.relations || this.contacts.relations.length == 0) {
            this.contacts.relations = this.relations;
        }
        if (!this.contacts.websites || this.contacts.websites.length == 0) {
            this.contacts.websites = this.websites;
        }
        if (!this.contacts.groups || this.contacts.groups.length == 0) {
            this.contacts.groups = this.groups;
        }
        if (!this.contacts.name) {
            this.contacts.name = this.name;
        }
        if (!this.contacts.nickName) {
            this.contacts.nickName = this.nickName;
        }
        if (!this.contacts.note) {
            this.contacts.note = this.note;
        }
        if (!this.contacts.organization) {
            this.contacts.organization = this.organization;
        }

        router.replace({
            uri: 'pages/contacts/accountants/accountants',
            params: {
                addShow: false,
                updataShow: true,
                showWork: true,
                upHouseShow: true,
                contactForm: this.contacts,
                groups: this.contacts.groups,
                upPinShow: true,
            },
        });
    },

    /**
     * Displays the showP attribute for each element in the array
     *
     * @param {Array} array
     */
    addShowPField(array) {
        LOG.info(TAG + 'addShowPField array' + array);
        if (array || array.length > 0) {
            array.forEach((item, index) => {
                item.showP = true;
                delete item.id;
            });
        }
    },

    routerBack() {
        this.$app.$def.setRefreshContacts(false);
        router.back();
    },

    onBackPress() {
        this.$app.$def.setRefreshContacts(false);
        router.back();
    },

    getMore: function () {
        if (Boolean(this.contactForm.showMoreButton) == true) {
            this.contactForm.showMoreButton = false;
        }
        this.dealRecordDetailsData();
    },

    /**
     * Deep copy obJ objects
     *
     * @param {Object} obj
     * @return {Object}
     */
    copy(obj) {
        return JSON.parse(JSON.stringify(obj));
    },

    /**
     * Obtain contact details
     *
     * @param {number} code 2005 FA and PA pass protocol codes
     * @param {number} data contactId The contact ID
     */
    getContactDetail: function (code, data) {
        var actionData = data;
        data.contactId = actionData.contactId;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        contactDetailReq.getContactById(DAHelper, data, result => {
            if (!result) {
                this.getDetailAsNewNumber();
                return;
            }
            this.contacts = result.data;
            LOG.info(TAG + 'getContactDetail is ' + result);
            this.dealRecordDetailsData();
        });
    },

    /**
     * Request background: obtain contact details, and assemble the display data after obtaining call record data
     */
    dealRecordDetailsData: function () {

        this.phoneNumberType();

        this.emailType();

        this.instantMessageType();

        this.residentialType();

        this.birthdayType();

        this.assistantType();

        var newContacts = this.copy(this.contacts);

        var totalCountNumber = 0;
        totalCountNumber = this.isTotalCountNumber(totalCountNumber, newContacts);

        var dataLengthCount = 0;

        newContacts.phoneNumbers = this.setTempPhoneNumbersList(totalCountNumber, dataLengthCount, newContacts);

        newContacts.emails = this.setTempEmailsList(totalCountNumber, dataLengthCount, newContacts);

        newContacts.imAddresses = this.setTempImAddressesList(totalCountNumber, dataLengthCount, newContacts);

        var showNickNameP = false;
        var showLastDividerNickNameP = true;
        if (newContacts.nickName && newContacts.nickName.nickName && newContacts.nickName.nickName.length > 0) {
            showNickNameP = true;
            if (dataLengthCount === totalCountNumber - 1) {
                showLastDividerNickNameP = false;
            } else {
                showLastDividerNickNameP = true;
            }
            dataLengthCount++;
        }

        newContacts.websites = this.setTempWebsitesList(totalCountNumber, dataLengthCount, newContacts);

        newContacts.postalAddresses = this.setTempPostalAddressesList(totalCountNumber, dataLengthCount, newContacts);

        newContacts.events = this.setTempEventsList(totalCountNumber, dataLengthCount, newContacts);

        var showGroupsP = false;
        var showLastDividerGroupsP = true;
        var showGroupsString = '';
        if (newContacts.groups && newContacts.groups.length > 0) {
            newContacts.groups.forEach((element) => {
                showGroupsString = showGroupsString + element.title + ', ';
            });
            showGroupsString = showGroupsString.substr(0, showGroupsString.length - 2);
        }
        if (showGroupsString && showGroupsString.length > 0) {
            showGroupsP = true;
            if (dataLengthCount === totalCountNumber - 1) {
                showLastDividerGroupsP = false;
            } else {
                showLastDividerGroupsP = true;
            }
            dataLengthCount++;
        }

        var showPinYinNameP = false;
        var showLastDividerPinYinNameP = true;
        if (newContacts.name && newContacts.name.familyNamePhonetic && newContacts.name.familyNamePhonetic.length > 0) {
            showPinYinNameP = true;
            if (dataLengthCount === totalCountNumber - 1) {
                showLastDividerPinYinNameP = false;
            } else {
                showLastDividerPinYinNameP = true;
            }
            dataLengthCount++;
        }

        newContacts.relations = this.setTempRelationsList(totalCountNumber, dataLengthCount, newContacts);

        var showNoteP = false;
        var showLastDividerNoteP = true;
        if (newContacts.note && newContacts.note.noteContent && newContacts.note.noteContent.length > 0) {
            showNoteP = true;
            if (dataLengthCount === totalCountNumber - 1) {
                showLastDividerNoteP = false;
            } else {
                showLastDividerNoteP = true;
            }
            dataLengthCount++;
        }

        this.contactForm.showLastDividerNickNameP = showLastDividerNickNameP;
        this.contactForm.showLastDividerNoteP = showLastDividerNoteP;
        this.contactForm.showNickNameP = showNickNameP;
        this.contactForm.showNoteP = showNoteP;
        this.contactForm.showPinYinNameP = showPinYinNameP;
        this.contactForm.showLastDividerPinYinNameP = showLastDividerPinYinNameP;
        this.contactForm.showGroupsP = showGroupsP;
        this.contactForm.showLastDividerGroupsP = showLastDividerGroupsP;
        this.contactForm.isNewNumber = false;
        this.contactForm.showMoreButton = false;
        this.contactForm.emptyNameData = newContacts.emptyNameData;
        var frist = this.contactForm.emptyNameData.substr(0, 1);
        if ((frist >= 'a' && frist <= 'z') || (frist >= 'A' && frist <= 'Z')) {
            this.contactForm.namePrefix = frist.toUpperCase();
        } else {
            this.contactForm.namePrefix = '0';
        }

        this.setContactForm(showGroupsString, newContacts);

        this.processingInitializationData(newContacts);
    },
    phoneNumberType() {
        if (this.contacts.hasOwnProperty('phoneNumbers') && this.contacts.phoneNumbers.length > 0) {
            this.contacts.phoneNumbers.forEach((element) => {
                switch (parseInt(element.labelId, 10)) {
                    case 1:
                        element.labelName = this.$t('accountants.house');
                        break;
                    case 2:
                        element.labelName = this.$t('accountants.phone');
                        break;
                    case 3:
                        element.labelName = this.$t('accountants.unit');
                        break;
                    case 4:
                        element.labelName = this.$t('accountants.unit fax');
                        break;
                    case 5:
                        element.labelName = this.$t('accountants.home fax');
                        break;
                    case 6:
                        element.labelName = this.$t('accountants.pager');
                        break;
                    case 7:
                        element.labelName = this.$t('accountants.others');
                        break;
                    case 12:
                        element.labelName = this.$t('accountants.switchboard');
                        break;
                    default:
                        element.labelName = element.labelName;

                }
            });
        }
    },
    emailType() {
        if (this.contacts.hasOwnProperty('emails') && this.contacts.emails.length > 0) {
            this.contacts.emails.forEach((element) => {
                switch (parseInt(element.labelId, 10)) {
                    case 1:
                        element.labelName = this.$t('accountants.private');
                        break;
                    case 2:
                        element.labelName = this.$t('accountants.unit');
                        break;
                    case 3:
                        element.labelName = this.$t('accountants.others');
                        break;
                    default:
                        element.labelName = element.labelName;
                }
            });
        }
    },
    instantMessageType() {
        if (this.contacts.hasOwnProperty('imAddresses') && this.contacts.imAddresses.length > 0) {
            this.contacts.imAddresses.forEach((element) => {
                switch (parseInt(element.labelId, 10)) {
                    case 1:
                        element.labelName = this.$t('accountants.AIM');
                        break;
                    case 2:
                        element.labelName = this.$t('accountants.Windows Live');
                        break;
                    case 3:
                        element.labelName = this.$t('accountants.Yahoo');
                        break;
                    case 4:
                        element.labelName = this.$t('accountants.Skype');
                        break;
                    case 5:
                        element.labelName = this.$t('accountants.QQ');
                        break;
                    case 6:
                        element.labelName = this.$t('accountants.Hangout');
                        break;
                    case 7:
                        element.labelName = this.$t('accountants.ICQ');
                        break;
                    case 8:
                        element.labelName = this.$t('accountants.Jabber');
                        break;
                    default:
                        element.labelName = element.labelName;
                }
            });
        }
    },
    residentialType() {
        if (this.contacts.hasOwnProperty('postalAddresses') && this.contacts.postalAddresses.length > 0) {
            this.contacts.postalAddresses.forEach((element) => {
                switch (parseInt(element.labelId, 10)) {
                    case 1:
                        element.labelName = this.$t('accountants.house');
                        break;
                    case 2:
                        element.labelName = this.$t('accountants.unit');
                        break;
                    case 3:
                        element.labelName = this.$t('accountants.others');
                        break;
                    default:
                        element.labelName = element.labelName;
                }
            });
        }
    },
    birthdayType() {
        if (this.contacts.hasOwnProperty('events') && this.contacts.events.length > 0) {
            this.contacts.events.forEach((element) => {
                LOG.info(TAG + ' contactDetail  events parseInt(element.labelId) =' + this.$t('accountants.phone'));
                switch (parseInt(element.labelId, 10)) {
                    case 1:
                        element.labelName = this.$t('accountants.Anniversary');
                        break;
                    case 2:
                        element.labelName = this.$t('accountants.Lunar Birthday');
                        break;
                    case 3:
                        element.labelName = this.$t('accountants.birth');
                        break;
                    case 4:
                        element.labelName = this.$t('accountants.import day');
                }
            });
        }
    },
    assistantType() {
        if (this.contacts.hasOwnProperty('relations') && this.contacts.relations.length > 0) {
            this.contacts.relations.forEach((element) => {
                switch (parseInt(element.labelId, 10)) {
                    case 1:
                        element.labelName = this.$t('accountants.assistant');
                        break;
                    case 2:
                        element.labelName = this.$t('accountants.brothers');
                        break;
                    case 3:
                        element.labelName = this.$t('accountants.child');
                        break;
                    case 4:
                        element.labelName = this.$t('accountants.companion');
                        break;
                    case 5:
                        element.labelName = this.$t('accountants.father');
                        break;
                    case 6:
                        element.labelName = this.$t('accountants.friend');
                        break;
                    case 7:
                        element.labelName = this.$t('accountants.boss');
                        break;
                    case 8:
                        element.labelName = this.$t('accountants.mother');
                        break;
                    case 9:
                        element.labelName = this.$t('accountants.parents');
                        break;
                    case 10:
                        element.labelName = this.$t('accountants.Partner');
                        break;
                    case 11:
                        element.labelName = this.$t('accountants.introducer');
                        break;
                    case 12:
                        element.labelName = this.$t('accountants.relatives');
                        break;
                    case 13:
                        element.labelName = this.$t('accountants.sisters');
                        break;
                    case 14:
                        element.labelName = this.$t('accountants.spouse');
                        break;
                    default:
                        element.labelName = element.labelName;

                }
            });
        }
    },
    isTotalCountNumber(totalCountNumber, newContacts) {
        totalCountNumber = (newContacts.phoneNumbers && newContacts.phoneNumbers.length > 0)
            ? totalCountNumber + newContacts.phoneNumbers.length : totalCountNumber;

        totalCountNumber = (newContacts.emails && newContacts.emails.length > 0)
            ? totalCountNumber + newContacts.emails.length : totalCountNumber;

        totalCountNumber = (newContacts.imAddresses && newContacts.imAddresses.length > 0)
            ? totalCountNumber + newContacts.imAddresses.length : totalCountNumber;

        totalCountNumber = (newContacts.nickName && newContacts.nickName.nickName
        && newContacts.nickName.nickName.length > 0) ? totalCountNumber + 1 : totalCountNumber;

        totalCountNumber = (newContacts.websites && newContacts.websites.length > 0)
            ? totalCountNumber + newContacts.websites.length : totalCountNumber;

        totalCountNumber = (newContacts.postalAddresses && newContacts.postalAddresses.length > 0)
            ? totalCountNumber + newContacts.postalAddresses.length : totalCountNumber;

        totalCountNumber = (newContacts.note && newContacts.note.noteContent
        && newContacts.note.noteContent.length > 0) ? totalCountNumber + 1 : totalCountNumber;

        totalCountNumber = (newContacts.events && newContacts.events.length > 0)
            ? totalCountNumber + newContacts.events.length : totalCountNumber;

        totalCountNumber = (newContacts.relations && newContacts.relations.length > 0)
            ? totalCountNumber + newContacts.relations.length : totalCountNumber;

        totalCountNumber = (newContacts.name && newContacts.name.familyNamePhonetic
        && newContacts.name.familyNamePhonetic.length > 0) ? totalCountNumber + 1 : totalCountNumber;

        totalCountNumber = (newContacts.groups && newContacts.groups.length > 0)
            ? totalCountNumber + 1 : totalCountNumber;

        return totalCountNumber;
    },
    setTempPhoneNumbersList(totalCountNumber, dataLengthCount, newContacts) {
        var tempPhoneNumbersList = [];
        if (newContacts.phoneNumbers && newContacts.phoneNumbers.length > 0) {
            newContacts.phoneNumbers.forEach((element) => {
                element.showElement = true;
                if (dataLengthCount === totalCountNumber - 1) {
                    element.showLastDivider = false;
                } else {
                    element.showLastDivider = true;
                }
                dataLengthCount++;
                tempPhoneNumbersList.push(element);
            });
        }
        return tempPhoneNumbersList;
    },
    setTempEmailsList(totalCountNumber, dataLengthCount, newContacts) {
        var tempEmailsList = [];
        if (newContacts.emails && newContacts.emails.length > 0) {
            newContacts.emails.forEach((element) => {
                element.showElement = true;
                if (dataLengthCount === totalCountNumber - 1) {
                    element.showLastDivider = false;
                } else {
                    element.showLastDivider = true;
                }
                dataLengthCount++;
                tempEmailsList.push(element);
            });
        }
        return tempEmailsList;
    },
    setTempImAddressesList(totalCountNumber, dataLengthCount, newContacts) {
        var tempImAddressesList = [];
        if (newContacts.imAddresses && newContacts.imAddresses.length > 0) {
            newContacts.imAddresses.forEach((element) => {
                element.showElement = true;
                if (dataLengthCount === totalCountNumber - 1) {
                    element.showLastDivider = false;
                } else {
                    element.showLastDivider = true;
                }
                dataLengthCount++;
                tempImAddressesList.push(element);
            });
        }
        return tempImAddressesList;
    },
    setTempWebsitesList(totalCountNumber, dataLengthCount, newContacts) {
        var tempWebsitesList = [];
        if (newContacts.websites && newContacts.websites.length > 0) {
            newContacts.websites.forEach((element) => {
                element.showElement = true;
                if (dataLengthCount === totalCountNumber - 1) {
                    element.showLastDivider = false;
                } else {
                    element.showLastDivider = true;
                }
                dataLengthCount++;
                tempWebsitesList.push(element);
            });
        }
        return tempWebsitesList;
    },
    setTempPostalAddressesList(totalCountNumber, dataLengthCount, newContacts) {
        var tempPostalAddressesList = [];
        if (newContacts.postalAddresses && newContacts.postalAddresses.length > 0) {
            newContacts.postalAddresses.forEach((element) => {
                element.showElement = true;

                if (dataLengthCount === totalCountNumber - 1) {
                    element.showLastDivider = false;
                } else {
                    element.showLastDivider = true;
                }
                dataLengthCount++;
                tempPostalAddressesList.push(element);
            });
        }
        return tempPostalAddressesList;
    },
    setTempEventsList(totalCountNumber, dataLengthCount, newContacts) {
        var tempEventsList = [];
        if (newContacts.events && newContacts.events.length > 0) {
            newContacts.events.forEach((element) => {
                element.showElement = true;
                if (dataLengthCount === totalCountNumber - 1) {
                    element.showLastDivider = false;
                } else {
                    element.showLastDivider = true;
                }
                dataLengthCount++;
                tempEventsList.push(element);
            });
        }
        return tempEventsList;
    },
    setTempRelationsList(totalCountNumber, dataLengthCount, newContacts) {
        var tempRelationsList = [];
        if (newContacts.relations && newContacts.relations.length > 0) {
            newContacts.relations.forEach((element) => {
                element.showElement = true;
                if (dataLengthCount === totalCountNumber - 1) {
                    element.showLastDivider = false;
                } else {
                    element.showLastDivider = true;
                }
                dataLengthCount++;
                tempRelationsList.push(element);
            });
        }
        return tempRelationsList;
    },
    setContactForm(showGroupsString, newContacts) {
        this.contactForm.lastName = (newContacts.name && newContacts.name.nameSuffix
        && newContacts.name.nameSuffix.length > 0) ? newContacts.name.nameSuffix : '';

        this.contactForm.company = (newContacts.organization && newContacts.organization.name
        && newContacts.organization.name.length > 0) ? newContacts.organization.name : '';

        this.contactForm.position = (newContacts.organization && newContacts.organization.title
        && newContacts.organization.title.length > 0) ? newContacts.organization.title : '';

        this.contactForm.phoneNumbers = (newContacts.phoneNumbers && newContacts.phoneNumbers.length > 0)
            ? newContacts.phoneNumbers : [];

        this.contactForm.emails = (newContacts.emails && newContacts.emails.length > 0) ? newContacts.emails : [];

        this.contactForm.imAddresses = (newContacts.imAddresses && newContacts.imAddresses.length > 0)
            ? newContacts.imAddresses : [];

        this.contactForm.nickName = (newContacts.nickName && newContacts.nickName.nickName
        && newContacts.nickName.nickName.length > 0) ? newContacts.nickName.nickName : '';

        this.contactForm.websites = (newContacts.websites && newContacts.websites.length > 0)
            ? newContacts.websites : [];

        this.contactForm.postalAddresses = (newContacts.postalAddresses && newContacts.postalAddresses.length > 0)
            ? newContacts.postalAddresses : [];

        this.contactForm.events = (newContacts.events && newContacts.events.length > 0) ? newContacts.events : [];

        this.contactForm.note = (newContacts.note && newContacts.note.noteContent
        && newContacts.note.noteContent.length > 0) ? newContacts.note.noteContent : '';

        this.contactForm.relations = (newContacts.relations && newContacts.relations.length > 0)
            ? newContacts.relations : [];

        this.contactForm.pinYinName = (newContacts.name && newContacts.name.familyNamePhonetic
        && newContacts.name.familyNamePhonetic.length > 0) ? newContacts.name.familyNamePhonetic : '';

        this.contactForm.showGroupsString = (showGroupsString && showGroupsString.length > 0) ? showGroupsString : '';
        this.contactForm.groups = (newContacts.groups && newContacts.groups.length > 0) ? newContacts.groups : [];
    },
    processingInitializationData(newContacts) {
        if (!Utils.isEmptyList(this.contactForm.phoneNumbers)) {
            var numbers = [];
            this.contactForm.phoneNumbers.forEach(element => {
                numbers.push(element.phoneNumber);
            });
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
            callLogService.getCallLogListByPhoneNumber(DAHelper, numbers, (resultList) => {
                this.contactForm.numRecords = this.getDetailMessage(resultList);
            });
        }

        if (this.sourceFromCallRecord && this.isNewNumber) {
            this.showNameLast = (this.contactForm.phoneNumbers && this.contactForm.phoneNumbers[0])
                ? this.contactForm.phoneNumbers[0].phoneNumber : '';
        } else {
            this.showNameLast = (this.contactForm.emptyNameData && this.contactForm.emptyNameData.length > 0)
                ? this.contactForm.emptyNameData : '';
        }
        this.showNameLastMenu = (this.showNameLast && this.showNameLast.length > 6)
            ? this.subStringWithEllipsis(this.showNameLast, 7) : this.showNameLast;

        if (!Utils.isEmptyList(this.contactForm.phoneNumbers)) {
            for (var i = 0; i < this.contactForm.phoneNumbers.length; i++) {
                if (this.contactForm.phoneNumbers[i].isPrimary === 1) {
                    var tempPhoneNumber = newContacts.phoneNumbers[i];
                    this.contactForm.phoneNumbers.splice(i, 1);
                    this.contactForm.phoneNumbers.unshift(tempPhoneNumber);
                }
            }
        }
    },
    openMailApp: function (index) {
        prompt.showToast({
            message: this.$t('recordDetail.menu.noAppToDealThisAction')
        });
    },
    openMessageApp: function (index) {
        prompt.showToast({
            message: this.$t('recordDetail.menu.noAppToDealThisAction')
        });
    },
    openCalenderApp: function (index) {
        prompt.showToast({
            message: this.$t('recordDetail.menu.noAppToDealThisAction')
        });
    },

    openMapApp() {
        this.$element('dialogPostalAddressMap').close();
        var actionData = {};
        actionData.postalAddressName = this.postalAddressName;
        let result = {
            'code': 0
        };
        if (result.code != 0) {
            LOG.info(TAG + 'plus result is error:' + result.code);
        }
    },

    /**
     * If source is 0, the search page is displayed for new contacts. When source is 1, the relation from relation relation jumps
     *
     * @param {number} source
     * @param {number} index
     */
    openSearchContact: function (source, index) {
        this.$app.$def.globalData.searchValue = this.contactForm.relations[index].relationName;
        this.$app.$def.globalData.navigationType = 'contacts';
        router.back({
            path: 'pages/navigation/navigation'
        });
    },
    sendNewContent() {
        router.push({
            uri: 'pages/contacts/selectContactsList/selectContactsList',
            params: {
                type: 'saveContacts',
                number: this.phoneNumberShow,
            }
        });
    },

    /**
     * Click to open the corresponding website
     *
     * @param {number} index
     */
    openBrowser: function (index) {
        var actionData = {};
        actionData.openContent = this.contactForm.websites[index].website;
        let result = {
            'code': 0
        };
        if (result.code != 0) {
            LOG.info(TAG + 'plus result is error:' + result.code);
        }
    },

    /**
     * Click postalAddress to open the select button
     *
     * @param {number} index
     */
    onclickPostalAddress: function (index) {
        LOG.info(TAG + 'onclickPostalAddress index' + index);
        this.postalAddressName = this.contacts.postalAddresses[index].postalAddress;
        clearTimeout(this.showMenuTimeOutId);
        this.showMenuTimeOutId = setTimeout(() => {
            this.$element('dialogPostalAddressMap').show({});
        }, 60);
    },

    /**
     * List The list move ends
     *
     * @param {Object} e
     */
    onTouchEnd: function (e) {
        LOG.info(TAG + 'onTouchEnd e' + e);
        this.directPoint = (this.directPoint + this.directPointTemp);
        this.directPointTemp = 0;
    },

    /**
     * The current list has slid to the top position
     *
     * @param {Object} e
     */
    onScrollTop: function (e) {
        LOG.info(TAG + 'onScrollTop e' + e);
        this.showHeaderFlag = true;
        this.directPoint = 0;
        this.directPointTemp = 0;
    },

    /**
     * Use the contact icon to place a call
     *
     * @param {Object} e
     */
    callOutByDialerIcon(e) {
        LOG.info(TAG + ' callOutByLog:' + e);
        this.callOut(this.contactForm.numRecords[e.detail.index].numbers[0].number);
    },

    /**
     * Outgoing interface of telephone
     *
     * @param {Array} phoneNumber
     */
    callOut(phoneNumber) {
        var actionData = {};
        if (phoneNumber.length == 0 && this.contactForm.numRecords.length > 0) {
            actionData.phoneNumber = this.contactForm.numRecords[0].numbers[0].number;
        } else if (phoneNumber.length > 0) {
            actionData.phoneNumber = phoneNumber;
        }
        this.$app.$def.call(phoneNumber);
    },

    /**
     * Obtaining Call Records
     *
     * @param {Array} numbers
     */
    getNumRecords(numbers) {
        var actionData = {};
        actionData.number = numbers;
        actionData.language = this.$t('recordDetail.language');
    },

    /**
     * Delete the call history menu option
     *
     * @param {Object} event
     */
    todoSelected(event) {
        if (event.value == 'delete') {
            this.$element('deleteCheckDialog').show();
        }
        if (event.value == 'edit') {
            this.$app.$def.dialerStateData.numTextDialer = this.sendNumber;
            this.$app.$def.dialerStateData.isEditNumber = true;
            this.$app.$def.globalData.navigationType = 0;
            this.$app.$def.globalData.menuType = 0;
            router.back({
                path: 'pages/navigation/navigation'
            });
        }
    },

    /**
     * Select menu option
     *
     * @param {Object} event
     */
    todoSelectedPhoneNumber(event) {
        if (event.value == 'copyNumber') {
            var number = '';
            number = this.contacts.phoneNumbers[this.numLongPressIndexIndex].phoneNumber.replace(/\s+/g, '');
            this.copyNumber(number);
        }
        if (event.value == 'edit') {
            this.$app.$def.dialerStateData.numTextDialer = this.sendNumber;
            this.$app.$def.dialerStateData.isEditNumber = true;
            this.$app.$def.globalData.navigationType = 0;
            this.$app.$def.globalData.menuType = 0;
            router.back({
                path: 'pages/navigation/navigation'
            });
        }
        if (event.value == 'setDefaultPhoneNumber') {
            this.setOrCancelDefaultPhoneNumber(SET_DEFAULT);
        }
        if (event.value == 'clearDefaultPhoneNumber') {
            this.setOrCancelDefaultPhoneNumber(CLEAR_DEFAULT);
        }
    },

    /**
     * Setting to cancel the default phone
     *
     * @param {number} defaultStatus
     */
    setOrCancelDefaultPhoneNumber(defaultStatus) {
        LOG.info(TAG + 'setOrCancelDefaultPhoneNumber' + defaultStatus);
        var actionData = {};
        actionData.contactId = this.contacts.contactId;
        actionData.phoneNumber = this.contactForm.phoneNumbers[this.numLongPressIndexIndex]
        .phoneNumber.replace(/\s+/g, '');
        actionData.isPrimary = defaultStatus;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        favoritesModel.setOrCancelDefaultPhoneNumber(DAHelper, actionData, result => {
            if (result.code == 0) {
                if (defaultStatus == SET_DEFAULT) {
                    this.contactForm.phoneNumbers[this.numLongPressIndexIndex].isPrimary = SET_DEFAULT;
                    var tempPhoneNumber = this.contactForm.phoneNumbers[this.numLongPressIndexIndex];
                    this.contactForm.phoneNumbers = this.copy(this.contacts.phoneNumbers);
                    var tempIndex = 0;
                    if (!Utils.isEmptyList(this.contactForm.phoneNumbers)) {
                        for (var i = 0; i < this.contactForm.phoneNumbers.length; i++) {
                            if (tempPhoneNumber.phoneNumber == this.contactForm.phoneNumbers[i].phoneNumber) {
                                tempIndex = i;
                            } else {
                                this.contactForm.phoneNumbers[i].isPrimary = CLEAR_DEFAULT;
                            }
                        }
                    }
                    this.contactForm.phoneNumbers.splice(tempIndex, 1);
                    this.contactForm.phoneNumbers.unshift(tempPhoneNumber);
                }
                if (defaultStatus == CLEAR_DEFAULT) {
                    this.contactForm.phoneNumbers = this.contacts.phoneNumbers;
                    this.contactForm.phoneNumbers.forEach(element => {
                        element.isPrimary = CLEAR_DEFAULT;
                    });
                }
            } else {
                prompt.showToast({
                    message: this.$t('Fail to update default phone number!')
                });
            }
        });

    },

    /**
     * Jump to the relational person
     *
     * @param {Object} event
     */
    todoSelectedContent(event) {
        if (event.value == 'copyToClipBoard') {
            this.copyNumber(this.relationName);
        }
    },
    copyContentCancelDialogPostalAddress() {
        this.$element('dialogPostalAddressMap').close();
        this.copyNumber(this.postalAddressName);
    },

    copyNumber(data) {
        LOG.info(TAG + 'copyNumber data' + data);
        var actionData = {};
        actionData.pasteBoardContent = data;
    },

    /**
     * Share selected content
     *
     * @param {Object} event
     */
    shareSelectContact: function (event) {
        if (event.value == 'deleteContact') {
            this.$element('deletedialogcontact').show();
        }
        if (event.value == 'deleteRecord') {
            this.$element('deletedialogrecord').show();
        }
        if (event.value == 'shareContact') {
            this.$element('shareDialogDetails').show();
        }
    },

    /**
     * Delete Contact Details More Call History Menu option
     *
     * @param {Object} event
     */
    shareSelectRecord: function (event) {
        if (event.value == 'deleteRecord') {
            this.$element('deletedialogrecord').show();
        }
    },

    cancelClickContact: function () {
        this.$element('deletedialogcontact').close();
    },

    cancelClickQrCode: function () {
        this.$element('dialogContactsDetailQrCode').close();
    },

    cancelClickRecord: function () {
        this.$element('deletedialogrecord').close();
    },

    /**
     * Delete contact list data
     *
     * @param {number} code
     * @param {number} data contactId The contact ID
     */
    deleteContactData(code, data) {
        LOG.info(TAG + 'deleteContactData code' + code);
        LOG.info(TAG + 'deleteContactData data' + data);
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        var result = contactsService.deleteContacts(DAHelper, data, result => {
            if (result == 0) {
                router.back();
            } else {
                prompt.showToast({
                    message: 'contactDetail Failed to delete data.'
                });
            }
        });
    },

    deleteClickContact: function () {
        this.$element('deletedialogcontact').close();
        var requestData = {
            contactId: this.contacts.contactId
        };
        this.deleteContactData(DELETE_CONTACT, requestData);
    },

    deleteClickRecord: function () {
        this.$element('deletedialogrecord').close();
        this.clearRecordsMore();
    },

    clearRecordsMore() {
        var id = '';
        var ids = [];
        for (let index = 0; index < this.contactForm.numRecords.length; index++) {
            id = this.contactForm.numRecords[index].id;
            ids.push(id);
        }
        this.removeCallLog(ids);
        this.contactForm.numRecords = [];
        this.contactForm.showMoreButton = false;
    },

    doDelete() {
        var id = this.contactForm.numRecords[this.deleteIndex].id;
        var ids = [];
        ids.push(id);
        this.removeCallLog(ids);
        this.contactForm.numRecords.splice(this.index, 1);
        this.$element('deleteCheckDialog').close();
    },

    cancelDialog() {
        this.$element('deleteCheckDialog').close();
    },

    cancelDialogPostalAddress() {
        this.$element('dialogPostalAddressMap').close();
    },

    /**
     * Deleting Call History
     *
     * @param {Array} ids
     */
    removeCallLog: function (ids) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.deleteCallLogByIds(DAHelper, ids, () => {
        });
    },

    /**
     * Send a message
     *
     * @param {number} phoneNumber
     * @param {string} name
     */
    sendMessage(phoneNumber, name) {
        var params = [];
        params.push({
            contactsName: name,
            telephone: phoneNumber,
            telephoneFormat: phoneNumber,
        });
        this.$app.$def.sendMessage(params);
    },

    addContacts() {
        let show = this.phoneNumberShow.length > 0 ? true : false;
        this.$app.$def.dialerStateData.isNeedShowDialer = false;
        router.push({
            uri: 'pages/contacts/accountants/accountants',
            params: {
                addShow: true,
                updataShow: false,
                showWork: true,
                upHouseShow: true,
                phoneNumbers: [
                    {
                        'id': '',
                        'labelId': 2,
                        'labelName': this.$t('accountants.phone'),
                        'phoneNumber': this.phoneNumberShow,
                        'phoneAddress': 'N',
                        'blueStyle': false,
                        'showP': show
                    }]
            },
        });
    },

    /**
      * Intercepts the first five characters of the string
      *
      * @param {string} str
      * @param {number} len
      * @return {Object} newStr
      */
    subStringWithEllipsis(str, len) {
        let newLength = 0;
        let newStr = '';
        let chineseRegex = /[^\x00-\xff]/g;
        let singleChar = '';
        let strLength = str.replace(chineseRegex, '**').length;
        for (var i = 0; i < strLength; i++) {
            singleChar = str.charAt(i).toString();
            if (singleChar.match(chineseRegex) != null) {
                newLength += 2;
            } else {
                newLength++;
            }
            if (newLength > len) {
                break;
            }
            newStr += singleChar;
        }
        newStr += '..'
        return newStr;
    },
    showMoreMenuOperationSaveContacts() {
        this.$element('contactSaveContactBottom').show({
            x: this.touchMoveStartX,
            y: this.touchMoveStartY
        });
    },
    showMoreMenuOperationNew() {
        this.$element('contactNewNumberBottom').show({
            x: this.touchMoveStartX,
            y: this.touchMoveStartY
        });
    },

    touchMoreStartButtom(e) {
        LOG.info(TAG + 'touchMoreStartButtom e' + e);
        this.touchMoveStartX = e.touches[0].globalX;
        this.touchMoveStartY = e.touches[0].globalY;
    },

    onclickContactsDetailQrCode: function () {
        var name = (this.contacts.name && this.contacts.name.fullName && this.contacts.name.fullName.length > 0)
            ? 'N:' + this.contacts.name.fullName + ';' : '';

        var company = (this.contacts.organization && this.contacts.organization.name
        && this.contacts.organization.name.length > 0) ? 'ORG:' + this.contacts.organization.name + ';' : '';

        var postalAddresses = (this.contacts.postalAddresses && this.contacts.postalAddresses[0]
        && this.contacts.postalAddresses[0].postalAddress.length > 0)
            ? 'ADR:' + this.contacts.postalAddresses[0].postalAddress + ';' : '';

        var phoneNumbersString = '';
        var phoneNumberLength = (this.contacts && this.contacts.phoneNumbers) ? this.contacts.phoneNumbers.length : 0;
        for (var i = 0; i < phoneNumberLength; i++) {
            if (i >= 2) {
                break;
            } else {
                phoneNumbersString = phoneNumbersString + 'TEL:' + this.contacts.phoneNumbers[i].phoneNumber + ';';
            }
        }
        var stringEmails = '';
        var emailsLength = (this.contacts && this.contacts.emails) ? this.contacts.emails.length : 0;
        for (var i = 0; i < emailsLength; i++) {
            if (i >= 2) {
                break;
            } else {
                stringEmails = stringEmails + 'EMAIL:' + this.contacts.emails[i].email + ';';
            }
        }
        var websites = (this.contacts.websites && this.contacts.websites[0]
        && this.contacts.websites[0].website.length > 0) ? 'URL:' + this.contacts.websites[0].website + ';' : '';

        var position = (this.contacts.organization && this.contacts.organization.title
        && this.contacts.organization.title.length > 0) ? 'TIL:' + this.contacts.organization.title + ';' : '';

        var note = (this.contacts.note && this.contacts.note.noteContent && this.contacts.note.noteContent.length > 0)
            ? 'NOTE:' + this.contacts.note.noteContent : '';

        var imAddresses = (this.contacts.imAddresses && this.contacts.imAddresses.length > 0
        && this.contacts.imAddresses[0].imAddress.length > 0) ? this.contacts.imAddresses[0].imAddress + ';;' : '';

        this.qrcodeString = 'MECARD:' + name + company + postalAddresses + phoneNumbersString
        + stringEmails + websites + position + note + imAddresses;
        clearTimeout(this.showMenuTimeOutId);
        this.showMenuTimeOutId = setTimeout(() => {
            this.$element('dialogContactsDetailQrCode').show();
        }, 60);
    },
    cancelContactsDetailQrCode: function () {
        clearTimeout(this.showMenuTimeOutId);
        this.$element('dialogContactsDetailQrCode').close();
    },

    shareCancelClick: function () {
        this.$element('shareDialogDetails').close();
    },

    shareClickQrCode: function () {
        prompt.showToast({
            message: this.$t('recordDetail.menu.noAppToDealThisAction')
        });
    },

    /**
     * Non-contact, call records, assembly parameters
     *
     * @param {Array} numbers
     */
    getNewNumRecords(numbers) {
        var actionData = {};
        actionData.number = numbers;
        actionData.language = this.$t('recordDetail.language');
        var newContacts = {};
        this.contactForm.isNewNumber = true;
        this.contactForm.showMoreButton = false;
        this.contactForm.name = this.phoneNumberShow;
        this.contactForm.showNewContact = true;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.getCallLogListByPhoneNumber(DAHelper, numbers, (resultList) => {
            this.contactForm.numRecords = this.getDetailMessage(resultList);
            var phoneNumbersTemp = {};
            if (this.contactForm.numRecords.length > 0) {
                phoneNumbersTemp.phoneAddress = this.contactForm.numRecords[0].callTag;
            }
            phoneNumbersTemp.phoneNumber = this.phoneNumberShow;
            var phoneNumbersTempList = [phoneNumbersTemp];
            this.contactForm.phoneNumbers = phoneNumbersTempList;
            newContacts.phoneNumbers = phoneNumbersTempList;
            newContacts.name = {
                'name': this.contactForm.name
            };
            newContacts.isNewNumber = this.contactForm.isNewNumber;
            newContacts.showMoreButton = this.contactForm.showMoreButton;
            newContacts.numRecords = this.contactForm.numRecords;
            var index = parseInt(this.contactForm.numRecords[0].id, 10) % 6;
            newContacts.portraitColor = this.backgroundColor[index];
            newContacts.detailsBgColor = this.backgroundDetailColor[index];
            this.contacts = newContacts;
            if (this.sourceFromCallRecord && this.isNewNumber) {
                this.showNameLast = (this.contactForm.phoneNumbers && this.contactForm.phoneNumbers[0])
                    ? this.contactForm.phoneNumbers[0].phoneNumber : '';
            } else {
                this.showNameLast = (this.contactForm.emptyNameData && this.contactForm.emptyNameData.length > 0)
                    ? this.contactForm.emptyNameData : '';
            }
            this.showNameLastMenu = (this.showNameLast && this.showNameLast.length > 6)
                ? this.subStringWithEllipsis(this.showNameLast, 7) : this.showNameLast;
        });
    },

    /**
     * Data required to convert the original callLogList content into call record details
     *
     * @param {Array} originList
     * @return {Array} resultList
     */
    getDetailMessage(originList) {
        LOG.info(TAG + 'getDetailMessage originList' + originList);
        var resultList = [];
        if (Utils.isEmptyList(originList)) {
            return resultList;
        }
        originList.forEach(element => {
            element.timeDetail = this.getTimeDetailByCallTime(element.callTime);
            element.talkTime = this.getTalkTimeMessage(element);
        });
        resultList = originList;
        return resultList;
    },

    shareContactInfoByTest() {
        var detailInfo = JSON.stringify(this.contactForm);
    },

    /**
     * Obtain the call details based on the call record
     *
     * @param {Object} callLogElement
     * @return {string} resultMessage
     */
    getTalkTimeMessage(callLogElement) {
        LOG.info(TAG + 'getTalkTimeMessage callLogElement' + callLogElement);
        var resultMessage = '';
        if (callLogElement.callType == 1) {
            resultMessage = this.getDescriptionByDuration(callLogElement.talkTime);
        } else if (callLogElement.callType == 2) {
            resultMessage = callLogElement.talkTime == 0 ? this.$t('recordDetail.language.blockCall')
                                                         : this.getDescriptionByDuration(callLogElement.talkTime);
        } else if (callLogElement.callType == 3) {
            resultMessage = this.$t('recordDetail.language.noAnswer') + this.getDescriptionByDuration(callLogElement.ringTime);
        } else if (callLogElement.callType == 5) {
            resultMessage = this.$t('recordDetail.language.reject');
        }
        return resultMessage;
    },

    /**
     * Takes the call duration (timeDuration in s) based on the specified timestamp
     *
     * @param {number} timeDuration
     * @return {Object}
     */
    getDescriptionByDuration(timeDuration) {
        LOG.info(TAG + 'getDescriptionByDuration timeDuration' + timeDuration);
        var seconds = parseInt(timeDuration);
        if (seconds < 60) {
            return seconds + this.$t('recordDetail.language.seconds');
        } else {
            var minutes = parseInt(seconds / 60);
            if (minutes < 60) {
                return minutes + this.$t('recordDetail.language.minute') + seconds % 60 + this.$t('recordDetail.language.seconds');
            } else {
                var hours = parseInt(minutes / 60);
                return hours + this.$t('recordDetail.language.hour') + minutes % 60 + this.$t('recordDetail.language.minute') + seconds % 3600 % 60 + this.$t('recordDetail.language.seconds');
            }
        }
    },

    /**
     * Get time details based on when call records were generated
     *
     * @param {number} callTime
     * @return {string} timeDetail
     */
    getTimeDetailByCallTime(callTime) {
        LOG.info(TAG + 'getTimeDetailByCallTime callTime' + callTime);
        var callLogTime = new Date(parseInt(callTime, 10) * 1000);
        var now = new Date();
        var yearDiff = now.getFullYear() - callLogTime.getFullYear();
        var monthDiff = now.getMonth() - callLogTime.getMonth();
        var dayDiff = now.getDate() - callLogTime.getDate();
        var hour = callLogTime.getHours();
        var timeDetail = '';
        if (yearDiff == 0) {
            if (monthDiff == 0) {
                if (dayDiff == 0) {
                    timeDetail = this.getDayMessage(hour) + callLogTime.getHours() + ':'
                    + (callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes());
                }
            }
            timeDetail = (callLogTime.getMonth() + 1) + this.$t('recordDetail.language.months') + callLogTime.getDate() + this.$t('recordDetail.language.day') + ' '
            + this.getDayMessage(hour) + callLogTime.getHours() + ':'
            + (callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes());
        } else {
            timeDetail = callLogTime.getFullYear() + this.$t('recordDetail.language.years')  + (callLogTime.getMonth() + 1) + this.$t('recordDetail.language.months')
            + callLogTime.getDate() + this.$t('recordDetail.language.day') + ' ' + this.getDayMessage(hour) + callLogTime.getHours() + ':'
            + (callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes());
        }
        LOG.info(TAG + ' timeDetail = ' + timeDetail);
        return timeDetail;
    },

    getDayMessage(hour) {
        LOG.info(TAG + ' getDayMessage' + hour);
        if (hour >= 0 && hour < 5) {
            return this.$t('recordDetail.language.beforeDawn');
        }
        if (hour >= 5 && hour < 11) {
            return this.$t('recordDetail.language.AM');
        }
        if (hour >= 11 && hour < 13) {
            return $t('recordDetail.language.noon');
        }
        if (hour >= 13 && hour < 17) {
            return $t('recordDetail.language.PM');
        }
        if (hour >= 17 && hour < 19) {
            return $t('recordDetail.language.nightfall');
        }
        if (hour >= 19 && hour < 22) {
            return $t('recordDetail.language.evening');
        }
        if (hour >= 22 && hour < 24) {
            return $t('recordDetail.language.middleNight');
        }
    }
};
