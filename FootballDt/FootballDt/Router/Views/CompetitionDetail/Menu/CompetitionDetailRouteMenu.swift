//
//  CompetitionDetailRouteMenu.swift
//  FootballDt
//
//  Created by Macbook on 8/1/26.
//

import SwiftUI

enum CompetitionDetailRouteMenu: String {
    case Leaderboard
    case Teams
    case Matches
    case Scorers
}

extension CompetitionDetailRouteMenu: RouteMenu {
    var title: String {
        switch self {
        case .Leaderboard: "Leaderboard"
        case .Teams: "Teams"
        case .Matches: "Matches"
        case .Scorers: "Scorers"
        }
    }
    
    var icon: String {
        switch self {
        case .Leaderboard: "list.bullet.clipboard"
        case .Teams: "person.3"
        case .Matches: "calendar"
        case .Scorers: "figure.australian.football"
        }
    }
    var color: Color {
        switch self {
        case .Leaderboard: .blue
        case .Teams: .blue
        case .Matches: .blue
        case .Scorers: .blue
        }
    }
    func getIconView() -> AnyView {
        AnyView(Image(systemName: icon))
    }
    
    var index: Int {
        switch self {
        case .Leaderboard: 0
        case .Teams: 1
        case .Matches: 2
        case .Scorers: 3
        }
    }
    
    func getIconView(active: Bool) -> AnyView {
        switch self {
        case .Leaderboard: return AnyView(Image(systemName: icon + "\(active ? ".fill" : "")"))
        case .Teams: return AnyView(Image(systemName: icon + "\(active ? ".fill" : "")"))
        case .Matches: return AnyView(Image(systemName: icon))
        case .Scorers: return AnyView(Image(systemName: icon))
        }
    }
    
}

extension CompetitionDetailRouteMenu {
    @ViewBuilder
    func getView() -> AnyView {
        AnyView(Group{
            switch self {
            case .Leaderboard:  LeaderboardView()
            case .Teams:        CompetitionTeamsView()
            case .Matches:      MatchesByCompetitionView()
            case .Scorers:      CompetitionScorersView()
            }
        })
    }
    
    @ViewBuilder
    func getTabView() -> some View {
        
        
        switch self {
        case .Leaderboard:  LeaderboardView().tag(self)
        case .Teams:        CompetitionTeamsView().tag(self)
        case .Matches:      MatchesByCompetitionView().tag(self)
        case .Scorers:      CompetitionScorersView().tag(self)
        }
        
    }
}
