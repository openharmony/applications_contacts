import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import AbilityStage from "@oho.app.ability.AbilityStage"
import notification from '@ohos.notificationManager';

const TAG = 'ContactListItemView ';

export default class MyAbilityStage extends AbilityStage {
    onCreate() {
        HiLog.i(TAG, 'AbilityStage onCreate');
        notification.setNotificationEnable({
            bundle: "com.ohos.contacts"
        }, true, (err, data) => {
            if (err) {
                HiLog.e(TAG, "enableNotification err: " + JSON.stringify(err));
            }
        })
        notification.addSlot({
            type: notification.SlotType.SOCIAL_COMMUNICATION,
            level: notification.SlotLevel.LEVEL_HIGH,
            desc: "missedCall",
            lockscreenVisibility: 2
        })
    }
}