# Contacts

## Introduction

The Contacts application is a preset system application in OpenHarmony. The main functions include dial pad, call logs, contact list, contact details, contact settings, contact search, contact groups, contact favorites, contact management, and contact picker.

**Core Features:**
1. **Dial Pad:** Provides dial pad display and interaction; supports number search within the dial pad; search results support viewing details, copying numbers, marking as, creating new contacts, and saving to existing contacts; supports dialing with input numbers and keypad tones; supports secret code capability and IMEI barcode display.
2. **Call Log List:** Displays all call records; shows missed call list; supports viewing call details; long-press enables multi-select for batch operations including deleting call logs, copying numbers, creating new contacts, saving to existing contacts, and marking.
3. **Contact Card:** Provides contact shortcuts; supports quick dial entry and missed call display; supports adding and removing contacts from the card.
4. **Contact List:** Supports contact search by number or name; supports smart groups (company, city, recent contacts) and phone groups; phone groups support creating new groups, deleting groups, adding members, sending messages, removing members, and renaming groups; provides contact list indexing; supports managing contact fields including avatar, name, company, job title, phone numbers, email, notes, instant messaging, ringtone, address, website, birthday, and related contacts (assistant).
5. **Contact Details:** Long-press on call logs in details page supports deletion; long-press on phone numbers supports copying to clipboard and setting as default; supports tapping numbers to dial; provides SMS entry point; supports contact editing; allows setting local music ringtones, video ringtones, or no ringtone for contacts.
6. **Contact Picker:** Provides contact picker selection capability.
7. **Contact Favorites:** Displays favorite contacts list; supports adding to and removing from favorites; supports sorting; supports select all and deselect all.
8. **Contact Settings:** Supports organizing contacts (automatically merging duplicate contacts, manually merging duplicates, batch deletion); supports importing contacts from storage devices and SIM cards; supports exporting contacts to storage devices; supports recently deleted recovery.
9. **Enhanced Contact Features:** Supports identification of three major carriers.

### Architecture diagram

![image-20220222110725915](./figures/contacts_en.png)

The application architecture mainly combines MVP and domain-driven design ideas.

## File Tree

~~~
/Contacts/
├── common
├── feature
│   ├── account
│   ├── call
│   ├── contact
│   ├── dialpad
│   ├── phonenumber
├── entry                 
│   └── src
│       └── main
│           └── ets                        
│               ├── Application
│               ├── backup
│               ├── card
│               ├── component
│               ├── data
│               ├── dialogentryability
│               ├── entryformability
│               ├── feature
│               ├── interception
│               ├── listeners
│               ├── MainAbility
│               ├── model
│               ├── pages
│               ├── presenter
│               ├── privacyAbility
│               ├── speeddialability
│               ├── StaticSubscriber
│               ├── task
│               ├── uiExtentionAbility
│               ├── util
│               ├── workers
│               ├── workSchedulerExtensionAbility 
│           ├── resources 
├── signature
└── LICENSE
~~~

## Related Repos

[**applications_mms**](https://gitcode.com/openharmony/applications_mms)

[**applications_contactsdata**](https://gitcode.com/openharmony/applications_contactsdata)

[**applications_call**](https://gitcode.com/openharmony/applications_call)
