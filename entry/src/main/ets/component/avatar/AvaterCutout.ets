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
import image from '@ohos.multimedia.image';
import { HiLog } from '../../../../../../common';
import { BusinessError } from '@ohos.base';
import window from '@ohos.window';
import { FontScaleState } from '../../util/fontScaleState';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';
import { copyPixelMap } from '../../util/UserPhoto'
import display from '@ohos.display';
import measure from '@ohos.measure';
import EnvironmentProp from '../../feature/EnvironmentProp';
import { LengthMetrics } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import AccessibilityUtil from '../../util/AccessibilityUtil';
import { fileUri } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';

const TAG: string = 'DealAvatar';

// 裁剪框直径
const CROP_CIRCLE_L = 268;
// 裁剪框半径
const CROP_CIRCLE_R = 134;
const BIG_CROP_CIRCLE_L = 526;

const CROP_WIDTH = 300;
const CROP_HEIGHT = 400;

// 裁剪框页面位置比例
const CROP_AREA_LOCATION = 0.5;

const SET_DARK_MODE_LIGHT: string = 'light';
const SET_DARK_MODE_DARK: string = 'dark';

@Component
export struct EditAvatar {
  @Link isShow: boolean;
  @Prop uri: string;
  @Prop displayTitle: string;
  @Prop displaySubTitle: string;
  @StorageLink('breakpoint') curBp: string = 'sm';
  @StorageLink('fullScreenPadding') fullScreenPadding: Padding = {};
  // 是否启动无障碍
  @StorageProp(AccessibilityUtil.ISOPENACCESSIBILITY) isOpenAccessibility: boolean = false;
  circleWidth: number = 150;
  fontColor: Resource | string | Color = Color.White;
  tapBarHeight: number = 0;
  // 裁剪相关逻辑
  @State img: image.PixelMap | undefined = undefined;
  @State imgScaled: image.PixelMap | undefined = undefined;
  // 裁剪框直径
  @State cropCircleL: number = CROP_CIRCLE_L;
  // 裁剪框半径
  @State @Watch('loadImg') cropCircleR: number = CROP_CIRCLE_R;
  // 裁剪框页面位置比例
  @State cropCircleLocation: number = CROP_AREA_LOCATION;
  // 照片的宽
  @State imgWidth: number = 0;
  // 照片的高
  @State imgHeight: number = 0;
  // 展示照片和照片实际尺寸的比例
  @State oriScale: number = 1;
  // 展示照片和修剪框的比例
  @State oriSize: number = 1;
  // 手势放大缩小比例
  @State scaleValue: number = 1;
  // 手势放大缩小比例(中间态)
  @State pinchValue: number = 1;
  // 图片滑动坐标x
  @State offsetX: number = 0;
  // 图片初始坐标y
  @State oriY: number = 0;
  // 图片滑动坐标y
  @State offsetY: number = 0;
  // 图片滑动距离坐标x(中间态)
  @State positionX: number = 0;
  // 图片滑动距离坐标y(中间态)
  @State positionY: number = 0;
  // 手否鼠标悬浮
  @State isBackHover: boolean = false;
  @State isOkHover: boolean = false;
  @State isMinusHover: boolean = false;
  @State isPlusHover: boolean = false;
  @State oldImageWidth: number = 0;
  @State oldImageHeight: number = 0;
  @State isPhotoComplete: boolean = false;
  // 裁剪初始坐标x
  fromX: number = 0;
  // 裁剪初始坐标y
  @State fromY: number = 0;
  // 裁剪长宽
  cropLength: number = 0;
  cropWidth: number = 0;
  cropHeight: number = 0;
  @State cropX: number = 0;
  @State cropY: number = 0;
  storage: LocalStorage = LocalStorage.GetShared();
  @LocalStorageLink('isPanelCenter') isPanelCenter?: boolean = false;
  @LocalStorageLink('isLandScape') isLandScape: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 0;
  @StorageProp('windowHeightPx') windowHeight: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  onFinish: (data: image.PixelMap, scaledData: image.PixelMap) => void = () => {
  };
  public saveClicked = false;
  private isPC: boolean = EnvironmentProp.isPC();

