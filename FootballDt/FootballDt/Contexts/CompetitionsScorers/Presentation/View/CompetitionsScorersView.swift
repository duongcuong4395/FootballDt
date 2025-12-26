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
    
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnApear = true
    
    var body: some View {
        ListItemPerPageView(
            listItem: scorers, grid: (columns, getHeaderView)
            , hasEffectOnApear: true
            , showModels: $showModels
            , repeatAnimationOnApear: $repeatAnimationOnApear
            , itemView: getItemView)
        
    }
    
    @ViewBuilder
    func getItemView(scorer: Scorer) -> some View {
        
        if let index = scorers.firstIndex(where: { $0.id == scorer.id })  {
            ScorerItemView(
                scorer: scorer
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03)
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
            
            
            Text("\(scorer.penalties ?? 0)").font(.caption2)
            Text("\(scorer.assists ?? 0)").font(.caption2)
            Text("\(scorer.goals)").font(.caption2.bold())
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
                Image(systemName: "figure.arms.open") // figure.soccer
                    .font(.caption)
                Text("\(player.section)")
                    .font(.caption)
            }
            
        }
        
        
    }
}


