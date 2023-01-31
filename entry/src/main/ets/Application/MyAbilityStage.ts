import { HiLog } from '../../../../../common/src/main/ets/util/HiLog';
import AbilityStage from "@ohos.app.ability.AbilityStage"

const TAG = 'ContactListItemView ';

export default class MyAbilityStage extends AbilityStage {
    onCreate() {
        HiLog.i(TAG, 'AbilityStage onCreate');
    }
}