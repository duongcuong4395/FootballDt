//
//  PagingControlsView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//
import SwiftUI

public struct PagingControlsView: View {

    let state: PaginationState
    let onPrevious: () -> Void
    let onNext: () -> Void

    public var body: some View {
        HStack {
            Button("Previous", action: onPrevious)
                .disabled(!state.hasPrevious)

            Spacer()

            Text("\(state.currentPage) / \(state.totalPages)")

            Spacer()

            Button("Next", action: onNext)
                .disabled(!state.hasNext)
        }
        .padding()
    }
}
