//
//  CompetitionsTeamsRepository.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

protocol CompetitionsTeamsRepository {
    func getCompetitionsTeams(by competitionCode: String, and season: String?) async throws -> CompetitionsTeams
}



