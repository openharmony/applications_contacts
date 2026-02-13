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
export enum PickerMediaType {
  PHOTO = 'photo',
  VIDEO = 'video'
}

export enum CameraPosition {
  CAMERA_POSITION_UNSPECIFIED = 0,
  CAMERA_POSITION_BACK = 1,
  CAMERA_POSITION_FRONT = 2,
  CAMERA_POSITION_FOLD_INNER = 3
}

export class PickerResult {
  resultCode: number;
  resultUri: string;
  mediaType: PickerMediaType;
}

export class PickerProfile {
  cameraPosition: CameraPosition;
  saveUri?: string;
  videoDuration?: number;
}