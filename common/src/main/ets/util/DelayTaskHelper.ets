/**
 * 延迟任务帮助，用于处理通知对应的刷新
 * 通知1到达，启动一个延迟1s的延迟任务；
 * 通知2到达，3到达，。。。，延迟任务已存在，记录通知标志位为true，延迟任务仍在初始创建时间的1s后执行
 * 1s后，延迟任务执行
 * 判断通知标志位还有通知没处理，继续创建延迟任务
 *
 */
export class DelayTaskHelper {
  public static DELAY_TASK_NAME_REFRESH_CONTACT_LIST_BY_NO_ID_MSG = 'refreshContactListByNoIdMsg';

  // {key：任务名称    value：任务处理期间，是否有新的通知到达，需要新触发标记}
  private static taskNewMsgFlagMap: Map<string, boolean> = new Map;
  // {key：任务名称    value：任务号码，如果已经存在延迟任务，有值，如果还没有对应延迟任务，没有值}
  private static taskIdMap: Map<string, number> = new Map;

  /**
   * 延迟1s执行；如果有新通知，本任务也会1s后执行；等待1s+任务执行期间，新的通知，会继续延迟1s执行
   * @param runnable 刷新的查询任务
   * @param name 任务名称
   * @param delayTime 延迟时间
   */
  public static async delayTask(runnable: () => Promise<void>, name: string, delayTime: number) {
    // 根据名称查询任务id
    let taskId = DelayTaskHelper.taskIdMap.get(name);

    if (taskId === undefined) {
      // 起动当前任务，消费当前的通知，消费后，是否有新通知标记设置为false
      DelayTaskHelper.taskNewMsgFlagMap.set(name, false);
      // 任务执行完后，将taskId置空，如果有新的通知，需要继续执行延迟任务
      let taskIdNew = setTimeout(async () => {
        // refresh
        await runnable();
        // 执行后，需要移除任务
        DelayTaskHelper.taskIdMap.delete(name);
        // 如果仍存在新通知（仍需要延迟消费这些）
        if (DelayTaskHelper.taskNewMsgFlagMap.get(name)) {
          DelayTaskHelper.delayTask(runnable, name, delayTime);
        }
      }, delayTime);
      DelayTaskHelper.taskIdMap.set(name, taskIdNew);
    } else {
      // 存在任务，任务期间有新通知，任务处理结束后，需要处理本任务等待和执行期间的通知
      DelayTaskHelper.taskNewMsgFlagMap.set(name, true);
    }
  }
}