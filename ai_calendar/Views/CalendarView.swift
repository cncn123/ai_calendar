//
//  CalendarView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI
import Foundation

// 导入TabBarButton组件

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    @State private var showingRegionFilter = false
    @State private var selectedRegion: Holiday.Region? = nil
    
    private let weekDays = ["日", "一", "二", "三", "四", "五", "六"]
    private let holidayService = HolidayService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部栏和地区选择栏（合并在同一行）
                HStack {
                    Text("节假日日历")
                        .font(.headline)
                        .padding(.leading)

                    Spacer()
                    
                    // 地区选择按钮
                    HStack(spacing: 12) {
                        ForEach([nil, Holiday.Region.mainland, Holiday.Region.hongKong], id: \.self) { region in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedRegion = region
                                }
                            }) {
                                Text(region?.rawValue ?? "全部")
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .frame(height: 36)
                                    .background(selectedRegion == region ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(selectedRegion == region ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.trailing, 16)
                    .frame(width: 220)
                }
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                
                // 月份选择器
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("\(String(currentYear))年\(currentMonth)月")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // 星期标题
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
                
                // 日历网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            DayCell(date: date, isSelected: isSameDay(date, selectedDate), holiday: getFilteredHoliday(for: date))
                                .onTapGesture {
                                    selectedDate = date
                                }
                        } else {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 300) // 设置日历网格的固定高度
                
                // 选中日期的节假日信息
                if let holiday = getFilteredHoliday(for: selectedDate) {
                    HolidayInfoCard(holiday: holiday)
                        .padding()
                        .transition(.move(edge: .bottom))
                }
                
                // 当月所有节假日卡片
                VStack(alignment: .leading, spacing: 10) {
                    Text("当月节假日")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.vertical) {
                        let monthHolidays = getCurrentMonthHolidays()
                        
                        if monthHolidays.isEmpty {
                            Text("本月暂无节假日")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(monthHolidays, id: \.id) { holiday in
                                    HolidayInfoCard(holiday: holiday)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxHeight: 300) // 设置最大高度，避免占用过多空间
                }
                .padding(.vertical)
                
                Spacer()
                
            }
            .navigationBarHidden(true)
        }
    }
    
    // 获取当月的所有日期
    private func daysInMonth() -> [Date?] {
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
        
        return days
    }
    
    private func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
    }
    
    private func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // 根据选择的地区过滤节假日
    private func getFilteredHoliday(for date: Date) -> Holiday? {
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
    private func getCurrentMonthHolidays() -> [Holiday] {
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

// 日期单元格
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let holiday: Holiday?
    
    var body: some View {
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
}

// 节假日信息卡片
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
    }
    
    // 获取节假日颜色
    private func getHolidayColor() -> Color {
        switch holiday.region {
        case .mainland:
            return .red
        case .hongKong:
            return .blue
        case .both:
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

// 底部标签按钮

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
