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
            , contentView: TeamDetailRouteContentView()
            , backgroundURLLink: nil)
        .backgroundOfPage(by: .Gradient)
    }
}

struct TeamDetailRouteHeaderView: View {
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var matchesByTeamVM: MatchesByTeamViewModel
    
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if case .success(data: let team) = teamVM.teamStatus {
                Button(action: {
                    backRoute()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                })
                
                getTeamItemHeaderView(by: team)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .themedBackground(.header(tintColor: .backgroundColor(for: colorScheme), height: 70))
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
        Group {
            switch teamVM.teamStatus {
            case .idle:
                Color.clear.onAppear{ loadDataIfNeeded() }
            case .loading:
                ProgressView("Loading team...")
            case .success(let team):
                
                MenuRouteView(menu: $selected, animationName: "TeamDetailRouteMenu")
                
                TabView(selection: $selected) {
                    LazyTabContent(
                        menu: TeamDetailRouteMenu.General
                        , isSelected: selected == TeamDetailRouteMenu.General
                        , loadedTabs: $loadedTabs) {
                            TeamGeneralView(team: team)
                        }
                        .tag(TeamDetailRouteMenu.General)
                    
                    LazyTabContent(
                        menu: TeamDetailRouteMenu.Match
                        , isSelected: selected == TeamDetailRouteMenu.Match
                        , loadedTabs: $loadedTabs) {
                            MatchesByTeamView()
                        }
                        .tag(TeamDetailRouteMenu.Match)
                }
                .padding(10)
                .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme)))
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.2), value: selected)
                
            case .failure(_):
                ErrorView(error: "") {
                    loadDataIfNeeded()
                }
            }
        }
        .onAppear {
            loadedTabs.insert(TeamDetailRouteMenu.General)
        }
    }
    
    func loadDataIfNeeded() {
        
    }
}

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
    
    
}






