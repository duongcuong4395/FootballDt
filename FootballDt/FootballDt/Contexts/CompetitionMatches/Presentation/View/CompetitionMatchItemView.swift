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
            
            Spacer()
            // MARK: Away Team
            TeamView(team: match.awayTeam)
                .frame(width: UIScreen.main.bounds.width/2 - 100)
                .slideInEffect(isVisible: $isVisible, delay: delay, direction: .rightToLeft)
        }
        .onAppear{
            withAnimation{
                isVisible = true
            }
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

