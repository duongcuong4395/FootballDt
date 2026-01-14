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

struct FetchMatchesByCompetitionUseCase {
    let repository: MatchRepository
    
    func execute(by competition: String, and season: String?) async throws -> CompetitionMatches {
        try await repository.fetchMatchesByCompetition(competitionId: competition, season: season, filters: nil)
    }
}

struct FetchMatchesByHeadToHeadUseCase {
    let repository: MatchRepository
    
    func execute(by matchID: Int, and filters: Filters?) async throws -> MatchesByHeadToHead {
        try await repository.fetchMatchesByHeadToHead(matchId: matchID, filters: filters)
    }
}

struct FetchMatchesByTeamUseCase {
    let repository: MatchRepository
    
    func execute(by teamID: Int, and filter: Filters?) async throws -> MatchesByTeam {
        try await repository.fetchMatchesByTeam(teamId: teamID, filters: filter)
    }
}

