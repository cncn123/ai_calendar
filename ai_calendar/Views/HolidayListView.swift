//
//  HolidayListView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

struct HolidayListView: View {
    @StateObject private var viewModel = HolidayListViewModel()
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            titleBar
            
            // 节假日列表
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(1...12, id: \.self) { month in
                        monthSection(month: month)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .onAppear {
            viewModel.loadHolidays(for: selectedYear)
        }
        .onChange(of: selectedYear) { newYear in
            viewModel.loadHolidays(for: newYear)
        }
    }
    
    // 标题栏
    private var titleBar: some View {
        HStack {
            Text("节假日一览")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            // 年份选择器 - 左右箭头切换
            HStack(spacing: 12) {
                Button(action: {
                    if let minYear = viewModel.supportedYears.min(),
                       selectedYear > minYear {
                        selectedYear -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(
                            selectedYear > (viewModel.supportedYears.min() ?? 0) ? 
                            Color.blue : Color.blue.opacity(0.3)
                        )
                        .padding(4)
                }
                
                Text("\(String(selectedYear)) 年")
                    .font(.headline)
                    .foregroundColor(Color.blue)
                    .frame(minWidth: 60)
                
                Button(action: {
                    if let maxYear = viewModel.supportedYears.max(),
                       selectedYear < maxYear {
                        selectedYear += 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(
                            selectedYear < (viewModel.supportedYears.max() ?? 0) ? 
                            Color.blue : Color.blue.opacity(0.3)
                        )
                        .padding(4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // 单个月份区域
    private func monthSection(month: Int) -> some View {
        let holidays = viewModel.getHolidays(for: month)
        
        return VStack(alignment: .leading, spacing: 12) {
            if !holidays.isEmpty {
                // 月份标题
                HStack {
                    Text("\(month)月")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.vertical, 4)
                    
                    // 地区标签
                    let hkCount = holidays.filter { $0.region == .hongKong }.count
                    let mlCount = holidays.filter { $0.region == .mainland }.count
                    
                    HStack(spacing: 8) {
                        if hkCount > 0 {
                            Text("香港: \(hkCount)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.hongKongBlue.opacity(0.2))
                                .foregroundColor(AppColors.hongKongBlue)
                                .cornerRadius(4)
                        }
                        
                        if mlCount > 0 {
                            Text("内地: \(mlCount)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.mainlandRed.opacity(0.2))
                                .foregroundColor(AppColors.mainlandRed)
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                }
                
                // 节假日列表
                ForEach(holidays) { holiday in
                    // 如果同一天有香港和内地假期，使用多地区卡片
                    if viewModel.hasMultiRegionHoliday(date: holiday.startDate) {
                        let multiHolidays = viewModel.getMultiRegionHolidays(for: holiday.startDate)
                        if let hkHoliday = multiHolidays.hkHoliday, 
                           let mlHoliday = multiHolidays.mlHoliday {
                            // 仅处理一次多地区假日 - 检查是否为香港假日
                            if holiday.region == .hongKong {
                                MultiRegionHolidayCard(
                                    hkHoliday: hkHoliday,
                                    mlHoliday: mlHoliday
                                )
                            }
                        } else {
                            HolidayInfoCard(holiday: holiday)
                        }
                    } else {
                        HolidayInfoCard(holiday: holiday)
                    }
                }
            }
        }
    }
}

// MARK: - 节假日列表视图模型
class HolidayListViewModel: ObservableObject {
    @Published var holidays: [Holiday] = []
    
    private let holidayService = HolidayService.shared
    
    // 支持的年份
    var supportedYears: [Int] {
        Array(holidayService.supportedYears)
    }
    
    // 加载指定年份的假期
    func loadHolidays(for year: Int) {
        holidays = holidayService.holidays(for: year)
    }
    
    // 获取指定月份的假期
    func getHolidays(for month: Int) -> [Holiday] {
        let monthHolidays = holidays.filter { $0.startDate.month == month }
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
        
        let hkHoliday = holidaysOnDate.first { $0.region == .hongKong }
        let mlHoliday = holidaysOnDate.first { $0.region == .mainland }
        
        return (hkHoliday, mlHoliday)
    }
}

#Preview {
    HolidayListView()
}