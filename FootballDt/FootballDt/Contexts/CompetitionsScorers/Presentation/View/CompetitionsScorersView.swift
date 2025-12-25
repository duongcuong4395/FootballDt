//
//  CompetitionsScorersView.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

import SwiftUI

struct CompetitionScorersView: View {
    @EnvironmentObject var competitionScorersVM: CompetitionsScorersViewModel
    
    var body: some View {
        switch competitionScorersVM.competitionsScorersStatus {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
        case .success(let data):
            ListScorerView(scorers: data.scorers ?? [])
        case .failure(_):
            EmptyView()
        }
    }
}

struct ListScorerView: View {
    var scorers: [Scorer]
    
    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.fixed(30)),
        GridItem(.fixed(30)),
        GridItem(.fixed(30))
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
                .font(.caption2)
            Text("Pen")
                .font(.caption2)
            Text("assists")
                .font(.caption2)
            Text("goals")
                .font(.caption2)
        })
    }
}



