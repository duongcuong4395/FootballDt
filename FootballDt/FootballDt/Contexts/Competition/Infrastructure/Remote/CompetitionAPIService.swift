//
//  CompetitionAPIService.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Networking

class CompetitionAPIService: APIExecution, CompetitionRepository {
    
    func getAllCompetition() async throws -> [Competition] {
        let response: GetAllCompetitionAPIResponse = try await sendRequest(for: CompetitionEndpoint<GetAllCompetitionAPIResponse>.GetAllCompetition)
        
        guard let competitions = response.competitions else { return [] }
        
        return competitions.map { $0.toDomain() }
    }
}


