//
//  FootballDtRoute.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI
import NavigationRouter

enum FootballDtRoute: Hashable {
    case ListCompetition
    case CompetitionDetail
    case TeamDetail
}

extension FootballDtRoute {
    @ViewBuilder
    func destinationView() -> some View {
        VStack {
            switch self {
            case .ListCompetition:
                ListCompetitionRouteView()
            case .CompetitionDetail:
                CompetitionDetailRouteView()
            case .TeamDetail:
                TeamDetailRouteView()
            }
        }
        .navigationBarHidden(true)
    }
}

class FootballDtRouter: BaseRouter<FootballDtRoute> {
    func navigationToCompetitionDetail() {
        
        push(.CompetitionDetail)
    }
    
    func navigationTeamDetail() {
        navigateToOrPush(.TeamDetail)
        //push(.TeamDetail)
    }
}
