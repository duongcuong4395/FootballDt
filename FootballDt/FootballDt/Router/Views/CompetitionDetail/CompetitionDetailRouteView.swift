//
//  CompetitionDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct CompetitionDetailRouteView: View {
    
    var body: some View {
        RouteGenericView(
            headerView: CompetitionDetailRouteHeaderView()
            , contentView: CompetitionDetailRouteContentView())
        .backgroundOfPage(by: .Gradient)
    }
}


struct CompetitionDetailRouteHeaderView: View {
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    @EnvironmentObject var router: FootballDtRouter
    
    @EnvironmentObject var matchesByCompetitionVM: MatchesByCompetitionViewModel
    
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    @EnvironmentObject var competitionsTeamsVM: CompetitionsTeamsViewModel
    @EnvironmentObject var competitionsScorersVM: CompetitionsScorersViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if case .success(data: let competition) = listCompetitionVM.competitionSelected {
            RouteHeaderView(
                backRouteAction: backRoute
                , contentView: CompetitionItemView(competition: competition, imageSize: 4, isCompact: true)
            )
        }
    }
    
    func backRoute() {
        listCompetitionVM.resetCompetitionSelected()
        matchesByCompetitionVM.setState(.idle)
        leaderboardVM.reset()
        competitionsTeamsVM.reset()
        competitionsScorersVM.reset()
        router.pop()
    }
}

struct CompetitionDetailRouteContentView: View {
    @State private var selected: CompetitionDetailRouteMenu = .Leaderboard
    @EnvironmentObject private var listCompetitionVM: ListCompetitionViewModel

    var body: some View {
        VStack {
            MenuRouteView(menu: $selected, animationName: "CompetitionDetailRouteMenu")
            TabViewByMenuRouteView(menu: $selected)
        }
    }
}




