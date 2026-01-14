//
//  MatchAPIService.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

import Networking

class MatchAPIService: APIExecution, MatchRepository {
    func fetchMatchesByCompetition(competitionId: String, season: String?, filters: Filters?) async throws -> CompetitionMatches {
        let response: MatchesByCompetitionAPIResponse = try await sendRequest(for: MatchEndpoint<MatchesByCompetitionAPIResponse>.fetchMatchesByCompetition(competitionID: competitionId, season: season))
        
        return response.toDomain()
    }
    
    func fetchMatchesByTeam(teamId: Int, filters: Filters?) async throws -> MatchesByTeam {
        let response: MatchesByTeamAPIResponse = try await sendRequest(for: MatchEndpoint<MatchesByTeamAPIResponse>.fetchMatchesByTeam(teamID: teamId, filters: filters))
        
        return response.toDomain()
    }
    
    func fetchMatchesByHeadToHead(matchId: Int, filters: Filters?) async throws -> MatchesByHeadToHead {
        let response: MatchesByHeadToHeadAPIResponse = try await sendRequest(for: MatchEndpoint<MatchesByHeadToHeadAPIResponse>.fetchMatchesByHeadToHead(matchID: matchId, filters: filters))
        
        return response.toDomain()
    }
}
