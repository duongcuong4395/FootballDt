//
//  GetLeaderboardUserCase.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

struct GetLeaderboardUserCase {
    let repository: LeaderboardRepository
    
    func execute(by competitionCode: String, and season: String?) async throws -> Leaderboard {
        try await repository.getLeaderboard(by: competitionCode, and: season)
    }
}
