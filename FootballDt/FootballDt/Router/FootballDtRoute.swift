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
}

extension FootballDtRoute {
    @ViewBuilder
    func destinationView() -> some View {
        VStack {
            switch self {
            case .ListCompetition:
                ListCompetitionRouteView()
            
            }
        }
        .navigationBarHidden(true)
        
    }
}

class FootballDtRouter: BaseRouter<FootballDtRoute> {
    
}
