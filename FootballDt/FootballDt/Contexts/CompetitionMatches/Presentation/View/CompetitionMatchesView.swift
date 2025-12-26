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
        Group {
            switch competitionMatchesVM.competitionMatchesStatus {
            case .idle:
                Text("MatchesView idle")
            case .loading:
                ProgressView()
            case .success(let data):
                VStack {
                    Text("\(data.resultSet?.fromDateToDate ?? "")")
                        .font(.caption2)
                    Text("\(data.resultSet?.played ?? 0)/\(data.resultSet?.count ?? 0)")
                        .font(.caption2)
                    
                    ListCompetitionMatchView(listMatch: data.matches)
                }
                .padding(.top, 10)
            case .failure(let error):
                Text("MatchesView failure \(error)")
            }
        }
    }
}

struct ListCompetitionMatchView: View {
    var listMatch: [Match]
    
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnApear = true
    
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
            CompetitionMatchItemView(
                match: match
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03) // , delay: Double(index) * 0.01
        }
    }
}




import Kingfisher

struct CompetitionMatchItemView: View {
    var match: Match
    @Binding var isVisible: Bool
    var delay: Double
    
    
    var body: some View {
        HStack{
            // MARK: Home Team
            TeamView(team: match.homeTeam)
                .frame(width: UIScreen.main.bounds.width/2 - 100)
                .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
            Spacer()
            VStack {
                Text("\(match.eventTime)")
                    .font(.caption2)
                ScoreView(score: match.score)
            }
            .slideInEffect(isVisible: $isVisible, delay: delay, direction: .topToBottom)
            
            Spacer()
            // MARK: Away Team
            TeamView(team: match.awayTeam)
                .frame(width: UIScreen.main.bounds.width/2 - 100)
                .slideInEffect(isVisible: $isVisible, delay: delay, direction: .rightToLeft)
        }
    }
}



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

