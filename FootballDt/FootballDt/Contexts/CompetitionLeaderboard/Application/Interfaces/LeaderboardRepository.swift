//
//  LeaderboardRepository.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

protocol LeaderboardRepository {
    func getLeaderboard(by competitionCode: String, and season: String?) async throws -> Leaderboard
}
