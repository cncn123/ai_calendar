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
                    AppColors.hongkongBlue.opacity(0.85),
                    Color(red: 0.4, green: 0.2, blue: 0.4).opacity(0.85),  // 中间过渡色
                    AppColors.mainlandRed.opacity(0.85)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20, corners: [.topLeft, .bottomLeft])
    }
    
    // 右侧信息区域视图
    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // 香港节假日名称和标签
                HStack(spacing: 8) {
                    Text(hkHoliday.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("香港")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.hongkongBlue.opacity(0.2),
                                    AppColors.hongkongBlue.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.hongkongBlue,
                                    AppColors.hongkongBlue.opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(8)
                }
                
                // 分隔线
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 20)
                
                // 内地节假日名称和标签
                HStack(spacing: 8) {
                    Text(mlHoliday.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("内地")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.mainlandRed.opacity(0.2),
                                    AppColors.mainlandRed.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.mainlandRed,
                                    AppColors.mainlandRed.opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
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
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        isSelected ? AppColors.hongkongBlue : Color.clear,
                        isSelected ? AppColors.mainlandRed : Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
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

// MARK: - 预览
#Preview {
    VStack(spacing: 20) {
        // 普通状态预览
        MultiRegionHolidayCard(
            hkHoliday: Holiday(
                id: "preview_hk_1",
                name: "元旦",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400),
                region: HolidayRegion.hongkong
            ),
            mlHoliday: Holiday(
                id: "preview_ml_1",
                name: "元旦",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400),
                region: HolidayRegion.mainland
            ),
            daysUntilText: "还有3天"
        )
        
        // 选中状态预览
        MultiRegionHolidayCard(
            hkHoliday: Holiday(
                id: "preview_hk_2",
                name: "国庆节",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 7),
                region: HolidayRegion.hongkong
            ),
            mlHoliday: Holiday(
                id: "preview_ml_2",
                name: "国庆节",
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
