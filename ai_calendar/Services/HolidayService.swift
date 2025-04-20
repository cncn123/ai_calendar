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
        .hongKong: [:],
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
        print("尝试加载香港假日文件: \(filename).json")
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("错误：找不到文件 \(filename).json")
            return []
        }
        
        print("找到文件URL: \(url)")
        
        guard let data = try? Data(contentsOf: url) else {
            print("错误：无法读取文件数据")
            return []
        }
        
        print("成功读取文件数据，大小: \(data.count) 字节")
        
        guard let calendarData = try? JSONDecoder().decode(CalendarData.self, from: data) else {
            print("错误：无法解析JSON数据")
            return []
        }
        
        print("成功解析JSON数据")
        print("节假日数量: \(calendarData.vcalendar.first?.vevent.count ?? 0)")
        
        let holidays = calendarData.vcalendar.first?.vevent.map { vevent in
            Holiday(from: vevent)
        } ?? []
        
        print("创建的香港节假日对象数量: \(holidays.count)")
        return holidays
    }
    
    // 从内地节假日 JSON 文件加载节假日数据
    private func loadMainlandHolidays(for year: Int) -> [Holiday] {
        let filename = String(format: mainlandHolidayFileTemplate, year)
        print("尝试加载内地假日文件: \(filename).json")
        
        // 查找文件路径
        let paths: [URL?] = [
            Bundle.main.url(forResource: filename, withExtension: "json")
        ]
        
        print("尝试查找文件路径")
        
        guard let url = paths.compactMap({ $0 }).first else {
            print("错误：找不到文件 \(filename).json")
            return []
        }
        
        print("找到内地假日文件URL: \(url)")
        
        guard let data = try? Data(contentsOf: url) else {
            print("错误：无法读取内地假日文件数据")
            return []
        }
        
        print("成功读取内地假日数据，大小: \(data.count) 字节")
        
        // 尝试将数据打印为字符串查看格式
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON内容预览: \(String(jsonString.prefix(200)))...")
        }
        
        do {
            let mainlandData = try JSONDecoder().decode(MainlandHolidayData.self, from: data)
            print("成功解析内地假日JSON数据: 年份 \(mainlandData.year), 假日数量: \(mainlandData.days.count)")
            
            // 只选择是休息日的节假日
            let holidays = mainlandData.days
                .filter { $0.isOffDay }
                .map { Holiday(from: $0, year: year) }
            
            print("创建的内地节假日对象数量: \(holidays.count)")
            
            // 打印前几个假日数据作为参考
            if !holidays.isEmpty {
                print("内地假日样本:")
                for (index, holiday) in holidays.prefix(3).enumerated() {
                    print("\(index+1). \(holiday.name): \(holiday.startDate) - \(holiday.endDate), 地区: \(holiday.region.rawValue)")
                }
            }
            
            return holidays
        } catch {
            print("内地假日JSON解析错误: \(error)")
            print("解码失败: \(error.localizedDescription)")
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
            print("警告：不支持 \(year) 年的数据，目前仅支持 \(supportedYearRange) 年")
            return []
        }
        
        var result: [Holiday] = []
        
        // 如果指定了地区，只加载该地区假日
        if let region = region {
            result = loadHolidays(for: year, region: region)
        } else {
            // 否则加载所有地区假日
            let hkHolidays = loadHolidays(for: year, region: .hongKong)
            let mainlandHolidays = loadHolidays(for: year, region: .mainland)
            
            print("合并假日数据: 香港 \(hkHolidays.count) 条, 内地 \(mainlandHolidays.count) 条")
            
            result = hkHolidays + mainlandHolidays
        }
        
        print("返回 \(year) 年的节假日共 \(result.count) 条")
        return result
    }
    
    // 加载指定地区和年份的节假日数据
    private func loadHolidays(for year: Int, region: HolidayRegion) -> [Holiday] {
        print("请求加载 \(year) 年 \(region.rawValue) 地区的节假日")
        
        // 如果已缓存，直接返回缓存数据
        if let cachedHolidays = holidaysCache[region]?[year] {
            print("使用缓存的 \(region.rawValue) 节假日数据: \(cachedHolidays.count) 条")
            return cachedHolidays
        }
        
        var holidays: [Holiday] = []
        
        switch region {
        case .hongKong:
            let allHKHolidays = loadHKHolidays(for: year)
            // 过滤出当年的假期
            holidays = allHKHolidays.filter { $0.startDate.year == year }
            print("过滤出 \(year) 年的香港节假日: \(holidays.count) 条")
        case .mainland:
            holidays = loadMainlandHolidays(for: year)
            print("加载 \(year) 年的内地节假日: \(holidays.count) 条")
        }
        
        // 添加到缓存
        if holidaysCache[region] == nil {
            holidaysCache[region] = [:]
        }
        holidaysCache[region]?[year] = holidays
        
        print("缓存 \(year) 年的 \(region.rawValue) 节假日数量: \(holidays.count)")
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
        print("获取 \(year)年\(month)月的节假日, 地区: \(region?.rawValue ?? "全部"), 结果: \(filteredHolidays.count) 条")
        return filteredHolidays
    }
    
    // 清除所有缓存
    func clearCache() {
        holidaysCache = [.hongKong: [:], .mainland: [:]]
        print("节假日缓存已清除")
    }
    
    // 清除指定地区的缓存
    func clearCache(for region: HolidayRegion) {
        holidaysCache[region] = [:]
        print("\(region.rawValue)节假日缓存已清除")
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
