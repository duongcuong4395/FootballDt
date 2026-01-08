//
//  TeamDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

import SwiftUI

struct TeamDetailRouteView: View {
    var body: some View {
        RouteGenericView(
            headerView: TeamDetailRouteHeaderView()
            , contentView: TeamDetailRouteContentView())
        .backgroundOfPage(by: .Gradient)
    }
}

struct TeamDetailRouteHeaderView: View {
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var matchesByTeamVM: MatchesByTeamViewModel
    
    var body: some View {
        if case .success(data: let team) = teamVM.teamStatus {
            RouteHeaderView(
                backRouteAction: backRoute
                , contentView: getTeamItemHeaderView(by: team))
        }
    }
    
    func backRoute() {
        matchesByTeamVM.resetAll()
        teamVM.resetAll()
        router.pop()
    }
    
    @ViewBuilder
    func getTeamItemHeaderView(by team: Team) -> some View {
        HStack {
            RemoteImageView(urlString: team.crest, size: 40)
            VStack(alignment: .leading) {
                Text(team.shortName ?? "")
                    .font(.body.bold())
                
            }
        }
    }
}

struct TeamDetailRouteContentView: View {
    @EnvironmentObject var teamVM: TeamViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var selected: TeamDetailRouteMenu = .General
    @State private var loadedTabs: Set<TeamDetailRouteMenu> = []
    var body: some View {
        VStack {
            MenuRouteView(menu: $selected, animationName: "TeamDetailRouteMenu")
            TabViewByMenuRouteView(menu: $selected)
        }
    }
}

struct TeamDetailGeneralView: View {
    @EnvironmentObject var teamVM: TeamViewModel
    var body: some View {
        switch teamVM.teamStatus {
        case .idle:
            Color.clear
        case .loading:
            ProgressView("Loading team...")
        case .success(let team):
            TeamDetailView(team: team)
        case .failure(_):
            ErrorView(error: "") { }
        }
    }
}
