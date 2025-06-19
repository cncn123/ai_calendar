//
//  YearSelectorView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// MARK: - 年份选择器视图
struct YearSelectorView: View {
    @ObservedObject var viewModel: HolidayListViewModel
    @Binding var selectedYear: Int
    
    var body: some View {
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
                    .accessibilityLabel("上一年")
            }
            .padding()
            
            Text("\(String(selectedYear))年")
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityLabel("\(selectedYear)年")
            
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
                    .accessibilityLabel("下一年")
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    YearSelectorView(
        viewModel: HolidayListViewModel(),
        selectedYear: .constant(2024)
    )
} 