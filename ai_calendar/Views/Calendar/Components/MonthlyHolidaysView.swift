import SwiftUI

// MARK: - 当月节假日列表视图
struct MonthlyHolidaysView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        // 统一外层样式
        VStack(alignment: .leading, spacing: 10) {
            let monthHolidays = viewModel.getCurrentMonthHolidays()
            let regionCounts = calculateRegionCounts(
                holidays: viewModel.getHolidaysForMonth(
                    month: viewModel.currentMonth, year: viewModel.currentYear))

            VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("当月节假日")
                    .font(.title2)
                    .fontWeight(.bold)
                    HStack(spacing: 12) {
                        if regionCounts.hkCount > 0 {
                            HStack(spacing: 4) {
                                Text("香港：\(regionCounts.hkCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppColors.hongkongBlue)
                                    .cornerRadius(4)
                            }
                        }
                        if regionCounts.mainlandCount > 0 {
                            HStack(spacing: 4) {
                                Text("内地：\(regionCounts.mainlandCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppColors.mainlandRed)
                                    .cornerRadius(4)
                            }
                        }
                        if regionCounts.multiRegionDates > 0 && viewModel.selectedRegion == nil {
                            HStack(spacing: 4) {
                                Text("共同：\(regionCounts.multiRegionDates)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [AppColors.hongkongBlue, AppColors.mainlandRed]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .accessibilityLabel(
                    "当月节假日列表，共\(monthHolidays.count)个，其中香港\(regionCounts.hkCount)个，内地\(regionCounts.mainlandCount)个"
                )
            }
            // 统一内容区域样式
            ZStack {
            if monthHolidays.isEmpty {
                    VStack {
                        Spacer(minLength: 24)
                Text("本月暂无节假日")
                    .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer(minLength: 24)
                    }
                    .frame(minHeight: 120) // 保证空时区域不塌陷
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 12) {
                            ForEach(monthHolidays) { holiday in
                                if viewModel.selectedRegion != nil {
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
                                } else {
                                    if viewModel.hasMultiRegionHolidays(holiday.startDate) {
                                        let multiHolidays = viewModel.getHolidaysForMultiRegionCard(date: holiday.startDate)
                                        if let hkHoliday = multiHolidays.hkHoliday, let mlHoliday = multiHolidays.mlHoliday {
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
                        if let holiday = viewModel.getHoliday(for: newDate) {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(holiday.id, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // 玻璃质感背景
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .opacity(0.05)
                    
                    // 渐变边框
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.3),
                                    Color.purple.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    // 计算不同地区节假日数量
    private func calculateRegionCounts(holidays: [Holiday]) -> (hkCount: Int, mainlandCount: Int, multiRegionDates: Int) {
        let hkHolidays = holidays.filter { $0.region == .hongkong }
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
                .previewLayout(.sizeThatFits)
            
            // 预览2：暗黑模式
            MonthlyHolidaysView(viewModel: viewModel)
                .previewDisplayName("暗黑模式")
                .preferredColorScheme(.dark)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
