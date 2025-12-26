//
//  CompetitionsTeamsView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct CompetitionTeamsView: View {
    @EnvironmentObject var competitionsTeamsVM: CompetitionsTeamsViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    
    var body: some View {
        Group {
            switch competitionsTeamsVM.competitionsTeamsStatus {
            case .idle:
                Text("TeamsView idle")
            case .loading:
                ProgressView()
            case .success(let data):
                if let teams = data.teams {
                    if teams.count > 0 {
                        listCompetitionTeamsView(teams: teams)
                    } else {
                        Text("TeamsView empty")
                    }
                } else {
                    Text("TeamsView idle")
                }
                
            case .failure(let error):
                Text("TeamsView failure \(error)")
            }
        }
        /*
        .onAppear{
            guard let competition = listCompetitionVM.competitionSelected.data else { return }
            switch competitionsTeamsVM.competitionsTeamsStatus {
                case .success(data: _):
                    return
                default:
                    Task {
                        await competitionsTeamsVM.getCompetitionsTeams(by: competition.code ?? "", and: nil)
                    }
            }
        }
        */
    }
}


struct listCompetitionTeamsView: View {
    var teams: [Team]
        
    var body: some View {
        ListItemPerPageView(listItem: teams, itemView: getItemView)
    }
    
    @ViewBuilder
    func getItemView(team: Team) -> some View {
        HStack {
            TeamItemView(team: team)
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.body)
                .padding(10)
                .themedBackground(.button())
                .onTapGesture {
                    print("Navigation To Team Detail View")
                }
        }
        
    }
}

struct TeamItemView: View {
    var team: Team
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                if let area = team.area {
                    AreaItemView(area: area, showName: false, imageSize: 20)
                }
                Text(team.shortName ?? "" + "(\(team.founded ?? 0))")
                    .font(.body.bold())
                Spacer()
            }
            .padding(0)
            HStack(spacing: 10) {
                RemoteImageView(urlString: team.crest, size: 50)
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                        Text(team.address ?? "")
                            .font(.caption2)
                    }
                    .padding(0)
                    
                    HStack {
                        Image(systemName: "sportscourt")
                            .font(.caption2)
                        Text(team.venue ?? "")
                            .font(.caption2)
                    }
                    .padding(0)
                    
                    if let runningCompetitions = team.runningCompetitions {
                        HStack(spacing: 30) {
                            ForEach(runningCompetitions, id: \.id) { competition in
                                VStack {
                                    RemoteImageView(urlString: competition.emblem ?? "", size: 40)
                                    //Text(competition.name)
                                        //.font(.caption2)
                                }
                            }
                        }
                        .padding(0)
                    }
                }
                Spacer()
            }
            .padding(0)
        }
        
    }
}

struct TeamItemForScorerView: View {
    var team : Team
    var body: some View {
        HStack(spacing: 5) {
            RemoteImageView(urlString: team.crest, size: 20)
            Text(team.shortName ?? "" + "(\(team.founded ?? 0))")
                .font(.caption.bold())
            Spacer()
        }
    }
}
