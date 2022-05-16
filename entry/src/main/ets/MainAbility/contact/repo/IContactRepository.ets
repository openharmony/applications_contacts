/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import Contact from '../entity/Contact';
import ContactList from './ContactList';
import ContactDelta from './ContactDelta';
import ContactListItem from './ContactListItem';

/**
 * Contact storage management, shielding dependency on the CP layer
 * Contacts Only
 */
export default interface IContactRepository {
  save: (contact: ContactDelta) => Promise<Array<any>>;
  findById: (id: number) => Promise<Contact>;
  findByQuickSearchKey: (searchKey: string) => Promise<Contact>;
  findAll: () => Promise<ContactListItem[]>;
  findAllWithBookIndex: () => ContactList;
  search: (queryStr: string) => ContactList;
  findByPhoneIsNotNull: () => Promise<ContactListItem[]>;
  findByMailIsNotNull: () => ContactList;
  deleteByIdIn: (ids: number[]) => boolean;
  deleteById: (id: number) => Promise<number>;
  notifyChange: () => void;
  registerDataChangeObserver: (callback) => void;
  unRegisterDataChangeObserver: (callback) => void;
}