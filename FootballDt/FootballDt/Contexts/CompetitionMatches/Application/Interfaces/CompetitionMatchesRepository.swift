//
//  CompetitionMatchesRepository.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

protocol CompetitionMatchesRepository {
    func getCompetitionMatches(by competition: String, and season: String?) async throws -> CompetitionMatches
}
