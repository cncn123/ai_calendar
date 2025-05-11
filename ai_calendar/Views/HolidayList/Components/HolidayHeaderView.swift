//
//  HolidayHeaderView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// MARK: - 节假日列表顶部栏视图
struct HolidayHeaderView: View {
    @ObservedObject var viewModel: HolidayListViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Text("节假日一览")
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityLabel("节假日一览")
            
            Spacer()
            
            // 地区选择器
            HStack(spacing: 12) {
                // 全部
                Button(action: {
                    viewModel.toggleRegion(nil)
                }) {
                    Text("全部")
                        .font(.footnote)
                        .fontWeight(viewModel.selectedRegion == nil ? .bold : .regular)
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.isRegionSelected(.mainland) ? AppColors.mainlandRed.opacity(0.2) : Color.gray.opacity(0.1))
                        .foregroundColor(viewModel.isRegionSelected(.mainland) ? AppColors.mainlandRed : .primary)
                        .cornerRadius(16)
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .padding(.vertical, 10)
    }
} 