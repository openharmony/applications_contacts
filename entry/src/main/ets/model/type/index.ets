import MergedCallLog from '../../../../../../feature/call/src/main/ets/entity/MergedCallLog';
import { DataItemType } from '../../../../../../feature/contact';
import { ContactVo } from '../bean/ContactVo';
import common from '@ohos.app.ability.common';
import { FavoriteBean } from '../bean/FavoriteBean';
import { RichContactInfo } from '../bean/RichContactInfo';
import { MergeRule } from '../../../../../../feature/call/src/main/ets/CallLogSetting';
import { ContackPhoneSubInfoModel } from './ContactParams';
import { EnterSingleSelectedMode } from './EnumUtil';
import { AssociatedPersonBean } from '../bean/AssociatedPersonBean';
import contact from '@ohos.contact';
import { CallLogTemp } from '../../../../../../feature/call/src/main/ets/entity/CallLogTemp';
import { RingtoneInfo } from '../ringTone/toneTypes';

export interface CallLogInterface {
  showDivifer: boolean,
  index: number,
  calllog: MergedCallLog
}

export interface SetPrimaryParam {
  contactId: string,
  dataType: DataItemType,
  dataId?: number,
  primary: boolean
}

export interface PhoneNumberInterface {
  // 对应contactdata表id
  dataId: number;

  // 对应detail_info
  phoneNumber: string,
  labelId: string,
  numType: string,
  labelName: Resource | string |undefined
  checked: boolean,
  startPhone: string,
  middlePhone: string,
  endPhone: string,
  primary?: boolean,
}

export interface ContactInterface {
  i: number,
  item: T
}

export interface BatchSelectContact {
  showIndex: boolean,
  showDivifer: boolean,
  contact: ContactVo,
  index: number,
  single?: boolean,
}

export interface ContactStrInterface {
  index: number,
  data: string,
}

export interface SingleSelectContact {
  editContact: number,
  contactId: number,
  callId: string,
  phones: ContackPhoneSubInfoModel[],
  phoneNumberShow: string,
  sourceHasParam?: boolean,

  //是否展开更多
  updataShow?: boolean,
  disPlayName?: string,
  phoneNumbers?: Record<string, string>[],
  fromSpeedDial?: EnterSingleSelectedMode,
  nameRawContactId?: number,
  displayNameHighlight?: boolean,

  //关联人
  relationships: AssociatedPersonBean[],
  newContactData?: contact.Contact,

  // 铃声
  ringtoneInfo?: RingtoneInfo,
}

export interface AccountantParams extends SingleSelectContact {
  isEditMyCard?: boolean
  isCreateMyCard?: boolean
  avtarDeletedCallBack?: () => void
}

export interface TableDataInterface {
  callLog: CallLogDetailInterface
}

export interface CallLogDetailInterface {
  id: string,
  phoneNumber: string,
  displayName: string,
  callDirection: string,
  isRead: string,
  ringDuration: string,
  endTime: string,
}

export interface RequestParam {
  actionData: T,
  context: common.UIAbilityContext
}

export interface DisplayNameParam {
  displayName: string[],
  usuallyPhone: string[],
  context: common.UIAbilityContext
}

export interface ContactDetailParam {
  sourceHasId: boolean,
  contactId: string
}

export interface SelectContactParam {
  addFavorite: number,
  selectType: number,
}

export interface EditFavoriteParam {
  favoriteList: FavoriteBean[],
  defaultSelectId?: string,
}

export interface FavoriteListParam {
  context: common.UIAbilityContext,
  favoriteList: string,
  favorite: number,
  favoriteOrder?: number,
}

export interface DeleteFavoriteParam {
  context: common.UIAbilityContext,
  favoriteList: string[],
}

export interface UsuallyListParam {
  context: common.UIAbilityContext,
  usuallyList: string
}

export class EmptyParam {
}

export interface ContactIdParam {
  context: common.UIAbilityContext,
  contactId: string,
}

export interface SearchContactParam {
  value: string,
  loopRequest: boolean,
  startIndex: number,
  limitNumber: number,
}

export class ContactReturnObj {
  public data?: RichContactInfo
}

export class ContactReturnArray {
  public data?: RichContactInfo[]
}

export interface SpeedDialItem {
  number?: number,
  contactName?: string,
  contactTelephone: string,
  portraitColor?: ResourceStr,
  nameSuffix?: string,
  namePrefix?: string,
  portraitPath?: string,
  contactId?: string
}

export interface VoiceMailItem {
  voiceMailItemName: ResourceStr;
  voiceMailItemValue: string;
  placeholder: ResourceStr
}

export interface PageLimit {
  page?: number,
  limit?: number
}

export interface GetAllCallActionData extends PageLimit {
  favoriteForm: string
  mergeRule: MergeRule
  isNeedQueryContact: boolean
}

export interface ReqData {
  actionData: T,
}