  /**
   *  将选择的媒体图片路径转换成沙箱路径，再创建pixelMap
   * @param imageUri
   * @returns
   */
  private async convertSelectImg(imageUri: string): Promise<image.PixelMap | undefined> {
    let pixelMap: image.PixelMap | undefined = undefined;
    if (!imageUri) {
      HiLog.e(TAG, `selected Image is empty`);
      return;
    }
    try {
      HiLog.w(TAG, `convertSelectImg start`);
      // let imageFileUri: fileUri.FileUri = new fileUri.FileUri(imageUri);
      // let imageSource: image.ImageSource = image.createImageSource(imageFileUri.path);
      const file = await fs.open(imageUri, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(file.fd, buffer, { offset: 0, length: stat.size });
      await fs.close(file.fd);
      const imageSource: image.ImageSource = image.createImageSource(buffer);
      pixelMap = await imageSource.createPixelMap();
      HiLog.i(TAG, 'createPixelMap success');
      return pixelMap;
    } catch (err) {
      HiLog.e(TAG, `convertSelectImg err: ${err.message}`);
    }
    return pixelMap;
  }

  onCropCircleChange() {
    if (!this.imgWidth) {
      return;
    }
    this.checkScale();
    this.checkOutArea();
    this.positionX = this.offsetX;
    this.positionY = this.offsetY;
    this.updateFromXAndFromY();
  }

  // 更新裁剪变量
  updateFromXAndFromY() {
    const offsetX: number = this.scaleValue * this.imgWidth - CROP_WIDTH;
    this.fromX = (offsetX / 2 - this.offsetX) / this.scaleValue / this.oriScale;
    const offsetY: number = this.scaleValue * this.imgHeight - CROP_HEIGHT;
    this.fromY = (offsetY / 2 - this.offsetY) / this.scaleValue / this.oriScale;
    this.cropWidth = CROP_WIDTH / this.scaleValue / this.oriScale;
    this.cropHeight = CROP_HEIGHT / this.scaleValue / this.oriScale;
  }

  // 检查比例
  checkScale() {
    if (this.scaleValue < 1) {
      if (this.imgWidth * this.scaleValue < CROP_WIDTH) {
        this.scaleValue = CROP_WIDTH / this.imgWidth
      }
      if (this.imgHeight * this.scaleValue < CROP_HEIGHT) {
        this.scaleValue = CROP_HEIGHT / this.imgHeight
      }
    }
    if (this.scaleValue > 2) {
      this.scaleValue = 2
    }
    this.pinchValue = this.scaleValue;
  }

  // 检查图片超脱裁剪框
  checkOutArea() {
    this.updateFromXAndFromY()
    if (this.fromX < 0) {
      this.offsetX = (this.scaleValue * this.imgWidth - CROP_WIDTH) / 2
    }
    if (this.fromY < 0) {
      this.offsetY = (this.scaleValue * this.imgHeight - CROP_HEIGHT) / 2
    }
    if (this.offsetX < (CROP_WIDTH / 2 - this.imgWidth * this.scaleValue / 2)) {
      this.offsetX = CROP_WIDTH / 2 - this.imgWidth * this.scaleValue / 2
    }
    if (this.offsetY < CROP_HEIGHT / 2 - this.imgHeight * this.scaleValue / 2) {
      this.offsetY = CROP_HEIGHT / 2 - this.imgHeight * this.scaleValue / 2
    }
  }

  // 加载初始图片
  async loadImg() {
    try {
      HiLog.w(TAG, `loadImg start`);
      let pixelMap: image.PixelMap | undefined;
      pixelMap = await this.convertSelectImg(this.uri);
      const info = await pixelMap?.getImageInfo();
      const height = info?.size.height ?? 100;
      const width = info?.size.width ?? 100;
      let oriWidth =
        this.canvasContext.width < this.canvasContext.height ? this.canvasContext.width : this.canvasContext.height;
      this.imgWidth = oriWidth;
      this.imgHeight = oriWidth * height / width;
      if (this.imgHeight < CROP_HEIGHT) {
        this.imgHeight = CROP_HEIGHT;
        this.imgWidth = CROP_HEIGHT / height * width;
        this.oriSize = 1;
      }
      this.oriScale = this.imgWidth / width;
      this.updateFromXAndFromY();
      const color: ArrayBuffer = new ArrayBuffer(height * width * 4);
      let opts: image.InitializationOptions = { editable: true, pixelFormat: 3, size: { height, width } }
      const temp = await image.createPixelMap(color, opts);
      const buffer: ArrayBuffer = new ArrayBuffer(height * width * 4);
      await pixelMap?.readPixelsToBuffer(buffer);
      await temp.writeBufferToPixels(buffer);
      this.img = temp;
      HiLog.w(TAG, `loadImg end, img is undefined: ${this.img === undefined}`);
    } catch (err) {
      HiLog.e(TAG, `loadImg err: ${err.message}`);
    }
  }

  // 裁剪
  async crop() {
    try {
      HiLog.w(TAG, `crop start`);
      const pixelMap = this.img
      await pixelMap?.crop({ size: { height: this.cropHeight, width: this.cropWidth }, x: this.fromX, y: this.fromY })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `crop pixelMap, error.code: ${error?.code}, error.message:${error?.message}`);
        })

