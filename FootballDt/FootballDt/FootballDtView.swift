//
//  FootballDtView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI
import NavigationRouter

struct FootballDtView: View {
    
    @StateObject private var container = AppDependencyContainer()
    
    var body: some View {
        NavigationRouter(
            router: container.footballDtRouter) {
                ListCompetitionRouteView()
                    .backgroundOfPage(by: .Gradient)
            } destination: { route in
                footballDtDestination(route)
            }
        .injectDependencies(container)
        
        .padding(0)
    }
    
    @ViewBuilder
    func footballDtDestination(_ route: FootballDtRoute) -> some View {
        route.destinationView()
    }
}


extension View {
    func injectDependencies(_ container: AppDependencyContainer) -> some View {
        self
            .environmentObject(container.footballDtRouter)
            .environmentObject(container.listCompetitionVM)
            .environmentObject(container.leaderboardVM)
    }
}

class AppDependencyContainer: ObservableObject {
    
    let footballDtRouter = FootballDtRouter()
    
    // MARK: Service
    private lazy var competitionAPIService = CompetitionAPIService()
    private lazy var leaderboardAPIService = LeaderboardAPIService()
    
    // MARK: UsserCase
    private lazy var getAllCompetitionUserCase = GetAllCompetitionUserCase(repository: competitionAPIService)
    private lazy var getLeaderboardUserCase = GetLeaderboardUserCase(repository: leaderboardAPIService)
    
    
    // MARK: ViewModel
    lazy var listCompetitionVM = ListCompetitionViewModel(getAllCompetitionUserCase: getAllCompetitionUserCase)
    
    lazy var leaderboardVM = LeaderboardViewModel(getLeaderboardUserCase: getLeaderboardUserCase)
}
