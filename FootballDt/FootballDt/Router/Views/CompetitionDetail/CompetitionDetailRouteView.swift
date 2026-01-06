//
//  CompetitionDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

protocol RouteMenu: CaseIterable, Hashable {
    var title: String { get }
    var icon: String { get }
    var color: Color { get }
    @ViewBuilder
    func getIconView() -> AnyView
    @ViewBuilder
    func getIconView(active: Bool) -> AnyView
}

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
    func getTabView() -> some View {
        
        
        switch self {
        case .Leaderboard:  LeaderboardView().tag(self)
        case .Teams:        CompetitionTeamsView().tag(self)
        case .Matches:      CompetitionMatchesView().tag(self)
        case .Scorers:      CompetitionScorersView().tag(self)
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
    @EnvironmentObject var competitionsTeamsVM: CompetitionsTeamsViewModel
    @EnvironmentObject var competitionsScorersVM: CompetitionsScorersViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if case .success(data: let competition) = listCompetitionVM.competitionSelected {
                Button(action: {
                    backRoute()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                })
                CompetitionItemView(competition: competition, imageSize: 4, isCompact: true)
                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                Spacer()
            }
            
        }
        .padding(.horizontal, 16)
        .themedBackground(.header(tintColor: .backgroundColor(for: colorScheme), height: 70))
    }
    
    func backRoute() {
        
        listCompetitionVM.resetCompetitionSelected()
        
        leaderboardVM.reset()
        competitionsTeamsVM.reset()
        competitionsScorersVM.reset()
        router.pop()
    }
    
    
    
}


struct CompetitionDetailRouteContentView: View {
    @State var selected: CompetitionDetailRouteMenu = .Leaderboard
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    @Environment(\.colorScheme) var colorScheme
    // Track loaded tabs
    @State private var loadedTabs: Set<CompetitionDetailRouteMenu> = []
    
    var body: some View {
        VStack {
            MenuOfCompetitionDetailRouteView(selected: $selected)
            
            TabView(selection: $selected) {
                ForEach(CompetitionDetailRouteMenu.allCases, id: \.self) { menu in
                    menu.getTabView()
                }
            }
            .padding(10)
            .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme), cornerRadius: 20, material: .none))
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.2), value: selected)
        }
        .padding(.bottom, 5)
        .onAppear {
            loadedTabs.insert(.Leaderboard)
        }
    }
    
    private var competitionId: Int {
            if case .success(let comp) = listCompetitionVM.competitionSelected {
                return comp.id
            }
            return 0
        }
}

struct MenuOfCompetitionDetailRouteView: View {
    @Environment(\.colorScheme) var colorScheme
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
                    tintColor: .backgroundColor(for: colorScheme)
                    , isSelected: selected == it
                    , animationID: animation, animationName: "CompetitionDetailRouteMenu"))
                .onTapGesture {
                    withAnimation() {
                        self.selected = it
                    }
                }
                .id(it)
            }
        }
        .padding(5)
        .padding(.horizontal, 5)
        .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme), material: .none))
        .padding(.horizontal, 5)
    }
}

struct LazyTabContent<Content: View, Menu: RouteMenu>: View {
    var menu: Menu
    let isSelected: Bool
    @Binding var loadedTabs: Set<Menu>
    let content: () -> Content
    
    var body: some View {
        Group {
            if loadedTabs.contains(menu) {
                content()
            } else {
                Color.clear
                    .onAppear {
                        if isSelected {
                            loadedTabs.insert(menu)
                        }
                    }
            }
        }
        .onChange(of: isSelected) { ol, newValue in
            if newValue && !loadedTabs.contains(menu) {
                loadedTabs.insert(menu)
            }
        }
    }
}


