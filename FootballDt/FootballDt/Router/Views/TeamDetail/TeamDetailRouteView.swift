//
//  TeamDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

import SwiftUI

struct TeamDetailRouteView: View {
    
    @State var menu: TeamDetailRouteMenu = .General
    
    var body: some View {
        RouteGenericView(
            headerView: TeamDetailRouteHeaderView()
            , contentView: RouteContentView(menu: $menu, animationMenuName: menu.name)
        )
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
