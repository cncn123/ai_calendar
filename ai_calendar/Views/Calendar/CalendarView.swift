//
//  CalendarView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI
import Foundation

// MARK: - 主日历视图
struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部栏 - 包含标题和地区选择器
                CalendarHeaderView(viewModel: viewModel)
                
                // 月份选择器
                MonthSelectorView(viewModel: viewModel)
                
                // 日历内容
                CalendarGridView(viewModel: viewModel)
                
                // 当月所有节假日卡片
                MonthlyHolidaysView(viewModel: viewModel)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .animation(.easeInOut, value: viewModel.selectedDate)
            .animation(.easeInOut, value: viewModel.selectedRegion)
            .onAppear {
                // 清除缓存并重新加载数据
                HolidayService.shared.clearCache()
                viewModel.loadHolidays()
            }
            // 监听月份变化
            .onChange(of: viewModel.currentMonth) { _, _ in
                viewModel.refreshMonthHolidays()
            }
            // 监听年份变化
            .onChange(of: viewModel.currentYear) { _, _ in
                viewModel.refreshMonthHolidays()
            }
            // 监听地区筛选变化
            .onChange(of: viewModel.selectedRegion) { _, _ in
                viewModel.refreshMonthHolidays()
            }
        }
    }
}

#Preview {
    CalendarView()
}