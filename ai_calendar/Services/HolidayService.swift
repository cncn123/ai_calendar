//
//  HolidayService.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import Foundation

class HolidayService {
    static let shared = HolidayService()
    
    private init() {}
    
    // 获取所有节假日
    func getAllHolidays(for year: Int = Calendar.current.component(.year, from: Date())) -> [Holiday] {
        return getMainlandHolidays(for: year) + getHongKongHolidays(for: year)
    }
    
    // 获取内地节假日
    func getMainlandHolidays(for year: Int = Calendar.current.component(.year, from: Date())) -> [Holiday] {
        return [
            // 国家法定节假日
            Holiday(
                name: "元旦",
                date: Date.from(year: year, month: 1, day: 1),
                type: .national,
                description: "新年的第一天",
                duration: 3,
                region: .mainland
            ),
            Holiday(
                name: "春节",
                date: Date.from(year: year, month: 1, day: 29), // 2025年春节是1月29日(农历正月初一)
                type: .national,
                description: "中国农历新年，是中国最重要的传统节日",
                duration: 7,
                region: .mainland
            ),
            Holiday(
                name: "清明节",
                date: Date.from(year: year, month: 4, day: 5), // 2025年清明节是4月5日
                type: .traditional,
                description: "扫墓祭祖的传统节日",
                duration: 3,
                region: .mainland
            ),
            Holiday(
                name: "劳动节",
                date: Date.from(year: year, month: 5, day: 1),
                type: .national,
                description: "国际劳动节",
                duration: 5,
                region: .mainland
            ),
            Holiday(
                name: "端午节",
                date: Date.from(year: year, month: 6, day: 25), // 2025年端午节是6月25日(农历五月初五)
                type: .traditional,
                description: "纪念屈原的传统节日，有吃粽子、赛龙舟等习俗",
                duration: 3,
                region: .mainland
            ),
            Holiday(
                name: "中秋节",
                date: Date.from(year: year, month: 9, day: 22), // 2025年中秋节是9月22日(农历八月十五)
                type: .traditional,
                description: "家人团聚、赏月、吃月饼的传统节日",
                duration: 3,
                region: .mainland
            ),
            Holiday(
                name: "国庆节",
                date: Date.from(year: year, month: 10, day: 1),
                type: .national,
                description: "庆祝中华人民共和国成立",
                duration: 7,
                region: .mainland
            )
        ]
    }
    
    // 获取香港节假日
    func getHongKongHolidays(for year: Int = Calendar.current.component(.year, from: Date())) -> [Holiday] {
        return [
            Holiday(
                name: "元旦",
                date: Date.from(year: year, month: 1, day: 1),
                type: .national,
                description: "新年的第一天",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "春节",
                date: Date.from(year: year, month: 1, day: 29), // 2025年农历正月初一是公历1月29日
                type: .traditional,
                description: "2025年农历正月初一—是公历1月29日，放假3天（正月初一至初三）。",
                duration: 3,
                region: .hongKong
            ),
            Holiday(
                name: "清明节",
                date: Date.from(year: year, month: 4, day: 4), // 2025年清明节是4月4日
                type: .traditional,
                description: "清明日",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "耶稣受难节",
                date: Date.from(year: year, month: 4, day: 18), // 2025年耶稣受难节是4月18日
                type: .international,
                description: "纪念耶稣被钉十字架而死。复活节前两天的星期五是受难节。",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "复活节星期一",
                date: Date.from(year: year, month: 4, day: 21), // 2025年复活节星期一是4月21日
                type: .international,
                description: "纪念耶稣被钉十字架而死后复活的奇迹。复活节是在每年春分之后第一次满月之后的第一个星期日。",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "复活节星期二",
                date: Date.from(year: year, month: 4, day:  22), // 2025年复活节星期一是4月21日
                type: .international,
                description: "纪念耶稣被钉十字架而死后复活的奇迹。复活节是在每年春分之后第一次满月之后的第一个星期日。",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "复活节星期三",
                date: Date.from(year: year, month: 4, day:  23), // 2025年复活节星期一是4月21日
                type: .international,
                description: "纪念耶稣被钉十字架而死后复活的奇迹。复活节是在每年春分之后第一次满月之后的第一个星期日。",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "劳动节",
                date: Date.from(year: year, month: 5, day: 1),
                type: .national,
                description: "国际劳动节",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "佛诞",
                date: Date.from(year: year, month: 5, day: 5), // 2025年佛诞是5月5日
                type: .traditional,
                description: "农历4月8日",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "端午节",
                date: Date.from(year: year, month: 5, day: 31), // 2025年端午节是5月31日
                type: .traditional,
                description: "农历5月5日",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "香港特别行政区成立纪念日",
                date: Date.from(year: year, month: 7, day: 1),
                type: .national,
                description: "纪念香港回归",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "中秋节翌日",
                date: Date.from(year: year, month: 10, day: 7), // 2025年中秋节翌日是10月7日
                type: .traditional,
                description: "农历8月15日（中秋节）的翌日。",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "国庆节",
                date: Date.from(year: year, month: 10, day: 1),
                type: .national,
                description: "庆祝中华人民共和国成立",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "重阳节",
                date: Date.from(year: year, month: 10, day: 29), // 2025年重阳节是10月29日
                type: .traditional,
                description: "农历9月9日，又称秋祭。",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "圣诞节",
                date: Date.from(year: year, month: 12, day: 25),
                type: .international,
                description: "Christmas Day",
                duration: 1,
                region: .hongKong
            ),
            Holiday(
                name: "圣诞节后第一个平日",
                date: Date.from(year: year, month: 12, day: 26),
                type: .international,
                description: "Boxing day / 节礼日",
                duration: 1,
                region: .hongKong
            )
        ]
    }
    
    // 根据日期获取节假日
    func getHoliday(for date: Date) -> Holiday? {
        let holidays = getAllHolidays(for: date.year)
        return holidays.first { holiday in
            let calendar = Calendar.current
            return calendar.isDate(holiday.date, inSameDayAs: date)
        }
    }
    
    // 获取当月的所有节假日
    func getHolidaysForMonth(month: Int, year: Int) -> [Holiday] {
        let allHolidays = getAllHolidays(for: year)
        return allHolidays.filter { $0.date.month == month }
    }
}
