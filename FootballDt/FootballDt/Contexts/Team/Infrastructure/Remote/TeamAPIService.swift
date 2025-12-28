//
//  TeamAPIService.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//



class TeamAPIService: APIExecution, TeamRepository {
    func getTeamDetail(by teamID: Int) async throws -> Team {
        let response: TeamDTO = try await sendRequest(for: TeamEndpoint<TeamDTO>.GetTeamDetail(teamID: teamID))
        
        return response.toDomain()
    }
}
