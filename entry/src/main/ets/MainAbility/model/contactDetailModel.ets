/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Constants from './common/Constants';
import Utils from '../util/Utils'
import callLogService from './calllog/CalllogModel';
import common from './common';
import HiLog from '../util/HiLog';
import router from '@system.router';
import ContactAbilityModel from './ContactAbilityModel'
import featureAbility from '@ohos.ability.featureAbility';
import prompt from '@system.prompt';
import LooseObject from '../model/bean/LooseObject'
import resourceManager from '@ohos.resourceManager';
import Birthday from '../contact/contract/Birthday';
import Relation from '../contact/contract/Relation';
import House from '../contact/contract/House';
import Aim from '../contact/contract/Aim';
import Email from '../contact/contract/Email';
import Phone from '../contact/contract/Phone';
import CallLogRepository from '../call/repo/CallLogRepository';
import ContactRepository from '../contact/repo/ContactRepository';
import CallLog from '../call/entity/CallLog';
import DbChangeHelper from '../model/common/DbChangeHelper';


/**
 * 联系人详情 逻辑
 */

var TAG = 'contactDetailModel';

const DELETE_CONTACT = 2003; // 删除联系人
const GET_CONTACT_DETAIL = 2005; // 获取详情


export default {
  // 用作刷新的标签
  flash: 0,
  // 更多选项menu
  moreMenuOptions: [$r("app.string.delete_contact")],
  // 短信跳转相关常量
  CONTRACTS: {
    MMS_BUNDLE_NAME: "com.ohos.mms",
    MMS_ABILITY_NAME: "com.ohos.mms.MainAbility",
    MMS_ENTITIES: 'entity.system.home'
  },
  // 信息的标签
  ITEMTAGS: {
    TAG_TELLIST: 0,
    TAG_EMAILLIST: 1,
    TAG_AIMLIST: 2,
    TAG_GIVENNAME: 3,
    TAG_WEBSITELIST: 4,
    TAG_HOUSELIST: 5,
    TAG_REMEMBRANCEDAY: 6,
    TAG_GROUP: 7,
    TAG_PINYINNAME: 8,
    TAG_ASSOCIATEDPERSON: 9,
    TAG_REMARKS: 10,
  },
  // 第一条信息的标签
  firstInfo: 0,
  /** 展示头像 */
  showHeaderFlag: true,
  /** Y坐标移动起始值 */
  pYStart: 0,
  /** Y坐标移动值 */
  pYMove: 0,
  /** 移动值计算 */
  directPoint: 0,
  directPointTemp: 0,
  /** 界面移动起始X坐标 */
  touchMoveStartX: 0,
  /** 界面移动起始Y坐标 */
  touchMoveStartY: 0,
  /** 收藏标记 */
  isFavorite: false,
  /** 新号码传入的详情展示信息 */
  newNumberContactDetail: {
    callTag: ''
  },
  /** 展示MENU延时标记 */
  showMenuTimeOutId: '',
  /** 长按电话号码对话框显示号码 */
  showPhoneNumber: '',
  /** 联系人所有电话号码数 */
  phoneNumbersLength: 0,
  /** 剪贴板内容 */
  copyToClipBoardContent: '',
  /** 长按地址弹出dialog的title */
  postalAddressName: '',
  /** 拨打电话的号码值 */
  sendNumber: '',
  /** 删除通话记录索引值 */
  deleteIndex: '',
  /**  长按电话号码的索引值 */
  numLongPressIndexIndex: 0,
  /** 页面全局X坐标 */
  globalX: '',
  /** 页面全局Y坐标 */
  globalY: '',
  /** 用于按钮显示折叠后的showNameLast */
  showNameLastMenu: '',
  /** 最终显示的头像未知的名称 */
  showNameLast: '',
  /** 二维码string值 */
  qrcodeString: '',
  /** 通话记录数据是否清除*/
  isCallLogClean: false,

  /** 根据联系人详情组装的展示用参数 */
  contactForm: {
    phones: [],
    emails: [],
    aims: [],
    nickname: '',
    websites: [],
    houses: [],
    events: [],
    remarks: '',
    relationships: [],
    pinYinName: '',
    alphaName: '',
    showGroupsString: '',
    name: '',
    display_name: '',
    namePrefix: '',
    lastName: '',
    company: '',
    position: '',
    numRecords: [],
    groups: [],
    /** 底部显示新建联系人底部图标 */
    showNewContact: false,
    isNewNumber: false,
  },
  /** 联系人临时 */
  contacts: {
    starred: 0,
    contactId: 0,
    organization: '',
    id: '',
    phones: [],
    emails: [],
    aims: [],
    nickname: '',
    websites: [],
    houses: [],
    events: [],
    remarks: '',
    relationships: [],
    pinYinName: '',
    alphaName: '',
    showGroupsString: '',
    name: {
      fullName: '',
    },
    display_name: '',
    namePrefix: '',
    lastName: '',
    company: '',
    position: '',
    numRecords: [],
    groups: [],
    detailsBgColor: '',
    portraitColor: '',
  },
  phoneNumbers: [
    {
      'phoneNumber': '',
      'phoneAddress': ''
    }
  ],
  /** 是否是新的优化后的请求接口，新接口调用参照收藏页面跳转，增加该字段 */
  isNewSource: false,
  /** 是否已经获取到contacts详情信息 */
  containContacts: false,
  /** 电话号码显示默认 */
  showSetDefault: false,
  /** 来自于通话记录跳转 */
  sourceFromCallRecord: false,
  /** 新号码传入的电话号 */
  phoneNumberShow: '',
  /** 联系人ID */
  contactId: '',
  /** 是新号码 */
  isNewNumber: false,

  onShow(callback) {
    // 优化后请求，新对接详情从该页面加载数据（群组，收藏，联系人列表从这里跳转）
    if (this.isNewSource) {
      HiLog.i(TAG, 'onShow:contact');
      let requestData = {
        contactId: this.contactId
      };
      this.getContactDetail(GET_CONTACT_DETAIL, requestData, () => {
        callback();
      });
    } else if (this.containContacts) {
      HiLog.i(TAG, 'onShow:add');
      // 新增编辑联系人后跳转至详情，contacts已经传入只加载通话记录
      this.dealRecordDetailsData();
    } else if (this.sourceFromCallRecord) {
      HiLog.i(TAG, 'onShow:newNum');
      // 未添加联系人且来自于通话记录跳转
      // 1.根据电话号码查询联系人id
      // 2.如果不存在联系人，则按照新号码处理，如果存在联系人，则根据第一个联系人id展示详情
      var DAHelper = common.getDAHelper(Constants.uri.CONTACT_DB_URI);
      ContactAbilityModel.getIdByTelephone(DAHelper, this.phoneNumberShow, (contactId) => {
        if (!Utils.isEmpty(contactId)) {
          // 存在联系人时，将isNewNumber置为false
          this.isNewNumber = false;
          let requestData = {
            contactId: contactId
          };
          this.getContactDetail(GET_CONTACT_DETAIL, requestData);
        } else {
          // 不存在联系人id则按照新号码处理
          this.getDetailAsNewNumber();
        }
      });
    }
    HiLog.i(TAG, ' onShow detail');
  },

  /* 没有联系人数据的情况下，显示电话号码的详情 */
  getDetailAsNewNumber() {
    var numbers = [this.phoneNumberShow.replace(/\s+/g, '')];
    this.getNewNumRecords(numbers);
  },

  /**
    * 清空通话记录弹窗
    */
  clearPhoneRecords() {
    HiLog.i(TAG, ' clearPhoneRecords');
    AlertDialog.show(
      {
        message: $r('app.string.clear_calllog_sure'),
        alignment: DialogAlignment.Bottom,
        autoCancel: false,
        primaryButton: {
          value: $r('app.string.cancel'),
          action: () => {
          }
        },
        secondaryButton: {
          value: $r('app.string.delete'),
          fontColor: "#da1232",
          action: () => {
            this.clearRecordsMore();
          }
        },
        cancel: () => {
          HiLog.i(TAG, 'Closed callbacks')
        },
        offset: {
          dx: 0, dy: -15
        },
      }
    )
  },

  /**
   * 删除联系人弹窗
   */
  deleteContact() {
    AlertDialog.show(
      {
        message: $r('app.string.delete_contact_sure'),
        alignment: DialogAlignment.Bottom,
        autoCancel: false,
        primaryButton: {
          value: $r('app.string.cancel'),
          action: () => {
          }
        },
        secondaryButton: {
          value: $r('app.string.delete'),
          fontColor: "#da1232",
          action: () => {
            HiLog.i(TAG, 'Callback when the second button is clicked')
            this.doDeleteContact();
          }
        },
        cancel: () => {
          HiLog.i(TAG, 'Closed callbacks')
        },
        offset: {
          dx: 0, dy: -15
        },
      }
    )
  },
  /**
   * 删除联系人
   */
  doDeleteContact() {
    ContactRepository.getInstance().deleteById(this.contactId).then((result) => {
      if (result == 0) {
        DbChangeHelper.getInstance().notifyChange(common.getDAHelper(Constants.uri.CONTACT_DB_URI), Constants.uri.CONTACT_URI);
        DbChangeHelper.getInstance().notifyChange(common.getDAHelper(Constants.uri.CALLLOG_DB_URI), Constants.uri.CALL_LOG_URI);
        router.back();
      } else {
        prompt.showToast({
          message: 'contactDetail Failed to delete data.'
        });
      }
    });
  },
  /**
    * 发送消息
    *
    * @param {number} phoneNumber 手机号码
    * @param {string} name 姓名
    */
  sendMessage(phoneNumber, name) {
    HiLog.i(TAG, 'sendMessage success');
    var params = [];
    params.push({
      contactsName: name,
      telephone: phoneNumber,
      telephoneFormat: phoneNumber
    });
    this.jumpToMms(params);
  },

  /**
   * 跳转短信app
   *
   * @param {string} params 跳转参数
   */
  jumpToMms(params) {
    let actionData: LooseObject = {};
    actionData.contactObjects = JSON.stringify(params);
    actionData.pageFlag = 'conversation';
    let str = {
      'want': {
        'bundleName': this.CONTRACTS.MMS_BUNDLE_NAME,
        'abilityName': this.CONTRACTS.MMS_ABILITY_NAME,
        'parameters': actionData,
        'entities': [
          this.CONTRACTS.MMS_ENTITIES,
        ]
      },
    };
    featureAbility.startAbility(str).then((data) => {
      HiLog.i(TAG, 'jumpToMms');
    }).catch((error) => {
      HiLog.e(TAG, 'jumpToMms,failed: %s', JSON.stringify(error.message));
    })
  },

  /** 编辑联系人 */
  updateContact() {
    // 新号码传入号码和归属地数据
    if (this.isNewNumber) {
      this.phoneNumbers[0].phoneNumber = this.phoneNumberShow;
      this.phoneNumbers[0].phoneAddress = this.contacts.phones[0].phoneAddress;
    }
    this.updateContacts();
  },

  updateContacts() {
    let upDataShow = false;
    if (!Utils.isEmpty(this.contactId)) {
      upDataShow = true
    }
    router.replace({
      uri: 'pages/contacts/accountants/Accountants',
      params: {
        updataShow: upDataShow,
        contactForm: this.contacts,
        phoneNumbers: this.phoneNumbers
      },
    });
  },

  /**显示隐藏更多选项*/
  getMore() {
    if (Boolean(this.contactForm.showMoreButton) == true) {
      this.contactForm.showMoreButton = false;
    }
    this.dealRecordDetailsData();
  },

  /**
     * 将obj对象实现深拷贝
     *
     * @param {Object} obj 联系人的contactForm
     * @return {Object} 返回拷贝对象
     */
  copy(obj) {
    return JSON.parse(JSON.stringify(obj));
  },

  /**
     * 获取联系人详细数据
     *
     * @param {number} code 2005 FA与PA通行协议码
     * @param {number} data contactId 联系人ID
     */
  getContactDetail(code, data, callback) {
    HiLog.i(TAG, 'go getContactDetail');
    var DAHelper = common.getDAHelper(Constants.uri.CONTACT_DB_URI);
    ContactAbilityModel.getContactById(DAHelper, data.contactId, result => {
      if (Utils.isEmpty(result)) {
        // 如果根据指定的id获取不到联系人，则按照新号码处理。
        this.getDetailAsNewNumber();
        return;
      }
      this.contacts = result.data;
      this.contacts.portraitColor = Constants.background.Color[Math.abs(parseInt(result.data.id, 10)) % 6];
      this.contacts.detailsBgColor = Constants.background.detailColor[Math.abs(parseInt(result.data.id, 10)) % 6];
      this.dealRecordDetailsData();
      callback();
    });
  },

  /**
     * 请求后台：获取联系人详细数据,同时获取通话记录数据后对展示数据进行组装
     */
  dealRecordDetailsData() {
    // 手机号码类型
    this.phoneNumberType();

    // 电子邮箱类型
    this.emailType();

    // 即时消息类型
    this.instantMessageType();

    // 住宅类型
    this.residentialType();

    // 生日类型
    this.eventsType();

    // 关联人类型
    this.relationshipsType();
    var newContacts = this.copy(this.contacts);

    var showGroupsString = '';

    this.contactForm.isNewNumber = false;
    this.contactForm.showMoreButton = false;
    this.contactForm.display_name = newContacts.display_name;
    var display_name = this.contactForm.display_name;
    var frist = display_name.substr(0, 1);
    this.contactForm.namePrefix = frist.toUpperCase();
    this.setContactForm(showGroupsString, newContacts);
    this.contactForm.company = newContacts.company
    this.contactForm.position = newContacts.position
    this.processingInitializationData(newContacts);
  },

  // 获取详细信息的类型
  // 电话号码类型
  phoneNumberType() {
    HiLog.i(TAG, 'phoneNumberType');
    if (this.contacts.hasOwnProperty('phones') && this.contacts.phones.length > 0) {
      this.contacts.phones.forEach((element) => {
        element.labelName = Phone.getTypeLabelResource(parseInt(element.numType, 10));
        // 归属地
        element.phoneAddress = (element.phoneAddress == 'N' || Utils.isEmpty(element.phoneAddress)) ? "未知" : element.phoneAddress;
      });
    }
  },
  // 邮箱类型
  emailType() {
    HiLog.i(TAG, 'emailType');
    if (this.contacts.hasOwnProperty('emails') && this.contacts.emails.length > 0) {
      this.contacts.emails.forEach((element) => {
        element.labelName = Email.getTypeLabelResource(parseInt(element.emailType, 10));
      });
    }
  },
  // aim类型
  instantMessageType() {
    HiLog.i(TAG, 'instantMessageType');
    if (this.contacts.hasOwnProperty('aims') && this.contacts.aims.length > 0) {
      this.contacts.aims.forEach((element) => {
            element.aimType = Aim.getTypeLabelResource(parseInt(element.aimType, 10));
      });
    }
  },
  // 住宅类型
  residentialType() {
    HiLog.i(TAG, 'residentialType');
    if (this.contacts.hasOwnProperty('houses') && this.contacts.houses.length > 0) {
      this.contacts.houses.forEach((element) => {
        element.houseType = House.getTypeLabelResource(parseInt(element.houseType, 10));
      });
    }
  },
  // 纪念日类型
  eventsType() {
    HiLog.i(TAG, 'eventsType');
    if (this.contacts.hasOwnProperty('events') && this.contacts.events.length > 0) {
      this.contacts.events.forEach((element) => {
        element.eventName = Birthday.getTypeLabelResource(parseInt(element.eventType, 10));
      });
    }
  },
  // 关联人类型
  relationshipsType() {
    HiLog.i(TAG, 'relationshipsType');
    if (this.contacts.hasOwnProperty('relationships') && this.contacts.relationships.length > 0) {
      this.contacts.relationships.forEach((element) => {
        element.associatedType = Relation.getTypeLabelResource(parseInt(element.associatedType, 10));
      });
    }
  },

  isTotalCountNumber(totalCountNumber, newContacts) {
    HiLog.i(TAG, 'isTotalCountNumber');
    totalCountNumber = (newContacts.phones && newContacts.phones.length > 0)
      ? totalCountNumber + newContacts.phones.length : totalCountNumber;

    totalCountNumber = (newContacts.emails && newContacts.emails.length > 0)
      ? totalCountNumber + newContacts.emails.length : totalCountNumber;

    totalCountNumber = (newContacts.aims && newContacts.aims.length > 0)
      ? totalCountNumber + newContacts.aims.length : totalCountNumber;

    totalCountNumber = (newContacts.nickname && newContacts.nickname
    && newContacts.nickname.length > 0) ? totalCountNumber + 1 : totalCountNumber;

    totalCountNumber = (newContacts.websites && newContacts.websites.length > 0)
      ? totalCountNumber + newContacts.websites.length : totalCountNumber;

    totalCountNumber = (newContacts.houses && newContacts.houses.length > 0)
      ? totalCountNumber + newContacts.houses.length : totalCountNumber;

    totalCountNumber = (newContacts.remarks && newContacts.remarks.noteContent
    && newContacts.remarks.noteContent.length > 0) ? totalCountNumber + 1 : totalCountNumber;

    totalCountNumber = (newContacts.events && newContacts.events.length > 0)
      ? totalCountNumber + newContacts.events.length : totalCountNumber;

    totalCountNumber = (newContacts.relations && newContacts.relations.length > 0)
      ? totalCountNumber + newContacts.relations.length : totalCountNumber;

    totalCountNumber = (newContacts.name && newContacts.name.familyNamePhonetic
    && newContacts.name.familyNamePhonetic.length > 0) ? totalCountNumber + 1 : totalCountNumber;

    totalCountNumber = (newContacts.groups && newContacts.groups.length > 0)
      ? totalCountNumber + 1 : totalCountNumber;

    return totalCountNumber;
  },

  setContactForm(showGroupsString, newContacts) {
    HiLog.i(TAG, 'setContactForm');
    this.contactForm.lastName = (newContacts.name && newContacts.name.nameSuffix
    && newContacts.name.nameSuffix.length > 0) ? newContacts.name.nameSuffix : '';

    this.contactForm.company = (newContacts.organization && newContacts.organization.name
    && newContacts.organization.name.length > 0) ? newContacts.organization.name : '';

    this.contactForm.position = (newContacts.organization && newContacts.organization.title
    && newContacts.organization.title.length > 0) ? newContacts.organization.title : '';

    this.contactForm.phones = (newContacts.phones && newContacts.phones.length > 0)
      ? newContacts.phones : [];

    this.contactForm.emails = (newContacts.emails && newContacts.emails.length > 0) ? newContacts.emails : [];

    this.contactForm.aims = (newContacts.aims && newContacts.aims.length > 0)
      ? newContacts.aims : [];

    this.contactForm.nickname = (newContacts.nickname && newContacts.nickname
    && newContacts.nickname.length > 0) ? newContacts.nickname : '';

    this.contactForm.websites = (newContacts.websites && newContacts.websites.length > 0)
      ? newContacts.websites : [];

    this.contactForm.houses = (newContacts.houses && newContacts.houses.length > 0)
      ? newContacts.houses : [];

    this.contactForm.events = (newContacts.events && newContacts.events.length > 0) ? newContacts.events : [];

    this.contactForm.remarks = (newContacts.remarks && newContacts.remarks.length > 0)
      ? newContacts.remarks : '';

    this.contactForm.relationships = (newContacts.relationships && newContacts.relationships.length > 0)
      ? newContacts.relationships : [];

    this.contactForm.pinYinName = (newContacts.pinYinName && newContacts.pinYinName.length > 0)
      ? newContacts.pinYinName : '';

    this.contactForm.showGroupsString = (showGroupsString && showGroupsString.length > 0) ? showGroupsString : '';
    this.contactForm.groups = (newContacts.groups && newContacts.groups.length > 0) ? newContacts.groups : [];
  },

  processingInitializationData(newContacts) {
    HiLog.i(TAG, 'processingInitializationData');
    if (!Utils.isEmptyList(this.contactForm.phones)) {
      var numbers = [];
      this.contactForm.phones.forEach(element => {
        numbers.push(element.num);
      });
      /* 获取到该联系人的所有电话号码的所有通话记录 */
      CallLogRepository.getInstance().findByNumberIn(numbers).then((resultList) => {
        this.contactForm.numRecords = this.getDetailMessage(resultList);
      });
      /* 根据获取到的通话记录原始数据封装详请页面需要的属性 */
    }
    // 处理初始化数据
    if (this.sourceFromCallRecord && this.isNewNumber) {
      this.showNameLast = (this.contactForm.phones && this.contactForm.phones[0])
        ? this.contactForm.phones[0].num : '';
    } else {
      this.showNameLast = (this.contactForm.display_name && this.contactForm.display_name.length > 0)
        ? this.contactForm.display_name : '';
    }
    this.showNameLastMenu = (this.showNameLast && this.showNameLast.length > 6)
      ? this.subStringWithEllipsis(this.showNameLast, 7) : this.showNameLast;
    // 将默认电话号码移动至最上边位置
    if (!Utils.isEmptyList(this.contactForm.phones)) {
      for (var i = 0; i < this.contactForm.phones.length; i++) {
        if (this.contactForm.phones[i].isPrimary === 1) {
          var tempPhoneNumber = newContacts.phones[i];
          this.contactForm.phones.splice(i, 1);
          this.contactForm.phones.unshift(tempPhoneNumber);
        }
      }
    }
  },

  sendNewContent() {
    router.push({
      uri: 'pages/contacts/selectContactsList/selectContactsList',
      params: {
        type: 'saveContacts',
        number: this.phoneNumberShow,
      }
    });
  },

  /**
     * 复制方法
     *
     * @param {string} data 需要复制的信息
     */
  copyNumber(data) {
    HiLog.i(TAG, 'copyNumber data');
    var actionData = {
      pasteBoardContent: "",
    };
    actionData.pasteBoardContent = data;
  },

  // 通话记录删除
  clearRecordsMore() {
    var id = '';
    var ids = [];
    for (let index = 0; index < this.contactForm.numRecords.length; index++) {
      id = this.contactForm.numRecords[index].id;
      ids.push(id);
    }
    this.removeCallLog(ids);
    this.contactForm.numRecords = [];
    this.contactForm.showMoreButton = false;
  },

  /**
     * 删除通话记录
     *
     * @param {Array} ids 删除的通话记录的id集
     */
  removeCallLog(ids) {
    HiLog.i(TAG, 'removeCallLog');
    CallLogRepository.getInstance().deleteByIdIn(ids).then(data => {
      HiLog.i(TAG, 'removeCallLog Success');
      this.contactForm.numRecords = null;
      this.isCallLogClean = true;
      DbChangeHelper.getInstance().notifyChange(common.getDAHelper(Constants.uri.CALLLOG_DB_URI), Constants.uri.CALL_LOG_URI);
    })
  },


  /* 新建联系人 */
  addContacts() {
    let show = this.phoneNumberShow.length > 0 ? true : false;
    router.push({
      uri: 'pages/contacts/accountants/Accountants',
      params: {
        addShow: true,
        updataShow: false,
        showWork: true,
        upHouseShow: true,
        phones: [
          {
            'id': '',
            'numType': 2,
            'labelName': '手机',
            'phoneNumber': this.phoneNumberShow,
            'phoneAddress': 'N',
            'blueStyle': false,
            'showP': show
          }]
      },
    });
  },

  /**
      * 截取字符串的前五个字符外加.. 例如：'哈哈哈哈哈哈哈哈' => '哈哈哈哈哈..'
      *
      * @param {string} str 对象字符串
      * @param {number} len 长度
      * @return {Object} newStr 截取后字符串
      */
  subStringWithEllipsis(str, len) {
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

  /**
     * 非联系人时，获取通话记录，组装参数
     *
     * @param {Array} numbers 手机号码
     */
  getNewNumRecords(numbers) {
    var actionData = {
      number: [],
      language: "",
    };
    actionData.number = numbers;
    var newContacts: LooseObject = {
      phones: [],
      name: {},
      isNewNumber: false,
      showMoreButton: false,
      numRecords: []
    };
    this.contactForm.isNewNumber = true;
    this.contactForm.showMoreButton = false;
    this.contactForm.name = this.phoneNumberShow;
    this.contactForm.showNewContact = true;
    CallLogRepository.getInstance().findByNumberIn(numbers).then((resultList) => {
      /* 根据获取到的通话记录原始数据封装详请页面需要的属性 */
      this.contactForm.numRecords = this.getDetailMessage(resultList);
      /* 创建联系人电话列表对象 */
      var phoneNumbersTemp = {
        id: 0,
        phoneAddress: "",
        num: "",
      };
      if (this.contactForm.numRecords.length > 0) {
        phoneNumbersTemp.phoneAddress = this.contactForm.numRecords[0].callTag;
      }
      phoneNumbersTemp.num = this.phoneNumberShow;
      var phoneNumbersTempList = [phoneNumbersTemp];
      this.contactForm.phones = phoneNumbersTempList;
      newContacts.phones = phoneNumbersTempList;
      // 组装 contacts: originalContacts
      newContacts.name = {
        'name': this.contactForm.name
      };
      newContacts.isNewNumber = this.contactForm.isNewNumber;
      newContacts.showMoreButton = this.contactForm.showMoreButton;
      newContacts.numRecords = this.contactForm.numRecords;
      /* 在新号码跳转详情界面中，使用通话记录第一条的id取模从头像背景色中获取获取 */
      newContacts.portraitColor = Constants.background.Color[Math.abs(parseInt(this.contactForm.numRecords[0].id, 10)) % 6];
      newContacts.detailsBgColor = Constants.background.detailColor[Math.abs(parseInt(this.contactForm.numRecords[0].id, 10)) % 6];
      this.contacts = newContacts;
      // 处理初始化数据
      if (this.sourceFromCallRecord && this.isNewNumber) {
        this.showNameLast = (this.contactForm.phones && this.contactForm.phones[0])
          ? this.contactForm.phones[0].num : '';
      } else {
        this.showNameLast = (this.contactForm.display_name && this.contactForm.display_name.length > 0)
          ? this.contactForm.display_name : '';
      }
      this.showNameLastMenu = (this.showNameLast && this.showNameLast.length > 6)
        ? this.subStringWithEllipsis(this.showNameLast, 7) : this.showNameLast;
    });
  },

  /**
     * 根据原始callLogList内容转化为通话记录详情需要的数据
     *
     * @param {Array} originList 原始通话列表
     * @return {Array} resultList 结果集
     */
  getDetailMessage(originList: CallLog[]) {
    var resultList = [];
    if (Utils.isEmptyList(originList)) {
      return resultList;
    }
    originList.forEach(element => {
      let contactDetailCallsItem = {
        id: element.id.toString(),
        phone: element.phoneNumber,
        name:  element.displayName,
        callTime: element.createTime.toString(),
        callType: element.callType,
        callTag: element.numberLocation,
        simType: element.simType.toString(),
        isHd: element.isHD,
        ringTime: element.ringDuration,
        formatNumber: element.formattedNumber,
        talkTime: this.getTalkTimeMessage(element),
        timeDetail: this.getTimeDetailByCallTime(element)
      };
      resultList.push(contactDetailCallsItem)
    });
    return resultList;
  },

  /**
     * 根据通话记录获取该通话记录的通话详情
     *
     * @param {Object} callLogElement 通话记录
     * @return {string} resultMessage 状态信息
     */
  getTalkTimeMessage(callLogElement: CallLog) {
    HiLog.i(TAG, 'getTalkTimeMessage callLogElement');
    var resultMessage: Resource = null;
    if (callLogElement.callType == 1) {
      // 呼入：直接显示通话时长
      resultMessage = this.getDescriptionByDuration(callLogElement.talkDuration);
    } else if (callLogElement.callType == 2) {
      // 呼出：通话时长为0时，为未接通，否则直接显示通话时长
      resultMessage = callLogElement.talkDuration == 0 ? $r('app.string.blockCall')
                                                   : this.getDescriptionByDuration(callLogElement.talkDuration);
    } else if (callLogElement.callType == 3) {
      // 未接：未接来电显示响铃时长
      resultMessage = this.getDescriptionByDuration(callLogElement.talkDuration);
    } else if (callLogElement.callType == 5) {
      // 拒接
      resultMessage = $r('app.string.reject');
    }
    return resultMessage;
  },

  /**
     * 根据指定的时间戳获取通话时长 timeDuration:单位s
     *
     * @param {number} timeDuration 时间周期
     * @return {Object} 返回时间单位
     */
  getDescriptionByDuration(timeDuration) {
    HiLog.i(TAG, 'getDescriptionByDuration timeDuration');
    var seconds = parseInt(timeDuration);
    if (seconds < 60) {
      // 一分钟以内
      return $r('app.string.secondsFormat', seconds);
    } else {
      var minutes = Math.floor(seconds / 60);
      if (minutes < 60) {
        // 一小时以内
        return $r('app.string.minutesSecondsFormat', minutes, seconds % 60);
      } else {
        var hours = Math.floor(minutes / 60);
        return $r('app.string.hourMinutesSecondsFormat', hours, minutes % 60, seconds % 3600 % 60);
      }
    }
  },

  /**
     * 根据通话记录生成时间获取时间细节信息
     *
     * @param {number} callTime 初始通话时间
     * @return {string} timeDetail 处理后的通话时间
     */
  getTimeDetailByCallTime(element: CallLog) {
    var callTime = element.createTime.toString();
    HiLog.i(TAG, 'getTimeDetailByCallTime callTime');
    // 获取通话记录的时间
    var callLogTime = new Date(parseInt(callTime, 10) * 1000);
    // 获取当前的系统时间
    var now = new Date();
    var yearDiff = now.getFullYear() - callLogTime.getFullYear();
    var monthDiff = now.getMonth() - callLogTime.getMonth();
    var dayDiff = now.getDate() - callLogTime.getDate();
    var hour = callLogTime.getHours();
    var timeDetail: string = '';
    var timeDetail = '';
    if (yearDiff == 0) { // 同一年份
      if (monthDiff == 0) { // 同一月份
        if (dayDiff == 0) { // 同一天
          /* 例：傍晚18:06 */
          timeDetail = this.getDayMessage(hour) + callLogTime.getHours() + ':'
          + (callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes());
          return timeDetail;
        }
      }
      timeDetail = (callLogTime.getMonth() + 1) + '月' + callLogTime.getDate() + '日' + ' '
      + this.getDayMessage(hour) + callLogTime.getHours() + ':'
      + (callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes());
    } else { // 不同年份：显示年月日
      timeDetail = callLogTime.getFullYear() + '年' + (callLogTime.getMonth() + 1) + '月'
      + callLogTime.getDate() + '日' + ' ' + this.getDayMessage(hour) + callLogTime.getHours() + ':'
      + (callLogTime.getMinutes() < 10 ? '0' + callLogTime.getMinutes() : callLogTime.getMinutes());
    }
    HiLog.i(TAG, ' timeDetail = ');
    return timeDetail;
  },

  /**
     * 根据小时数获取该时间在一天范围内的描述
     *
     * @param {number} hour 时间
     * @return {string} 时间节点
     */
  getDayMessage(hour) {
    HiLog.i(TAG, ' getDayMessage');
    if (hour >= 0 && hour < 5) {
      return '凌晨';
    }
    if (hour >= 5 && hour < 11) {
      return '上午';
    }
    if (hour >= 11 && hour < 13) {
      return '中午';
    }
    if (hour >= 13 && hour < 17) {
      return '下午';
    }
    if (hour >= 17 && hour < 19) {
      return '傍晚';
    }
    if (hour >= 19 && hour < 22) {
      return '晚上';
    }
    if (hour >= 22 && hour < 24) {
      return '半夜';
    }
  }
};
