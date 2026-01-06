//
//  TeamViewModel.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

import SwiftUI

class TeamViewModel: ObservableObject {
    @Published var teamStatus: ModelsStatus<Team> = .idle
    
    private var getTeamDetailUserCase: GetTeamDetailUserCase
    
    init(getTeamDetailUserCase: GetTeamDetailUserCase) {
        self.getTeamDetailUserCase = getTeamDetailUserCase
    }
    
    func getTeamDetail(by teamID: Int) async {
        do {
            let team = try await getTeamDetailUserCase.execute(by: teamID)
            DispatchQueue.main.async {
                self.teamStatus = .success(data: team)
            }
        } catch {
            DispatchQueue.main.async {
                self.teamStatus = .failure(error: error.localizedDescription)
            }
        }
    }
    
    func setTeam(by team: Team) {
        teamStatus = .success(data: team)
    }
    
    func resetAll() {
        teamStatus = .idle
    }
}






@MainActor
class MatchesGeneralViewModel: StateStore<Match> {
    
    func setUpMatches(by matches: [Match]) {
        setState(.success(matches))
    }
    
    func toggleLike(matchId: Int) {
        guard let match = model(withId: matchId) else { return }
        // Update UI
        update(matchId, keyPath: \.like, value: !match.like)
    }
}
