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
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.getCurrentColorScheme(for: systemColorScheme))
        }
    }
}
