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
import callLogService from '../../../../default/model/CalllogModel.js';
import router from '@system.router';
import LOG from '../../../utils/ContactsLog.js';
import Constants from '../../../../default/common/constants/Constants.js';
import Utils from '../../../../default/utils/utils.js';

var TAG = 'callLogDelete...:';

export default {
    data: {
        callLogTemp: [],
        callLogMergeRule: '',
        ic_cancle_m: '/res/image/ic_cancel_m.svg',
        ic_delete_m: '/res/image/ic_delete_m.svg',
        ic_select_all: '/res/image/ic_select all_m.svg',
        titleMessage: '',
        totalCount: 0,
        selectCount: 0,
        allSelectMessage: '',
        allSelectTextStyle: 'batch-delete-text',
        deleteMessage: '',
        isSelectAll: false,
        selectAllClicked: false,
        deleteDisabled: true,
        refreshBatchDeleteLogId: 0,
        from_contact: ' from_contact',
        pageInfo: {
            pageIndex: 0,
            pageSize: 20,
        }
    },
    onInit() {
        LOG.info(TAG + 'onInit success')
        if (this.logIndex == 2) {// Voice mail
            this.totalCount = this.$app.$def.globalData.voicemailTotalData.voicemailCount;
        } else if (this.logIndex == 1) {
            this.totalCount = this.$app.$def.globalData.callLogTotalData.missedCount;
        } else {
            this.totalCount = this.$app.$def.globalData.callLogTotalData.totalCount;
        }
        this.callLogMergeRule = this.$app.$def.globalData.storage.getSync('call_log_merge_rule', 'from_time');
        this.getCallLog(this.pageInfo.pageIndex, this.pageInfo.pageSize);
        this.titleMessage = this.$t('value.callRecords.titleMessageNoSelect');
        this.allSelectMessage = this.$t('value.callRecords.selectAll');
        this.allSelectTextStyle = 'batch-delete-text';
    },
    onDestroy() {
        LOG.info(TAG + 'logMessage onDestroy calllogDelete');
    },

    clickSelectAll(e) {
        LOG.info(TAG + 'clickSelectAll e' + e.target);
        if (!this.isSelectAll) { // Select all
            this.selectAllClicked = true;
            this.selectAll();
        } else { // Click the deselect all button，
            this.selectAllClicked = false;
            this.unSelectAll();
        }
        this.refreshPageMessage();
    },

    checkStateChange(e) {
        LOG.info(TAG + 'checkStateChange e' + e.target);
        this.callLogTemp[e.detail.index].checked = e.detail.checked;
        this.selectCount = e.detail.checked ? this.selectCount + e.detail.num : this.selectCount - e.detail.num; // 若复选框选中，则计数加1，未选中则计数-1
        this.refreshPageMessage();
    },

    selectAll() {
        LOG.info('logMessage selectAll!!!');
        this.callLogTemp.forEach(element => {
            element.checked = true;
        });
        this.selectCount = this.totalCount;
    },


    unSelectAll() {
        this.callLogTemp.forEach(element => {
            element.checked = false;
        });
        this.selectCount = 0; // selectCount Clear
    },


    refreshPageMessage() {
        if (this.selectCount > 0) {
            this.titleMessage = this.$t('value.callRecords.titleMessageSelect') + this.selectCount +
            this.$t('value.callRecords.titleMessageUnit');
            this.deleteDisabled = false;
            if (this.selectCount == this.totalCount) { // Select all button status refresh
                this.ic_select_all = '/res/image/ic_select all_filled_m.svg';
                this.allSelectMessage = this.$t('value.callRecords.unSelectAll');
                this.allSelectTextStyle = 'batch-delete-text-selected';
                this.isSelectAll = true;

                this.deleteMessage = this.$t('value.callRecords.deleteMessageAsk') +
                this.$t('value.callRecords.deleteMessageAll') + this.$t('value.callRecords.deleteMessageCalls');
            } else {
                this.ic_select_all = '/res/image/ic_select all_m.svg';
                this.allSelectMessage = this.$t('value.callRecords.selectAll');
                this.allSelectTextStyle = 'batch-delete-text';
                this.isSelectAll = false;
                if (this.selectCount == 1) {

                    this.deleteMessage = this.$t('value.callRecords.deleteMessageAsk') +
                    this.$t('value.callRecords.deleteMessageThis') + this.$t('value.callRecords.deleteMessageCalls');
                } else {

                    this.deleteMessage = this.$t('value.callRecords.deleteMessageAsk') + this.selectCount +
                    this.$t('value.callRecords.deleteMessageUnit') + this.$t('value.callRecords.deleteMessageCalls');
                }
            }
        } else {
            this.selectCount = 0;
            this.ic_select_all = '/res/image/ic_select all_m.svg';
            this.allSelectMessage = this.$t('value.callRecords.selectAll');
            this.allSelectTextStyle = 'batch-delete-text';
            this.titleMessage = this.$t('value.callRecords.titleMessageNoSelect');
            this.deleteDisabled = true;
            this.isSelectAll = false;
        }
    },

    deleteCheckedCalls() {
        LOG.info('logMessage click delete !!!');
        this.$element('deleteCheckDialog').show(); // Show delete prompt box
    },
    doDelete() {
        if (this.isSelectAll && this.logIndex == 0) { // Select all to delete all call records
            this.callLogTemp = [];

            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
            callLogService.clearCallLog(DAHelper, () => {
                this.$app.$def.globalData.callLogTotalData.callLogList = [];
                this.$app.$def.globalData.callLogTotalData.missedList = [];
                this.$app.$def.globalData.callLogTotalData.totalCount = 0;
                this.$app.$def.globalData.callLogTotalData.missedCount = 0;
                router.back();
            });
        } else {
            if (this.logIndex == 2) { // Voice mail
                if (this.isSelectAll) { // Full deletion of voice mailbox
                    this.callLogTemp = [];
                    var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
                    callLogService.clearVoicemailList(DAHelper, () => {
                        this.$app.$def.globalData.voicemailTotalData.voicemailList = [];
                        this.$app.$def.globalData.voicemailTotalData.voicemailCount = 0;
                        router.back();
                    });
                } else { // Partial deletion of voice mailbox
                    this.doDeleteVoicemail();
                }
            } else {
                if (this.callLogMergeRule == this.from_contact) {
                    this.doDeleteByContactMerge();
                } else {
                    this.doDeleteByTimeMerge();
                }
            }
        }
        this.$element('deleteCheckDialog').close();
    },
    doDeleteVoicemail() {
        var unCheckedList = [];
        var voicemailIds = [];
        this.callLogTemp.forEach(element => {
            if (element.checked) { // Selected element
                voicemailIds.push(element.id);
            } else {
                unCheckedList.push(element);
            }
        });
        this.callLogTemp = unCheckedList;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
        callLogService.deleteVoicemailByIds(DAHelper, voicemailIds, ()=>{
            this.back();
        });
    },
    doDeleteByContactMerge() {
        var unCheckedList = [];
        var numberList = []; // Phone number used to store call records without contacts
        var contactIds = []; // QuickSearch for storing contact call records_ key(The contact ID)
        this.callLogTemp.forEach(element => {
            if (element.checked) { // Selected element
                if (Utils.isEmpty(element.contactKey)) {// Number has no associated contact
                    numberList.push(element.phone);
                } else { // The number is already associated with a contact
                    contactIds.push(element.contactKey);
                }
            } else {
                unCheckedList.push(element);
            }
        });
        this.callLogTemp = unCheckedList;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.deleteCallLogByNumbersOrContacts(DAHelper, numberList, contactIds, ()=>{
            LOG.info('logMessage delete call log by contacts or number callBack success!');
            this.back();
        });

    },
    doDeleteByTimeMerge() {
        var unCheckedList = [];
        var checkedList = [];
        var removeIds = [];
        this.callLogTemp.forEach(element => {
            if (element.checked) { // Selected element
                checkedList.push(element);
                if (!this.selectAllClicked || this.logIndex == 1) {
                    element.ids.forEach(elementId => {
                        removeIds.push(elementId);
                    });
                }
            } else {
                unCheckedList.push(element);
                if (this.selectAllClicked && this.logIndex != 1) {
                    element.ids.forEach(elementId => {
                        removeIds.push(elementId);
                    });
                }
            }
        });
        this.callLogTemp = unCheckedList;
        if (!this.selectAllClicked || this.logIndex == 1) {
            LOG.info('logMessage delete by ids:' + removeIds);
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
            callLogService.deleteCallLogByIds(DAHelper, removeIds, () => {
                LOG.info('logMessage delete call log callBack success!!!');
                this.back();
            });
        } else {
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
            callLogService.deleteOtherCallLog(DAHelper, removeIds, ()=>{
                LOG.info('logMessage delete other call log callBack success!!!');
                this.back();
            });
        }
    },
    cancelDialog() {
        this.$element('deleteCheckDialog').close();
    },
    back() {
        router.back();
    },
    requestLogByPage() {
        if (this.logIndex != 2) {
            this.pageInfo.pageIndex++;
        }
        this.getCallLog(this.pageInfo.pageIndex, this.pageInfo.pageSize);
    },
    getCallLog(pageIndex, pageSize) {
        var pageList = [];
        if (this.logIndex == 2) {// voiceMail
            pageList = this.callLogList;
        } else {
            pageList = callLogService.getCallLog(pageIndex, pageSize, this.callLogList);
        }
        if (this.selectAllClicked) { // Click Select all
            pageList.forEach((element) => {
                element.checked = true;
            });
        }
        LOG.info('logMessage batchDelete selectAllClicked = ');
        if (pageIndex == 0) {
            this.callLogTemp = pageList;
        } else {
            this.callLogTemp = this.callLogTemp.concat(pageList);
        }
    }
};
