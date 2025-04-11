//
//  DayCell.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// MARK: - 日期单元格视图
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let holiday: Holiday?
    let onTap: () -> Void
    
    private func getHolidayColor(for holiday: Holiday) -> Color {
        switch holiday.region {
        case .mainland:
            return .red
        case .hongKong:
            return .blue
        case .both:
            return .purple
        }
    }
    
    var body: some View {
        Button(action: {
            // 点击日期单元格时执行onTap回调
            onTap()
        }) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                
                VStack(spacing: 2) {
                    Text("\(date.dayOfMonth)")
                        .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                        .foregroundColor(holiday != nil ? getHolidayColor(for: holiday!) : .primary)
                    
                    if let holiday = holiday {
                        Text(holiday.name)
                            .font(.system(size: 8))
                            .foregroundColor(getHolidayColor(for: holiday))
                            .lineLimit(1)
                    }
                }
                .padding(4)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(date.year)年\(date.month)月\(date.dayOfMonth)日\(holiday?.name ?? "")")
    }
}