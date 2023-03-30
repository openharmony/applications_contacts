import i18n from '@ohos.i18n';

const YEAR_CONVERT: number = 2697;
const YEAR_CYCLE: number = 60;
const LUNAR_MONTH = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "腊"];
const LUNAR_DAY = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四",
"十五", "十六", "十七", "十八", "十九", "廿十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十",
"三一"];
const NUM_CHAR = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"];

class CalendarUtil {
  //公历转农历
  getLunarDate(date: Date) {
    let calendar = i18n.getCalendar("zh-CN", "chinese");
    calendar.setTime(date);
    const lunarMonth = calendar.get('month');
    const lunarDay = calendar.get('date');
    let lunarYear = calendar.get('era') * YEAR_CYCLE + calendar.get('year') - YEAR_CONVERT;
    return {
      year: lunarYear,
      month: lunarMonth,
      day: lunarDay
    }
  }

  formatLunarDate(lunar: any) {
    if (!lunar) {
      return "";
    }
    let result: string = '';
    if (lunar.year) {
      result += `${lunar.year}年`
    }
    if (lunar.month != undefined) {
      result += `${LUNAR_MONTH[lunar.month]}月`
    }
    if (lunar.day) {
      result += ` ${LUNAR_DAY[lunar.day - 1]}`
    }
    return result;
  }
}

export default new CalendarUtil();




