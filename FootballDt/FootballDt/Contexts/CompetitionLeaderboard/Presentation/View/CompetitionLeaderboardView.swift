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
    var columns: [GridItem] =
     [
         GridItem(.fixed(30)),
         GridItem(.flexible(minimum: 40)),
         GridItem(.fixed(35)),
         GridItem(.fixed(35)),
         GridItem(.fixed(35)),
         GridItem(.fixed(35))
     ]
    
    @State private var showModels: [Bool] = []
    
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var teamVM: TeamViewModel
    
    var body: some View {
        /*
        PaginatedGrid(
            dataSource: InMemoryDataSource(items: listRank)
            , columns: columns
            , configuration: PaginationConfiguration(pageSize: listRank.count)
            , header: getHeaderView
            , content: { rank in
                getItemView(rank: rank)
            })
        .onAppear{
            withAnimation {
                if showModels.count != listRank.count {
                    self.showModels = Array(repeating: false, count: listRank.count)
               }
            }
        }
        */
      
        ListItemPerPageView(
            listItem: listRank
            , itemsPerPage: listRank.count
            , grid: (columns, getHeaderView)
            , hasEffectOnApear: true
            , showModels: $showModels
            , repeatAnimationOnApear: .constant(false)
            , itemView: getItemView)
       
    }
    
    @ViewBuilder
    func getItemView(rank: Rank) -> some View {
        if let index = listRank.firstIndex(where: { $0.id == rank.id }) {
            ItemRankView(
                rank: rank, hasColumns: true
                , isVisible: $showModels.indices.indices.contains(index) ? $showModels[index] : .constant(false)
                , delay: Double(index) * 0.03)
            .foregroundColor(positionColor(rank.position))
            .onTapGesture {
                Task {
                    await teamVM.getTeamDetail(by: rank.team.id ?? 0)
                    withAnimation(.spring()) {
                        router.navigationTeamDetail()
                    }
                }
            }
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
    
    @ViewBuilder
    func getHeaderView() -> AnyView {
        AnyView(Group {
            Image(systemName: "medal")
                .font(.body.bold())
            //Text("Rank")
            Text("Team")
            Text("W")
            Text("D")
            Text("L")
            Text("P")
        }
            .font(.caption2.bold())
        )
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
                RemoteImageView(urlString: rank.team.crest ?? "", size: 35)
                Text(rank.team.shortName ?? "")
                    .font(.caption.bold())
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
