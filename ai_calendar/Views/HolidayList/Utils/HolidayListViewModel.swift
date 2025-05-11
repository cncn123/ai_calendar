//
//  HolidayListViewModel.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI
import Foundation

// MARK: - 节假日列表视图模型
class HolidayListViewModel: ObservableObject {
    @Published var holidays: [Holiday] = []
    @Published var selectedRegion: HolidayRegion? = nil // 添加地区选择状态
    
    private let holidayService = HolidayService.shared
    
    // 支持的年份
    var supportedYears: [Int] {
        Array(holidayService.supportedYears)
    }
    
    // 加载指定年份的假期
    func loadHolidays(for year: Int) {
        holidays = holidayService.holidays(for: year)
    }
    
    // 切换地区显示
    func toggleRegion(_ region: HolidayRegion?) {
        selectedRegion = (selectedRegion == region) ? nil : region
    }
    
    // 检查当前是否选中了特定地区
    func isRegionSelected(_ region: HolidayRegion) -> Bool {
        return selectedRegion == region
    }
    
    // 获取指定月份的假期，根据所选地区进行过滤
    func getHolidays(for month: Int) -> [Holiday] {
        let monthHolidays = holidays.filter { $0.startDate.month == month }
        
        // 如果选择了特定地区，则过滤相应地区的假期
        if let region = selectedRegion {
            return monthHolidays.filter { $0.region == region }.sorted { $0.startDate < $1.startDate }
        }
        
        return monthHolidays.sorted { $0.startDate < $1.startDate }
    }
    
    // 检查指定日期是否有多地区假日
    func hasMultiRegionHoliday(date: Date) -> Bool {
        let holidaysOnDate = holidays.filter { 
            Calendar.current.isDate($0.startDate, inSameDayAs: date)
        }
        
        let regions = Set(holidaysOnDate.map { $0.region })
        return regions.count > 1
    }
    
    // 获取多地区假日
    func getMultiRegionHolidays(for date: Date) -> (hkHoliday: Holiday?, mlHoliday: Holiday?) {
        let holidaysOnDate = holidays.filter { 
            Calendar.current.isDate($0.startDate, inSameDayAs: date)
        }
        
        let hkHoliday = holidaysOnDate.first { $0.region == .hongkong }
        let mlHoliday = holidaysOnDate.first { $0.region == .mainland }
        
        return (hkHoliday, mlHoliday)
    }
} 