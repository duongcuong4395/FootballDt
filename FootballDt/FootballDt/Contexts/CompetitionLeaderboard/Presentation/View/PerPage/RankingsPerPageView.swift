//
//  RankingsPerPageView.swift
//  FootballDt
//
//  Created by Macbook on 13/1/26.
//

import SwiftUI

struct LeaderboardView2: View {
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    
    @State private var hasInitialLoad = false
    
    var body: some View {
        Group {
            switch leaderboardVM.leaderboardStatus {
            case .idle:
                Color.clear
                    .onAppear {
                        loadDataIfNeeded()
                    }
            case .loading:
                ProgressView("Loading leaderboard...")
            case .success(let data):
                GetContentView(rankings: data.rankings)
            case .failure(let error):
                ErrorView(error: error) {
                    loadDataIfNeeded()
                }
            }
        }
    }
    
    @ViewBuilder
    private func GetContentView(rankings: [Rankings]?) -> some View {
        VStack {
            if let rankings = rankings {
                if rankings.count > 1 {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 5) {
                            ForEach (rankings, id: \.id) { ranking in
                                VStack {
                                    Text(ranking.group ?? "")
                                    //RankingsViewFixed(listRank: ranking.rankings, hasEffectOnApear: true, itemsPerPage: 30)
                                    RankingsViewFixed(listRank: ranking.rankings, itemsPerPage: 10, enableAnimations: true)
                                }
                                .id(ranking.id)
                            }
                        }
                    }
                } else {
                    //RankingsViewFixed(listRank: rankings[0].rankings, hasEffectOnApear: true, itemsPerPage: 30)
                    RankingsViewFixed(listRank: rankings[0].rankings, itemsPerPage: 10, enableAnimations: true)
                }
            }
        }
        .onAppear {
            hasInitialLoad = true
        }
    }
    
    func loadDataIfNeeded() {
        guard case .success(data: let competition) = listCompetitionVM.competitionSelected else { return }
        
        if case .idle = leaderboardVM.leaderboardStatus {
            Task {
                await leaderboardVM.getLeaderboard(by: competition.code ?? "", and: nil)
            }
        }
    }
}

// MARK: - ✅ CRITICAL: Rewrite RankingsView to Eliminate ALL Cycles

struct RankingsViewFixed: View {
    let listRank: [Rank]
    let itemsPerPage: Int
    let enableAnimations: Bool
    
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var teamVM: TeamViewModel
    
    // ✅ NO @State for showModels - use simple counter instead
    @State private var animationPhase = 0
    
    private let columns: [GridItem] = [
        GridItem(.fixed(30)),
        GridItem(.flexible(minimum: 40)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35)),
        GridItem(.fixed(40))
    ]
    
    init(listRank: [Rank], itemsPerPage: Int = 10, enableAnimations: Bool = false) {
        self.listRank = listRank
        self.itemsPerPage = itemsPerPage
        self.enableAnimations = enableAnimations
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.secondary.opacity(0.1))
            
            Divider()
            
            // ✅ Use PaginatedGrid correctly WITHOUT state cycles
            //PaginatedGrid(dataSource: InMemoryDataSource(items: listRank), header: EmptyView(), content: <#T##(_) -> View#>)
            
            PaginatedGrid(
                dataSource: InMemoryDataSource(items: listRank),
                
                columns: columns,
                
                configuration: .init(
                    pageSize: itemsPerPage,
                    enablePageJumping: true
                ),
                header: {}
            ) { rank in
                // ✅ NO firstIndex search - direct rendering
                rankRowView(rank)
            }
        }
        .onAppear {
            // ✅ Trigger animation phase ONCE
            if enableAnimations {
                animationPhase = 1
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            Group {
                Text("Rank")
                Text("Team")
                Text("W")
                Text("D")
                Text("L")
                Text("Pts")
            }
            .font(.caption.bold())
        }
    }
    
    @ViewBuilder
    private func rankRowView(_ rank: Rank) -> some View {
        LazyVGrid(columns: columns, spacing: 8) {
            // Position
            Text("\(rank.position)")
                .font(.caption2.bold())
                .foregroundColor(positionColor(rank.position))
            
            // Team
            HStack(spacing: 6) {
                RemoteImageView(
                    urlString: rank.team.crest ?? "",
                    size: 30
                )
                Text(rank.team.shortName ?? "")
                    .font(.caption.bold())
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            
            // Stats
            Text("\(rank.won)").font(.caption2)
            Text("\(rank.draw)").font(.caption2)
            Text("\(rank.lost)").font(.caption2)
            Text("\(rank.points)").font(.caption2.bold())
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(rowBackground(rank.position))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap(rank)
        }
        // ✅ Simple animation without state cycles
        .if(enableAnimations) { view in
            view.modifier(
                SimpleSlideIn(
                    index: listRank.firstIndex(where: { $0.id == rank.id }) ?? 0,
                    phase: animationPhase
                )
            )
        }
    }
    
    // MARK: - Helpers
    
    private func rowBackground(_ position: Int) -> some View {
        Group {
            switch position {
            case 1...4: Color.green.opacity(0.1)
            case 5...6: Color.blue.opacity(0.1)
            case let p where p >= 18: Color.red.opacity(0.1)
            default: Color.clear
            }
        }
    }
    
    private func positionColor(_ position: Int) -> Color {
        switch position {
        case 1...4: return .green
        case 5...6: return .blue
        case let p where p >= 18: return .red
        default: return .primary
        }
    }
    
    private func handleTap(_ rank: Rank) {
        guard let teamId = rank.team.id else { return }
        
        Task {
            await teamVM.getTeamDetail(by: teamId)
            withAnimation(.spring()) {
                router.navigationTeamDetail()
            }
        }
    }
}

// MARK: - ✅ Simple Animation Modifier (No State Binding)

struct SimpleSlideIn: ViewModifier {
    let index: Int
    let phase: Int
    
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: appeared ? 0 : -50)
            .opacity(appeared ? 1 : 0)
            .task(id: phase) {
                // ✅ Delay based on index
                guard phase > 0 else { return }
                
                try? await Task.sleep(nanoseconds: UInt64(Double(index) * 0.03 * 1_000_000_000))
                
                withAnimation(.easeOut(duration: 0.4)) {
                    appeared = true
                }
            }
    }
}

// MARK: - ✅ Helper Extension

extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
