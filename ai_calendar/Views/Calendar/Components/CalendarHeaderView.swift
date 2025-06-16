import SwiftUI

// MARK: - 顶部栏视图
struct CalendarHeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Text("节假日日历")
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityLabel("节假日日历")
            Spacer()
            regionSelector
        }
        .padding(.horizontal)
//        .background(Color(.systemBackground))
        .padding(.vertical, 10)
    }
    
    // 地区选择器
    private var regionSelector: some View {
        HStack(spacing: 12) {
            // 全部
            Button(action: {
                viewModel.toggleRegion(nil)
            }) {
                Text("全部")
                    .font(.footnote)
                    .fontWeight(viewModel.selectedRegion == nil ? .bold : .regular)
                    .fixedSize(horizontal: true, vertical: false) // 防止换行
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedRegion == nil ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.selectedRegion == nil ? Color.blue : .primary)
                    .cornerRadius(16)
            }
            
            // 香港
            Button(action: {
                viewModel.toggleRegion(.hongkong)
            }) {
                Text("香港")
                    .font(.footnote)
                    .fontWeight(viewModel.isRegionSelected(.hongkong) ? .bold : .regular)
                    .fixedSize(horizontal: true, vertical: false) // 防止换行
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.isRegionSelected(.hongkong) ? AppColors.hongkongBlue.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.isRegionSelected(.hongkong) ? AppColors.hongkongBlue : .primary)
                    .cornerRadius(16)
            }
            
            // 内地
            Button(action: {
                viewModel.toggleRegion(.mainland)
            }) {
                Text("内地")
                    .font(.footnote)
                    .fontWeight(viewModel.isRegionSelected(.mainland) ? .bold : .regular)
                    .fixedSize(horizontal: true, vertical: false) // 防止换行
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.isRegionSelected(.mainland) ? AppColors.mainlandRed.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.isRegionSelected(.mainland) ? AppColors.mainlandRed : .primary)
                    .cornerRadius(16)
            }
        }
    }
}


// MARK: - 预览提供者
#Preview {
    VStack(spacing: 20) {
        // 默认状态预览
        CalendarHeaderView(viewModel: {
            let vm = CalendarViewModel()
            vm.selectedRegion = nil
            return vm
        }())
        .padding()
        .background(Color(.systemBackground))
        
        // 香港地区选中状态预览
        CalendarHeaderView(viewModel: {
            let vm = CalendarViewModel()
            vm.selectedRegion = .hongkong
            return vm
        }())
        .padding()
        .background(Color(.systemBackground))
        
        // 内地地区选中状态预览
        CalendarHeaderView(viewModel: {
            let vm = CalendarViewModel()
            vm.selectedRegion = .mainland
            return vm
        }())
        .padding()
        .background(Color(.systemBackground))
    }
}

