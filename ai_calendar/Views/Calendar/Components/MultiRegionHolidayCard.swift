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
        .cornerRadius(20)
        .overlay(selectionOverlay)
        .background(
            ZStack {
                // 玻璃质感背景
                RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                    .opacity(0.8)
                
                // 渐变边框
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.hongkongBlue.opacity(0.3),
                                AppColors.mainlandRed.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
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
                    AppColors.hongkongBlue.opacity(0.9),
                    AppColors.mainlandRed.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20, corners: [.topLeft, .bottomLeft])
    }
    
    // 右侧信息区域视图
    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                    Text(hkHoliday.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                // 显示地区标签
                HStack(spacing: 4) {
                    Text("香港")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.hongkongBlue.opacity(0.15),
                                    AppColors.hongkongBlue.opacity(0.05)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundColor(AppColors.hongkongBlue)
                        .cornerRadius(8)
                    
                    Text("内地")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.mainlandRed.opacity(0.15),
                                    AppColors.mainlandRed.opacity(0.05)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundColor(AppColors.mainlandRed)
                        .cornerRadius(8)
                }
            }
            
            HStack {
                // 显示开始日期
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
            
                Text(getWeekday(from: hkHoliday.startDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(20, corners: [.topRight, .bottomRight])
    }
    
    // 选中状态边框
    private var selectionOverlay: some View {
        RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 1.5,
                                dash: [5, 3]
                            )
                        )
            .foregroundColor(isSelected ? AppColors.hongkongBlue : Color.clear)
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