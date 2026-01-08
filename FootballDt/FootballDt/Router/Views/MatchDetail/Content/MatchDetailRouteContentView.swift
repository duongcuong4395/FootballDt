//
//  MatchDetailRouteContentView.swift
//  FootballDt
//
//  Created by Macbook on 8/1/26.
//

import SwiftUI

struct MatchDetailRouteContentView: View {
    
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var previousEncountersVM: PreviousEncountersViewModel
    
    @State var menu: MatchDetailRouteMenu = .General
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

struct Head2HeadDetailView: View {
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    @EnvironmentObject var previousEncountersVM: PreviousEncountersViewModel
    
    var body: some View {
        HStack {
            if let homeTeam = previousEncountersVM.homeTeam {
                TeamDetailByMatch(team: homeTeam)
            }
                
            if let awayTeam = previousEncountersVM.awayTeam {
                TeamDetailByMatch(team: awayTeam)
            }
        }
        .onAppear{
            guard previousEncountersVM.homeTeam == nil && previousEncountersVM.awayTeam == nil else { return }
            
            guard case .success(let match) = matchDetailVM.state else { return }
            
            let teamAPIService = TeamAPIService()
            let getTeamDetailUserCase = GetTeamDetailUserCase(repository: teamAPIService)
            
            guard let homeTeamId = match.homeTeam.id else { return }
            guard let awayTeamId = match.awayTeam.id else { return }
            Task {
                previousEncountersVM.homeTeam = try await getTeamDetailUserCase.execute(by: homeTeamId)
                previousEncountersVM.awayTeam = try await getTeamDetailUserCase.execute(by: awayTeamId)
            }
            
        }
    }
}

struct TeamDetailByMatch: View {
    var team: Team
    
    var body: some View {
        VStack {
            if let coach = team.coach {
                CoachView(coach: coach)
            }
            ScrollView(showsIndicators: false) {
                if let squad = team.squad {
                    ListSquadView(listSquad: squad, columns: .one)
                }
            }
        }
    }
}
