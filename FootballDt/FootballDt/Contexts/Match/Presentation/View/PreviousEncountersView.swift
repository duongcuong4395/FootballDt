//
//  PreviousEncountersView.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

import SwiftUI


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



