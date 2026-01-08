//
//  MatchDetailRouteHeaderView.swift
//  FootballDt
//
//  Created by Macbook on 8/1/26.
//

import SwiftUI



struct MatchDetailRouteHeaderView: View {
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    
    var body: some View {
        if case .success(let match) = matchDetailVM.state {
            RouteHeaderView(backRouteAction: backRoute, contentView: UniversalMatchItemView.header(match: match)
                .scaleEffect(0.95))
        }
    }
    
    func backRoute() {
        matchDetailVM.setState(.idle)
        router.pop()
    }
}
