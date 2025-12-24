//
//  RouteGenericView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct RouteGenericView<HeaderView: View, ContentView: View>: View {
    
    private var headerView: HeaderView
    private var contentView: ContentView
    private var backgroundURLLink: String?
    
    init(headerView: HeaderView, contentView: ContentView, backgroundURLLink: String? = nil) {
        self.headerView = headerView
        self.contentView = contentView
        self.backgroundURLLink = backgroundURLLink
    }
    
    var body: some View {
        if let backgroundURLLink {
            VStack {
                headerView
                contentView
                    .padding(.horizontal, 5)
            }
            .padding(.bottom, 45)
            //.backgroundOfPage(by: .URLImage(url: backgroundURLLink))
        } else {
            VStack {
                headerView
                contentView
                    .padding(.horizontal, 5)
            }
            .padding(.bottom, 45)
        }
    }
}
