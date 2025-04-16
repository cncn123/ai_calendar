//
//  CalendarViewModel.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI
import Foundation

// MARK: - 日历视图模型
class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var currentMonth = Calendar.current.component(.month, from: Date())
    @Published var currentYear = Calendar.current.component(.year, from: Date())
    @Published var selectedRegion: Holiday.Region? = nil
    
    let weekDays = ["日", "一", "二", "三", "四", "五", "六"]
    let holidayService = HolidayService.shared
    
    // 获取当月的所有日期（已缓存）
    private var cachedDays: [Date?]? = nil
    private var cachedMonth: Int = 0
    private var cachedYear: Int = 0
    
    func daysInMonth() -> [Date?] {
        // 如果已经计算过且月份年份没变，返回缓存结果
        if cachedDays != nil && cachedMonth == currentMonth && cachedYear == currentYear {
            return cachedDays!
        }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 30
        
        var days = [Date?](repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            dateComponents.day = day
            if let date = calendar.date(from: dateComponents) {
                days.append(date)
            }
        }
        
        // 补全最后一行
        let remainingCells = 7 - (days.count % 7)
        if remainingCells < 7 {
            days.append(contentsOf: [Date?](repeating: nil, count: remainingCells))
        }
        
        // 更新缓存
        cachedDays = days
        cachedMonth = currentMonth
        cachedYear = currentYear
        
        return days
    }
    
    func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentMonth == 1 {
                currentMonth = 12
                currentYear -= 1
            } else {
                currentMonth -= 1
            }
        }
    }
    
    func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentMonth == 12 {
                currentMonth = 1
                currentYear += 1
            } else {
                currentMonth += 1
            }
        }
    }
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // 根据选择的地区过滤节假日
    func getFilteredHoliday(for date: Date) -> Holiday? {
        let holiday = holidayService.getHoliday(for: date)
        
        // 如果没有选择地区或节假日为空，直接返回
        if selectedRegion == nil || holiday == nil {
            return holiday
        }
        
        // 根据选择的地区过滤
        if holiday?.region == selectedRegion {
            return holiday
        }
        
        return nil
    }
    
    // 获取当月的所有节假日并根据地区过滤
    func getCurrentMonthHolidays() -> [Holiday] {
        let holidays = holidayService.getHolidaysForMonth(month: currentMonth, year: currentYear)
        
        // 如果选择了地区，则过滤
        if let region = selectedRegion {
            return holidays.filter { $0.region == region }
                          .sorted(by: { $0.startDate < $1.startDate })
        }
        
        // 否则返回所有节假日
        return holidays.sorted(by: { $0.startDate < $1.startDate })
    }
}
