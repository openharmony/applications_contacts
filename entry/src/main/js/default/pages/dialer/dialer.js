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
import callLogService from '../../../default/model/CalllogModel.js';
import searchContactModel from '../../../default/model/GroupsModel.js';
import Utils from '../../../default/utils/utils.js';
import router from '@system.router';
import pasteboard from '@ohos.pasteboard';
import LOG from '../../utils/ContactsLog.js';
import Constants from '../../../default/common/constants/Constants.js';
import sim from '@ohos.telephony.sim';
import radio from '@ohos.telephony.radio';

const DEFAULT_INT_VALUE = 0;
const NUM_TEXT_FONT_SIZE_MAX = 70;
const NUM_TEXT_PADDING_LEFT_MAX = 364;
const NUM_TEXT_MAXSIZE_LENGTH = 16;
const NUM_TEXT_OFFSET_UNIT = 20;
const NUM_TEXT_MAX_LENGTH = 25;
const NUM_TEXT_SPACE_OFFSET_UNIT = 10;
const DIALER_BUTTON_MARGIN_HIDE = 260;
const DIALER_BUTTON_MARGIN_SHOW = 0;
const DIALER_BUTTON_OPACITY_HIDE = 0.0;
const DIALER_BUTTON_OPACITY_SHOW = 1.0;
const DIALER_MARGIN_BOTTOM_HIDE = -690;
const DIALER_MARGIN_BOTTOM_OPTION_HIDE = -820;
const DIALER_MARGIN_BOTTOM_SHOW = 0;
const DIALER_ANIMATION_DISTANCE_DEFAULT = 690;
const DIALER_ANIMATION_DISTANCE_OPTION = 820;
const LOG_ITEM_ANIMATION_MAX_DISTANCE = 180;
const LOG_ITEM_ANIMATION_INIT_DISTANCE = 0;
const BOTTOM_MENU_HEIGHT = 130;
const VOICE_MAIL_INDEX = 2;
const MISSED_CALLS_INDEX = 1;
const ALL_CALLS_INDEX = 0;
const SECRETE_CODE_1 = '*#06#';
const SECRETE_CODE_2 = '*#0000#';
const SECRETE_CODE_3 = '*#*#2846579#*#*';

var TAG = '   dialer....: ';

