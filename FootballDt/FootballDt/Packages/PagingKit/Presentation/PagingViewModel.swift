//
//  PagingViewModel.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

@MainActor
public final class PagingViewModel<T>: ObservableObject {

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

@MainActor
public final class PagingViewModelNew<T: Identifiable>: ObservableObject {

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
