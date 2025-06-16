import SwiftUI

// MARK: - 节假日信息卡片
struct HolidayInfoCard: View {
    let holiday: Holiday
    var isSelected: Bool = false
    var daysUntilText: String? = nil
    
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
        .cornerRadius(20)
        .overlay(selectionOverlay)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(createAccessibilityLabel())
    }
    
    // 左侧日期方块视图
    private var dateBlock: some View {
        VStack(spacing: 0) {
            Text("\(holiday.startDate.month)月")
                .font(.system(size: 14))
                .foregroundColor(.white)
            Text("\(holiday.startDate.dayOfMonth)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 70, height: 70)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    getHolidayColor().opacity(0.9),
                    getHolidayColor().opacity(0.7)
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
                Text(holiday.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // 显示地区标签
                Text(holiday.region.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                getHolidayColor().opacity(0.2),
                                getHolidayColor().opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                getHolidayColor(),
                                getHolidayColor().opacity(0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(8)
            }
            
            HStack {
                // 显示开始日期
                Text(formatDate(holiday.startDate))
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
                
                Text(getWeekday(from: holiday.startDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Color(.systemBackground)
                    .opacity(0.8)
                
                // 添加微妙的渐变叠加
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .cornerRadius(20, corners: [.topRight, .bottomRight])
    }
    
    // 选中状态边框
    private var selectionOverlay: some View {
        RoundedRectangle(cornerRadius: 24)
            .strokeBorder(
                style: StrokeStyle(
                    lineWidth: 1.5,
                    dash: [5, 3]
                )
            )
            .foregroundColor(isSelected ? getHolidayColor() : Color.clear)
    }
    
    // 创建无障碍标签
    private func createAccessibilityLabel() -> String {
        let weekday = getWeekday(from: holiday.startDate)
        let durationText = "\(duration)天假期"
        let selectedStatus = isSelected ? ", 当前选中" : ""
        let daysUntilStatus = daysUntilText.map { ", \($0)" } ?? ""
        
        return "\(holiday.name), \(holiday.region.rawValue), \(weekday), \(durationText)\(daysUntilStatus)\(selectedStatus)"
    }
    
    // 获取节假日颜色
    private func getHolidayColor() -> Color {
        // 根据假日地区设置不同颜色
        switch holiday.region {
        case .hongkong:
            return AppColors.hongkongBlue
        case .mainland:
            return AppColors.mainlandRed
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

// MARK: - 预览
#Preview {
    VStack(spacing: 20) {
        // 香港节假日预览
        HolidayInfoCard(
            holiday: Holiday(
                id: "preview_hk_1",
                name: "元旦",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400),
                region: HolidayRegion.hongkong
            ),
            daysUntilText: "还有3天"
        )
        
        // 内地节假日预览
        HolidayInfoCard(
            holiday: Holiday(
                id: "preview_ml_1",
                name: "春节",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 7),
                region: HolidayRegion.mainland
            ),
            isSelected: true,
            daysUntilText: "还有15天"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

