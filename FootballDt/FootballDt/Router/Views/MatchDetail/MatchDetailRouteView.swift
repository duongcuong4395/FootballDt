//
//  MatchDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

import SwiftUI

struct MatchDetailRouteView: View {
    
    @StateObject private var matchesByHeadToHeadVM: MatchesByHeadToHeadViewModel
    @State private var menu: MatchDetailRouteMenu = .General
    
    init() {
        lazy var matchAPIService = MatchAPIService()
        lazy var fetchMatchesByHeadToHeadUC = FetchMatchesByHeadToHeadUseCase(repository: matchAPIService)
        
        self._matchesByHeadToHeadVM = StateObject(
            wrappedValue: MatchesByHeadToHeadViewModel(
                fetchMatchesByHeadToHeadUC: fetchMatchesByHeadToHeadUC)
        )
    }
    
    var body: some View {
        RouteGenericView(
            headerView: MatchDetailRouteHeaderView()
            , contentView: RouteContentView(menu: $menu, animationMenuName: menu.name)
                .environmentObject(matchesByHeadToHeadVM)
        )
        .backgroundOfPage(by: .Gradient)
    }
}

struct MatchDetailRouteHeaderView: View {
    @EnvironmentObject private var router: FootballDtRouter
    @EnvironmentObject private var matchDetailVM: MatchDetailViewModel
    
    var body: some View {
        if case .success(let match) = matchDetailVM.state {
            RouteHeaderView(backRouteAction: backRoute
                , contentView: UniversalMatchItemView.header(match: match)
                    .scaleEffect(0.95)
            )
        }
    }
    
    func backRoute() {
        matchDetailVM.setState(.idle)
        router.pop()
    }
}
