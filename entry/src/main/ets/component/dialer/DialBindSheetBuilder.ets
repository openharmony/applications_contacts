/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import DialerPresenter from '../../presenter/dialer/DialerPresenter';

const TAG = 'DialBindSheetBuilder';
class Tmp {
  public mPresenter: DialerPresenter = DialerPresenter.getInstance();
}

@Component
struct StrComponent {
  @Prop str: string;

  build() {
    Text(this.str)
      .width('100%')
      .fontSize($r('sys.float.Subtitle_S'))
      .fontColor($r('app.color.skin_font_primary'))
      .fontWeight(FontWeight.Medium)
      .textAlign(TextAlign.Center)
      .copyOption(CopyOptions.LocalDevice)
      .margin({
        top: '28vp',
        bottom: $r('sys.float.padding_level2'),
      })
  }
}

@Builder
export function DialBindSheetBuilder(params: Tmp) {
  Column() {
    ForEach(params.mPresenter.pixelMapArr, (item: PixelMap, index: number) => {
      StrComponent({str: params.mPresenter.imeiStrArr[index]})
      Column(){
        Image(item)
          .width('100%')
          .height('100%')
      }
      .height('64vp')
      .width('174vp')
      .padding({
        top: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level6'),
        bottom: $r('sys.float.padding_level2'),
        left: $r('sys.float.padding_level6')
      })
      .backgroundColor('#F9F9F9')
    })
    if (params.mPresenter.eidStr) {
      StrComponent({ str: 'EID:' + params.mPresenter.eidStr })
      Column() {
        Image(params.mPresenter.eidPixelMap)
          .width('100%')
          .height('100%')
      }
      .height('64vp')
      .width('204vp')
      .padding({
        top: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level6'),
        bottom: $r('sys.float.padding_level2'),
        left: $r('sys.float.padding_level6')
      })
      .backgroundColor('#F9F9F9')
    }
    if (params.mPresenter.serialStr.length > 0) {
      StrComponent({str: 'SN:' + params.mPresenter.serialStr})
      Column(){
        Image(params.mPresenter.serialPixelMap)
          .width('100%')
          .height('100%')
      }
      .height('64vp')
      .width('204vp')
      .padding({
        top: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level6'),
        bottom: $r('sys.float.padding_level2'),
        left: $r('sys.float.padding_level6')
      })
      .backgroundColor('#F9F9F9')
    }
  }
  .padding({
    bottom: '28vp'
  })
  .margin({
    left: $r('sys.float.padding_level8'),
    right: $r('sys.float.padding_level8')
  })
  .align(Alignment.Center)
  .onAreaChange((oldValue: Area, newValue: Area) => {
    params.mPresenter.sizeValue = JSON.stringify(newValue);
  })
  .onDisAppear(() => {
    params.mPresenter.releasePixelMap();
  })
}