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
}

enum CompetitionDetailRouteMenu: String, RouteMenu {
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
        case .Leaderboard: "book.fill"
        case .Teams: "book.fill"
        case .Matches: "book.fill"
        case .Scorers: "book.fill"
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
                    .themedBackground(.card(tintColor: .white, cornerRadius: 20, material: .none))
                    .tag(CompetitionDetailRouteMenu.Teams)
                
                CompetitionMatchesView()
                    .themedBackground(.card(tintColor: .white, cornerRadius: 20, material: .none))
                    .tag(CompetitionDetailRouteMenu.Matches)
                
                Text("Scorers")
                    .tag(CompetitionDetailRouteMenu.Scorers)
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.2), value: selected)
        }
        .padding(.bottom, 5)
    }
}



struct CompetitionScorersView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
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
                    tintColor: .orange
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
