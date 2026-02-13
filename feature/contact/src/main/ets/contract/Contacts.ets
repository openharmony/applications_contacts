/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ContactsColumns from './ContactsColumns';

/**
 * rawContact data type
 */
export class Contacts extends ContactsColumns {
  public static readonly CONTENT_URI: string = 'datashare:///com.ohos.contactsdataability';
  public static readonly CONTACT_URI: string = Contacts.CONTENT_URI + '/contacts/contact';
  public static readonly CLOUD_SYNC_CONTACT_DELETE_NOTIFY_URI: string =
    Contacts.CONTENT_URI + '/contacts/cloud_sync_contact_delete';
  public static readonly CONTACT_LOCATION_URI: string = Contacts.CONTENT_URI + '/contacts/contact_location';
  // company uri
  public static readonly INTELLIGENCE_GROUP_COMPANY_CLASSIFY_URI: string = Contacts.CONTENT_URI + '/contacts/company_classify';
  public static readonly INTELLIGENCE_GROUP_NO_COMPANY_CLASSIFY_URI: string = Contacts.CONTENT_URI + '/contacts/query_count_without_company';
  // city uri
  public static readonly INTELLIGENCE_GROUP_CITY_CLASSIFY_URI: string = Contacts.CONTENT_URI + '/contacts/location_classify';
  public static readonly INTELLIGENCE_GROUP_NO_CITY_CLASSIFY_URI: string = Contacts.CONTENT_URI + '/contacts/query_count_without_location';
  // latest contact time uri
  public static readonly INTELLIGENCE_GROUP_LATEST_CONTACT_TIME_CLASSIFY_URI: string = Contacts.CONTENT_URI + '/contacts/frequent_classify';
  public static readonly ACCOUNT_URI: string = Contacts.CONTENT_URI + '/contacts/account';
  public static readonly CONTACT_SYNC_URI: string = Contacts.CONTENT_URI + '/contacts/sync_contact_data';
  public static readonly GROUP_SYNC_URI: string = Contacts.CONTENT_URI + '/contacts/groups';
  public static readonly CONTACT_SYNC_CALENDER_URI: string = Contacts.CONTENT_URI + '/contacts/sync_birthday_to_calendar';
  public static readonly CONTACT_RAW_URI: string = Contacts.CONTENT_URI + '/contacts/raw_contact';
  public static readonly BACKUP_RESTORE_URI: string = Contacts.CONTENT_URI + '/contacts/backup_restore';
  public static readonly BLOCK_LIST_URI: string = Contacts.CONTENT_URI + '/contacts/contact_blocklist';
  public static readonly DELETED_RAW_CONTACT_URI: string = Contacts.CONTENT_URI + '/contacts/deleted_raw_contact';
  public static readonly RECYCLE_RESTORE_URI: string = Contacts.CONTENT_URI + '/contacts/recycle_restore';
  public static readonly RESTORE_CONTACTS_URI: string = Contacts.CONTENT_URI + '/contacts/restore_contact_by_double_to_single_upgrade_data';
  public static readonly QUERY_CONTACT_COUNT_DOUBLE_DB_URI: string = Contacts.CONTENT_URI + '/contacts/query_contact_count_double_db';
  public static readonly CONTACTS_HARD_DELETE: string = Contacts.CONTENT_URI + '/contacts/contacts_hard_delete';
  public static readonly ADD_CONTACT_BATCH: string = Contacts.CONTENT_URI + '/contacts/add_contact_batch';

  constructor() {
    super();
  }
}