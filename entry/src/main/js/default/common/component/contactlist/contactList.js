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
export default {
    props: ['contactList', 'searchContactList', 'searchLayoutShow', 'searchPhoneNum', 'phoneCheckShow',
    'showDefaultNumber', 'childPhoneCheckShow', 'showNumberList', 'selectType'],
    data: {
        layoutState: true,
    },
    onInit() {
        this.conciseLayoutInit();
    },

    deleteCheckedCalls() {
        this.$element('deleteCheckDialog').show();
    },

    doDelete() {
        this.$emit('sureProcess', {});
        this.$element('deleteCheckDialog').close();
    },

    conciseLayoutInit: function () {
        let data = this.$app.$def.globalData.storage.getSync('contacts_settings_concise_layout_switch', 'false');
        this.layoutState = data === 'true' ? false : true;
    },

    cancelDialog() {
        this.$element('deleteCheckDialog').close();
    },
    listItemTouchStartSearch(index, indexChild) {
        this.listItemTouchStart(index, indexChild);
    },
    listItemTouchStart(index, indexChild) {
        if (this.selectType === 'batchSelect') { // Select contacts in batches
            this.$emit('checkChange', {
                contactIndex: index,
                numberIndex: indexChild,
                checked: this.searchLayoutShow ? !this.searchContactList[index].phoneNumbers[indexChild].checked
                                               : !this.contactList[index].phoneNumbers[indexChild].checked
            });
        } else { // The speed dial screen is displayed
            this.$emit('eventType', {
                index: index,
                indexChild: indexChild
            });
        }
    },

    editContacts(index) {
        this.$emit('contactsSelected', {
            contacts: this.contactList[index]
        });
    },
    requestItem() {
        // Data cache refresh
        this.$emit('requestItem', {});
    },
    changeCheckState: function (contactIndex, numberIndex, event) {
        this.$emit('checkChange', {
            contactIndex: contactIndex,
            numberIndex: numberIndex,
            checked: event.checked
        });
    }
};