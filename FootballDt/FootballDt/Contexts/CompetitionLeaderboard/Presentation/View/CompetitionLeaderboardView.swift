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

/*

struct LeaderboardRouteView: View {
    var body: some View {
        RouteGenericView(
            headerView: LeaderboardHeaderView()
            , contentView: LeaderboardView()
            , backgroundURLLink: nil)
    }
}

struct LeaderboardHeaderView: View {
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    @EnvironmentObject var footballDtRouter: FootballDtRouter
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                leaderboardVM.resetAll()
                footballDtRouter.pop()
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
            })
            switch listCompetitionVM.competitionSelected {
            case .success(data: let data):
                CompetitionItemView(competition: data)
            default: EmptyView()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 70)
        //.themedBackground(.header(height: 70))
    }
}
 
*/
struct LeaderboardView: View {
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    
    var body: some View {
        switch leaderboardVM.leaderboardStatus {
        case .idle:
            
            Text("LeaderboardView.idle")
        case .loading:
            ProgressView()
        case .success(let data):
            VStack {
                RankingsView(listRank: data.rankings?[0].rankings ?? [])
            }
        case .failure(let error):
            Text("LeaderboardView.failure: \(error)")
        }
        
    }
}


struct RankingsView: View {
    var listRank: [Rank]
    
    @StateObject
    private var pagingVM: PagingViewModel<Rank>
    
    init(listRank: [Rank]) {
        self.listRank = listRank
        _pagingVM = StateObject(wrappedValue: PagingViewModel<Rank>(
            items: listRank,
            itemsPerPage: 11
        ))
    }

    var body: some View {
        List(pagingVM.items, id: \.position) { rank in
            ItemRankView(rank: rank)
        }

        PagingControlsView(
            state: pagingVM.state,
            onPrevious: pagingVM.previousPage,
            onNext: pagingVM.nextPage
        )
        
        
        /*
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(listRank, id: \.position) { rank in
                    ItemRankView(rank: rank)
                }
            }
        }
        */
    }
}

import Kingfisher

struct ItemRankView: View {
    let rank: Rank
    
    var body: some View {
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
