/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import ContactAbilityModel from '../../model/ContactAbilityModel';
import WorkFactory, { WorkerType } from '../../workers/WorkFactory';
import { BusinessError } from '@ohos.base';
import { ArrayUtil, HiLog, sharedPreferencesUtils, StringUtil } from '../../../../../../common';
import sim from '@ohos.telephony.sim';
import formProvider from '@ohos.app.form.formProvider';
import formBindingData from '@ohos.app.form.formBindingData';
import { ActionDataType, CardDialogInfoType, CardDialogSimInfo, MissedCallListType, ObjNull } from '../type/commonType';
import { PhoneNumber } from '../../../../../../feature/phonenumber';
import prompt from '@ohos.promptAction';
import { ContactReturnObj } from '../../model/type';
import { SpeedDialCardDataType } from '../type/speedDialCardType';
import CallLogSetting from '../../../../../../feature/call/src/main/ets/CallLogSetting';
import { contactPage, infoString } from '../data/cardData';
import { CallLog } from '../../../../../../feature/call';
import { MissedCallDataShare } from './MissedCallDataShare';
import { MissedCallNotifyData } from '../../../../../../feature/call/src/main/ets/missedcall/MissedCallNotifier';
import Notification from '@ohos.notificationManager';
import contextConstant from '@ohos.app.ability.contextConstant';
import data_preferences from '@ohos.data.preferences';
import resourceManager from '@ohos.resourceManager';
import { DSDS_MODE_V2 } from '../../component/mutisim/DsdaConstants';
import { getDialDirectlyAccountId } from '../../model/CallStateModel';
import { ContactsGlobalThisHelper } from '../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { RoamingData, RoamingUtils } from '../../../../../../common/src/main/ets/util/RoamingUtils';
import { RoamingManager } from '../../feature/roaming/RoamingManager';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import taskpool from '@ohos.taskpool';
import { queryContactNameByNumber } from '../../../../../../feature/contact/src/main/ets/repo/ContactRepository';
import ContactNameNumberInfo from '../../../../../../feature/contact/src/main/ets/entity/ContactNameNumberInfo';
import Banner from './utils/Banner';
import { PhoneNumBean } from '../../model/bean/PhoneNumBean';
import WorkerWrapper from '../../workers/base/WorkerWrapper';
import { RichContactInfo } from '../../model/bean/RichContactInfo';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { SimCardType } from '../../data/Constants';

const TAG = 'formCardController';
const KEY_MISSED_BADGE_NUM = 'missed_badge_number'
const GROUP_NAME: string = 'MissedCall'

/**
 * Form Card Controller
 */
export class FormCardController {
  private static sInstance: FormCardController;
  public mDataWorker = WorkFactory.getWorker(WorkerType.DataWorker);
  public simStateStatusCardOne: boolean = false;
  public simStateStatusCardTwo: boolean = false;
  public isEmergencyNum: boolean = false;
  public resultDT: boolean = false;

  static getInstance() {
    if (FormCardController.sInstance == null) {
      FormCardController.sInstance = new FormCardController();
    }
    return FormCardController.sInstance;
  }

  aboutToAppear() {
    sharedPreferencesUtils.init(ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext());
    HiLog.w(TAG, 'aboutToAppear!');
  }

  // 获取收藏联系人
  public getFavoriteByIndex(index: number, callback: (favList: SpeedDialCardDataType[]) => void) {
    let actionData: Record<string, number> = {};
    actionData.favorite = 1;
    if (this.mDataWorker) {
      this.mDataWorker.sendRequest('getFavoriteByIndex', {
        actionData: actionData,
        index: index,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext()
      }, async (result: SpeedDialCardDataType[]) => {
        HiLog.w(TAG, `getFavoriteByIndex data success! `);
        callback(result);
      })
    }
  }

