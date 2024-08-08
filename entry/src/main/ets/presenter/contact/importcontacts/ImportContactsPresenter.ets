import fs, { Filter } from '@ohos.file.fs';
import { VCardParserImpl_V21, VCardEntry, VCardInterpreter, VCardProperty, contact } from '@ohos/vcard/';
import { BusinessError } from '@ohos.base';
import promptAction from '@ohos.promptAction';
import { ContactInfo } from '../../../model/bean/ContactInfo';
import { PhoneNumBean } from '../../../model/bean/PhoneNumBean';
import { EmailBean } from '../../../model/bean/EmailBean';
import { AIMBean } from '../../../model/bean/AIMBean';
import { HouseBean } from '../../../model/bean/HouseBean';
import { AssociatedPersonBean } from '../../../model/bean/AssociatedPersonBean';
import { EventBean } from '../../../model/bean/EventBean';
import common from '@ohos.app.ability.common';
import ohosContact from '@ohos.contact';
import { Aim, Birthday, Phone } from '../../../../../../../feature/contact';
import { HiLog } from '../../../../../../../common/src/main/ets/util/HiLog';

const DURATION_TIME = 2000;
const PROMPT_BOTTOM = 100;
const TAG = 'ImportContactsPresenter';

export default class ImportContactsPresenter {
  public uri: string = '';
  public contactInfoAfters: ContactInfo[] = [];
  public allContact: ohosContact.Contact[] = [];
  public filesDir = (getContext(this) as common.UIAbilityContext).filesDir;
  public srcPath: string = '';
  private static sInstance: ImportContactsPresenter;

  public dialogController: CustomDialogController | null;

  public static getInstance(): ImportContactsPresenter {
    if (ImportContactsPresenter.sInstance == null) {
      ImportContactsPresenter.sInstance = new ImportContactsPresenter();
    }
    return ImportContactsPresenter.sInstance;
  }

  aboutToAppear() {
    this.getUri();
  }

  getUri() {
    let filesDir = (getContext(this) as common.UIAbilityContext).filesDir;
    this.uri = filesDir + '/' + 'contactsCacheFile.vcf';
    HiLog.i(TAG, `importuri: ${this.uri}`);
  }

  importFile() {
    this.getLatestFile()
  }

  handleContact() {
    ohosContact.queryContacts(globalThis.context, {
      attributes: [ohosContact.Attribute.ATTR_NAME, ohosContact.Attribute.ATTR_PHONE]
    }, (err: BusinessError, allContact) => {
      if (err) {
        HiLog.e(TAG, `queryContacts callback: err-> ${JSON.stringify(err)}`);
        return;
      }
      let filterContactInfoAfters = this.filterContactInfoAfters(this.contactInfoAfters);
      let contactInfoMatched = this.filterContacts(filterContactInfoAfters, allContact);
      if (contactInfoMatched != null && contactInfoMatched.length > 0) {
        contactInfoMatched.forEach((contactInfoAfter) => {
          this.addContact(contactInfoAfter);
        })
      } else {
        setTimeout(() => {
          promptAction.showToast({
            message: '已导入',
            duration: DURATION_TIME,
            bottom: PROMPT_BOTTOM
          });
        }, 1500);
      }
      this.contactInfoAfters = [];
    });
  }

  addContact(contactInfoAfter: ContactInfo) {
    globalThis.DataWorker.sendRequest('addContact',
      {
        context: globalThis.context,
        contactInfoAfter: JSON.stringify(contactInfoAfter)
      }
      , (arg) => {
        HiLog.i(TAG, `addContact arg: ${JSON.stringify(arg)}`);
      })
  }

  filterContacts(contactInfoAfters: ContactInfo[], allContact: ohosContact.Contact[]): ContactInfo[] {
    if (allContact != null && allContact.length > 0) {
      let filteredArr = contactInfoAfters.filter((itemA) => {
        let isExisted = false;
        for (let i = 0; i < allContact.length; i++) {
          if (allContact[i]?.name?.fullName === itemA?.display_name) {
            isExisted = true;
            break;
          }
        }
        return !isExisted;
      });
      HiLog.i(TAG, `filteredArr: ${JSON.stringify(filteredArr)}`);
      return filteredArr;
    } else {
      return contactInfoAfters;
    }
  }

