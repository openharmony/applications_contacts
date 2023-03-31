import Ability from '@ohos.app.ability.UIAbility'
import Window from '@ohos.window'
import WorkFactory, { WorkerType } from "../workers/WorkFactory";
import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import Want from '@ohos.app.ability.Want';
import SimManager from '../feature/sim/SimManager';
import { missedCallManager } from '../feature/missedCall/MissedCallManager';
import CallsService from "../service/CallsService";
import ContactsService from "../service/ContactsService";

const TAG = 'MainAbility ';

export default class MainAbility extends Ability {
    storage: LocalStorage;
    simManager: SimManager;
    mDataWorker = WorkFactory.getWorker(WorkerType.DataWorker);
    mCallsService: CallsService;
    mContactsService: ContactsService;

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
        if (!want || !want.parameters) {
            return;
        }
        const data: any = want.parameters["missedCallData"];
        const action = want.parameters["action"];
        HiLog.i(TAG, `onRequest action: ${action}`);
        if (action != undefined && data != undefined) {
            missedCallManager.requestMissedCallAction(action, data);
        }
    }

    onCreate(want, launchParam) {
        HiLog.i(TAG, 'Application onCreate start');
        globalThis.isFromOnCreate = true;
        globalThis.context = this.context;
        globalThis.abilityWant = want;
        this.storage = new LocalStorage()
        this.onRequest(want, true);
        this.simManager = new SimManager();
        globalThis.DataWorker = this.mDataWorker;
        this.mCallsService = new CallsService(this.context, this.mDataWorker);
        this.mContactsService = new ContactsService(this.context, this.mDataWorker);
    }

    onNewWant(want, launchParam) {
        HiLog.i(TAG, 'Application onNewWant');
        globalThis.isFromOnCreate = false;
        globalThis.abilityWant = want;
        this.onRequest(want, false);
    }

    onDestroy() {
        HiLog.i(TAG, 'Ability onDestroy');
        this.mDataWorker.close();
        this.mCallsService.onDestroy();
        this.mContactsService.onDestroy();
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