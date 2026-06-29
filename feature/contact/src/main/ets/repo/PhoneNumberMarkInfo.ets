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
import { HiLog } from '../../../../../../common';
import { ObjectUtil, StringUtil } from 'common';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import NumberMark from '../contract/NumberMark';
import LooseObject from '../../../../../../entry/src/main/ets/model/type/LooseObject';
import NumberMarkUtil from '../../../../../../entry/src/main/ets/util/NumberMarkUtil';

@Concurrent
export async function getNumberMarkInfoTask(context: Context, number: string): Promise<LooseObject> {
  HiLog.w('getNumberMarkInfoTask', `getNumberMarkInfoTask: ${StringUtil.maskSensitiveInfo(number)}`);

  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    if (StringUtil.isEmpty(number)) {
      return {
        markType: '0'
      }
    }
    HiLog.i('getNumberMarkInfoTask', 'Start to query a phoneNumber is in numberMark.');
    let dataShareHelper: dataShare.DataShareHelper =
      await dataShare.createDataShareHelper(context, NumberMark.NUMBER_MARK_URI);
    let option = new dataSharePredicates.DataSharePredicates();
    option.equalTo(NumberMark.NUMBER, number);
    resultSet = await dataShareHelper.query(NumberMark.NUMBER_MARK_INFO_URI, option, []);
    if (resultSet.rowCount === 0) {
      HiLog.e('getNumberMarkInfoTask', 'phoneNumber is not in numberMark');
    }
    let res: LooseObject = {};
    resultSet.goToFirstRow();
    do {
      let isCloud = resultSet.getDouble(resultSet.getColumnIndex(NumberMark.IS_CLOUD));
      res.isCloud = isCloud;
      res.markType = NumberMarkUtil.getNumberMarkType(
        resultSet.getString(resultSet.getColumnIndex(NumberMark.CLASSIFY)));
      res.markContent = resultSet.getString(resultSet.getColumnIndex(NumberMark.NAME));
      res.markCount = resultSet.getDouble(resultSet.getColumnIndex(NumberMark.MARKED_COUNT));
      res.markSource = resultSet.getString(resultSet.getColumnIndex(NumberMark.SUPPLIER));
      res.markDetails = resultSet.getString(resultSet.getColumnIndex(NumberMark.DESCRIPTION));
      if (res.markType === '2' && res.markSource === '5' && !NumberMarkUtil.isFromNationalAntiFraudCenter(context)) {
        res.markSource = '3';
      }

      HiLog.w('getNumberMarkInfoTask', `markType: ${res.markType},markSource: ${res.markSource}`);
      if (isCloud === 0) {
        break;
      }
    } while (resultSet.goToNextRow())
    return res;
  } catch (err) {
    HiLog.e('getNumberMarkInfoTask', `numberMark error: ${err?.message}, stack: ${err?.stack}`);
    return {
      markType: '0'
    }
  } finally {
    ObjectUtil.closeResultSet(resultSet);
  }
}
