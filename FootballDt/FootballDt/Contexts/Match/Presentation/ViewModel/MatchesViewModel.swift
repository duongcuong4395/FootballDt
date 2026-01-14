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
    
    private var fetchMatchesByCompetitionUseCase: FetchMatchesByCompetitionUseCase
    private var currentCompetitionID: String?
    private var currentSeason: String?
    
    init(fetchMatchesByCompetitionUseCase: FetchMatchesByCompetitionUseCase) {
        self.fetchMatchesByCompetitionUseCase = fetchMatchesByCompetitionUseCase
        super.init()
    }
    
    func loadMatches(by competitionID: String, and season: String?) async {
        self.currentCompetitionID = competitionID
        self.currentSeason = season
        
        let dataSource = CompetitionMatchesDataSource(
            useCase: fetchMatchesByCompetitionUseCase,
            competitionID: competitionID,
            season: season
        )
        
        await loadMatchesGrouped(dataSource: dataSource)
    }
}

// MARK: - Concrete Implementation: MatchesByTeamViewModel

@MainActor
class MatchesByTeamViewModel: BaseMatchesViewModel {
    
    private var fetchMatchesByTeamUseCase: FetchMatchesByTeamUseCase
    private var currentTeamID: Int?
    private var currentFilters: Filters?
    
    init(fetchMatchesByTeamUseCase: FetchMatchesByTeamUseCase) {
        self.fetchMatchesByTeamUseCase = fetchMatchesByTeamUseCase
        super.init()
    }
    
    func loadMatches(by teamID: Int, and filters: Filters?) async {
        self.currentTeamID = teamID
        self.currentFilters = filters
        
        let dataSource = TeamMatchesDataSource(
            useCase: fetchMatchesByTeamUseCase,
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
    
    let useCase: FetchMatchesByCompetitionUseCase
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
    let useCase: FetchMatchesByTeamUseCase
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
class MatchesByHeadToHeadViewModel: BaseMatchesViewModel {
    let fetchMatchesByHeadToHeadUC: FetchMatchesByHeadToHeadUseCase
    
    @Published var awayTeam: Team?
    @Published var homeTeam: Team?
    
    init(fetchMatchesByHeadToHeadUC: FetchMatchesByHeadToHeadUseCase) {
        self.fetchMatchesByHeadToHeadUC = fetchMatchesByHeadToHeadUC
    }
    
    func getMatchesByHeadToHead(by matchID: Int, and filters: Filters?) async {
        let dataSource = MatchesByHeadToHeadDataSource(
            useCase: fetchMatchesByHeadToHeadUC,
            matchID: matchID,
            filters: filters
        )
        
        await loadMatchesGrouped(dataSource: dataSource)
    }
}

struct MatchesByHeadToHeadDataSource: MatchesDataSource {
    let useCase: FetchMatchesByHeadToHeadUseCase
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
