//
//  ScorerItemView.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

import SwiftUI

struct ScorerItemView: View {
    var scorer: Scorer
    var hasGrid: Bool = false
    var body: some View {
        if hasGrid {
            VStack(alignment: .leading, spacing: 5) {
                PlayerItemForScorerView(player: scorer.player)
                    .padding(0)
                TeamItemForScorerView(team: scorer.team)
                    .padding(0)
            }
            
            Text("\(scorer.penalties ?? 0)")
                .font(.caption2)
            Text("\(scorer.assists ?? 0)")
                .font(.caption2)
            Text("\(scorer.goals)")
                .font(.caption2.bold())
        } else {
            HStack {
                TeamItemView(team: scorer.team)
                
                Text("\(scorer.penalties ?? 0)")
                    .font(.caption2)
                    
                Text("\(scorer.assists ?? 0)")
                    .font(.caption2)
                    
                Text("\(scorer.goals)")
                    .font(.caption2.bold())
            }
        }
        
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
