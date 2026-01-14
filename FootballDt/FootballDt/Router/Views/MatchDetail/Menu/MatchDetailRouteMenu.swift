//
//  MatchDetailRouteMenu.swift
//  FootballDt
//
//  Created by Macbook on 8/1/26.
//

import SwiftUI

enum MatchDetailRouteMenu: String, RouteMenu {
    
    case General = "Information"
    case HeadToHead = "History"
    
    var name: String { "MatchDetailRouteMenu" }
    
    var title: String {
        return self.rawValue
    }
    
    var index: Int {
        switch self {
        case .General: 0
        case .HeadToHead: 1
        }
    }
    
    var icon: String {
        switch self {
        case .General: "list.bullet.clipboard"
        case .HeadToHead: "calendar"
        }
    }
    
    var color: Color { return .blue }
    
    func getIconView() -> AnyView {
        AnyView(Image(systemName: icon))
    }
    
    func getIconView(active: Bool) -> AnyView {
        switch self {
        case .General: return AnyView(Image(systemName: icon + "\(active ? ".fill" : "")"))
        case .HeadToHead: return AnyView(Image(systemName: icon))
        }
    }
    
    
}


extension MatchDetailRouteMenu {
    @ViewBuilder
    func getView() -> AnyView {
        AnyView(
            Group {
                switch self {
                case .General:
                    Head2HeadDetailView()
                case .HeadToHead:
                    MatchesByHeadToHeadView()
                }
            }
        )
        
    }
    
    @ViewBuilder
    func getContentView() -> some View {
        switch self {
        case .General:
            Head2HeadDetailView()
        case .HeadToHead:
            MatchesByHeadToHeadView()
        }
    }
}
