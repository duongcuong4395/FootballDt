//
//  PagingViewModel.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

@MainActor
public final class PagingViewModel<T: Identifiable>: ObservableObject {

    @Published public private(set) var items: [T] = []
    @Published public private(set) var state: PaginationState

    private let controller: PaginationController<T>

    public init(items: [T], itemsPerPage: Int) {
        self.controller = PaginationController(
            items: items,
            config: PaginationConfig(itemsPerPage: itemsPerPage)
        )
        self.state = controller.state()
        self.items = controller.pageItems()
    }

    public func nextPage() {
        controller.next()
        refresh()
    }

    public func previousPage() {
        controller.previous()
        refresh()
    }

    private func refresh() {
        items = controller.pageItems()
        state = controller.state()
    }
}

struct ListItemPerPageView<T: Identifiable, ItemView: View>: View {
    var listItem: [T]
    var itemsPerPage: Int
    var grid: (columms: [GridItem], headerView: () -> AnyView)?
    var itemView: (T) -> ItemView
    var hasEffectOnApear: Bool = false
    
    @StateObject private var pagingVM: PagingViewModel<T>
    @Binding var showModels: [Bool]
    @Binding var repeatAnimationOnApear: Bool
    
    init(listItem: [T], itemsPerPage: Int = 10
         , grid: (columms: [GridItem], headerView: () -> AnyView)? = nil
         , hasEffectOnApear: Bool = false
         , showModels: Binding<[Bool]> = .constant([])
         , repeatAnimationOnApear: Binding<Bool> = .constant(false)
         , itemView: @escaping (T) -> ItemView) {
        
        self.listItem = listItem
        _pagingVM = StateObject(wrappedValue: PagingViewModel<T>(
            items: listItem,
            itemsPerPage: itemsPerPage
        ))
        self.itemView = itemView
        self.itemsPerPage = itemsPerPage
        self.grid = grid
        self.hasEffectOnApear = hasEffectOnApear
        
        _showModels = showModels
        _repeatAnimationOnApear = repeatAnimationOnApear
        
    }
    
    var body: some View {
        VStack(spacing: 5) {
            PagingControlsView(
                state: pagingVM.state,
                onPrevious: pagingVM.previousPage,
                onNext: pagingVM.nextPage
            )
            .padding(0)
            
            if let grid = grid {
                LazyVGrid(columns: grid.columms) {
                    grid.headerView()
                    
                }
            }
            
            ScrollView(showsIndicators: false) {
                if let grid = grid {
                    LazyVGrid(columns: grid.columms, spacing: 10) {
                        ForEach(pagingVM.items, id: \.id) { item in
                            if !hasEffectOnApear {
                                itemView(item)
                            } else {
                                if let index = listItem.firstIndex(where: { $0.id == item.id })  {
                                    itemView(item)
                                        .onAppear{
                                            guard showModels.count > 0 else { return }
                                            guard showModels[index] == false else { return }
                                            withAnimation {
                                                showModels[index] = true
                                            }
                                        }
                                        .onDisappear{
                                            guard showModels.count > 0 else { return }
                                            guard showModels[index] == true else { return }
                                            if repeatAnimationOnApear {
                                                self.showModels[index] = false
                                            }
                                            
                                        }
                                }
                            }
                            
                            
                        }
                    }
                } else {
                    LazyVStack{
                        ForEach(pagingVM.items, id: \.id) { item in
                            if !hasEffectOnApear {
                                itemView(item)
                            } else {
                                if let index = listItem.firstIndex(where: { $0.id == item.id })  {
                                    
                                    itemView(item)
                                        .onAppear{
                                            guard showModels.count > 0 else { return }
                                            guard showModels[index] == false else { return }
                                            withAnimation {
                                                showModels[index] = true
                                            }
                                        }
                                        .onDisappear{
                                            guard showModels.count > 0 else { return }
                                            guard showModels[index] == true else { return }
                                            if repeatAnimationOnApear {
                                                self.showModels[index] = false
                                            }
                                            
                                        }
                                }
                            }
                            
                        }
                    }
                }
                Spacer().frame(height: 10)
            }
            
        }
        .onAppear{
            if hasEffectOnApear {
                
                withAnimation {
                    if showModels.count != listItem.count {
                        self.showModels = Array(repeating: false, count: listItem.count)
                   }
                }
            }
        }
        
    }
}
