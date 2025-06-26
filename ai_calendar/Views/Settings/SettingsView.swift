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

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // 根据主题选择弥散光斑背景
                Group {
                    if systemColorScheme == .dark {
                        // 暗黑模式：深色系弥散背景
                        ZStack {
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#2D1B69").opacity(0.6), .clear]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 300
                            )
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#1B3B6F").opacity(0.6), .clear]),
                                center: .bottomLeading,
                                startRadius: 0,
                                endRadius: 300
                            )
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#0F4C75").opacity(0.6), .clear]),
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 350
                            )
                        }
                    } else {
                        // 亮色模式：浅色系弥散背景
                        ZStack {
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#FBE1FC").opacity(0.7), .clear]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 300
                            )
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#F8EAE7").opacity(0.7), .clear]),
                                center: .bottomLeading,
                                startRadius: 0,
                                endRadius: 300
                            )
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#7BD4FC").opacity(0.7), .clear]),
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 350
                            )
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // 外观设置 Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("appearance", comment: "外观设置"))
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        ForEach(Array(AppTheme.allCases.enumerated()), id: \.element) { index, theme in
                            VStack(spacing: 0) {
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
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                }
                                .foregroundColor(.primary)
                                
                                // 添加分隔线，除了最后一个选项
                                if index < AppTheme.allCases.count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .background(
                        ZStack {
                            // 玻璃质感背景
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .opacity(0.05)
                            
                            // 渐变边框
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.3),
                                            Color.purple.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
                    
                    // 关于 Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("about", comment: "关于"))
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        HStack {
                            Text(NSLocalizedString("version", comment: "版本"))
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(
                        ZStack {
                            // 玻璃质感背景
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .opacity(0.05)
                            
                            // 渐变边框
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.3),
                                            Color.purple.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
                    
                    Spacer() // 将内容推到顶部
                }
                .padding(.horizontal)
                .padding(.top, 12) // 改为顶部内边距
                .navigationTitle(NSLocalizedString("settings", comment: "设置"))
                .preferredColorScheme(themeManager.colorScheme)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}