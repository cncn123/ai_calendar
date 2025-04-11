//
//  MonthSelectorView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// MARK: - 月份选择器视图
struct MonthSelectorView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        HStack {
            Button(action: viewModel.previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .accessibilityLabel("上个月")
            }
            .padding()
            
            Spacer()
            
            Text("\(String(viewModel.currentYear))年\(viewModel.currentMonth)月")
                .font(.headline)
                .accessibilityLabel("\(viewModel.currentYear)年\(viewModel.currentMonth)月")
            
            Spacer()
            
            Button(action: viewModel.nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .accessibilityLabel("下个月")
            }
            .padding()
        }
        .padding(.vertical, 8)
    }
}