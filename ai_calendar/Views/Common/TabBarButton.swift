//
//  TabBarButton.swift
//  ai_calendar
//
//  Created by Trae AI on 2023
//

import SwiftUI

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(title)
                .font(.system(size: 12))
        }
        .foregroundColor(isSelected ? .blue : .gray)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}