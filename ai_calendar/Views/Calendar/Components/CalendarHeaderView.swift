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
            
            // 地区选择
            Picker("地区", selection: $viewModel.selectedRegion) {
                Text("全部").tag(Optional<Holiday.Region>.none)
                Text("香港").tag(Optional<Holiday.Region>.some(.hongKong))
                Text("内地").tag(Optional<Holiday.Region>.some(.mainland))
            }
            .pickerStyle(.segmented)
            .frame(width: 220)
            .padding(.trailing, 16)
            .onChange(of: viewModel.selectedRegion) { oldValue, newValue in
                print("地区选择已更改: \(String(describing: newValue))")
            }
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}