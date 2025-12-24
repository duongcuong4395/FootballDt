//
//  CompetitionRepository.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

protocol CompetitionRepository {
    func getAllCompetition() async throws -> [Competition]
}