  // 通过id数组获取联系人
  public getContactByIdList(
    idList: Array<string>,
    callback: (contactList: SpeedDialCardDataType[]) => void) {
    if (ArrayUtil.isEmpty(idList)) {
      HiLog.e(TAG, 'The parameter IDList is empty.');
      callback([]);
      return;
    }
    HiLog.w(TAG, `[idList]`);
    if (this.mDataWorker) {
      this.mDataWorker.sendRequest('getContactByIdList', {
        contactIdList: idList,
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext()
      }, (result: SpeedDialCardDataType[]) => {
        HiLog.w(TAG, '[getContactByIdList result]');
        let count: number = 0;
        result.forEach((item: SpeedDialCardDataType, index: number) => {
          const regex = new RegExp('.', 'gu');
          result[index].displayName = item.displayName.replace(regex, '$&\u200B');
          result[index].showName = item.showName.replace(regex, '$&\u200B');
          let contactId: string = item.contactId;
          this.getContactPhonesById(contactId, (res: ContactReturnObj) => {
            HiLog.w(TAG, '[getContactByIdList res]');
            if (res.data) {
              result[index].phones = res.data?.phones;
              result[index].id = Number(res.data.contactID);
              result[index].photoFirstName = res.data.photoFirstName;
              count++;
              if (count === result.length) {
                HiLog.w(TAG, 'result' + result.length);
                callback(result);
              }
            }
          })
        })
      })
    }
  }

  // 通过手机号获取联系人
  public getContactByPhones(callLog: Array<Record<string, string>>, contactType: number, callback: Function) {
    let actionData: Record<string, Object> = {};
    actionData.numberList = this.getNumberList(callLog);
    actionData.contactType = contactType;
    let context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
    let task = new taskpool.Task(queryContactNameByNumber, context, this.getNumberList(callLog), contactType);
    taskpool.execute(task).then((contactInfosObject: Object) => {
      let contactInfos = contactInfosObject as ContactNameNumberInfo[];
      let numberMap: Map<string, string> = new Map();
      contactInfos.forEach((item: ContactNameNumberInfo) => {
        if (!numberMap.has(item.phoneNumber) && !StringUtil.isEmpty(item.name)) {
          numberMap.set(item.phoneNumber, item.name);
        }
      })
      HiLog.w(TAG, 'getContactByPhoneNums getNumberMap success');
      let filterLog: Record<string, string>[] = []
      for (let item of callLog) {
        if (numberMap.has(item.phoneNumber)) {
          filterLog.push(item)
        }
      }
      callback(filterLog);
    })
  }

  getNumberList(callLog: Array<Record<string, string>>): Array<string> {
    let numberList: Set<string> = new Set();
    for (let item of callLog) {
      numberList.add(item.phoneNumber);
    }
    return Array.from(numberList);
  }

  getNumberMap(contacts: Array<Record<string, string>>): Map<string, string> {
    let numberMap: Map<string, string> = new Map();
    for (let item of contacts) {
      if (!numberMap.has(item.detailInfo) && !StringUtil.isEmpty(item.displayName)) {
        numberMap.set(item.detailInfo, item.displayName);
      }
    }
    return numberMap;
  }

  public getFirstMissedCall(formId: string, formName: string) {
    let actionData: ActionDataType = new ActionDataType();
    let favoriteForm: ObjNull = new ObjNull();
    actionData.mergeRule = CallLogSetting.getInstance().getMergeRule();
    actionData.favoriteForm = JSON.stringify(favoriteForm);
    if (this.mDataWorker) {
      this.mDataWorker.sendRequest('getFirstMissedCall', {
        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext(),
        actionData: actionData,
      }, async (data: CallLog[]) => {
        HiLog.w(TAG, 'getFirstMissedCall data length:' + data.length);
        let obj: MissedCallListType = {
          callLog: data,
          formId: formId,
          title: 'missedCall'
        }
        let formData = formBindingData.createFormBindingData(obj);
        HiLog.w(TAG, 'getFirstMissedCall formData end');
        this.updateToCard(formId, formData);
      })
    }
  }

  public async setMissedCallToRead(phone: string[]) {
    const dataShare = new MissedCallDataShare();
    await dataShare?.initData()
    await dataShare?.setMissedLogToRead(phone)
  }

