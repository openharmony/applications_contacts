/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { CustomizedParams } from '../model/type';
import hiSysEvent from '@ohos.hiSysEvent';
import { BusinessError } from '@ohos.base';
import { HiLog } from '../../../../../feature/call/oh_modules/common';
import hiAppEvent from '@ohos.hiviewdfx.hiAppEvent';
import bundleManager from '@ohos.bundle.bundleManager';
import { deviceInfo } from '@kit.BasicServicesKit';

const TAG = 'DotUtil';
const DOMAIN_UE = 'CONTACTS_UE';
const DOMAIN = 'CONTACTS';
// 通化防护事件未单独申请事件名，采用安工域名SPAMSHIELD_UE
const BLOCKEDDOMAIN = 'SPAMSHIELD_UE';
const PNAMEID = 'com.ohos.contacts';
const beginTime:number = Date.now()

export default class DotUtil {
  private static instance: DotUtil;
  public version: string = '';

  public static getInstance(): DotUtil {
    if (!DotUtil.instance) {
      DotUtil.instance = new DotUtil();
    }
    return DotUtil.instance;
  }


  async updateVersionName(): Promise<void> {
    if (this.version != '') {
      return;
    }
    try {
      HiLog.w(TAG, 'updateVersionName')
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      this.version = bundleInfo.versionName;
    } catch (err) {
      HiLog.w(TAG, `this is err message ${err}`)
    }
  }

  // 摘要卡片跳转备忘录UE打点
  contacToNotetDot(params: CustomizedParams, event: string, eventType?: hiSysEvent.EventType) {
    //先获取版本号
    this.updateVersionName().then(()=>{
      // 打点写入
      params.PNAMEID = PNAMEID;
      params.PVERSIONID = this.version;
      params.MOBILE_MODLE = deviceInfo.productModel;
      params.DEVICE_TYPE = Number(deviceInfo.deviceType);
      let eventInfo: hiSysEvent.SysEventInfo = {
        domain: 'PHONE_UE',
        name: event,
        eventType: eventType == undefined ? hiSysEvent.EventType.BEHAVIOR : eventType,
        params: params
      };
      hiSysEvent.write(eventInfo, (err: BusinessError) => {
        if (err) {
          HiLog.e(TAG, `event: ${eventInfo.name}, this is err message: ${err?.message}`);
        } else {
          HiLog.w(TAG, `event: ${eventInfo.name} success`);
        }
      });
    })
  }

  // 摘要生成故障打点
  reportFaultSummaryEvent(params: CustomizedParams, event: string) {
    try {
      this.updateVersionName().then(() => {
        params.PNAMEID = PNAMEID;
        params.PVERSIONID = this.version;
        let eventInfo: hiSysEvent.SysEventInfo = {
          domain: 'PHONE',
          name: event,
          eventType: hiSysEvent.EventType.FAULT,
          params: params
        };
        hiSysEvent.write(eventInfo, (err: BusinessError) => {
          if (err) {
            HiLog.e(TAG, `fault event: ${eventInfo.name}, this is err message: ${err?.message}`);
          } else {
            HiLog.w(TAG, `fault event: ${eventInfo.name} success`);
          }
        });
      })
    } catch (error) {
      HiLog.e(TAG, `catch reportFaultEvent error ${error?.message}, stack: ${error?.stack}`);
    }
  }

  // UE打点
  contactDot(params: CustomizedParams, event: string, eventType?: hiSysEvent.EventType) {
    //先获取版本号
    this.updateVersionName().then(()=>{
      // 打点写入
      params.PNAMEID = PNAMEID;
      params.PVERSIONID = this.version;
      let eventInfo: hiSysEvent.SysEventInfo = {
        domain: DOMAIN_UE,
        name: event,
        eventType: eventType == undefined ? hiSysEvent.EventType.BEHAVIOR : eventType,
        params: params
      };
      hiSysEvent.write(eventInfo, (err: BusinessError) => {
        if (err) {
          HiLog.e(TAG, `event: ${eventInfo.name}, this is err message: ${err?.message}`);
        } else {
          HiLog.w(TAG, `event: ${eventInfo.name} success`);
        }
      });
    })

  }