  filterContactInfoAfters(contactInfoAfters: ContactInfo[]): ContactInfo[] {
    let seenNames: { [key: string]: boolean } = {};
    let contactInfofilter  = contactInfoAfters.filter(item => {
      if (seenNames[item?.display_name]) {
        return false;
      } else {
        seenNames[item?.display_name] = true;
        return true;
      }
    });
    HiLog.i(TAG, `contactInfofilter: ${JSON.stringify(contactInfofilter)}`);
    return contactInfofilter
  }

  getLatestFile() {
    class ListFileOption {
      public recursion: boolean = false;
      public listNum: number = 0;
      public filter: Filter = {};
    }
    let option = new ListFileOption();
    option.filter.suffix = ['.vcf'];
    fs.listFile(this.filesDir, option).then((filenames: Array<string>) => {
      console.info('listFile succeed');
      console.info(`srcPathgetfilenames: ${JSON.stringify(filenames)}`);
      let timeList = new Map()
      let maxKey = 0
      let maxValue = 0;
      function findMaxIndex(timeList: Map<number, number>) {
        for (let [key, value] of timeList) {
          if (value > maxValue) {
            maxValue = value;
            maxKey = key;
          }
        }
      }
      filenames.forEach((item,index) => {
        if (item !== 'contactsCacheFile.vcf') {
          let srcPath = this.filesDir + '/' + item;
          console.info('timeListsrcPath: ', srcPath);
          fs.stat(srcPath).then((stat: fs.Stat) => {
            HiLog.i(TAG, `srcPathget file info succeed, the ctime of file is: ${JSON.stringify(stat.ctime)}`);
            timeList.set(index,stat.ctime)
            if (index === filenames.length-1) {
              findMaxIndex(timeList);
              this.srcPath = this.filesDir + '/' + filenames[maxKey];
              this.parseFile();
            }
          }).catch((err: BusinessError) => {
            HiLog.e(TAG, `srcPathget file info failed with error message: ${JSON.stringify(err)}`);
          });
        }
        if (filenames.length === 1 && item === 'contactsCacheFile.vcf') {
          this.dialogController.open()
        }
      })
    }).catch((err: BusinessError) => {
      console.error('list file failed with error message: ' + err.message + ', error code: ' + err.code);
    });
  }

