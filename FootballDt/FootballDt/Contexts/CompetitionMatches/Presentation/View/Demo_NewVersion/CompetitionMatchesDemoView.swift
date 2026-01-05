//
//  CompetitionMatchesDemoView.swift
//  FootballDt
//
//  Created by Macbook on 5/1/26.
//

import SwiftUI

struct CompetitionMatchesDemoView: View {
    @EnvironmentObject var competitionMatchesVM: CompetitionMatchesViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    
    var body: some View {
        VStack {
            if case .success(_) = competitionMatchesVM.state {
               ForEach(competitionMatchesVM.allModels()) { match in
                   MatchRow(match: match, viewModel: competitionMatchesVM)
               }
            }
        }
        .task {
            guard case .success(data: let competition) = listCompetitionVM.competitionSelected else { return }
            Task {
                await competitionMatchesVM.loadMatches(by: "\(competition.id)", and: nil)
            }
        }
    }
}


struct MatchRow: View {
    let match: Match
    @ObservedObject var viewModel: CompetitionMatchesViewModel
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let currentMatch = viewModel.mutatedModel(withId: match.id) ?? match
                        
            HStack {
                Text(match.homeTeam.name ?? "")
                    .font(.headline)
                
                Spacer()
                
                Text("\(match.score.fullTime.home ?? 0)")
                    .font(.title2)
                    .bold()
            }
            
            HStack {
                Text(match.awayTeam.name ?? "")
                    .font(.headline)
                
                Spacer()
                
                Text("\(match.score.fullTime.away ?? 0)")
                    .font(.title2)
                    .bold()
            }
            
            HStack {
                Text(match.eventTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                StatusBadge(status: match.status)
                
                // Like button
                Button(action: {
                    viewModel.toggleLike(matchId: match.id)
                }) {
                    Image(systemName: currentMatch.like ? "heart.fill" : "heart")
                        .foregroundColor(match.like ? .red : .gray)
                }
                
                // Mutation indicator
                if viewModel.hasMutations(for: match.id) {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}


struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(statusText)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    var statusText: String {
        switch status {
        case "SCHEDULED", "TIMED": return "Upcoming"
        case "IN_PLAY": return "Live"
        case "FINISHED": return "Finished"
        default: return status
        }
    }
    
    var statusColor: Color {
        switch status {
        case "SCHEDULED", "TIMED": return .blue
        case "IN_PLAY": return .green
        case "FINISHED": return .gray
        default: return .secondary
        }
    }
}