  public async setMissedCallBadgeNumberByPhone(phoneList: string[]) {
    HiLog.w(TAG, `setMissedCallBadgeNumber start list count: ${phoneList?.length}`);
    try {
      let result: Array<MissedCallNotifyData> = [];
      const notifications: Array<Notification.NotificationRequest> =
        await Notification.getActiveNotifications()
      for (let notify of notifications) {
        if (notify.groupName?.startsWith(GROUP_NAME) && notify.extraInfo) {
          result.push(notify.extraInfo as MissedCallNotifyData);
        }
      }
      let ctx = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
      let res = $r('app.string.missed_call');
      let resource: resourceManager.Resource = {
        bundleName: res.bundleName,
        moduleName: res.moduleName,
        id: res.id
      }
      let idList: number[] = []
      let missCount: number = 0;
      let badgeNumber: number = 0;
      result.forEach((item: MissedCallNotifyData) => {
        if (item.count != undefined) {
          badgeNumber += item.count;
        }
        phoneList.forEach(phone => {
          if (item.phoneNumber === phone) {
            if (item.id) {
              idList.push(item.id)
            }
            if (item.count != undefined) {
              missCount = item.count;
            }
          }
        })
      })
      let label = ctx.resourceManager.getStringSync(resource);
      idList.forEach(id => {
        Notification.cancel(id, label);
      })
      ctx.area = contextConstant.AreaMode.EL1
      let preferences: data_preferences.Preferences = await data_preferences.getPreferences(ctx, 'CONTACT_PREFERENCE')
      HiLog.w(TAG, `setMissedCallBadgeNumber badgeNumber->${badgeNumber}`);
      badgeNumber -= missCount;
      HiLog.w(TAG, `setMissedCallBadgeNumber -1 badgeNumber->${badgeNumber}`);
      if (badgeNumber >= 0) {
        Notification.setBadgeNumber(badgeNumber);
        await preferences.put(KEY_MISSED_BADGE_NUM, badgeNumber);
        preferences.flush();
        ;
        HiLog.w(TAG, `setMissedCallBadgeNumber put success`);
      }
    } catch (e) {
      HiLog.e(TAG, 'setMissedCallBadgeNumber catch error: ' + (e as BusinessError).message);
    }
  }

  public getContactPhonesById(contactId: string, callback: (result: ContactReturnObj) => void): void {
    ContactAbilityModel.getContactById(Number(contactId),
      (data: ContactReturnObj) => {
        if (data) {
          HiLog.w(TAG, 'getContactPhonesById callback');
          callback(data);
        }
      },
      ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext());
  }

  getSimStateDataCard(slotId: number) {
    HiLog.w(TAG, 'getSimStateDataCardOne');
    return new Promise((resolve: (value: boolean) => void, reject: (value: boolean) => void) => {
      try {
        sim.getSimState(slotId).then((value) => {
          HiLog.w(TAG, 'getSimStateDataCardOne resolve' + value);
          if (value === 4 || value === 5) {
            this.simStateStatusCardOne = true;
            resolve(true);
          } else {
            resolve(false);
          }
        }).catch((error: BusinessError) => {
          HiLog.e(TAG, 'getSimStateDataCardOne error: ' + error.message);
          reject(false);
        });
      } catch (error) {
        HiLog.e(TAG, 'getSimStateDataCardOne catch error: ' + (error as BusinessError).message);
        reject(false);
      }
    });
  }

  public mergeDuplicateNumbers(phoneList: PhoneNumBean[]) {
    let newPhoneList: PhoneNumBean[] = []
    for (let i = 0; i < phoneList.length; i++) {
      let isDuplicate = false
      for (let j = 0; j < newPhoneList.length; j++) {
        if (newPhoneList[j].num === phoneList[i].num) {
          isDuplicate = true
          break
        }
      }
      if (!isDuplicate) {
        newPhoneList.push(phoneList[i])
      }
    }
    return newPhoneList
  }

