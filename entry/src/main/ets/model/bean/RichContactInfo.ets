import MeeTimeAbilityInfoModel from '../../../../../../feature/contact/src/main/ets/entity/MeeTimeAbilityInfoModel';
import { ContactInfo } from './ContactInfo';

export class RichContactInfo extends ContactInfo {
  public photoFirstName: string = ''
  // 对应contactdata名称类型数据，数据库EXTEND7，如果为1，表示联系人名称没有值，当前显示的名称是根据规则从其他详情信息获取的
  public nameUpdate?: number | string | Uint8Array
  public meeTimeAbilityInfoModel: MeeTimeAbilityInfoModel = new MeeTimeAbilityInfoModel()
  public accountId: number = -1

  constructor(id: string) {
    super(id, '', '', [], [], '', '', '', [], [], [], [], [], [], -1, '', '', '')
  }
}