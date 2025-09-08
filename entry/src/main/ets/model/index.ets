import { ContactVo } from "./bean/ContactVo";
import common from '@ohos.app.ability.common';
import { RichContactInfo } from "./bean/RichContactInfo";

export interface BatchSelectContact {
  showIndex: boolean,
  showDivifer: boolean,
  contact: ContactVo,
  index: number,
  single?: boolean,
  calllog: CallLogDetailInterface
}

export interface CallLogDetailInterface {
  id: string,
  phoneNumber: string,
  displayName: string,
  callDirection: string,
  isRead: string,
  ringDuration: string,
  endTime: string,
  suffix:string,
  portraitColor:ResourceColor,
  formattedNumber:string,
  numberLocation:string,
  checked:boolean,
}

export interface GetLunarDateRe {
  year: number
  month: number
  day: number,
  isLeapMonth: boolean
}

export interface PageLimit {
  page?: number,
  limit?: number
}

export interface AllCallsGetActionData extends PageLimit {
  favoriteForm?: string
  isNeedQueryContact?: boolean
  // 是否使用静默访问方式查询
  isProxyQuery?: boolean
}

export interface FindByNumberActionData extends PageLimit {
  context?: common.UIAbilityContext,
  numbers: string[],
  contactId?: number,
}

export interface CallHistorySearchGetActionData {
  teleNumber: string
  nameArray: Array
}

export class SendMessageParams {
  public contactName: string;
  public telephone: string;
  public telephoneFormat: string;
  public contactId?: number;

  constructor(number: string, formatNum: string, name?: string, id?: number) {
    this.telephone = number;
    this.telephoneFormat = formatNum;
    this.contactName = name as string;
    this.contactId = id;
  }
}

export interface AccountantParams extends SingleSelectContact {
  isEditMyCard?: boolean
  isCreateMyCard?: boolean
  avtarDeletedCallBack?: () => void
  phoneNumbers?: Record<string, string>[],
}

export interface SingleSelectContact {
  editContact: number,
  contactId: string,
  phones: ContackPhoneSubInfoModel[],
  callId: string,
  phoneNumberShow: string,
  sourceHasParam?: boolean,
  //是否展开更多
  updataShow?: boolean,
  disPlayName: string,
  phoneNumbers?: Record<string, string>[],
  nameRawContactId?: number,
  displayNameHighlight?: boolean,
}

export interface ContactInterface {
  i: number,
  item: T
}

export class ContactReturnObj {
  public data?: RichContactInfo
}

export interface BaseContackSubInfoModel {
  id: string;
  data: string;
  type: number;
  labelName: Resource | string;
  dataType: number;
  calendarEventId: string;
  contactDataId: number;
}

export interface ContackPhoneSubInfoModel extends BaseContackSubInfoModel {
  num?: string;
  phoneAddress?: string | Resource;
  primary?: boolean;
  dataId?: number;
  formatNum?: string;
}

export interface TargetPageInter {
  url?: string,
  pageIndex?: number,
  params?: Record<string, string>
}

export class DetailInfo {
  id:number = -1;
  data: string = '';
  labelName: Resource|string = '';
  type: number | undefined = -1;
}