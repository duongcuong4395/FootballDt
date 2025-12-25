//
//  CompetitionsScorersView.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

import SwiftUI

struct CompetitionScorersView: View {
    @EnvironmentObject var competitionScorersVM: CompetitionsScorersViewModel
    
    var body: some View {
        switch competitionScorersVM.competitionsScorersStatus {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
        case .success(let data):
            ListScorerView(scorers: data.scorers ?? [])
        case .failure(let error):
            EmptyView()
        }
    }
}

struct ListScorerView: View {
    var scorers: [Scorer]
    
    @StateObject private var pagingVM: PagingViewModel<Scorer>
    
    init(scorers: [Scorer]) {
        self.scorers = scorers
        _pagingVM = StateObject(wrappedValue: PagingViewModel<Scorer>(
            items: scorers,
            itemsPerPage: 10
        ))
    }
    
    var body: some View {
        ListItemPerPageView(listItem: scorers, itemView: getItemView)
        
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack{
                    ForEach(pagingVM.items, id: \.id) { scorer in
                        ScorerItemView(scorer: scorer)
                    }
                }
            }
            .padding(.top, 10)
            
            PagingControlsView(
                state: pagingVM.state,
                onPrevious: pagingVM.previousPage,
                onNext: pagingVM.nextPage
            )
        }
    }
    
    @ViewBuilder
    func getItemView(scorer: Scorer) -> some View {
        ScorerItemView(scorer: scorer)
    }
}


struct ScorerItemView: View {
    var scorer: Scorer
    
    var body: some View {
        HStack {
            Text("\(scorer.playedMatches)")
                .font(.caption2)
            TeamItemView(team: scorer.team)
            
            Text("\(scorer.penalties ?? 0)")
                .font(.caption2)
                .foregroundStyle(.red)
            Text("\(scorer.assists ?? 0)")
                .font(.caption2)
                .foregroundStyle(.orange)
            Text("\(scorer.goals)")
                .font(.caption2.bold())
                .foregroundStyle(.yellow)
        }
    }
}


struct ListItemPerPageView<T: Identifiable, ItemView: View>: View {
    var listItem: [T]
    var itemView: (T) -> ItemView
    
    @StateObject private var pagingVM: PagingViewModelNew<T>
    
    /*
    init(listItem: [T], itemView: ItemView) {
        self.listItem = listItem
        _pagingVM = StateObject(wrappedValue: PagingViewModelNew<T>(
            items: listItem,
            itemsPerPage: 10
        ))
        
        self.itemView = itemView
    }
    */
    
    init(listItem: [T], itemView: @escaping (T) -> ItemView) {
        self.listItem = listItem
        _pagingVM = StateObject(wrappedValue: PagingViewModelNew<T>(
            items: listItem,
            itemsPerPage: 10
        ))
        self.itemView = itemView
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack{
                    ForEach(pagingVM.items, id: \.id) { item in
                        itemView(item)
                    }
                }
            }
            .padding(.top, 10)
            
            PagingControlsView(
                state: pagingVM.state,
                onPrevious: pagingVM.previousPage,
                onNext: pagingVM.nextPage
            )
        }
    }
}