  parseFile() {
    promptAction.showToast({
      message: '系统将在稍后导入该文件，请勿重复点击',
      duration: 1500,
      bottom: PROMPT_BOTTOM
    });
    class MyVCardInterpreter implements VCardInterpreter {
      public vCardEntries: VCardEntry[] = [];
      public vCardEntry: VCardEntry = new VCardEntry();

      onVCardStarted(): void {
      }

      onVCardEnded(): void {
      }

      onEntryStarted(): void {
        this.vCardEntry = new VCardEntry();
      }

      onEntryEnded(): void {
        this.vCardEntries.push(this.vCardEntry);
      }

      onPropertyCreated(property: VCardProperty): void {
        this.vCardEntry.addProperty(property);
      }
    }

    let myParser = new VCardParserImpl_V21();
    let myInterpreter = new MyVCardInterpreter();
    myParser.addInterpreter(myInterpreter);

    let dstPath = this.filesDir + '/' + 'contactsCacheFile.vcf';
    fs.copyFile(this.srcPath, dstPath, 0).then(() => {

      fs.open(this.uri, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE , (err: BusinessError, file: fs.File) => {
        if (err) {
          promptAction.showToast({
            message: '未读取到.vcf文件',
            duration: DURATION_TIME,
            bottom: PROMPT_BOTTOM
          });
          HiLog.e(TAG, `open failed with error message: ${JSON.stringify(err)}`);
        } else {
          myParser.parse(file.fd);
          myInterpreter.vCardEntries.forEach((vCardEntry: VCardEntry, index: number) => {
            let contactInfoAfter: ContactInfo = new ContactInfo('', '', '', [], [], '', '', '', [], [], [], [], [], [], 0);

            HiLog.i(TAG, `getPhoneList: ${JSON.stringify(vCardEntry.getPhoneList())}`);
            if (vCardEntry.getPhoneList() != null && vCardEntry.getPhoneList().length > 0) {
              vCardEntry.getPhoneList().forEach((item: contact.PhoneNumber) => {
                let newItem = new PhoneNumBean('', '', '', '', '')
                newItem.num = item.phoneNumber
                newItem.numType = this.getPhoneNumberType(item.labelId).toString();
                contactInfoAfter.phones.push(newItem)
              });
            } else {
              return
            }

            let displayName = vCardEntry.getDisplayName();
            HiLog.i(TAG, `getDisplayName: ${JSON.stringify(displayName)}`);
            if (displayName != null) {
              if (displayName == '') {
                contactInfoAfter.display_name = vCardEntry.getPhoneList()[0].phoneNumber
              } else {
                contactInfoAfter.display_name = displayName;
              }
            }

            let organizationList = vCardEntry.getOrganizationList();
            HiLog.i(TAG, `organizationList: ${JSON.stringify(vCardEntry.getOrganizationList())}`);
            if (organizationList != null && organizationList.length > 0) {
              const newObj = organizationList.reduce(
                (prev, cur) => ({
                  name: cur.name ? cur.name : prev.name,
                  title: cur.title ? cur.title : prev.title,
                }),
                {
                  name: '', title: ''
                },
              );
              HiLog.i(TAG, `newObj: ${JSON.stringify(newObj)}`);
              contactInfoAfter.company = newObj.name;
              contactInfoAfter.position = newObj.title;
            }

            HiLog.i(TAG, `getEmailList: ${JSON.stringify(vCardEntry.getEmailList())}`);
            if (vCardEntry.getEmailList() != null && vCardEntry.getEmailList().length > 0) {
              vCardEntry.getEmailList().forEach((item: contact.Email) => {
                let newItem = new EmailBean('', '', '');
                newItem.address = item.email;
                newItem.emailType = item.labelId.toString();
                contactInfoAfter.emails.push(newItem);
              });
            }

            let notes = vCardEntry.getNotes();
            if (notes != null && notes.length > 0) {
              contactInfoAfter.remarks = notes[0].noteContent;
            }

            if (vCardEntry.getImList() != null && vCardEntry.getImList().length > 0) {
              vCardEntry.getImList().forEach((item: contact.ImAddress) => {
                let newItem = new AIMBean('', '', '', '');
                newItem.aimName = item.imAddress;
                newItem.aimType = this.getAIMType(item.labelId).toString();
                contactInfoAfter.aims.push(newItem);
              });
            }

            if (vCardEntry.getPostalList() != null && vCardEntry.getPostalList().length > 0) {
              HiLog.i(TAG, `getPostalList: ${JSON.stringify(vCardEntry.getPostalList())}`);
              vCardEntry.getPostalList().forEach((item: contact.PostalAddress) => {
                let newItem = new HouseBean('', '', '', '');
                if (item.city == null) {
                  item.city = '';
                }
                newItem.houseName = item.country + item.city + item.region +
                item.neighborhood + item.street + item.postalAddress + item.pobox;
                newItem.houseType = item.labelId.toString();
                contactInfoAfter.houses.push(newItem);
              })
            }

            if (vCardEntry.getNickNameList() != null && vCardEntry.getNickNameList().length > 0) {
              HiLog.i(TAG, `nickNameList: ${JSON.stringify(vCardEntry.getNickNameList())}`);
              contactInfoAfter.nickname = vCardEntry.getNickNameList()[0].nickName;
            }

            if (vCardEntry.getWebsiteList() != null && vCardEntry.getWebsiteList().length > 0) {
              HiLog.i(TAG, `getWebsiteList: ${JSON.stringify(vCardEntry.getWebsiteList())}`);
              contactInfoAfter.websites[0] = vCardEntry.getWebsiteList()[0].website;
            }

            HiLog.i(TAG, `getCustomData: ${JSON.stringify(vCardEntry.getCustomData())}`);
            if (vCardEntry.getCustomData() != null && vCardEntry.getCustomData().length > 0) {
              vCardEntry.getCustomData().forEach((item: contact.Relation) => {
                let newItem = new AssociatedPersonBean('', '', '', '');
                newItem.name = item.relationName;
                newItem.associatedType = item.labelId.toString();
                contactInfoAfter.relationships.push(newItem);
              })
            }

            let bday = vCardEntry.getBirthday();
            HiLog.i(TAG, `bday: ${JSON.stringify(bday)}`);
            if (bday != null) {
              let newItem = new EventBean('', '', '', '');
              newItem.data = bday;
              newItem.eventType = this.getEventType(contact.Event.EVENT_BIRTHDAY).toString();
              contactInfoAfter.events.push(newItem);
            }

            let anniversaryList = vCardEntry.getAnniversaryList();
            HiLog.i(TAG, `anniversaryList: ${JSON.stringify(anniversaryList)}`);
            if (anniversaryList != null && anniversaryList.length > 0) {
              anniversaryList.forEach((item: contact.Event) => {
                let newItem = new EventBean('', '', '', '');
                newItem.data = item.eventDate;
                newItem.eventType = this.getEventType(item.labelId).toString();
                contactInfoAfter.events.push(newItem);
              })
            }
            this.contactInfoAfters.push(contactInfoAfter);
          })
          this.handleContact();
          fs.closeSync(file);
        }
      });
      fs.unlink(this.srcPath).then(() => {
        console.info('remove file succeed');
      }).catch((err: BusinessError) => {
        console.error('remove file failed with error message: ' + err.message + ', error code: ' + err.code);
      });
      console.info('copy file succeed');
    }).catch((err: BusinessError) => {
      console.error('copy file failed with error message: ' + err.message + ', error code: ' + err.code);
    });
  }

