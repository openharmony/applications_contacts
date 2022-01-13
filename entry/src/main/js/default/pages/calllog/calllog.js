/**
 * @file: Call records
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
import LOG from '../../utils/ContactsLog.js';

var TAG = 'callLog';

export default {
    props: ['allCalls', 'batchDelete', 'missedCallLogs', 'voicemailList', 'singleCardMode', 'showVoicemail'],
    data: {
        voicemailIntervalId: 0,
        tabIndex: 0,
        lastVoicemailDetailIndex: -1,
        showTabTitle: false,
        isFirstTop: true,

        icContactsCallIn: '/res/image/ic_contacts_call_in_mini.svg',
        icContactsCallMissed: '/res/image/ic_contacts_call_missed_mini.svg',
        icContactsCallRejected: '/res/image/ic_contacts_call_rejected_mini.svg',
        icContactsCallOut: '/res/image/ic_contacts_callout_mini.svg',
        icContactsVoicemailMini: '/res/image/ic_contacts_voicemail_mini.svg',
        icContactsSim1: '/res/image/ic_contacts_sim_1_mini.svg',
        icContactsSim2: '/res/image/ic_contacts_sim_2_mini.svg',
        icContactsHd: '/res/image/ic_contacts_HD_mini.svg',
        icDetailPublic: '/res/image/ic_public_about_m.svg',
        icContactsEmptyCallLog: '/res/image/ic_contacts_empty_calllog_72.svg',
        icContactsEmptyVoicemail: '/res/image/ic_contacts_empty_voicemaile_72.svg',
        icDeleteM: '/res/image/ic_delete_white.svg',

        icVoicemailPlay: '/res/image/ic_play_filled_m.svg',
        icVoicemailPause: '/res/image/ic_contacts_pause voicemail_m.svg',
        icVoicemailVolume: '/res/image/ic_volume_m.svg',
        icVoicemailEarpiece: '/res/image/ic_contacts_Earpiece_m.svg',
        icVoicemailMessage: '/res/image/ic_massage_m.svg',
        icVoicemailPhone: '/res/image/ic_phonecall_m_block.svg',
        icVoicemailDelete: '/res/image/ic_delete_m.svg',

        useCheckBox: true,
        checked: true,

        needSmallTitle: true,
        touchMoveData: {
            touchStartX: 0,
            touchStartY: 0,
            lastFrameX: 0,
            lastFrameY: 0,
            isTouchMove: false
        },
        listAnimateId: 0,

        callMenuData: {
            index: '',
            itemId: [],
            name: '',
            number: ''
        },

        showMenuTimeOutId: '',
        contactCount: 0,
        contacts: [],
        numRecords: []
    },
    onInit() {
        LOG.info(TAG + 'onInit' + 'logMessage: onInit calllog: length = ' + this.allCalls.length);
        this.$app.$def.globalData.refreshFunctions.push(() => {
            LOG.info(TAG + 'onInit' + 'logMessage callBack callLog!');
            if (this.$app.$def.dialerStateData.isGoToMissedCalls) {
                this.tabIndex = 1;
                this.showTabTitle = true;
                this.$app.$def.dialerStateData.isGoToMissedCalls = false;
            }
        });
        this.useCheckBox = this.batchDelete;
    },
    onShow() {
        this.isFirstTop = true;
    },
    onDestroy() {
        LOG.info(TAG + 'onDestroy' + 'logMessage onDestroy callLog!');
        this.$app.$def.globalData.refreshFunctions.pop();
    },

    /**
     * Play or pause
     *
     * @param {number} index
     */
    startOrPause: function (index) {
        LOG.info(TAG + 'startOrPause' + 'logMessage startOrPause index = ' + index);
        if (this.voicemailList[index].playState == 'start') {
            this.voicemailIntervalId = setInterval(() => {
                this.voicemailList[index].percentProgress += 1;
                if (this.voicemailList[index].percentProgress % 10 == 0) {
                    var displayValue = this.voicemailList[index].percentProgress / 10;
                    this.voicemailList[index].start = displayValue < 10 ? '00:0' + displayValue : '00:' + displayValue;
                }
                this.voicemailList[index].percent = parseInt(parseFloat(this.voicemailList[index].percentProgress)
                / parseFloat(this.voicemailList[index].timeDuration) * 10, 10);

                if (this.voicemailList[index].percentProgress
                == this.voicemailList[index].timeDuration * 10) {
                    clearInterval(this.voicemailIntervalId);
                    this.voicemailList[index].playState = 'start';
                    this.voicemailList[index].start = '00:00';
                    this.voicemailList[index].percentProgress = 0;
                    this.voicemailList[index].percent = 0;
                }
            }, 100);
            this.voicemailList[index].playState = 'pause';
        } else {
            clearInterval(this.voicemailIntervalId);
            this.voicemailList[index].playState = 'start';
        }
        LOG.info(TAG + 'onInit' + 'logMessage startOrPause voicemailList = ' + this.voicemailList);
    },

    /**
     * Change the volume
     *
     * @param {number} index
     */
    changeVolume: function (index) {
        LOG.info(TAG + 'changeVolume' + 'logMessage changeVolume index = ' + index);
        if (this.voicemailList[index].volumeState == 'volume') {
            this.voicemailList[index].volumeState = 'earpiece';
        } else {
            this.voicemailList[index].volumeState = 'volume';
        }
        LOG.info(TAG + 'onInit' + 'logMessage startOrPause voicemailList = ' + this.voicemailList);
    },
    deleteVoicemail() {
        this.$element('deleteDialog').show();
    },
    sendMessageByLog() {
        var params = [];
        params.push({
            contactsName: this.callMenuData.name,
            telephone: this.callMenuData.number.replace(' ', '').replace(' ', ''),
            telephoneFormat: this.callMenuData.number,
        });
        this.$app.$def.sendMessage(params);
    },
    editBeforeByLog() {
        this.$emit('editCall', {
            number: this.callMenuData.number,
        });
    },

    /**
     * Click on a voicemail message
     *
     * @param {number} index
     */
    clickVoicemailMessage: function (index) {
        this.callMenuData.index = index;
        this.callMenuData.itemId = this.voicemailList[index].ids;
        this.callMenuData.name = this.voicemailList[index].name;
        this.callMenuData.number = this.voicemailList[index].formatNumber;
        if (this.lastVoicemailDetailIndex != -1 && this.lastVoicemailDetailIndex != index) {
            this.voicemailList[this.lastVoicemailDetailIndex].showMail = false;
            this.voicemailList[this.lastVoicemailDetailIndex].start = '00:00';
            this.voicemailList[this.lastVoicemailDetailIndex].percent = 0;
            this.voicemailList[this.lastVoicemailDetailIndex].percentProgress = 0;
        }
        this.voicemailList[index].showMail = !this.voicemailList[index].showMail;
        if (this.voicemailList[index].showMail) {
            this.lastVoicemailDetailIndex = index;
        } else {
            this.lastVoicemailDetailIndex = -1;
        }
    },

    /**
     * Example Delete a single call record
     *
     * @param {number} index
     */
    deleteSingleLog: function (index) {
        var tempList = [];
        if (this.tabIndex == 2) {
            tempList = this.voicemailList;
        } else if (this.tabIndex == 1) {
            tempList = this.missedCallLogs;
        } else {
            tempList = this.allCalls;
        }
        this.$emit('deleteSingleCall', {
            id: tempList[index].ids,
            phoneNumber: [tempList[index].phone],
            contactKey: [tempList[index].contactKey],
            tabIndex: this.tabIndex
        });

    },

    /**
     * In the case of batch deletion, click a call record to select or deselect the check box. In the case of non-batch deletion, dial the call based on card 1 and card 2
     *
     * @param {number} index
     * @param {number} type
     * @param {number} e
     */
    callLogProcess(index, type, e) {
        if (this.batchDelete) {
            var checked = !this.allCalls[index].checked;
            this.changeCheckState(index, {
                'checked': checked
            });

        } else {
            this.$emit('callProcess', {
                number: Number(type) === 0 ? this.allCalls[index].formatNumber
                                           : this.missedCallLogs[index].formatNumber,
            });
        }
    },

    listScrollTop() {
        if (!this.batchDelete) {
            this.showTabTitle = true;
            this.needSmallTitle = true;
            this.$emit('changeTitle', {
                type: 0
            });
        }
    },

    listScrollBottom() {
        this.showTabTitle = false;
    },
    listScroll(e) {
        if (this.isFirstTop && e.scrollY < 0 && !this.batchDelete) {
            this.showTabTitle = true;
            this.isFirstTop = false;
        }
    },

    /**
     * Display specific call history details
     *
     * @param {number} id
     * @param {Object} e
     */
    showRecordDetails: function (id, e) {
        this.$emit('showDetails', {
            logIndex: id,
            tabIndex: this.tabIndex
        });
    },

    /**
     * Change the selected state
     *
     * @param {number} index
     * @param {Object} e
     */
    changeCheckState(index, e) {
        this.$emit('changeChecked', {
            checked: e.checked,
            index: index,
            num: this.allCalls[index].num
        });
    },

    /**
     * Select the call
     *
     * @param {number} index
     */
    selectCall(index) {
        this.$emit('checkCall', {
            id: this.allCalls[index].id,
            index: index
        });
    },
    requestCallLog() {
        this.$emit('requestLog', {});
    },
    requestMissedCalls() {
        this.$emit('requestMissed', {});
    },

    /**
     * Start touching the Call List child event
     *
     * @param {number} index
     * @param {Object} e
     */
    touchStartListItemDiv(index, e) {
        if (this.batchDelete) {
            return;
        }
        LOG.info(TAG + 'touchStartListItemDiv' + 'logMessage touchStartListItemDiv : ' + e);
        this.touchMoveData.touchStartX = e.touches[0].globalX;
        this.touchMoveData.touchStartY = e.touches[0].globalY;
        this.$emit('itemTouchStart', {
            index: index,
            positionX: e.touches[0].globalX,
            positionY: e.touches[0].globalY,
        });
    },

    /**
     * Slide the call List child event
     *
     * @param {number} index
     * @param {Object} e
     */
    touchMoveListItem(index, e) {
        if (this.batchDelete) {
            return;
        }
        this.$emit('itemTouchMove', {
            index: index,
            positionX: e.touches[0].globalX,
            positionY: e.touches[0].globalY,
        });
    },

    /**
     * End touch Call List child event
     *
     * @param {number} index
     * @param {Object} e
     */
    touchEndListItem(index, e) {
        if (this.batchDelete) {
            return;
        }
        this.$emit('itemTouchEnd', {
            index: index,
            positionX: e.changedTouches[0].globalX,
            positionY: e.changedTouches[0].globalY,
        });
    },

    /**
     * Long press to display a single record menu item
     *
     * @param {number} index
     * @param {number} type
     */
    showCallMenu(index, type) {
        if (this.batchDelete) {
            return;
        }
        if (type == 2) {
            this.callMenuData.index = index;
            this.callMenuData.itemId = this.voicemailList[index].ids;
            this.callMenuData.name = this.voicemailList[index].name;
            this.callMenuData.number = this.voicemailList[index].formatNumber;
        } else if (type == 1) {
            this.callMenuData.index = index;
            this.callMenuData.itemId = this.missedCallLogs[index].ids;
            this.callMenuData.name = this.missedCallLogs[index].name;
            this.callMenuData.number = this.missedCallLogs[index].formatNumber;
        } else {
            this.callMenuData.index = index;
            this.callMenuData.itemId = this.allCalls[index].ids;
            this.callMenuData.name = this.allCalls[index].name;
            this.callMenuData.number = this.allCalls[index].formatNumber;
        }
        var tempX = this.touchMoveData.touchStartX;
        var tempY = this.touchMoveData.touchStartY;

        if (this.touchMoveData.touchStartX > 360) {
            tempX = 360;
        }
        if (this.callMenuData.name == '' || this.callMenuData.name == undefined) {
            if ((tempX > 320 && tempX < 330) && tempY > 450) {
                tempY = 450;
            } else if (tempX < 320 && tempY > 510) {
                tempY = 510;
            } else if (tempY > 420) {
                tempY = 420;
            }
        } else {
            tempY = tempY > 700 ? 700 : tempY;
        }
        clearTimeout(this.showMenuTimeOutId);

        this.showMenuTimeOutId = setTimeout(() => {
            this.$element('callLogMenu').show({
                x: tempX,
                y: tempY
            });
        }, 100);
    },

    /**
     * Long press the menu item to process each operation
     *
     * @param {Object} e
     */
    onCallMenuSelected(e) {
        switch (parseInt(e.value, 10)) {
            case 1:
                router.push({
                    uri: 'pages/contacts/accountants/accountants',
                    params: {
                        phoneNumbers: [
                            {
                                'labelId': 2,
                                'labelName': this.$t('accountants.phone'),
                                'phoneNumber': this.callMenuData.number,
                                'phoneAddress': 'N',
                                'showP': true,
                                'blueStyle': true
                            }
                        ]
                    },
                });
                break;
            case 2:
                router.push({
                    uri: 'pages/contacts/selectContactsList/selectContactsList',
                    params: {
                        type: 'saveContacts',
                        number: this.callMenuData.number,
                    }
                });
                break;
            case 3:
                this.sendMessageByLog();
                break;
            case 4:
                this.$emit('copyNumber', {
                    number: this.callMenuData.number
                });
                break;
            case 5: // Pre-call editing
                this.$emit('editCall', {
                    number: this.callMenuData.number,
                });
                break;
            case 6: // Add to the blacklist
                break;
            case 7: // Deleting Call History
                this.$element('deleteDialog').show();
                break;
            default:
                break;
        }
    },
    doDelete() {
        this.$emit('removeCall', {
            id: this.callMenuData.itemId,
            index: this.callMenuData.index
        });
    },

    /**
     * Monitor the sliding distance to determine whether the dial needs to be hidden
     *
     * @param {Object} e
     */
    touchMoveContent(e) {
        if (e.touches[0].globalY - this.touchMoveData.touchStartY > 100 && !this.touchMoveData.isTouchMove) {
            this.$emit('hideDialer', {});
            if (!this.batchDelete && this.allCalls.length > 0) {
                this.showTabTitle = true;
            }
            this.touchMoveData.isTouchMove = true;
        }
        if ((e.touches[0].globalY - this.touchMoveData.touchStartY < -100) && this.allCalls.length > 0
        && !this.touchMoveData.isTouchMove) {
            this.$emit('hideDialer', {});
            this.showTabTitle = false;
            if (this.needSmallTitle) {
                this.$emit('changeTitle', {
                    type: 1
                });
                this.needSmallTitle = false;
            }
            this.touchMoveData.isTouchMove = true;
        }
    },
    touchEndContent: function () {
        this.touchMoveData.isTouchMove = false;
    },

    /**
     * Call history and missed call switchover event
     *
     * @param {Object} e
     */
    changeCallListTab(e) {
        this.tabIndex = e.index;
        this.$emit('changeLog', {
            logIndex: e.index,
        });
    },

    /**
      * Parameters that：
      *
      * @param {string} str
      * @return {string} newStr
      */
    subStringWithEllipsis(str) {
        let newLength = 0;
        let len = 7;
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
    }
};