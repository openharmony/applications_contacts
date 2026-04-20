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
export default class TraceConstants {
  // 联系人详情trace 101开始
  public static readonly TRACE_DETAIL_DEL: string = 'con_trace_detail_del';
  public static readonly TRACE_DETAIL_DEL_ID: number = 101;
  public static readonly TRACE_DETAIL_CREATE_BIG_PHOTO: string = 'con_trace_detail_create_big_photo';
  public static readonly TRACE_DETAIL_CREATE_BIG_PHOTO_ID: number = 102;
  public static readonly TRACE_DETAIL_GET_DETAIL: string = 'con_trace_detail_get_detail';
  public static readonly TRACE_DETAIL_GET_DETAIL_ID: number = 103;
  public static readonly TRACE_DETAIL_APPEAR: string = 'con_trace_detail_appear';
  public static readonly TRACE_DETAIL_APPEAR_ID: number = 104;
  // 通话记录trace 201开始
  public static readonly TRACE_CALL_DISPLAY_NAME: string = 'con_trace_call_display_name';
  public static readonly TRACE_CALL_DISPLAY_NAME_ID: number = 201;

  // 智能分组查询某个分类下(单位 城市 最近联系人)联系人统计信息
  public static readonly TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY: string =
    'trace_intelligence_query_contact_category';
  public static readonly TRACE_INTELLIGENCE_QUERY_CONTACT_CATEGORY_ID: number = 301;
  // 智能分组查询联系人信息
  public static readonly TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL: string =
    'trace_intelligence_query_contact_detail';
  public static readonly TRACE_INTELLIGENCE_QUERY_CONTACT_DETAIL_ID: number = 302;
  // 智能分组查询联系人信息,发送短信
  public static readonly TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG: string =
    'trace_intelligence_query_contact_send_msg';
  public static readonly TRACE_INTELLIGENCE_QUERY_CONTACT_SEND_MSG_ID: number = 303;
};