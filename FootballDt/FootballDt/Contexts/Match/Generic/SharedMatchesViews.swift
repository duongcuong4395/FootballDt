//
//  SharedMatchesViews.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//
//  Shared UI components for displaying matches
//

import SwiftUI

enum KindTeam {
    case AwayTeam
    case HomeTeam
}

// MARK: - Generic Matches Container View

struct MatchesContainerView<VM: BaseMatchesViewModel>: View {
    @ObservedObject var viewModel: VM
    
    var onTeamEvent: (ItemEvent<Team>) -> Void
    var onMatchEvent: (ItemEvent<Match>) -> Void
    var loadAction: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @Namespace var animation
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .idle:
                Color.clear.onAppear { loadAction() }
                
            case .loading(previous: let matches):
                ProgressView("Loading matches...")
                
            case .success(let matches):
                MatchesSuccessView(
                    viewModel: viewModel,
                    matches: matches,
                    onTeamEvent: onTeamEvent,
                    onMatchEvent: onMatchEvent
                )
                
            case .failure(let error, previous: let matches):
                ErrorView(error: error.localizedDescription) {
                    loadAction()
                }
            }
        }
    }
}

// MARK: - Success State View with Competition Tabs

struct MatchesSuccessView<VM: BaseMatchesViewModel>: View {
    @ObservedObject var viewModel: VM
    let matches: [Match]
    
    var onTeamEvent: (ItemEvent<Team>) -> Void
    var onMatchEvent: (ItemEvent<Match>) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @Namespace var animation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Result Set Info
            if let resultSet = viewModel.resultSet {
                ResultSetInfoView(resultSet: resultSet)
            }
            
            // Competition Tabs
            if viewModel.matchesByCompetition.count > 1 {
                CompetitionTabsView(
                    competitions: viewModel.matchesByCompetition,
                    selectedIndex: $viewModel.selectedCompetitionIndex,
                    colorScheme: colorScheme,
                    animation: animation
                )
            }
            
            // Matches List with TabView
            if viewModel.matchesByCompetition.isEmpty {
                EmptyMatchesView()
            } else if viewModel.matchesByCompetition.count == 1 {
                // Single competition - no need for TabView
                MatchesListView(
                    matches: viewModel.selectedMatches,
                    viewModel: viewModel,
                    onTeamEvent: onTeamEvent,
                    onMatchEvent: onMatchEvent
                )
            } else {
                // Multiple competitions - use TabView
                TabView(selection: $viewModel.selectedCompetitionIndex) {
                    ForEach(Array(viewModel.matchesByCompetition.enumerated()), id: \.element.id) { index, competition in
                        MatchesListView(
                            matches: competition.matches ?? [],
                            viewModel: viewModel,
                            onTeamEvent: onTeamEvent,
                            onMatchEvent: onMatchEvent
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedCompetitionIndex)
            }
        }
        .padding(5)
    }
}

// MARK: - Result Set Info View

struct ResultSetInfoView: View {
    let resultSet: ResultSet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(resultSet.fromDateToDate)
                .font(.caption2)
            
            HStack(spacing: 15) {
                StatItem(label: "Played", value: resultSet.played)
                if let wins = resultSet.wins {
                    StatItem(label: "Wins", value: wins)
                }
                if let draws = resultSet.draws {
                    StatItem(label: "Draws", value: draws)
                }
                if let losses = resultSet.losses {
                    StatItem(label: "Losses", value: losses)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

struct StatItem: View {
    let label: String
    let value: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label + ":")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.caption2.bold())
        }
    }
}

// MARK: - Competition Tabs View

struct CompetitionTabsView: View {
    let competitions: [MatchByCompetition]
    @Binding var selectedIndex: Int
    let colorScheme: ColorScheme
    let animation: Namespace.ID
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(competitions.enumerated()), id: \.element.id) { index, competition in
                    CompetitionTabItem(
                        competition: competition.competition,
                        isSelected: selectedIndex == index
                    )
                    .padding(10)
                    .themedBackground(.itemSelected(
                        tintColor: .backgroundColor(for: colorScheme),
                        isSelected: selectedIndex == index,
                        animationID: animation,
                        animationName: "MatchByCompetitionMenu"
                    ))
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 5)
        }
    }
}

