//
//  BaseMatchesViewModel.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//
//  Shared base class for managing matches grouped by competition
//

import SwiftUI

// MARK: - Protocol định nghĩa data source

protocol MatchesDataSource {
    func fetchMatches() async throws -> Matches
}

// MARK: - Base ViewModel quản lý matches với StateStore

@MainActor
class BaseMatchesViewModel: StateStore<Match> {
    
    // MARK: - Published Properties
    @Published var resultSet: ResultSet?
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
            
            // Update metadata
            await MainActor.run {
                self.resultSet = data.resultSet
                self.matchesByCompetition = data.matchesByCompetition
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

// MARK: - Concrete Implementation: CompetitionMatchesViewModel

@MainActor
class MatchesByCompetitionViewModel: BaseMatchesViewModel {
    
    private var getCompetitionMatchesUseCase: GetCompetitionMatchesUserCase
    private var currentCompetitionID: String?
    private var currentSeason: String?
    
    init(getCompetitionMatchesUseCase: GetCompetitionMatchesUserCase) {
        self.getCompetitionMatchesUseCase = getCompetitionMatchesUseCase
        super.init()
    }
    
    func loadMatches(by competitionID: String, and season: String?) async {
        self.currentCompetitionID = competitionID
        self.currentSeason = season
        
        let dataSource = CompetitionMatchesDataSource(
            useCase: getCompetitionMatchesUseCase,
            competitionID: competitionID,
            season: season
        )
        
        await loadMatchesGrouped(dataSource: dataSource)
    }
}

// MARK: - Concrete Implementation: MatchesByTeamViewModel

@MainActor
class MatchesByTeamViewModel: BaseMatchesViewModel {
    
    private var getMatchesByTeamUseCase: GetMatchesByTeamUserCase
    private var currentTeamID: Int?
    private var currentFilters: Filters?
    
    init(getMatchesByTeamUseCase: GetMatchesByTeamUserCase) {
        self.getMatchesByTeamUseCase = getMatchesByTeamUseCase
        super.init()
    }
    
    func loadMatches(by teamID: Int, and filters: Filters?) async {
        self.currentTeamID = teamID
        self.currentFilters = filters
        
        let dataSource = TeamMatchesDataSource(
            useCase: getMatchesByTeamUseCase,
            teamID: teamID,
            filters: filters
        )
        
        await loadMatchesGrouped(dataSource: dataSource)
    }
    
    func resetAll() {
        setState(.idle)
        selectedCompetitionIndex = 0
    }
    
}

// MARK: - Data Source Implementations

struct CompetitionMatchesDataSource: MatchesDataSource {
    let useCase: GetCompetitionMatchesUserCase
    let competitionID: String
    let season: String?
    
    func fetchMatches() async throws -> Matches {
        let data = try await useCase.execute(by: competitionID, and: season)
        return Matches(
            filters: data.filters
            , resultSet: data.resultSet
            , competition: data.competition
            , matches: data.matches
        )
    }
}

struct TeamMatchesDataSource: MatchesDataSource {
    let useCase: GetMatchesByTeamUserCase
    let teamID: Int
    let filters: Filters?
    
    func fetchMatches() async throws -> Matches {
        let data = try await useCase.execute(by: teamID, and: filters)
        return Matches(
            filters: data.filters
            , resultSet: data.resultSet
            , matches: data.matches ?? []
        )
    }
}


class MatchDetailViewModel: SingleStateStore<Match> {}
