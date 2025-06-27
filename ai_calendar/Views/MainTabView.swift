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
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label(NSLocalizedString("calendar", comment: "日历"), systemImage: "calendar")
                }
                .tag(0)
            
            HolidayListView()
                .tabItem {
                    Label(NSLocalizedString("list", comment: "列表"), systemImage: "list.bullet")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label(NSLocalizedString("settings", comment: "设置"), systemImage: "gear")
                }
                .tag(2)
        }.preferredColorScheme(themeManager.getCurrentColorScheme(for: systemColorScheme))
    }
}

#Preview {
    MainTabView()
        .environmentObject(ThemeManager())
}
