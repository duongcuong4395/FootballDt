//
//  LeaderboardAPIService.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Networking

class LeaderboardAPIService: APIExecution, LeaderboardRepository {
    func getLeaderboard(by competitionCode: String, and season: String?) async throws -> Leaderboard {
        let response: GetLeaderboardAPIResponse = try await sendRequest(for: CompetitionEndpoint<GetLeaderboardAPIResponse>.GetLeaderboard(competitionCode: competitionCode, season: season))
        
        //guard let rankings = response.rankings else { return Leaderboard() }
        
        return response.toDomain()
    }
    
    
}
