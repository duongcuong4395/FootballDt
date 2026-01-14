//
//  MatchesViewModel.swift
//  FootballDt
//
//  Created by Macbook on 14/1/26.
//

import SwiftUI
import StateManagementKit

// MARK: - Concrete Implementation: CompetitionMatchesViewModel

@MainActor
class MatchesByCompetitionViewModel: BaseMatchesViewModel {
    
    private var getCompetitionMatchesUseCase: GetCompetitionMatchesUseCase
    private var currentCompetitionID: String?
    private var currentSeason: String?
    
    init(getCompetitionMatchesUseCase: GetCompetitionMatchesUseCase) {
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
    
    private var getMatchesByTeamUseCase: GetMatchesByTeamUseCase
    private var currentTeamID: Int?
    private var currentFilters: Filters?
    
    init(getMatchesByTeamUseCase: GetMatchesByTeamUseCase) {
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
    
    let useCase: GetCompetitionMatchesUseCase
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
    let useCase: GetMatchesByTeamUseCase
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

// MARK: - Concrete Implementation: MatchDetailViewModel

class MatchDetailViewModel: SingleStateStore<Match> {}

@MainActor
class PreviousEncountersViewModel: BaseMatchesViewModel {
    let getPreviousEncountersUC: GetPreviousEncountersUseCase
    
    @Published var awayTeam: Team?
    @Published var homeTeam: Team?
    
    init(getPreviousEncountersUC: GetPreviousEncountersUseCase) {
        self.getPreviousEncountersUC = getPreviousEncountersUC
    }
    
    func getPreviousEncounters(by matchID: Int, and filters: Filters?) async {
        
        let dataSource = PreviousEncountersMatchesDataSource(
            useCase: getPreviousEncountersUC,
            matchID: matchID,
            filters: filters
        )
        
        await loadMatchesGrouped(dataSource: dataSource)
    }
}

struct PreviousEncountersMatchesDataSource: MatchesDataSource {
    let useCase: GetPreviousEncountersUseCase
    let matchID: Int
    let filters: Filters?
    
    func fetchMatches() async throws -> Matches {
        let data = try await useCase.execute(by: matchID, and: filters)
        return Matches(
            filters: data.filters
            , resultSet: data.resultSet
            , aggregates: data.aggregates
            , matches: data.matches ?? []
        )
    }
}
