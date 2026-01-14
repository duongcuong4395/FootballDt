//
//  PagingKit.swift
//  FootballDt
//
//  Created by Macbook on 12/1/26.
//

import SwiftUI
import Combine

// MARK: - 1. Core Protocol-Oriented Design

/// Protocol for any pageable data source
public protocol PageableDataSource {
    associatedtype Item: Identifiable
    var totalItems: Int { get }
    func items(for page: Int, pageSize: Int) -> [Item]
}

/// In-memory implementation
public struct InMemoryDataSource<T: Identifiable>: PageableDataSource {
    public typealias Item = T
    private let allItems: [T]
    
    public var totalItems: Int { allItems.count }
    
    public init(items: [T]) {
        self.allItems = items
    }
    
    public func items(for page: Int, pageSize: Int) -> [T] {
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, allItems.count)
        guard startIndex < endIndex else { return [] }
        return Array(allItems[startIndex..<endIndex])
    }
}

// MARK: - 2. Configuration với Builder Pattern

public struct PaginationConfiguration {
    public let pageSize: Int
    public let prefetchThreshold: Int
    public let enablePageJumping: Bool
    
    public init(
        pageSize: Int = 10,
        prefetchThreshold: Int = 3,
        enablePageJumping: Bool = true
    ) {
        self.pageSize = max(1, pageSize)
        self.prefetchThreshold = max(0, prefetchThreshold)
        self.enablePageJumping = enablePageJumping
    }
    
    public static let `default` = PaginationConfiguration()
}

// MARK: - 3. State Management

public struct PaginationState: Equatable {
    public let currentPage: Int
    public let totalPages: Int
    public let pageSize: Int
    public let totalItems: Int
    
    public var hasNext: Bool { currentPage < totalPages }
    public var hasPrevious: Bool { currentPage > 1 }
    public var pageRange: String { "\(currentPage) / \(totalPages)" }
    
    public static let empty = PaginationState(
        currentPage: 1,
        totalPages: 1,
        pageSize: 10,
        totalItems: 0
    )
}

// MARK: - 4. ViewModel với Dependency Injection

@MainActor
public final class PaginationViewModel<DataSource: PageableDataSource>: ObservableObject {
    
    // Published states
    @Published public private(set) var items: [DataSource.Item] = []
    @Published public private(set) var state: PaginationState = .empty
    @Published public private(set) var isLoading = false
    
    // Dependencies
    private let dataSource: DataSource
    let configuration: PaginationConfiguration
    
    // Private state
    private var currentPage = 1
    
    public init(
        dataSource: DataSource,
        configuration: PaginationConfiguration = .default
    ) {
        self.dataSource = dataSource
        self.configuration = configuration
        self.loadPage(1)
    }
    
    // MARK: - Public API
    
    public func nextPage() {
        guard state.hasNext else { return }
        loadPage(currentPage + 1)
    }
    
    public func previousPage() {
        guard state.hasPrevious else { return }
        loadPage(currentPage - 1)
    }
    
    public func goToPage(_ page: Int) {
        let validPage = max(1, min(page, state.totalPages))
        guard validPage != currentPage else { return }
        loadPage(validPage)
    }
    
    public func reload() {
        loadPage(currentPage)
    }
    
    // MARK: - Private Methods
    
    private func loadPage(_ page: Int) {
        isLoading = true
        
        // Simulate async loading (replace with real async data fetching)
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            
            let pageItems = dataSource.items(
                for: page,
                pageSize: configuration.pageSize
            )
            
            self.items = pageItems
            self.currentPage = page
            self.updateState()
            self.isLoading = false
        }
    }
    
    private func updateState() {
        let totalPages = Int(ceil(
            Double(dataSource.totalItems) / Double(configuration.pageSize)
        ))
        
        state = PaginationState(
            currentPage: currentPage,
            totalPages: max(1, totalPages),
            pageSize: configuration.pageSize,
            totalItems: dataSource.totalItems
        )
    }
}

// MARK: - 5. Composable View Components

/// Minimal, reusable pagination controls
public struct PaginationControls: View {
    let state: PaginationState
    let configuration: PaginationConfiguration
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onPageSelect: ((Int) -> Void)?
    
    @State private var showPagePicker = false
    
