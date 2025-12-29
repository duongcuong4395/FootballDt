//
//  CompetitionLeaderboardView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct LeaderboardView: View {
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
                //Text("LeaderboardView failure: \(error)")
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
                        LazyVStack {
                            ForEach (rankings, id: \.id) { ranking in
                                VStack {
                                    Text(ranking.group ?? "")
                                    RankingsView(listRank: ranking.rankings, hasEffectOnApear: false)
                                }
                                .id(ranking.id)
                            }
                        }
                    }
                } else {
                    RankingsView(listRank: rankings[0].rankings, hasEffectOnApear: true)
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


struct RankingsView: View {
    var listRank: [Rank]
    var hasEffectOnApear: Bool
    var columns: [GridItem] = [
        GridItem(.fixed(35)),
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35))
    ]
    
    @State private var showModels: [Bool] = []
    @State private var repeatAnimationOnApear = true
    
    var body: some View {
        ListItemPerPageView(
            listItem: listRank
            , itemsPerPage: listRank.count
            , grid: (columns, getHeaderView)
            , hasEffectOnApear: true
            , showModels: $showModels
            , repeatAnimationOnApear: $repeatAnimationOnApear
            , itemView: getItemView)
    }
    
    @ViewBuilder
    func getItemView(rank: Rank) -> some View {
        if let index = listRank.firstIndex(where: { $0.id == rank.id }) {
            ItemRankView(
                rank: rank, hasColumns: true
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03, repeatAnimationOnApear: repeatAnimationOnApear)
        }
    }
    
    @ViewBuilder
    func getHeaderView() -> AnyView {
        AnyView(Group {
            Text("Rank")
            Text("Team")
            Text("Won")
            Text("Draw")
            Text("Lost")
            Text("Point")
        }.font(.caption2.bold()))
    }
}

import Kingfisher

struct ItemRankView: View {
    let rank: Rank
    var hasColumns: Bool = false
    
    @Binding var isVisible: Bool
    var delay: Double
    var repeatAnimationOnApear: Bool
    
    var body: some View {
        Group {
            Text("\(rank.position)")
                .font(.caption2.bold())
            HStack {
                RemoteImageView(urlString: rank.team.crest ?? "", size: 20)
                Text(rank.team.shortName ?? "")
                    .font(.caption)
                Spacer()
            }
            Text("\(rank.won)").font(.caption2)
            Text("\(rank.draw)").font(.caption2)
            Text("\(rank.lost)").font(.caption2)
            Text("\(rank.points)").font(.caption2.bold())
        }
        .slideInEffect(isVisible: $isVisible, delay: delay, repeatAnimationOnApear: repeatAnimationOnApear, direction: .leftToRight)
    }
}
