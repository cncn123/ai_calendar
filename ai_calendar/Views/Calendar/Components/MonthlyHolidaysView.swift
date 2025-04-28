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
            let monthHolidays = viewModel.getCurrentMonthHolidays()
            
            // 计算分地区节假日数量
            let regionCounts = calculateRegionCounts(
                holidays: viewModel.getHolidaysForMonth(
                    month: viewModel.currentMonth, year: viewModel.currentYear))

            VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("当月节假日")
                    .font(.title2)
                    .fontWeight(.bold)
                    // 地区节假日数量显示
                    HStack(spacing: 12) {
                        if regionCounts.hkCount > 0 {
                            HStack(spacing: 4) {
                                Text("香港：\(regionCounts.hkCount)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.hongKongBlue)
                                    .clipShape(Capsule())
                            }
                        }

                        if regionCounts.mainlandCount > 0 {
                            HStack(spacing: 4) {
                                Text("内地：\(regionCounts.mainlandCount)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.mainlandRed)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        if regionCounts.multiRegionDates > 0 && viewModel.selectedRegion == nil {
                            HStack(spacing: 4) {
                                Text("共同：\(regionCounts.multiRegionDates)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [AppColors.hongKongBlue, AppColors.mainlandRed]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                        .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .accessibilityLabel(
                    "当月节假日列表，共\(monthHolidays.count)个，其中香港\(regionCounts.hkCount)个，内地\(regionCounts.mainlandCount)个"
                )

            }
            
            if monthHolidays.isEmpty {
                Text("本月暂无节假日")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 12) {
                            // 打印调试信息
                            let _ = print(
                                "当前显示节假日: \(monthHolidays.map { "\($0.name)(\($0.region.rawValue))" }.joined(separator: ", "))"
                            )

                            ForEach(monthHolidays) { holiday in
                                // 如果选择了特定地区，直接显示对应节假日
                                if viewModel.selectedRegion != nil {
                                HolidayInfoCard(
                                    holiday: holiday,
                                        isSelected: viewModel.isSameDay(
                                            holiday.startDate, viewModel.selectedDate)
                                )
                                    .frame(maxWidth: .infinity)
                                    .id("\(holiday.id)")  // 使用节假日唯一ID作为视图ID
                                    .onTapGesture {
                                        // 点击节假日卡片时更新选中日期
                                        withAnimation {
                                            viewModel.selectedDate = holiday.startDate
                                        }
                                    }
                                } else {
                                    // 在"全部"状态下，检查是否为多地区节假日
                                    if viewModel.hasMultiRegionHolidays(holiday.startDate) {
                                        // 获取多地区节假日数据
                                        let multiHolidays = viewModel.getHolidaysForMultiRegionCard(date: holiday.startDate)
                                        
                                        // 确保两个地区的节假日都存在
                                        if let hkHoliday = multiHolidays.hkHoliday, let mlHoliday = multiHolidays.mlHoliday {
                                            // 显示合并的多地区节假日卡片
                                            MultiRegionHolidayCard(
                                                hkHoliday: hkHoliday,
                                                mlHoliday: mlHoliday,
                                                isSelected: viewModel.isSameDay(
                                                    holiday.startDate, viewModel.selectedDate)
                                            )
                                            .frame(maxWidth: .infinity)
                                            .id("multi_\(holiday.startDate.formattedForID)")
                                            .onTapGesture {
                                                withAnimation {
                                                    viewModel.selectedDate = holiday.startDate
                                                }
                                            }
                                        } else {
                                            // 降级处理：如果意外缺少某个地区的节假日数据
                                            HolidayInfoCard(
                                                holiday: holiday,
                                                isSelected: viewModel.isSameDay(
                                                    holiday.startDate, viewModel.selectedDate)
                                            )
                                            .frame(maxWidth: .infinity)
                                            .id("\(holiday.id)")
                                            .onTapGesture {
                                                withAnimation {
                                                    viewModel.selectedDate = holiday.startDate
                                                }
                                            }
                                        }
                                    } else {
                                        // 普通单一地区节假日卡片
                                        HolidayInfoCard(
                                            holiday: holiday,
                                            isSelected: viewModel.isSameDay(
                                                holiday.startDate, viewModel.selectedDate)
                                        )
                                        .frame(maxWidth: .infinity)
                                        .id("\(holiday.id)")
                                        .onTapGesture {
                                            withAnimation {
                                                viewModel.selectedDate = holiday.startDate
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.selectedDate) { oldDate, newDate in
                        // 当选中日期变化时，检查是否有对应的节假日
                        if let holiday = viewModel.getHoliday(for: newDate) {
                            // 延迟一帧以确保布局已完成
                            DispatchQueue.main.async {
                                // 使用动画效果滚动到对应的节假日卡片
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    // 滚动到对应的节假日卡片，使用center锚点确保完整显示
                                    proxy.scrollTo(holiday.id, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }

    // 计算不同地区节假日数量
    private func calculateRegionCounts(holidays: [Holiday]) -> (hkCount: Int, mainlandCount: Int, multiRegionDates: Int) {
        let hkHolidays = holidays.filter { $0.region == .hongKong }
        let mainlandHolidays = holidays.filter { $0.region == .mainland }
        
        // 计算多地区节假日的日期数量
        var multiRegionDatesCount = 0
        if viewModel.selectedRegion == nil {
            // 按日期分组统计节假日
            let _ = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let allDatesWithHolidays = Set(holidays.map { dateFormatter.string(from: $0.startDate) })
            
            // 检查每个日期是否有多个地区的节假日
            for dateString in allDatesWithHolidays {
                if let date = dateFormatter.date(from: dateString),
                   viewModel.hasMultiRegionHolidays(date) {
                    multiRegionDatesCount += 1
                }
            }
        }
        
        return (hkHolidays.count, mainlandHolidays.count, multiRegionDatesCount)
    }
}

// MARK: - 预览提供者
#if DEBUG
struct MonthlyHolidaysView_Previews: PreviewProvider {
    static var previews: some View {
        // 创建模拟的CalendarViewModel
        let viewModel = CalendarViewModel()
        
        // 设置当前日期为预览日期
        return Group {
            // 预览1：默认状态
            MonthlyHolidaysView(viewModel: viewModel)
                .previewDisplayName("默认状态")
                .preferredColorScheme(.light)
                .padding()
                .background(Color(.systemBackground))
                .previewLayout(.sizeThatFits)
            
            // 预览2：暗黑模式
            MonthlyHolidaysView(viewModel: viewModel)
                .previewDisplayName("暗黑模式")
                .preferredColorScheme(.dark)
                .padding()
                .background(Color(.systemBackground))
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
