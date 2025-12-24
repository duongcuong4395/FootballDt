//
//  MenuTabIndicatorView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct MenuTabIndicatorView<Menu: RouteMenu>: View {
    var menu: Menu
    let isSelected: Bool
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Icon với animation
                menu.getIconView()
                //Image(systemName: menu.icon)
                    .font(.title3)
                //.font(.system(size: isSelected ? 24 : 20, weight: .semibold))
                    .foregroundColor(isSelected ? menu.color : (colorScheme == .light ? .gray : .white))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
                
                // Title
                if isSelected {
                    Text(menu.title)
                        .font(.system(size: isSelected ? 14 : 12, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? menu.color : (colorScheme == .light ? .gray : .white))
                        .animation(.easeInOut(duration: 0.3), value: isSelected)
                }
            }
            
            
            
            // Animated Indicator Line
            /*
            Rectangle()
                .fill(menu.color)
                .frame(width: isSelected ? 40 : 0, height: 3)
                .cornerRadius(1.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isSelected)
                */
        }
        .padding(5)
        //.padding(.vertical, 12)
        //.padding(.horizontal, 16)
        
    }
}
