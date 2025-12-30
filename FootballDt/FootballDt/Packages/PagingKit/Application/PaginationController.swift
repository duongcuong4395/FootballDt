//
//  PaginationController.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//
import Foundation


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
        PaginationState(currentPage: currentPage, totalPages: totalPages)
    }
    
    public func goToPage(_ page: Int) {
        guard page >= 1 && page <= totalPages else { return }
        currentPage = page
    }
}
