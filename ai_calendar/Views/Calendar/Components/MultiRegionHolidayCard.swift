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
            infoBlock.frame(height: 70)
        }
        .frame(height: 70)
        .cornerRadius(16)
        .overlay(selectionOverlay)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(createAccessibilityLabel())
    }
    
    // 左侧日期方块视图 - 使用渐变背景
    private var dateBlock: some View {
        VStack(spacing: 0) {
            Text("\(hkHoliday.startDate.month)月")
                .font(.system(size: 14))
                .foregroundColor(.white)
            Text("\(hkHoliday.startDate.dayOfMonth)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 70, height: 70)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.hongkongBlue.opacity(0.85),
                    AppColors.mainlandRed.opacity(0.85)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16, corners: [.topLeft, .bottomLeft])
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppColors.hongkongBlue.opacity(0.12))
                        .foregroundColor(AppColors.hongkongBlue)
                        .cornerRadius(8)
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppColors.mainlandRed.opacity(0.12))
                        .foregroundColor(AppColors.mainlandRed)
                        .cornerRadius(8)
                }
            }
            
            HStack {
                // 显示日期信息
                Text(formatDate(hkHoliday.startDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                Spacer()
                
                // 显示距离天数
                if let daysUntilText = daysUntilText {
                    Text(daysUntilText)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        .background(.ultraThinMaterial)
        .cornerRadius(16, corners: [.topRight, .bottomRight])
    }
    
    // 选中状态边框 - 使用渐变虚线
    private var selectionOverlay: some View {
        ZStack {
            if isSelected {
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.hongkongBlue.opacity(0.7),
                        AppColors.mainlandRed.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 1.5,
                                dash: [5, 3]
                            )
                        )
                )
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.clear, lineWidth: 0)
            }
        }
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