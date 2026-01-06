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
            print("View Match detail", match.homeTeam.name ?? "", match.awayTeam.name ?? "")
            
        case .analysis(let match):
            print("Analysis Match", match.homeTeam.name ?? "", match.awayTeam.name ?? "")
            
        case .toggleNotify(let match):
            print("Toggle notification for match", match.id)
            
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
            matchesByTeamVM.toggleLike(matchId: match.id)
            
        case .viewDetail(let match):
            print("View Match detail", match.homeTeam.name ?? "", match.awayTeam.name ?? "")
            
        case .analysis(let match):
            print("Analysis Match", match.homeTeam.name ?? "", match.awayTeam.name ?? "")
            
        case .toggleNotify(let match):
            print("Toggle notification for match", match.id)
            
        default:
            break
        }
    }
}

