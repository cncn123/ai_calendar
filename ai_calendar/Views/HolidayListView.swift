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
        VStack(spacing: 8) {
            // 第一行：标题和地区选择器
            HStack {
                Text("节假日一览")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // 地区选择器
                regionSelector
            }
            
            // 第二行：年份选择器
            HStack {
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
                    
                    Spacer()
                    
                    Text("\(String(selectedYear)) 年")
                        .font(.headline)
                        .foregroundColor(Color.blue)
                        .frame(minWidth: 60)
                    
                    Spacer()
                    
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
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // 地区选择器
    private var regionSelector: some View {
        HStack(spacing: 12) {
            // 全部
            Button(action: {
                viewModel.toggleRegion(nil)
            }) {
                Text("全部")
                    .font(.footnote)
                    .fontWeight(viewModel.selectedRegion == nil ? .bold : .regular)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedRegion == nil ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.selectedRegion == nil ? Color.blue : .primary)
                    .cornerRadius(16)
            }
            
            // 香港
            Button(action: {
                viewModel.toggleRegion(.hongKong)
            }) {
                Text("香港")
                    .font(.footnote)
                    .fontWeight(viewModel.isRegionSelected(.hongKong) ? .bold : .regular)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.isRegionSelected(.hongKong) ? AppColors.hongKongBlue.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.isRegionSelected(.hongKong) ? AppColors.hongKongBlue : .primary)
                    .cornerRadius(16)
            }
            
            // 内地
            Button(action: {
                viewModel.toggleRegion(.mainland)
            }) {
                Text("内地")
                    .font(.footnote)
                    .fontWeight(viewModel.isRegionSelected(.mainland) ? .bold : .regular)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.isRegionSelected(.mainland) ? AppColors.mainlandRed.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.isRegionSelected(.mainland) ? AppColors.mainlandRed : .primary)
                    .cornerRadius(16)
            }
        }
    }
    
    // 单个月份区域
    private func monthSection(month: Int) -> some View {
        return VStack(alignment: .leading, spacing: 8) {
            Text("\(month) 月")
                .font(.headline)
                .padding(.top, 8)
            
            let monthHolidays = viewModel.getHolidays(for: month)
            
            if monthHolidays.isEmpty {
                // 没有符合筛选条件的假期
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.top, 4)
                    
                    Text("本月无符合条件的假期")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else {
                ForEach(monthHolidays) { holiday in
                    holidayRow(holiday: holiday)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // 节假日行
    private func holidayRow(holiday: Holiday) -> some View {
        // 如果同一天有香港和内地假期，使用多地区卡片
        if viewModel.hasMultiRegionHoliday(date: holiday.startDate) {
            let multiHolidays = viewModel.getMultiRegionHolidays(for: holiday.startDate)
            
            // 当地区选择器设置为"全部"时，使用多地区卡片
            if viewModel.selectedRegion == nil {
                if let hkHoliday = multiHolidays.hkHoliday, 
                   let mlHoliday = multiHolidays.mlHoliday {
                    // 仅处理一次多地区假日 - 检查是否为香港假日
                    if holiday.region == .hongKong {
                        return AnyView(MultiRegionHolidayCard(
                            hkHoliday: hkHoliday,
                            mlHoliday: mlHoliday
                        ))
                    } else {
                        return AnyView(EmptyView()) // 对于内地假日在重复的情况下不显示
                    }
                }
            } else {
                // 当地区选择器设置为特定地区时，显示该地区的假日卡片
                return AnyView(HolidayInfoCard(holiday: holiday))
            }
        }
        
        // 默认情况：显示单个假日卡片
        return AnyView(HolidayInfoCard(holiday: holiday))
    }
}

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
        
        let hkHoliday = holidaysOnDate.first { $0.region == .hongKong }
        let mlHoliday = holidaysOnDate.first { $0.region == .mainland }
        
        return (hkHoliday, mlHoliday)
    }
}

#Preview {
    HolidayListView()
}