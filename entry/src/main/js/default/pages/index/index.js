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
import LOG from '../../utils/ContactsLog.js'
import cardModel from '../../../default/model/AccountantsModel.js'
import Constants from '../../../default/common/constants/Constants.js';
var TAG = 'index';

export default {
    data: {
        params: {},
        uri: '',
        newNumberContactDetail: {}
    },
    onInit() {
        LOG.info("logMessage onInit index.js");
    },
    onShow() {
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.getWant()
            .then((Want) => {
            LOG.info(TAG + 'onShow' + 'logMessage Operation successful. Data: ' + Want);
            if (Utils.isEmpty(Want.uri) && Utils.isEmpty(Want.parameters.pageFlag)) {
                this.goToContacts();
            } else if (!Utils.isEmpty(Want.uri)) {
                this.pageRouteHandler({
                    pageFlag: Want.uri
                });
            } else {
                this.pageRouteHandler(Want.parameters);
            }

        }).catch((error) => {
            LOG.error(TAG + 'onShow' + 'logMessage Operation failed. Cause: ' + error);
        })
    },

    pageRouteHandler: function (routeMessage) {
        if (Utils.isEmpty(routeMessage.pageFlag)) {
            this.goToContacts();
            return;
        }
        switch (routeMessage.pageFlag) {
            case 'page_flag_contacts':
                this.uri = 'pages/navigation/navigation';
                this.params = {
                    'navigationType': 'contacts'
                }
                break;
            case 'page_flag_edit_before_calling':
                this.editBeforeCall(routeMessage.phoneNumber);
                break;
            case 'page_flag_save_contact':
                this.addContacts(routeMessage.phoneNumber);
                break;
            case 'page_flag_save_exist_contact':
                this.saveToContacts(routeMessage.phoneNumber);
                break;
            case 'page_flag_sms_forward':
                this.uri = 'pages/contacts/batchselectcontacts/batchselectcontacts';
                this.params = {
                    selectType: 1
                }
                break;
            case 'page_flag_mult_choose':
                this.uri = 'pages/contacts/batchselectcontacts/batchselectcontacts';
                this.params = {
                    selectType: 0
                }
                break;
            case 'page_flag_choose_contacts':
                this.uri = 'pages/contacts/selectContactsList/selectContactsList';
                this.params = {
                    type: 'mmsChooseContacts'
                }
                break;
            case 'page_flag_contact_details':
                this.uri = 'pages/contacts/contactDetail/contactDetail';
                if (routeMessage.contactId) {
                    this.params = {
                        'contactId': routeMessage.contactId,
                    }
                } else {
                    this.params = {
                        'sourceFromCallRecord': true,
                        'isNewNumber': true,
                        'phoneNumberShow': routeMessage.phoneNumber,
                    }
                }
                break;
            case 'page_flag_dialer':
                this.uri = 'pages/navigation/navigation';
                this.params = {
                    'navigationType': 0
                }
                break;
            case 'page_flag_call_logs':
                this.uri = 'pages/navigation/navigation';
                this.$app.$def.dialerStateData.isNeedHideDialer = true;
                this.params = {
                    'navigationType': 0
                }
                break;
            case 'page_flag_missed_calls':
                this.goToMissedCalls();
                break;
            case 'page_flag_card_details':
                this.goToMyCard();
                break;
            default:
                LOG.error(TAG + 'pageRouteHandler' + 'This page is not open.');
                break;
        }
        router.replace({
            uri: this.uri,
            params: this.params
        });
    },

    goToMyCard() {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        cardModel.getCardDetails(DAHelper, '', (result) => {
            var contactForm = result.data;
            router.replace({
                uri: 'pages/contacts/card/card',
                params: {
                    contactForm: contactForm,
                },
            });
        });
    },
    /* 呼叫前编辑 */
    editBeforeCall(phoneNumber) {
        this.$app.$def.dialerStateData.isEditNumber = true;
        this.$app.$def.dialerStateData.numTextDialer = phoneNumber;
        this.goToDialer();
    },

    goToMissedCalls() {
        this.$app.$def.dialerStateData.isGoToMissedCalls = true;
        this.goToDialer();
    },

    goToContacts() {
        router.replace({
            uri: 'pages/navigation/navigation',
            params: {
                'navigationType': 'contacts'
            }
        })
    },

    goToDialer() {
        router.replace({
            uri: 'pages/navigation/navigation',
            params: {
                'navigationType': 0,
            }
        });
    },

    saveToContacts(phoneNumber) {
        router.replace({
            uri: 'pages/contacts/selectContactsList/selectContactsList',
            params: {
                type: 'saveContacts',
                number: phoneNumber,
            }
        });
    },

    addContacts(phoneNumber) {
        var number = phoneNumber.replace(/[^0123456789+]*/g, '');
        var show = false;
        this.uri = 'pages/contacts/accountants/accountants';
        router.replace({
            uri: 'pages/contacts/accountants/accountants',
            params: {
                phoneNumbers: [
                    {
                        'labelId': 2,
                        'labelName': this.$t('accountants.phone'),
                        'phoneNumber': number,
                        'phoneAddress': 'N',
                        'showP': show,
                        'blueStyle': true
                    }
                ]
            }
        });
    },
}
