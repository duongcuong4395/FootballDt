//
//  TeamDetailRouteMenu.swift
//  FootballDt
//
//  Created by Macbook on 8/1/26.
//

import SwiftUI

enum TeamDetailRouteMenu: String, RouteMenu {
    case General = "Information"
    case Match
    
    var title: String {
        return self.rawValue
    }
    
    var index: Int {
        switch self {
        case .General: 0
        case .Match: 1
        }
    }
    
    var icon: String {
        switch self {
        case .General: "list.bullet.clipboard"
        case .Match: "calendar"
        }
    }
    
    var color: Color { return .blue }
    
    func getIconView() -> AnyView {
        AnyView(Image(systemName: icon))
    }
    
    func getIconView(active: Bool) -> AnyView {
        switch self {
        case .General: return AnyView(Image(systemName: icon + "\(active ? ".fill" : "")"))
        case .Match: return AnyView(Image(systemName: icon))
        }
    }
    
    @ViewBuilder
    func getView() -> AnyView {
        AnyView(Group {
            switch self {
            case .General:
                TeamDetailGeneralView()
            case .Match:
                MatchesByTeamView()
            }
        })
    }
}
