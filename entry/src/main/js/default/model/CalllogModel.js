/**
 * @file: Call record model
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
import ohosDataAbility from '@ohos.data.dataability';
import Utils from '../../default/utils/utils.js';
import Constants from '../common/constants/Constants.js'
import LOG from '../utils/ContactsLog.js';
import telephony from '@ohos.telephony.call';

var TAG = 'calllogModel';

export const CALL_LOG_DB_COLUMNS = {
    ID: 'id', // Call History ID
    PHONE_NUMBER: 'phone_number', // The phone number
    CONTACT_NAME: 'display_name', // Contact Name
    CALL_TIME: 'create_time', // Time when call records are generated
    CALL_DIRECTION: 'call_direction', // Call type: 1 Incoming call, 2 Outgoing call, 3 missed call, 5 rejected call
    NUMBER_LOCATION: 'number_location', // Address of number
    SIM_ID: 'sim_type', // Call SIM card: 0: card 1, 1: card 2
    CALL_HD: 'is_hd', // Hd call True: HD call false: non-HD call
    FORMAT_NUMBER: 'format_number', // Formatting a phone number
    IS_READ: 'is_read', // Have read
    RING_TIME: 'ring_duration', // The ring time
    TALK_TIME: 'talk_duration', // duration
    CONTACT_KEY: 'quicksearch_key', // The contact ID
    ANSWER_STATE: 'answer_state',
    VOICE_MAIL_URI: 'voicemail_uri', // Voice mail related
}
export const ANSWER_STATE = {
    MISSED_CALLS : 0, // Did not get through
    RECEIVED_CALLS : 1, // Has been switched on
    REJECT_CALLS: 2 // reject
}
export const CALL_DIRECTION = {
    CALL_IN: 0, // inbound
    CALL_OUT: 1 // Breathe out
}
export const CALL_LOG_TYPE = {
    CALL_LOG_IN: 1, // inbound
    CALL_LOG_OUT: 2, // Breathe out
    CALL_LOG_VOICEMAIL: 4, // voicemail
    CALL_LOG_MISSED_CALLS: 3, // Don't answer
    CALL_LOG_REJECTED: 5, // reject
}
export default {

    /**
     * Obtain the full number of call records (2000) and cache them
     *
     * @param {string} DAHelper Database path
     * @param {string} mergeRule  Call Record Type
     * @param {Object} callBack Call log data
     */
    getAllCalls:async function(DAHelper, mergeRule, callBack) {
        // The returned dataset field
        var resultColumns = [
            CALL_LOG_DB_COLUMNS.ID,
            CALL_LOG_DB_COLUMNS.PHONE_NUMBER,
            CALL_LOG_DB_COLUMNS.CONTACT_NAME,
            CALL_LOG_DB_COLUMNS.CALL_TIME,
            CALL_LOG_DB_COLUMNS.CALL_DIRECTION,
            CALL_LOG_DB_COLUMNS.NUMBER_LOCATION,
            CALL_LOG_DB_COLUMNS.SIM_ID,
            CALL_LOG_DB_COLUMNS.CALL_HD,
            CALL_LOG_DB_COLUMNS.RING_TIME,
            CALL_LOG_DB_COLUMNS.TALK_TIME,
            CALL_LOG_DB_COLUMNS.ANSWER_STATE,
            CALL_LOG_DB_COLUMNS.FORMAT_NUMBER,
            CALL_LOG_DB_COLUMNS.CONTACT_KEY
        ];
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.limitAs(2000).orderByDesc(CALL_LOG_DB_COLUMNS.CALL_TIME).offsetAs(0);
        var resultData = {};
        var resultSet = await DAHelper.query(Constants.uri.CALL_LOG_URI, resultColumns, condition);
        if(Utils.isEmpty(resultSet) || resultSet.rowCount == 0){
            LOG.info(TAG + 'getAllCalls' + 'logMessage callLog resultSet is empty!');
            resultData.callLogList = [];
            resultData.missedList = [];
            resultData.totalCount = 0;
            resultData.missedCount = 0;
            callBack(resultData);
            return;
        }
        resultSet.goToFirstRow();
        var callLogList = [];
        var missedList = [];
        do{
            var callLogItem = {};
            callLogItem.id = resultSet.getString(0);
            callLogItem.phone = resultSet.getString(1);
            callLogItem.name = resultSet.getString(2);
            callLogItem.callTime = resultSet.getString(3);
            callLogItem.callType = this.getCallLogType(resultSet.getString(4),
                resultSet.getString(10));// param: call_direction, answer_state
            callLogItem.callTag = resultSet.getString(5);
            callLogItem.simType = resultSet.getString(6);
            callLogItem.isHd = resultSet.getString(7);
            var formattedNumber = resultSet.getString(1);
            try{
                formattedNumber = await telephony.formatPhoneNumber(resultSet.getString(1));
            }catch{
                formattedNumber = resultSet.getString(1);
            }
            callLogItem.formatNumber = formattedNumber;
            callLogItem.contactKey = resultSet.getString(12); // Id of a contact associated with call records
            callLogList.push(callLogItem);
            if (callLogItem.callType == CALL_LOG_TYPE.CALL_LOG_MISSED_CALLS ||
            callLogItem.callType == CALL_LOG_TYPE.CALL_LOG_REJECTED) {
                missedList.push(callLogItem);// Filter missed call data
                let timeList = [];
                if (mergeRule == 'from_contact') { // Filter calls by missed calls and redial calls
                    for (var k = 0; k <  missedList.length; k++) {
                        let missedPhone = missedList[k].phone;
                        for (var i = 0; i < callLogList.length; i++) {
                            let allSpecialPhone = callLogList[i].phone;
                            if (missedPhone == allSpecialPhone ) {
                                let time = callLogList[i].callTime;
                                let timeNumber = parseInt(time);
                                let obj = {
                                    'id': i,
                                    'timeObj': timeNumber,
                                };
                                timeList.push(obj);
                                let max = timeList[0].timeObj;
                                for (var j = 0; j < timeList.length; j++) {
                                    if (timeList[j].timeObj > max) {
                                        max = timeList[j].timeObj;
                                        let n = timeList[j].id;
                                        if (callLogList[n].callType == CALL_LOG_TYPE.CALL_LOG_OUT) {
                                            missedList.splice(k,1);
                                        }
                                    } else {
                                        let m = timeList[0].id
                                        if (callLogList[m].callType == CALL_LOG_TYPE.CALL_LOG_OUT) {
                                            missedList.splice(k,1);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } while(resultSet.goToNextRow());
        if (mergeRule == 'from_contact') {
            resultData.callLogList = this.fillCallLogDataMergeByContact(callLogList);
            resultData.missedList = this.fillCallLogDataMergeByContact(missedList);
            resultData.totalCount = resultData.callLogList.length;
            resultData.missedCount = resultData.missedList.length;
        } else {
            resultData.callLogList = this.fillCallLogDataMergeByTime(callLogList);
            resultData.missedList = this.fillCallLogDataMergeByTime(missedList);
            resultData.totalCount = resultSet.rowCount;
            resultData.missedCount = missedList.length;
        }
        resultSet.close();
        callBack(resultData);
    },

    /**
     * Gets the voice mailbox list
     *
     * @param {string} DAHelper Database path
     * @param {Object} callBack Voicemail list
     */
    getVoicemailList: async function(DAHelper, callBack) {
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.orderByDesc('create_time');
        var resultColumns = [
            'id',
            'phone_number',
            'display_name',
            'voicemail_uri',
            'voicemail_type',
            'voice_file_size',
            'voice_duration',
            'voice_status',
            'origin_type',
            'create_time',
        ];
        var resultSet = await DAHelper.query(Constants.uri.VOICEMAIL_URI, resultColumns, condition);
        var voicemailList = [];
        if (Utils.isEmpty(resultSet) || resultSet.rowCount == 0) {
            callBack(voicemailList);
            LOG.error(TAG + 'getVoicemailList' + 'logMessage voicemailList is empty! resultSet = ' + resultSet);
            return;
        }
        resultSet.goToFirstRow();
        do{
            var voicemailItem = {};
            voicemailItem.id = resultSet.getString(0);
            voicemailItem.phone = resultSet.getString(1);
            voicemailItem.name = resultSet.getString(2);
            voicemailItem.uri = resultSet.getString(3); // voicemail_uri
            voicemailItem.callTime = this.getCallTime(resultSet.getString(9)); // create_time
            voicemailItem.callType = CALL_LOG_TYPE.CALL_LOG_VOICEMAIL;// param: call_direction, answer_state
            voicemailItem.callTag = resultSet.getString(4); // voicemail_type
            try{
                voicemailItem.formatNumber = await telephony.formatPhoneNumber(resultSet.getString(1));
            }catch{
                voicemailItem.formatNumber = resultSet.getString(1);
            }
            voicemailItem.timeDuration = resultSet.getString(6);
            voicemailItem.voicemailDuration = this.getTimeString(resultSet.getString(6)) // voice_duration
            voicemailItem = this.fillServiceProperty(voicemailItem);
            voicemailList.push(voicemailItem);
        } while(resultSet.goToNextRow());
        resultSet.close();
        callBack(voicemailList);
    },

    /**
     * Generates a string of type 00:00 based on the number of seconds given
     *
     * @param {number} secondsString A period of voicemail
     * @return {string} The time of voice mail playback
     */
    getTimeString(secondsString) {
        var timeString = '00:00';
        var seconds= parseInt(secondsString);
        if (seconds > 60) {
            var minutes = parseInt(seconds/60);
            timeString = (minutes < 10 ? ('0'+minutes) : minutes)+':'
            +((seconds%60) < 10 ? ('0'+(seconds%60)) : (seconds%60));
        } else {
            timeString = '00:'+(seconds < 10 ? ('0'+seconds) : seconds);
        }
        return timeString;
    },

    /**
     * Obtain the call record type
     *
     * @param {string} callDirection Call type
     * @param {string} answerState  Whether the call is connected
     * @return {string} Exhale type
     */
    getCallLogType(callDirection, answerState) {
        if (callDirection == CALL_DIRECTION.CALL_IN) {
            if (answerState == ANSWER_STATE.RECEIVED_CALLS) {
                return CALL_LOG_TYPE.CALL_LOG_IN;
            }
            if (answerState == ANSWER_STATE.MISSED_CALLS) {
                return CALL_LOG_TYPE.CALL_LOG_MISSED_CALLS
            }
            if (answerState == ANSWER_STATE.REJECT_CALLS) {
                return CALL_LOG_TYPE.CALL_LOG_REJECTED;
            }
        } else {
            return CALL_LOG_TYPE.CALL_LOG_OUT;
        }
    },

    /**
     * Page to obtain the call history list
     *
     * @param {number} pageIndex Page index
     * @param {number} pageSize  How many pieces of data on a page
     * @param {Array} callLogList  Call history list
     * @return {Array} Call history list
     */
   getCallLog:function(pageIndex, pageSize, callLogList) {
       var tempList = [];
       if (Utils.isEmptyList(callLogList)) {
           return [];
       }
       var length = callLogList.length;
       if (length > (pageIndex+1)*pageSize) {
           for (var i = pageIndex * pageSize; i < (pageIndex+1)*pageSize; i++) {
               tempList.push(callLogList[i]);
           }
       } else {
           for (var i = pageIndex * pageSize; i < length; i++) {
               tempList.push(callLogList[i]);
           }
       }
       return tempList;
   },

    /**
     * Obtain all call records of these numbers based on the phone number array for displaying call record details
     *
     * @param {string} DAHelper Database path
     * @param {Array} phoneNumbers The phone number
     * @param {Object} callBack The callback
     */
    async getCallLogListByPhoneNumber(DAHelper, phoneNumbers, callBack) {
        if (Utils.isEmptyList(phoneNumbers)) {
            return [];
        }
        var realPhoneNumbers = [];
        for (var i = 0; i < phoneNumbers.length; i++) {
            realPhoneNumbers.push(Utils.removeSpace(phoneNumbers[i]));
        }
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(CALL_LOG_DB_COLUMNS.PHONE_NUMBER, realPhoneNumbers).orderByDesc(CALL_LOG_DB_COLUMNS.CALL_TIME);
        var resultColumns = [
            CALL_LOG_DB_COLUMNS.ID,
            CALL_LOG_DB_COLUMNS.PHONE_NUMBER,
            CALL_LOG_DB_COLUMNS.CONTACT_NAME,
            CALL_LOG_DB_COLUMNS.CALL_TIME,
            CALL_LOG_DB_COLUMNS.CALL_DIRECTION,
            CALL_LOG_DB_COLUMNS.NUMBER_LOCATION,
            CALL_LOG_DB_COLUMNS.SIM_ID,
            CALL_LOG_DB_COLUMNS.CALL_HD,
            CALL_LOG_DB_COLUMNS.RING_TIME,
            CALL_LOG_DB_COLUMNS.TALK_TIME,
            CALL_LOG_DB_COLUMNS.ANSWER_STATE,
            CALL_LOG_DB_COLUMNS.FORMAT_NUMBER
        ];
        var resultSet = await DAHelper.query(Constants.uri.CALL_LOG_URI, resultColumns, condition);
        var resultList = [];
        if(Utils.isEmpty(resultSet) || resultSet.rowCount == 0){
            callBack(resultList);
            return;
        }
        resultSet.goToFirstRow();
        do{
            var callLogItem = {};
            callLogItem.id = resultSet.getString(0);
            callLogItem.phone = resultSet.getString(1);
            callLogItem.name = resultSet.getString(2);
            callLogItem.callTime = resultSet.getString(3);
            callLogItem.callType = this.getCallLogType(resultSet.getString(4),
                resultSet.getString(10));// param: call_direction, answer_state
            callLogItem.callTag = resultSet.getString(5);
            callLogItem.simType = resultSet.getString(6);
            callLogItem.isHd = resultSet.getString(7);
            callLogItem.ringTime = resultSet.getString(8);
            callLogItem.talkTime = resultSet.getString(9);
            var formattedNumber = resultSet.getString(1);
            try{
                formattedNumber = await telephony.formatPhoneNumber(resultSet.getString(1));
            }catch{
                formattedNumber = resultSet.getString(1);
            }
            callLogItem.formatNumber = formattedNumber;
            resultList.push(callLogItem);
        } while(resultSet.goToNextRow());
        resultSet.close();
        callBack(resultList);
    },

    /**
     * Clearing Call History
     *
     * @param {string} DAHelper Database path
     * @param {Object} callBack
     */
    clearCallLog(DAHelper, callBack) {
        var condition = new ohosDataAbility.DataAbilityPredicates();
        DAHelper.delete(Constants.uri.CALL_LOG_URI, condition).then(data=>{
        callBack();
        }).catch(error=>{
            LOG.error(TAG + 'clearCallLog' + 'logMessage delete call log error:' + error);
        });
    },

    /**
     * Clearing voice Mail
     *
     * @param {string} DAHelper Database path
     * @param {Object} callBack
     */
    clearVoicemailList(DAHelper, callBack) {
        var condition = new ohosDataAbility.DataAbilityPredicates();
        DAHelper.delete(Constants.uri.VOICEMAIL_URI, condition).then(data=>{
            callBack();
        }).catch(error=>{
            LOG.error(TAG + 'clearVoicemailList' + 'logMessage delete call log error:' + error);
        });
    },

    /**
     * In the contact merge case, you can delete call records by phone number or contact ID
     *
     * @param {string} DAHelper Database path
     * @param {Array} phoneNumbers
     * @param {number} contactKeys The contact ID
     * @param {Object} callBack
     */
    deleteCallLogByNumbersOrContacts:async function(DAHelper, phoneNumbers, contactKeys, callBack) {
        var condition = new ohosDataAbility.DataAbilityPredicates();
        if (!Utils.isEmptyList(phoneNumbers)) {
            condition = condition.in(CALL_LOG_DB_COLUMNS.PHONE_NUMBER, phoneNumbers);
        }
        if (!Utils.isEmptyList(phoneNumbers) && !Utils.isEmptyList(contactKeys)) {
            condition = condition.or();
        }
        if (!Utils.isEmptyList(contactKeys)) {
            condition = condition.in(CALL_LOG_DB_COLUMNS.CONTACT_KEY, contactKeys);
        }
        await DAHelper.delete(Constants.uri.CALL_LOG_URI, condition);
        callBack();
    },

    /**
     * Delete specified call records by ID
     *
     * @param {string} DAHelper Database path
     * @param {Array} ids  The contact ID
     * @param {Object} callBack
     */
    deleteCallLogByIds: async function (DAHelper, ids, callBack) {
        if (Utils.isEmptyList(ids)) {
            return;
        }
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(CALL_LOG_DB_COLUMNS.ID, ids);
        await DAHelper.delete(Constants.uri.CALL_LOG_URI, condition);
        callBack();
    },

    /**
     * Delete specified voice mailbox records by ID
     *
     * @param {string} DAHelper Database path
     * @param {Array} ids  The contact ID
     * @param {Object} callBack
     */
    deleteVoicemailByIds: async function (DAHelper, ids, callBack) {
        if (Utils.isEmptyList(ids)) {
            return;
        }
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in('id', ids);
        await DAHelper.delete(Constants.uri.VOICEMAIL_URI, condition);
        callBack();
    },

    /**
     * Deletes records other than the specified IDS
     *
     * @param {string} DAHelper Database path
     * @param {Array} ids  The contact ID
     * @param {Object} callBack
     */
    deleteOtherCallLog(DAHelper, ids, callBack) {
        if (Utils.isEmptyList(ids)) {
            return;
        }
        var condition = new ohosDataAbility.DataAbilityPredicates();
        for (var index = 0; index < ids.length; index++) {
            condition = condition.notEqualTo('id',ids[index]);
        }
        DAHelper.delete(Constants.uri.CALL_LOG_URI, condition).then(data=>{
            LOG.info(TAG + 'deleteOtherCallLog' + 'logMessage delete call log by other ids success!!! data:'+data);
            callBack();
        }).catch(error=>{
            LOG.error(TAG + 'deleteOtherCallLog' + 'logMessage delete call log error:' + error);
        });
    },

    /**
     * In the case of merging by contact, improve the post-processing of call record service data based on the original call record data
     *
     * @param {Array} callLogList
     * @return {Array} Call records
     */
    fillCallLogDataMergeByContact: function(callLogList) {
        var resultList = [];
        if (Utils.isEmptyList(callLogList)) {
            return resultList;
        }
        var contactTempMap = new Map();
        var phoneNumberMap = new Map();
        for (var i = 0; i < callLogList.length; i++) {
            var element = this.fillServiceProperty(callLogList[i]);
            element.callTime = this.getCallTime(callLogList[i].callTime);
            element.num = 1; // In the case of contact merge, the merged record entry is fixed as 1
            element.ids = [element.id]; // In the case of contact merging, the ids of the merged record is its own ID
            if (Utils.isEmpty(element.contactKey)) { // If there is no call record of the contact, merge it by phone number
                if (!phoneNumberMap.has(element.phone)) {
                    resultList.push(element);
                    phoneNumberMap.set(element.phone);
                }
            } else { // If contact call records exist, merge calls based on contacts
                let isContactKey = contactTempMap.has(element.contactKey);
                if (!isContactKey) {
                    resultList.push(element);
                    contactTempMap.set(element.contactKey);
                }
            }
        }
        return resultList;
    },

    /**
     * In the case of time consolidation, improve the post-processing of call record service data based on the original call record data
     *
     * @param callLogList
     * @return
     */
    fillCallLogDataMergeByTime: function(callLogList) {
        var resultList = [];
        if (Utils.isEmptyList(callLogList)) {
            return resultList;
        }
        var tempElement = this.fillServiceProperty(callLogList[0]); // Caches call records starting from the first record
        var tempCallTime = tempElement.callTime; // Retain the creation time of the last call record and display the time after the call record is merged.
        var tempCallType = tempElement.callType; // The type of the latest call record is saved and displayed after the call record is merged.
        var num = 1;
        var ids = [];
        ids.push(callLogList[0].id);
        for (var i = 1; i < callLogList.length; i++) {
            var element = callLogList[i];
            if(this.callLogMergeCheck(tempElement, element)) {// Check whether the cache field needs to be merged with the current field
                num++;
                ids.push(element.id);// Puts the latest record ID into the merge array
            } else {
                tempElement.num = num;
                tempElement.ids = ids;
                tempElement.callTime = this.getCallTime(tempCallTime); // Displays the creation time of the last saved record
                tempElement.callType = tempCallType;
                resultList.push(tempElement);
                num = 1;
                ids = [];
                tempCallTime = element.callTime;
                tempCallType = element.callType;
                ids.push(element.id);
            }
            tempElement = this.fillServiceProperty(element);
        }
        if (tempElement != null) {
            tempElement.num = num;
            tempElement.ids = ids;
            tempElement.callTime = this.getCallTime(tempCallTime);
            tempElement.callType = tempCallType;
            resultList.push(tempElement);
        }
        return resultList;
    },

    /**
     * To verify whether two call records need to be merged by time, return true if the call records need to be merged; otherwise return false
     *
     * @param oldElement Merge call records before
     * @param newElement Merged call records
     * @return
     */
    callLogMergeCheck:function(oldElement, newElement){
        if (oldElement.phone.trim() == newElement.phone.trim()) {
            if (oldElement.callType == 1||oldElement.callType == 2) {
                if (newElement.callType == 1 || newElement.callType ==2) {
                    return true;
                }
                return false;
            }
            if (newElement.callType == 3 || newElement.callType == 5) {
                return true;
            }
        }
        return false;
    },

    /**
     * Add data attributes required by the business
     *
     * @param element Call records
     * @return
     */
    fillServiceProperty:function (element) {
        element.leftDst = 0;
        element.checked = false;
        if (element.callType == CALL_LOG_TYPE.CALL_LOG_VOICEMAIL) {
            element.showMail = false;
            element.start = '00:00';
            element.percent = 0;
            element.playState = 'start';
            element.volumeState = 'volume';
            element.percentProgress = 0;
            element.ids = [element.id];
            element.num = 1;
        }
        return element;
    },

    /**
     * Get talk time
     *
     * @param date Call record creation time stamp
     * @return {object} Talk time
     */
    getCallTime(date) {
        let result = "";
        if (isNaN(date)) { // If the value is not a number, it is not parsed
            return date;
        }
        var timestamp = parseInt(date)*1000;
        let callTime = new Date(timestamp);
        let now = new Date();
        if (callTime.getTime() > now.getTime()) {
            result = callTime.getFullYear() + '/' + (callTime.getMonth()+1) + '/' + callTime.getDate();
        } else if (callTime.getFullYear() == now.getFullYear()) {
            if (callTime.getMonth() == now.getMonth()) {
                let timeDiff = parseInt((now.getTime() - callTime.getTime()) / 60000);
                let dayDiff = now.getDate() - callTime.getDate();
                if (dayDiff == 0) {
                    if (timeDiff == 0) {
                        result = this.$t('recordDetail.language.justNow');
                    } else if (timeDiff < 60) {
                        result = timeDiff + this.$t('recordDetail.language.minutesAgo');
                    } else {
                        result = callTime.getHours()
                        + ':' + (callTime.getMinutes() < 10 ? '0' + callTime.getMinutes() : callTime.getMinutes());
                    }
                } else if (dayDiff == 1) {
                    result = this.$t('recordDetail.language.yesterday');
                } else {
                    result = (callTime.getMonth()+1) + '/' + callTime.getDate();
                }
            } else {
                result = (callTime.getMonth()+1) + '/' + callTime.getDate();
            }
        } else {
            result = callTime.getFullYear() + '/' + (callTime.getMonth()+1) + '/' + callTime.getDate();
        }
        return result;
    }
}
