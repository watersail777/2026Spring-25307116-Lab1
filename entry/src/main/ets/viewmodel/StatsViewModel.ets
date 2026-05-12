/**
 * 统计视图模型
 * 从数据库读取打卡历史数据，计算图表展示所需信息
 */

import DayInfoApi from '../common/database/tables/DayInfoApi';
import GlobalInfoApi from '../common/database/tables/GlobalInfoApi';
import DayInfo from './DayInfo';
import GlobalInfo from './GlobalInfo';
import { dateToStr } from '../common/utils/Utils';
import Logger from '../common/utils/Logger';

/** 单日统计数据 */
export interface DayStats {
  date: string       // 日期字符串
  dayLabel: string   // 显示标签（周一/周二等）
  percent: number    // 完成率 0-100
  targetNum: number  // 目标任务数
  finishNum: number  // 完成数
  isToday: boolean   // 是否今天
}

/** 整体统计汇总 */
export interface StatsSummary {
  totalCheckInDays: number   // 累计打卡天数
  currentStreak: number      // 当前连续打卡天数
  bestStreak: number         // 历史最长连续天数
  achievedCount: number      // 已获得成就数
}

/** 统计页完整数据 */
export class StatsData {
  dayStatsList: DayStats[] = []
  summary: StatsSummary = { totalCheckInDays: 0, currentStreak: 0, bestStreak: 0, achievedCount: 0 }

  constructor(days: DayStats[], summary: StatsSummary) {
    this.dayStatsList = days
    this.summary = summary
  }
}

const WEEK_DAY_LABELS = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

/**
 * 查询近7天统计数据
 */
export async function queryWeekStats(): Promise<StatsData> {
  const today = new Date()
  const dateStrList: string[] = []

  // 生成近7天日期字符串列表（含今天）
  for (let i = 6; i >= 0; i--) {
    const d = new Date(today)
    d.setDate(d.getDate() - i)
    dateStrList.push(dateToStr(d))
  }

  // 查询DayInfo
  const dayInfoList: DayStats[] = await new Promise((resolve) => {
    DayInfoApi.queryList(dateStrList, (res: DayInfo[]) => {
      const todayStr = dateToStr(today)
      const result: DayStats[] = dateStrList.map((dateStr, idx) => {
        const originalDate = new Date(today)
        originalDate.setDate(originalDate.getDate() - (6 - idx))
        const found = res.find((item) => item.date === dateStr)
        return {
          date: dateStr,
          dayLabel: WEEK_DAY_LABELS[originalDate.getDay()],
          percent: found && found.targetTaskNum > 0 ?
            Math.round(found.finTaskNum / found.targetTaskNum * 100) : 0,
          targetNum: found ? found.targetTaskNum : 0,
          finishNum: found ? found.finTaskNum : 0,
          isToday: dateStr === todayStr
        } as DayStats
      })
      resolve(result)
    })
  })

  // 查询汇总数据
  const summary: StatsSummary = await new Promise((resolve) => {
    GlobalInfoApi.query((res: GlobalInfo) => {
      // 从 achievements 字段解析成就数量（格式："3,7,30"）
      let achievedCount = 0
      if (res.achievements && res.achievements.length > 0) {
        achievedCount = res.achievements.split(',').filter((s: string) => s.length > 0).length
      }
      resolve({
        totalCheckInDays: res.checkInDays || 0,
        currentStreak: calculateCurrentStreak(dayInfoList),
        bestStreak: calculateBestStreak(res),
        achievedCount: achievedCount
      } as StatsSummary)
    })
  })

  return new StatsData(dayInfoList, summary)
}

/**
 * 计算当前连续打卡天数（从今天往前数，中断即停）
 */
function calculateCurrentStreak(dayList: DayStats[]): number {
  let streak = 0
  // 从最后一天（今天）往前数
  for (let i = dayList.length - 1; i >= 0; i--) {
    if (dayList[i].percent >= 100) {
      streak++
    } else if (dayList[i].isToday && dayList[i].percent < 100) {
      // 今天还没完成，继续往前看
      continue
    } else {
      break
    }
  }
  return streak
}

/**
 * 从globalInfo获取最长连续天数
 */
function calculateBestStreak(globalInfo: GlobalInfo): number {
  // checkInDays 记录的是累计打卡天数，achievements 中的最大值反映历史最佳
  const achievements = globalInfo.achievements || ''
  if (!achievements || achievements.length === 0) {
    return 0
  }
  const levels = achievements.split(',').map(Number).filter(n => !isNaN(n))
  return levels.length > 0 ? Math.max(...levels) : 0
}
