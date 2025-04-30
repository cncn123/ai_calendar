//
//  MultiRegionHolidayCard.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// MARK: - 多地区节假日卡片
struct MultiRegionHolidayCard: View {
    let hkHoliday: Holiday  // 香港节假日
    let mlHoliday: Holiday  // 内地节假日
    var isSelected: Bool = false
    var daysUntilText: String? = nil
    
    // 计算假期天数
    private var duration: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: hkHoliday.startDate, to: hkHoliday.endDate)
        return (components.day ?? 0) + 1
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧日期方块 - 使用渐变背景
            dateBlock
            
            // 右侧信息区域
            infoBlock
        }
        .frame(height: 70)  // 稍微增加高度以适应多行内容
        .cornerRadius(8)
        .overlay(selectionOverlay)
        .background(selectionBackground)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(createAccessibilityLabel())
    }
    
    // 左侧日期方块视图 - 使用渐变背景
    private var dateBlock: some View {
        VStack(spacing: 0) {
            Text("\(hkHoliday.startDate.dayOfMonth)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text("\(hkHoliday.startDate.month)月")
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .frame(width: 70, height: 70)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppColors.hongKongBlue, AppColors.mainlandRed]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(8, corners: [.topLeft, .bottomLeft])
    }
    
    // 右侧信息区域视图
    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 节假日名称区域 - 香港和内地节假日并排显示
            HStack(spacing: 6) {
                // 香港节假日信息
                HStack(spacing: 4) {
                    Text(hkHoliday.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // 香港标签
                    Text(hkHoliday.region.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(AppColors.hongKongBlue.opacity(0.2))
                        .foregroundColor(AppColors.hongKongBlue)
                        .cornerRadius(4)
                }
                
                Spacer(minLength: 8)
                
                // 内地节假日信息
                HStack(spacing: 4) {
                    Text(mlHoliday.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // 内地标签
                    Text(mlHoliday.region.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(AppColors.mainlandRed.opacity(0.2))
                        .foregroundColor(AppColors.mainlandRed)
                        .cornerRadius(4)
                }
            }
            
            HStack {
                // 显示日期信息
                Text(formatDate(hkHoliday.startDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                Spacer()
                
                // 显示距离天数
                if let daysUntilText = daysUntilText {
                    Text(daysUntilText)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.hongKongBlue.opacity(0.1), AppColors.mainlandRed.opacity(0.1)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(4)
                }
                
                Spacer()
            
                // 显示星期几
                Text(getWeekday(from: hkHoliday.startDate))
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
    
    // 选中状态边框 - 使用渐变虚线
    private var selectionOverlay: some View {
        ZStack {
            if isSelected {
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.hongKongBlue, AppColors.mainlandRed]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 1.5,
                                dash: [5, 3]
                            )
                        )
                )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.clear, lineWidth: 0)
            }
        }
    }
    
    // 选中状态背景 - 保持透明
    private var selectionBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.clear)
    }
    
    // 创建无障碍标签
    private func createAccessibilityLabel() -> String {
        let weekday = getWeekday(from: hkHoliday.startDate)
        let durationText = "\(duration)天假期"
        let selectedStatus = isSelected ? ", 当前选中" : ""
        let daysUntilStatus = daysUntilText.map { ", \($0)" } ?? ""
        
        return "多地区节假日，香港：\(hkHoliday.name)，内地：\(mlHoliday.name)，\(weekday)，\(durationText)\(daysUntilStatus)\(selectedStatus)"
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