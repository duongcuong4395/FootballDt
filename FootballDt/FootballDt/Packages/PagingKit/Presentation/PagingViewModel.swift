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

struct ListItemPerPageViewNew<T: Identifiable, ItemView: View>: View {
    var listItem: [T]
    var itemsPerPage: Int
    var grid: (columms: [GridItem], headerView: () -> AnyView)?
    var itemView: (T, Binding<Bool>, Double) -> ItemView
    var animationEnabled: Bool = true
    
    @StateObject private var pagingVM: PagingViewModel<T>
    @State private var visibleItems: Set<T.ID> = []
    @State private var pageChangeID = UUID()
    
    init(listItem: [T],
         itemsPerPage: Int = 10,
         grid: (columms: [GridItem], headerView: () -> AnyView)? = nil,
         animationEnabled: Bool = true,
         itemView: @escaping (T, Binding<Bool>, Double) -> ItemView) {
        
        self.listItem = listItem
        _pagingVM = StateObject(wrappedValue: PagingViewModel<T>(
            items: listItem,
            itemsPerPage: itemsPerPage
        ))
        self.itemView = itemView
        self.itemsPerPage = itemsPerPage
        self.grid = grid
        self.animationEnabled = animationEnabled
    }
    
    var body: some View {
        VStack(spacing: 5) {
            PagingControlsView(
                state: pagingVM.state,
                onPrevious: {
                    pagingVM.previousPage()
                    resetAnimations()
                },
                onNext: {
                    pagingVM.nextPage()
                    resetAnimations()
                }
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
                        itemsContent()
                    }
                } else {
                    LazyVStack {
                        itemsContent()
                    }
                }
            }
        }
        .id(pageChangeID)
        .onAppear {
            if animationEnabled {
                scheduleAnimations()
            } else {
                // If you turn off animation, show everything immediately.
                visibleItems = Set(pagingVM.items.map { $0.id })
            }
        }
    }
    
    @ViewBuilder
    private func itemsContent() -> some View {
        ForEach(Array(pagingVM.items.enumerated()), id: \.element.id) { index, item in
            let isVisible = Binding(
                get: { visibleItems.contains(item.id) },
                set: { newValue in
                    if newValue {
                        visibleItems.insert(item.id)
                    } else {
                        visibleItems.remove(item.id)
                    }
                }
            )
            
            let delay = animationEnabled ? Double(index) * 0.03 : 0
            
            itemView(item, isVisible, delay)
        }
    }
    
    private func scheduleAnimations() {
        visibleItems.removeAll()
        
        if !animationEnabled {
            // If you turn off the animation, everything will be shown.
            visibleItems = Set(pagingVM.items.map { $0.id })
            return
        }
        
        for (index, item) in pagingVM.items.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    
                    _ = visibleItems.insert(item.id)
                }
            }
        }
    }
    
    private func resetAnimations() {
        // Force view recreation with new ID
        pageChangeID = UUID()
    }
}

struct ListItemPerPageViewNew2<T: Identifiable, ItemView: View>: View {
    
    var listItem: [T]
    var itemsPerPage: Int
    var grid: (columms: [GridItem], headerView: () -> AnyView)?
    var itemView: (T, Binding<Bool>, Double) -> ItemView
    var animationEnabled: Bool = true
    var repeatAnimationOnAppear: Bool = true
    
    @StateObject private var pagingVM: PagingViewModel<T>
    @State private var visibleItems: Set<T.ID> = []
    @State private var pageChangeID = UUID()
    @State private var hasAnimatedOnce = false
    
    init(listItem: [T],
         itemsPerPage: Int = 10,
         grid: (columms: [GridItem], headerView: () -> AnyView)? = nil,
         animationEnabled: Bool = true,
         repeatAnimationOnAppear: Bool = true,
         itemView: @escaping (T, Binding<Bool>, Double) -> ItemView) {
        
        self.listItem = listItem
        _pagingVM = StateObject(wrappedValue: PagingViewModel<T>(
            items: listItem,
            itemsPerPage: itemsPerPage
        ))
        self.itemView = itemView
        self.itemsPerPage = itemsPerPage
        self.grid = grid
        self.animationEnabled = animationEnabled
        self.repeatAnimationOnAppear = repeatAnimationOnAppear
    }
    
    var body: some View {
        VStack(spacing: 5) {
            PagingControlsView(
                state: pagingVM.state,
                onPrevious: {
                    pagingVM.previousPage()
                    resetAnimations()
                },
                onNext: {
                    pagingVM.nextPage()
                    resetAnimations()
                }
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
                        itemsContent()
                    }
                } else {
                    LazyVStack {
                        itemsContent()
                    }
                }
            }
        }
        .id(pageChangeID)
        .onAppear {
            handleOnAppear()
        }
    }
    
    @ViewBuilder
    private func itemsContent() -> some View {
        ForEach(Array(pagingVM.items.enumerated()), id: \.element.id) { index, item in
            let isVisible = Binding(
                get: { visibleItems.contains(item.id) },
                set: { newValue in
                    if newValue {
                        visibleItems.insert(item.id)
                    } else {
                        visibleItems.remove(item.id)
                    }
                }
            )
            
            let delay = animationEnabled ? Double(index) * 0.03 : 0
            itemView(item, isVisible, delay)
        }
    }
    
    private func handleOnAppear() {
        if !animationEnabled {
            visibleItems = Set(pagingVM.items.map { $0.id })
            hasAnimatedOnce = true
            return
        }
        
        if !repeatAnimationOnAppear && hasAnimatedOnce {
            visibleItems = Set(pagingVM.items.map { $0.id })
            return
        }
        
        scheduleAnimations()
        hasAnimatedOnce = true
    }
    
    private func scheduleAnimations() {
        visibleItems.removeAll()
        
        if !animationEnabled {
            visibleItems = Set(pagingVM.items.map { $0.id })
            return
        }
        
        for (index, item) in pagingVM.items.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    _ = visibleItems.insert(item.id)
                }
            }
        }
    }
    
    private func resetAnimations() {
        pageChangeID = UUID()
        
        if repeatAnimationOnAppear {
            hasAnimatedOnce = false
        }
    }
}
