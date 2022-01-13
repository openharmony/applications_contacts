/**
 * @file: card
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
import Utils from '../../../../default/utils/utils.js';
import LOG from '../../../utils/ContactsLog.js';

var TAG = 'Card...:';

export default {
    data: {
        icAvatarNormalLight: '/res/image/ic_contacts_name_m.svg',
        icContactsAllergies: '/res/image/ic_contacts_allergies_m.svg',
        icShare: '/res/image/ic_share_m.svg',
        arrowUnfold: '/res/image/ic_contacts_arrow_unfold_s.svg',
        arrowUp: '/res/image/ic_contacts_arrow_unfold.svg',
        scrollDown: true,
        scrollUp: false,
        contactForm: {},
        startGlobalY: 0,
        moveGlobalY: 0,
        shareList: [],
        emails: [],
        events: [],
        imAddresses: [],
        phoneNumbers: [],
        postalAddresses: [],
        relations: [],
        websites: [],
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
        showNameLast: '',
        count: 0,
        countStaus: true,
        qrcodeParam: ''
    },
    onInit() {
        if (Utils.isEmpty(this.contactForm.name)) {
            this.contactForm.name = this.name;
        }
        this.showNameLast = this.contactForm.name && this.contactForm.name.fullName ? this.contactForm.name.fullName
                                                                                    : ((this.contactForm.emptyNameData && this.contactForm.emptyNameData.length > 0)
                ? this.contactForm.emptyNameData : (this.contactForm.phoneNumbers && this.contactForm.phoneNumbers[0])
                                                       ? this.contactForm.phoneNumbers[0].phoneNumber : '');
        if (!this.contactForm.emails || this.contactForm.emails.length == 0) {
            this.contactForm.emails = this.emails;
        } else {
            this.count = this.count + 1;
        }
        if (!this.contactForm.events || this.contactForm.events.length == 0) {
            this.contactForm.events = this.events;
        } else {
            this.count = this.count + 1;
        }
        this.setInit();
        this.isState();
        this.getQrcode();
    },
    setInit() {
        if (!this.contactForm.imAddresses || this.contactForm.imAddresses.length == 0) {
            this.contactForm.imAddresses = this.imAddresses;
        } else {
            this.count = this.count + 1;
        }
        if (!this.contactForm.phoneNumbers || this.contactForm.phoneNumbers.length == 0) {
            this.contactForm.phoneNumbers = this.phoneNumbers;
        } else {
            this.count = this.count + 1;
        }
        if (!this.contactForm.postalAddresses || this.contactForm.postalAddresses.length == 0) {
            this.contactForm.postalAddresses = this.postalAddresses;
        } else {
            this.count = this.count + 1;
        }
        if (!this.contactForm.relations || this.contactForm.relations.length == 0) {
            this.contactForm.relations = this.relations;
        } else {
            this.count = this.count + 1;
        }
    },
    isState() {
        if (!this.contactForm.websites || this.contactForm.websites.length === 0) {
            this.contactForm.websites = this.websites;
        } else {
            this.count = this.count + 1;
        }
        if (this.contactForm.name.familyNamePhonetic.length > 0) {
            this.count = this.count + 1;
        }
        if (!this.contactForm.name) {
            this.contactForm.name = this.name;
        }
        if (!this.contactForm.nickName) {
            this.contactForm.nickName = this.nickName;
        } else {
            this.count = this.count + 1;
        }
        if (!this.contactForm.note) {
            this.contactForm.note = this.note;
        } else {
            this.count = this.count + 1;
        }
        if (!this.contactForm.organization) {
            this.contactForm.organization = this.organization;
        }
        if (Utils.isEmpty(this.contactForm.organization.name)) {
            this.contactForm.organization.name = '';
        }
        if (Utils.isEmpty(this.contactForm.organization.title)) {
            this.contactForm.organization.title = '';
        }
        if (this.count <= 1) {
            this.countStaus = false;

        }
        this.shareList = [{
                              text: this.$t('value.contacts.page.menu.shareInfo.content.qrCode')
                          },
                          {
                              text: this.$t('value.contacts.page.menu.shareInfo.content.vCard')
                          },
                          {
                              text: this.$t('value.contacts.page.menu.shareInfo.content.text')
                          }];
    },
    onBackPress() {
        router.back();
    },

    getQrcode() {
        var name = (this.contactForm.name && this.contactForm.name.fullName
        && this.contactForm.name.fullName.length > 0) ? 'N:' + this.contactForm.name.fullName + ';' : '';

        var company = (this.contactForm.organization && this.contactForm.organization.name
        && this.contactForm.organization.name.length > 0) ? 'ORG:' + this.contactForm.organization.name + ';' : '';

        var postalAddresses = (this.contactForm.postalAddresses && this.contactForm.postalAddresses[0]
        && this.contactForm.postalAddresses[0].postalAddress.length > 0) ? 'ADR:' + this.contactForm.postalAddresses[0].postalAddress + ';' : '';

        var phoneNumbersString = '';
        var phoneNumberLength = (this.contactForm && this.contactForm.phoneNumbers)
            ? this.contactForm.phoneNumbers.length : 0;
        for (var i = 0; i < phoneNumberLength; i++) {
            if (i >= 2) {
                break;
            } else {
                phoneNumbersString = phoneNumbersString + 'TEL:' + this.contactForm.phoneNumbers[i].phoneNumber + ';';
            }
        }
        var stringEmails = '';
        var emailsLength = (this.contactForm && this.contactForm.emails) ? this.contactForm.emails.length : 0;
        for (var i = 0; i < emailsLength; i++) {
            if (i >= 2) {
                break;
            } else {
                stringEmails = stringEmails + 'EMAIL:' + this.contactForm.emails[i].email + ';';
            }
        }
        var websites = (this.contactForm.websites && this.contactForm.websites[0]
        && this.contactForm.websites[0].website.length > 0) ? 'URL:' + this.contactForm.websites[0].website + ';' : '';

        var position = (this.contactForm.organization && this.contactForm.organization.title
        && this.contactForm.organization.title.length > 0) ? 'TIL:' + this.contactForm.organization.title + ';' : '';

        var note = (this.contactForm.note && this.contactForm.note.noteContent
        && this.contactForm.note.noteContent.length > 0) ? 'NOTE:' + this.contactForm.note.noteContent : '';

        var imAddresses = (this.contactForm.imAddresses && this.contactForm.imAddresses.length > 0
        && this.contactForm.imAddresses[0].imAddress.length > 0)
            ? this.contactForm.imAddresses[0].imAddress + ';;' : '';

        this.qrcodeParam = 'MECARD:' + name + company + postalAddresses + phoneNumbersString
        + stringEmails + websites + position + note + imAddresses;
    },

    routerBack() {
        router.back();
    },
    onDestroy() {

    },

    /**
     * Scroll to the bottom of the list
     *
     * @param {Object} e
     */
    scrollTend(e) {
        LOG.info(TAG + 'scrollTend' + e);
        this.scrollDown = false;
    },

    /**
     * Move after finger touch finger touch action begins.
     *
     * @param {Object} e
     */
    moveSroll(e) {
        this.moveGlobalY = e.touches[0].globalY;
        var temp = this.startGlobalY - this.moveGlobalY;
        if (temp < 0) {
            this.scrollDown = true;
        }
    },

    /**
     * Finger touch begins。
     *
     * @param {Object} e
     */
    srtartMove(e) {
        this.startGlobalY = e.touches[0].globalY;
    },
    scrollToTop(e) {
        this.scrollDown = true;
        this.$element('listItem').scrollTop(true);
    },
    scrollToBottom(e) {
        this.$element('listItem').scrollBottom(true);
    },

    editCard() {
        this.setContactForm();

        this.setContactForms();

        this.addAccountants()
    },
    setContactForm() {
        if (this.contactForm.emails) {
            this.addShowPField(this.contactForm.emails);
        }
        if (this.contactForm.events) {
            this.addShowPField(this.contactForm.events);
        }
        if (this.contactForm.imAddresses) {
            this.addShowPField(this.contactForm.imAddresses);
        }
        if (this.contactForm.phoneNumbers) {
            this.addShowPField(this.contactForm.phoneNumbers);
        }
        if (this.contactForm.postalAddresses) {
            this.addShowPField(this.contactForm.postalAddresses);
        }
        if (this.contactForm.relations) {
            this.addShowPField(this.contactForm.relations);
        }
        if (this.contactForm.websites) {
            this.addShowPField(this.contactForm.websites);
        }
    },
    setContactForms() {
        if (!this.contactForm.emails || this.contactForm.emails.length == 0) {
            this.contactForm.emails = this.emails;
        }
        if (!this.contactForm.events || this.contactForm.events.length == 0) {
            this.contactForm.events = this.events;
        }
        if (!this.contactForm.imAddresses || this.contactForm.imAddresses.length == 0) {
            this.contactForm.imAddresses = this.imAddresses;
        }
        if (!this.contactForm.phoneNumbers || this.contactForm.phoneNumbers.length == 0) {
            this.contactForm.phoneNumbers = this.phoneNumbers;
        }
        if (!this.contactForm.postalAddresses || this.contactForm.postalAddresses.length == 0) {
            this.contactForm.postalAddresses = this.postalAddresses;
        }
        if (!this.contactForm.relations || this.contactForm.relations.length == 0) {
            this.contactForm.relations = this.relations;
        }
        if (!this.contactForm.websites || this.contactForm.websites.length == 0) {
            this.contactForm.websites = this.websites;
        }
    },
    addAccountants() {
        if (!this.contactForm.name) {
            this.contactForm.name = this.name;
        }
        if (!this.contactForm.nickName) {
            this.contactForm.nickName = this.nickName;
        }
        if (!this.contactForm.note) {
            this.contactForm.note = this.note;
        }
        if (!this.contactForm.organization) {
            this.contactForm.organization = this.organization;
        }

        LOG.info(TAG + 'contactForm is ' + this.contactForm);
        router.replace({
            uri: 'pages/contacts/accountants/accountants',
            params: {
                addShow: false,
                updataShow: true,
                updateCard: true,
                showWork: true,
                upHouseShow: true,
                contactForm: this.contactForm,
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
        if (array || array.length > 0) {
            array.forEach((item, index) => {
                item.showP = true;
                delete item.id;
            });
        }
    },

    shareCarte() {
        this.$element('shareCartedialog').show();
    },

    /**
     * Share Contacts
     *
     * @param {number} idx Contact data
     */
    shareClick(idx) {
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

    shareCancelClick() {
        this.$element('shareCartedialog').close();
    }
};
