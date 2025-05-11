//
//  SettingsView.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// 主题设置管理器
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
    
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
    var localizationKey: String {
        switch self {
        case .system: return "theme_system"
        case .light: return "theme_light"
        case .dark: return "theme_dark"
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

enum AppLanguage: String, CaseIterable {
    case system
    case simplified
    case traditional
    case english

    var localeIdentifier: String? {
        switch self {
        case .system: return nil
        case .simplified: return "zh-Hans"
        case .traditional: return "zh-Hant"
        case .english: return "en"
        }
    }
    var localizationKey: String {
        switch self {
        case .system: return "system"
        case .simplified: return "simplified"
        case .traditional: return "traditional"
        case .english: return "english"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemColorScheme
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("appearance", comment: "外观设置"))) {
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
                                Text(NSLocalizedString(theme.localizationKey, comment: "主题选项"))
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
                
                Section(header: Text(NSLocalizedString("language", comment: "语言"))) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Button(action: {
                            languageManager.currentLanguage = lang.localeIdentifier ?? "system"
                        }) {
                            HStack {
                                Text(NSLocalizedString(lang.localizationKey, comment: "语言选项"))
                                Spacer()
                                if languageManager.currentLanguage == (lang.localeIdentifier ?? "system") {
                                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    Text(NSLocalizedString("language_restart_tip", comment: "切换语言后需重启App生效"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text(NSLocalizedString("about", comment: "关于"))) {
                    HStack {
                        Text(NSLocalizedString("version", comment: "版本"))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("settings", comment: "设置"))
            .preferredColorScheme(themeManager.colorScheme)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}