    public var body: some View {
        HStack(spacing: 16) {
            // Previous button
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.medium))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .disabled(!state.hasPrevious)
            .opacity(state.hasPrevious ? 1 : 0.3)
            
            Spacer()
            
            // Page indicator
            if configuration.enablePageJumping, let onPageSelect = onPageSelect {
                Button(action: { showPagePicker = true }) {
                    pageIndicatorContent
                }
                .sheet(isPresented: $showPagePicker) {
                    PagePickerView(
                        currentPage: state.currentPage,
                        totalPages: state.totalPages,
                        onSelect: { page in
                            onPageSelect(page)
                            showPagePicker = false
                        }
                    )
                }
            } else {
                pageIndicatorContent
            }
            
            Spacer()
            
            // Next button
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.medium))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .disabled(!state.hasNext)
            .opacity(state.hasNext ? 1 : 0.3)
        }
        .animation(.easeInOut(duration: 0.2), value: state)
    }
    
    private var pageIndicatorContent: some View {
        HStack(spacing: 4) {
            Text(state.pageRange)
                .font(.subheadline.weight(.semibold))
            if configuration.enablePageJumping {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - 6. Page Picker

struct PagePickerView: View {
    let currentPage: Int
    let totalPages: Int
    let onSelect: (Int) -> Void
    
    @State private var selectedPage: Int
    @Environment(\.dismiss) private var dismiss
    
    init(currentPage: Int, totalPages: Int, onSelect: @escaping (Int) -> Void) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.onSelect = onSelect
        _selectedPage = State(initialValue: currentPage)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("Page", selection: $selectedPage) {
                    ForEach(1...totalPages, id: \.self) { page in
                        Text("Page \(page)").tag(page)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                
                Button {
                    onSelect(selectedPage)
                } label: {
                    Text("Go to Page \(selectedPage)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .navigationTitle("Select Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - 7. Generic Paginated List View

public struct PaginatedList<
    DataSource: PageableDataSource,
    Content: View
>: View {
    
    @StateObject private var viewModel: PaginationViewModel<DataSource>
    private let content: (DataSource.Item) -> Content
    private let emptyView: AnyView?
    private let loadingView: AnyView?
    
    public init(
        dataSource: DataSource,
        configuration: PaginationConfiguration = .default,
        @ViewBuilder content: @escaping (DataSource.Item) -> Content,
        emptyView: AnyView? = nil,
        loadingView: AnyView? = nil
    ) {
        _viewModel = StateObject(wrappedValue: PaginationViewModel(
            dataSource: dataSource,
            configuration: configuration
        ))
        self.content = content
        self.emptyView = emptyView
        self.loadingView = loadingView
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Pagination controls
            PaginationControls(
                state: viewModel.state,
                configuration: viewModel.configuration,
                onPrevious: viewModel.previousPage,
                onNext: viewModel.nextPage,
                onPageSelect: viewModel.goToPage
            )
            
            Divider()
            
            // Content area
            contentArea
        }
    }
    
    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading {
            loadingView ?? AnyView(
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        } else if viewModel.items.isEmpty {
            emptyView ?? AnyView(
                ContentUnavailableView(
                    "No Items",
                    systemImage: "tray",
                    description: Text("There are no items to display")
                )
            )
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.items) { item in
                        content(item)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.items.map(\.id))
            }
        }
    }
}

// MARK: - 8. Grid Variant

public struct PaginatedGrid<
    DataSource: PageableDataSource,
    Content: View,
    Header: View
>: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: PaginationViewModel<DataSource>
    private let columns: [GridItem]
    private let content: (DataSource.Item) -> Content
    private let header: () -> Header
    
    public init(
        dataSource: DataSource,
        columns: [GridItem] = [GridItem(.adaptive(minimum: 150))],
        configuration: PaginationConfiguration = .default,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping (DataSource.Item) -> Content        
    ) {
        _viewModel = StateObject(wrappedValue: PaginationViewModel(
            dataSource: dataSource,
            configuration: configuration
        ))
        self.columns = columns
        self.content = content
        self.header = header
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            
            PaginationControls(
                state: viewModel.state,
                configuration: viewModel.configuration,
                onPrevious: viewModel.previousPage,
                onNext: viewModel.nextPage,
                onPageSelect: viewModel.goToPage
            )
            .padding()
            
            LazyVGrid(columns: columns) {
                header()
            }
            .padding(.vertical, 8)
            .background(content: {
                Color.clear
                    .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme)))
            })
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.items) { item in
                        content(item)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.items.map(\.id))
            }
        }
    }
}


