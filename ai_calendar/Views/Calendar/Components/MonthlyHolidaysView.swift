//
//  MonthlyHolidaysView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

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
                ScrollViewReader { proxy in
                    VStack {
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(spacing: 12) {
                                ForEach(monthHolidays) { holiday in
                                    HolidayInfoCard(
                                        holiday: holiday,
                                        isSelected: viewModel.isSameDay(holiday.date, viewModel.selectedDate)
                                    )
                                        .frame(maxWidth: .infinity)
                                        .id(holiday.id) // 为每个节假日设置唯一 ID
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                        .onChange(of: viewModel.selectedDate) { newDate in
                            // 当选中日期变化时，检查是否有对应的节假日
                            if let holiday = viewModel.getFilteredHoliday(for: newDate) {
                                // 打印日志
                                print("选中日期：\(newDate)，对应的节假日：\(holiday.name), holiday.id: \(holiday.id)")
                                // 延迟一帧以确保布局已完成
                                DispatchQueue.main.async {
                                    // 使用动画效果滚动到对应的节假日卡片
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        // 滚动到对应的节假日卡片，使用center锚点确保完整显示
                                        proxy.scrollTo(holiday.id, anchor: .center)
                                        print("滚动到了 \(holiday.id)")
                                        print("对应的节假日：\(holiday.name), holiday.id: \(holiday.id)")
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
        .padding(.vertical)
    }
}
