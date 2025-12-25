//
//  GetCompetitionsTeamsUserCase.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

struct GetCompetitionsTeamsUserCase {
    let repository: CompetitionsTeamsRepository
    
    func execute(by competitionCode: String, and season: String?) async throws -> CompetitionsTeams {
        try await repository.getCompetitionsTeams(by: competitionCode, and: season)
    }
}