  public getContactPhone(contactId: string) {
    HiLog.w(TAG, 'getContactPhone contactId');
    this.getContactPhonesById(contactId, async (res: ContactReturnObj) => {
      HiLog.w(TAG, 'getContactPhone res.data');
      if (res.data) {
        let phones: PhoneNumBean[] = this.mergeDuplicateNumbers(res.data.phones);
        if (phones.length !== 0) {
          let phoneList: string[] = [];
          res.data.phones.forEach(item => {
            phoneList.push(item.num);
          })
          this.setMissedCallBadgeNumberByPhone(phoneList);
          this.setMissedCallToRead(phoneList);

          let hasDefaultNum: boolean = false;
          let defaultNum: string;
          let defaultPhone: PhoneNumBean | undefined;
          phones.forEach(item => {
            if (item.primary) {
              hasDefaultNum = item.primary;
              defaultNum = item.num;
              defaultPhone = item;
            }
          })

          let simPromiseList: Promise<boolean>[] = [];
          let simList: CardDialogSimInfo[] = [];
          let simCount: number = sim.getMaxSimCount();
          let spnList = AppStorage.Get<Array<string | Resource>>('spnList') ?? [];
          HiLog.w(TAG, `sim name is ${spnList}`)
          for (let i = 0; i < simCount; i++) {
            let simLabel: sim.SimLabel = sim.getSimLabelSync(i);
            simPromiseList.push(new Promise(async (resolve) => {
              let item: CardDialogSimInfo = {
                state: await sim.isSimActive(i) ?? false,
                slotId: i,
                name: spnList[i] === '' ? $r('app.string.NoService') : spnList[i],
                img: $r(`sys.symbol.phone_badge_` + (i + 1)),
                simType: simLabel.simType === sim.SimType.ESIM ? SimCardType.ESIM : SimCardType.PSIM,
                index: simLabel.index,
              }
              simList[i] = item;
              resolve(true);
            }))
          }

          Promise.all(simPromiseList).then(() => {
            let activeSimCount: number = 0;
            let aloneActiveSim: number = -1;
            simList.forEach((item, index) => {
              if (item.state) {
                activeSimCount++;
                aloneActiveSim = index;
              }
            })
            HiLog.w(TAG, `activeSimCount:${activeSimCount} , aloneActiveSim:${aloneActiveSim}`);
            let formatPhoneNumPromiseList: Promise<boolean>[] = []
            phones.forEach(item => {
              formatPhoneNumPromiseList.push(new Promise(async (resolve) => {
                item.displayNum = await new PhoneNumber(item.num).format();
                item.contactId = (res.data as RichContactInfo).contactID ?? '';
                resolve(true);
              }))
            })
            Promise.all(formatPhoneNumPromiseList).then(async () => {
              let dialogInfo: CardDialogInfoType = {
                flag: 'selectNum',
                phoneList: phones,
                simList: simList,
                lastSimId: -1
              }
              if (phones.length === 1 && !hasDefaultNum) {
                defaultNum = phones[0].num;
                defaultPhone = phones[0];
              }
              HiLog.w(TAG, `phones.length:${phones.length} `);
              if (phones.length === 1 || hasDefaultNum) {
                dialogInfo.flag = 'selectSim';
                let defaultVoiceSlotId: number
                try {
                  defaultVoiceSlotId = await sim.getDefaultVoiceSlotId()
                } catch (e) {
                  defaultVoiceSlotId = -1
                }
                if (defaultVoiceSlotId !== -1) {
                  this.startRoamingNumberDialog(defaultPhone, defaultVoiceSlotId);
                } else {
                  if (activeSimCount === 0) {
                    this.notHaveSimCard(defaultNum, 0);
                  } else if (activeSimCount === 1) {
                    this.startRoamingNumberDialog(defaultPhone, aloneActiveSim);
                  } else {
                    ContactsGlobalThisHelper.GetGlobalThis()
                      .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('findByNumberIn', {
                      actionData: {
                        context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardDialogContext(),
                        numbers: [defaultNum],
                        limit: 1,
                        page: 1
                      }
                    }, (resultList: CallLog[]) => {
                      HiLog.w(TAG, `findByNumberIn resultList:`);
                      if (!ArrayUtil.isEmpty(resultList)) {
                        dialogInfo.lastSimId = resultList[0].simId;
                      } else {
                        dialogInfo.lastSimId = -1;
                      }
                      Banner.getInstance().bannerStart(dialogInfo);
                    });
                  }
                }
              } else {
                Banner.getInstance().bannerStart(dialogInfo);
              }
            })
          })
        } else {
          try {
            prompt.showToast({
              message: $r('app.string.no_number_available')
            });
          } catch (err) {
            HiLog.e(TAG, 'getContactPhone, prompt.showToast err: ' + err?.message);
          }
          HiLog.e(TAG, ' popupSelectNumber phones null');
        }
      }
    })
  }

  getMaxSimCount(): number {
    return sim.getMaxSimCount();
  }

  isSimActive(slotId: number): Promise<boolean> {
		return sim.isSimActive(slotId);
	}