export default {
    props: ['recordList', 'missedList', 'voicemailList', 'batchDelete', 'numTextValue', 'ifShow', 'pasteDisabled',
    'showTips', 'tipData'],
    data: {
        showDialer: true,
        isFirstInit: true,
        showVoiceMail: false,
        numText: '',
        numTextPaddingLeft: DEFAULT_INT_VALUE,
        viewText: '',
        numTextSize: NUM_TEXT_FONT_SIZE_MAX,
        areaInfo: '',
        deleteButtonDisabled: true,
        dialButtonDisabled: true,
        isTouchActive: false,
        dialerStyle: 'board-contacts-operate',
        boardThumbnailStyle: 'board-thumbnail-button-thumbnail',
        hideDialerTimeOutId: '',
        showDialerTimeOutId: '',
        showDialButton: 'visible',

        bordButtonMarginRight: 260,
        bordButtonWidth: 100,
        showBoardThumbnail: false,
        thumbnailOpacity: 1,

        isHDMode: false,

        isLongPressEvent: false,

        markFlag: false,

        isCallState: false,

        isShowDetailState: false,

        callLogIndex: 0,

        matchedRecordsList: [],

        titleType: 0,

        dialerTouchData: {
            touchStartX: 0,
            touchStartY: 0,
            isTouchMove: false
        },

        isSingleCard: true,
        simMessage: {
            simCount: 0,
            sim1State: 0,
            sim2State: 0,
            sim1SpnMessage: '',
            sim2SpnMessage: '',
            voicemailNumberSim1: '',
            voicemailNumberSim2: '',
            telephoneNumberSim1: '',
            telephoneNumberSim2: '',
            defaultSimSlot: 0,
        },

        optionMenu: {
            copyDisabled: true,
            batchDeleteDisabled: true
        },


        ifShowConfig: {
            showAeraInfo: false,
            showContactsOperates: false,

            showPhoneTitle: true,

            showNumTextAera: false,
            showAttentionInfo: false,

            showCallRecords: false,

            showMatchedList: false,
        },


        dynamicStyle: {
            boardThumbnailButtonClass: 'board-thumbnail-button',
            boardThumbnailIconClass: 'board-thumbnail-button-icon',
            boardThumbnailBoxClass: 'board-thumbnail-box',
            numTextAeraClass: 'num-text-area-num',

            numTextAttention: 'num-text-attention',
        },


        iconResource: {
            ic_contacts_add: '/res/image/ic_contacts_add_m2.svg',
            ic_contacts_call_dial: '/res/image/ic_contacts_call_dial_56.svg.svg',
            ic_contacts_call_dial_HD: '/res/image/ic_contacts_call HD dial_56.svg.svg',
            ic_contacts_delete: '/res/image/ic_contacts_Delete_m.svg',
            ic_contacts_name: '/res/image/ic_contacts_name_m.svg',
            ic_contacts_voicemail: '/res/image/ic_contacts_voicemail_mini.svg',
            ic_contacts_dialer: '/res/image/ic_contacts_dialer.svg',
            ic_video_m: '/res/image/ic_video_m.svg',
            ic_message: '/res/image/ic_meetime_24x24_message.svg',
            ic_more: '/res/image/ic_more_24x24.svg',
            ic_contacts_dial_HD_1: '/res/image/ic_contacts_dial call HD_1_m.svg',
            ic_contacts_dial_HD_2: '/res/image/ic_contacts_dial call_HD_2_m.svg',
            ic_contacts_dial_1: '/res/image/ic_contacts_dial call_1_m.svg',
            ic_contacts_dial_2: '/res/image/ic_contacts_dial call_2_m.svg',
            ic_detail_public: '/res/image/ic_public_about_m.svg',
        },

        clipboardData: {
            showClipboard: false,
            number: '',
            showClipboardInit: false,
            bottomDst: DIALER_ANIMATION_DISTANCE_OPTION,
        },

        pageInfo: {
            pageIndex: 0,
            pageSize: 20,
            pageIndexMissedCalls: 0,
            pageSizeMissedCalls: 20,
            pageIndexMatchedList: 0,
            pageSizeMatchedList: 200,
            totalCount: 0,
        },

        matchedMenuData: {
            index: '',
            itemId: [],
            name: '',
            number: '',
            showMatchedMenuTimeOutId: 0,
        },

        speedDetailsDataKey: 'speedDetailsDataKey',

        routerIndex: -1,
        speedIndex: -1,
        speedNum: 9,

        speedTempList: [],
        speedTempItem: null,
        callLogTouchData: {
            touchStartX: 0,
            touchStartY: 0,
            firstLeftDst: 0,
            currentIndex: 0,
            leftItemIndex: null,
            touchEventTaskId: 0,
        },
        secreteCodeMessage: {
            meid: '',
            pesn: '',
            imei1: '',
            imei2: '',
            sn: '',
        },

        callLogMergeRule: '',
        pinYinArr: []
    },

    onInit() {
        LOG.info(TAG + 'onInit......');
        this.numText = this.$app.$def.dialerStateData.numTextDialer;

        this.deleteButtonDisabled = true;

        this.initSimCardMessage();
        this.numText = this.$app.$def.dialerStateData.numTextDialer;

        this.$app.$def.globalData.refreshFunctions.push(() => {
            LOG.info(TAG + 'onInit' + ' editNumber = ');
            if (this.$app.$def.dialerStateData.isEditNumber) {
                this.numText = this.$app.$def.dialerStateData.numTextDialer;
                this.$app.$def.dialerStateData.isEditNumber = false;
                this.$app.$def.dialerStateData.numTextDialer = '';
            }
            this.initSimCardMessage();
            this.checkIfShow();
        });

        this.$app.$def.globalData.navigationBackPressFunctions.push(() => {
            LOG.info(TAG + 'onInit' + ' onBackPress Dialer!');
            if (this.numText.length > 0) {
                this.numText = '';
                this.checkIfShow();
                return true;
            }
            return false;
        });
        this.isFirstInit = this.$app.$def.globalData.storage.getSync('showAttention', true);
        this.checkIfShow();
    },
    onReady() {
        LOG.info(TAG + 'onReady......');
    },
    onShow() {
        LOG.info(TAG + 'onShow......');
    },
    onHide() {
        LOG.info(TAG + 'onHide......');
    },
    onDestroy() {
        LOG.info(TAG + 'onDestroy......');
        this.$app.$def.globalData.refreshFunctions.pop();
        this.$app.$def.globalData.navigationBackPressFunctions.pop();
    },

    onRefreshDialerState() {
        LOG.info(TAG + 'onRefreshDialerState' + ' this.onRefreshDialerState: ' + this.onRefreshDialerState);
        this.refreshCallLog();
        this.resetItemState();
        this.checkIfShow();
    },
    sendMessage(number, name) {
        var params = [];
        params.push({
            contactsName: name,
            telephone: number,
            telephoneFormat: number,
        });

        this.$app.$def.sendMessage(params);
        this.$app.$def.dialerStateData.isNeedShowDialer = false;
    },

    changeTitle(e) {
        LOG.info(TAG + 'changeTitle' + 'logMessage changeTitle type = ');
        this.titleType = e.detail.type;
    },
    touchStartDialer(e) {

        this.dialerTouchData.touchStartX = e.touches[0].globalX;
        this.dialerTouchData.touchStartY = e.touches[0].globalY;
    },
    touchMoveDialer(e) {

        var offsetY = e.touches[0].globalY - this.dialerTouchData.touchStartY;
        if ((offsetY > 100) && offsetY > Math.abs(e.touches[0].globalX - this.dialerTouchData.touchStartX)
        && !this.dialerTouchData.isTouchMove) {

            this.dialerTouchData.isTouchMove = true;
            this.hideDialer();
        }
    },
    buttonTouchStart() {
        if (!Utils.isEmpty(this.numText)) {
            this.vibrateByConfig();
        }
    },

    dialButtonTouchStart() {

        this.iconResource.ic_contacts_call_dial = '/res/image/ic_contacts_call_dial_56_clicked.svg.svg';
        this.iconResource.ic_contacts_call_dial_HD = '/res/image/ic_contacts_call HD dial_56_clicked.svg.svg';
        if (!Utils.isEmpty(this.numText)) {
            this.vibrateByConfig();
        }
    },

    dialButtonTouchEnd() {

        this.iconResource.ic_contacts_call_dial = '/res/image/ic_contacts_call_dial_56.svg.svg';
        this.iconResource.ic_contacts_call_dial_HD = '/res/image/ic_contacts_call HD dial_56.svg.svg';
    },
    buttonTouchEnd(keyValue) {
        if (Utils.isEmpty(this.numText) && !this.isLongPressEvent) {
            this.vibrateByConfig();
        }
        if (!this.isLongPressEvent && !this.dialerTouchData.isTouchMove) {
            this.appendNumText(keyValue);
            this.markFlag = false;
        }
        this.isLongPressEvent = false;
        this.dialerTouchData.isTouchMove = false;
    },

    buttonLongPress(keyValue) {

        this.vibrateByConfig();
        this.isLongPressEvent = true;
        switch (keyValue) {
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:

                if (Utils.isEmpty(this.numText)) {
                    this.speedCall(keyValue);
                } else {
                    this.appendNumText(keyValue);
                }
                break;

            case 0:
                this.appendNumText('+')
                break;

            case '*':
                if (this.numText.length == 0) {
                    this.appendNumText('*');
                } else {
                    this.appendNumText(',');
                }
                this.markFlag = false;
                break;

            case '#':
                if (this.numText.length == 0) {
                    this.appendNumText('#');
                    this.markFlag = false;
                } else if (this.markFlag) {
                    this.appendNumText('#');
                    this.markFlag = false;
                } else {
                    this.appendNumText(';');
                    this.markFlag = true;
                }
                break;
            default:
                break;
        }
    },
    appendNumText(keyValue) {
        this.numText = this.numText + keyValue;
        this.numberPressCheck();
    },

    comb(arr) {
        let temp = []
        for (let i in arr[0]) {
            for (let j in arr[1]) {
                temp.push(`${arr[0][i]}${arr[1][j]}`)
            }
        }
        arr.splice(0, 2, temp)
        if (arr.length > 1) {
            this.comb(arr)
        } else {
            return temp
        }
        return arr[0];
    },


    buttonTouchStartX() {
        if (this.numText.length == 0) {
            LOG.info(TAG + 'buttonTouchStartX' + 'numText length is empty.');
        }
    },
    buttonTouchEndX() {
        if (!this.isLongPressEvent) {
            this.vibrateByConfig();
        } else {
            this.isLongPressEvent = false;
        }
        if (this.numText.length > 0) {
            this.numText = this.numText.trim();
            this.numText = this.numText.substr(0, this.numText.length - 1).trim();
        }
        if (this.numText.length >= 6) {
            this.showAeraInfo = true;
        } else {
            this.showAeraInfo = false;
        }
        this.numberPressCheck();
    },
    clearNumText() {
        this.isLongPressEvent = true;
        this.vibrateByConfig();
        this.numText = '';
        this.checkIfShow();
    },

    vibrateByConfig: function () {
        if (this.isTouchActive) {
        }
    },
    numberPressCheck() {
        this.ifNeedSpace();
        this.checkIfSecretCode();
        this.checkIfShow();
    },
    ifNeedSpace() {
        if (this.numText.length >= 6) {
            this.showAeraInfo = true;
        } else {
            this.showAeraInfo = false;
        }
        switch (this.numText.length) {
            case 3:
                if (this.checkNeedNumberSpace(this.numText)) {
                    this.numText = this.numText + ' ';
                }
                break;
            case 8:
                this.numText = this.numText + ' ';
                break;
            default:
                break;
        }
    },
    checkNeedNumberSpace(numText) {
        let isSpace = /[\+;,#\*]/g;
        let isRule = /^\+.*/;
        if (isSpace.test(numText)) {
            if (isRule.test(numText)) {
                return true;
            } else {
                return false;
            }
        }
        return true;
    },
    getMatchedList() {
        if (!this.numText.startsWith('1') && !this.numText.startsWith('0')
        && !this.numText.startsWith('*') && !this.numText.startsWith('#')
        && !this.numText.startsWith('+') && !this.numText.startsWith(',')
        && !this.numText.startsWith(';')) {
            var a = {
                2: 'abc',
                3: 'def',
                4: 'ghi',
                5: 'jkl',
                6: 'mno',
                7: 'pqr',
                8: 'stu',
                9: 'vwxyz'
            }
            var number = Utils.removeSpace(this.numText);
            let code = number.split('').map(ee => a[ee]);
            if (code.length == 1) {
                this.pinYinArr = code[0].split('');
            } else {
                this.pinYinArr = this.comb(code);
            }
        }
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        var searchText = Utils.removeSpace(this.numText);
        var data = {
            likeValue: searchText,
            pinYinArr: this.pinYinArr
        }
        searchContactModel.searchContacts(DAHelper, data, result => {
            var matchedList = [];
            var contactMap = new Map();
            var phoneNumberMap = new Map();
            if (result.code == 0 && !Utils.isEmptyList(result.data)) {
                result.data.forEach(contactElement => {
                    if (!contactMap.has(contactElement.contactId) && !Utils.isEmptyList(contactElement.phoneNumbers)) {
                        var matchedElement = {};
                        matchedElement.phone = contactElement.phoneNumbers[0].phoneNumber;
                        matchedElement.name = contactElement.emptyNameData;
                        for (var i = 0; i < contactElement.phoneNumbers.length; i++) {
                            var number = contactElement.phoneNumbers[i].phoneNumber;
                            if (Utils.removeSpace(number).indexOf(Utils.removeSpace(this.numText)) > -1) {
                                matchedElement.phone = number;
                                try {
                                    matchedElement.formatNumber = number; // await telephony.formatPhoneNumber(number);
                                } catch {
                                    matchedElement.formatNumber = number;
                                }
                                break;
                            }

                        }
                        matchedElement.callTag = '';
                        this.fillMatchedElementProperty(matchedElement);
                        matchedList.push(matchedElement);
                        contactMap.set(contactElement.contactId);
                        phoneNumberMap.set(contactElement.phone);
                    }
                });
            }
            if (this.numText.length >= 3) {
                this.getMatchedCallLog(matchedList, contactMap, phoneNumberMap);
            } else {
                this.matchedRecordsList = matchedList;
                this.ifShowConfig.showContactsOperates = false;
                this.ifShowConfig.showMatchedList = true;
            }
            this.viewNumberTextProc();
            this.checkMoreMenuState();
        });
    },

    getMatchedCallLog(matchedList, contactMap, phoneNumberMap) {
        this.matchedRecordsList = [];
        if (!Utils.isEmpty(this.$app.$def.globalData.callLogTotalData.callLogList)) {
            for (var i = 0; i < this.$app.$def.globalData.callLogTotalData.callLogList.length; i++) {
                var element = this.$app.$def.globalData.callLogTotalData.callLogList[i];
                if (!Utils.isEmpty(element.contactKey) && contactMap.has(element.contactKey)) {
                    continue;
                }
                if (!Utils.isEmpty(element.phone) && phoneNumberMap.has(element.phone)) {
                    continue;
                }
                if (Utils.removeSpace(element.phone).indexOf(Utils.removeSpace(this.numText)) > -1) {
                    this.fillMatchedElementProperty(element);
                    matchedList.push(element);
                    phoneNumberMap.set(element.phone);
                }
            }
        } else {
            LOG.info(TAG + 'getMatchedCallLog' + 'logMessage callLogList is empty!');
        }
        if (matchedList.length > 0) {
            setTimeout(() => {
                this.matchedRecordsList = matchedList;
                this.ifShowConfig.showContactsOperates = false;
                this.ifShowConfig.showMatchedList = true;
            }, 0);
        } else {
            if (this.showDialer) {
                this.ifShowConfig.showContactsOperates = true;
            }
            this.ifShowConfig.showMatchedList = false;
        }

    },

    fillMatchedElementProperty(element) {
        var matchedString = Utils.getMatchedString(element.formatNumber, this.numText);
        if (!Utils.isEmpty(element.formatNumber)) {
            var startIndex = element.formatNumber.indexOf(matchedString);
            element.firstPart = element.formatNumber.substring(0, startIndex);
            element.matchedPart = element.formatNumber.substr(startIndex, matchedString.length);
            LOG.info(TAG + 'fillMatchedElementProperty' + 'logMessage element.matchedPart = '
            + ' startIndex = ' + startIndex);
            element.endPart = element.formatNumber.substr(startIndex + matchedString.length);
        } else {
            element.firstPart = element.phone;
            element.matchedPart = '';
            element.endPart = '';
        }
    },

    getMatchedRecordList() {
        var matchedList = [];
        if (!Utils.isEmpty(this.$app.$def.globalData.callLogTotalData.callLogList)) {
            this.$app.$def.globalData.callLogTotalData.callLogList.forEach((element) => {
                if (Utils.removeSpace(element.phone).indexOf(Utils.removeSpace(this.numText)) > -1) {
                    this.fillMatchedElementProperty(element)
                    matchedList.push(element);
                }
            });
        } else {
            LOG.info(TAG + 'getMatchedRecordList' + 'logMessage callLogList is empty! callLogList = ');
        }
        if (matchedList.length > 0) {
            this.matchedRecordsList = matchedList;
            this.ifShowConfig.showContactsOperates = false;
            this.ifShowConfig.showMatchedList = true;
        } else {
            if (this.showDialer) {
                this.ifShowConfig.showContactsOperates = true;
            }
            this.ifShowConfig.showMatchedList = false;
        }
    },

    hideDialer(e) {
        clearTimeout(this.hideDialerTimeOutId);
        var delay = 0;

        LOG.info(TAG + 'hideDialer' + 'logMessage showDialer = ');
        if (this.$app.$def.dialerStateData.showDialer) {
            this.dialerAnimationProc(false);
            this.$app.$def.dialerStateData.showDialer = false;
        }
        if (this.ifShowConfig.showAttentionInfo) {
            this.hideDialerTimeOutId = setTimeout(() => {
                this.dynamicStyle.numTextAttention = 'num-text-attention-all'
                this.$app.$def.dialerStateData.showDialer = false;
            }, delay);
        }
    },

    boardThunmbnailTouchStart() {
        this.dynamicStyle.boardThumbnailButtonClass = 'board-thumbnail-button-onpress';
        this.dynamicStyle.boardThumbnailBoxClass = 'board-thumbnail-box-onpress';
        this.dynamicStyle.boardThumbnailIconClass = 'board-thumbnail-button-icon-onpress';

    },

    showNumBoard() {
        this.dynamicStyle.boardThumbnailBoxClass = 'board-thumbnail-box';
        this.dynamicStyle.boardThumbnailIconClass = 'board-thumbnail-button-icon';
        this.dialerAnimationProc(true);
        this.$app.$def.dialerStateData.showDialer = true;
        clearTimeout(this.showDialerTimeOutId);
        this.showDialerTimeOutId = setTimeout(() => {
            this.dynamicStyle.numTextAttention = 'num-text-attention'
        }, 300);
        if (this.numText.length > 0) {
            this.showContactsOperates = true;
        }
    },

    dialerStateShow() {
        this.dialerMarginBottom = DIALER_MARGIN_BOTTOM_SHOW;
        this.bordButtonMarginRight = DIALER_BUTTON_MARGIN_HIDE;
        this.thumbnailOpacity = DIALER_BUTTON_OPACITY_HIDE;
        this.showBoardThumbnail = false;
        this.showDialer = true;
        this.showDialButton = 'visible';
        this.$app.$def.dialerStateData.showDialer = true;
        },

    dialerStateHide() {
        this.dialerMarginBottom = this.ifShowConfig.showContactsOperates ?
            DIALER_MARGIN_BOTTOM_OPTION_HIDE : DIALER_MARGIN_BOTTOM_HIDE;
        this.bordButtonMarginRight = DIALER_BUTTON_MARGIN_SHOW;
        this.thumbnailOpacity = DIALER_BUTTON_OPACITY_SHOW;
        this.showBoardThumbnail = true;
        this.showDialer = false;
        this.showDialButton = 'hidden';
        this.$app.$def.dialerStateData.showDialer = false;
    },

    callOutByDialer(simIndex) {
        LOG.info(TAG + 'onInit' + 'logMessage this.numText:'  + 'this.simIndex:' + simIndex);
        this.callOut(this.numText, simIndex);
    },

    callOutByLog(e) {
        if (this.isSingleCard) {
            this.callOut(e.detail.number, this.simMessage.defaultSimSlot);
        } else {
            this.editNumberBefore(e.detail.number);
        }
    },

    callOutByMatchedList: function (index) {
        if (this.isSingleCard) {
            this.callOut(this.matchedRecordsList[index].phone);
        } else {
            this.editNumberBefore(this.matchedRecordsList[index].formatNumber)
        }
    },

    singleCardMode() {
        this.isSingleCard = true;
    },

    doubleCardMode() {
        this.isSingleCard = false;
    },
    getNumTextCursorPosition() {
        var numTextObj = this.$element('numTextId');
        var cursorPosition = -1;
        if (numTextObj.selectionStart) {
            cursorPosition = numTextObj.selectionStart;
        }
    },

    cancelSchedule(e) {
        this.$element('simpledialog').close();
    },

    showRecordDetailsByMatchedList(index) {
        LOG.info(TAG + 'showRecordDetailsByMatchedList' + 'logMessage:index=' + index);
        this.$app.$def.dialerStateData.isNeedShowDialer = false;
        var newNumberContactDetail = this.matchedRecordsList[index];
        this.showDetails(newNumberContactDetail);
    },

    showRecordDetailsByLog: function (e) {
        this.$app.$def.dialerStateData.isNeedShowDialer = false;
        var newNumberContactDetail = {};
        if (this.callLogIndex == 2) {
            newNumberContactDetail = this.voicemailList[e.detail.logIndex];
        } else if (this.callLogIndex == 1) {
            newNumberContactDetail = this.missedList[e.detail.logIndex];
        } else {
            newNumberContactDetail = this.recordList[e.detail.logIndex];
        }
        this.showDetails(newNumberContactDetail);
    },

    showDetails(newNumberContactDetail) {
        LOG.info(TAG + 'showDetails' + ' newNumberContactDetail = ' + newNumberContactDetail);
        router.push({
            uri: 'pages/contacts/contactDetail/contactDetail',
            params: {
                sourceFromCallRecord: true,
                isNewNumber: true,
                phoneNumberShow: newNumberContactDetail.formatNumber,
                newNumberContactDetail: newNumberContactDetail
            }
        });
    },
    copyObj(obj) {
        return JSON.parse(JSON.stringify(obj));
    },

    getContactDetailByPhoneNum: function (code, phoneNumberShow, newNumberContactDetail) {
        var requestData = {};
        requestData.phoneNumber = phoneNumberShow.replace(/\s+/g, '');
    },

    async getSimCardMessage() {
    },

    getTouchActiveConfig: function () {
    },
    getCorrectMessage(simMessage) {
        switch (simMessage) {
            case 'CHINA MOBILE':
                return this.$t('phone.simMsgYiDong');
            case 'CHINA UNICOM':
                return this.$t('phone.simMsgLianTong');
            case 'CHINA TELECOM':
                return this.$t('phone.simMsgDianXin');
            default:
                return simMessage;
        }
    },

    copy(data) {
        var systemPasteBoard = pasteboard.getSystemPasteboard();

        var pasteData = pasteboard.createPlainTextData(data);

        systemPasteBoard.setPasteData(pasteData, (error, msg) => {
            if (error) {
                LOG.error('logMessage Failed to set PasteData. Cause: ');
                return;
            }

            this.$app.$def.globalData.storage.putSync('clipboardTempKey', data);
            LOG.info(TAG + 'systemPasteBoard' + ' PasteData set successfully. data = ');
        });
    },

    paste() {

        var systemPasteBoard = pasteboard.getSystemPasteboard();
        systemPasteBoard.getPasteData((error, pasteData) => {
            if (error) {
                LOG.error('logMessage Failed to obtain PasteData. Cause: ');
                return;
            }
            var text = pasteData.getPrimaryText();
            LOG.info(TAG + 'paste' + 'logMessage paste text = ');
            var numTemp = Utils.getNumberString(text);
            this.editNumberBefore(numTemp);
        });
    },

    addContacts(number) {
        var phoneNumber = number.replace(/[^0123456789+]*/g, '');
        var show = false;
        if (phoneNumber.length > 0) {
            show = true;
        }
        this.$app.$def.dialerStateData.isNeedShowDialer = false;
        router.push({
            uri: 'pages/contacts/accountants/accountants',
            params: {
                phoneNumbers: [
                    {
                        'labelId': 2,
                        'labelName': this.$t('accountants.phone'),
                        'phoneNumber': phoneNumber,
                        'phoneAddress': 'N',
                        'showP': show,
                        'blueStyle': true
                    }
                ]
            },
        });
    },

    async formatPhoneNumber(number) {
    },

    callOut(phoneNumber, simIndex) {
        this.$app.$def.dialerStateData.isCallState = true;
        var dailNumber = '';
        if (phoneNumber.length == 0 && this.recordList.length > 0) { // If no phone number is entered, the first call record is dialed by default
            dailNumber = this.recordList[0].phone;
        } else if (phoneNumber.length > 0) {
            dailNumber = phoneNumber; // Pass in the phone number to format
        }
        this.$app.$def.call(dailNumber);
        this.numText = '';
        this.checkIfShow();
    },
    requestLogByPage() {
        this.pageInfo.pageIndex++;
        LOG.info(TAG + 'requestLogByPage' + ' onRequestItem index=' + this.pageInfo.pageIndex);
        this.$emit('getLogPage', {
            pageIndex: this.pageInfo.pageIndex,
            logIndex: ALL_CALLS_INDEX
        });
    },
    requestMissedCallsByPage() {
        this.pageInfo.pageIndexMissedCalls++;
        this.$emit('getLogPage', {
            pageIndex: this.pageInfo.pageIndexMissedCalls,
            logIndex: MISSED_CALLS_INDEX
        });
    },
    checkMoreMenuState() {
        if (this.recordList.length > 0 && this.callLogIndex == ALL_CALLS_INDEX) {
            this.optionMenu.batchDeleteDisabled = false;
        } else if (this.missedList.length > 0 && this.callLogIndex == MISSED_CALLS_INDEX) {
            this.optionMenu.batchDeleteDisabled = false;
        } else if (this.voicemailList.length > 0 && this.callLogIndex == VOICE_MAIL_INDEX) {
            this.optionMenu.batchDeleteDisabled = false;
        }
        else {
            this.optionMenu.batchDeleteDisabled = true;
        }
    },

    changeCallLogIndex(e) {
        this.callLogIndex = e.detail.logIndex;
        LOG.info(TAG + 'changeCallLogIndex' + ' changeCallLogIndex this.callLogIndex = ' + this.callLogIndex);
        this.resetItemState();
        this.checkMoreMenuState();
    },
    getSimMessage: function (simCardState, simCardMessage) {
        if (Utils.isEmpty(simCardMessage)) { // If no carrier information exists, judge
            switch (parseInt(simCardState)) {
                case 0:
                case 1:
                    return this.$t('phone.notInService');
                case 2:
                case 3:
                    return this.$t('phone.emergencyCall');
                case 4:
                case 5:
                    return this.getCorrectMessage(simCardMessage);
                default:
                    break;
            }
        }
        return this.getCorrectMessage(simCardMessage);
    },

    onMoreMenuSelected(e) {
        this.$app.$def.dialerStateData.isNeedShowDialer = false;
        switch (parseInt(e.value)) {
            case 0:
                this.paste();
                break;
            case 1:
                this.$emit('batchDelete', {});
                var tempList = [];
                if (this.callLogIndex == VOICE_MAIL_INDEX) {
                    tempList = this.$app.$def.globalData.voicemailTotalData.voicemailList;
                } else if (this.callLogIndex == MISSED_CALLS_INDEX) {
                    tempList = this.$app.$def.globalData.callLogTotalData.missedList;
                } else {
                    tempList = this.$app.$def.globalData.callLogTotalData.callLogList;
                }
                router.push({
                    uri: 'pages/dialer/calllogdelete/calllogdelete',
                    params: {
                        batchDelete: 1,
                        logIndex: this.callLogIndex,
                        callLogList: tempList,
                        singleCardMode: this.isSingleCard,
                    }
                });
                break;
            case 2:
                break;
            case 3: // Settings (Skip to speed dial Settings page for now)
                router.push({
                    uri: 'pages/dialer/speeddial/speeddial'
                });
                break;
            case 4: // Settings (Jump to About page)
                router.push({
                    uri: 'pages/contacts/settings/about/about',
                    params: {}
                })
                break;
            case 5:
                router.push({
                    uri: 'pages/contacts/batchselectcontacts/batchselectcontacts',
                    params: {
                        selectType: 0,
                    }
                })
                break;
            case 6:
                this.callLogSettings();
                break;
            case 7:
                router.push({
                    uri: 'pages/dialer/greeting/greeting'
                });
                break;
            case 8:
                router.push({
                    uri: 'pages/index_demo/index'
                });
                break;
            default:
                break;
        }
    },
    callLogSettings: function () {
        this.getCallLogMergeRule();
    },
    closeCallLogDialog: function () {
        this.$element('logSettingDialog').close();
    },

    checkIfShow() {
        if (this.numText.trim().length > 0) {
            this.ifShowConfig.showPhoneTitle = false;
            this.ifShowConfig.showAttentionInfo = false;
            this.ifShowConfig.showNumTextAera = true;
            this.ifShowConfig.showCallRecords = false;
            this.deleteButtonDisabled = false;
            this.dialButtonDisabled = false;
            if (this.numText.trim().length < 3) {
                if (this.showDialer) {
                    this.ifShowConfig.showContactsOperates = true;
                    this.clipboardData.bottomDst = BOTTOM_MENU_HEIGHT + DIALER_ANIMATION_DISTANCE_OPTION;
                }
                this.ifShowConfig.showMatchedList = false;
                if (!this.numText.startsWith('1')) {
                    this.getMatchedList();
                }
            } else {
                this.getMatchedList()
            }
            this.viewNumberTextProc();
        } else {
            this.numTextPaddingLeft = DEFAULT_INT_VALUE;
            this.numTextSize = NUM_TEXT_FONT_SIZE_MAX;
            this.ifShowConfig.showNumTextAera = false;
            this.dynamicStyle.numTextAttention = 'num-text-attention';
            this.deleteButtonDisabled = true;
            this.ifShowConfig.showPhoneTitle = true;
            this.ifShowConfig.showMatchedList = false;
            this.ifShowConfig.showContactsOperates = false;
            this.clipboardData.bottomDst = BOTTOM_MENU_HEIGHT + DIALER_ANIMATION_DISTANCE_DEFAULT;
            if (this.recordList.length > 0) {
                this.ifShowConfig.showAttentionInfo = false;
                this.ifShowConfig.showCallRecords = true;
                this.dialButtonDisabled = false;
                if (this.isFirstInit) {
                    this.isFirstInit = false;
                    this.$app.$def.globalData.storage.putSync('showAttention', false);
                    this.$app.$def.globalData.storage.flushSync();
                }
            } else if (this.voicemailList.length > 0) {
                this.ifShowConfig.showAttentionInfo = false;
                this.ifShowConfig.showCallRecords = true;
                this.dialButtonDisabled = true;
            } else {
                this.dialButtonDisabled = true;
                if (!this.isFirstInit) {
                    this.ifShowConfig.showAttentionInfo = false;
                    this.ifShowConfig.showCallRecords = true;
                } else {
                    this.ifShowConfig.showCallRecords = false;
                    this.ifShowConfig.showAttentionInfo = true;
                }
            }

        }
        this.checkMoreMenuState();
    },
    checkIfSecretCode: function () {
        switch (Utils.removeSpace(this.numText)) {
            case SECRETE_CODE_1:
                this.numText = '';
                this.secretCode1Proc();
                break;
            case SECRETE_CODE_2:
                this.numText = '';
                break;
            case SECRETE_CODE_3:
                this.numText = '';
                break;
            default:
                break;
        }
    },
    secretCode1Proc: async function () {
        var meIdString = '';
        var pesnString = '';
        var imei1String = '';
        var imei2String = '';
        var snString = '';
        try {
        } catch {
            LOG.info(TAG + 'secretCode1Proc' + 'logMessage get meid error');
        }
        this.secreteCodeMessage.meid = meIdString;
        try {
        } catch {
            LOG.info(TAG + 'secretCode1Proc' + 'logMessage get pesn error');
        }
        this.secreteCodeMessage.pesn = pesnString;
        try {
            imei1String = await radio.getIMEI(0);
        } catch {
            LOG.info(TAG + 'secretCode1Proc' + 'logMessage get imei1 error');
        }
        this.secreteCodeMessage.imei1 = imei1String;
        try {
            imei2String = await radio.getIMEI(1);
        } catch {
            LOG.info(TAG + 'secretCode1Proc' + 'logMessage get imei2 error');
        }
        this.secreteCodeMessage.imei2 = imei2String;
        try {
        } catch {
            LOG.info(TAG + 'secretCode1Proc' + 'logMessage get sn error');
        }
        this.secreteCodeMessage.pesn = pesnString;
        this.$element('codeDialog').show();
    },
    closeCodeDialog: function () {
        this.$element('codeDialog').close();
    },
    clickOut: function () {
        this.$element('codeDialog').focus();
    },
    viewNumberTextProc() {
        var numStringNoSpace = Utils.removeSpace(this.numText);
        this.viewText = numStringNoSpace.length > NUM_TEXT_MAX_LENGTH ?
            numStringNoSpace.substr(numStringNoSpace.length - NUM_TEXT_MAX_LENGTH) : this.numText;
        var spaceCount = 0;
        if (/[\s]/g.test(this.viewText)) {
            spaceCount = this.viewText.match(/[\s]/g).length;
        }
        if (this.viewText.trim().length > NUM_TEXT_MAXSIZE_LENGTH) {
            this.viewText = Utils.removeSpace(this.viewText);
            if (this.viewText.trim().length <= NUM_TEXT_MAXSIZE_LENGTH) {
                this.numTextPaddingLeft = NUM_TEXT_PADDING_LEFT_MAX - NUM_TEXT_OFFSET_UNIT * this.viewText.trim().length;
            } else {
                this.numTextSize = NUM_TEXT_FONT_SIZE_MAX * NUM_TEXT_MAXSIZE_LENGTH / (this.viewText.trim().length);
            }
        } else {
            this.numTextPaddingLeft = NUM_TEXT_PADDING_LEFT_MAX - NUM_TEXT_OFFSET_UNIT * this.viewText.trim().length
            + spaceCount * NUM_TEXT_SPACE_OFFSET_UNIT;
        }
    },
    editNumberBeforeByLog(e) {
        this.editNumberBefore(e.detail.number);
    },
    editNumberBefore(number) {
        this.numText = number;
        this.showNumBoard()
        this.checkIfShow();
    },
    copyNumber(e) {
        LOG.info(TAG + 'copyNumber' + 'logMessage copy Number 1');
        var number = '';
        number = e.detail.number.replace(/[^0123456789+;,#*-]*/g, '');
        this.copy(number);
    },
    pasteNumber() {
        this.paste();
        this.$emit('hideTips', {});
    },
    removeCall(e) {
        var tempList = [];
        var missedTempList = [];
        var voicemailTempList = [];
        for (let i = 0; i < this.recordList.length; i++) {
            if (this.recordList[i].ids != e.detail.id) {
                tempList.push(this.recordList[i]);
            }
        }
        for (let j = 0; j < this.missedList.length; j++) {
            if (this.missedList[j].ids != e.detail.id) {
                missedTempList.push(this.missedList[j]);
            }
        }
        for (let k = 0; k < this.voicemailList.length; k++) {
            if (this.voicemailList[k].ids != e.detail.id) {
                voicemailTempList.push(this.voicemailList[k]);
            }
        }
        this.$emit('updateLogList', {
            recordList: tempList,
            missedList: missedTempList,
            voicemailList: voicemailTempList
        });
        if (this.callLogIndex == 2) {
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
            callLogService.deleteVoicemailByIds(DAHelper, e.detail.id, () => {
                this.refreshVoicemailList();
            })
        } else {
            var mergeRule = this.$app.$def.globalData.storage.getSync('call_log_merge_rule', 'from_time');
            var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
            if (mergeRule == 'from_contact') {
                callLogService.deleteCallLogByNumbersOrContacts(DAHelper, e.detail.phoneNumber, e.detail.contactKey, () => {
                    this.refreshCallLogData();
                });
            } else {
                callLogService.deleteCallLogByIds(DAHelper, e.detail.id, () => {
                    this.refreshCallLogData();
                });
            }
        }
    },
    refreshCallLogData() {
        var mergeRule = this.$app.$def.globalData.storage.getSync('call_log_merge_rule', 'from_time');
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CALLLOG_DB_URI);
        callLogService.getAllCalls(DAHelper, mergeRule, data => {
            this.$app.$def.globalData.callLogTotalData = data;
            this.checkIfShow();
        });
    },
    refreshVoicemailList() {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.VOICEMAIL_DB_URI);
        callLogService.getVoicemailList(DAHelper, (voicemailList) => {
            this.$app.$def.globalData.voicemailTotalData.voicemailList = voicemailList;
            this.$app.$def.globalData.voicemailTotalData.voicemailCount = voicemailList.length;
        });
    },
    hideClipBoard(e) {
        this.$emit('hideTips', {});
    },
    speedCall: function (keyValue) {
        if (keyValue == 1) {
            var value = this.$app.$def.globalData.voicemailNumber;
            if (value !== '') {
                this.$app.$def.call(value);
            } else {
                if (this.simMessage.simCount == 0) {
                    this.$element('NotvoicemalDialog').show();
                } else {
                    var simIndex = 0;
                    if (this.simMessage.sim2State > 3) {
                        simIndex = 1;
                    }
                    this.goToVoicemailSettings(simIndex);
                }
            }
        } else {
            this.speedIndex = keyValue - 1;
            var speedItemString = this.$app.$def.globalData.storage.getSync('speedDial' + this.speedIndex, '');
            if (!Utils.isEmpty(speedItemString)) {
                this.callOut(JSON.parse(speedItemString).speedNumber);
            } else {
                this.$element('simpledialog').show();
            }
        }
    },

    cancelNotVoicemailDialog: function () {
        this.$element('NotvoicemalDialog').close();
    },

    cancelVoicemailDialog: function () {
        this.$element('voicemailDialog').close();
    },
    goToVoicemailSettings(simIndex) {
        var voicemailNumber = this.$app.$def.globalData.storage.getSync('voicemailNumber', '');
        if (Utils.isEmpty(voicemailNumber)) {
            if (simIndex == 0) {
                voicemailNumber = this.simMessage.voicemailNumberSim1;
            } else {
                voicemailNumber = this.simMessage.voicemailNumberSim2;
            }
        }
        router.push({
            uri: 'pages/dialer/voicemailsettings/voicemailsettings',
            params: {
                voiceMailNumber: voicemailNumber
            }
        });
    },
    setSchedule: function () {
        if (this.speedIndex > 0) {
            this.$element('simpledialog').close();
            router.push({
                uri: 'pages/dialer/speeddial/selectcontact/selectcontact',
                params: {
                    type: 'saveSpeedDial',
                    speedDialIndex: this.speedIndex,
                }
            });
        }
    },
    showMatchedListMenu(index) {
        LOG.info(TAG + 'showMatchedListMenu...: ' + this.matchedRecordsList[index]);
        this.matchedMenuData.index = index;
        this.matchedMenuData.itemId = this.matchedRecordsList[index].ids;
        this.matchedMenuData.name = this.matchedRecordsList[index].name;
        this.matchedMenuData.number = this.matchedRecordsList[index].formatNumber;
        var tempX = this.dialerTouchData.touchStartX;
        var tempY = this.dialerTouchData.touchStartY;

        if (this.dialerTouchData.touchStartX > 360) {
            tempX = 360;
        }
        clearTimeout(this.matchedMenuData.showMatchedMenuTimeOutId);

        this.matchedMenuData.showMatchedMenuTimeOutId = setTimeout(() => {
            this.vibrateByConfig();
            this.$element('matchedListMenu').show({
                x: tempX,
                y: tempY
            });
        }, 100);
        LOG.info(TAG + 'showMatchedListMenu' + 'logMessage showMatchedListMenu!');
    },
    saveToContacts(numText) {
        this.$app.$def.dialerStateData.isNeedShowDialer = false;
        router.push({
            uri: 'pages/contacts/selectContactsList/selectContactsList',
            params: {
                type: 'saveContacts',
                number: numText,
            }
        });
    },
    onMatchedListSelected(e) {
        switch (parseInt(e.value)) {
            case 1:
                this.addContacts(this.matchedMenuData.number);
                break;
            case 2:
                this.saveToContacts(this.matchedMenuData.number);
                break;
            case 3:
                this.sendMessage(this.matchedMenuData.number, this.matchedMenuData.name);
                break;
            case 4:
                this.editNumberBefore(this.matchedMenuData.number);
                break;
            case 5:
                break;
            default:
                break;
        }
    },

    subStringWithEllipsis(str) {
        let len = 7;
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
    touchStartMatchedItem: function () {
    },
    phoneNumberIndexOf: function (phoneNumbers, phoneNumber) {
        var indexOf = -1;
        for (var i = 0; i < phoneNumbers.length; i++) {
            if (phoneNumber == phoneNumbers[i].phoneNumber) {
                indexOf = i;
                break;
            }
        }
        return indexOf;
    },
    dialerAnimationProc(show) {
        if (show) {
            setTimeout(() => {
                this.showBoardThumbnail = false;
            }, 500);
            this.dialerStyle = 'dialer-display';
            this.boardThumbnailStyle = 'board-thumbnail-button-hide';
        } else {
            this.showBoardThumbnail = true;
            this.dialerStyle = 'dialer-hide';
            this.boardThumbnailStyle = 'board-thumbnail-button-display';
        }
    },
    touchStartItem(e) {
        LOG.info(TAG + 'touchStartItem' + 'logMessage touchStartItem !!!!!');
        this.callLogTouchData.touchStartX = e.detail.positionX;
        this.callLogTouchData.touchStartY = e.detail.positionY;
        var firstLeftDst = 0;
        if (this.callLogIndex == VOICE_MAIL_INDEX) {
            firstLeftDst = this.voicemailList[e.detail.index].leftDst;
        } else if (this.callLogIndex == MISSED_CALLS_INDEX) {
            firstLeftDst = this.missedList[e.detail.index].leftDst;
        } else {
            firstLeftDst = this.recordList[e.detail.index].leftDst;
        }
        this.callLogTouchData.firstLeftDst = firstLeftDst;
        this.callLogTouchData.currentIndex = e.detail.index;
        LOG.info(TAG + 'touchStartItem' + 'logMessage firstLeftDst = ');
        if (this.callLogTouchData.leftItemIndex != null && this.callLogTouchData.leftItemIndex
        != this.callLogTouchData.currentIndex) {
            if (this.callLogIndex == VOICE_MAIL_INDEX) {
                this.voicemailList[this.callLogTouchData.leftItemIndex].leftDst = 0;
            } else if (this.callLogIndex == MISSED_CALLS_INDEX) {
                this.missedList[this.callLogTouchData.leftItemIndex].leftDst = 0;
            } else {
                this.recordList[this.callLogTouchData.leftItemIndex].leftDst = 0;
            }
            this.callLogTouchData.leftItemIndex = null;
        }
    },
    touchMoveItem(e) {
        var offsetX = e.detail.positionX - this.callLogTouchData.touchStartX;
        var offsetY = e.detail.positionY - this.callLogTouchData.touchStartY;
        if (Math.abs(offsetX) > Math.abs(offsetY) && Math.abs(offsetX) < LOG_ITEM_ANIMATION_MAX_DISTANCE) { // 横向偏移大于竖向偏移时，才会触发左滑
            this.setItemMoveState(offsetX);
        }
    },
    touchEndItem(e) {
        var offsetX = e.detail.positionX - this.callLogTouchData.touchStartX;
        var offsetY = e.detail.positionY - this.callLogTouchData.touchStartY;
        if (Math.abs(offsetX) > Math.abs(offsetY) && Math.abs(offsetX) >= 50) {
            this.setItemEndState(offsetX);
        } else if (Math.abs(offsetX) > Math.abs(offsetY) && Math.abs(offsetX) < 50) {
            if (this.callLogIndex == VOICE_MAIL_INDEX) {
                this.voicemailList[this.callLogTouchData.currentIndex].leftDst = this.callLogTouchData.firstLeftDst
            } else if (this.callLogIndex == MISSED_CALLS_INDEX) {
                this.missedList[this.callLogTouchData.currentIndex].leftDst = this.callLogTouchData.firstLeftDst
            } else {
                this.recordList[this.callLogTouchData.currentIndex].leftDst = this.callLogTouchData.firstLeftDst;
            }
        }
    },
    setItemMoveState(offsetX) {
        if (this.callLogIndex == VOICE_MAIL_INDEX) {
            if (offsetX < 0) {
                this.voicemailList[this.callLogTouchData.currentIndex].leftDst =
                    this.callLogTouchData.firstLeftDst == LOG_ITEM_ANIMATION_INIT_DISTANCE ?
                    offsetX : this.callLogTouchData.firstLeftDst;
            } else {
                this.voicemailList[this.callLogTouchData.currentIndex].leftDst =
                    this.callLogTouchData.firstLeftDst == LOG_ITEM_ANIMATION_INIT_DISTANCE ?
                    0 : this.callLogTouchData.firstLeftDst + offsetX;
            }
        } else if (this.callLogIndex == MISSED_CALLS_INDEX) {
            if (offsetX < 0) {
                this.missedList[this.callLogTouchData.currentIndex].leftDst =
                    this.callLogTouchData.firstLeftDst == LOG_ITEM_ANIMATION_INIT_DISTANCE ?
                    offsetX : this.callLogTouchData.firstLeftDst;
            } else {
                this.missedList[this.callLogTouchData.currentIndex].leftDst =
                    this.callLogTouchData.firstLeftDst == LOG_ITEM_ANIMATION_INIT_DISTANCE ?
                    0 : this.callLogTouchData.firstLeftDst + offsetX;
            }
        } else if (offsetX < 0) {
            this.recordList[this.callLogTouchData.currentIndex].leftDst =
                this.callLogTouchData.firstLeftDst == LOG_ITEM_ANIMATION_INIT_DISTANCE ?
                offsetX : this.callLogTouchData.firstLeftDst;
        } else {
            this.recordList[this.callLogTouchData.currentIndex].leftDst =
                this.callLogTouchData.firstLeftDst == LOG_ITEM_ANIMATION_INIT_DISTANCE ?
                0 : this.callLogTouchData.firstLeftDst + offsetX;
        }
    },

    setItemEndState(offsetX) {
        if (offsetX < 0) {
            if (this.callLogTouchData.firstLeftDst == LOG_ITEM_ANIMATION_INIT_DISTANCE) {
                if (this.callLogIndex == VOICE_MAIL_INDEX) {
                    this.voicemailList[this.callLogTouchData.currentIndex].leftDst = -LOG_ITEM_ANIMATION_MAX_DISTANCE;
                } else if (this.callLogIndex == MISSED_CALLS_INDEX) {
                    this.missedList[this.callLogTouchData.currentIndex].leftDst = -LOG_ITEM_ANIMATION_MAX_DISTANCE;
                } else {
                    this.recordList[this.callLogTouchData.currentIndex].leftDst = -LOG_ITEM_ANIMATION_MAX_DISTANCE;
                }
            }
            this.callLogTouchData.leftItemIndex = this.callLogTouchData.currentIndex;
            this.callLogTouchData.firstLeftDst = LOG_ITEM_ANIMATION_MAX_DISTANCE;
        } else {
            if (this.callLogTouchData.firstLeftDst != LOG_ITEM_ANIMATION_INIT_DISTANCE) {
                if (this.callLogIndex == VOICE_MAIL_INDEX) {
                    this.voicemailList[this.callLogTouchData.currentIndex].leftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE;
                } else if (this.callLogIndex == MISSED_CALLS_INDEX) {
                    this.missedList[this.callLogTouchData.currentIndex].leftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE;
                } else {
                    this.recordList[this.callLogTouchData.currentIndex].leftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE;
                }
            }
            this.callLogTouchData.leftItemIndex = null;
            this.callLogTouchData.firstLeftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE;
        }
    },
    resetItemState() {
        if (this.callLogTouchData.leftItemIndex != null) {
            if (this.callLogIndex == VOICE_MAIL_INDEX) {
                this.voicemailList[this.callLogTouchData.leftItemIndex].leftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE;
            } else if (this.callLogIndex == MISSED_CALLS_INDEX) {
                this.missedList[this.callLogTouchData.leftItemIndex].leftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE;
            } else {
                this.recordList[this.callLogTouchData.leftItemIndex].leftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE
            }
            this.callLogTouchData.leftItemIndex = null;
            this.callLogTouchData.firstLeftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE;
        }
    },
    deleteSingleLog: function (e) {
        LOG.info(TAG + 'deleteSingleLog' + 'logMessage deleteSingleLog  e = ' + JSON.stringify(e))
        this.callLogTouchData.leftItemIndex = null;
        this.callLogTouchData.firstLeftDst = LOG_ITEM_ANIMATION_INIT_DISTANCE;
        this.removeCall(e);
    },
    checkMergeRule: function (type) {
        this.setCallLogMergeRule(type);
        this.pageInfo.pageIndex = 0;
        this.$emit('refreshCallLog', {});
        this.closeCallLogDialog();
    },
    setCallLogMergeRule(merge_rule) {
        this.callLogMergeRule = merge_rule;
        this.$app.$def.globalData.storage.putSync('call_log_merge_rule', merge_rule);
        this.$app.$def.globalData.storage.flushSync();
    },
    getCallLogMergeRule() {
        var mergeRule = this.$app.$def.globalData.storage.getSync('call_log_merge_rule', 'from_time');
        this.callLogMergeRule = mergeRule;
        this.$element('logSettingDialog').show();
    },
    async initSimCardMessage() {
        var hasCard1 = false;
        try {
            hasCard1 = await sim.hasSimCard(0);
        } catch {
            LOG.info(TAG + 'initSimCardMessage' + 'check sim1 error!');
        }
        if (hasCard1) {
            try {
                this.simMessage.sim1State = await sim.getSimState(0);
                var simSpn1 = await radio.getNetworkState(0);
                var spnMsg1 = Utils.isEmpty(simSpn1.longOperatorName) ? '' : simSpn1.longOperatorName.toUpperCase();
                if ('CHINA MOBILE' == spnMsg1) {
                    this.showVoiceMail = true;
                }
                this.simMessage.sim1SpnMessage = this.getSimMessage(this.simMessage.sim1State, spnMsg1);
                this.simMessage.voicemailNumberSim1 = await sim.getVoiceMailNumber(0)
                this.simMessage.telephoneNumberSim1 = await sim.getSimTelephoneNumber(0)
            } catch {
                this.simMessage.sim1State = 0;
                this.simMessage.sim1SpnMessage = '';
                this.simMessage.voicemailNumberSim1 = '';
                this.simMessage.telephoneNumberSim1 = '';
                LOG.error('logMessage get sim1 message has error!');
            }
        }
        var hasCard2 = false
        try {
            hasCard2 = await sim.hasSimCard(1);
        } catch {
            LOG.info(TAG + 'initSimCardMessage' + 'check sim2 error!');
        }
        if (hasCard2) {
            try {
                this.simMessage.sim2State = await sim.getSimState(1);
                var simSpn2 = await radio.getNetworkState(1);
                var spnMsg2 = Utils.isEmpty(simSpn2.longOperatorName) ? '' : simSpn2.longOperatorName.toUpperCase();
                if ('CHINA MOBILE' == spnMsg2) {
                    this.showVoiceMail = true;
                }
                this.simMessage.sim2SpnMessage = this.getSimMessage(this.simMessage.sim2State, spnMsg2);
                this.simMessage.voicemailNumberSim2 = await sim.getVoiceMailNumber(1);
                this.simMessage.telephoneNumberSim2 = await sim.getSimTelephoneNumber(1);
            } catch {
                this.simMessage.sim2State = 0;
                this.simMessage.sim2SpnMessage = '';
                this.simMessage.voicemailNumberSim2 = '';
                this.simMessage.telephoneNumberSim2 = '';
                LOG.error('logMessage get sim2 message has error!!');
            }
        }
        try {
            this.simMessage.defaultSimSlot = await sim.getDefaultVoiceSlotId();
        } catch {
            this.simMessage.defaultSimSlot = 0;
            LOG.error('get default sim slot error!');
        }
        if (hasCard1 && hasCard2) {
            this.simMessage.simCount = 2;
            this.doubleCardMode();
        } else if (hasCard1 || hasCard2) {
            this.simMessage.simCount = 1;
            this.singleCardMode();
        } else {
            this.simMessage.simCount = 0;
            LOG.info(TAG + 'initSimCardMessage' + 'no sim card!');
        }
    }

}
