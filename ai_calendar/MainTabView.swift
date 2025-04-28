//
//  MainTabView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
                .tag(0)
            
            HolidayListView()
                .tabItem {
                    Label("列表", systemImage: "list.bullet")
                }
                .tag(1)
            
            Text("提醒功能开发中...")
                .tabItem {
                    Label("提醒", systemImage: "bell")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(3)
        }.preferredColorScheme(themeManager.colorScheme)
    }
}

#Preview {
    MainTabView()
        .environmentObject(ThemeManager())
}