import Ability from '@ohos.app.ability.UIAbility'
import Window from '@ohos.window'
import WorkFactory, { WorkerType } from "../workers/WorkFactory";
import { MissedCallService } from '../../../../../feature/call';
import { PhoneNumber } from '../../../../../feature/phonenumber';
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import Constants from '../../../../../common/src/main/ets/Constants';
import Want from '@ohos.application.Want';
import SimManager from '../feature/sim/SimManager';

const TAG = 'MainAbility ';

export default class MainAbility extends Ability {
    storage: LocalStorage;
    simManager: SimManager;

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

    onRequest(want: Want, isOnCreate: boolean) {
        HiLog.i(TAG, "onRequest Contact notification");
        if (!want || !want.parameters) {
            return;
        }
        const data = want.parameters["missedCallData"];
        const action = want.parameters["action"];
        HiLog.i(TAG, `onRequest action: ${action}`);
        MissedCallService.getInstance().init(this.context);
        switch (action) {
            case 'notification.event.click':
            case 'notification.event.dial_back':
                HiLog.i(TAG, "action to dialBack.");
                if (data) {
                    MissedCallService.getInstance().cancelMissedNotificationAction(data);
                }
                break;
            case 'notification.event.message':
                if (data && data.phoneNumber) {
                    PhoneNumber.fromString(data.phoneNumber).sendMessage()
                    MissedCallService.getInstance().cancelMissedNotificationAction(data);
                }
                break;
            default:
                HiLog.i(TAG, "onRequest, no action!")
                break;
        }
    }

    onCreate(want, launchParam) {
        HiLog.i(TAG, 'Application onCreate start');
        globalThis.DataWorker = WorkFactory.getWorker(WorkerType.DataWorker);
        globalThis.isFromOnCreate = true;
        globalThis.context = this.context;
        globalThis.abilityWant = want;
        this.storage = new LocalStorage()
        this.onRequest(want, true);
        this.simManager = new SimManager();
    }

    onNewWant(want, launchParam) {
        HiLog.i(TAG, 'Application onNewWant');
        globalThis.isFromOnCreate = false;
        globalThis.abilityWant = want;
        this.onRequest(want, false);
    }

    onDestroy() {
        HiLog.i(TAG, 'Ability onDestroy');
        globalThis.DataWorker?.close()
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
        this.simManager.init();
    }

    onBackground() {
        // Ability has back to background
        HiLog.i(TAG, 'Ability onBackground');
        this.simManager.recycle();
    }
}