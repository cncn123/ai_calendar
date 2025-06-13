import SwiftUI

// MARK: - 日期单元格视图
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let holiday: Holiday?
    let onTap: () -> Void
    @ObservedObject var viewModel: CalendarViewModel // 添加对viewModel的引用
    
    private func getHolidayColor() -> Color {
        guard let holiday = holiday else {
            return .primary
        }
        
        // 根据假日地区设置不同颜色
        switch holiday.region {
        case .hongkong:
            return AppColors.hongkongBlue
        case .mainland:
            return AppColors.mainlandRed
        }
    }
    
    // 获取选中状态的颜色
    private func getSelectionColor() -> Color {
        if let holiday = holiday {
            switch holiday.region {
            case .hongkong:
                return AppColors.hongkongBlue
            case .mainland:
                return AppColors.mainlandRed
            }
        }
        return Color.blue // 非节假日使用默认蓝色
    }
    
    // 检查是否为多地区节假日
    private var isMultiRegionHoliday: Bool {
        viewModel.hasMultiRegionHolidays(date)
    }
    
    var body: some View {
        Button(action: {
            // 点击日期单元格时执行onTap回调
            onTap()
        }) {
            ZStack {
                // 选中状态显示虚线圆圈
                if isSelected {
                    Circle()
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 1.5,
                                dash: [3, 3]
                            )
                        )
                        .foregroundColor(getSelectionColor())
                }
                
                VStack(spacing: 2) {
                    // 日期数字
                    if isMultiRegionHoliday && viewModel.selectedRegion == nil {
                        // 多地区节假日时使用渐变色文本
                        ZStack {
                            Text("\(date.dayOfMonth)")
                                .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                                .foregroundColor(.clear)
                            
                            // 渐变色蒙版
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.hongkongBlue, AppColors.mainlandRed]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .mask(
                                Text("\(date.dayOfMonth)")
                                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                            )
                        }
                    } else {
                        Text("\(date.dayOfMonth)")
                            .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                            .foregroundColor(holiday != nil ? getHolidayColor() : .primary)
                    }
                    
                    if let holiday = holiday {
                        if isMultiRegionHoliday && viewModel.selectedRegion == nil {
                            // 多地区节假日时，节假日名称用渐变色
                            ZStack {
                                Text(holiday.name)
                                    .font(.system(size: 10))
                                    .foregroundColor(.clear)
                                    .lineLimit(1)
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.hongkongBlue, AppColors.mainlandRed]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text(holiday.name)
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                )
                            }
                        } else {
                            // 单一地区节假日，正常显示
                            Text(holiday.name)
                                .font(.system(size: 10))
                                .foregroundColor(getHolidayColor())
                                .lineLimit(1)
                        }
                    } else if isMultiRegionHoliday && viewModel.selectedRegion == nil {
                        // 多地区节假日时显示特殊提示，使用渐变色
                        ZStack {
                            Text("多地区")
                                .font(.system(size: 8))
                                .foregroundColor(.clear)
                                .lineLimit(1)
                            
                            // 渐变色蒙版
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.hongkongBlue, AppColors.mainlandRed]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .mask(
                                Text("多地区")
                                    .font(.system(size: 8))
                                    .lineLimit(1)
                            )
                        }
                    }
                }
                .padding(4)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(date.year)年\(date.month)月\(date.dayOfMonth)日\(holiday?.name ?? "")\(isMultiRegionHoliday && viewModel.selectedRegion == nil ? " 多地区节假日" : "")")
    }
}
