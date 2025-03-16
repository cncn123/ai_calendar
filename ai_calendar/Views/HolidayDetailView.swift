//
//  HolidayDetailView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

struct HolidayDetailView: View {
    let holiday: Holiday
    @Environment(\.presentationMode) var presentationMode
    @State private var isReminderSet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 顶部标题区域
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(holiday.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(formatDate(holiday.date))
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        VStack(spacing: 0) {
                            Text("\(holiday.date.dayOfMonth)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            
                            Text(getMonthString(holiday.date.month))
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 基本信息区域
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle(title: "基本信息")
                    
                    InfoRow(icon: "calendar", title: "假期类型", value: holiday.type.rawValue)
                    InfoRow(icon: "mappin.and.ellipse", title: "适用地区", value: holiday.region.rawValue)
                    InfoRow(icon: "clock", title: "假期时长", value: "\(holiday.duration)天")
                    
                    if holiday.region == .mainland {
                        InfoRow(icon: "calendar.badge.clock", title: "调休安排", value: "7天假期（10月1日-10月7日）")
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 节日介绍区域
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle(title: "节日介绍")
                    
                    Text(holiday.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    if holiday.name == "国庆节" {
                        Text("国庆节是中华人民共和国成立的纪念日。1949年10月1日，是中华人民共和国中央人民政府成立大典举行的日子，也是中华人民共和国的国庆节。每年的10月1日，全国各地都会举行各种庆祝活动，庆祝中华人民共和国成立。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 提醒设置区域
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle(title: "提醒设置")
                    
                    Toggle("开启假期提醒", isOn: $isReminderSet)
                        .padding(.vertical, 8)
                    
                    if isReminderSet {
                        HStack {
                            Text("提醒时间")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("提前1天 9:00")
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        
                        HStack {
                            Text("提醒声音")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("默认")
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 分享按钮
                Button(action: {}) {
                    HStack {
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                        Text("分享节日信息")
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
    
    private func getMonthString(_ month: Int) -> String {
        let months = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        return months[month - 1]
    }
}

// 信息行组件
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// 区域标题组件
struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

#Preview {
    NavigationView {
        HolidayDetailView(holiday: Holiday(
            name: "国庆节",
            date: Date.from(year: 2023, month: 10, day: 1),
            type: .national,
            description: "庆祝中华人民共和国成立",
            duration: 7,
            region: .mainland
        ))
    }
}