export interface AllCallsGetActionData extends PageLimit {
  mergeRule?: MergeRule
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

export interface FindPhotoByIdActionData extends PageLimit {
  context?: common.UIAbilityContext,
}

export interface CallHistorySearchGetActionData {
  teleNumber: string
  nameArray: Array
}

export interface paramsInterface {
  mainTabsIndex?: number,
  contactId?: Object,
  sourceHasId?: boolean,
  phoneNumberShow?: Object,
  fromSmsList?: boolean,
  sourceHasPhone?: boolean,
  teleNumber?: Object,
  disPlayName?: Object,
  phoneNumbers?: Array<Record<string, string>>,
  number?: Object,
  type?: string,
  selectType?: number,
  contactCount?: Object,
  isLimit?: Object,
  sourceHasParam?: boolean,
  isNotShowTab?: boolean,
  pageFlag?: string,
  addFavorite?: number,
  isCardEntry?: boolean,
  editContact?: number,
  newContactData?: contact.Contact,
  isFormCard?: boolean,
  isCardSharing?: boolean,
  isSaveExistContact?: boolean,
  isDisplayByName?: boolean,
  isNoMissFormCard?: boolean
}

export interface GetLunarDateRe {
  year: number
  month: number
  day: number,
  isLeapMonth: boolean
}

export interface TargetPageInter {
  url?: string,
  pageIndex?: number,
  params?: Record<string, string>
}

export interface GroupParams {
  id?: number,
  groupName: string,
}

export interface SelectContactParams {
  addFavorite?: number
  contactCount?: number
  isLimit?: boolean
  pageTag?: string
  groupId?: number
  isNotShowTab?: boolean
  isCardEntry?: boolean
}

export interface ScrollerOffset {
  xOffset: number;
  yOffset: number;
}

export interface ContactBlobSource {
  contactId: string,
  blobSource: number,
  rawContactId: string,
  detailInfo: string,
  blobData?: Uint8Array | undefined,
}

export interface RecorderLog {
  id: number,
  dateAdded: string,
  filePath: string,
  displayName: string,
  phoneNumber?: string,
}

export interface dialogDataStruct {
  objectUse: string
  confirm: (value?: string) => void
}

export class RepeatContact {
  public contactId: string = ''
  public name: string = ''
  public phoneTags: string[] = []

  constructor() {
    this.resetRepeatContact();
  }

  getUniqueKey() {
    let uniqueKey = this.name + '-' + this.phoneTags.sort().join('-');
    return uniqueKey;
  }

  initFromRepeatContact(repeatContact: RepeatContact) {
    this.contactId = repeatContact.contactId;
    this.name = repeatContact.name;
    this.phoneTags = repeatContact.phoneTags;
  }

  resetRepeatContact() {
    this.contactId = '';
    this.name = '';
    this.phoneTags = [];
  }
}

export interface CustomizedParams {
  PNAMEID?: string,
  PVERSIONID?: string,
  ENC?: number,
  ISNAME?: number,
  ISUNIT?: number,
  ISPHONE?: number,
  ISEMAIL?: number,
  ISMESSAGE?: number,
  ISADDRESS?: number,
  ISREMARKS?: number,
  ISNICKNAME?: number,
  ISWEBSITE?: number,
  ISBIRTHDAYDATE?: number,
  ISASSOCIATED?: number,
  FLAG?: number,
  ACTION?: number,
  ISPOP?: number,
  ISSAVE?: number,
  ISDELETE?: number,
  LEVELONE?: number,
  LEVELTWO?: number,
  ISCANCEL?: number,
  ITEM?: number,
  ISSELECT?: number,
  ISCREATE?: number,
  ISADD?: number,
  ISDRAG?: number,
  ISREMOVE?: number,
  ISFAVORITE?: number,
  ISCLICK?: number,
  ISDEFAULT?: number,
  ISOPEN?: number,
  ISKNOW?: number,
  ISMERGE?: number,
  NUM?: number,
  ISRESULT?: number,
  RESULT?: number,
  SLOT?: number,
  TYPE?: string,
  ISMULTISIMCARD?: number,
  ISSHOW?: number,
  ISSET?: number,
  ISIUPUT?: number,
  ISOK?: number,
  SETNUM?: number,
  HAS_DEFAULT_SIM_CARD?: number,
  EDIT_ACTIONS?: number,
  ISEXPORT?: number,
  REGISTERED_VOLTE_CARD?: number,
  BLOCKED_STATUS?: number,
  OPTION?: number,
  CONFIRM?: number,
  RECOVER?: number,
  FAULT_INFO?: string,
  CLEAR?: number,
  OPERATE?: number,
  IMPORT?: number,
  MARKTYPE?: number,
  INDEX?: number,
  DIRECTION?: number,
  MARKSOURCE?: string
}

export interface DialerSearchResultType {
  resultList: CallLogTemp[],
  contactsOffset: number,
  teleOffset: number,
  contactsResultOffset: number,
  contactNameKeySet: string[],
  searchPhoneNumberSet: string[]
}

export enum CachedContactsPixelMapType {
  CONTACT_LIST = 0,
  CONTACT_SEARCH_LIST = 1,
}