  async dealCallNumber(phoneNum: string) {
    let simCount: number = this.getMaxSimCount();
    let simStateOne: boolean = false;
    let simStateTwo: boolean = false;
    switch (simCount) {
      case 1:
        simStateOne = await this.isSimActive(0) ?? false;
        break;
      case 2:
        simStateOne = await this.isSimActive(0) ?? false;
        simStateTwo = await this.isSimActive(1) ?? false;
        break;
    }
    let defaultVoiceSlotId: number
    try {
      defaultVoiceSlotId = await sim.getDefaultVoiceSlotId()
    } catch (e) {
      defaultVoiceSlotId = -1
    }
    HiLog.w(TAG, `dealCallNumber simState ${simStateOne},${simStateTwo}`);
    HiLog.w(TAG, `dealCallNumber defaultVoiceSlotId ${defaultVoiceSlotId}`);
    let haveMultiSimCard = simStateOne && simStateTwo;
    let haveSimCard = simStateOne || simStateTwo;
    if (!haveSimCard) {
      HiLog.w(TAG, 'No SIM card!');
      this.notHaveSimCard(phoneNum, !simStateOne ? 1 : 0);
    } else if (defaultVoiceSlotId !== -1) {
      this.buildPhoneBean(phoneNum).then((phoneBean) => {
        this.startRoamingNumberDialog(phoneBean, defaultVoiceSlotId);
      });
    } else if (haveMultiSimCard) {
      this.dealMultiCardNumber(phoneNum);
    } else {
      HiLog.w(TAG, 'getContactPhone');
        this.buildPhoneBean(phoneNum).then((phoneBean) => {
          this.startRoamingNumberDialog(phoneBean, simStateOne ? 0 : 1);
      });
    }
  }

  callSharingNumber(phoneNum: string) {
    HiLog.i(TAG, 'StaticSubscriber callSharingNumber');
    this.buildPhoneBean(phoneNum).then((phoneBean) => {
      this.startRoamingNumberDialog(phoneBean, 0);
    });
  }

  clickToContactDetail(actionData: Record<string, string>, context: Context) {
    HiLog.w(TAG, 'clickToContactDetail');
    this.jumpToContactDetailForResult(actionData, context, 'page');
  }

  clickToContactRecord(context: Context, startAbilityPage: string) {
    HiLog.w(TAG, 'clickToContactRecord');
    let actionData: Record<string, string> = {
      'pageFlag': startAbilityPage
    };
    this.jumpToContactDetailForResult(actionData, context, 'page');
  }

  startDialogUIAbility(context: Context, startAbilityPage: string, param?: string) {
    HiLog.w(TAG, 'clickToContactRecord');
    let actionData: Record<string, string> = {
      'pageFlag': startAbilityPage,
      'phoneNumber': param as string
    };
    this.jumpToContactDetailForResult(actionData, context, 'dialog');
  }

