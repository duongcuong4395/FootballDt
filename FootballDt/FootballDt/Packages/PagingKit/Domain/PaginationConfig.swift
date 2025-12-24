//
//  PaginationConfig.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

public struct PaginationConfig {
    public let itemsPerPage: Int

    public init(itemsPerPage: Int) {
        self.itemsPerPage = max(1, itemsPerPage)
    }
}


public struct PaginationState {
    public let currentPage: Int
    public let totalPages: Int

    public var hasNext: Bool {
        currentPage < totalPages
    }

    public var hasPrevious: Bool {
        currentPage > 1
    }
}
