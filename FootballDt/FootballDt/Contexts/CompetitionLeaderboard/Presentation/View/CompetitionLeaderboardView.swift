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
                ProgressView()
            case .success(let data):
                VStack {
                    if let rankings = data.rankings {
                        if rankings.count > 1 {
                            TabView {
                                ForEach (rankings, id: \.id) { ranking in
                                    VStack {
                                        Text(ranking.group ?? "")
                                        RankingsView(listRank: ranking.rankings)
                                            .id(ranking.id)
                                            .tag(ranking.id)
                                            //.frame(height: 300)
                                    }
                                }
                            }
                            .tabViewStyle(.page)
                            .padding(.top, 10)
                            
                        } else {
                            RankingsView(listRank: rankings[0].rankings)
                        }
                    }
                    
                }
            case .failure(let error):
                Text("LeaderboardView.failure: \(error)")
            }
        }
    }
}


struct RankingsView: View {
    var listRank: [Rank]

    var columns: [GridItem] = [
        GridItem(.fixed(35)),
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35)),
        GridItem(.fixed(35))
    ]
    
    var body: some View {
        ListItemPerPageView(listItem: listRank, itemsPerPage: listRank.count, grid: (columns, getHeaderView), itemView: getItemView)
    }
    
    @ViewBuilder
    func getItemView(rank: Rank) -> some View {
        if rank.team.id != nil {
            ItemRankView(rank: rank, hasColumns: true)
        }
    }
    
    @ViewBuilder
    func getHeaderView() -> AnyView {
        AnyView(Group {
            Text("Rank")
                .font(.caption2.bold())
            Text("Team")
                .font(.caption2.bold())
            Text("Won")
                .font(.caption2.bold())
            Text("Draw")
                .font(.caption2.bold())
            Text("Lost")
                .font(.caption2.bold())
            Text("Point")
                .font(.caption2.bold())
        })

    }
}

import Kingfisher

struct ItemRankView: View {
    let rank: Rank
    var hasColumns: Bool = false
    
    var body: some View {
        if hasColumns {
            Text("\(rank.position)")
                .font(.caption2.bold())
            HStack {
                RemoteImageView(urlString: rank.team.crest ?? "", size: 20)
                Text(rank.team.shortName ?? "")
                    .font(.caption)
                Spacer()
            }
            
            Text("\(rank.won)")
                .font(.caption2)
            Text("\(rank.draw)")
                .font(.caption2)
            Text("\(rank.lost)")
                .font(.caption2)
            Text("\(rank.points)")
                .font(.caption2.bold())
        } else {
            HStack {
                Text("\(rank.position)")
                    .font(.caption2.bold())
                
                KFImage(URL(string: rank.team.crest ?? ""))
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text(rank.team.shortName ?? "")
                    .font(.caption)
                Spacer()
                Text("\(rank.won)")
                    .font(.caption2)
                Text("\(rank.draw)")
                    .font(.caption2)
                Text("\(rank.lost)")
                    .font(.caption2)
                Text("\(rank.points)")
                    .font(.caption2.bold())
            }
        }
    }
}
