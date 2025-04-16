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
    
    // 计算假期天数
    private var duration: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: holiday.startDate, to: holiday.endDate)
        return (components.day ?? 0) + 1
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧日期方块
            dateBlock
            
            // 右侧信息区域
            infoBlock
        }
        .frame(height: 70)
        .cornerRadius(8)
        .overlay(selectionOverlay)
        .background(selectionBackground)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(createAccessibilityLabel())
    }
    
    // 左侧日期方块视图
    private var dateBlock: some View {
        VStack(spacing: 0) {
            Text("\(holiday.startDate.dayOfMonth)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text("\(holiday.startDate.month)月")
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .frame(width: 70, height: 70)
        .background(getHolidayColor())
        .cornerRadius(8, corners: [.topLeft, .bottomLeft])
    }
    
    // 右侧信息区域视图
    private var infoBlock: some View {
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
                
                if duration > 1 {
                    Text("\(formatDate(holiday.startDate)) - \(formatDate(holiday.endDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(formatDate(holiday.startDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(getWeekday(from: holiday.startDate))
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
    
    // 选中状态边框
    private var selectionOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(isSelected ? getHolidayColor() : Color.clear, lineWidth: 2)
    }
    
    // 选中状态背景
    private var selectionBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isSelected ? getHolidayColor().opacity(0.05) : Color.clear)
    }
    
    // 创建无障碍标签
    private func createAccessibilityLabel() -> String {
        let weekday = getWeekday(from: holiday.startDate)
        let region = holiday.region.rawValue
        let durationText = "\(duration)天假期"
        let selectedStatus = isSelected ? ", 当前选中" : ""
        
        return "\(holiday.name), \(weekday), \(region), \(durationText)\(selectedStatus)"
    }
    
    // 获取节假日颜色
    private func getHolidayColor() -> Color {
        switch holiday.region {
        case .mainland:
            return .red
        case .hongKong:
            return .blue
        case .both:
            return .purple
        }
    }
    
    // 获取星期几
    private func getWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}