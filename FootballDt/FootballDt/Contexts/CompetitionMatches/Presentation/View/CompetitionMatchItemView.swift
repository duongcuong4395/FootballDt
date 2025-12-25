//
//  CompetitionMatchItemView.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

import SwiftUI
import Kingfisher

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

