//
//  Holiday.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import Foundation

struct Holiday: Identifiable, Codable {
    var id: String // 使用 uid 作为唯一标识符
    var name: String // 节假日名称
    var startDate: Date // 开始日期
    var endDate: Date // 结束日期
    var region: HolidayRegion // 地区信息
    
    // 从 vevent 数据创建香港假日
    init(from vevent: VEvent) {
        self.id = vevent.uid
        self.name = vevent.summary
        self.startDate = vevent.dtstart.date
        self.endDate = vevent.dtend.date
        self.region = .hongKong
    }
    
    // 从内地假日数据创建假日
    init(from mainlandDay: MainlandHolidayDay, year: Int) {
        self.id = "mainland_\(mainlandDay.date)"
        self.name = mainlandDay.name
        
        // 解析日期 (YYYY-MM-DD 格式)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        self.startDate = dateFormatter.date(from: mainlandDay.date) ?? Date()
        
        // 结束日期设为开始日期后一天
        self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? Date()
        self.region = .mainland
    }
}

// 假日区域枚举
enum HolidayRegion: String, Codable {
    case hongKong = "香港"
    case mainland = "内地"
}

// vevent 数据结构
struct VEvent: Codable {
    let dtstart: DateValue
    let dtend: DateValue
    let transp: String
    let uid: String
    let summary: String
}

// 日期值结构
struct DateValue: Codable {
    let date: Date
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let dateString = try container.decode(String.self)
        _ = try container.decode(DateValueType.self) // 忽略第二个元素
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Hong_Kong")
        
        guard let date = dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "日期格式错误")
        }
        
        self.date = date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Hong_Kong")
        try container.encode(dateFormatter.string(from: date))
        try container.encode(DateValueType(value: "DATE"))
    }
}

// 日期值类型
struct DateValueType: Codable {
    let value: String
}

// 日历数据结构
struct CalendarData: Codable {
    let vcalendar: [VCalendar]
}

struct VCalendar: Codable {
    let prodid: String
    let version: String
    let calscale: String
    let xWrTimezone: String
    let xWrCalname: String
    let xWrCaldesc: String
    let vevent: [VEvent]
    
    enum CodingKeys: String, CodingKey {
        case prodid
        case version
        case calscale
        case xWrTimezone = "x-wr-timezone"
        case xWrCalname = "x-wr-calname"
        case xWrCaldesc = "x-wr-caldesc"
        case vevent
    }
}

// 内地节假日数据结构
struct MainlandHolidayData: Codable {
    let year: Int
    let days: [MainlandHolidayDay]
}

struct MainlandHolidayDay: Codable {
    let name: String
    let date: String
    let isOffDay: Bool
}

// 扩展Date以便于处理日期
extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    var dayOfMonth: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var formattedForID: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: self)
    }
}
