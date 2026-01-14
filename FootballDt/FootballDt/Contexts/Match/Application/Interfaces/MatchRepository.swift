//
//  MatchRepository.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

// MARK: - Repository Protocol

protocol MatchRepository {
    
    func fetchMatchesByCompetition(
        competitionId: String,
        season: String?,
        filters: Filters?
    ) async throws -> MatchesByCompetition
    
    func fetchMatchesByTeam(
        teamId: Int,
        filters: Filters?
    ) async throws -> MatchesByTeam
    
    func fetchMatchesByHeadToHead(
        matchId: Int,
        filters: Filters?
    ) async throws -> MatchesByHeadToHead
}
