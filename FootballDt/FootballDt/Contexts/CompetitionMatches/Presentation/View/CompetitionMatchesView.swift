//
//  CompetitionMatchesView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct CompetitionMatchesView: View {
    @EnvironmentObject var competitionMatchesVM: CompetitionMatchesViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    
    var body: some View {
        VStack {
            switch competitionMatchesVM.competitionMatchesStatus {
            case .idle:
                Color.clear.onAppear{ loadDataIfNeeded() }
            case .loading:
                ProgressView("Loading matches...")
            case .success(let data):
                if !data.matches.isEmpty {
                    VStack {
                        Text("\(data.resultSet?.fromDateToDate ?? "")")
                            .font(.caption2)
                        Text("\(data.resultSet?.played ?? 0)/\(data.resultSet?.count ?? 0)")
                            .font(.caption2)
                        ListCompetitionMatchView(listMatch: data.matches)
                    }
                    .padding(.top, 10)
                } else {
                    EmptyStateView(message: "No matches found")
                }
            case .failure(let error):
                ErrorView(error: error) {
                    loadDataIfNeeded()
                }
            }
        }
    }
    
    func loadDataIfNeeded() {
        guard case .success(data: let competition) = listCompetitionVM.competitionSelected else { return }
        
        if case .idle = competitionMatchesVM.competitionMatchesStatus {
            Task {
                await competitionMatchesVM.getCompetitionMatches(by: "\(competition.id)", and: nil)
            }
        }
        
    }
}

struct ListCompetitionMatchView: View {
    var listMatch: [Match]
    
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnApear = true
    
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var router: FootballDtRouter
    
    var body: some View {
        ListItemPerPageView(
            listItem: listMatch
            , hasEffectOnApear: true
            , showModels: $showModels
            , repeatAnimationOnApear: $repeatAnimationOnApear
            , itemView: getItemView)
    }
    
    @ViewBuilder
    func getItemView(match: Match) -> some View {
        if let index = listMatch.firstIndex(where: { $0.id == match.id })  {
            MatchItemView(
                match: match
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03, onEvent: handleForTeam) // , delay: Double(index) * 0.01
        }
    }
    
    func handleForTeam(event: ItemEvent<Team>) {
        if case .viewDetail(let team) = event {
            Task {
                await teamVM.getTeamDetail(by: team.id ?? 0)
                withAnimation(.spring()) {
                    router.navigationTeamDetail()
                }
                
            }
        }
        
    }
}




import Kingfisher





struct TeamView: View {
    var team: Team
    
    var body: some View {
        VStack {
            Text(team.shortName ?? "")
                .font(.caption.bold())
            
            RemoteImageView(urlString: team.crest ?? "", size: 30)
        }
    }
}

struct ScoreView: View {
    var score: Score
    
    var body: some View {
        VStack {
            Text("\(score.halfTime.home ?? 0) - \(score.halfTime.away ?? 0)")
                .font(.caption2.bold())
            Text("\(score.fullTime.home ?? 0) - \(score.fullTime.away ?? 0)")
                .font(.caption2.bold())
        }
    }
}

