//
//  Holiday.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import Foundation

struct Holiday: Identifiable {
    var id = UUID()
    var name: String
    var date: Date
    var type: HolidayType
    var description: String
    var duration: Int // 假期持续天数
    var region: Region // 适用地区
    
    // 节假日类型
    enum HolidayType: String, CaseIterable, Identifiable {
        case national = "国家法定节假日"
        case traditional = "传统节日"
        case international = "国际节日"
        case memorial = "纪念日"
        
        var id: String { self.rawValue }
    }
    
    // 地区
    enum Region: String, CaseIterable, Identifiable {
        case mainland = "内地"
        case hongKong = "香港"
        case both = "内地和香港"
        
        var id: String { self.rawValue }
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