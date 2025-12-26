//
//  CompetitionsScorersView.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

import SwiftUI

struct CompetitionScorersView: View {
    @EnvironmentObject var competitionScorersVM: CompetitionsScorersViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    
    var body: some View {
        Group {
            switch competitionScorersVM.competitionsScorersStatus {
            case .idle:
                Text("ScorersView idle")
            case .loading:
                Text("ScorersView loading")
            case .success(let data):
                if let scorers = data.scorers {
                    ListScorerView(scorers: scorers)
                } else {
                    Text("empty")
                }
                
            case .failure(_):
                Text("ScorersView failure")
            }
        }
    }
}

struct ListScorerView: View {
    var scorers: [Scorer]
    
    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.fixed(60)),
        GridItem(.fixed(40)),
        GridItem(.fixed(40))
    ]
    
    var body: some View {
        ListItemPerPageView(listItem: scorers, grid: (columns, getHeaderView), itemView: getItemView)
    }
    
    @ViewBuilder
    func getItemView(scorer: Scorer) -> some View {
        ScorerItemView(scorer: scorer, hasGrid: true)
    }
    
    @ViewBuilder
    func getHeaderView() -> AnyView {
        AnyView(Group{
            Text("Team")
                .font(.caption2.bold())
            Text("Penalties")
                .font(.caption2.bold())
            /*
            HStack(spacing: 0) {
                Image(systemName: "figure.soccer")
                    .font(.caption2)
                Image(systemName: "figure.run")
                    .font(.caption2)
            }
            */
            Text("Assists").font(.caption2.bold())
            
            Text("Goals")
                .font(.caption2.bold())
        })
    }
}



