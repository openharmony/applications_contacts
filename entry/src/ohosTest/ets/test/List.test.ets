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
import SystemModeControllerTest from './entry/util/SystemModeController.test'
import ToneTypesTest from './entry/model/ringTone/toneTypes.test'
import VCardImportUtilTest from './entry/util/VcardImportUtil.test'
import RingTonePresenterTest from './entry/presenter/ringtone/RingTonePresenter.test'
import RingtoneSelectionUtilTest from './entry/util/RingtoneSelectionUtil.test'
import ContactsPickerPresenterTest from './entry/presenter/contact/batchselectcontacts/ContactsPickerPresenter.test'
import RoamingManagerTest from './feature/RoamingManager.test'
import BigPhotoCopyUtilTest from './entry/util/BigPhotoCopyUtil.test'
import PreDefineContactUtilTest from './entry/util/PreDefineContactUtil.test'
import InterceptionCallRecordListDataSourceTest from './entry/model/bean/InterceptionCallRecordListDataSource.test'
import ScreenFormUtilTest from './entry/util/ScreenFormUtil.test'
import fontScaleStateTest from './entry/util/fontScaleState.test'
import HiCarCallRecordPresenterTest from './entry/presenter/dialer/callRecord/HiCarCallRecordPresenter.test'
import DeviceTypeUtilTest from './entry/util/DeviceTypeUtil.test'
import CallSharingModelTest from './entry/model/CallSharingModel.test'
import SimCardStateTest from './entry/feature/sim/SimCardState.test'
import RemoveMemberPresenterTest from './entry/presenter/group/RemoveMemberPresenter.test'
import VibrationUtilsTest from './entry/util/VibrationUtils.test'
import NameDisposalTest from './entry/feature/NameDisposal.test'
import SpeedDialAbilityTest from './entry/speeddialability/SpeedDialAbility.test'
import PageManagerTest from './entry/dialogentryability/PageManager.test'
import DialogEntryAbilityTest from './entry/dialogentryability/DialogEntryAbility.test'
import SpeedDialEditCommonTest from './entry/card/common/SpeedDialEditCommon.test'
import ShortcutEditCommonTest from './entry/card/common/ShortcutEditCommon.test'
import SettingsDatashareCommonTest from './entry/card/common/SettingsDatashareCommon.test'
import MissedCallDataShareTest from './entry/card/common/MissedCallDataShare.test'
import EntryFormAbilityTest from './entry/entryformability/EntryFormAbility.test'
import FormCardControllerTest from './entry/card/common/FormCardController.test'
import SpeedDialCardAbilityTest from './entry/card/ability/SpeedDialCardAbility.test'
import ShortcutCardAbilityTest from './entry/card/ability/ShortcutCardAbility.test'
import MissedCallCardAbilityTest from './entry/card/ability/MissedCallCardAbility.test'
import VCardUtilTest from './entry/util/VCardUtil.test'
import SettingsPresenterTest from './entry/presenter/contact/settings/SettingsPresenter.test'
import BatchSelectPresenterTest from './entry/presenter/contact/settings/BatchSelectPresenter.test'
import SimIccDiallingNumbersTest from './entry/feature/sim/SimIccDiallingNumbers.test'
import SimOpNameTest from './entry/feature/sim/SimOpName.test'
import VoLteStateTest from './entry/feature/sim/VoLteState.test'
import ErrorStringUtilTest from './entry/util/ErrorStringUtil.test'
import SimManagerTest from './entry/feature/sim/SimManager.test'
import MissedCallManagerTest from './entry/feature/missedCall/MissedCallManager.test'
import EnvironmentPropTest from './entry/feature/EnvironmentProp.test'
import AirplaneModelTest from './entry/model/AirplaneModel.test'
import SearchContactResultTest from './entry/model/bean/SearchContactResult.test'
import AccountantsPresenterTest from './entry/presenter/contact/accountants/AccountantsPresenter.test'
import CallStateModelTest from './entry/model/CallStateModel.test'
import AddFavoriteListPresenterTest from './entry/presenter/favorite/AddFavoriteListPresenter.test'
import MutiDialerButtonViewTest from './entry/component/mutisim/MutiDialerButtonView.test'
import DialerButtonViewTest from './entry/component/dialer/DialerButtonView.test'
import ArrangeContactsPresenterTest from './entry/presenter/contact/settings/ArrangeContactsPresenter.test'
import BatchDeleteGroupPresenterTest from './entry/presenter/group/BatchDeleteGroupPresenter.test'
import ContactListDataSourceTest from './entry/model/bean/ContactListDataSource.test'
import BatchDeleteContactSource from './entry/model/bean/BatchDeleteContactSource.test'
import ContactDetailDataSourceTest from './entry/model/bean/ContactDetailDataSource.test'
import ContactBeanTest from './entry/model/bean/ContactBean.test'
import CallRecordListDataSourceTest from './entry/model/bean/CallRecordListDataSource.test'
import CallLogBeanTest from './entry/model/bean/CallLogBean.test'
import AccountVoTest from './entry/model/bean/AccountVo.test'
import GroupListDetailPresenterTest from './entry/presenter/group/GroupListDetailPresenter.test'
import BatchSelectRecentSourceTest from './entry/model/bean/BatchSelectRecentSource.test'
import ContactInfoTest from './entry/model/bean/ContactInfo.test'
import CallBeanTest from './entry/model/bean/CallBean.test'
import BatchSelectContactSourceTest from './entry/model/bean/BatchSelectContactSource.test'
import BasicDataSourceTest from './entry/model/bean/BasicDataSource.test'
import AssociatedPersonBeanTest from './entry/model/bean/AssociatedPersonBean.test'
import AIMBeanTest from './entry/model/bean/AIMBean.test'
import SelectMemberSendMessagePresenterTest from './entry/presenter/group/SelectMemberSendMessagePresenter.test'
import FavoriteListPresenterTest from './entry/presenter/favorite/FavoriteListPresenter.test'
import AlphabetIndexerPresenterTest from './entry/presenter/contact/alphabetindex/AlphabetIndexerPresenter.test'
import ContactListPresenterTest from './entry/presenter/contact/ContactListPresenter.test'
import LimitRefreshDataUtilTest from './entry/util/LimitRefreshDataUtil.test'
import VoicemailManagerTest from './entry/feature/sim/VoicemailManager.test'
import StringFormatUtilTest from './entry/util/StringFormatUtil.test'
import CalendarUtilTest from './entry/util/CalendarUtil.test'
import PreferencesUtilTest from './entry/util/PreferencesUtil.test'
import IndexPresenterTest from './entry/presenter/IndexPresenter.test'
import ArrayUtilTest from './common/util/ArrayUtil.test'
import ContactsGlobalThisHelperTest from './common/util/ContactsGlobalThisHelper.test'
import ObjectUtilTest from './common/util/ObjectUtil.test'
import StringUtilTest from './common/util/StringUtil.test'
import NumberAddressUtilTest from './common/util/NumberAddressUtil.test'
import CallLogServiceTest from './feature/call/CallLogService.test'
import UserPhotoTest from './entry/util/UserPhotoUtil.test'
import CallLogRepositoryTest from './feature/call/repo/CallLogRepository.test'
import CallLogSettingTest from './feature/call/CallLogSetting.test'
import AimTest from './feature/contact/contract/Aim.test'
import BirthdayTest from './feature/contact/contract/Birthday.test'
import EmailTest from './feature/contact/contract/Email.test'
import EventTest from './feature/contact/contract/Event.test'
import HouseTest from './feature/contact/contract/House.test'
import ImTest from './feature/contact/contract/im.test'
import PhoneTest from './feature/contact/contract/Phone.test'
import RelationTest from './feature/contact/contract/Relation.test'
import StructuredPostalTest from './feature/contact/contract/StructuredPostal.test'
import ContactTest from './feature/contact/entity/Contact.test'
import ContactBuilderTest from './feature/contact/entity/ContactBuilder.test'
import CallLogTest from './feature/call/entity/CallLog.test'
import CallLogBuilderTest from './feature/call/entity/CallLogBuilder.test'
import MissedCallNotifierTest from './feature/call/missedcall/MissedCallNotifier.test'
import MissedCallServiceTest from './feature/call/missedcall/MissedCallService.test'
import MmsServiceTest from './feature/phonenumber/MmsService.test'
import PhoneNumberTest from './feature/phonenumber/PhoneNumber.test'
import DataItemTest from './feature/contact/entity/DataItem.test'
import PhoneDateItemTest from './feature/contact/entity/PhoneDataItem.test'
import RelationDataItemTest from './feature/contact/entity/RelationDataItem.test'
import DialerPresenterTest from './entry/presenter/dialer/DialerPresenter.test'
import CallRecordPresenterTest from './entry/presenter/dialer/callRecord/CallRecordPresenter.test'
import BatchDeletePresenterTest from './entry/presenter/dialer/batchdelete/BatchDeletePresenter.test'
import DataWorkerTaskTest from './entry/workers/DataWorkerTask.test'
import RawContactTest from './feature/contact/entity/RawContact.test'
import PermissionManagerTest from './common/permission/PermissionManager.test'
import SharedPreferencesUtilsTest from './common/util/SharedPreferencesUtils.test'
import WindowsManagerTest from './common/util/WindowsManager.test'
import SearchContactsSourceTest from './entry/model/bean/SearchContactsSource.test'
import CalllogModelTest from './entry/model/calllog/CalllogModel.test'
import CallLogDeltaTest from './feature/call/repo/CallLogDelta.test'
import ContactParamsTest from './entry/model/type/ContactParams.test'
import ContactVoTest from './entry/model/bean/ContactVo.test'
import DetailCallLogDataSourceTest from './entry/model/bean/DetailCallLogDataSource.test'
import DeviceInfoBeanTest from './entry/model/bean/DeviceInfoBean.test';
import EmailBeanTest from './entry/model/bean/EmailBean.test'
import EventBeanTest from './entry/model/bean/EventBean.test'
import FavoriteBeanTest from './entry/model/bean/FavoriteBean.test'
import FavoriteDataSourceTest from './entry/model/bean/FavoriteDataSource.test'
import GroupBeanTest from './entry/model/bean/GroupBean.test'
import GroupListDataSourceTest from './entry/model/bean/GroupListDataSource.test'
import GroupMemberDataSourceTest from './entry/model/bean/GroupMemberDataSource.test'
import GroupMemberListBeanTest from './entry/model/bean/GroupMemberListBean.test'
import HouseBeanTest from './entry/model/bean/HouseBean.test'
import PhoneNumBeanTest from './entry/model/bean/PhoneNumBean.test'
import RemDayBeanTest from './entry/model/bean/RemDayBean.test'
import RepeatDataSourceTest from './entry/model/bean/RepeatDataSource.test'
import SearchContactsBeanTest from './entry/model/bean/SearchContactsBean.test'
import ContactRepositoryTest from './feature/contact/repo/ContactRepository.test'
import WorkerTaskTest from './entry/workers/base/WorkerTask.test'
import WorkFactoryTest from './entry/workers/WorkFactory.test'
import WorkWrapperTest from './entry/workers/base/WorkerWrapper.test'
import GetNumberLocation from './entry/util/GetNumberLocation.test'
import DetailPresenterTest from './entry/presenter/contact/detail/DetailPresenter.test'
import DotUtilTest from './entry/util/DotUtil.test'
import ResourceUtilTest from './entry/util/ResourceUtil.test'
import SpeedDialPresenterTest from './entry/presenter/speeddial/SpeedDialPresenter.test'
import EditFavoriteListPresenterTest from './entry/presenter/favorite/EditFavoriteListPresenter.test'
import MeetimeCallsTest from './feature/call/contract/MeetimeCalls.test'
import CallRecordTimeFormatUtilsTest from './common/util/CallRecordTimeFormatUtils.test'
import NavPathCheckUtilTest from './common/util/NavPathCheckUtil.test'
import NumberMatchTest from './feature/contact/cust/NumberMatch.test'
import ContactNameNumberInfoTest from './feature/contact/entity/ContactNameNumberInfo.test'
import MeeTimeAbilityInfoModelTest from './feature/contact/entity/MeeTimeAbilityInfoModel.test'
import MeeTimeDeviceInfoModelTest from './feature/contact/entity/MeeTimeDeviceInfoModel.test'
import ContactDeltaTest from './feature/contact/repo/ContactDelta.test'
import RawContactDeltaTest from './feature/contact/repo/RawContactDelta.test'
import ValuesDeltaTest from './feature/contact/repo/ValuesDelta.test'
import TaskUtilTest from './common/util/TaskUtil.test'
import DynamicLoaderTest from './common/util/DynamicLoader.test'
import DeviceUtilsTest from './common/util/DeviceUtils.test'
import CallDetailTest from './entry/model/bean/CallDetail.test'
import PageManagerMainAbilityTest from './entry/MainAbility/PageManagerMainAbility.test'
import GroupListPresenterTest from './entry/presenter/group/GroupListPresenter.test'
import LunarUtilsTest from './entry/util/LunarUtils.test'
import ProfileUtilsTest from './entry/util/ProfileUtils.test'
import GetDpiZoomSizeTest from './entry/model/GetDpiZoomSize.test'
import CardDialogExtensionAbilityTest from './entry/card/ability/CardDialogExtensionAbility.test'
import BannerTest from './entry/card/common/utils/Banner.test'
import GetNumberLocationTest from './entry/util/GetNumberLocation.test'
import HiCarUtilTest from './entry/util/HiCarUtil.test'
import CallServiceManagerTest from './feature/phonenumber/idl/CallServiceManager.test'
import ListenerManagerTest from './entry/listeners/ListenerManager.test'
import MissedCallEditCommonTest from './entry/card/common/MissedCallEditCommon.test'
import IdlServiceBannerProxyTest from './entry/card/idl/IdlServiceBannerProxy.test'
import MainAbilityTest from './entry/MainAbility/MainAbility.test'
import OriginalDataHandleHelperTest from './entry/presenter/contact/accountants/OriginalDataHandleHelper.test'
import IdlMeetimeServiceProxyTest from './feature/phonenumber/idl/service/IdlMeetimeServiceProxy.test'
import MeeTimeServiceTest from './feature/phonenumber/MeeTimeService.test'
import RemoteContactInfoTest from './feature/phonenumber/idl/model/RemoteContactInfo.test'
import IdlContactsServiceProxyTest from './feature/phonenumber/idl/service/idl_contacts_service_proxy.test'
import IdlCallServiceProxyTest from './feature/phonenumber/idl/service/idl_call_service_proxy.test'
import ContactAbilityModelTest from './entry/model/ContactAbilityModel.test'
import BatchDeleteContactsPresenterTest from './entry/presenter/contact/settings/BatchDeleteContactsPresenter.test'
import AccessibilityUtilTest from './entry/util/AccessibilityUtil.test'
import InterceptionCallsExtAbilityTest from './interception/InterceptionCallsExtAbility.test'
import TelNumberModelTest from './entry/model/TelNumberModel.test'
import ContactListBoModelTest from './entry/model/ContactListBoModel.test'
import CantactColumnUtilsTest from './entry/util/CantactColumnUtils.test'
import CustomNavigationUtilTest from './entry/util/CustomNavigationUtil.test'
import JsonUtilTest from './common/util/JsonUtil.test'
import HiCarContactListDataSource from './entry/model/bean/HiCarContactListDataSource.test'
import RecentDeleteDataSourceTest from './entry/model/bean/RecentDeleteDataSource.test'
import RoamingUtilsTest from './common/util/RoamingUtils.test'
import RecentDeletePresenterTest from './entry/presenter/contact/settings/RecentDeletePresenter.test'
import ContactUiExtentionAbilityTest from './entry/uiExtentionAbility/ContactUiExtentionAbility.test'
import BatchSelectFavoriteSourceTest from './entry/model/bean/BatchSelectFavoriteSource.test'
import SearchUtilTest from './entry/util/SearchUtil.test'
import ContactWorkSchedulerUtilTest from './entry/util/ContactWorkSchedulerUtil.test'
import MeetimeDeviceInfoDataSourceTest from './entry/model/bean/MeetimeDeviceInfoDataSource.test'
import CaretPositionUtilTest from './entry/util/CaretPositionUtil.test'
import StaticSubscriberTest from './entry/StaticSubscriber/StaticSubscriber.test'
import DisplaySplitUtilTest from './entry/util/DisplaySplitUtil.test'
import ContactInfoUtilTest from './entry/util/ContactInfoUtil.test'
import LunarDateUtilTest from './common/date/LunarDateUtil.test'
import DateManagerTest from './common/date/DateManager.test'
import DateTest from './common/date/Date.test'
import DateUtilTest from './common/util/DateUtil.test'
import CountryIdUtilTest from './common/util/CountryIdUtil.test'
import ContactPickerDataSourceTest from './entry/model/bean/ContactPickerDataSource.test'
import NumberMarkUtilTest from './entry/util/NumberMarkUtil.test'
import ResourceAudioManagerTest from './entry/presenter/ringtone/ResourceAudioManager.test'
import BreakpointUtilTest from './entry/util/BreakpointUtil.test'
import TelecomServiceTest from './feature/phonenumber/TelecomService.test'
import DateTimeFormatTest from './entry/util/DateTimeFormat.test'
import QrCodeManagerTest from './entry/presenter/qrcode/QrCodeManager.test'
import VCardParseTest from './entry/presenter/qrcode/VCardParse.test'