  async jumpToContactDetailForResult(actionData: Record<string, string>, context: Context, flag: string) {
    const want: Want = {
      bundleName: infoString.CONTACT_BUNDLE_NAME,
      abilityName: flag === 'dialog' ? 'DiologEntryAbility' : infoString.CONTACT_ABILITY_NAME,
      parameters: actionData,
      entities: [
        infoString.COMMON_ENTITIES
      ]
    };
    (context as common.UIAbilityContext).startAbility(want).then(() => {
      HiLog.w(TAG, 'jumpToContact, startAbility Success');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'jumpToContact, failed. Cause: ' + error?.message);
    });
  }

  public notHaveSimCard(phoneNum: string, accountId?: number) {
    PhoneNumber.fromString(phoneNum).isDialEmergencyNum().then((res) => {
      this.isEmergencyNum = res;
      if (!this.isEmergencyNum) {
        HiLog.w(TAG, 'Is not Emergency Phone Number!');
        PhoneNumber.fromString(phoneNum).dial({
          accountId: accountId
        });
      } else {
        HiLog.w(TAG, 'No SIM card, but is Emergency Phone Number');
        PhoneNumber.fromString(phoneNum).dial({
          accountId: accountId
        });
      }
    })
  }

  // 将数据更新到卡片
  public updateToCard(formId: string, data: formBindingData.FormBindingData) {
    formProvider.updateForm(formId, data).then(() => {
      HiLog.w(TAG, `updateToCard updateForm success, formId: ${formId}`);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `[updateToCard err]: ${err?.message}, [formId]: ${formId}`);
    })
  }

  public async handleRoamingNumber(phoneInfo: PhoneNumBean | undefined, slotId: number, callback: Function) {
    if (phoneInfo == undefined) {
      HiLog.e(TAG, 'handleRoamingNumber phones null');
      callback(undefined);
      return;
    }
    let context: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
    let callLogFormatNum: string | undefined =
      await RoamingManager.getInstance().queryValidFormatNumber(context, phoneInfo.num);
    RoamingUtils.getRoamingDialNumber(phoneInfo.num, phoneInfo.formatNum, callLogFormatNum, slotId)
      .then((phoneList: string[]) => {
      if (!phoneList || phoneList.length === 0) {
        try {
          prompt.showToast({
            message: $r('app.string.no_number_available')
          });
        } catch (err) {
          HiLog.e(TAG, 'handleRoamingNumber, prompt.showToast err: ' + err?.message);
        }
        HiLog.e(TAG, ' popupSelectNumber phones null');
        callback(undefined);
        return;
      }
      HiLog.w(TAG, `phoneList length is: ${phoneList.length} `);
      if (phoneList.length === 1) {
        PhoneNumber.fromString(phoneList[0]).dial({
          accountId: slotId
        });
        callback(undefined);
      } else {
        this.buildPhoneBeans(context, phoneList, phoneInfo.numType).then((phones: PhoneNumBean[]) => {
          let dialogInfo: CardDialogInfoType = {
            flag: 'selectRoamingNum',
            phoneList: phones,
            simList: [this.buildCardDialogSimInfo(slotId)],
            lastSimId: -1,
            roamingOriginNumber: phoneInfo.num,
            roamingOldFormatNumber: phoneInfo.formatNum
          }
          callback(dialogInfo);
        })
      }
    });
  }

  public async buildPhoneBeans(context: Context, phoneList: string[], type: string): Promise<PhoneNumBean[]> {
    let phones: PhoneNumBean[] = [];
    if (phoneList.length === 0) {
      return phones;
    }
    let locations: string[] = await RoamingManager.getInstance().getLocations(phoneList, context);
    if (locations.length !== phoneList.length) {
      locations = new Array(phoneList.length).fill($r('app.string.unknow_location'));
    }
    for (let i = 0; i < phoneList.length; i++) {
      let numLocation: string | Resource = (StringUtil.isEmpty(locations[i]) || locations[i] === 'N') ?
      $r('app.string.unknow_location') : locations[i];
      phones.push(new PhoneNumBean('', phoneList[i], type, '', '', false, -1, numLocation))
    }
    return phones;
  }

  public dealMultiCardNumber(phoneNum: string) {
    const directAccountId = getDialDirectlyAccountId(DSDS_MODE_V2)
    if (directAccountId !== undefined) {
      // 3.0 case!
      HiLog.w(TAG, 'Call directly through sim ' + directAccountId);
      this.buildPhoneBean(phoneNum).then((phoneBean) => {
        this.startRoamingNumberDialog(phoneBean, directAccountId);
      });
      return;
    }
    let startAbilityPage = contactPage.MULTI_SIM_DIALOG;
    let context: Context = ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardContext();
    this.startDialogUIAbility(context, startAbilityPage, phoneNum);
  }

  private startRoamingNumberDialog(phoneInfo: PhoneNumBean | undefined, slotId: number) {
    this.handleRoamingNumber(phoneInfo, slotId, (dialogInfo: CardDialogInfoType | undefined) => {
      if (dialogInfo) {
        Banner.getInstance().bannerStart(dialogInfo);
      }
    });
  }

  private buildCardDialogSimInfo(slotId: number): CardDialogSimInfo {
    let spnList = AppStorage.Get<Array<string | Resource>>('spnList') ?? [];
    let simInfo: CardDialogSimInfo = {
      state: sim.isSimActiveSync(slotId) ?? false,
      slotId: slotId,
      name: spnList[slotId] === '' ? $r('app.string.NoService') : spnList[slotId],
      img: $r(`sys.symbol.phone_badge_` + (slotId + 1)),
      simType: SimCardType.PSIM,
      index: slotId + 1,
    }
    return simInfo;
  }

  private async buildPhoneBean(phoneNum: string): Promise<PhoneNumBean> {
    return new Promise((resolve) => {
      RoamingManager.getInstance().queryFormatNumberTask(phoneNum, (data: RoamingData | undefined) => {
        HiLog.w(TAG, `query format number success`);
        let phoneBean: PhoneNumBean = new PhoneNumBean('', phoneNum, String(data?.labelId ?? 7), '', '');
        phoneBean.formatNum = data?.formatNumber;
        resolve(phoneBean);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'query format number error: ' + error.message);
        resolve(new PhoneNumBean('', phoneNum, '7', '', ''));
      });
    });
  }

  // create random
  public async createRandom(): Promise<Uint8Array> {
    let rand = cryptoFramework.createRandom();
    let seed = new Uint8Array([1, 2, 3]);
    rand.setSeed({
      data: seed
    });
    let len = 12;
    let randOutput = await rand.generateRandom(len);
    let data = randOutput.data;
    HiLog.i(TAG, `createRandom end`);
    return data;
  }
}

class AbilityActionDataType {
  public pageFlag: string = ''
  public contactId: string = ''
  public phoneNumber: string = ''
}