/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http:// www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
export default {
    uri: {
        CONTACT_DB_URI: 'dataability:///com.ohos.contactsdataability', // Uri for connecting to the contact database to obtain the contact database DAHelper
        VOICEMAIL_DB_URI: 'dataability:///com.ohos.voicemailability', // Uri for connecting to the voice mailbox database to obtain the voice mailbox database DAHelper
        CALLLOG_DB_URI: 'dataability:///com.ohos.calllogability', // Call record database URI, used to obtain the call record database DAHelper
        CONTACTS_URI_PREFIX: 'dataability:///com.ohos.contactsdataability/contacts/', // Query the various table URI prefixes in the Contacts library
        CALLS_URI_PREFIX: 'dataability:///com.ohos.calllogability/calls/', // SQL > alter TABLE URI prefixes
        VOICEMAIL_URI_PREFIX: 'dataability:///com.ohos.voicemailability/calls/', // Example Query the URI prefixes of various tables in the Voicemail library
        SEARCH_CONTACT_URI: 'dataability:///com.ohos.contactsdataability/contacts/search_contact',
        ROW_CONTACTS_URI: 'dataability:///com.ohos.contactsdataability/contacts/raw_contact', // // Uri of the operation on the row_contacts table
        CONTACT_DATA_URI: 'dataability:///com.ohos.contactsdataability/contacts/contact_data', // Uri of operation on contact_data table
        CONTACT_URI: 'dataability:///com.ohos.contactsdataability/contacts/contact',
        CONTACT_TYPE_URI: 'dataability:///com.ohos.contactsdataability/contacts/contact_type',
        GROUPS_URI: 'dataability:///com.ohos.contactsdataability/contacts/groups',
        CALL_LOG_URI: 'dataability:///com.ohos.calllogability/calls/calllog', // Uri of call record table operation
        PROFILE_ROW_CONTACTS_URI: 'dataability:///com.ohos.contactsdataability/profile/raw_contact', // My business card raw_contact table operation URI
        PROFILE_CONTACT_DATA_URI: 'dataability:///com.ohos.contactsdataability/profile/contact_data', // The URI of the contact_data table operation on my business card
        VOICEMAIL_URI: 'dataability:///com.ohos.voicemailability/calls/voicemail'
    },
    int: {
        Success: 0,
        Two: 2,
    }
};