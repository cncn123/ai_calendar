//
//  HolidayService.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import Foundation

class HolidayService {
    static let shared = HolidayService()
    
    // 缓存不同年份、不同地区的节假日数据
    private var holidaysCache: [HolidayRegion: [Int: [Holiday]]] = [
        .hongkong: [:],
        .mainland: [:]
    ]
    
    // 支持的年份范围
    private let supportedYearRange = 2023...2025
    
    // 默认假日数据文件名
    private let hkHolidayFileTemplate = "hk_holidays_sc_%d"
    private let mainlandHolidayFileTemplate = "mainland_holidays_%d"
    
    private init() {}
    
    // 从香港节假日 JSON 文件加载节假日数据
    private func loadHKHolidays(for year: Int) -> [Holiday] {
        let filename = String(format: hkHolidayFileTemplate, year)
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return []
        }
        
        guard let data = try? Data(contentsOf: url) else {
            return []
        }
        
        guard let calendarData = try? JSONDecoder().decode(CalendarData.self, from: data) else {
            return []
        }
        
        let holidays = calendarData.vcalendar.first?.vevent.map { vevent in
            Holiday(from: vevent)
        } ?? []
        
        return holidays
    }
    
    // 从内地节假日 JSON 文件加载节假日数据
    private func loadMainlandHolidays(for year: Int) -> [Holiday] {
        let filename = String(format: mainlandHolidayFileTemplate, year)
        
        // 查找文件路径
        let paths: [URL?] = [
            Bundle.main.url(forResource: filename, withExtension: "json")
        ]
        
        guard let url = paths.compactMap({ $0 }).first else {
            return []
        }
        
        guard let data = try? Data(contentsOf: url) else {
            return []
        }
        
        do {
            let mainlandData = try JSONDecoder().decode(MainlandHolidayData.self, from: data)
            
            // 只选择是休息日的节假日
            let holidays = mainlandData.days
                .filter { $0.isOffDay }
                .map { Holiday(from: $0, year: year) }
            
            return holidays
        } catch {
            return []
        }
    }
    
    // 检查年份是否在支持范围内
    private func isYearSupported(_ year: Int) -> Bool {
        return supportedYearRange.contains(year)
    }
    
    // 获取指定地区和年份的所有节假日
    func holidays(for year: Int = Calendar.current.component(.year, from: Date()), region: HolidayRegion? = nil) -> [Holiday] {
        // 检查年份是否在支持范围内
        guard isYearSupported(year) else {
            return []
        }
        
        var result: [Holiday] = []
        
        // 如果指定了地区，只加载该地区假日
        if let region = region {
            result = loadHolidays(for: year, region: region)
        } else {
            // 否则加载所有地区假日
            let hkHolidays = loadHolidays(for: year, region: .hongkong)
            let mainlandHolidays = loadHolidays(for: year, region: .mainland)
            
            result = hkHolidays + mainlandHolidays
        }
        
        return result
    }
    
    // 加载指定地区和年份的节假日数据
    private func loadHolidays(for year: Int, region: HolidayRegion) -> [Holiday] {
        // 如果已缓存，直接返回缓存数据
        if let cachedHolidays = holidaysCache[region]?[year] {
            return cachedHolidays
        }
        
        var holidays: [Holiday] = []
        
        switch region {
        case .hongkong:
            let allHKHolidays = loadHKHolidays(for: year)
        // 过滤出当年的假期
            holidays = allHKHolidays.filter { $0.startDate.year == year }
        case .mainland:
            holidays = loadMainlandHolidays(for: year)
        }
        
        // 添加到缓存
        if holidaysCache[region] == nil {
            holidaysCache[region] = [:]
        }
        holidaysCache[region]?[year] = holidays
        
        return holidays
    }
    
    // 根据日期获取节假日，可选择指定地区
    func holiday(for date: Date, region: HolidayRegion? = nil) -> Holiday? {
        let allHolidays = holidays(for: date.year, region: region)
        return allHolidays.first { holiday in
            let calendar = Calendar.current
            return calendar.isDate(date, inSameDayAs: holiday.startDate)
        }
    }
    
    // 获取当月的所有节假日，可选择指定地区
    func holidays(in month: Int, year: Int, region: HolidayRegion? = nil) -> [Holiday] {
        let allHolidays = holidays(for: year, region: region)
        let filteredHolidays = allHolidays.filter { $0.startDate.month == month }
        return filteredHolidays
    }
    
    // 清除所有缓存
    func clearCache() {
        holidaysCache = [.hongkong: [:], .mainland: [:]]
    }
    
    // 清除指定地区的缓存
    func clearCache(for region: HolidayRegion) {
        holidaysCache[region] = [:]
    }
    
    // 获取支持的年份范围
    var supportedYears: ClosedRange<Int> {
        return supportedYearRange
    }
    
    // 向后兼容旧API
    @available(*, deprecated, message: "请使用 holidays(for:region:) 代替")
    func getAllHolidays(for year: Int = Calendar.current.component(.year, from: Date())) -> [Holiday] {
        return holidays(for: year)
    }
    
    @available(*, deprecated, message: "请使用 holiday(for:region:) 代替")
    func getHoliday(for date: Date) -> Holiday? {
        return holiday(for: date)
    }
    
    @available(*, deprecated, message: "请使用 holidays(in:year:region:) 代替")
    func getHolidaysForMonth(month: Int, year: Int) -> [Holiday] {
        return holidays(in: month, year: year)
    }
    
    @available(*, deprecated, message: "请使用 supportedYears 代替")
    func getSupportedYearRange() -> ClosedRange<Int> {
        return supportedYears
    }
    
    // 添加获取特定日期所有节假日的方法，不过滤地区
    func holidaysForDate(_ date: Date) -> [Holiday] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        // 获取所有节假日
        let allHolidays = holidays(for: year)
        
        // 过滤出指定日期的节假日
        return allHolidays.filter { holiday in
            calendar.isDate(holiday.startDate, inSameDayAs: date)
        }
    }
}
