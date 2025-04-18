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
    
    // 从 JSON 文件加载节假日数据
    private func loadHolidays(from filename: String, region: Holiday.Region) -> [Holiday] {
        print("尝试加载文件: \(filename).json")
        
        // 获取 bundle 中的所有文件
        if let resourcePath = Bundle.main.resourcePath {
            print("Bundle 资源路径: \(resourcePath)")
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("Bundle 中的文件: \(files)")
            } catch {
                print("无法读取 bundle 内容: \(error)")
            }
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("错误：找不到文件 \(filename).json")
            // 尝试直接使用完整路径
            if let path = Bundle.main.path(forResource: filename, ofType: "json") {
                print("找到文件路径: \(path)")
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    print("成功读取文件数据，大小: \(data.count) 字节")
                    if let calendarData = try? JSONDecoder().decode(CalendarData.self, from: data) {
                        print("成功解析JSON数据")
                        print("节假日数量: \(calendarData.vcalendar.first?.vevent.count ?? 0)")
                        let holidays = calendarData.vcalendar.first?.vevent.map { vevent in
                            Holiday(from: vevent, region: region)
                        } ?? []
                        print("创建的节假日对象数量: \(holidays.count)")
                        return holidays
                    }
                }
            }
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
            Holiday(from: vevent, region: region)
        } ?? []
        
        print("创建的节假日对象数量: \(holidays.count)")
        return holidays
    }
    
    // 获取所有节假日
    func getAllHolidays(for year: Int = Calendar.current.component(.year, from: Date())) -> [Holiday] {
        let hongKongHolidays = loadHolidays(from: "cal_hk_holiday", region: .hongKong)
        print("加载的香港节假日数量: \(hongKongHolidays.count)")
        return hongKongHolidays
    }
    
    // 获取香港节假日
    func getHongKongHolidays(for year: Int = Calendar.current.component(.year, from: Date())) -> [Holiday] {
        let holidays = loadHolidays(from: "cal_hk_holiday", region: .hongKong)
        print("加载的香港节假日数量: \(holidays.count)")
        return holidays
    }
    
    // 根据日期获取节假日
    func getHoliday(for date: Date) -> Holiday? {
        let holidays = getAllHolidays(for: date.year)
        return holidays.first { holiday in
            let calendar = Calendar.current
            return calendar.isDate(date, inSameDayAs: holiday.startDate)
        }
    }
    
    // 获取当月的所有节假日
    func getHolidaysForMonth(month: Int, year: Int) -> [Holiday] {
        let allHolidays = getAllHolidays(for: year)
        return allHolidays.filter { $0.startDate.month == month }
    }
}
