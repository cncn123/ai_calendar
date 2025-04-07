//
//  CalendarView.swift
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
                          .sorted { $0.date < $1.date }
        }
        
        // 否则返回所有节假日
        return holidays.sorted { $0.date < $1.date }
    }
}

// MARK: - 主日历视图
struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部栏
                CalendarHeaderView(viewModel: viewModel)
                
                // 月份选择器
                MonthSelectorView(viewModel: viewModel)
                
                // 日历内容
                CalendarGridView(viewModel: viewModel)
                
                // 选中日期的节假日信息
                if let holiday = viewModel.getFilteredHoliday(for: viewModel.selectedDate) {
                    HolidayInfoCard(holiday: holiday)
                        .padding()
                        .transition(.move(edge: .bottom))
                }
                
                // 当月所有节假日卡片
                MonthlyHolidaysView(viewModel: viewModel)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .animation(.easeInOut, value: viewModel.selectedDate)
            .animation(.easeInOut, value: viewModel.selectedRegion)
        }
    }
}

// MARK: - 顶部栏视图
struct CalendarHeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        HStack {
            Text("节假日日历")
                .font(.headline)
                .padding(.leading)
                .accessibilityLabel("节假日日历标题")

            Spacer()
            
            // 地区选择按钮
            HStack(spacing: 12) {
                ForEach([nil, Holiday.Region.mainland, Holiday.Region.hongKong], id: \.self) { region in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedRegion = region
                        }
                    }) {
                        Text(region?.rawValue ?? "全部")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                            .background(viewModel.selectedRegion == region ? Color.blue : Color(.systemGray6))
                            .foregroundColor(viewModel.selectedRegion == region ? .white : .primary)
                            .clipShape(Capsule())
                            .accessibilityLabel("\(region?.rawValue ?? "全部")地区")
                    }
                }
            }
            .padding(.trailing, 16)
            .frame(width: 220)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

// MARK: - 月份选择器视图
struct MonthSelectorView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        HStack {
            Button(action: viewModel.previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .accessibilityLabel("上个月")
            }
            .padding()
            
            Spacer()
            
            Text("\(String(viewModel.currentYear))年\(viewModel.currentMonth)月")
                .font(.headline)
                .accessibilityLabel("\(viewModel.currentYear)年\(viewModel.currentMonth)月")
            
            Spacer()
            
            Button(action: viewModel.nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .accessibilityLabel("下个月")
            }
            .padding()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 日历网格视图
struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 星期标题
            HStack(spacing: 0) {
                ForEach(viewModel.weekDays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal)
            
            // 日期网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                ForEach(Array(viewModel.daysInMonth().enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: viewModel.isSameDay(date, viewModel.selectedDate),
                            holiday: viewModel.getFilteredHoliday(for: date),
                            onTap: { viewModel.selectedDate = date }
                        )
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 300)
        }
        .id("\(viewModel.currentYear)-\(viewModel.currentMonth)") // 保证月份改变时重新渲染
    }
}

// MARK: - 当月节假日列表视图
struct MonthlyHolidaysView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("当月节假日")
                .font(.headline)
                .padding(.horizontal)
                .accessibilityLabel("当月节假日列表")
            
            let monthHolidays = viewModel.getCurrentMonthHolidays()
            
            if monthHolidays.isEmpty {
                Text("本月暂无节假日")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 12) {
                        ForEach(monthHolidays) { holiday in
                            HolidayInfoCard(holiday: holiday)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 300)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - 日期单元格视图
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let holiday: Holiday?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                
                VStack(spacing: 2) {
                    Text("\(date.dayOfMonth)")
                        .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                        .foregroundColor(holiday != nil ? .red : .primary)
                    
                    if let holiday = holiday {
                        Text(holiday.name)
                            .font(.system(size: 8))
                            .foregroundColor(.red)
                            .lineLimit(1)
                    }
                }
                .padding(4)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(date.year)年\(date.month)月\(date.dayOfMonth)日\(holiday?.name ?? "")")
    }
}

// MARK: - 节假日信息卡片
struct HolidayInfoCard: View {
    let holiday: Holiday
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧日期方块
            VStack(spacing: 0) {
                Text("\(holiday.date.dayOfMonth)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("\(holiday.date.month)月")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .frame(width: 70, height: 70)
            .background(getHolidayColor())
            .cornerRadius(8, corners: [.topLeft, .bottomLeft])
            
            // 右侧信息区域
            VStack(alignment: .leading, spacing: 8) {
                Text(holiday.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(holiday.region.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(getHolidayColor().opacity(0.1))
                        .cornerRadius(4)
                    
                    if holiday.duration > 1 {
                        Text("假期 \(holiday.duration) 天")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(getWeekday(from: holiday.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8, corners: [.topRight, .bottomRight])
        }
        .frame(height: 70)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(holiday.name), \(getWeekday(from: holiday.date)), \(holiday.region.rawValue), \(holiday.duration)天假期")
    }
    
    // 获取节假日颜色
    private func getHolidayColor() -> Color {
        switch holiday.type {
        case .national:
            return .red
        case .traditional:
            return .orange
        case .international:
            return .blue
        case .memorial:
            return .purple
        }
    }
    
    // 获取星期几
    private func getWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

// 扩展View以支持特定角落的圆角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// 自定义形状以实现特定角落的圆角
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    CalendarView()
}
