//
//  MatchAPIService.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

import Networking

class MatchAPIService: APIExecution, MatchRepository {
    func fetchMatches(competitionId: String, season: String?, filters: Filters?) async throws -> CompetitionMatches {
        let response: GetCompetitionMatchesAPIResponse = try await sendRequest(for: CompetitionEndpoint<GetCompetitionMatchesAPIResponse>.GetMatches(competitionID: competitionId, season: season))
        
        return response.toDomain()
    }
    
    func fetchTeamMatches(teamId: Int, filters: Filters?) async throws -> MatchesByTeam {
        let response: GetMatchesByTeamAPIResponse = try await sendRequest(for: TeamEndpoint<GetMatchesByTeamAPIResponse>.Getmatches(TeamID: teamId, filter: filters))
        
        return response.toDomain()
    }
    
    func fetchPreviousEncounters(matchId: Int, filters: Filters?) async throws -> PreviousEncounters {
        let response: PreviousEncountersAPIResponse = try await sendRequest(for: MatchEndpoint<PreviousEncountersAPIResponse>.getPreviousEncounters(matchID: matchId, filters: filters))
        
        return response.toDomain()
    }
}
