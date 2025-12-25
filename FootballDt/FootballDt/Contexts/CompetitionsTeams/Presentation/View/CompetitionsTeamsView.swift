//
//  CompetitionsTeamsView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct CompetitionTeamsView: View {
    @EnvironmentObject var competitionsTeamsVM: CompetitionsTeamsViewModel
    
    var body: some View {
        switch competitionsTeamsVM.competitionsTeamsStatus {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
        case .success(let data):
            listCompetitionTeamsView(teams: data.teams ?? [])
        case .failure(_):
            EmptyView()
        }
    }
}


struct listCompetitionTeamsView: View {
    var teams: [Team]
    
    @StateObject private var pagingVM: PagingViewModel<Team>
    
    init(teams: [Team]) {
        self.teams = teams
        _pagingVM = StateObject(wrappedValue: PagingViewModel<Team>(
            items: teams,
            itemsPerPage: 10
        ))
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(pagingVM.items, id: \.id) { team in
                        TeamItemView(team: team)
                    }
                }
            }
            
            PagingControlsView(
                state: pagingVM.state,
                onPrevious: pagingVM.previousPage,
                onNext: pagingVM.nextPage
            )
        }
    }
}

struct TeamItemView: View {
    
    var team: Team
    
    var body: some View {
        HStack {
            RemoteImageView(urlString: team.crest, size: 50)
            VStack(alignment: .leading) {
                HStack {
                    if let area = team.area {
                        AreaItemView(area: area, showName: false, imageSize: 20)
                    }
                    Text(team.shortName ?? "" + "(\(team.founded ?? 0))")
                        .font(.caption.bold())
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption2)
                    Text(team.address ?? "")
                        .font(.caption2)
                }
                
                HStack {
                    Image(systemName: "sportscourt")
                        .font(.caption2)
                    Text(team.venue ?? "")
                        .font(.caption2)
                }
                
                
                HStack(spacing: 30) {
                    ForEach(team.runningCompetitions ?? [], id: \.id) { competition in
                        VStack {
                            RemoteImageView(urlString: competition.emblem ?? "", size: 40)
                            //Text(competition.name)
                                //.font(.caption2)
                        }
                    }
                }
                
            }
            Spacer()
            
        }
        .padding()
    }
}
