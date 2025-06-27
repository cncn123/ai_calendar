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
                // iOS 16 风格的液体玻璃效果背景
                Group {
                    if colorScheme == .dark {
                        // 暗黑模式液体玻璃效果
                        ZStack {
                            // 深色基础渐变背景
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#1A1A2E").opacity(0.9),
                                    Color(hex: "#16213E").opacity(0.8),
                                    Color(hex: "#0F3460").opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // 深色液体玻璃光斑效果
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#2D1B69").opacity(0.4),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 400
                            )
                            .blur(radius: 20)
                            
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#1B3B6F").opacity(0.3),
                                    Color.clear
                                ]),
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 350
                            )
                            .blur(radius: 15)
                            
                            // 深色微妙光斑
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#0F4C75").opacity(0.2),
                                    Color.clear
                                ]),
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 300
                            )
                            .blur(radius: 25)
                            
                            // 深色液体玻璃纹理层
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.05),
                                            Color.clear,
                                            Color.white.opacity(0.02)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .blur(radius: 1)
                        }
                    } else {
                        // 亮色模式液体玻璃效果
                        ZStack {
                            // 基础渐变背景
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#F0F8FF").opacity(0.8),
                                    Color(hex: "#E6F3FF").opacity(0.6),
                                    Color(hex: "#F5F0FF").opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // 液体玻璃光斑效果
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 400
                            )
                            .blur(radius: 20)
                            
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#E8F4FD").opacity(0.4),
                                    Color.clear
                                ]),
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 350
                            )
                            .blur(radius: 15)
                            
                            // 微妙的色彩光斑
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#F0E6FF").opacity(0.3),
                                    Color.clear
                                ]),
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 300
                            )
                            .blur(radius: 25)
                            
                            // 液体玻璃纹理层
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear,
                                            Color.white.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .blur(radius: 1)
                        }
                    }
                }
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .animation(.easeInOut, value: viewModel.selectedDate)
            .animation(.easeInOut, value: viewModel.selectedRegion)
            .preferredColorScheme(themeManager.getCurrentColorScheme(for: colorScheme))
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
