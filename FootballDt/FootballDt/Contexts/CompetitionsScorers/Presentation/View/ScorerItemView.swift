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
            TeamItemView(team: scorer.team)
            
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
