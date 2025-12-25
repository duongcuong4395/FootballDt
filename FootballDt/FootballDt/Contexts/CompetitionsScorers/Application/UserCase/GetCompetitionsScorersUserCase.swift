//
//  GetCompetitionsScorersUserCase.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

struct GetCompetitionsScorersUserCase {
    let repository: CompetitionsScorersRepository

    func execute(by competitionCode: String, and filter: Filters?) async throws -> CompetitionsScorers {
        try await repository.getCompetitionsScorers(by: competitionCode, and: filter)
    }
}
