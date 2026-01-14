//
//  CompetitionsScorersAPIService.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//
import Networking

class CompetitionsScorersAPIService: APIExecution, CompetitionsScorersRepository {
    func getCompetitionsScorers(by competitionCode: String, and filter: Filters?) async throws -> CompetitionsScorers {
        let response: GetCompetitionsScorersAPIResponse = try await sendRequest(for: CompetitionEndpoint<GetCompetitionsScorersAPIResponse>.GetScores(competitionCode: competitionCode, filters: filter))
        
        return response.toDomain()
    }
    
    
}
