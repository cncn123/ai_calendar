//
//  CalendarGridView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

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
                        .font(.headline)
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
                            holiday: viewModel.getHoliday(for: date),
                            onTap: { viewModel.selectedDate = date },
                            viewModel: viewModel
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
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6).opacity(0.8))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
