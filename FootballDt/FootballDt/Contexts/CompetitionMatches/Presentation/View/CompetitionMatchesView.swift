//
//  CompetitionMatchesView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct CompetitionMatchesView: View {
    @EnvironmentObject var competitionMatchesVM: CompetitionMatchesViewModel
    
    var body: some View {
        switch competitionMatchesVM.competitionMatchesStatus {
        case .idle:
            EmptyView()
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
        case .failure(_):
            EmptyView()
        }
    }
}

struct ListCompetitionMatchView: View {
    
    var listMatch: [Match]
    
    @StateObject private var pagingVM: PagingViewModel<Match>
    
    init(listMatch: [Match]) {
        self.listMatch = listMatch
        _pagingVM = StateObject(wrappedValue: PagingViewModel<Match>(
            items: listMatch,
            itemsPerPage: 10
        ))
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack{
                    ForEach(pagingVM.items, id: \.id) { match in
                        CompetitionMatchItemView(match: match)
                    }
                }
            }
            .padding(.top, 10)
            
            PagingControlsView(
                state: pagingVM.state,
                onPrevious: pagingVM.previousPage,
                onNext: pagingVM.nextPage
            )
        }
    }
}


struct CompetitionMatchItemView: View {
    var match: Match
    
    var body: some View {
        HStack{
            TeamView(team: match.homeTeam)
                .frame(width: UIScreen.main.bounds.width/2 - 100)
            Spacer()
            VStack {
                Text("\(match.eventTime)")
                    .font(.caption2)
                ScoreView(score: match.score)
            }
            
            Spacer()
            TeamView(team: match.awayTeam)
                .frame(width: UIScreen.main.bounds.width/2 - 100)
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
            KFImage(URL(string: team.crest ?? ""))
                .resizable()
                .frame(width: 30, height: 30)
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
