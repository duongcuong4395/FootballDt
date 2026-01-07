//
//  GetPreviousEncountersUseCase.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

struct GetPreviousEncountersUseCase {
    let repository: MatchRepository
    
    func execute(by matchID: Int, and filters: Filters?) async throws -> PreviousEncounters {
        try await repository.GetPreviousEncountersUseCase(by: matchID, and: filters)
    }
}
