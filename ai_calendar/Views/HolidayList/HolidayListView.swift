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
    
    // 计算距离节假日的天数
    private func daysUntilHoliday(_ holiday: Holiday) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let holidayDate = holiday.startDate
        
        // 如果假期已经过去，计算到明年同一天的天数
        if holidayDate < today {
            let nextYear = calendar.component(.year, from: today) + 1
            var components = calendar.dateComponents([.month, .day], from: holidayDate)
            components.year = nextYear
            if let nextHolidayDate = calendar.date(from: components) {
                return calendar.dateComponents([.day], from: today, to: nextHolidayDate).day ?? 0
            }
        }
        
        return calendar.dateComponents([.day], from: today, to: holidayDate).day ?? 0
    }
    
    // 获取距离节假日的描述文本
    private func daysUntilHolidayText(_ holiday: Holiday) -> String {
        let calendar = Calendar.current
        let today = Date()
        let holidayDate = holiday.startDate
        
        // 如果假期已经过去
        if holidayDate < today {
            let daysPassed = abs(calendar.dateComponents([.day], from: holidayDate, to: today).day ?? 0)
            return "已过去 \(daysPassed) 天"
        }
        
        // 如果假期还未到来
        let days = calendar.dateComponents([.day], from: today, to: holidayDate).day ?? 0
        if days == 0 {
            return "今天"
        } else if days == 1 {
            return "明天"
        } else {
            return "还有 \(days) 天"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HolidayHeaderView(viewModel: viewModel)
                .padding(.top, 8)
            
            // 年份选择器
            YearSelectorView(viewModel: viewModel, selectedYear: $selectedYear)
            
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
    
    // 单个月份区域
    private func monthSection(month: Int) -> some View {
        return VStack(alignment: .leading, spacing: 8) {
            Text("\(month) 月")
                .font(.title3)
                .padding(.top, 8)
            
            let monthHolidays = viewModel.getHolidays(for: month)
            
            if monthHolidays.isEmpty {
                // 没有符合筛选条件的假期
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.top, 4)
                    
                    Text("本月无符合条件的假期")
                        .font(.body)
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
                            mlHoliday: mlHoliday,
                            daysUntilText: daysUntilHolidayText(holiday)
                        ))
                    } else {
                        return AnyView(EmptyView()) // 对于内地假日在重复的情况下不显示
                    }
                }
            } else {
                // 当地区选择器设置为特定地区时，显示该地区的假日卡片
                return AnyView(HolidayInfoCard(
                    holiday: holiday,
                    daysUntilText: daysUntilHolidayText(holiday)
                ))
            }
        }
        
        // 默认情况：显示单个假日卡片
        return AnyView(HolidayInfoCard(
            holiday: holiday,
            daysUntilText: daysUntilHolidayText(holiday)
        ))
    }
}

#Preview {
    HolidayListView()
}
