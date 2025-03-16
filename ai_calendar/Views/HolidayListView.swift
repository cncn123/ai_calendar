//
//  HolidayListView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

struct HolidayListView: View {
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedRegion: Holiday.Region? = nil
    @State private var searchText = ""
    
    private let holidayService = HolidayService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部筛选区域
                VStack(spacing: 12) {
                    HStack {
                        Text("节假日详情")
                            .font(.headline)
                        
                        Spacer()
                        
                        Menu {
                            Button("全部", action: { selectedRegion = nil })
                            ForEach(Holiday.Region.allCases) { region in
                                Button(region.rawValue, action: { selectedRegion = region })
                            }
                        } label: {
                            HStack {
                                Text(selectedRegion?.rawValue ?? "全部地区")
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 年份选择器
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach((selectedYear-2)...(selectedYear+2), id: \.self) { year in
                                Button(action: {
                                    selectedYear = year
                                }) {
                                    Text(String(year))
                                        .fontWeight(year == selectedYear ? .bold : .regular)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(year == selectedYear ? Color.blue : Color.clear)
                                        .foregroundColor(year == selectedYear ? .white : .primary)
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 搜索栏
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("搜索节假日", text: $searchText)
                            .font(.system(size: 14))
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // 节假日列表
                List {
                    ForEach(filteredHolidays()) { holiday in
                        NavigationLink(destination: HolidayDetailView(holiday: holiday)) {
                            HolidayRow(holiday: holiday)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
            }
            .navigationBarHidden(true)
        }
    }
    
    // 过滤节假日
    private func filteredHolidays() -> [Holiday] {
        var holidays = holidayService.getAllHolidays(for: selectedYear)
        
        // 按地区筛选
        if let region = selectedRegion {
            holidays = holidays.filter { $0.region == region }
        }
        
        // 按搜索文本筛选
        if !searchText.isEmpty {
            holidays = holidays.filter { $0.name.contains(searchText) || $0.description.contains(searchText) }
        }
        
        // 按日期排序
        return holidays.sorted { $0.date < $1.date }
    }
}

// 节假日行组件
struct HolidayRow: View {
    let holiday: Holiday
    
    var body: some View {
        HStack(spacing: 15) {
            // 日期圆圈
            ZStack {
                Circle()
                    .fill(getHolidayColor(holiday.type).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 0) {
                    Text("\(holiday.date.dayOfMonth)")
                        .font(.system(size: 18, weight: .bold))
                    Text(getMonthAbbreviation(holiday.date.month))
                        .font(.system(size: 12))
                }
                .foregroundColor(getHolidayColor(holiday.type))
            }
            
            // 节假日信息
            VStack(alignment: .leading, spacing: 4) {
                Text(holiday.name)
                    .font(.headline)
                
                HStack {
                    Text(holiday.type.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(getHolidayColor(holiday.type).opacity(0.1))
                        .cornerRadius(4)
                    
                    Text(holiday.region.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 假期天数
            VStack(alignment: .trailing) {
                Text("\(holiday.duration)天")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if holiday.duration > 1 {
                    Text("假期")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // 获取节假日类型对应的颜色
    private func getHolidayColor(_ type: Holiday.HolidayType) -> Color {
        switch type {
        case .national:
            return .red
        case .traditional:
            return .orange
        case .international:
            return .blue
        case .memorial:
            return .purple
        }
    }
    
    // 获取月份缩写
    private func getMonthAbbreviation(_ month: Int) -> String {
        let abbreviations = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"]
        return abbreviations[month - 1]
    }
}

// 底部标签按钮（与CalendarView中相同，实际应用中应该提取到共享组件）


#Preview {
    HolidayListView()
}