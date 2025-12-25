//
//  CompetitionsScorersRepository.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

protocol CompetitionsScorersRepository {
    func getCompetitionsScorers(by competitionCode: String, and filter: Filters?) async throws -> CompetitionsScorers
}
