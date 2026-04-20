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
import { describe, expect, it } from '@ohos/hypium';
import IdlMeetimeServiceProxy
  from '../../../../../../../../../feature/phonenumber/src/main/ets/idl/service/idl_meetime_service_proxy';
import { rpc } from '@kit.IPCKit';
import {
  GetActiveStatus,
  RegisterServiceCallback,
  InitClientCapabilityCallback,
  GetClientNameListCallback,
  OffLineClientCallback,
  DeregisterServiceCallback,
  pushToLoginCallback
} from '../../../../../../../../../feature/phonenumber/src/main/ets/idl/service/i_idl_meetime_service';

export default function IdlMeetimeServiceProxyTest() {
  describe('IdlMeetimeServiceProxyTest', () => {

    class Result {
      private errCode = 0;
      public reply: Reply = new Reply(1);

      constructor(errCode: number, reply: Reply) {
        this.errCode = errCode;
        this.reply = reply;
      }
    }

    class Reply {
      public flag?: number;

      constructor(flag?: number) {
        this.flag = flag;
      }

      public readInt() {
        if (this.flag === 0) {
          return 0;
        } else {
          return 1;
        }
      }

      public readBoolean() {
        return false;
      }

      public readString() {
        return 'string'
      }
    }

    class Proxy {
      public code: number;
      public flag?: number;

      constructor(code: number, flag?: number) {
        this.code = code;
        this.flag = flag;
      }

      public sendRequest(command: number, _data: rpc.MessageParcel, _reply: rpc.MessageParcel, _option: rpc.MessageOption): Promise<Result> {
        if (this.code === 0)
          return new Promise<Result>(resolve => resolve(new Result(0, new Reply(this.flag))));
        else
          return new Promise<Result>(resolve => resolve(new Result(1, new Reply(this.flag))));
      }
    }

    it('IdlMeetimeServiceProxyTest_getActiveStatus_if', 0, () => {
      let rpcCallback: rpc.IRemoteObject = {
        queryLocalInterface: (descriptor: string): rpc.IRemoteBroker => {
          throw new Error('Function not implemented.');
        },
        getLocalInterface: (descriptor: string): rpc.IRemoteBroker => {
          throw new Error('Function not implemented.');
        },
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          throw new Error('Function not implemented.');
        },
        addDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): boolean => {
          throw new Error('Function not implemented.');
        },
        registerDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): void => {
          throw new Error('Function not implemented.');
        },
        removeDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): boolean => {
          throw new Error('Function not implemented.');
        },
        unregisterDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): void => {
          throw new Error('Function not implemented.');
        },
        getInterfaceDescriptor: (): string => {
          throw new Error('Function not implemented.');
        },
        getDescriptor: (): string => {
          throw new Error('Function not implemented.');
        },
        isObjectDead: (): boolean => {
          throw new Error('Function not implemented.');
        }
      } as rpc.IRemoteObject;
      let callback: GetActiveStatus = (errCode: number, returnValue: boolean) => {
        expect(errCode).assertEqual(1);
        expect(returnValue).assertEqual(false);
      };
      let proxy: Proxy = new Proxy(0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.getActiveStatus(rpcCallback, callback);
    })

    it('IdlMeetimeServiceProxyTest_getActiveStatus_else', 0, () => {
      let rpcCallback: rpc.IRemoteObject = {
        queryLocalInterface: (descriptor: string): rpc.IRemoteBroker => {
          throw new Error('Function not implemented.');
        },
        getLocalInterface: (descriptor: string): rpc.IRemoteBroker => {
          throw new Error('Function not implemented.');
        },
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          throw new Error('Function not implemented.');
        },
        addDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): boolean => {
          throw new Error('Function not implemented.');
        },
        registerDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): void => {
          throw new Error('Function not implemented.');
        },
        removeDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): boolean => {
          throw new Error('Function not implemented.');
        },
        unregisterDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): void => {
          throw new Error('Function not implemented.');
        },
        getInterfaceDescriptor: (): string => {
          throw new Error('Function not implemented.');
        },
        getDescriptor: (): string => {
          throw new Error('Function not implemented.');
        },
        isObjectDead: (): boolean => {
          throw new Error('Function not implemented.');
        }
      } as rpc.IRemoteObject;
      let callback: GetActiveStatus = (errCode: number, returnValue: boolean) => {
      };
      let proxy: Proxy = new Proxy(1);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.getActiveStatus(rpcCallback, callback);

      expect(idlMeetimeServiceProxy.getStr()).assertEqual('');
    })

    it('IdlMeetimeServiceProxyTest_registerService_if', 0, () => {
      let rpcCallback: rpc.IRemoteObject = {
        queryLocalInterface: (descriptor: string): rpc.IRemoteBroker => {
          throw new Error('Function not implemented.');
        },
        getLocalInterface: (descriptor: string): rpc.IRemoteBroker => {
          throw new Error('Function not implemented.');
        },
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          throw new Error('Function not implemented.');
        },
        addDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): boolean => {
          throw new Error('Function not implemented.');
        },
        registerDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): void => {
          throw new Error('Function not implemented.');
        },
        removeDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): boolean => {
          throw new Error('Function not implemented.');
        },
        unregisterDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): void => {
          throw new Error('Function not implemented.');
        },
        getInterfaceDescriptor: (): string => {
          throw new Error('Function not implemented.');
        },
        getDescriptor: (): string => {
          throw new Error('Function not implemented.');
        },
        isObjectDead: (): boolean => {
          throw new Error('Function not implemented.');
        }
      } as rpc.IRemoteObject;
      let callback: RegisterServiceCallback = (errCode: number) => {
        expect(errCode).assertEqual(1);
      };
      let proxy: Proxy = new Proxy(0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.registerService(rpcCallback, callback);
    })

    it('IdlMeetimeServiceProxyTest_registerService_else', 0, () => {
      let rpcCallback: rpc.IRemoteObject = {
        queryLocalInterface: (descriptor: string): rpc.IRemoteBroker => {
          throw new Error('Function not implemented.');
        },
        getLocalInterface: (descriptor: string): rpc.IRemoteBroker => {
          throw new Error('Function not implemented.');
        },
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<rpc.RequestResult> => {
          throw new Error('Function not implemented.');
        },
        addDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): boolean => {
          throw new Error('Function not implemented.');
        },
        registerDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): void => {
          throw new Error('Function not implemented.');
        },
        removeDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): boolean => {
          throw new Error('Function not implemented.');
        },
        unregisterDeathRecipient: (recipient: rpc.DeathRecipient, flags: number): void => {
          throw new Error('Function not implemented.');
        },
        getInterfaceDescriptor: (): string => {
          throw new Error('Function not implemented.');
        },
        getDescriptor: (): string => {
          throw new Error('Function not implemented.');
        },
        isObjectDead: (): boolean => {
          throw new Error('Function not implemented.');
        }
      } as rpc.IRemoteObject;
      let callback: RegisterServiceCallback = (errCode: number) => {
      };
      let proxy: Proxy = new Proxy(1);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.registerService(rpcCallback, callback);

      expect(idlMeetimeServiceProxy.getBoolean()).assertFalse();
    })

    it('IdlMeetimeServiceProxyTest_initClientCapability_if', 0, () => {
      let callback: InitClientCapabilityCallback = (errCode: number) => {
        expect(errCode).assertEqual(1);
      };
      let proxy: Proxy = new Proxy(0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.initClientCapability('', '', 'com.ohos.contacts', 1, '', callback);
    })

    it('IdlMeetimeServiceProxyTest_initClientCapability_else', 0, () => {
      let callback: InitClientCapabilityCallback = (errCode: number) => {
      };
      let proxy: Proxy = new Proxy(1);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.initClientCapability('', '', 'com.ohos.contacts', 1, '', callback);

      expect(idlMeetimeServiceProxy.getStr()).assertEqual('');
    })

    it('IdlMeetimeServiceProxyTest_getClientNameList_if_if', 0, () => {
      let callback: GetClientNameListCallback = (errCode: number, returnValue: string) => {
        expect(errCode).assertEqual(1);
        expect(returnValue).assertUndefined();
      };
      let proxy: Proxy = new Proxy(0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.getClientNameList('', callback);
    })

    it('IdlMeetimeServiceProxyTest_getClientNameList_if_else', 0, () => {
      let callback: GetClientNameListCallback = (errCode: number, returnValue: string) => {
        expect(returnValue).assertEqual('string');
      };
      let proxy: Proxy = new Proxy(0, 0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.getClientNameList('', callback);
    })

    it('IdlMeetimeServiceProxyTest_getClientNameList_else', 0, () => {
      let callback: GetClientNameListCallback = (errCode: number, returnValue: string) => {
      };
      let proxy: Proxy = new Proxy(1);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.getClientNameList('', callback);

      expect(idlMeetimeServiceProxy.getStr()).assertEqual('');
    })

    it('IdlMeetimeServiceProxyTest_offLineClient_if', 0, () => {
      let callback: OffLineClientCallback = (errCode: number) => {
        expect(errCode).assertEqual(1);
      };
      let proxy: Proxy = new Proxy(0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.offLineClient('', '', callback);
    })

    it('IdlMeetimeServiceProxyTest_offLineClient_else', 0, () => {
      let callback: OffLineClientCallback = (errCode: number) => {
      };
      let proxy: Proxy = new Proxy(1);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.offLineClient('', '', callback);

      expect(idlMeetimeServiceProxy.getStr()).assertEqual('');
    })

    it('IdlMeetimeServiceProxyTest_deregisterService_if', 0, () => {
      let callback: DeregisterServiceCallback = (errCode: number) => {
        expect(errCode).assertEqual(1);
      };
      let proxy: Proxy = new Proxy(0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.deregisterService('', '', callback);
    })

    it('IdlMeetimeServiceProxyTest_deregisterService_else', 0, () => {
      let callback: DeregisterServiceCallback = (errCode: number) => {
      };
      let proxy: Proxy = new Proxy(1);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.deregisterService('', '', callback);

      expect(idlMeetimeServiceProxy.getBoolean()).assertFalse();
    })

    it('IdlMeetimeServiceProxyTest_pushToLogin_if_if', 0, () => {
      let callback: pushToLoginCallback = (errCode: number) => {
        expect(idlMeetimeServiceProxy.getBoolean()).assertEqual(false);
      };
      let proxy: Proxy = new Proxy(0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.pushToLogin(callback);
    })

    it('IdlMeetimeServiceProxyTest_pushToLogin_if_else', 0, () => {
      let callback: pushToLoginCallback = (errCode: number) => {
        expect(errCode).assertEqual(0);
      };
      let proxy: Proxy = new Proxy(0,0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.pushToLogin(callback);
    })

    it('IdlMeetimeServiceProxyTest_pushToLogin_else', 0, () => {
      let callback: pushToLoginCallback = (errCode: number) => {
      };
      let proxy: Proxy = new Proxy(0);
      let idlMeetimeServiceProxy: IdlMeetimeServiceProxy = new IdlMeetimeServiceProxy(proxy);

      idlMeetimeServiceProxy.pushToLogin(callback);
      expect(idlMeetimeServiceProxy.getBoolean()).assertFalse();
    })
  })
}