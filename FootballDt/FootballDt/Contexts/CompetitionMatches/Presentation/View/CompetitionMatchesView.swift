//
//  CompetitionMatchesView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct CompetitionMatchesView: View {
    @EnvironmentObject var competitionMatchesVM: CompetitionMatchesViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    
    var body: some View {
        //CompetitionMatchesDemoView()
        VStack {
            switch competitionMatchesVM.state {
            case .idle: Color.clear.onAppear{ loadDataIfNeeded() }
            case .success(let data): ListCompetitionMatchView(listMatch: data)
            case .loading(previous: let matches): ProgressView("Loading matches...")
            case .failure(let stateError, previous: let matches): ErrorView(error: "error") { loadDataIfNeeded() }
            }
        }
        
        /*
        VStack {
            switch competitionMatchesVM.competitionMatchesStatus {
            case .idle:
                Color.clear.onAppear{ loadDataIfNeeded() }
            case .loading:
                ProgressView("Loading matches...")
            case .success(let data):
                if !data.matches.isEmpty {
                    VStack {
                        Text("\(data.resultSet?.fromDateToDate ?? "")")
                            .font(.caption2)
                        Text("\(data.resultSet?.played ?? 0)/\(data.resultSet?.count ?? 0)")
                            .font(.caption2)
                        ListCompetitionMatchView(listMatch: data.matches)
                    }
                    .padding(.top, 10)
                } else {
                    EmptyStateView(message: "No matches found")
                }
            case .failure(let error):
                ErrorView(error: error) {
                    loadDataIfNeeded()
                }
            }
        }
        */
    }
    
    func loadDataIfNeeded() {
        guard case .success(data: let competition) = listCompetitionVM.competitionSelected else { return }
        
        if case .idle = competitionMatchesVM.state {
            Task {
                await competitionMatchesVM.loadMatches(by: "\(competition.id)", and: nil)
            }
            
        }
    }
}

struct ListCompetitionMatchView: View {
    var listMatch: [Match]
    
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnApear = true
    
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var competitionMatchesVM: CompetitionMatchesViewModel
    
    var body: some View {
        VStack {
            Text("matches \(listMatch.count)")
            ListItemPerPageView(
                listItem: listMatch
                , hasEffectOnApear: true
                , showModels: $showModels
                , repeatAnimationOnApear: $repeatAnimationOnApear
                , itemView: getItemView)
        }
        
    }
    
    @ViewBuilder
    func getItemView(match: Match) -> some View {
        if let index = listMatch.firstIndex(where: { $0.id == match.id })  {
            MatchItemView_New(
                stateStoreVM: competitionMatchesVM
                , match: match
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03
                , onEventTeam: handleForTeam
                , onEventMatch: handleForMatch
            )
        }
    }
    
    func handleForTeam(event: ItemEvent<Team>) {
        if case .viewDetail(let team) = event {
            Task {
                await teamVM.getTeamDetail(by: team.id ?? 0)
                withAnimation(.spring()) {
                    router.navigationTeamDetail()
                }
                
            }
        }
        
    }
    
    func handleForMatch(event: ItemEvent<Match>) {
        if case .viewDetail(let match) = event {
            print("View Match detail", match.homeTeam.name ?? "" , match.awayTeam.name ?? "")
        }
        
        if case .analysis(for: let match) = event {
            print("Analysis Match", match.homeTeam.name ?? "" , match.awayTeam.name ?? "")
        }
        
        if case .toggleLike(for: let match) = event {
            
            competitionMatchesVM.toggleLike(matchId: match.id)
        }
        
        
    }
}




import Kingfisher





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





struct MatchItemView_New<ss: StateStore<Match>>: View {
    @ObservedObject var stateStoreVM: ss
    var match: Match
    @Binding var isVisible: Bool
    var delay: Double
    
    var onEventTeam: (ItemEvent<Team>) -> Void
    var onEventMatch: (ItemEvent<Match>) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showingTooltipMenu = false
    
    @Namespace var animation
    
    var body: some View {
        VStack(alignment: .leading) {
            let currentMatch = stateStoreVM.mutatedModel(withId: match.id) ?? match
            HStack{
                // MARK: Home Team
                TeamName(name: match.awayTeam.shortName ?? "", kindTeam: .HomeTeam)
                    .frame(width: UIScreen.main.bounds.width/2 - (match.score.winner == nil ? 50 : 70))
                    .overlay(alignment: .leading) {
                        TeamBadgeView(teamUrl: match.homeTeam.crest ?? "")
                    }
                    .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
                    .onTapGesture {
                        onEventTeam(.viewDetail(for: match.homeTeam))
                    }
                
                Spacer()
                VStack {
                    if !showingTooltipMenu {
                        Image(systemName: "chevron.compact.up")
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    if let _ = match.score.winner {
                        ScoreView(score: match.score)
                            .padding(5)
                    } else {
                        Text(" - ")
                            .font(.caption.bold())
                            .padding(5)
                    }
                }
                .padding(.horizontal, 10)
                .themedBackground(
                    .card(
                        tintColor: .backgroundColor(
                            for: colorScheme
                            , color: match.score.winner == nil ? .white : .blue)
                          , cornerRadius: 10))
                .transition(.rotate3D())
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showingTooltipMenu.toggle()
                    }
                }
                
                Spacer()
                // MARK: Away Team
                TeamName(name: match.awayTeam.shortName ?? "", kindTeam: .AwayTeam)
                    .frame(width: UIScreen.main.bounds.width/2 - (match.score.winner == nil ? 50 : 70))
                    .overlay(alignment: .trailing) {
                        TeamBadgeView(teamUrl: match.awayTeam.crest ?? "")
                    }
                    .slideInEffect(isVisible: $isVisible, delay: delay, direction: .rightToLeft)
                    .onTapGesture {
                        onEventTeam(.viewDetail(for: match.awayTeam))
                    }
            }
            .overlay(alignment: .topLeading) {
                Text("\(match.eventTime)")
                    .font(.caption2.bold())
                    .offset(x: 40, y: -15)
            }
            .popover(isPresented: $showingTooltipMenu, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.caption)
                        Text("AI analysis")
                    }
                    .presentationBackground(.clear)
                    .onTapGesture {
                        onEventMatch(.analysis(for: match))
                    }
                    
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.caption)
                        Text("View Detail")
                    }
                    .presentationBackground(.clear)
                    .onTapGesture {
                        onEventMatch(.viewDetail(for: match))
                    }
                    
                    HStack {
                        Image(systemName: "bell")
                            .font(.caption)
                        Text("Notification")
                    }
                    .presentationBackground(.clear)
                    .onTapGesture {
                        onEventMatch(.toggleNotify(for: match))
                    }
                    
                    HStack {
                        Image(systemName: currentMatch.like ? "heart.fill" : "heart")
                            .font(.caption)
                        Text("Favorite")
                    }
                    .presentationBackground(.clear)
                    .onTapGesture {
                        onEventMatch(.toggleLike(for: match))
                    }
                }
                .padding(10)
                .presentationBackground(.clear)
                .presentationCompactAdaptation(.popover)
                .themedBackground(.card())
            }
        }
        .padding(.top, 40)
        
        
    }
}
