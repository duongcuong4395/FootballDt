//
//  MatchesByTeamView.swift
//  FootballDt
//
//  Created by Macbook on 29/12/25.
//

import SwiftUI

struct MatchesByTeamView: View {
    @EnvironmentObject var matchesByTeamVM: MatchesByTeamViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @Namespace var animation
    @State var selected: Int = 0
    
    var body: some View {
        Group {
            switch matchesByTeamVM.matchesByTeamStatus {
            case .idle:
                Color.clear.onAppear{ loadDataIfNeeded() }
            case .loading:
                Text("Loading Match")
            case .success(let data):
                VStack(alignment: .leading) {
                    if let resultSet = data.resultSet {
                        Text(resultSet.fromDateToDate)
                            .font(.caption2)
                        HStack {
                            Text("Played: \(resultSet.played)")
                                .font(.caption2)
                            Text("Wins: \(resultSet.wins ?? 0)")
                                .font(.caption2)
                            Text("Draws: \(resultSet.draws ?? 0)")
                                .font(.caption2)
                            Text("Losses: \(resultSet.losses ?? 0)")
                                .font(.caption2)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        ForEach(Array(data.matchesByCompetition.enumerated()), id: \.element.id) { index, cp in
                            CompetitionItemView(competition: cp.competition)
                                .padding(10)
                                .themedBackground(.itemSelected(
                                    tintColor: .backgroundColor(for: colorScheme)
                                    , isSelected: selected == index
                                    , animationID: animation, animationName: "MatchByCompetitionMenu"))
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        self.selected = index
                                    }
                                }
                        }
                    }
                    TabView(selection: $selected){
                        ForEach(Array(data.matchesByCompetition.enumerated()), id: \.element.id) { index, cp in
                            ListMatchByTeamView(listMatch: cp.matches ?? [])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.2), value: selected)
                    
                    //ListMatchByTeamView(listMatch: data.matches ?? [])
                }
            case .failure(let error):
                ErrorView(error: error) {
                    loadDataIfNeeded()
                }
            }
        }
        .padding(5)
    }
    
    func loadDataIfNeeded() {
        guard case .success(data: let team) = teamVM.teamStatus else { return }
        
        if case .idle = matchesByTeamVM.matchesByTeamStatus {
            Task {
                await matchesByTeamVM.getMatchesByTeam(by: team.id ?? 0, and: Filters(competitions: availableCompetitionCodes.joined(separator: ",")))
            }
        }
    }
}

struct ResultMatchesByTeamView: View {
    var result: ResultSet
    
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

struct ListMatchByTeamView: View {
    var listMatch: [Match]
    
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnApear = true
    
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var router: FootballDtRouter
    
    init(listMatch: [Match]) {
        self.listMatch = listMatch.sorted { $0.competition.name > $1.competition.name }
    }
    
    var body: some View {
        ListItemPerPageView(
            listItem: listMatch
            , hasEffectOnApear: true
            , showModels: $showModels
            , repeatAnimationOnApear: $repeatAnimationOnApear
            , itemView: getItemView)
    }
    
    @ViewBuilder
    func getItemView(match: Match) -> some View {
        if let index = listMatch.firstIndex(where: { $0.id == match.id })  {
            MatchItemView(
                match: match
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03, onEvent: handleForTeam) // , delay: Double(index) * 0.01
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
}


struct MatchItemView: View {
    var match: Match
    @Binding var isVisible: Bool
    var delay: Double
    var onEvent: (ItemEvent<Team>) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                // MARK: Home Team
                /*
                TeamView(team: match.homeTeam)
                    .frame(width: UIScreen.main.bounds.width/2 - 100)
                    .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
                    .onTapGesture {
                        onEvent(.viewDetail(for: match.homeTeam))
                    }
                */
                TeamName(name: match.awayTeam.shortName ?? "", kindTeam: .HomeTeam)
                    .frame(width: UIScreen.main.bounds.width/2 - (match.score.winner == nil ? 50 : 70))
                    .overlay(alignment: .leading) {
                        TeamBadgeView(teamUrl: match.homeTeam.crest ?? "")
                        /*
                        HStack {
                            TeamBadgeView(teamUrl: match.homeTeam.crest ?? "")
                            Spacer()
                        }
                        */
                    }
                    
                    .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
                    .onTapGesture {
                        onEvent(.viewDetail(for: match.homeTeam))
                    }
                
                Spacer()
                VStack {
                    //Text("\(match.eventTime)")
                        //.font(.caption2.bold())
                    if let _ = match.score.winner {
                        ScoreView(score: match.score)
                            .padding(5)
                            .padding(.horizontal, 10)
                            .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme, color: .blue), cornerRadius: 15))
                    } else {
                        Text(" - ")
                            .font(.caption.bold())
                            .padding(5)
                            .padding(.horizontal, 10)
                            .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme, color: .white), cornerRadius: 20))
                    }
                    
                }
                .transition(.rotate3D())
                
                Spacer()
                /*
                // MARK: Away Team
                TeamView(team: match.awayTeam)
                    .frame(width: UIScreen.main.bounds.width/2 - 100)
                    .slideInEffect(isVisible: $isVisible, delay: delay, direction: .rightToLeft)
                    .onTapGesture {
                        onEvent(.viewDetail(for: match.awayTeam))
                    }
                */
                TeamName(name: match.awayTeam.shortName ?? "", kindTeam: .AwayTeam)
                    .frame(width: UIScreen.main.bounds.width/2 - (match.score.winner == nil ? 50 : 70))
                    .overlay(alignment: .trailing) {
                        HStack {
                            Spacer()
                            TeamBadgeView(teamUrl: match.awayTeam.crest ?? "")
                        }
                    }
                    
                    .slideInEffect(isVisible: $isVisible, delay: delay, direction: .rightToLeft)
                    .onTapGesture {
                        onEvent(.viewDetail(for: match.awayTeam))
                    }
            }
        }
        .padding(.vertical, 20)
    }
}

enum KindTeam {
    case AwayTeam
    case HomeTeam
}

struct TeamName: View {
    var name: String
    var kindTeam: KindTeam
    var body: some View {
        Text(name)
            .fontByDevice(.caption, weight: .medium)
            .foregroundStyle(.white)
            .lineLimit(2)
            .paddingByDevice(.small)
            //.frame(width: UIScreen.main.bounds.width/2 - 50.0)
            .background {
                ArrowShape()
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue, .blue, .blue, .white.opacity(0.1)]), startPoint: .trailing, endPoint: .leading))
                    .rotation3DEffect(Angle(degrees: kindTeam == .HomeTeam ? 0 : 180), axis: (0, 1, 0))
                    .frame(width: UIScreen.main.bounds.width/2 - 50.0)
            }
    }
}

struct TeamBadgeView: View {
    var teamUrl: String
    var body: some View {
        RemoteImageView(urlString: teamUrl, size: 40)
            .offset(y: -25)
    }
}



