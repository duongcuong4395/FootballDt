//
//  BaseMatchesViewModel.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//
//  Shared base class for managing matches grouped by competition
//

import SwiftUI
import StateManagementKit

// MARK: - Protocol định nghĩa data source

protocol MatchesDataSource {
    func fetchMatches() async throws -> Matches
}

// MARK: - Base ViewModel quản lý matches với StateStore

@MainActor
class BaseMatchesViewModel: StateStore<Match> {
    
    
    // MARK: - Published Properties
    @Published var resultSet: ResultSet?
    @Published var aggregates: Aggregates?
    @Published var matchesByCompetition: [MatchByCompetition] = []
    @Published var selectedCompetitionIndex: Int = 0
    
    @Published var matchSelected: Match?
    
    // MARK: - Private Properties
    private var allMatches: [Match] = []
    
    // MARK: - Computed Properties
    
    var selectedMatches: [Match] {
        guard matchesByCompetition.indices.contains(selectedCompetitionIndex) else {
            return []
        }
        return matchesByCompetition[selectedCompetitionIndex].matches ?? []
    }
    
    // MARK: - Public Methods
    
    /// Load matches từ data source và group theo competition
    func loadMatchesGrouped(dataSource: MatchesDataSource) async {
        await loadPage(page: 0) { [weak self] page, pageSize in
            guard let self = self else { throw StateError.cancelled }
            
            let data = try await dataSource.fetchMatches()
            
            print("✅ Fetched \(data.matches.count) matches")
            print("📊 Competitions: \(data.matchesByCompetition.count)")
            
            // Update metadata
            await MainActor.run {
                self.resultSet = data.resultSet
                self.aggregates = data.aggregates
                self.matchesByCompetition = data.matchesByCompetition                
                print("🎯 State updated")
            }
            
            return data.matches// ?? []
        }
    }
    
    /// Toggle like cho match
    func toggleLike(matchId: Int) {
        guard let match = model(withId: matchId) else { return }
        
        //Update CoreData/SwiftData
        
        // update UI
        update(matchId, keyPath: \.like, value: !match.like)
    }
    
    
    
    
    func toggleNotify(matchId: Int) {
        guard let match = model(withId: matchId) else { return }
        
        //Update CoreData/SwiftData
        
        // update UI
        update(matchId, keyPath: \.notify, value: !match.notify)
    }
    
    func selectMatch(_ match: Match) {
        self.matchSelected = match
    }
    
    /// Select competition by index
    func selectCompetition(at index: Int) {
        guard matchesByCompetition.indices.contains(index) else { return }
        selectedCompetitionIndex = index
    }
    
    /// Reset về trạng thái ban đầu
    func reset() {
        setState(.idle)
        resultSet = nil
        matchesByCompetition = []
        selectedCompetitionIndex = 0
        matchSelected = nil
    }
}

