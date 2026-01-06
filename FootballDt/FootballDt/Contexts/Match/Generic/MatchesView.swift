//
//  MatchesView.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

//  Refactored main views using shared components
//

import SwiftUI

// MARK: - Competition Matches View (Refactored)

struct CompetitionMatchesView: View {
    @EnvironmentObject var matchesByCompetitionVM: MatchesByCompetitionViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var router: FootballDtRouter
    
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    
    var body: some View {
        MatchesContainerView(
            viewModel: matchesByCompetitionVM,
            onTeamEvent: handleTeamEvent,
            onMatchEvent: handleMatchEvent,
            loadAction: loadDataIfNeeded
        )
    }
    
    private func loadDataIfNeeded() {
        guard case .success(data: let competition) = listCompetitionVM.competitionSelected else { return }
        
        if case .idle = matchesByCompetitionVM.state {
            Task {
                await matchesByCompetitionVM.loadMatches(
                    by: "\(competition.id)",
                    and: nil
                )
            }
        }
    }
    
    private func handleTeamEvent(_ event: ItemEvent<Team>) {
        switch event {
        case .viewDetail(let team):
            Task {
                await teamVM.getTeamDetail(by: team.id ?? 0)
                withAnimation(.spring()) {
                    router.navigationTeamDetail()
                }
            }
        default:
            break
        }
    }
    
    private func handleMatchEvent(_ event: ItemEvent<Match>) {
        switch event {
        case .toggleLike(let match):
            matchesByCompetitionVM.toggleLike(matchId: match.id)
            
        case .viewDetail(let match):
            router.navigationMatchDetail()
            
            matchDetailVM.setState(.success(match))
            
            
        case .analysis(let match):
            print("Analysis Match", match.homeTeam.name ?? "", match.awayTeam.name ?? "")
            
        case .toggleNotify(let match):
            matchesByCompetitionVM.toggleNotify(matchId: match.id)
        default:
            break
        }
    }
}

// MARK: - Matches By Team View (Refactored)

struct MatchesByTeamView: View {
    @EnvironmentObject var matchesByTeamVM: MatchesByTeamViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    var body: some View {
        MatchesContainerView(
            viewModel: matchesByTeamVM,
            onTeamEvent: handleTeamEvent,
            onMatchEvent: handleMatchEvent,
            loadAction: loadDataIfNeeded
        )
    }
    
    private func loadDataIfNeeded() {
        guard case .success(data: let team) = teamVM.teamStatus else { return }
        
        if case .idle = matchesByTeamVM.state {
            Task {
                await matchesByTeamVM.loadMatches(
                    by: team.id ?? 0,
                    and: Filters(competitions: availableCompetitionCodes.joined(separator: ","))
                )
            }
        }
    }
    
    private func handleTeamEvent(_ event: ItemEvent<Team>) {
        switch event {
        case .viewDetail(let team):
            guard case .success(data: let team2) = teamVM.teamStatus
                    , team2.id != team.id
            else { return }
            
            Task {
                
                withAnimation(.spring()){
                    matchesByTeamVM.setState(.loading(previous: []))
                }
                await teamVM.getTeamDetail(by: team.id ?? 0)
                withAnimation(.spring()){
                    matchesByTeamVM.setState(.idle)
                }
                // withAnimation(.spring()) {
                    //router.navigationTeamDetail()
                //}
            }
        default:
            break
        }
    }
    
    private func handleMatchEvent(_ event: ItemEvent<Match>) {
        switch event {
        case .toggleLike(let match):
            matchesByTeamVM.toggleLike(matchId: match.id)
            
        case .viewDetail(let match):
            matchDetailVM.setState(.success(match))
            router.navigationMatchDetail()
            
        case .analysis(let match):
            print("Analysis Match", match.homeTeam.name ?? "", match.awayTeam.name ?? "")
            
        case .toggleNotify(let match):
            
            matchesByTeamVM.toggleNotify(matchId: match.id)
        default:
            break
        }
    }
}

