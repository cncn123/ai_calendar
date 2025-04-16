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
    var region: Region // 适用地区
    
    // 节假日类型
    enum HolidayType: String, CaseIterable, Identifiable, Codable {
        case national = "国家法定节假日"
        case traditional = "传统节日"
        case international = "国际节日"
        case memorial = "纪念日"
        
        var id: String { self.rawValue }
    }
    
    // 地区
    enum Region: String, CaseIterable, Identifiable, Codable {
        case mainland = "内地"
        case hongKong = "香港"
        case both = "内地和香港"
        
        var id: String { self.rawValue }
    }
    
    // 从 vevent 数据创建 Holiday
    init(from vevent: VEvent, region: Region) {
        self.id = vevent.uid
        self.name = vevent.summary
        self.startDate = vevent.dtstart.date
        self.endDate = vevent.dtend.date
        self.region = region
    }
    
    // 获取节假日描述
    private func getDescription(for name: String) -> String {
        switch name {
        case "一月一日", "一月一日翌日":
            return "新年的第一天"
        case "农历年初一", "农历年初二", "农历年初三", "农历年初四":
            return "中国农历新年，是中国最重要的传统节日"
        case "清明节":
            return "扫墓祭祖的传统节日"
        case "耶稣受难节", "耶稣受难节翌日":
            return "纪念耶稣被钉十字架而死"
        case "复活节星期一":
            return "纪念耶稣被钉十字架而死后复活的奇迹"
        case "劳动节":
            return "国际劳动节"
        case "佛诞":
            return "农历4月8日，纪念佛祖诞辰"
        case "端午节":
            return "纪念屈原的传统节日，有吃粽子、赛龙舟等习俗"
        case "香港特别行政区成立纪念日":
            return "纪念香港回归"
        case "中秋节翌日":
            return "农历8月15日（中秋节）的翌日"
        case "国庆日", "国庆节翌日":
            return "庆祝中华人民共和国成立"
        case "重阳节":
            return "农历9月9日，又称秋祭"
        case "圣诞节":
            return "纪念耶稣基督诞生的节日"
        case "圣诞节后第一个周日":
            return "圣诞节后的第一个周日"
        default:
            return name
        }
    }
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
}
