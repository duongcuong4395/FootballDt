//
//  MatchAPIService.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

import Networking

class MatchAPIService: APIExecution, MatchRepository {
    func GetPreviousEncountersUseCase(by matchID: Int, and filters: Filters?) async throws -> PreviousEncounters {
        let response: PreviousEncountersAPIResponse = try await sendRequest(for: MatchEndpoint<PreviousEncountersAPIResponse>.getPreviousEncounters(matchID: matchID, filters: filters))
        
        return response.toDomain()
    }
    
    
}
