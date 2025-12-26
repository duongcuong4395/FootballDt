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

                Text("\(state.currentPage) / \(state.totalPages)")
                    .font(.caption.bold())

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
}
