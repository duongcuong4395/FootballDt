//
//  CompetitionDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

protocol RouteMenu: CaseIterable {
    var title: String { get }
    var icon: String { get }
    var color: Color { get }
    @ViewBuilder
    func getIconView() -> AnyView
    @ViewBuilder
    func getIconView(active: Bool) -> AnyView
}

enum CompetitionDetailRouteMenu: String, RouteMenu {
    func getIconView(active: Bool) -> AnyView {
        switch self {
        case .Leaderboard: return AnyView(Image(systemName: icon + "\(active ? ".fill" : "")"))
        case .Teams: return AnyView(Image(systemName: icon + "\(active ? ".fill" : "")"))
        case .Matches: return AnyView(Image(systemName: icon))
        case .Scorers: return AnyView(Image(systemName: icon))
        }
    }
    
    case Leaderboard
    case Teams
    case Matches
    case Scorers
    
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
}

struct CompetitionDetailRouteView: View {
    
    var body: some View {
        RouteGenericView(
            headerView: CompetitionDetailRouteHeaderView()
            , contentView: CompetitionDetailRouteContentView()
            , backgroundURLLink: nil)
        .backgroundOfPage(by: .Gradient)
    }
}


struct CompetitionDetailRouteHeaderView: View {
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    @EnvironmentObject var router: FootballDtRouter
    
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    @EnvironmentObject var competitionMatchesVM: CompetitionMatchesViewModel
    @EnvironmentObject var competitionsTeamsVM: CompetitionsTeamsViewModel
    @EnvironmentObject var competitionsScorersVM: CompetitionsScorersViewModel
    
    var body: some View {
        HStack {
            switch listCompetitionVM.competitionSelected {
                case .success(data: let competition):
                    Button(action: {
                        backRoute()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    })
                    CompetitionItemView(competition: competition, isHStack: true)
                    
                default: EmptyView()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .themedBackground(.header(height: 70))   
    }
    
    func backRoute() {
        router.pop()
        listCompetitionVM.resetCompetitionSelected()
        
        leaderboardVM.reset()
        competitionMatchesVM.reset()
        competitionsTeamsVM.reset()
        competitionsScorersVM.reset()
    }
}


struct CompetitionDetailRouteContentView: View {
    @State var selected: CompetitionDetailRouteMenu = .Leaderboard
    
    var body: some View {
        VStack {
            MenuOfCompetitionDetailRouteView(selected: $selected)
            
            TabView(selection: $selected) {
                LeaderboardView()
                    .padding(10)
                    .themedBackground(.card(tintColor: .white, cornerRadius: 20, material: .none))
                    
                    .tag(CompetitionDetailRouteMenu.Leaderboard)
                
                CompetitionTeamsView()
                    .padding(10)
                    .themedBackground(.card(tintColor: .white, cornerRadius: 20, material: .none))
                    .tag(CompetitionDetailRouteMenu.Teams)
                
                CompetitionMatchesView()
                    .padding(10)
                    .themedBackground(.card(tintColor: .white, cornerRadius: 20, material: .none))
                    .tag(CompetitionDetailRouteMenu.Matches)
                
                CompetitionScorersView()
                    .padding(10)
                    .themedBackground(.card(tintColor: .white, cornerRadius: 20, material: .none))
                    .tag(CompetitionDetailRouteMenu.Scorers)
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.2), value: selected)
        }
        .padding(.bottom, 5)
    }
}

struct MenuOfCompetitionDetailRouteView: View {
    @Binding var selected: CompetitionDetailRouteMenu
    @Namespace var animation
    
    var body: some View {
        HStack(spacing: 20) {
            
            ForEach(CompetitionDetailRouteMenu.allCases, id: \.self) { it in
                MenuTabIndicatorView(
                    menu: CompetitionDetailRouteMenu.allCases[it.index],
                    isSelected: selected == it
                )
                .themedBackground(.itemSelected(
                    tintColor: .white
                    , isSelected: selected == it
                    , animationID: animation, animationName: "CompetitionDetailRouteMenu"))
                .onTapGesture {
                    withAnimation {
                        selected = it
                    }
                }
                .id(it)
            }
            
        }
        .padding(5)
        .padding(.horizontal, 5)
        .themedBackground(.card(material: .none))
        .padding(.horizontal, 5)
    }
}
