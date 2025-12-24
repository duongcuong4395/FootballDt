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
            } destination: { route in
                footballDtDestination(route)
            }
        .injectDependencies(container)
        .padding()
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
    }
}

class AppDependencyContainer: ObservableObject {
    
    let footballDtRouter = FootballDtRouter()
    
    // MARK: Service
    private lazy var competitionAPIService = CompetitionAPIService()
    
    // MARK: UsserCase
    private lazy var getAllCompetitionUserCase = GetAllCompetitionUserCase(repository: competitionAPIService)
    
    // MARK: ViewModel
    lazy var listCompetitionVM = ListCompetitionViewModel(getAllCompetitionUserCase: getAllCompetitionUserCase)
}



// MARK: RouteGenericView
struct RouteGenericView<HeaderView: View, ContentView: View>: View {
    
    private var headerView: HeaderView
    private var contentView: ContentView
    private var backgroundURLLink: String?
    
    init(headerView: HeaderView, contentView: ContentView, backgroundURLLink: String? = nil) {
        self.headerView = headerView
        self.contentView = contentView
        self.backgroundURLLink = backgroundURLLink
    }
    
    var body: some View {
        if let backgroundURLLink {
            VStack {
                headerView
                contentView
                    .padding(.horizontal, 5)
            }
            .padding(.bottom, 45)
            //.backgroundOfPage(by: .URLImage(url: backgroundURLLink))
        } else {
            VStack {
                headerView
                contentView
                    .padding(.horizontal, 5)
            }
            .padding(.bottom, 45)
        }
    }
}
