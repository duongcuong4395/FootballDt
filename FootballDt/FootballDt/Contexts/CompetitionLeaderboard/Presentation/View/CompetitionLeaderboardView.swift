//
//  CompetitionLeaderboardView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct CompetitionLeaderboardView: View {
    var body: some View {
        LeaderboardView()
    }
}

struct LeaderboardView: View {
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    
    var body: some View {
        Group {
            switch leaderboardVM.leaderboardStatus {
            case .idle:
                Text("LeaderboardView idle")
            case .loading:
                Text("LeaderboardView Loading")
            case .success(let data):
                VStack {
                    if let rankings = data.rankings {
                        if rankings.count > 1 {
                            
                            ScrollView(showsIndicators: false) {
                                LazyVStack {
                                    ForEach (rankings, id: \.id) { ranking in
                                        VStack {
                                            Text(ranking.group ?? "")
                                            RankingsView(listRank: ranking.rankings, hasEffectOnApear: false)
                                        }
                                        .id(ranking.id)
                                        .tag(ranking.id)
                                    }
                                }
                            }
                            
                            /*
                            TabView {
                                ForEach (rankings, id: \.id) { ranking in
                                    VStack {
                                        Text(ranking.group ?? "")
                                        RankingsView(listRank: ranking.rankings, hasEffectOnApear: false)
                                    }
                                    .id(ranking.id)
                                    .tag(ranking.id)
                                }
                            }
                            .tabViewStyle(.page)
                            .padding(.top, 10)
                            */
                        } else {
                            RankingsView(listRank: rankings[0].rankings, hasEffectOnApear: true)
                        }
                    }
                    
                }
            case .failure(let error):
                Text("LeaderboardView failure: \(error)")
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
    
    var body: some View {
        ListItemPerPageViewNew2(
            listItem: listRank
            , itemsPerPage: listRank.count
            , grid: (columns, getHeaderView)
            , animationEnabled: true
            , repeatAnimationOnAppear: false
        ) { rank, isVisible, delay in
            ItemRankView(
                rank: rank, hasColumns: true
                , isVisible: isVisible
                , delay: delay)
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
        .slideInEffect(isVisible: $isVisible, delay: delay, direction: .leftToRight)
    }
}
