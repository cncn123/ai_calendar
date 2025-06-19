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
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
    // 获取距离节假日的描述文本（已融合计算天数和文本描述）
    private func daysUntilHolidayText(_ holiday: Holiday) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let holidayDate = calendar.startOfDay(for: holiday.startDate)
        let days = calendar.dateComponents([.day], from: today, to: holidayDate).day ?? 0

        if days < 0 {
            return "已过去 \(-days) 天"
        } else if days == 0 {
            return "今天"
        } else if days == 1 {
            return "明天"
        } else {
            return "还有 \(days) 天"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 顶部栏
                HolidayHeaderView(viewModel: viewModel)
                
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
            .padding(.vertical)
            .background(
                // 添加渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(colorScheme == .dark ? 0.15 : 0.05),
                        Color.purple.opacity(colorScheme == .dark ? 0.15 : 0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadHolidays(for: selectedYear)
        }
        .onChange(of: selectedYear) { oldValue, newValue in
            viewModel.loadHolidays(for: newValue)
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
                    if holiday.region == .hongkong {
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
        .environmentObject(ThemeManager())
}
