// /**
//  * Copyright (c) 2025 Huawei Device Co., Ltd.
//  * Licensed under the Apache License, Version 2.0 (the 'License');
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *     http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an 'AS IS' BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
// import { HdsNavigationBadgeIconOptions, HdsNavigationTitleBarOptions, IconType,
//   TitleBarStyleOptions } from '@kit.UIDesignKit';
// import { LengthMetrics } from '@kit.ArkUI';
// import { ResourceUtil } from './ResourceUtil';
// import { BottomBuilderParams, IconStyleMode } from '@hms.hds.hdsBaseComponent';
// import { HiLog } from '../../../../../feature/call/oh_modules/common/src/main/ets/util/HiLog';
// import EmitterConstant from '../data/EmitterConstant';
// import { emitter } from '@kit.BasicServicesKit';
//
// const TAG = 'TitleBarUtil';
//
// interface mainTitle {
//   title?: string;
//   isMultipleSelectState?: boolean;
//   selectedNumber?: number;
// }
//
// interface backIconParams {
//   isThemeActive?: boolean;
//   backIcon?: boolean;
//   closeIcon?: boolean;
// }
//
// interface paddingParams {
//   start?: LengthMetrics;
//   end?: LengthMetrics;
// }
//
// export interface TitleBarParams {
//   style?: TitleBarStyleOptions;
//   avoidLayoutSafeArea?: boolean;
//   enableComponentSafeArea?: boolean;
//   padding?: paddingParams;
//   title?: mainTitle;
//   backIcon?: backIconParams;
//   stackBuilder?: CustomBuilder;
//   bottomBuilder?: BottomBuilderParams;
// }
//
// class TitleBarUtil {
//
//   /**
//    * 提取titleBar
//    */
//   public getTitleBar(titleBarParam: TitleBarParams, menuValue: HdsNavigationBadgeIconOptions[] | undefined,
//     callBack: Function): HdsNavigationTitleBarOptions {
//     let titleBar: HdsNavigationTitleBarOptions = {
//       style: titleBarParam.style,
//       avoidLayoutSafeArea: titleBarParam?.avoidLayoutSafeArea ? true : false,
//       enableComponentSafeArea: titleBarParam?.enableComponentSafeArea ?? false,
//       padding: {
//         start: titleBarParam?.padding?.start,
//         end: titleBarParam?.padding?.end
//       },
//       content: {
//         title: {
//           mainTitle: this.getMainTitle(titleBarParam?.title?.title, titleBarParam.title?.isMultipleSelectState,
//             titleBarParam?.title?.selectedNumber)
//         },
//         backIcon: {
//           icon: this.getBackIcon(titleBarParam?.backIcon),
//           label: titleBarParam?.backIcon?.backIcon ? $r('app.string.accessibility_back') :
//             titleBarParam?.backIcon?.closeIcon ? $r('app.string.shut_down') : '',
//           action: ()=> {
//             callBack();
//           }
//         },
//         stackBuilder: titleBarParam?.stackBuilder,
//         bottomBuilder: titleBarParam?.bottomBuilder,
//         menu: {
//           value: menuValue
//         }
//       }
//     }
//     return titleBar;
//   }
//
//   /**
//    * 获取图标
//    */
//   private getBackIcon(backParams?: backIconParams): IconType {
//     if (!backParams) {
//       HiLog.e(TAG, 'getBackIcon backParams is null');
//       return '';
//     }
//       if (backParams.backIcon) {
//       return $r('sys.symbol.chevron_backward')
//     } else if (backParams.closeIcon) {
//       return $r('sys.symbol.xmark')
//     }
//     return '';
//   }
//
//   /**
//    * 获取标题
//    */
//   private getMainTitle(mainTitle?: string, isMultipleSelectState?: boolean, selectedNumber?: number): ResourceStr {
//     if (isMultipleSelectState && selectedNumber != undefined) {
//       if (selectedNumber === 0) {
//         return ResourceUtil.getStringByResource($r('app.string.no_select'));
//       } else {
//         return ResourceUtil.getPluralStringByResource($r('app.plural.select_num'), selectedNumber);
//       }
//     }
//     return mainTitle ?? '';
//   }
//
//   /**
//    * 联系人设置半模态页面关闭按钮，跟随hds转场
//    */
//   getBindSheetCloseButton(): HdsNavigationBadgeIconOptions[] {
//     return [
//       {
//         content: {
//           type: IconStyleMode.SMALL,
//           action: () => {
//             let event: emitter.InnerEvent = {
//               // 通知关闭设置半模态页面
//               eventId: EmitterConstant.EMITTER_SETTING_ABOUT_EXIT_ID
//             }
//             emitter.emit(event);
//           }
//         },
//       },
//     ]
//   }
// }
//
// export default new TitleBarUtil()
