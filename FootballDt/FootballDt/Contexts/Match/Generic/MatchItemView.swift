//
//  MatchItemView.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

import SwiftUI

// MARK: - Base Match Item Content (Shared Logic)

struct MatchItemContent: View {
    let match: Match
    let currentMatch: Match?  // nil for static view, mutated match for interactive view
    let isVisible: Binding<Bool>
    let delay: Double
    let showMenu: Bool
    
    var onEventTeam: ((ItemEvent<Team>) -> Void)?
    var onMenuTap: (() -> Void)?
    
    @Environment(\.colorScheme) var colorScheme
    @Namespace var animation
    
    private var displayMatch: Match {
        currentMatch ?? match
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Home Team
                TeamSection(
                    team: match.homeTeam,
                    kindTeam: .HomeTeam,
                    hasWinner: match.score.winner != nil,
                    isVisible: isVisible,
                    delay: delay,
                    onTap: {
                        onEventTeam?(.viewDetail(for: match.homeTeam))
                    }
                )
                
                Spacer()
                
                // Score/Menu Section
                ScoreSection(
                    match: match,
                    displayMatch: displayMatch,
                    showMenu: showMenu,
                    colorScheme: colorScheme,
                    animation: animation,
                    onTap: onMenuTap
                )
                
                Spacer()
                
                // Away Team
                TeamSection(
                    team: match.awayTeam,
                    kindTeam: .AwayTeam,
                    hasWinner: match.score.winner != nil,
                    isVisible: isVisible,
                    delay: delay,
                    onTap: {
                        onEventTeam?(.viewDetail(for: match.awayTeam))
                    }
                )
            }
            .overlay(alignment: .topLeading) {
                EventTimeLabel(eventTime: match.eventTime)
            }
        }
    }
}

// MARK: - Team Section Component

struct TeamSection: View {
    let team: Team
    let kindTeam: KindTeam
    let hasWinner: Bool
    let isVisible: Binding<Bool>
    let delay: Double
    let onTap: () -> Void
    
    private var frameWidth: CGFloat {
        UIScreen.main.bounds.width/2 - (hasWinner ? 75 : 75)
    }
    
    var body: some View {
        TeamName(name: team.shortName ?? "", kindTeam: kindTeam)
            .frame(width: frameWidth)
            .overlay(alignment: kindTeam == .HomeTeam ? .leading : .trailing) {
                TeamBadgeView(teamUrl: team.crest ?? "")
            }
            .slideInEffect(isVisible: isVisible, delay: delay, direction: kindTeam == .HomeTeam ? .leftToRight : .rightToLeft)
            .onTapGesture(perform: onTap)
    }
}

// MARK: - Score Section Component

struct ScoreSection: View {
    let match: Match
    let displayMatch: Match
    let showMenu: Bool
    let colorScheme: ColorScheme
    let animation: Namespace.ID
    let onTap: (() -> Void)?
    
    var body: some View {
        VStack {
            if let _ = match.score.winner {
                ScoreView(score: match.score)
                    .font(.body.bold())
                    .padding(5)
            } else {
                Text("VS")
                    .font(.body.bold())
                    .padding(5)
            }
        }
        .padding(.horizontal, 10)
        .background {
            RemoteImageView(urlString: match.competition.emblem, size: 50)
                .opacity(0.2)
        }
        .themedBackground(
            .itemSelected(
                tintColor: .backgroundColor(
                    for: colorScheme,
                    color: .orange
                ),
                cornerRadius: 10,
                isSelected: true,
                animationID: animation,
                animationName: "selectTeamOption"
            )
        )
        .transition(.rotate3D())
        .onTapGesture {
            onTap?()
        }
    }
}


// MARK: - Event Time Label Component

struct EventTimeLabel: View {
    let eventTime: String
    
    var body: some View {
        Text(eventTime)
            .font(.caption2.bold())
            .offset(x: 45, y: -15)
    }
}


// MARK: - Configuration Struct for Customization

struct MatchItemConfiguration {
    var showMenu: Bool
    var isInteractive: Bool
    var padding: CGFloat
    var frameWidthAdjustment: CGFloat
    
    static let interactive = MatchItemConfiguration(
        showMenu: true,
        isInteractive: true,
        padding: 30,
        frameWidthAdjustment: 60
    )
    
    static let header = MatchItemConfiguration(
        showMenu: false,
        isInteractive: false,
        padding: 0,
        frameWidthAdjustment: 80
    )
    
    static let simple = MatchItemConfiguration(
        showMenu: false,
        isInteractive: false,
        padding: 30,
        frameWidthAdjustment: 60
    )
}

// MARK: - Universal Match Item View (Most Flexible)

struct UniversalMatchItemView<VM: BaseMatchesViewModel>: View {
    // Optional StateStore for interactive mode
    var stateStoreVM: VM?
    let match: Match
    let configuration: MatchItemConfiguration
    
    @Binding var isVisible: Bool
    let delay: Double
    
    var onEventTeam: ((ItemEvent<Team>) -> Void)?
    var onEventMatch: ((ItemEvent<Match>) -> Void)?
    
    @State private var showingTooltipMenu = false
    
    var body: some View {
        MatchItemContent(
            match: match,
            currentMatch: stateStoreVM?.mutatedModel(withId: match.id),
            isVisible: $isVisible,
            delay: delay,
            showMenu: configuration.showMenu,
            onEventTeam: onEventTeam,
            onMenuTap: configuration.isInteractive ? {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showingTooltipMenu.toggle()
                }
            } : nil
        )
        .popover(isPresented: $showingTooltipMenu, arrowEdge: .top) {
            if configuration.showMenu, let onEventMatch = onEventMatch {
                MatchMenuView(
                    match: stateStoreVM?.mutatedModel(withId: match.id) ?? match,
                    onEventMatch: onEventMatch,
                    showingTooltipMenu: $showingTooltipMenu
                )
            }
        }
        .padding(.top, configuration.padding)
    }
}

// MARK: - Convenience Initializers

extension UniversalMatchItemView {
    // Interactive mode with StateStore
    static func interactive(
        stateStoreVM: VM,
        match: Match,
        isVisible: Binding<Bool>,
        delay: Double,
        onEventTeam: @escaping (ItemEvent<Team>) -> Void,
        onEventMatch: @escaping (ItemEvent<Match>) -> Void
    ) -> UniversalMatchItemView {
        UniversalMatchItemView(
            stateStoreVM: stateStoreVM,
            match: match,
            configuration: .interactive,
            isVisible: isVisible,
            delay: delay,
            onEventTeam: onEventTeam,
            onEventMatch: onEventMatch
        )
    }
    
    // Static header mode
    static func header(
        match: Match
    ) -> UniversalMatchItemView {
        UniversalMatchItemView(
            stateStoreVM: nil,
            match: match,
            configuration: .header,
            isVisible: .constant(true),
            delay: 0.03,
            onEventTeam: nil,
            onEventMatch: nil
        )
    }
    
    static func simpleMatch(
        match: Match
    ) -> UniversalMatchItemView {
        UniversalMatchItemView(
            stateStoreVM: nil,
            match: match,
            configuration: .simple,
            isVisible: .constant(true),
            delay: 0.03,
            onEventTeam: nil,
            onEventMatch: nil
        )
    }
}
