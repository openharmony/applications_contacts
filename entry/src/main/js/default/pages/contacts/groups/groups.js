/**
 *  @file group
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
import groupReq from '../../../../default/model/GroupsModel.js';
import prompt from '@system.prompt';
import LOG from '../../../utils/ContactsLog.js';
import Constants from '../../../../default/common/constants/Constants.js';

var TAG = 'Groups...:';

export default {
    data: {
        page: 0, // Initial load current page
        limit: 20,
        groupList: [],
        newGroupName: '', // Group name of the new group
        updateGroupName: '', // Update the group name of the group
        menuGroupName: '',
        dialogInputActive: false,
        showEmptyPage: false,
        operateItem: {
            title: '',
            groupId: 0
        }
    },

    onInit() {
        LOG.info(TAG + 'onInit success');
    },
    onShow() {
        LOG.info(TAG + 'onShow success');
        this.page = 0;
        var requestData = {
            page: this.page,
            limit: this.limit
        };
        this.getGroupList(requestData);
    },

    getGroupList: function (actionData) {
        LOG.info(TAG + 'getGroupList actionData' + actionData);
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryGroups(DAHelper, actionData, result => {
            setInterval(() => {
                LOG.info(TAG + 'delay 1 s');
            }, 1000);
            if (this.page == 0) {
                this.groupList = result;
            } else {
                this.groupList = this.groupList.concat(result);
            }
            if (this.groupList.length == 0) {
                this.showEmptyPage = true;
            } else {
                this.showEmptyPage = false;
            }
        });
    },

    requestItem: function () {
        this.page++;
        var requestData = {
            page: this.page,
            limit: this.limit
        };
        this.getGroupList(requestData);
    },

    back: function () {
        router.back();
    },

    recentContactsClicked: function () {
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.queryRecentContactsCount(DAHelper, result => {
            router.push({
                uri: 'pages/contacts/groups/recentContacts/recentContacts',
                params: {
                    count1: result.count1,
                    count2: result.count2,
                    count3: result.count3,
                    count4: result.count4
                },
            });
        });
    },

    groupItemClick: function (item) {
        LOG.info(TAG + 'groupItemClick item' + item);
        router.push({
            uri: 'pages/contacts/groups/groupMembersList/groupMembersList',
            params: {
                groupItem: item
            },
        });
    },

    listItemTouchStart: function (event) {
        this.position = {};
        this.position.X = Math.round(event.touches[0].globalX);
        this.position.Y = Math.round(event.touches[0].globalY);
    },

    groupLongPress: function (item) {
        this.operateItem.title = item.title;
        this.operateItem.groupId = item.groupId;
        if (item.title.length > 4) {
            this.menuGroupName = item.title.substring(0, 4) + '..';
        } else {
            this.menuGroupName = item.title;
        }
        var tempX = this.position.X > 360 ? 360 : this.position.X;
        var tempY = this.position.Y > 1100 ? 1100 : this.position.Y;
        clearTimeout(this.menuTimeOutId);
        this.menuTimeOutId = setTimeout(() => {
            this.$element('groupItemMenu').show({
                x: tempX,
                y: tempY
            });
        }, 1);
    },

    todoSelected: function (event) {
        if (event.value == 'delete') {
            this.$element('deleteGroupDialog').show();
        }
        if (event.value == 'rename') {
            this.$element('renameGroupDialog').show();
        }
    },

    confirmDeleteGroup: function () {
        this.$element('deleteGroupDialog').close();
        var actionData = {
            ids: [this.operateItem.groupId]
        };
        LOG.info(TAG + 'start deleteGroups');
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.deleteGroups(DAHelper, actionData.ids, result => {
            this.onShow();
        });
    },

    changeStyle: function () {
        this.dialogInputActive = true;
    },

    cancelDeleteGroup: function () {
        this.$element('deleteGroupDialog').close();
    },

    groupNameChanged: function (e) {
        LOG.info(TAG + 'groupNameChanged e' + e);
        this.newGroupName = e.value;
    },

    renameGroupNameChanged: function (e) {
        LOG.info(TAG + 'renameGroupNameChanged e' + e);
        this.updateGroupName = e.value;
    },

    confirmUpdateGroup: function () {
        this.$element('renameGroupDialog').close();
        if (this.updateGroupName == this.operateItem.title) {
            return;
        }
        var actionData = {};
        actionData.title = this.updateGroupName;
        actionData.groupId = this.operateItem.groupId;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);
        groupReq.updateGroup(DAHelper, actionData, data => {
            if (data == 0) {
                this.groupList.forEach((item) => {
                    if (item.groupId == this.operateItem.groupId) {
                        item.title = actionData.title;
                    }
                });
            } else if (data == -2) {
                prompt.showToast({
                    message: this.$t('value.contacts.groupsPage.alreadyExists')
                });
            } else {
                LOG.error(TAG + 'add group error. code is ' + data);
            }
        });
    },

    confirmAddGroup() {
        var actionData = {};
        actionData.title = this.newGroupName;
        var DAHelper = this.$app.$def.getDAHelper(Constants.uri.CONTACT_DB_URI);

        groupReq.addGroup(DAHelper, this.newGroupName, (result) => {
            LOG.error(TAG + 'confirmAddGroup  result' + result);
            if (result == -2) {
                prompt.showToast({
                    message: this.$t('value.contacts.groupsPage.alreadyExists')
                });
            } else if (result != 0) {
                let newGroup = {
                    'groupId': result,
                    'contactCount': 0,
                    'contactBeans': [],
                    'title': this.newGroupName
                };
                this.groupList.push(newGroup);
                LOG.info(TAG + 'newgroup' + newGroup);
                router.push({
                    uri: 'pages/contacts/groups/groupMembersList/groupMembersList',
                    params: {
                        groupItem: newGroup
                    },
                });
            } else {
                LOG.error(TAG + 'add group error. result is ' + result);
            }
            this.$element('addGroupDialog').close();
        });
    },

    cancelAddGroup() {
        this.$element('addGroupDialog').close();
    },

    clickAddGroup(e) {
        LOG.info(TAG + 'clickAddGroup e' + e);
        this.newGroupName = '';
        this.$element('addGroupDialog').show();
    },

    cancelUpdateGroup() {
        this.$element('renameGroupDialog').close();
    },

    clickUpdateGroup(e) {
        LOG.info(TAG + 'clickUpdateGroup e' + e);
        this.$element('renameGroupDialog').show();
    },

    deleteGroup: function () {
        router.push({
            uri: 'pages/contacts/groups/deleteGroup/deleteGroup',
            params: {},
        });
    }
};