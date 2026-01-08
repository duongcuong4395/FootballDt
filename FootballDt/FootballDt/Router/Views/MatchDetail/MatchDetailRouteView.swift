//
//  MatchDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

import SwiftUI

struct MatchDetailRouteView: View {
    
    var body: some View {
        RouteGenericView(
            headerView: MatchDetailRouteHeaderView()
            , contentView: MatchDetailRouteContentView())
        .backgroundOfPage(by: .Gradient)
    }
}

struct MatchDetailRouteHeaderView: View {
    @EnvironmentObject private var router: FootballDtRouter
    @EnvironmentObject private var matchDetailVM: MatchDetailViewModel
    
    var body: some View {
        if case .success(let match) = matchDetailVM.state {
            RouteHeaderView(
                backRouteAction: backRoute
                , contentView: UniversalMatchItemView.header(match: match)
                    .scaleEffect(0.95))
        }
    }
    
    func backRoute() {
        matchDetailVM.setState(.idle)
        router.pop()
    }
}

struct MatchDetailRouteContentView: View {
    @EnvironmentObject private var matchDetailVM: MatchDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var previousEncountersVM: PreviousEncountersViewModel
    
    @State private var menu: MatchDetailRouteMenu = .General
    @State private var loadedTabs: Set<MatchDetailRouteMenu> = []
    
    init() {
        lazy var matchAPIService = MatchAPIService()
        lazy var getPreviousEncountersUC = GetPreviousEncountersUseCase(repository: matchAPIService)
        self._previousEncountersVM = StateObject(wrappedValue: PreviousEncountersViewModel(getPreviousEncountersUC: getPreviousEncountersUC))
    }
    
    var body: some View {
        VStack {
            MenuRouteView(menu: $menu, animationName: "MatchDetailRouteMenu")
            TabViewByMenuRouteView(menu: $menu)
        }
        .environmentObject(previousEncountersVM)
    }
}
