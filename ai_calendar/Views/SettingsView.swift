//
//  SettingsView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// 主题设置管理器
enum AppTheme: String, CaseIterable {
    case system = "跟随系统"
    case light = "浅色"
    case dark = "深色"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
            withAnimation(.easeInOut(duration: 0.3)) {
                colorScheme = currentTheme.colorScheme
            }
        }
    }
    
    @Published private(set) var colorScheme: ColorScheme?
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
        colorScheme = currentTheme.colorScheme
    }
    
    // 切换主题
    func toggleTheme() {
        let currentIndex = AppTheme.allCases.firstIndex(of: currentTheme) ?? 0
        let nextIndex = (currentIndex + 1) % AppTheme.allCases.count
        currentTheme = AppTheme.allCases[nextIndex]
    }
}

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("外观设置")) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button(action: {
                            withAnimation {
                                themeManager.currentTheme = theme
                            }
                        }) {
                            HStack {
                                Image(systemName: theme.icon)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 30)
                                Text(theme.rawValue)
                                Spacer()
                                if themeManager.currentTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .preferredColorScheme(themeManager.colorScheme)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}