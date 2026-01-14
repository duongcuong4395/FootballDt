//
//  MatchRepository.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

// MARK: - Repository Protocol

protocol MatchRepository {
    
    func fetchMatches(
        competitionId: String,
        season: String?,
        filters: Filters?
    ) async throws -> CompetitionMatches
    
    func fetchTeamMatches(
        teamId: Int,
        filters: Filters?
    ) async throws -> MatchesByTeam
    
    func fetchPreviousEncounters(
        matchId: Int,
        filters: Filters?
    ) async throws -> PreviousEncounters
}
