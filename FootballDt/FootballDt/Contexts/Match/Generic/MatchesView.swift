//
//  MatchesView.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

//  Refactored main views using shared components
//

import SwiftUI

// MARK: - Matches by Competition View (Refactored)

struct MatchesByCompetitionView: View {
    @EnvironmentObject var matchesByCompetitionVM: MatchesByCompetitionViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    
    @StateObject private var aiAnalysisManager: MatchAIAnalysisManager
    
    init() {
        let coordinator = AIAnalysisCoordinator()
        _aiAnalysisManager = StateObject(wrappedValue: MatchAIAnalysisManager(aiCoordinator: coordinator))
    }
    
    var body: some View {
        MatchesContainerView(
            viewModel: matchesByCompetitionVM
            , teamVM: teamVM
            , router: router
            , matchDetailVM: matchDetailVM, aiAnalysisManager: aiAnalysisManager
            , onTeamEvent: handleTeamEvent
            , loadAction: loadDataIfNeeded)
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
}

// MARK: - Matches By Team View (Refactored)

struct MatchesByTeamView: View {
    
    @EnvironmentObject var matchesByTeamVM: MatchesByTeamViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    
    @StateObject private var aiAnalysisManager: MatchAIAnalysisManager
    
    init() {
        let coordinator = AIAnalysisCoordinator()
        _aiAnalysisManager = StateObject(wrappedValue: MatchAIAnalysisManager(aiCoordinator: coordinator))
    }
    
    var body: some View {
        MatchesContainerView(
            viewModel: matchesByTeamVM
            , teamVM: teamVM
            , router: router
            , matchDetailVM: matchDetailVM, aiAnalysisManager: aiAnalysisManager
            , onTeamEvent: handleTeamEvent
            , loadAction: loadDataIfNeeded)
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
}

// MARK: Matches By Previous Encounters View

struct MatchesByPreviousEncountersView: View {
    @EnvironmentObject var previousEncountersVM: PreviousEncountersViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    
    @StateObject private var aiAnalysisManager: MatchAIAnalysisManager
    
    init() {
        let coordinator = AIAnalysisCoordinator()
        _aiAnalysisManager = StateObject(wrappedValue: MatchAIAnalysisManager(aiCoordinator: coordinator))
    }
    
    var body: some View {
        VStack {
            /*
            if let aggregates = previousEncountersVM.aggregates {
                AggregatesView(aggregates: aggregates)
            }
            */
            MatchesContainerView(
                viewModel: previousEncountersVM
                , teamVM: teamVM
                , router: router
                , matchDetailVM: matchDetailVM
                , aiAnalysisManager: aiAnalysisManager
                , kindMatchView: .NoneAction
                , onTeamEvent: { _ in }
                , loadAction: loadDataIfNeeded)
            
        }
    }
    
    func loadDataIfNeeded() {
        guard case .success(let match) = matchDetailVM.state else { return }
        
        if case .idle = previousEncountersVM.state {
            Task {
                await previousEncountersVM.getPreviousEncounters(by: match.id, and: nil)
            }
        }
    }
}

struct AggregatesView: View {
    
    var aggregates: Aggregates
    
    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35))
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("Number of matches: \(aggregates.numberOfMatches)")
                    .font(.caption.bold())
            }
            HStack {
                Text("Total goals: \(aggregates.totalGoals)")
                    .font(.caption.bold())
            }
            
            LazyVGrid(columns: columns, alignment: .leading) {
                Group {
                    Text("Team")
                    Text("Wins")
                    Text("Draws")
                    Text("Losses")
                }.font(.caption2.bold())
                
                Group {
                    Text(aggregates.homeTeam.name).font(.caption.bold())
                    Text("\(aggregates.homeTeam.wins)").font(.caption2)
                    Text("\(aggregates.homeTeam.draws)").font(.caption2)
                    Text("\(aggregates.homeTeam.losses)").font(.caption2)
                }
                Group {
                    Text(aggregates.awayTeam.name).font(.caption.bold())
                    Text("\(aggregates.awayTeam.wins)").font(.caption2)
                    Text("\(aggregates.awayTeam.draws)").font(.caption2)
                    Text("\(aggregates.awayTeam.losses)").font(.caption2)
                }
            }
        }
    }
}
