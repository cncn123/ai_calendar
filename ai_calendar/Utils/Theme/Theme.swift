//
//  Theme.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

// MARK: - 应用主题颜色
struct AppColors {
    // 香港节假日颜色 - 深蓝色
    static let hongkongBlue = Color(red: 0, green: 0.3, blue: 0.7)
    
    // 中国内地节假日颜色 - 中国红
    static let mainlandRed = Color(red: 0.9, green: 0.1, blue: 0.1)
    
    // 获取节假日颜色
    static func getHolidayColor(for region: HolidayRegion) -> Color {
        switch region {
        case .hongkong:
            return hongkongBlue
        case .mainland:
            return mainlandRed
        }
    }
    
    // 获取节假日背景颜色（带透明度）
    static func getHolidayBackgroundColor(for region: HolidayRegion, opacity: Double = 0.2) -> Color {
        getHolidayColor(for: region).opacity(opacity)
    }
} 