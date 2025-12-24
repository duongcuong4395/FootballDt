//
//  GetCompetitionMatchesUserCase.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

struct GetCompetitionMatchesUserCase {
    let repository: CompetitionMatchesRepository
    
    func execute(by competition: String, and season: String?) async throws -> CompetitionMatches {
        try await repository.getCompetitionMatches(by: competition, and: season)
    }
}
