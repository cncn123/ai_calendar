import SwiftUI
import Foundation

// MARK: - 日历视图模型
class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var currentMonth = Calendar.current.component(.month, from: Date())
    @Published var currentYear = Calendar.current.component(.year, from: Date())
    @Published var holidays: [Holiday] = []
    @Published var selectedHoliday: Holiday?
    @Published var selectedRegion: HolidayRegion? = nil // 选择的地区过滤
    
    let weekDays = ["日", "一", "二", "三", "四", "五", "六"]
    
    private let holidayService = HolidayService.shared
    
    // 获取当月的所有日期（已缓存）
    private var cachedDays: [Date?]? = nil
    private var cachedMonth: Int = 0
    private var cachedYear: Int = 0
    
    // 每月假日缓存
    private var monthHolidaysCache: [String: [Holiday]] = [:]
    
    init() {
        loadHolidays()
    }
    
    // 加载节假日数据
    func loadHolidays() {
        holidays = holidayService.holidays(for: Calendar.current.component(.year, from: Date()))
    }
    
    // 刷新当月假日数据
    func refreshMonthHolidays() {
        // 清除当月缓存
        let cacheKey = "\(currentYear)-\(currentMonth)-\(selectedRegion?.rawValue ?? "all")"
        monthHolidaysCache.removeValue(forKey: cacheKey)
        
        // 强制重新加载
        holidayService.clearCache(for: .hongkong)
        holidayService.clearCache(for: .mainland)
        
        // 通知UI更新
        objectWillChange.send()
    }
    
    // 切换地区显示
    func toggleRegion(_ region: HolidayRegion?) {
        withAnimation {
            selectedRegion = (selectedRegion == region) ? nil : region
        }
    }
    
    // 检查当前是否选中了特定地区
    func isRegionSelected(_ region: HolidayRegion) -> Bool {
        return selectedRegion == region
    }
    
    func getHolidaysForMonth(month: Int, year: Int) -> [Holiday] {
        return holidayService.holidays(in: month, year: year, region: selectedRegion)
    }
    
    func getHoliday(for date: Date) -> Holiday? {
        return holidayService.holiday(for: date, region: selectedRegion)
    }
    
    // 获取特定日期的所有地区节假日
    func getAllHolidaysForDate(_ date: Date) -> [Holiday] {
        return holidayService.holidaysForDate(date)
    }
    
    // 获取特定日期的香港和内地节假日（用于多地区节假日显示）
    func getHolidaysForMultiRegionCard(date: Date) -> (hkHoliday: Holiday?, mlHoliday: Holiday?) {
        let holidays = getAllHolidaysForDate(date)
        let hkHoliday = holidays.first { $0.region == .hongkong }
        let mlHoliday = holidays.first { $0.region == .mainland }
        return (hkHoliday, mlHoliday)
    }
    
    // 判断日期是否有多个地区的节假日
    func hasMultiRegionHolidays(_ date: Date) -> Bool {
        let holidays = getAllHolidaysForDate(date)
        if holidays.count <= 1 {
            return false
        }
        
        // 检查是否有不同地区的节假日
        let regions = Set(holidays.map { $0.region })
        return regions.count > 1
    }
    
    func selectHoliday(_ holiday: Holiday) {
        selectedHoliday = holiday
    }
    
    func clearSelectedHoliday() {
        selectedHoliday = nil
    }
    
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
        // 新增：补齐到6行（42个格子）
        while days.count < 42 {
            days.append(nil)
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
    
    // 获取当月的所有节假日并根据地区过滤，去重并正确排序
    func getCurrentMonthHolidays() -> [Holiday] {
        // 使用缓存键
        let cacheKey = "\(currentYear)-\(currentMonth)-\(selectedRegion?.rawValue ?? "all")"
        
        // 如果已有缓存，直接返回
        if let cachedHolidays = monthHolidaysCache[cacheKey] {
            return cachedHolidays
        }
        
        let holidays = holidayService.holidays(in: currentMonth, year: currentYear, region: selectedRegion)
        
        // 使用日期分组，确保同一天的节假日只显示一个（按地区优先级选择）
        let groupedByDate = Dictionary(grouping: holidays) { holiday -> String in
            // 使用日期作为分组键
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: holiday.startDate)
        }
        
        // 从每组中选择一个节假日（优先选择香港节假日）
        let uniqueHolidays = groupedByDate.compactMap { (_, holidaysForDate) -> Holiday? in
            // 如果有香港节假日，优先显示
            if let hkHoliday = holidaysForDate.first(where: { $0.region == .hongkong }) {
                return hkHoliday
            }
            // 否则显示内地节假日
            return holidaysForDate.first
        }
        
        // 按日期排序
        let result = uniqueHolidays.sorted { $0.startDate < $1.startDate }
        
        // 存入缓存
        monthHolidaysCache[cacheKey] = result
        
        return result
    }
}
