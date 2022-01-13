/**
 * @file: Group operating
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
import groupReq from '../../../../../default/model/GroupsModel.js';
import LOG from '../../../../utils/ContactsLog.js';
import Constants from '../../../../../default/common/constants/Constants.js';

var TAG = 'deleteGroup...:';

export default {
    data: {
        // New contact ID
        addContactStatus: false,
        reset: '/res/image/ic_cancel_m.svg',
        save: '/res/image/ic_comfirm.svg',
        imageUnsave: '/res/image/uncomfirm.png',
        addGroup: '/res/image/ic_contacts_add_m2.svg',
        isEmpty: true,
        groupList: [],
        title: '',
        deleteDialogTitle: '',
        checkedNum: 0,
        contactForm: {},
        // New group
        newGroupName: '',
        page: 0,
        limit: 20, // Number of entries per page
        addShow: false,
        updataShow: false,
        screenDirection: 0, // 0: vertical screen, 1: horizontal screen
        oldParam: [],
        dataflag: false,
        groups: []
    },
    onInit() {
        LOG.info(TAG + 'onInit success')
        this.title = this.$t('value.contacts.groupsPage.noSelect');
        var requestData = {
            page: this.page,
            limit: this.limit
        };
        this.getGroupList(requestData);
    },

    requestItem: function () {
        this.page++;
        var requestData = {
            page: this.page,
            limit: this.limit
        };
        LOG.info(TAG + 'requestItem requestData' +requestData)
        this.getGroupList(requestData);
    },
    getGroupList: function (actionData) {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryGroups(DAHelper, actionData, result => {
            LOG.info(TAG + 'delete getGroupList' + result);
            result.forEach((item) => {
                if (this.groups.length > 0) {
                    this.groups.forEach((element) => {
                        if (item.groupId == element.groupId) {
                            item.checked = true;
                        } else {
                            item.checked = false;
                        }
                    })
                } else {
                    item.checked = false;
                }
            })
            if (this.page == 0) {
                this.groupList = result;
            } else {
                this.groupList = this.groupList.concat(result);
            }
            this.oldParam = this.copy(this.groupList);
        });
    },
    itemClick: function (item) {
        LOG.info(TAG + 'itemClick item' + item)
        item.checked = !item.checked;
        if (item.checked) {
            this.checkedNum++;
        } else {
            this.checkedNum--;
        }
        this.initTitle();
    },
    initTitle: function () {
        if (this.checkedNum != 0) {
            this.title = this.$t('value.contacts.groupsPage.alreadySelect').replace('num', this.checkedNum + "");
            if (this.addContactStatus) {
                this.isEmpty = false;
            }
        } else {
            this.title = this.$t('value.contacts.groupsPage.noSelect');
        }
        LOG.info(TAG + 'old group is ' + this.oldParam);
        LOG.info(TAG + 'group is ' + this.groupList)
        if (this.isSameData(this.oldParam, this.groupList, 'Array')) {
            this.isEmpty = true;
        } else {
            this.isEmpty = false;
        }
    },

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
            LOG.info(TAG + 'isSameData type')
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

    showDeleteGroupDialog: function () {
        var deleteList = [];
        this.groupList.forEach(item => {
            if (item.checked) {
                deleteList.push(item);
            }
        })
        if (deleteList.length == 1) {
            this.deleteDialogTitle = this.$t('value.contacts.groupsPage.deleteThisGroup');
        } else if (deleteList.length == this.groupList.length) {
            this.deleteDialogTitle = this.$t('value.contacts.groupsPage.deleteAllGroups');
        } else {
            this.deleteDialogTitle = this.$t('value.contacts.groupsPage.deleteNumGroups').replace('num', this.checkedNum + "");
        }
        this.$element('deleteGroupDialog').show()
    },
    
    showAddGroupDialog: function () {
        this.newGroupName = "";
        this.$element('addGroupDialog').show();
    },
    
    groupNameChanged: function (e) {
        this.newGroupName = e.value;
    },
    
    cancelAddGroup() {
        this.$element('addGroupDialog').close()
    },
    
    confirmAddGroup() {
        var actionData = {};
        actionData.title = this.newGroupName;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.addGroup(DAHelper, this.newGroupName, result => {
            if (result == -2) {
                prompt.showToast({
                    message: this.$t('value.contacts.groupsPage.alreadyExists')
                });
            } else if (result != 0) {
                let newGroup = {
                    'groupId': result,
                    'contactCount': 0,
                    'contactBeans': [],
                    'title': this.newGroupName,
                    'checked': false
                };
                this.dataflag = true;
                this.isEmpty = false;
                this.groupList.push(newGroup);
                this.$element('addGroupDialog').close();
            } else {
                LOG.error(TAG + 'add group error. code is ' + result.code)
            }
            this.$element('addGroupDialog').close()
        });

    },
    
    cancelDeleteGroup: function () {
        this.$element('deleteGroupDialog').close();
    },
    
    confirmDeleteGroup: function () {
        var actionData = {
            ids: []
        };
        this.groupList.forEach((item) => {
            LOG.info(TAG + 'confirmDeleteGroup item' + item)
            if (item.checked) {
                actionData.ids.push(item.groupId);
            }
        })
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.deleteGroups(DAHelper, actionData.ids, result => {
            this.getGroupList();
            this.checkedNum = 0;
            this.initTitle();
            this.$element('deleteGroupDialog').close();
            router.back();
        });

    },

    selectGroups() {
        var addConGroups = [];
        this.groupList.forEach((item) => {
            if (item.checked) {
                addConGroups.push({
                    groupId: item.groupId,
                    title: item.title,
                    checked: true,
                    id: 0
                })
            }
        })
        this.contactForm.groups = addConGroups;
        this.$app.$def.groups.group = addConGroups;
        LOG.info(TAG + 'selectGroups' + addConGroups)
        let params = {
            contactId: this.contactId,
            contactForm: this.contactForm,
            groups: addConGroups,
            groupStatus: true,
            addShow: this.addShow,
            updataShow: this.updataShow,
            screenDirection: this.screenDirection,
            MoreDivStatus: this.MoreDivStatus,
            LetterShow: this.LetterShow,
            upMessShow: this.upMessShow,
            upRingShow: this.upRingShow,
            upHouseShow: this.upHouseShow,
            upNickShow: this.upNickShow,
            upWebShow: this.upWebShow,
            upBirthShow: this.upBirthShow,
            upAssShow: this.upAssShow
        };
        this.$app.$def.globalData.groupParams = params;
        router.back();
    },

    back () {
        router.back({
            path:'pages/contacts/accountants/accountants'
        });
    },
    
    copy(obj) {
        LOG.info(TAG + 'copy obj' + obj)
        return JSON.parse(JSON.stringify(obj));
    },
}
