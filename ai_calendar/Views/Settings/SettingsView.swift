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
            print("主题已更改到: \(currentTheme.rawValue)") // 调试信息
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
    
    // 获取当前应该使用的主题
    func getCurrentColorScheme(for systemScheme: ColorScheme) -> ColorScheme? {
        switch currentTheme {
        case .system:
            return systemScheme
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // iOS 16 风格的液体玻璃效果背景
                Group {
                    if themeManager.getCurrentColorScheme(for: systemColorScheme) == .dark {
                        // 暗黑模式液体玻璃效果
                        ZStack {
                            // 深色基础渐变背景
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#1A1A2E").opacity(0.9),
                                    Color(hex: "#16213E").opacity(0.8),
                                    Color(hex: "#0F3460").opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // 深色液体玻璃光斑效果
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#2D1B69").opacity(0.4),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 400
                            )
                            .blur(radius: 20)
                            
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#1B3B6F").opacity(0.3),
                                    Color.clear
                                ]),
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 350
                            )
                            .blur(radius: 15)
                            
                            // 深色微妙光斑
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#0F4C75").opacity(0.2),
                                    Color.clear
                                ]),
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 300
                            )
                            .blur(radius: 25)
                            
                            // 深色液体玻璃纹理层
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.05),
                                            Color.clear,
                                            Color.white.opacity(0.02)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .blur(radius: 1)
                        }
                    } else {
                        // 亮色模式液体玻璃效果
                        ZStack {
                            // 基础渐变背景
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#F0F8FF").opacity(0.8),
                                    Color(hex: "#E6F3FF").opacity(0.6),
                                    Color(hex: "#F5F0FF").opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // 液体玻璃光斑效果
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 400
                            )
                            .blur(radius: 20)
                            
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#E8F4FD").opacity(0.4),
                                    Color.clear
                                ]),
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 350
                            )
                            .blur(radius: 15)
                            
                            // 微妙的色彩光斑
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#F0E6FF").opacity(0.3),
                                    Color.clear
                                ]),
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 300
                            )
                            .blur(radius: 25)
                            
                            // 液体玻璃纹理层
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear,
                                            Color.white.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .blur(radius: 1)
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // 当前主题状态显示（调试用）
                    HStack {
                        Text("当前主题: \(themeManager.currentTheme.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 外观设置 Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("appearance", comment: "外观设置"))
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        ForEach(Array(AppTheme.allCases.enumerated()), id: \.element) { index, theme in
                            VStack(spacing: 0) {
                                Button(action: {
                                    print("切换主题到: \(theme.rawValue)") // 调试信息
                                    withAnimation(.easeInOut(duration: 0.3)) {
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
                .preferredColorScheme(themeManager.getCurrentColorScheme(for: systemColorScheme))
            }
        }
        .id("settings-\(themeManager.currentTheme.rawValue)") // 强制重新渲染
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}