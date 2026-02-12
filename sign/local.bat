@rem Copyright (c) 2024 Huawei Device Co., Ltd.
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

@echo off

set SIGN_TOOL_PATH=.\hap-sign-tool.jar
set SIGN_PLUGIN_PATH=.\hapsign-online-plugin.jar
set CURRENT_PATH=%cd%

chcp 65001
if not exist %SIGN_TOOL_PATH% (
    echo "copy hap sign tool from local SDK..."
    cd %HM_SDK_HOME%\
    copy "hap-sign-tool.jar" "%CURRENT_PATH%"
) else (
    echo "hap sign tool is exist."
)