// MARK: Old version

public struct PaginationConfig {
    public let itemsPerPage: Int

    public init(itemsPerPage: Int) {
        self.itemsPerPage = max(1, itemsPerPage)
    }
}

public final class PaginationController<T> {

    private let config: PaginationConfig
    private let allItems: [T]

    private(set) var currentPage: Int = 1

    public init(items: [T], config: PaginationConfig) {
        self.allItems = items
        self.config = config
    }

    public var totalPages: Int {
        Int(ceil(Double(allItems.count) / Double(config.itemsPerPage)))
    }

    public func pageItems() -> [T] {
        let start = (currentPage - 1) * config.itemsPerPage
        let end = min(start + config.itemsPerPage, allItems.count)
        guard start < end else { return [] }
        return Array(allItems[start..<end])
    }

    public func next() {
        guard currentPage < totalPages else { return }
        currentPage += 1
    }

    public func previous() {
        guard currentPage > 1 else { return }
        currentPage -= 1
    }

    public func state() -> PaginationState {
        PaginationState(currentPage: currentPage, totalPages: totalPages, pageSize: config.itemsPerPage, totalItems: allItems.count)
    }
    
    public func goToPage(_ page: Int) {
        guard page >= 1 && page <= totalPages else { return }
        currentPage = page
    }
}

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
    
    public func goToPage(_ page: Int) {
        controller.goToPage(page)
        refresh()
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
    
    @Environment(\.colorScheme) var colorScheme
    
    init(
        listItem: [T], itemsPerPage: Int = 10
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
                onNext: pagingVM.nextPage,
                onPageSelect: pagingVM.goToPage
            )
            .padding(0)
            
            if let grid = grid {
                LazyVGrid(columns: grid.columms) {
                    grid.headerView()
                }
                .padding(.vertical, 8)
                .background(content: {
                    Color.clear
                        .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme)))
                })
                
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

public struct PagingControlsView: View {

    let state: PaginationState
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onPageSelect: ((Int) -> Void)?
        
    @State private var showPagePicker = false
    @State private var selectedPage: Int = 1
    
    public init(
        state: PaginationState,
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onPageSelect: ((Int) -> Void)? = nil
    ) {
        self.state = state
        self.onPrevious = onPrevious
        self.onNext = onNext
        self.onPageSelect = onPageSelect
        self._selectedPage = State(initialValue: state.currentPage)
    }
    
    public var body: some View {
        if !state.hasPrevious && !state.hasNext {
            EmptyView()
        } else {
            HStack {
                Button(action: {
                    withAnimation {
                        onPrevious()
                    }
                    
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .padding(10)
                        .themedBackground(.button())
                }
                .disabled(!state.hasPrevious)
                
                Spacer()

                // Page selector - clickable
                if let onPageSelect = onPageSelect {
                    Button(action: {
                        selectedPage = state.currentPage
                        showPagePicker = true
                    }) {
                        HStack(spacing: 4) {
                            Text("\(state.currentPage) / \(state.totalPages)")
                                .font(.caption.bold())
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .sheet(isPresented: $showPagePicker) {
                        pagePickerSheet
                    }
                } else {
                    // Original text-only display
                    Text("\(state.currentPage) / \(state.totalPages)")
                        .font(.caption.bold())
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        onNext()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .padding(10)
                        .themedBackground(.button())
                }
                .disabled(!state.hasNext)
            }
            .padding(0)
        }
        
    }
    
    private var pagePickerSheet: some View {
        NavigationView {
            VStack {
                Picker("Select Page", selection: $selectedPage) {
                    ForEach(1...state.totalPages, id: \.self) { page in
                        Text("Page \(page)")
                            .tag(page)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                
                Button("Go to Page \(selectedPage)") {
                    withAnimation {
                        onPageSelect?(selectedPage)
                    }
                    showPagePicker = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .navigationTitle("Select Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showPagePicker = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
}
