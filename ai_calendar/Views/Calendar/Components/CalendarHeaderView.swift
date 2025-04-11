//
//  CalendarHeaderView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// MARK: - 顶部栏视图
struct CalendarHeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        HStack {
            Text("节假日日历")
                .font(.headline)
                .padding(.leading)
                .accessibilityLabel("节假日日历标题")

            Spacer()
            
            // 地区选择按钮
            HStack(spacing: 12) {
                ForEach([nil,  Holiday.Region.hongKong, Holiday.Region.mainland], id: \.self) { region in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedRegion = region
                        }
                    }) {
                        Text(region?.rawValue ?? "全部")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                            .background(viewModel.selectedRegion == region ? Color.blue : Color(.systemGray6))
                            .foregroundColor(viewModel.selectedRegion == region ? .white : .primary)
                            .clipShape(Capsule())
                            .accessibilityLabel("\(region?.rawValue ?? "全部")地区")
                    }
                }
            }
            .padding(.trailing, 16)
            .frame(width: 220)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}