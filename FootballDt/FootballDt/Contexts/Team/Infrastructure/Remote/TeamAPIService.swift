//
//  TeamAPIService.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//



class TeamAPIService: APIExecution, TeamRepository {
    func getMatches(by teamID: Int, and filters: Filters?) async throws -> MatchesByTeam {
        let response: GetMatchesByTeamAPIResponse = try await sendRequest(for: TeamEndpoint<GetMatchesByTeamAPIResponse>.Getmatches(TeamID: teamID, filter: filters))
        
        return response.toDomain()
    }
    
    func getTeamDetail(by teamID: Int) async throws -> Team {
        let response: TeamDTO = try await sendRequest(for: TeamEndpoint<TeamDTO>.GetTeamDetail(teamID: teamID))
        
        return response.toDomain()
    }
}
