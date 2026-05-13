/**
 * 自定义任务存储管理
 * 使用 Preferences 存储用户创建的自定义健康任务定义
 * 自定义任务 taskID 从 8 开始（最多 5 个）
 */

import { preferences } from '@kit.ArkData';
import { GlobalContext } from '../common/utils/GlobalContext';
import Logger from '../common/utils/Logger';

/** 自定义任务定义 */
export interface CustomTaskDef {
  taskID: number;        // 8-12
  taskName: string;      // 用户自定义名称
  unit: string;          // 单位（如"分钟""页""组"）
  targetValue: string;   // 默认目标值
  step: number;          // 每次打卡步进
  icon: string;          // 图标emoji
}

const PREF_NAME: string = 'custom_task_store';
// 内存缓存，避免异步查表
const customCache: Map<number, CustomTaskDef> = new Map();

/** 刷新内存缓存 */
async function refreshCache(): Promise<void> {
  const list: CustomTaskDef[] = await getCustomTasksRaw();
  customCache.clear();
  for (let i: number = 0; i < list.length; i++) {
    customCache.set(list[i].taskID, list[i]);
  }
}

/** 同步获取自定义任务定义（从缓存） */
export function getCustomTaskSync(taskID: number): CustomTaskDef | null {
  return customCache.get(taskID) || null;
}

/** 初始化缓存（应用启动时调用） */
export async function initCustomTaskCache(): Promise<void> {
  await refreshCache();
}
const KEY_CUSTOM_TASKS: string = 'custom_tasks_json';
const MAX_CUSTOM: number = 5;
const CUSTOM_ID_START: number = 8;

/** 获取所有自定义任务定义 */
export async function getCustomTasks(): Promise<CustomTaskDef[]> {
  return await getCustomTasksRaw();
}

/** 内部实现：从Preferences读取 */
async function getCustomTasksRaw(): Promise<CustomTaskDef[]> {
  try {
    const ctx = GlobalContext.getContext().getObject('context') as Context;
    const pref = await preferences.getPreferences(ctx, PREF_NAME);
    const json: string = pref.getSync(KEY_CUSTOM_TASKS, '[]') as string;
    return JSON.parse(json) as CustomTaskDef[];
  } catch (err) {
    Logger.error('CustomTaskStore', 'getCustomTasks failed');
    return [];
  }
}

/** 添加一个自定义任务 */
export async function addCustomTask(task: CustomTaskDef): Promise<boolean> {
  const list: CustomTaskDef[] = await getCustomTasks();
  if (list.length >= MAX_CUSTOM) {
    return false;
  }
  // 分配最小可用ID
  let nextId: number = CUSTOM_ID_START;
  const usedIds: number[] = [];
  for (let i: number = 0; i < list.length; i++) {
    usedIds.push(list[i].taskID);
  }
  while (usedIds.indexOf(nextId) >= 0) {
    nextId++;
  }
  task.taskID = nextId;
  list.push(task);
  return await saveTaskList(list);
}

/** 更新自定义任务 */
export async function updateCustomTask(task: CustomTaskDef): Promise<boolean> {
  const list: CustomTaskDef[] = await getCustomTasks();
  for (let i: number = 0; i < list.length; i++) {
    if (list[i].taskID === task.taskID) {
      list[i] = task;
      return await saveTaskList(list);
    }
  }
  return false;
}

/** 删除自定义任务 */
export async function deleteCustomTask(taskID: number): Promise<boolean> {
  const list: CustomTaskDef[] = await getCustomTasks();
  const newList: CustomTaskDef[] = [];
  for (let i: number = 0; i < list.length; i++) {
    if (list[i].taskID !== taskID) {
      newList.push(list[i]);
    }
  }
  return await saveTaskList(newList);
}

/** 获取自定义任务总数 */
export async function getCustomTaskCount(): Promise<number> {
  const list: CustomTaskDef[] = await getCustomTasks();
  return list.length;
}

/** 最大自定义任务数 */
export function getMaxCustomCount(): number {
  return MAX_CUSTOM;
}

/** 自定义任务ID起始 */
export function getCustomIdStart(): number {
  return CUSTOM_ID_START;
}

/** 根据taskID查找自定义任务定义 */
export async function getCustomTaskById(taskID: number): Promise<CustomTaskDef | null> {
  const list: CustomTaskDef[] = await getCustomTasks();
  for (let i: number = 0; i < list.length; i++) {
    if (list[i].taskID === taskID) {
      return list[i];
    }
  }
  return null;
}

/** 保存任务列表到Preferences */
async function saveTaskList(list: CustomTaskDef[]): Promise<boolean> {
  try {
    const ctx = GlobalContext.getContext().getObject('context') as Context;
    const pref = await preferences.getPreferences(ctx, PREF_NAME);
    await pref.put(KEY_CUSTOM_TASKS, JSON.stringify(list));
    await pref.flush();
    await refreshCache();
    return true;
  } catch (err) {
    Logger.error('CustomTaskStore', 'saveTaskList failed');
    return false;
  }
}