  getPhoneNumberType(type: number): number {
    switch (type) {
      case contact.PhoneNumber.CUSTOM_LABEL:
        return Phone.TYPE_CUSTOM;
      case contact.PhoneNumber.NUM_HOME:
        return Phone.TYPE_HOME;
      case contact.PhoneNumber.NUM_MOBILE:
        return Phone.TYPE_MOBILE;
      case contact.PhoneNumber.NUM_WORK:
        return Phone.TYPE_WORK;
      case contact.PhoneNumber.NUM_FAX_WORK:
        return Phone.TYPE_FAX_WORK;
      case contact.PhoneNumber.NUM_FAX_HOME:
        return Phone.TYPE_FAX_HOME;
      case contact.PhoneNumber.NUM_PAGER:
        return Phone.TYPE_PAGER;
      case contact.PhoneNumber.NUM_OTHER:
        return Phone.TYPE_OTHER;
      case contact.PhoneNumber.NUM_MAIN:
        return Phone.TYPE_MAIN;
      default:
        return Phone.TYPE_CUSTOM;
    }
  }

  getAIMType(type: number): number {
    switch (type) {
      case contact.ImAddress.IM_AIM:
        return Aim.TYPE_AIM;
      case contact.ImAddress.IM_MSN:
        return Aim.TYPE_WINDOWSLIVE;
      case contact.ImAddress.IM_YAHOO:
        return Aim.TYPE_YAHOO;
      case contact.ImAddress.IM_SKYPE:
        return Aim.TYPE_SKYPE;
      case contact.ImAddress.IM_QQ:
        return Aim.TYPE_QQ;
      case contact.ImAddress.IM_ICQ:
        return Aim.TYPE_ICQ;
      case contact.ImAddress.IM_JABBER:
        return Aim.TYPE_JABBER;
      case contact.ImAddress.CUSTOM_LABEL:
        return Aim.TYPE_CUSTOM;
      default:
        return Aim.TYPE_CUSTOM;
    }
  }

  getEventType(type: number): number {
    switch (type) {
      case contact.Event.EVENT_ANNIVERSARY:
        return Birthday.TYPE_ANNIVERSARIES;
      case contact.Event.EVENT_OTHER:
        return Birthday.TYPE_OTHER;
      case contact.Event.EVENT_BIRTHDAY:
        return Birthday.TYPE_GREBIRTHDAY;
      case contact.Event.CUSTOM_LABEL:
        return Birthday.TYPE_OTHER;
      default:
        return Birthday.TYPE_OTHER;
    }
  }
}