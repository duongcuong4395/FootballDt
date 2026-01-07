//
//  MatchRepository.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

protocol MatchRepository {
    func GetPreviousEncountersUseCase(by matchID: Int, and filters: Filters?) async throws -> PreviousEncounters
}
