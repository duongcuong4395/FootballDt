//
//  MatchDetailRouteMenu.swift
//  FootballDt
//
//  Created by Macbook on 8/1/26.
//

import SwiftUI

enum MatchDetailRouteMenu: String, RouteMenu {
    
    case General = "Information"
    case PreviousEncounters = "History"
    
    var name: String { "MatchDetailRouteMenu" }
    
    var title: String {
        return self.rawValue
    }
    
    var index: Int {
        switch self {
        case .General: 0
        case .PreviousEncounters: 1
        }
    }
    
    var icon: String {
        switch self {
        case .General: "list.bullet.clipboard"
        case .PreviousEncounters: "calendar"
        }
    }
    
    var color: Color { return .blue }
    
    func getIconView() -> AnyView {
        AnyView(Image(systemName: icon))
    }
    
    func getIconView(active: Bool) -> AnyView {
        switch self {
        case .General: return AnyView(Image(systemName: icon + "\(active ? ".fill" : "")"))
        case .PreviousEncounters: return AnyView(Image(systemName: icon))
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
                case .PreviousEncounters:
                    MatchesByPreviousEncountersView()
                }
            }
        )
        
    }
    
    @ViewBuilder
    func getContentView() -> some View {
        switch self {
        case .General:
            Head2HeadDetailView()
        case .PreviousEncounters:
            MatchesByPreviousEncountersView()
        }
    }
}
