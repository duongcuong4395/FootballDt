//
//  MatchDetailRouteContentView.swift
//  FootballDt
//
//  Created by Macbook on 8/1/26.
//

import SwiftUI



struct Head2HeadDetailView: View {
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    @EnvironmentObject var matchesByHeadToHeadVM: MatchesByHeadToHeadViewModel
    
    var body: some View {
        HStack {
            if let homeTeam = matchesByHeadToHeadVM.homeTeam {
                TeamDetailByMatch(team: homeTeam)
            }
                
            if let awayTeam = matchesByHeadToHeadVM.awayTeam {
                TeamDetailByMatch(team: awayTeam)
            }
        }
        .onAppear{
            guard matchesByHeadToHeadVM.homeTeam == nil && matchesByHeadToHeadVM.awayTeam == nil else { return }
            
            guard case .success(let match) = matchDetailVM.state else { return }
            
            let teamAPIService = TeamAPIService()
            let getTeamDetailUserCase = GetTeamDetailUserCase(repository: teamAPIService)
            
            guard let homeTeamId = match.homeTeam.id else { return }
            guard let awayTeamId = match.awayTeam.id else { return }
            Task {
                matchesByHeadToHeadVM.homeTeam = try await getTeamDetailUserCase.execute(by: homeTeamId)
                matchesByHeadToHeadVM.awayTeam = try await getTeamDetailUserCase.execute(by: awayTeamId)
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
