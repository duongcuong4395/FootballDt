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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {

            switch competitionsTeamsVM.competitionsTeamsStatus {
            case .idle:
                Color.clear.onAppear{ loadDataIfNeeded() }
            case .loading:
                
                Text("Loading teams...")
            case .success(let data):
                if let teams = data.teams, !teams.isEmpty {
                    listCompetitionTeamsView(teams: teams)
                } else {
                    EmptyStateView(message: "No teams found")
                }
            case .failure(let error):
                //Text("TeamsView failure \(error)")
                ErrorView(error: error) {
                    loadDataIfNeeded()
                }
            }
            
        }
        
    }
    
    private func loadDataIfNeeded() {
        guard case .success(data: let competition) = listCompetitionVM.competitionSelected else { return }
        
        if case .idle = competitionsTeamsVM.competitionsTeamsStatus {
            Task {
                await competitionsTeamsVM.getCompetitionsTeams(by: competition.code ?? "", and: nil)
            }
        }
    }
}


struct listCompetitionTeamsView: View {
    var teams: [Team]
        
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnApear = true
    
    // Router
    @EnvironmentObject var router: FootballDtRouter
    // for navigation to Team Detail View
    @EnvironmentObject var teamVM: TeamViewModel
    
    var body: some View {
        ListItemPerPageView(
            listItem: teams
            , hasEffectOnApear: true
            , showModels: $showModels
            , repeatAnimationOnApear: $repeatAnimationOnApear
            , itemView: getItemView)
    }
    
    @ViewBuilder
    func getItemView(team: Team) -> some View {
        if let index = teams.firstIndex(where: { $0.id == team.id })  {
            TeamItemForCompetitionView(
                team: team
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03
                , itemBuilder: ItemBuilderForCompetitionTeam()
                , onEvent: handleEvent)
        }
    }
    
    func handleEvent(_ event: ItemEvent<Team>) -> Void {
        switch event {
        case .viewDetail(for: let team):
            teamVM.setTeam(by: team)
            router.navigationTeamDetail()
            //print("Navigation To Team Detail View", team.id ?? 0, team.name ?? "")
            return
            
        default: return
        }
    }
}

struct ItemBuilderForCompetitionTeam: ItemBuilder {
    func buildOptions(for item: Team, send: @escaping (ItemEvent<Team>) -> Void) -> AnyView {
        AnyView(Image(systemName: "chevron.right")
            .font(.body)
            .padding(10)
            .themedBackground(.button())
            .onTapGesture {
                send(.viewDetail(for: item))
            })
    }
}

struct TeamItemForCompetitionView<Builder: ItemBuilder>: View where Builder.T == Team {
    var team: Team
    
    @Binding var isVisible: Bool
    var delay: Double
    
    var itemBuilder: Builder
    var onEvent: (ItemEvent<Team>) -> Void
    
    var body: some View {
        HStack {
            TeamItemView(team: team)
                .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
            Spacer()
            itemBuilder.buildOptions(for: team, send: onEvent)
                .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
        }
        .onAppear{
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: Item View

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