  // 故障打点
  reportFaultEvent(params: CustomizedParams, event: string) {
    try {
      this.updateVersionName().then(() => {
        params.PNAMEID = PNAMEID;
        params.PVERSIONID = this.version;
        let eventInfo: hiSysEvent.SysEventInfo = {
          domain: DOMAIN,
          name: event,
          eventType: hiSysEvent.EventType.FAULT,
          params: params
        };
        hiSysEvent.write(eventInfo, (err: BusinessError) => {
          if (err) {
            HiLog.e(TAG, `fault event: ${eventInfo.name}, this is err message: ${err?.message}`);
          } else {
            HiLog.w(TAG, `fault event: ${eventInfo.name} success`);
          }
        });
      })
    } catch (error) {
      HiLog.e(TAG, `catch reportFaultEvent error ${error?.message}, stack: ${error?.stack}`);
    }
  }

  // 通话防护打点
  blockedDot(params: CustomizedParams, eventName: string) {
    try {
      this.updateVersionName().then(() => {
        params.PNAMEID = PNAMEID;
        params.PVERSIONID = this.version;
        let eventInfo: hiSysEvent.SysEventInfo = {
          domain: BLOCKEDDOMAIN,
          name: eventName,
          eventType: hiSysEvent.EventType.BEHAVIOR,
          params: params
        };
        hiSysEvent.write(eventInfo, (err: BusinessError) => {
          if (err) {
            HiLog.e(TAG, `blocked event: ${eventInfo.name}, this is err message: ${err?.message}`);
          } else {
            HiLog.w(TAG, `blocked event: ${eventInfo.name} success`);
          }
        });
      })
    } catch (error) {
      HiLog.e(TAG, `blocked catch report error ${error?.message}, stack: ${error?.stack}`);
    }
  }
}

export class HiAppEvent {

  private static instance: HiAppEvent;

  public static getInstance(): HiAppEvent {
    if (!HiAppEvent.instance) {
      HiAppEvent.instance = new HiAppEvent();
    }
    return HiAppEvent.instance;
  }

 public SchedulerUpload(processorId: number, appName: string, startTime: number, runTime:number[], succCount: number,
   sumTime: number, errCodes: number) {
   HiLog.w(TAG, 'testTag SchedulerUpload start');

   // 添加处理者(配置完全相同时，不会重复生成处理者对象)
   if (!processorId) {
     processorId = this.addEventProcessor();
   }
   // 上报api接口统计事件
   this.writeCallStatusEvent(appName, startTime, runTime, succCount, sumTime, errCodes);
   HiLog.w(TAG, 'testTag SchedulerUpload end');
 }

  public addEventProcessor() {
    HiLog.w(TAG, 'testTag addEventProcessor');
    let processor: hiAppEvent.Processor = {
      name: 'ha_app_event',
      appId: 'com_openharmony_sdk_ocg', // 固定值，指接口埋点事件
      // 下方为测试环境上报地址。现网上报需要Kit传递AUTO字样，即routeInfo: 'AUTO'。
      routeInfo: 'AUTO',
      eventConfigs: [
        {
          domain: 'api_diagnostic',
          name: 'api_exec_end',
          isRealTime: false
        },
        {
          domain: 'api_diagnostic',
          name: 'api_called_stat',
          isRealTime: true
        },
        {
          domain: 'api_diagnostic',
          name: 'api_called_stat_cnt',
          isRealTime: true
        },
      ],
    }
    return hiAppEvent.addProcessor(processor);
  }

  public writeCallStatusEvent(appName: string, startTime: number, runTime:number[], succCount: number,
    sumTime: number, errCodes: number) {
    HiLog.w(TAG, 'testTag writeCallStatusEvent');

    let event: hiAppEvent.AppEventInfo = {
      domain: 'api_diagnostic',
      name: 'api_called_stat',
      params: {
        app_name: appName,
        api_name: 'selectContacts',
        sdk_name: 'ContactsKit',
        begin_time: startTime, // 开始时间
        call_times: runTime.length, // 调用次数
        success_times: succCount, // 调用成功次数
        max_cost_time: Math.max(...runTime), // 最大响应时延
        min_cost_time: Math.min(...runTime), // 最小响应时延
        total_cost_time: sumTime, // 累计响应时延
        error_dist: [errCodes], // 累计报错的错误码
      },
      eventType: hiAppEvent.EventType.BEHAVIOR
    }
    try {
      hiAppEvent.write(event)
    } catch (e) {
      HiLog.e(TAG, `hiAppEvent write error, ${e.code}, ${e.message}`);
    }
  }
}