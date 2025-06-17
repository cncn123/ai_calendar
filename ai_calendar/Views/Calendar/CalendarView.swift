import SwiftUI
import Foundation

// MARK: - 主日历视图
struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var hasScrolledToTodayHoliday = false
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 顶部栏 - 包含标题和地区选择器
                CalendarHeaderView(viewModel: viewModel)
                
                // 日历内容（包含月份选择器和网格）
                CalendarGridView(viewModel: viewModel)
                
                // 当月所有节假日卡片
                MonthlyHolidaysView(viewModel: viewModel)
                    .id("holidaysView")
            }
            .padding(.vertical)
            .background(
                // 添加渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(colorScheme == .dark ? 0.15 : 0.05),
                        Color.purple.opacity(colorScheme == .dark ? 0.15 : 0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
            .animation(.easeInOut, value: viewModel.selectedDate)
            .animation(.easeInOut, value: viewModel.selectedRegion)
            .preferredColorScheme(themeManager.colorScheme)
            .onAppear {
                // 清除缓存并重新加载数据
                HolidayService.shared.clearCache()
                viewModel.loadHolidays()
                
                // 首次进入时检查当天是否为节假日
                if !hasScrolledToTodayHoliday {
                    checkTodayHoliday()
                }
            }
            // 监听月份变化
            .onChange(of: viewModel.currentMonth) { _, _ in
                viewModel.refreshMonthHolidays()
            }
            // 监听年份变化
            .onChange(of: viewModel.currentYear) { _, _ in
                viewModel.refreshMonthHolidays()
            }
            // 监听地区筛选变化
            .onChange(of: viewModel.selectedRegion) { _, _ in
                viewModel.refreshMonthHolidays()
            }
        }
    }
    
    // 检查当天是否为节假日，如果是则滚动到对应位置
    private func checkTodayHoliday() {
        let today = Date()
        
        // 确保当前显示的是今天所在的月份
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        // 如果当前不是显示今天所在月份，则切换到今天所在月份
        if viewModel.currentMonth != currentMonth || viewModel.currentYear != currentYear {
            viewModel.currentMonth = currentMonth
            viewModel.currentYear = currentYear
        }
        
        // 检查今天是否有节假日
        if viewModel.getHoliday(for: today) != nil {
            // 将选中日期设置为今天，这会触发 MonthlyHolidaysView 中的滚动
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    viewModel.selectedDate = today
                }
                hasScrolledToTodayHoliday = true
            }
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(ThemeManager())
}
