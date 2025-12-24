//
//  GetAllCompetitionUserCase.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

struct GetAllCompetitionUserCase {
    let repository: CompetitionRepository
    
    func execute() async throws -> [Competition] {
        try await repository.getAllCompetition()
    }
}
