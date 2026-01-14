//
//  MatchUseCase.swift
//  FootballDt
//
//  Created by Macbook on 14/1/26.
//

protocol UseCase {
    associatedtype Input
    associatedtype Output
    func execute(input: Input) async throws -> Output
}

struct MatchUseCases {
    let repository: MatchRepository
}

struct GetCompetitionMatchesUseCase {
    let repository: MatchRepository
    init(repository: MatchRepository) {
        self.repository = repository
    }
    
    func execute(by competition: String, and season: String?) async throws -> CompetitionMatches {
        try await repository.fetchMatches(competitionId: competition, season: season, filters: nil)
    }
}

struct GetPreviousEncountersUseCase {
    let repository: MatchRepository
    
    func execute(by matchID: Int, and filters: Filters?) async throws -> PreviousEncounters {
        try await repository.fetchPreviousEncounters(matchId: matchID, filters: filters)
    }
}

struct GetMatchesByTeamUseCase {
    let repository: MatchRepository
    
    func execute(by teamID: Int, and filter: Filters?) async throws -> MatchesByTeam {
        try await repository.fetchTeamMatches(teamId: teamID, filters: filter)
    }
}

