@rem
@rem Copyright (c) 2022-2023 Huawei Device Co., Ltd.
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem     http://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

 TODO: 合入主干前需删除
set HOME=%~dp0
hdc shell mount -o remount,rw /

hdc shell rm system/app/com.ohos.contacts/Contacts.hap
hdc file send  %HOME%entry\build\default\outputs\default\entry-default-signed.hap system/app/com.ohos.contacts/Contacts.hap
hdc shell rm -rf /data/*
hdc shell chown root:root system/app/com.ohos.contacts/Contacts.hap
hdc shell setenforce 0
hdc shell sync
hdc shell sync /system/bin/udevadm trigger
hdc shell reboot
