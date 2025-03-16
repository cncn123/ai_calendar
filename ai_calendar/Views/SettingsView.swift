//
//  SettingsView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

struct SettingsView: View {
    @State private var showMainlandHolidays = true
    @State private var showHongKongHolidays = true
    @State private var reminderTime = "提前一天"
    @State private var reminderSound = "默认"
    @State private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            List {
                // 地区设置
                Section(header: Text("地区设置")) {
                    Toggle("显示内地节假日", isOn: $showMainlandHolidays)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Toggle("显示香港节假日", isOn: $showHongKongHolidays)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                // 提醒设置
                Section(header: Text("提醒设置")) {
                    NavigationLink(destination: Text("提醒时间设置")) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            Text("提醒时间")
                            Spacer()
                            Text(reminderTime)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: Text("提醒声音设置")) {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            Text("提醒声音")
                            Spacer()
                            Text(reminderSound)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 界面设置
                Section(header: Text("界面设置")) {
                    Toggle("深色模式", isOn: $isDarkMode)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    NavigationLink(destination: Text("主题颜色设置")) {
                        HStack {
                            Image(systemName: "paintbrush")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            Text("主题颜色")
                            Spacer()
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                // 小组件设置
                Section(header: Text("小组件")) {
                    NavigationLink(destination: Text("小组件设置")) {
                        HStack {
                            Image(systemName: "square.grid.2x2")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            Text("小组件设置")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 关于
                Section {
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            Text("关于应用")
                            Spacer()
                            Text("v1.0.0")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            Text("隐私政策")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("设置")
        }
    }
}

// 关于应用视图
struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top)
                    
                    Text("香港/内地节假日")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("版本 1.0.0")
                        .foregroundColor(.secondary)
                    
                    Text("© 2023 Bobby Space")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            Section(header: Text("功能")) {
                FeatureRow(icon: "calendar", title: "节假日日历", description: "查看香港和内地的所有节假日")
                FeatureRow(icon: "bell", title: "假期提醒", description: "设置节假日提醒，不错过任何假期")
                FeatureRow(icon: "globe", title: "多地区支持", description: "同时支持香港和内地节假日")
            }
            
            Section(header: Text("联系我们")) {
                Link(destination: URL(string: "mailto:support@example.com")!) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.blue)
                            .frame(width: 25)
                        Text("发送邮件")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Link(destination: URL(string: "https://example.com")!) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .frame(width: 25)
                        Text("访问网站")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 功能行组件
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
}