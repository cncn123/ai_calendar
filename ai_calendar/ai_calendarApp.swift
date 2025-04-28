//
//  ai_calendarApp.swift
//  ai_calendar
//
//  Created by Bobby on 8/3/2025.
//

import SwiftUI

@main
struct ai_calendarApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
