//
//  LeaderboardViewModel.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboardStatus: ModelsStatus<Leaderboard> = .idle
    
    private var getLeaderboardUserCase: GetLeaderboardUserCase
    
    init(getLeaderboardUserCase: GetLeaderboardUserCase) {
        self.getLeaderboardUserCase = getLeaderboardUserCase
    }
    
    func getLeaderboard(by competitionCode: String, and season: String?) async {
        do {
            let data = try await getLeaderboardUserCase.execute(by: competitionCode, and: season)
            DispatchQueue.main.async {
                self.leaderboardStatus = .success(data: data)
            }
        } catch {
            DispatchQueue.main.async {
                self.leaderboardStatus = .failure(error: error.localizedDescription)
            }
        }
    }
    
    func resetAll() {
        self.leaderboardStatus = .idle
    }
}