      this.imgScaled = copyPixelMap(pixelMap);
      let scaledImgInfo = this.imgScaled?.getImageInfoSync();
      let scaledL: number = 0;
      if (scaledImgInfo) {
        let size = scaledImgInfo.size;
        scaledL = size.width;
        let cropY = (size.height - size.width) / 2;
        if (cropY < 0) {
          cropY = 0;
        }
        await this.imgScaled?.crop({
          size: {height:scaledL, width:scaledL},
          x:0,
          y:cropY
        })
          .catch((error: BusinessError) => {
            HiLog.i(TAG, `crop scaled pixelMap, error.code: ${error?.code}, error.message:${error?.message}`);
          })
      }
      let vpValue = getContext(this).resourceManager.getNumber($r('app.float.id_card_image_mid'));
      let scale = 0.5;
      if (scaledL > 0) {
        scale = vp2px(vpValue) * 2 / scaledL;
      }
      HiLog.w(TAG, 'photo crop vpValue = ' + vpValue + ', scale = ' + scale);
      await this.imgScaled?.scale(scale, scale);
      HiLog.w(TAG, `crop end, imgScaled is undefined: ${this.imgScaled === undefined}`);
    } catch (err) {
      HiLog.e(TAG, `crop err: ${err.message}`);
    }
  }

  // draw image gray mask
  doDrawMask(showGuide: boolean = false) {
    this.canvasContext.globalCompositeOperation = 'source-over';

    let canvasX = this.canvasContext.width;
    let canvasY = this.canvasContext.height;
    let island = canvasX >= canvasY;
    // 需要清空画布保证不重复画
    let cropLocation = island ? 0.5 : CROP_AREA_LOCATION;
    this.canvasContext.clearRect(0, 0, canvasX, canvasY);

    let fromY = this.isPanelCenter ? canvasY * cropLocation : canvasY * cropLocation;
    this.oriY = this.isPanelCenter ? canvasY * cropLocation : canvasY * cropLocation;
    let curDiameter: number = this.curBp === 'sm' ? CROP_CIRCLE_L : BIG_CROP_CIRCLE_L;
    const windowHeightVp: number = px2vp(this.windowHeight);
    //解决设备上下三分之一分屏场景,裁剪直径会超过窗口高度问题
    if (windowHeightVp < curDiameter) {
      curDiameter = windowHeightVp;
    }
    this.cropCircleL = curDiameter;
    this.cropCircleR = this.cropCircleL / 2;
    // 解决重叠留白问题,减去1px
    let canvasL = this.cropCircleL - 1;

    if (showGuide) {
      this.canvasContext.shadowBlur = 0;
    } else {
      this.canvasContext.shadowBlur = 50;
      this.canvasContext.shadowColor = '#000000';
    }
    this.canvasContext.fillStyle = '#000000';
    this.canvasContext.globalAlpha = 0.8;
    this.canvasContext.fillRect(0, 0, canvasX, canvasY);

    const p1X = canvasX / 2 - 150;
    const p1Y = fromY - 200;

    this.cropX = p1X;
    this.cropY = p1Y;

    const p2X = canvasX / 2 + 150;
    const p2Y = fromY + 200;

    this.canvasContext.globalCompositeOperation = 'destination-out';
    this.drawCutRect(p1X, p1Y, p2X, p2Y);

    this.canvasContext.globalCompositeOperation = 'source-over';

    if (showGuide) {
      this.drawGuidArea(p1X, p1Y, p2X, p2Y);
    }
  }

  drawCutRect(p1X: number, p1Y: number, p2X: number, p2Y: number) {
    this.canvasContext.shadowBlur = 1
    this.canvasContext.fillStyle = 'rgb(0,0,0)';
    this.canvasContext.globalAlpha = 1;
    this.canvasContext.beginPath();

    this.canvasContext.moveTo(p1X, p1Y + 10);
    this.canvasContext.lineTo(p1X, p2Y - 10);
    this.canvasContext.arcTo(p1X, p2Y, p1X + 10, p2Y, 10);
    this.canvasContext.lineTo(p2X - 10, p2Y);
    this.canvasContext.arcTo(p2X, p2Y, p2X, p2Y - 10, 10);
    this.canvasContext.lineTo(p2X, p1Y + 10);
    this.canvasContext.arcTo(p2X, p1Y, p2X - 10, p1Y, 10);
    this.canvasContext.lineTo(p1X + 10, p1Y);
    this.canvasContext.arcTo(p1X, p1Y, p1X, p1Y + 10, 10);

    this.canvasContext.strokeStyle = Color.Red;
    this.canvasContext.stroke();

    this.canvasContext.closePath();
    this.canvasContext.fill();
  }
  drawGuidArea(p1X: number, p1Y: number, p2X: number, p2Y: number) {
    this.canvasContext.beginPath();
    this.canvasContext.moveTo(p1X, p1Y + 10);
    this.canvasContext.lineTo(p1X, p1Y + 64);
    this.canvasContext.lineTo(p2X, p1Y + 64);
    this.canvasContext.lineTo(p2X, p1Y + 10);
    this.canvasContext.arcTo(p2X, p1Y, p2X - 10, p1Y, 10);
    this.canvasContext.lineTo(p1X + 10, p1Y);
    this.canvasContext.arcTo(p1X, p1Y, p1X, p1Y + 10, 10);
    this.canvasContext.closePath();
    this.canvasContext.shadowBlur = 0;
    this.canvasContext.fillStyle = '#3f0000';
    this.canvasContext.globalAlpha = 0.3;
    this.canvasContext.fill();


    this.canvasContext.beginPath();
    this.canvasContext.moveTo(p1X, p2Y - 108);
    this.canvasContext.lineTo(p1X, p2Y - 10);
    this.canvasContext.arcTo(p1X, p2Y, p1X + 10, p2Y, 10);
    this.canvasContext.lineTo(p2X - 10, p2Y);
    this.canvasContext.arcTo(p2X, p2Y, p2X, p2Y - 10, 10);
    this.canvasContext.lineTo(p2X, p2Y - 108);
    this.canvasContext.lineTo(p1X, p2Y - 108);
    this.canvasContext.closePath();
    this.canvasContext.fill();
  }
  // 设置导航栏深色模式
  setDarkMode(status: string) {
    let windowClass: window.Window | undefined = undefined;
    try {
      window.getLastWindow(getContext(this), (err, data) => {
        const errCode: number = err.code;
        if (errCode) {
          HiLog.e(TAG, `Failed to obtain the top window. Cause errCode: ${errCode}`);
          return;
        }
        windowClass = data;
        HiLog.i(TAG,
          `Succeeded in obtaining the top window. statusBarContentColor: ${data?.getWindowSystemBarProperties()?.statusBarContentColor}`);

        let systemBarProperties: window.SystemBarProperties;
        if (status === SET_DARK_MODE_LIGHT) {
          systemBarProperties = {
            statusBarContentColor: '#ffffff',
          }
        } else {
          systemBarProperties = {
            statusBarContentColor: '#000000',
          }
        }

        try {
          if (this.isPC) {
            windowClass.setDecorButtonStyle({
              colorMode: ConfigurationConstant.ColorMode.COLOR_MODE_DARK
            });
            HiLog.i(TAG, 'setDecorButtonStyle success');
          }
          let promise = windowClass.setWindowSystemBarProperties(systemBarProperties);
          promise.then(() => {
            HiLog.i(TAG, 'Succeeded in setting the system bar properties.');
          }).catch((err: BusinessError) => {
            HiLog.e(TAG,
              `Failed to set the system bar properties. Cause: err.code: ${err?.code}, err.message: ${err?.message}`);
          });
        } catch (exception) {
          HiLog.e(TAG,
            `Failed to set the system bar properties. Cause: ${exception}`);
        }
      });
    } catch (exception) {
      HiLog.e(TAG,
        `Failed to obtain the top window. Cause: ${exception}`);
    }
  }

  setWindowOrientation(isTurnOffRotation: boolean) {
    let windowObj: window.Window | undefined = AppStorage.get('windowObj');
    if (!windowObj) {
      HiLog.e(TAG, 'set the window orientation Failed, can not get windowObj');
      return;
    }
    let windowOrientation: window.Orientation = window.Orientation.FOLLOW_DESKTOP;
    if (isTurnOffRotation) {
      if (this.curBp !== 'lg') {
        windowOrientation = window.Orientation.PORTRAIT;
      }
    }
    windowObj.setPreferredOrientation(windowOrientation).then(() => {
      HiLog.i(TAG, 'setting the window orientation Succeeded');
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'set the window orientation Failed, Cause: ' + err.message);
    });
  }
  aboutToAppear() {
    this.setWindowOrientation(true)
    this.setDarkMode(SET_DARK_MODE_LIGHT);
    this.loadImg()
    this.isPanelCenter = this.storage?.get<boolean>('isPanelCenter')
  }

  aboutToDisappear() {
    if (AppStorage.get('currentColorMode') != 0) {
      this.setDarkMode(SET_DARK_MODE_DARK);
    }
    this.setWindowOrientation(false)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Image(this.img)
            .id('img_hwid_edit_head_image_cropper_img')
            .scale({ x: this.scaleValue, y: this.scaleValue, z: 0 })
            .translate({ x: this.offsetX, y: this.offsetY + (this.oriY - this.imgHeight / 2), z: 0 })
            .width(this.imgWidth)
            .height(this.imgHeight)
            .draggable(false)
            .onError(() => {
              HiLog.e(TAG, 'Image onError!');
            })
            .onComplete(() => {
              HiLog.i(TAG, 'Image onComplete!');
              this.isPhotoComplete = true;
            })
        }
        .width('100%')
        .height('100%')
        Canvas(this.canvasContext)
          .id('img_hwid_edit_head_image_cropper_canvas')
          .width('100%')
          .height('100%')
          .enabled(false)
          .onReady(() => {
            HiLog.i(TAG, 'Canvas onReady!');
            this.doDrawMask();
          })

        Column() {
          Column({ space: 20 }) {
            Text(this.displayTitle)
              .fontSize(this.getTitleForAutoSize(this.displayTitle, 'sm'))
              .fontFamily('HarmonyHeiti')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.skin_font_on_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textShadow({
                radius: 20,
                color: '#3f3f3f'
              })
              .maxLines(2)
              .textAlign(TextAlign.Center)
              .width(CROP_WIDTH - 48)

            Text(this.displaySubTitle)
              .fontSize(14)
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.skin_font_on_primary'))
              .textShadow({
                radius: 20,
                color: '#3f3f3f'
              })
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(WordBreak.BREAK_ALL)
              .maxLines(1)
              .textAlign(TextAlign.Center)
              .width(CROP_WIDTH - 48)
          }
          .padding({ bottom: 20 })
          .justifyContent(FlexAlign.End)
          .alignItems(HorizontalAlign.Center)
          .offset({ y: this.cropY })
          .height(400)
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            // 在组件上绑定二指触发的捏合手势
            PinchGesture({ fingers: 2 })
              .onActionStart((_event?: GestureEvent | undefined) => {
                this.doDrawMask(true);
              })// 当捏合手势触发时，可以通过回调函数获取缩放比例，从而修改组件的缩放比例
              .onActionUpdate((event?: GestureEvent | undefined) => {
                this.scaleValue = this.pinchValue * event?.scale!;
              })
              .onActionEnd(() => {
                this.doDrawMask(false);
                this.checkScale()
                this.checkOutArea()
                this.updateFromXAndFromY()
              }),

            PanGesture()
              .onActionStart((_event?: GestureEvent | undefined) => {
                this.doDrawMask(true);
              })// 当触发拖动手势时，根据回调函数修改组件的布局位置信息
              .onActionUpdate((event?: GestureEvent | undefined) => {
                this.offsetX = this.positionX + event?.offsetX!;
                this.offsetY = this.positionY + event?.offsetY!;
              })
              .onActionEnd(() => {
                this.doDrawMask(false);
                this.checkOutArea()
                this.positionX = this.offsetX;
                this.positionY = this.offsetY;
                this.updateFromXAndFromY()
              })

          )
        )
        Row() {
          Row() {
            if (this.isPC) {
              Row() {
                Image($r('app.media.foreground_single'))
                  .width(24)
                  .height(24)
                  .objectFit(ImageFit.Contain)
                  .backgroundImage($r('app.media.background_single'))
                  .borderRadius($r('sys.float.padding_level3'))

                Text($r('app.string.contact'))
                  .fontSize('16vp')
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.fontColor)
                  .margin({ start: LengthMetrics.vp(8) })
              }
              .width('240vp')
              .height(56)
              .padding({ start: LengthMetrics.vp(24) })
              .focusable(false)
            }
            Button() {
              SymbolGlyph($r('sys.symbol.chevron_backward'))
                .fontSize($r('app.float.id_card_margin_max'))
                .fontColor([this.fontColor])
            }
            .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
            .height($r('app.float.id_item_height_sm'))
            .width($r('app.float.id_item_height_sm'))
            .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : $r('sys.float.corner_radius_level4'))
            .buttonStyle(ButtonStyleMode.NORMAL)
            .stateEffect(false)
            .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal_dark'))
            .margin({ left: $r('sys.float.padding_level8') })
            .onClick(() => {
              HiLog.i(TAG, 'back onClick!');
              this.isShow = false;
            })
            .accessibilityText(AccessibilityUtil.getInstance()
              .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_back')))

            Text($r('app.string.contact_photo'))
              .lineHeight('28vp')
              .fontSize(FontScaleState.isStandardGeer(this.fontSizeScale) ?
              $r('sys.float.Title_S') : $r('app.float.id_card_image_s'))
              .fontColor(this.fontColor)
              .fontWeight(FontWeight.Bold)
              .margin({
                left: $r('app.float.id_card_margin_large')
              })
          }

          Button() {
            SymbolGlyph($r('sys.symbol.checkmark'))
              .fontSize($r('app.float.id_card_margin_max'))
              .fontColor([this.fontColor])
          }
          .type(this.isPC ? ButtonType.Normal : ButtonType.Circle)
          .height($r('app.float.id_item_height_sm'))
          .id('contact_photo_save_bnt')
          .width($r('app.float.id_item_height_sm'))
          .borderRadius(this.isPC ? $r('sys.float.corner_radius_level2') : $r('sys.float.corner_radius_level4'))
          .buttonStyle(ButtonStyleMode.NORMAL)
          .stateEffect(false)
          .backgroundColor(this.isPC ? Color.Transparent : $r('app.color.skin_ohos_id_color_button_normal_dark'))
          .onClick(async () => {
            HiLog.i(TAG, 'ok onClick!');
            if (this.saveClicked) {
              return;
            }
            this.saveClicked = true;
            await this.crop();
            if (this.img && this.imgScaled) {
              this.onFinish(this.img, this.imgScaled);
            }
            this.isShow = false;
          })
          .margin({
            right: this.isPC ? 144 : $r('sys.float.padding_level8')
          })
          .enabled(this.isPhotoComplete)
          .accessibilityText(AccessibilityUtil.getInstance()
            .setAccessibilityText(this.isOpenAccessibility, $r('app.string.accessibility_done')))
        }
        .width('100%')
        .height($r('app.float.id_item_height_large'))
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .margin({
          top: px2vp(this.fullScreenPadding.top as number)
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .backgroundColor($r('app.color.skin_ohos_id_color_sub_background_dark'))
  }

  public getTitleForAutoSize(name: ResourceStr | undefined, curBp: string): number {
    let fontSize = 32;
    let size: number = this.cropX;
    let widthVp =
      curBp === 'sm' ?
        (px2vp(display.getDefaultDisplaySync().width) - size * 2) * 0.8 :
        (curBp === 'lg' ? $r('sys.float.ohos_id_text_size_headline5') :
          (px2vp(display.getDefaultDisplaySync().width) - size * 2))
    do {
      let num = px2vp(measure.measureText({
        textContent: name,
        fontSize: fontSize,
        fontWeight: 600
      }));
      if (num < widthVp) {
        break;
      }
    } while (--fontSize > 20);
    return fontSize;
  }
}