//
//  FootballDtApp.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI
import SDWebImageSVGCoder
import SDWebImage

@main
struct FootballDtApp: App {
    
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
    
    var body: some Scene {
        WindowGroup {
            FootballDtView()
            // EnhancedDarkModeExamples()
        }
    }
}
