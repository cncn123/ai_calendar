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
    @State private var preloadedHolidays: [Int: [Holiday]] = [:] // 预加载的节假日数据
    @State private var isLoading: Bool = false // 加载状态
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
    
    // 异步预加载指定年份的所有月份数据
    private func preloadYearData(for year: Int) {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 在后台线程处理数据
            var newPreloadedHolidays: [Int: [Holiday]] = [:]
            let allHolidays = viewModel.holidays
            
            // 按月份分组
            for month in 1...12 {
                let monthHolidays = allHolidays.filter { $0.startDate.month == month }
                
                // 根据所选地区过滤
                if let region = viewModel.selectedRegion {
                    newPreloadedHolidays[month] = monthHolidays.filter { $0.region == region }.sorted { $0.startDate < $1.startDate }
                } else {
                    newPreloadedHolidays[month] = monthHolidays.sorted { $0.startDate < $1.startDate }
                }
            }
            
            // 回到主线程更新UI
            DispatchQueue.main.async {
                preloadedHolidays = newPreloadedHolidays
                isLoading = false
            }
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
                    if isLoading {
                        // 加载状态
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .padding()
                            
                            Text("正在加载节假日数据...")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(1...12, id: \.self) { month in
                                monthSection(month: month)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.vertical)
            .background(
                // iOS 16 风格的液体玻璃效果背景
                Group {
                    if colorScheme == .dark {
                        // 暗黑模式液体玻璃效果
                        ZStack {
                            // 深色基础渐变背景
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#1A1A2E").opacity(0.9),
                                    Color(hex: "#16213E").opacity(0.8),
                                    Color(hex: "#0F3460").opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // 深色液体玻璃光斑效果
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#2D1B69").opacity(0.4),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 400
                            )
                            .blur(radius: 20)
                            
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#1B3B6F").opacity(0.3),
                                    Color.clear
                                ]),
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 350
                            )
                            .blur(radius: 15)
                            
                            // 深色微妙光斑
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#0F4C75").opacity(0.2),
                                    Color.clear
                                ]),
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 300
                            )
                            .blur(radius: 25)
                            
                            // 深色液体玻璃纹理层
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.05),
                                            Color.clear,
                                            Color.white.opacity(0.02)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .blur(radius: 1)
                        }
                    } else {
                        // 亮色模式液体玻璃效果
                        ZStack {
                            // 基础渐变背景
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#F0F8FF").opacity(0.8),
                                    Color(hex: "#E6F3FF").opacity(0.6),
                                    Color(hex: "#F5F0FF").opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // 液体玻璃光斑效果
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 400
                            )
                            .blur(radius: 20)
                            
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#E8F4FD").opacity(0.4),
                                    Color.clear
                                ]),
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 350
                            )
                            .blur(radius: 15)
                            
                            // 微妙的色彩光斑
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#F0E6FF").opacity(0.3),
                                    Color.clear
                                ]),
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 300
                            )
                            .blur(radius: 25)
                            
                            // 液体玻璃纹理层
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear,
                                            Color.white.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .blur(radius: 1)
                        }
                    }
                }
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadHolidays(for: selectedYear)
            preloadYearData(for: selectedYear)
        }
        .onChange(of: selectedYear) { oldValue, newValue in
            viewModel.loadHolidays(for: newValue)
            preloadYearData(for: newValue)
        }
        .onChange(of: viewModel.selectedRegion) { _, _ in
            // 当地区选择改变时，重新预加载数据
            preloadYearData(for: selectedYear)
        }
    }
    
    // 单个月份区域
    @ViewBuilder
    private func monthSection(month: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(month) 月")
                .font(.title3)
                .padding(.top, 8)
            
            let monthHolidays = preloadedHolidays[month] ?? []
            
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
        .background(
            ZStack {
                // 玻璃质感背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.05)
                
                // 渐变边框
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
    
    // 节假日行
    @ViewBuilder
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
                        MultiRegionHolidayCard(
                            hkHoliday: hkHoliday,
                            mlHoliday: mlHoliday,
                            daysUntilText: daysUntilHolidayText(holiday)
                        )
                    }
                    // 对于内地假日在重复的情况下不显示
                }
            } else {
                // 当地区选择器设置为特定地区时，显示该地区的假日卡片
                HolidayInfoCard(
                    holiday: holiday,
                    daysUntilText: daysUntilHolidayText(holiday)
                )
            }
        } else {
            // 默认情况：显示单个假日卡片
            HolidayInfoCard(
                holiday: holiday,
                daysUntilText: daysUntilHolidayText(holiday)
            )
        }
    }
}

#Preview {
    HolidayListView()
        .environmentObject(ThemeManager())
}
