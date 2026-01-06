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
    let currentMatch: Match? // nil for static view, mutated match for interactive view
    let isVisible: Binding<Bool>
    let delay: Double
    let showMenu: Bool
    
    var onEventTeam: ((ItemEvent<Team>) -> Void)?
    var onMenuTap: (() -> Void)?
    
    @Environment(\.colorScheme) var colorScheme
    @Namespace var animation
    
    // Computed property để xác định match hiển thị
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
    
    // Tính toán width dựa trên hasWinner và loại view
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
