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

/**
 * 由于@ohos.caas.d.ts文件当前定义不够规范，且未集成到SDK子系统内，业务当前无法像调用系统接口一样进行依赖，
 * 因此，业务针对@ohos.caas.d.ts文件中的内容，规范了caaskit服务实现相关的接口定义，此方案作为临时方案执行。
 */
export namespace Caas {
/**
 * @name 媒体类型定义，
 * @default 暂仅支持音视频通话类型。
 * @typedef
 * @enum
 * @caaskit
 * @since 2.0.2
 */
  export enum MediaType {
    /**
     * @name 音频流，
     * @default 该参数负责标识媒体面音频类型，
     * @default 基本通话类型，包括运营商通话和畅连通话。
     * @typedef
     * @enum
     * @caaskit
     * @since 2.0.2
     */
    AUDIO = 0,

    /**
     * @name 视频流，
     * @default 该参数负责标识媒体面视频类型。
     * @typedef
     * @enum
     * @caaskit
     * @since 2.0.2
     */
    VIDEO = 1
  }
}
