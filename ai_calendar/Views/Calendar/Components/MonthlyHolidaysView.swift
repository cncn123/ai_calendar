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
            let mainlandHolidays = monthHolidays.filter { $0.region == .mainland }
            let hongKongHolidays = monthHolidays.filter { $0.region == .hongKong }
            
            HStack(spacing: 8) {
                Text("当月节假日")
                    .font(.headline)

                if !hongKongHolidays.isEmpty {
                    Text("\(hongKongHolidays.count)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .clipShape(Capsule())
                }
                
                if !mainlandHolidays.isEmpty {
                    Text("\(mainlandHolidays.count)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
                }
                
            }
            .padding(.horizontal)
            .accessibilityLabel("当月节假日列表，内地\(mainlandHolidays.count)个，香港\(hongKongHolidays.count)个")
            
            if monthHolidays.isEmpty {
                Text("本月暂无节假日")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 12) {
                            ForEach(monthHolidays) { holiday in
                                HolidayInfoCard(
                                    holiday: holiday,
                                    isSelected: viewModel.isSameDay(holiday.date, viewModel.selectedDate)
                                )
                                    .frame(maxWidth: .infinity)
                                    .id("\(holiday.name)_\(holiday.date)") // 使用节假日名称和日期组合作为稳定的id
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.selectedDate) { oldDate, newDate in
                        // 当选中日期变化时，检查是否有对应的节假日
                        if let holiday = viewModel.getFilteredHoliday(for: newDate) {
                            // 延迟一帧以确保布局已完成
                            DispatchQueue.main.async {
                                let holidayId = "\(holiday.name)_\(holiday.date)"
                                // 使用动画效果滚动到对应的节假日卡片
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    // 滚动到对应的节假日卡片，使用center锚点确保完整显示
                                    proxy.scrollTo(holidayId, anchor: .center)
                                }
                            }
                        } else {
                            // print("未找到对应日期的节假日")
                        }
                    }
                }
            }
        }
        .padding(.vertical)
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
