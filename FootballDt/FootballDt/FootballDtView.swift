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
    
    @Namespace private var competitionAnimation
    
    var body: some View {
        NavigationRouter(
            router: container.footballDtRouter) {
                ListCompetitionRouteView()
                    .backgroundOfPage(by: .Gradient)
                    .environment(\.competitionNamespace, competitionAnimation)
            } destination: { route in
                footballDtDestination(route)
            }
        .injectDependencies(container)
        .environment(\.competitionNamespace, competitionAnimation)
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
            .environmentObject(container.competitionMatchesVM)
            .environmentObject(container.competitionsTeamsVM)
            .environmentObject(container.competitionsScorersVM)
            .environmentObject(container.teamVM)
            .environmentObject(container.matchesByTeamVM)
    }
}

@MainActor
class AppDependencyContainer: ObservableObject {
    
    let footballDtRouter = FootballDtRouter()
    
    // MARK: Service
    private lazy var competitionAPIService = CompetitionAPIService()
    private lazy var leaderboardAPIService = LeaderboardAPIService()
    private lazy var competitionMatchesAPIService = CompetitionMatchesAPIService()
    private lazy var competitionsTeamsAPIService = CompetitionsTeamsAPIService()
    private lazy var competitionsScorersAPIService = CompetitionsScorersAPIService()
    private lazy var teamAPIService = TeamAPIService()
    
    
    // MARK: UsserCase
    private lazy var getAllCompetitionUserCase = GetAllCompetitionUserCase(repository: competitionAPIService)
    private lazy var getLeaderboardUserCase = GetLeaderboardUserCase(repository: leaderboardAPIService)
    private lazy var getCompetitionMatchesUserCase = GetCompetitionMatchesUserCase(repository: competitionMatchesAPIService)
    private lazy var getCompetitionsTeamsUserCase = GetCompetitionsTeamsUserCase(repository: competitionsTeamsAPIService)
    private lazy var getCompetitionsScorersUserCase = GetCompetitionsScorersUserCase(repository: competitionsScorersAPIService)
    private lazy var getTeamDetailUserCase = GetTeamDetailUserCase(repository: teamAPIService)
    private lazy var getMatchesByTeamUserCase = GetMatchesByTeamUserCase(repository: teamAPIService)
    
    // MARK: ViewModel
    lazy var listCompetitionVM = ListCompetitionViewModel(getAllCompetitionUserCase: getAllCompetitionUserCase)
    lazy var leaderboardVM = LeaderboardViewModel(getLeaderboardUserCase: getLeaderboardUserCase)
    lazy var competitionMatchesVM = CompetitionMatchesViewModel(getCompetitionMatchesUserCase: getCompetitionMatchesUserCase)
    lazy var competitionsTeamsVM = CompetitionsTeamsViewModel(getCompetitionsTeamsUserCase: getCompetitionsTeamsUserCase)
    
    lazy var competitionsScorersVM = CompetitionsScorersViewModel(getCompetitionsScorersUserCase: getCompetitionsScorersUserCase)
    
    lazy var teamVM = TeamViewModel(getTeamDetailUserCase: getTeamDetailUserCase)
    lazy var matchesByTeamVM = MatchesByTeamViewModel(getMatchesByTeamUserCase: getMatchesByTeamUserCase)
    
    
    
}


// MARK: - Reusable Components
struct ErrorView: View {
    let error: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.headline)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}


// MARK: - Environment Key cho Namespace
private struct CompetitionNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var competitionNamespace: Namespace.ID? {
        get { self[CompetitionNamespaceKey.self] }
        set { self[CompetitionNamespaceKey.self] = newValue }
    }
}
