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
import { ArrayUtil, HiLog, sharedPreferencesUtils } from '../../../../../../../feature/call/oh_modules/common';
import { ContactsGlobalThisHelper } from '../../../../../../../common/src/main/ets/util/ContactsGlobalThisHelper';
import { BusinessError } from '@ohos.base';
import { CardDialogInfoType, CardDialogSimInfo } from '../../type/commonType';
import { PhoneNumBean } from '../../../model/bean/PhoneNumBean';
import { PhoneNumber } from '../../../../../../../feature/phonenumber';
import { DataItemType, Phone } from '../../../../../../../feature/contact';
import { CustomizedParams, SetPrimaryParam } from '../../../model/type';
import WorkerWrapper from '../../../workers/base/WorkerWrapper';
import { FormCardController } from '../FormCardController';
import { CallLog } from '../../../../../../../feature/call';
import DialerPresenter from '../../../presenter/dialer/DialerPresenter';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';
import sim from '@ohos.telephony.sim';
import DotUtil from '../../../util/DotUtil';
import { RoamingManager } from '../../../feature/roaming/RoamingManager';
import { FontScaleState } from '../../../util/fontScaleState';
import { display } from '@kit.ArkUI';
import { mediaquery } from '@kit.ArkUI';
import { SimCardType } from '../../../data/Constants';

const TAG: string = 'CardSelectDialog';
const CALL_EVENT: string = 'CALL_EVENT'

let storage = LocalStorage.getShared();

@Entry(storage)
@Component
struct Index {
  @State newWidthSize: string = '16vp';
  private landscapeListener = mediaquery.matchMediaSync('(orientation: landscape)');
  @LocalStorageLink('dialogInfo') dialogInfo: CardDialogInfoType = {
    phoneList: [],
    simList: [],
    flag: 'selectNum',
    lastSimId: -1
  };
  @LocalStorageLink('session') session: UIExtensionContentSession | null = null;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  // 是否启动主题
  @StorageProp('isThemeActive') isThemeActive: boolean = false;
  mFormCardController: FormCardController = FormCardController.getInstance();
  private selectDefault: Boolean = false;
  callParams: CustomizedParams = {
    ENC: -1,
    SLOT: 0,
    ISMULTISIMCARD: 0
  };
  private eSimDialImg = $r('app.media.ic_call_eSIM');
  private dialImg = [$r('sys.symbol.phone_badge_1'), $r('sys.symbol.phone_badge_2')];

  setWidthSize() {
    try {
      // 获取屏幕宽度
      let displayClass = display.getDefaultDisplaySync();
      let displayWidth = displayClass.width;
      HiLog.w(TAG, 'displayWidth: ' + displayWidth);
      let windowWidthVp = px2vp(displayWidth);
      HiLog.w(TAG, `px2vp px:${displayWidth} vp:${windowWidthVp}`);
      if (windowWidthVp < 520) {
        this.newWidthSize = '16vp';
      } else if (windowWidthVp < 840) {
        this.newWidthSize = '156vp';
      } else {
        this.newWidthSize = '368vp';
      }
      HiLog.w(TAG, 'newWidthSize: ' + this.newWidthSize);
    } catch (error) {
      HiLog.e(TAG, `setWidthSize failed with error message: ${error?.message}, error code: ${error?.code}`);
    }
  }

  // 开启折叠设备折叠状态变化的监听
  foldStatusListen() {
    try {
      display.on('foldStatusChange', (data: display.FoldStatus) => {
        HiLog.w(TAG, 'on foldStatusChange: display.FoldStatus: ' + data);
        if (data === display.FoldStatus.FOLD_STATUS_EXPANDED || data === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
          // 折叠展开状态 || 半折叠状态
          this.newWidthSize = '156vp';
        }
        if (data === display.FoldStatus.FOLD_STATUS_FOLDED || data === display.FoldStatus.FOLD_STATUS_UNKNOWN) {
          // 完全折叠状态 || 未知状态
          this.newWidthSize = '16vp';
        }
      });
    } catch (error) {
      HiLog.e(TAG, `foldStatusListen failed with error message: ${error?.message}, error code:${error?.code}`);
    }
  }

