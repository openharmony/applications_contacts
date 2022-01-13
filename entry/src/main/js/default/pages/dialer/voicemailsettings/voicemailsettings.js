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
var TAG = 'voicemailSettings';
export default {
    data: {
        voiceMailNumber: '',
        newNumberTemp:'',
        dialogInputActive: false,
    },

    onInit() {
        this.voiceMailNumber = this.$app.$def.globalData.storage.getSync('voicemailNumber',this.$t('value.callRecords.noSettings'));
        if (this.$t('value.callRecords.noSettings') != this.voiceMailNumber) {
            this.$app.$def.globalData.voicemailNumber = this.voiceMailNumber;
        }
    },
    onShow() {
        if (this.$app.$def.globalData.dialogShow == true) {
            setTimeout(() => {
                this.newNumberTemp = this.$app.$def.globalData.voicemailNumber;
            }, 200);
            setTimeout(() => {
                this.$element('editVoiceMailNumber').show();
            }, 500);
        }
    },
    onDestroy() {

    },
    copy(value){
        var newValue = value;
        return newValue;
    },
    back: function () {
        this.$app.$def.globalData.dialogShow = false;
        router.back();
    },
    selectContacts: function () {
        router.push({
            uri: 'pages/dialer/speeddial/selectcontact/selectcontact',
            params: {
                type: 'saveVoicemail',
            }
        });
    },
    changeStyle: function () {
        this.dialogInputActive = true;
    },

    editProvider:function() {
        this.$element('myProvider').show();
    },

    editVoiceNumber:function() {

        this.$element('editVoiceMailNumber').show();
        if (this.voiceMailNumber != this.$t('value.callRecords.noSettings')) {
            this.newNumberTemp = this.voiceMailNumber;
        }
    },
    cancelEdit: function () {
        this.$element('editVoiceMailNumber').close();
        this.newNumberTemp = this.voiceMailNumber;
        this.$app.$def.globalData.voicemailNumber = this.voiceMailNumber;
    },
    changeVoicemailNumber: function (e) {
        this.newNumberTemp = e.value;
    },
    confirmVoiceNumber:function() {
        this.voiceMailNumber = this.newNumberTemp; // Set number to new value
        this.$app.$def.globalData.storage.putSync('voicemailNumber',this.newNumberTemp);
        this.$app.$def.globalData.storage.flushSync();// Persistent storage of new numbers
        this.$element('editVoiceMailNumber').close();
    },
    cancelProvider:function() {
        this.$element('myProvider').close();
    },
    confirmProvider:function() {
        this.$element('myProvider').close();
    }

}