//
//  BackgroundOfPage.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI
import Kingfisher

enum BackgroundStyle {
    case Gradient
    case URLImage(url: String)
}

extension BackgroundStyle {
    @MainActor
    @ViewBuilder
    func getView() -> some View {
        switch self {
        case .Gradient:
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.3),
                    Color.pink.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
        case .URLImage(url: let url):
            KFImage(URL(string: url))
                .placeholder { progress in
                    ProgressView()
                }
                .opacity(0.1)
                .ignoresSafeArea(.all)
        }
    }
}

extension View {
    func backgroundOfPage(by style: BackgroundStyle) -> some View {
        self.background {
            style.getView()
        }
    }
}