  // 监听横屏事件
  landscapeListen() {
    this.landscapeListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      HiLog.w(TAG, `mediaQueryResult matches: ${mediaQueryResult?.matches}, media: ${mediaQueryResult?.media}`);
      this.setWidthSize();
    })
  }

  aboutToAppear() {
    HiLog.w(TAG, '[aboutToAppear] SelectMultiNumDialog');
    this.dialogInfo.phoneList.forEach((item, index) => {
      if (item.primary) {
        let primaryItem = item;
        this.dialogInfo.phoneList.splice(index, 1);
        this.dialogInfo.phoneList.unshift(primaryItem);
        return
      }
    })
    sharedPreferencesUtils.init(getContext(this));
    this.setWidthSize();
    this.foldStatusListen();
    this.landscapeListen();
  }

  aboutToDisappear(): void {
    HiLog.w(TAG, '[aboutToDisappear] SelectMultiNumDialog');
    try {
      display.off('foldStatusChange', (data: display.FoldStatus) => {
        HiLog.w(TAG, 'off foldStatusChange: display.FoldStatus: ' + data);
      });
      this.landscapeListener.off('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
        HiLog.w(TAG, `mediaQueryResult matches: ${mediaQueryResult?.matches}, media: ${mediaQueryResult?.media}`);
      });
    } catch (error) {
      let err = error as BusinessError
      HiLog.e(TAG,
        'aboutToDisappear listen off failed with error message: ' + err.message + ', error code: ' + err.code);
    }
  }

  terminateSelf() {
    if (this.session !== null) {
      this.session.terminateSelf()
        .then(() => {
          HiLog.w(TAG, 'terminateSelfWithResult Operation succeeded: ');
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `Operation failed. Cause: ${error?.code}-${error?.message}`);
        });
    }
  }

  async formatPhoneNum(num: string) {
    return await new PhoneNumber(num).format();
  }

  async selectNumConfirm(phoneItem: PhoneNumBean) {
    if (this.selectDefault) {
      const setPrimaryParam: SetPrimaryParam = {
        contactId: phoneItem.contactId as string,
        dataType: DataItemType.PHONE,
        dataId: phoneItem.dataId,
        primary: true
      }
      ContactsGlobalThisHelper.GetGlobalThis()
        .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('setPrimary', setPrimaryParam);
    }
    let activeSimCount: number = 0;
    let aloneActiveSim: number = -1;
    this.dialogInfo.simList.forEach((item, index: number) => {
      if (item.state) {
        activeSimCount++;
        aloneActiveSim = index;
      }
    })
    let defaultVoiceSlotId = await this.hasDefaultVoiceSlotId();
    if (defaultVoiceSlotId !== -1) {
      this.mFormCardController.handleRoamingNumber(phoneItem, defaultVoiceSlotId,
        (dialogInfo: CardDialogInfoType | undefined) => {
          this.updateDialog(dialogInfo);
        });
    } else {
      if (activeSimCount === 0) {
        this.mFormCardController.notHaveSimCard(phoneItem.num, 0);
        this.terminateSelf();
      } else if (activeSimCount === 1) {
        this.mFormCardController.handleRoamingNumber(phoneItem, aloneActiveSim,
          (dialogInfo: CardDialogInfoType | undefined) => {
            this.updateDialog(dialogInfo);
          });
      } else {
        ContactsGlobalThisHelper.GetGlobalThis()
          .getValue<WorkerWrapper>(ContactsGlobalThisHelper.DataWorkerName).sendRequest('findByNumberIn', {
          actionData: {
            context: ContactsGlobalThisHelper.GetGlobalThis().getDefaultCardDialogContext(),
            number: [phoneItem.num],
            limit: 1,
            page: 1
          }
        }, (resultList: CallLog[]) => {
          if (!ArrayUtil.isEmpty(resultList)) {
            this.dialogInfo.lastSimId = resultList[0].simId;
          } else {
            this.dialogInfo.lastSimId = -1;
          }
        });
        this.dialogInfo.phoneList = [phoneItem];
        this.dialogInfo.flag = 'selectSim';
      }
    }
  }

  gotoDialer() {
    DialerPresenter.getInstance().editPhoneNumber(this.dialogInfo.phoneList[0].num);
    const want: Want = {
      bundleName: 'com.ohos.contacts',
      abilityName: 'com.ohos.contacts.MainAbility',
      parameters: { pageFlag: 'page_flag_edit_before_calling', phoneNumber: this.dialogInfo.phoneList[0].num },
      entities: [
        'entity.system.home'
      ]
    };
    if (this.session !== null) {
      this.session.startAbility(want).then(() => {
        HiLog.w(TAG, 'jumpToContact, startAbility Success');
        this.terminateSelf();
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `jumpToContact, failed, error: ${error?.code}-${error?.message}`);
        this.terminateSelf();
      });
    } else {
      this.terminateSelf();
    }
  }

  getSimName(name: string | Resource) {
    let text: string = ''
    let context = getContext(this) as Context;
    if (typeof name === 'string') {
      text = name
    } else {
      HiLog.w(TAG, `simName is No service`)
      text = context ? context.resourceManager.getStringSync(name as Resource) : ''
    }
    return text;
  }

  selectSimConfirm(slotId: number) {
    this.mFormCardController.handleRoamingNumber(this.dialogInfo.phoneList[0],
      slotId, (dialogInfo: CardDialogInfoType | undefined) => {
        this.updateDialog(dialogInfo);
      });
  }

  selectRoamingConfirm(phoneNumber: string, slotId: number) {
    if (this.dialogInfo.roamingOriginNumber) {
      RoamingManager.getInstance().updateFormatNumber(
        this.dialogInfo.roamingOriginNumber, this.dialogInfo.roamingOldFormatNumber, phoneNumber);
    }
    this.dialUp(phoneNumber, slotId);
  }

  dialUp(phoneNum: string, slotId: number) {
    HiLog.w(TAG, `dialUp start`)
    PhoneNumber.fromString(phoneNum).dial({
      accountId: slotId,
    }).then(() => {
      HiLog.w(TAG, `dialUp success`);
      this.terminateSelf();
    }).catch(() => {
      HiLog.w(TAG, `dialUp failed`);
      this.terminateSelf();
    })
  }

  async hasDefaultVoiceSlotId() {
    let defaultVoiceSlotId: number
    try {
      defaultVoiceSlotId = await sim.getDefaultVoiceSlotId()
    } catch (e) {
      defaultVoiceSlotId = -1
    }
    return defaultVoiceSlotId;
  }

  fastCardDot(item: CardDialogSimInfo) {
    // 联系人打点--快捷卡片点击拨号按钮弹出弹窗选择卡号呼出
    this.callParams.SLOT = item.slotId;
    this.callParams.ISMULTISIMCARD = 1;
    DotUtil.getInstance().contactDot(this.callParams, CALL_EVENT);
  }

  private updateDialog(dialogInfo: CardDialogInfoType | undefined) {
    if (dialogInfo) {
      this.dialogInfo = dialogInfo;
    } else {
      this.terminateSelf();
    }
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.skin_interactive_click'))
    .borderRadius($r('sys.float.padding_level8'))
  }

  @Builder
  MenuDivider() {
    Divider()
      .color($r('app.color.skin_comp_divider'))
      .strokeWidth('1px')
      .margin({
        left: '64vp',
        right: $r('sys.float.padding_level12'),
      })
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center, direction: FlexDirection.Column }) {
        if (this.dialogInfo.flag === 'selectNum') {
          Column() {
            Row() {
              Text($r('app.string.contacts_call'))
                .fontSize('20vp')
                .fontColor($r('app.color.skin_font_primary'))
                .fontWeight(FontWeight.Bold)
                .lineHeight('27vp')
                .alignSelf(ItemAlign.Center)
                .width('100%')
                .textAlign(TextAlign.Center)
                .constraintSize({ minHeight: '56vp' })
                .padding({
                  top: '15vp',
                  bottom: '15vp'
                })
            }
            .margin({
              left: $r('sys.float.padding_level12'),
              right: $r('sys.float.padding_level12')
            })

            List() {
              ForEach(this.dialogInfo.phoneList, (item: PhoneNumBean, index) => {
                ListItem() {
                  Row() {
                    SymbolGlyph($r('sys.symbol.phone'))
                      .fontSize($r('app.float.id_card_image_small'))
                      .fontColor([$r('app.color.skin_icon_secondary')])
                      .padding({ right: $r('sys.float.padding_level8') })

                    Column() {
                      Row() {
                        Text(item.num)
                          .fontSize($r('sys.float.Body_L'))
                          .fontColor($r('app.color.skin_font_primary'))
                          .fontWeight(FontWeight.Medium)
                          .maxLines(FontScaleState.isStandardGeer(this.fontSizeScale) ? 1 : 10)
                          .width('238vp')
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }

                      Row() {
                        Text(item.numType === '10000' ? item.selectTextCustom :
                          Phone.getTypeLabelResource(Number.parseInt(item.numType, 10)))
                          .fontColor($r('app.color.skin_font_secondary'))
                          .fontSize($r('sys.float.Body_M'))
                          .fontWeight(FontWeight.Regular)
                      }
                      .margin({ top: $r('sys.float.padding_level1') })
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .constraintSize({ minHeight: '64vp' })
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Center)
                  .padding({
                    left: $r('sys.float.padding_level6'),
                    right: $r('sys.float.padding_level6'),
                  })
                }
                .constraintSize({ minHeight: '64vp' })
                .margin({
                  left: $r('sys.float.padding_level6'),
                  right: $r('sys.float.padding_level6')
                })
                .stateStyles({
                  normal: this.normalStyles,
                  pressed: this.pressedStyles
                })
                .onClick(() => {
                  this.selectNumConfirm(item);
                })

                this.MenuDivider();
              })

              ListItem() {
                Row() {
                  Column() {
                    Checkbox({ name: 'checkbox2', group: 'checkboxGroup' })
                      .height('24vp')
                      .width('24vp')
                      .select(false)
                      .unselectedColor(this.isThemeActive ? $r('app.color.skin_icon_fourth') :
                        undefined)
                      .mark(this.isThemeActive ? { strokeColor: $r('app.color.skin_icon_on_primary') } : undefined)
                      .margin($r('sys.float.padding_level0'))
                      .padding($r('sys.float.padding_level1'))
                      .selectedColor($r('app.color.skin_comp_background_emphasize'))
                      .onChange((value: boolean) => {
                        this.selectDefault = value
                      })
                      .accessibilityText($r('app.string.set_card_select_contact'))
                  }
                  .padding({ right: $r('sys.float.padding_level6') })

                  Column() {
                    Text($r('app.string.set_card_select_contact'))
                      .width('100%')
                      .fontColor($r('app.color.skin_font_primary'))
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Regular)
                      .accessibilityLevel('no')
                  }
                  .width('100%')
                  .flexShrink(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .height('48vp')
                .justifyContent(FlexAlign.Start)
                .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
              }
              .margin({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
              .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
              })
            }
            .constraintSize({ maxHeight: '50%' })

            Row() {
              Button($r('app.string.cancel'))
                .alignSelf(ItemAlign.Center)// .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.skin_ohos_id_color_text_primary_activated'))
                .fontSize($r('sys.float.Body_L'))
                .width('100%')
                .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
                .onClick(() => {
                  this.terminateSelf();
                })
                .buttonStyle(ButtonStyleMode.TEXTUAL)
                .margin({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level8') })
            }
            .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
            .padding({
              left: $r('sys.float.padding_level6'),
              right: $r('sys.float.padding_level6'),
            })
          }
          .margin({ left: this.newWidthSize, right: this.newWidthSize })
          .borderRadius($r('sys.float.corner_radius_level16'))
          .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
        } else if (this.dialogInfo.flag === 'selectRoamingNum') {
          Column() {
            Text($r('app.string.roaming_dial_title'))
              .fontSize($r('sys.float.Title_S'))
              .maxFontScale(2)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .alignSelf(ItemAlign.Center)
              .width('100%')
              .constraintSize({ minHeight: '56vp' })
              .backgroundColor(Color.Transparent)
              .margin({
                left: $r('app.float.id_dialog_title_margin'),
                right: $r('app.float.id_dialog_title_margin'),
                top: $r('app.float.id_list_primary_margin_top'),
                bottom: $r('app.float.id_list_primary_margin_top')
              })
              .padding({
                left: $r('app.float.id_card_margin_max'),
                right: $r('app.float.id_card_margin_max')
              })
            List() {
              ForEach(this.dialogInfo.phoneList, (item: PhoneNumBean, index) => {
                ListItem() {
                  RelativeContainer() {
                    Text(item.num)
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontColor($r('app.color.skin_ohos_id_color_text_primary'))
                      .fontWeight(FontWeight.Medium)
                      .width('100%')
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({
                        top: FontScaleState.fetchSeniorListSpace(),
                        left: $r('sys.float.padding_level8')
                      })
                      .constraintSize({ minHeight: $r('app.float.id_list_primary_line_height') })
                      .id('call_number')
                    Text(Phone.getTypeLabelResource(Number.parseInt(item.numType, 10)))
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .constraintSize({ minHeight: $r('app.float.id_list_summary_line_height') })
                      .fontWeight(FontWeight.Regular)
                      .margin({
                        top: $r('sys.float.ohos_id_text_margin_vertical'),
                        bottom: FontScaleState.fetchSeniorListSpace()
                      })
                      .alignRules({
                        top: { anchor: 'call_number', align: VerticalAlign.Bottom },
                        left: { anchor: 'call_number', align: HorizontalAlign.Start }
                      })
                      .id('numType')
                    Text(' - ')
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .constraintSize({ minHeight: $r('app.float.id_list_summary_line_height') })
                      .fontWeight(FontWeight.Regular)
                      .margin({
                        top: $r('sys.float.ohos_id_text_margin_vertical'),
                        bottom: FontScaleState.fetchSeniorListSpace()
                      })
                      .alignRules({
                        top: { anchor: 'call_number', align: VerticalAlign.Bottom },
                        left: { anchor: 'numType', align: HorizontalAlign.End }
                      })
                      .id('dash');
                    Text(item.numLocation)
                      .fontColor($r('app.color.skin_ohos_id_color_text_secondary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .constraintSize({ minHeight: $r('app.float.id_list_summary_line_height') })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .fontWeight(FontWeight.Regular)
                      .margin({
                        top: $r('sys.float.ohos_id_text_margin_vertical'),
                        bottom: FontScaleState.fetchSeniorListSpace()
                      })
                      .alignRules({
                        top: { anchor: 'call_number', align: VerticalAlign.Bottom },
                        left: { anchor: 'dash', align: HorizontalAlign.End },
                        right: { anchor: 'call_number', align: HorizontalAlign.End }
                      })
                      .id('numLocation');
                    SymbolGlyph($r('sys.symbol.phone'))
                      .fontSize($r('app.float.id_card_image_small'))
                      .fontColor([$r('app.color.skin_ohos_id_color_secondary')])
                      .alignRules({
                        center: { anchor: 'call_number', align: VerticalAlign.Bottom },
                        right: { anchor: 'call_number', align: HorizontalAlign.Start }
                      })
                      .margin({ right: $r('sys.float.padding_level8') })
                      .id('call_icon')
                  }
                  .height('auto')
                  .padding({
                    left: '24vp',
                    right: '16vp'
                  })
                }
                .width('100%')
                .constraintSize({ minHeight: $r('app.float.id_item_height_max') })
                .padding({
                  left: $r('sys.float.alert_content_default_padding'),
                  right: $r('sys.float.alert_content_default_padding')
                })
                .onClick(() => {
                  this.selectRoamingConfirm(item.num, this.dialogInfo.simList[0].slotId);
                })

                this.MenuDivider();
              })
            }
            .backgroundColor(Color.Transparent)
            .divider({
              strokeWidth: 0.5,
              startMargin: '64vp',
              endMargin: $r('sys.float.ohos_id_max_padding_end'),
              color: $r('app.color.skin_ohos_id_color_list_separator')
            })
            Button($r('app.string.cancel'))
              .onClick(() => {
                this.terminateSelf();
              })
              .backgroundColor(Color.Transparent)
              .fontColor($r('app.color.skin_font_emphasize'))
              .fontSize($r('sys.float.Body_L'))
              .width('100%')
              .margin({
                left: $r('app.float.id_card_margin_xxl_minus'),
                right: $r('app.float.id_card_margin_xxl_minus'),
                top: $r('app.float.id_card_margin_large')
              })
              .padding({
                left: $r('app.float.id_card_margin_xxl'),
                right: $r('app.float.id_card_margin_xxl'),
                top: $r('app.float.id_card_margin_large'),
                bottom: $r('app.float.id_card_margin_large')
              })
          }
          .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
          .borderRadius($r('app.float.id_corner_radius_dialog'))
          .alignItems(HorizontalAlign.Center)
          .padding({
            bottom: $r('app.float.id_dialog_button_bottom_margin')
          })
          .margin({
            left: $r('app.float.id_dialog_button_horizontal_margin'),
            right: $r('app.float.id_dialog_button_horizontal_margin'),
          })
        } else {
          Column() {
            Row() {
              Text($r('app.string.contacts_call_number', this.dialogInfo.phoneList[0].displayNum ?? ''))
                .fontSize('20vp')
                .fontColor($r('app.color.skin_font_primary'))
                .fontWeight(FontWeight.Bold)
                .lineHeight('27vp')
                .alignSelf(ItemAlign.Center)
                .width('100%')
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(2)
                .textAlign(TextAlign.Center)
                .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
                .wordBreak(WordBreak.BREAK_ALL)
                .padding({
                  top: '15vp',
                  bottom: '15vp'
                })
            }
            .margin({
              left: $r('sys.float.padding_level12'),
              right: $r('sys.float.padding_level12')
            })

            List() {
              ForEach(this.dialogInfo.simList, (item: CardDialogSimInfo, index) => {
                ListItem() {
                  Row() {
                    if (item.simType === SimCardType.ESIM) {
                      Image(this.eSimDialImg)
                        .width('24vp')
                        .height('24vp')
                        .margin({ right: $r('sys.float.padding_level8') })
                        .flexShrink(0)
                    } else {
                      SymbolGlyph(item.index === index + 1 ? this.dialImg[index] :
                        this.dialImg[item.index >= 1 ? item.index - 1 : 0])
                        .fontSize($r('app.float.id_card_image_small'))
                        .fontColor([$r('app.color.skin_icon_secondary')])
                        .margin({ right: $r('sys.float.padding_level8') })
                    }

                    Column() {
                      Text(this.getSimName(item.name))
                        .fontSize($r('sys.float.Body_L'))
                        .fontColor($r('app.color.skin_font_primary'))
                        .fontWeight(FontWeight.Medium)

                      Text($r('app.string.choose_sub_recommend'))
                        .fontSize($r('sys.float.Body_M'))
                        .fontColor($r('app.color.skin_font_secondary'))
                        .fontWeight(FontWeight.Regular)
                        .margin({ top: $r('sys.float.padding_level1') })
                        .visibility(this.dialogInfo.lastSimId == index ? Visibility.Visible : Visibility.None);
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .constraintSize({
                    minHeight: this.dialogInfo.lastSimId == index ?
                    $r('app.float.id_item_height_max') : $r('app.float.id_item_height_large')
                  })
                  .justifyContent(FlexAlign.Start)
                  .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
                }
                .margin({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
                .stateStyles({
                  normal: this.normalStyles,
                  pressed: this.pressedStyles
                })
                .onClick(() => {
                  this.fastCardDot(item);
                  this.selectSimConfirm(item.slotId);
                })

                this.MenuDivider();
              })

              ListItem() {
                Row() {
                  SymbolGlyph($r('sys.symbol.square_and_pencil'))
                    .fontSize($r('app.float.id_card_image_small'))
                    .fontColor([$r('app.color.skin_icon_secondary')])
                    .padding({ right: $r('sys.float.padding_level8') })

                  Column() {
                    Text($r('app.string.contacts_call'))
                      .fontSize($r('sys.float.Body_L'))
                      .fontColor($r('app.color.skin_font_primary'))
                      .fontWeight(FontWeight.Medium)
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
                .justifyContent(FlexAlign.Start)
                .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
              }
              .margin({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
              .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
              })
              .onClick(() => {
                this.gotoDialer();
              })
            }
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.None)

            Row() {
              Button($r('app.string.cancel'))
                .onClick(() => {
                  this.terminateSelf();
                })
                .height('40vp')
                .fontColor($r('app.color.skin_ohos_id_color_text_primary_activated'))
                .constraintSize({ minHeight: '40vp' })
                .buttonStyle(ButtonStyleMode.TEXTUAL)
                .width('100%')
                .margin({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level8') })
            }
            .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Top)
            .padding({
              left: $r('sys.float.padding_level6'),
              right: $r('sys.float.padding_level6'),
            })
          }
          .margin({
            left: this.newWidthSize,
            right: this.newWidthSize,
          })
          .borderRadius($r('sys.float.corner_radius_level16'))
          .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
        }
      }
      .height('100%')
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_mask_thin'))
    .transition(TransitionEffect.OPACITY.animation({ duration: 200 }).combine(TransitionEffect.translate({ y: 0 })))
    .onClick(() => {
      this.terminateSelf();
    })
  }
}
