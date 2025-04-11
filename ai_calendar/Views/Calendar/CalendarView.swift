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
                // 顶部栏
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
        }
    }
}

#Preview {
    CalendarView()
}