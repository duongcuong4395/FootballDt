//
//  CompetitionsTeamsAPIService.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//
//import Networking

class CompetitionsTeamsAPIService: APIExecution, CompetitionsTeamsRepository {
    func getCompetitionsTeams(by competitionCode: String, and season: String?) async throws -> CompetitionsTeams {
        let response: GetCompetitionsTeamsAPIResponse = try await sendRequest(for: CompetitionEndpoint<GetCompetitionsTeamsAPIResponse>.GetTeams(competitionCode: competitionCode, season: season))
        
        return response.toDomain()
    }
    
    
}
