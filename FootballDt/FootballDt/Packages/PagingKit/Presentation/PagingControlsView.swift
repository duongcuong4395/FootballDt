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
