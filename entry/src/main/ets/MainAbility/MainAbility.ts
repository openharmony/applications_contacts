import Ability from '@ohos.app.ability.UIAbility'
import Window from '@ohos.window'
import { CallLogService } from '../../../../../feature/call/src/main/ets/CallLogService';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';

const TAG = 'MainAbility ';

export default class MainAbility extends UIAbility {
    storage: LocalStorage;

    updateBreakpoint(windowWidth: number) {
        let windowWidthVp: number = px2vp(windowWidth);
        let breakpoint: string;
        if (windowWidthVp < 520) {
            breakpoint = 'sm';
        } else if (windowWidthVp < 840) {
            breakpoint = 'md';
        } else {
            breakpoint = 'lg';
        }
        this.storage.setOrCreate('breakpoint', breakpoint);
    }

    onCreate(want, launchParam) {
        HiLog.i(TAG, 'Application onCreate version : OH-2022-12-19_changed');
        CallLogService.getInstance().init();
        globalThis.isFromOnCreate = true;
        globalThis.context = this.context;
        globalThis.abilityWant = want;
        this.storage = new LocalStorage()
    }

    onNewWant(want, launchParam) {
        HiLog.i(TAG, 'Application onNewWant');
        globalThis.isFromOnCreate = false;
        globalThis.abilityWant = want;
    }

    onDestroy() {
        HiLog.i(TAG, 'Ability onDestroy');
    }

    onWindowStageCreate(windowStage: Window.WindowStage) {
        // Main window is created, set main page for this ability
        HiLog.i(TAG, 'Ability onWindowStageCreate');

        Window.getTopWindow(this.context).then((windowObj) => {
            windowObj.getProperties().then((windowProperties) => {
                this.updateBreakpoint(windowProperties.windowRect.width);
            })
            windowObj.on('windowSizeChange', (data) => {
                this.updateBreakpoint(data.width);
            });
        })

        windowStage.loadContent('pages/index', this.storage, (err, data) => {
            if (err.code) {
                HiLog.e(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err) ?? '');
                return;
            }
            HiLog.i(TAG, 'Succeeded in loading the content. Data: ' + JSON.stringify(data) ?? '');
        });
    }

    onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        HiLog.i(TAG, 'Ability onWindowStageDestroy');
    }

    onForeground() {
        // Ability has brought to foreground
        HiLog.i(TAG, 'Ability onForeground');
    }

    onBackground() {
        // Ability has back to background
        HiLog.i(TAG, 'Ability onBackground');
    }
}