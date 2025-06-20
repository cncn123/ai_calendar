import SwiftUI

// MARK: - 日历网格视图
struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    // 新增：定义枚举类型
    enum CalendarGridItem: Hashable {
        case weekDay(String)
        case date(Date?)
    }
    
    var gridItems: [CalendarGridItem] {
        viewModel.weekDays.map { .weekDay($0) } + viewModel.daysInMonth().map { .date($0) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 月份选择器
            HStack(spacing: 12) {
                Button(action: viewModel.previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .accessibilityLabel("上个月")
                }
                .padding(.horizontal)

                Text("\(String(viewModel.currentYear))年\(viewModel.currentMonth)月")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityLabel("\(viewModel.currentYear)年\(viewModel.currentMonth)月")

                Button(action: viewModel.nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .accessibilityLabel("下个月")
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            
            // 合并星期标题和日期网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(gridItems, id: \.self) { item in
                    switch item {
                    case .weekDay(let day):
                        Text(day)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    case .date(let date):
                        if let date = date {
                            DayCell(
                                date: date,
                                isSelected: viewModel.isSameDay(date, viewModel.selectedDate),
                                holiday: viewModel.getHoliday(for: date),
                                onTap: { viewModel.selectedDate = date },
                                viewModel: viewModel
                            )
                        } else {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(height: 340)
        }
        .id("\(viewModel.currentYear)-\(viewModel.currentMonth)") // 保证月份改变时重新渲染
        .padding(.vertical, 12)
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
        .padding(.horizontal)
    }
}

// MARK: - 预览提供者
#if DEBUG
struct CalendarGridView_Previews: PreviewProvider {
    static var previews: some View {
        // 创建模拟的CalendarViewModel
        let viewModel = CalendarViewModel()
        
        return Group {
            // 预览1：默认状态
            CalendarGridView(viewModel: viewModel)
                .previewDisplayName("默认状态")
                .preferredColorScheme(.light)
                .previewLayout(.sizeThatFits)
            
            // 预览2：暗黑模式
            CalendarGridView(viewModel: viewModel)
                .previewDisplayName("暗黑模式")
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
