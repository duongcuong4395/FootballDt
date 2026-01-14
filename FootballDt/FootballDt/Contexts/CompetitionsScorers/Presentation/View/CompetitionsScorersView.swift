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
        VStack {
            switch competitionScorersVM.competitionsScorersStatus {
            case .idle:
                Color.clear.onAppear{ loadDataIfNeeded() }
            case .loading:
                ProgressView("Loading scorers...")
            case .success(let data):
                if let scorers = data.scorers, !scorers.isEmpty {
                    ListScorerView(scorers: scorers)
                } else {
                    EmptyStateView(message: "No scorers found")
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
        
        if case .idle = competitionScorersVM.competitionsScorersStatus {
            Task {
                await competitionScorersVM.getCompetitionsScorers(by: competition.code ?? "", and: Filters(season: nil, limit: 300))
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
    
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnApear = true
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        PaginatedGrid(
            dataSource: InMemoryDataSource(items: scorers)
            , columns: columns
            , configuration: PaginationConfiguration(pageSize: 10)
            , header: getHeaderView
            , content: getItemView
        ).onAppear{
            withAnimation {
                if showModels.count != scorers.count {
                    self.showModels = Array(repeating: false, count: scorers.count)
               }
            }
        }
        
        /*
        ListItemPerPageView(
            listItem: scorers, grid: (columns, getHeaderView)
            , hasEffectOnApear: true
            , showModels: $showModels
            , repeatAnimationOnApear: $repeatAnimationOnApear
            , itemView: getItemView)
        */
    }
    
    @ViewBuilder
    func getItemView(scorer: Scorer) -> some View {
        
        if let index = scorers.firstIndex(where: { $0.id == scorer.id })  {
            ScorerItemView(
                scorer: scorer
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03)
            .onAppear{
                guard showModels.count > 0 else { return }
                guard showModels[index] == false else { return }
                withAnimation {
                    showModels[index] = true
                }
            }
        }
    }
    
    
    @ViewBuilder
    func getHeaderView() -> AnyView {
        AnyView(Group{
            Text("Team")
            Text("Penalties")
            Text("Assists")
            Text("Goals")
        }.font(.caption2.bold()))
    }
}

struct ScorerItemView: View {
    var scorer: Scorer
    
    @Binding var isVisible: Bool
    var delay: Double
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 5) {
                PlayerItemForScorerView(player: scorer.player)
                    .padding(0)
                TeamItemForScorerView(team: scorer.team)
                    .padding(0)
            }
            
            Text("\(scorer.penalties ?? 0)").font(.caption)
            Text("\(scorer.assists ?? 0)").font(.caption)
            Text("\(scorer.goals)").font(.caption.bold())
        }
        .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
    }
}


struct PlayerItemForScorerView: View {
    var player: Player
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(player.name)
                    .font(.body.bold())
            }
            HStack {
                Image(systemName: "birthday.cake")
                    .font(.caption)
                Text(player.nationality)
                    .font(.caption)
                + Text(" (\(player.birthDate))")
                    .font(.caption)
            }
            HStack{
                Image(systemName: "figure.arms.open") 
                    .font(.caption)
                Text("\(player.section)")
                    .font(.caption)
            }
            
        }
        
        
    }
}