struct CompetitionTabItem: View {
    let competition: Competition
    let isSelected: Bool
    
    var body: some View {
        CompetitionItemView(competition: competition)
    }
}

// MARK: - Matches List View

struct MatchesListView<VM: BaseMatchesViewModel>: View {
    let matches: [Match]
    @ObservedObject var viewModel: VM
    
    var onTeamEvent: (ItemEvent<Team>) -> Void
    var onMatchEvent: (ItemEvent<Match>) -> Void
    
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnAppear = true
    
    var body: some View {
        ListItemPerPageView(
            listItem: matches,
            hasEffectOnApear: true,
            showModels: $showModels,
            repeatAnimationOnApear: $repeatAnimationOnAppear,
            itemView: { match in
                matchItemView(for: match)
            }
        )
    }
    
    @ViewBuilder
    private func matchItemView(for match: Match) -> some View {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            MatchItemView_StateStore(
                stateStoreVM: viewModel,
                match: match,
                isVisible: showModels.indices.contains(index) ? $showModels[index] : .constant(false),
                delay: Double(index) * 0.03,
                onEventTeam: onTeamEvent,
                onEventMatch: onMatchEvent
            )
        }
    }
}

// MARK: - Match Item View with StateStore Support

struct MatchItemView_StateStore<VM: BaseMatchesViewModel>: View {
    @ObservedObject var stateStoreVM: VM
    let match: Match
    @Binding var isVisible: Bool
    let delay: Double
    
    var onEventTeam: (ItemEvent<Team>) -> Void
    var onEventMatch: (ItemEvent<Match>) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showingTooltipMenu = false
    @Namespace var animation
    
    var body: some View {
        VStack(alignment: .leading) {
            let currentMatch = stateStoreVM.mutatedModel(withId: match.id) ?? match
            
            HStack {
                // Home Team
                TeamName(name: match.homeTeam.shortName ?? "", kindTeam: .HomeTeam)
                    .frame(width: UIScreen.main.bounds.width/2 - (match.score.winner == nil ? 50 : 70))
                    .overlay(alignment: .leading) {
                        TeamBadgeView(teamUrl: match.homeTeam.crest ?? "")
                    }
                    .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
                    .onTapGesture {
                        onEventTeam(.viewDetail(for: match.homeTeam))
                    }
                
                Spacer()
                
                // Score/Menu Section
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
                            for: colorScheme,
                            color: match.score.winner == nil ? .white : .blue
                        ),
                        cornerRadius: 10
                    )
                )
                .transition(.rotate3D())
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showingTooltipMenu.toggle()
                    }
                }
                
                Spacer()
                
                // Away Team
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
                Text(match.eventTime)
                    .font(.caption2.bold())
                    .offset(x: 40, y: -15)
            }
            .popover(isPresented: $showingTooltipMenu, arrowEdge: .top) {
                MatchMenuView(
                    match: currentMatch,
                    onEventMatch: onEventMatch
                )
            }
        }
        .padding(.top, 40)
    }
}

// MARK: - Match Menu View

struct MatchMenuView: View {
    let match: Match
    var onEventMatch: (ItemEvent<Match>) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MenuButton(icon: "chart.xyaxis.line", text: "AI analysis") {
                onEventMatch(.analysis(for: match))
            }
            
            MenuButton(icon: "list.bullet.clipboard", text: "View Detail") {
                onEventMatch(.viewDetail(for: match))
            }
            
            MenuButton(icon: match.notify ? "bell.fill" : "bell", text: "Notification") {
                onEventMatch(.toggleNotify(for: match))
            }
            
            MenuButton(
                icon: match.like ? "heart.fill" : "heart",
                text: "Favorite"
            ) {
                onEventMatch(.toggleLike(for: match))
            }
        }
        .padding(10)
        .presentationBackground(.clear)
        .presentationCompactAdaptation(.popover)
        .themedBackground(.card())
    }
}

struct MenuButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
        }
        .presentationBackground(.clear)
        .onTapGesture(perform: action)
    }
}

// MARK: - Empty State View

struct EmptyMatchesView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sportscourt")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No matches found")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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



