//
//  CompetitionMatchesAPIService.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Networking

class CompetitionMatchesAPIService: APIExecution, CompetitionMatchesRepository {
    func getCompetitionMatches(by competition: String, and season: String?) async throws -> CompetitionMatches {
        let response: GetCompetitionMatchesAPIResponse = try await sendRequest(for: CompetitionEndpoint<GetCompetitionMatchesAPIResponse>.GetMatches(competitionID: competition, season: season))
        
        return response.toDomain()
    }
    
    
}