export default function testsuite() {
  ToneTypesTest();
  DateTimeFormatTest();
  VCardImportUtilTest();
  RingTonePresenterTest();
  BreakpointUtilTest();
  ResourceAudioManagerTest();
  NumberMarkUtilTest();
  ContactPickerDataSourceTest();
  IndexPresenterTest();
  PreferencesUtilTest();
  GetNumberLocationTest();
  HiCarUtilTest();
  CalendarUtilTest();
  StringFormatUtilTest();
  ArrayUtilTest();
  ContactsGlobalThisHelperTest();
  ObjectUtilTest();
  StringUtilTest();
  UserPhotoTest();
  CallLogRepositoryTest();
  CallLogSettingTest();
  AimTest();
  BirthdayTest();
  EmailTest();
  EventTest();
  HouseTest();
  ImTest();
  PhoneTest();
  RelationTest();
  StructuredPostalTest();
  ContactTest();
  ContactBuilderTest();
  VoicemailManagerTest();
  LimitRefreshDataUtilTest();
  AlphabetIndexerPresenterTest();
  FavoriteListPresenterTest();
  SelectMemberSendMessagePresenterTest();
  AIMBeanTest();
  AssociatedPersonBeanTest();
  BasicDataSourceTest();
  BatchSelectContactSourceTest();
  CallBeanTest();
  ContactInfoTest();
  BatchSelectRecentSourceTest();
  AccountVoTest();
  CallLogBeanTest();
  CallRecordListDataSourceTest();
  ContactBeanTest();
  ContactDetailDataSourceTest();
  ContactListDataSourceTest();
  MmsServiceTest();
  PhoneNumberTest();
  DataItemTest();
  PhoneDateItemTest();
  RelationDataItemTest();
  BatchDeletePresenterTest();
  DialerPresenterTest();
  CallRecordPresenterTest();
  DataWorkerTaskTest();
  GroupListDetailPresenterTest();
  BatchDeleteGroupPresenterTest();
  CallLogTest();
  CallLogBuilderTest();
  MissedCallNotifierTest();
  MissedCallServiceTest();
  RawContactTest();
  CallLogDeltaTest();
  SearchContactsSourceTest();
  CalllogModelTest();
  ContactParamsTest();
  SearchContactsBeanTest();
  RepeatDataSourceTest();
  RemDayBeanTest();
  PhoneNumBeanTest();
  HouseBeanTest();
  GroupMemberListBeanTest();
  GroupMemberDataSourceTest();
  GroupListDataSourceTest();
  GroupBeanTest();
  FavoriteDataSourceTest();
  FavoriteBeanTest();
  EventBeanTest();
  EmailBeanTest();
  DetailCallLogDataSourceTest();
  DeviceInfoBeanTest();
  ContactVoTest();
  WorkerTaskTest();
  WorkFactoryTest();
  WorkWrapperTest();
  GetNumberLocation();
  DetailPresenterTest();
  DialerButtonViewTest();
  MutiDialerButtonViewTest();
  AddFavoriteListPresenterTest();
  CallStateModelTest();
  AccountantsPresenterTest();
  DotUtilTest();
  ResourceUtilTest();
  SearchContactResultTest();
  AirplaneModelTest();
  EnvironmentPropTest();
  MissedCallManagerTest();
  SimCardStateTest();
  SimManagerTest();
  ErrorStringUtilTest();
  VoLteStateTest();
  SimOpNameTest();
  SimIccDiallingNumbersTest();
  GroupListPresenterTest();
  SettingsPresenterTest();
  VCardUtilTest();
  BatchSelectPresenterTest();
  MissedCallCardAbilityTest();
  ShortcutCardAbilityTest();
  SpeedDialCardAbilityTest();
  FormCardControllerTest();
  EntryFormAbilityTest();
  GetDpiZoomSizeTest();
  NameDisposalTest();
  MissedCallDataShareTest();
  SettingsDatashareCommonTest();
  ShortcutEditCommonTest();
  SpeedDialEditCommonTest();
  DialogEntryAbilityTest();
  PageManagerTest();
  SpeedDialAbilityTest();
  SpeedDialPresenterTest();
  EditFavoriteListPresenterTest();
  MeetimeCallsTest();
  CallRecordTimeFormatUtilsTest();
  NavPathCheckUtilTest();
  VibrationUtilsTest();
  NumberMatchTest();
  ContactNameNumberInfoTest();
  MeeTimeAbilityInfoModelTest();
  MeeTimeDeviceInfoModelTest();
  ContactDeltaTest();
  RawContactDeltaTest();
  ValuesDeltaTest();
  RemoveMemberPresenterTest();
  TaskUtilTest();
  DynamicLoaderTest();
  DeviceUtilsTest();
  CallDetailTest();
  PageManagerMainAbilityTest();
  LunarUtilsTest();
  ListenerManagerTest();
  CardDialogExtensionAbilityTest();
  BannerTest();
  MissedCallEditCommonTest();
  IdlServiceBannerProxyTest();
  OriginalDataHandleHelperTest();
  IdlMeetimeServiceProxyTest();
  MeeTimeServiceTest();
  RemoteContactInfoTest();
  NumberAddressUtilTest();
  CallServiceManagerTest();
  MainAbilityTest();
  WindowsManagerTest();
  ProfileUtilsTest();
  SharedPreferencesUtilsTest();
  PermissionManagerTest();
  ContactRepositoryTest();
  IdlContactsServiceProxyTest();
  IdlCallServiceProxyTest();
  CallLogServiceTest();
  ContactListPresenterTest();
  ArrangeContactsPresenterTest();
  ContactAbilityModelTest();
  BatchDeleteContactsPresenterTest();
  AccessibilityUtilTest();
  InterceptionCallsExtAbilityTest();
  TelNumberModelTest();
  ContactListBoModelTest();
  CantactColumnUtilsTest();
  CustomNavigationUtilTest();
  JsonUtilTest();
  HiCarContactListDataSource();
  RecentDeleteDataSourceTest();
  RoamingUtilsTest();
  RecentDeletePresenterTest();
  ContactUiExtentionAbilityTest();
  BatchSelectFavoriteSourceTest();
  BatchDeleteContactSource();
  SearchUtilTest();
  ContactWorkSchedulerUtilTest();
  MeetimeDeviceInfoDataSourceTest();
  CaretPositionUtilTest();
  StaticSubscriberTest();
  DisplaySplitUtilTest();
  ContactInfoUtilTest();
  LunarDateUtilTest();
  CallSharingModelTest();
  DeviceTypeUtilTest();
  HiCarCallRecordPresenterTest();
  fontScaleStateTest();
  ScreenFormUtilTest();
  InterceptionCallRecordListDataSourceTest();
  PreDefineContactUtilTest();
  BigPhotoCopyUtilTest();
  RoamingManagerTest();
  DateManagerTest();
  DateTest();
  DateUtilTest();
  ContactsPickerPresenterTest();
  RingtoneSelectionUtilTest();
  CountryIdUtilTest();
  TelecomServiceTest();
  SystemModeControllerTest();
  QrCodeManagerTest();
  VCardParseTest();
}