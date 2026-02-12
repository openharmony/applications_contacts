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
import { DataItemType } from '../../../../../../feature/contact';
import { ArrayList, HashMap } from '@kit.ArkTS';

export class MergeContactInfo {
  public contactId: string = '';
  public nickname: string = '';
  // 公司
  public organization: string = '';
  // 职位
  public position: string = '';
  public blobData: Uint8Array = new Uint8Array();
  //存在子类型的字段集合 比如 email、生日等
  public dataInfoList: MergeContactDataInfo[] = [];
  //联系人详情信息集合  key: data_type+"_"+custom_data ,value : 对应的信息详情列表，
  // eg: 事件_生日，1991-07-08 1:1 ，地址_住宅，List<住宅信息> 1:n, 网址_ ,List<网址信息>
  public dataInfoMap: HashMap<string, ArrayList<MergeContactDataInfo>> = new HashMap();

  public static getKey(typeId: number, subTypeId: number): string {
    // 使用 typeid+ customData 组合作为该数据类型的唯一标识。部分类型只有typeId，则使用typeId作为唯一标识.subTypeId为空时，会转换成0作为匹配
    return typeId + '_' + subTypeId;
  }

  public addData(typeId: number, subTypeId: number, dataInfo: MergeContactDataInfo) {
    let key: string = MergeContactInfo.getKey(typeId, subTypeId);
    if (this.dataInfoMap.hasKey(key)) {
      this.dataInfoMap.get(key).add(dataInfo);
    } else {
      let dataInfoList: ArrayList<MergeContactDataInfo> = new ArrayList();
      dataInfoList.add(dataInfo);
      this.dataInfoMap.set(key, dataInfoList);
    }
  }
}

export class MergeContactDataInfo {
  // 对应type值
  public typeId: DataItemType;
  // 对应type对应的具体值
  public detailInfo: string;
  //eg: email 类型 : 0 1 2
  public customData: number;

  constructor(type: DataItemType, detailInfo: string, customData: number) {
    this.typeId = type;
    this.detailInfo = detailInfo;
    this.customData = customData;
  }
}
