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
    
    @EnvironmentObject var matchesByTeamVM: MatchesByTeamViewModel
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
        switch event {
        case .toggleLike(let match):
            print("Like Match detail", match.homeTeam.name ?? "" , match.awayTeam.name ?? "")
            
            //match.like
            matchesByTeamVM.toggleLike(for: match)
        case .viewDetail(let match):
            print("View Match detail", match.homeTeam.name ?? "" , match.awayTeam.name ?? "")
        case .toggleNotify(let match):
            print("Notification Match", match.homeTeam.name ?? "" , match.awayTeam.name ?? "")
        case .analysis(let match):
            print("Analysis Match", match.homeTeam.name ?? "" , match.awayTeam.name ?? "")
        default: return
        }
    }
}


struct MatchItemView: View {
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
                    Image(systemName: match.like ? "heart.fill" : "heart")
                        .font(.caption)
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
                        Image(systemName: match.like ? "heart.fill" : "heart")
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



