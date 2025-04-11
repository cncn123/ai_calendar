//
//  HolidayInfoCard.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// MARK: - 节假日信息卡片
struct HolidayInfoCard: View {
    let holiday: Holiday
    var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧日期方块
            VStack(spacing: 0) {
                Text("\(holiday.date.dayOfMonth)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("\(holiday.date.month)月")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .frame(width: 70, height: 70)
            .background(getHolidayColor())
            .cornerRadius(8, corners: [.topLeft, .bottomLeft])
            
            // 右侧信息区域
            VStack(alignment: .leading, spacing: 8) {
                Text(holiday.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(holiday.region.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(getHolidayColor().opacity(0.1))
                        .cornerRadius(4)
                    
                    if holiday.duration > 1 {
                        Text("假期 \(holiday.duration) 天")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(getWeekday(from: holiday.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8, corners: [.topRight, .bottomRight])
        }
        .frame(height: 70)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? getHolidayColor() : Color.clear, lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? getHolidayColor().opacity(0.05) : Color.clear)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(holiday.name), \(getWeekday(from: holiday.date)), \(holiday.region.rawValue), \(holiday.duration)天假期\(isSelected ? ", 当前选中" : "")")
    }
    
    // 获取节假日颜色
    private func getHolidayColor() -> Color {
        switch holiday.region {
        case .mainland:
            return .red
        case .hongKong:
            return .blue
        case.both:
            return.purple
        }
    }
    
    // 获取星期几
    private func getWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}