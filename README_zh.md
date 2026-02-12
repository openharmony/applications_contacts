# 联系人应用

## 简介

### 内容介绍

Contacts应用是OpenHarmony中预置的系统应用，主要的功能包含包括拨号盘、通话记录、联系人列表、联系人详情、联系人设置、联系人搜索、联系人群组、联系人收藏、联系人管理、联系人Picker。

### 架构图

![image-20220222110725915](./figures/contacts.png)

该应用架构主要结合MVP+领域驱动设计思路。

## 目录

~~~
/Contacts/
├── common                                 # 通用工具
├── feature                                # 业务模块
│   ├── account                            # 联系人账号
│   ├── call                               # 通话记录
│   ├── contact                            # 联系人
│   ├── dialpad                            # 拨号盘
│   ├── phonenumber                        # 手机号码
├── entry                 
│   └── src
│       └── main
│           └── ets                        
│               ├── Application            # 应用生命周期/公共方法存放
│               ├── backup                 # 备份
│               ├── card                   # 服务卡片
│               ├── component              # 组件
│               ├── data                   # 常量
│               ├── dialogentryability     # 弹框Ability
│               ├── entryformability       # 卡片Ability
│               ├── feature                # 未接来电、SIM卡等
│               ├── interception           # 拦截通话记录
│               ├── listeners              # 监听器管理
│               ├── MainAbility            # 主Ability
│               ├── model                  # 业务数据
│               ├── pages                  # 业务页面
│               ├── presenter              # 业务逻辑
│               ├── privacyAbility         # 隐私界面
│               ├── speeddialability       # 快捷拨号
│               ├── StaticSubscriber       # 公共事件订阅
│               ├── task                   # 异步任务
│               ├── uiExtentionAbility     # 联系人ExtentionAbility
│               ├── util                   # 工具类
│               ├── workers                # worker线程
│               ├── workSchedulerExtensionAbility  # 延时任务
│           ├── resources                  # 资源配置文件存放目录
├── signature                              # 签名
└── LICENSE                                # 许可证
~~~

## 相关仓

[**applications_mms**](https://gitcode.com/openharmony/applications_mms)

[**applications_contactsdata**](https://gitcode.com/openharmony/applications_contactsdata)

[**applications_call**](https://gitcode.com/openharmony/applications_call)





