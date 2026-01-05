//
//  CompetitionMatchesViewModel.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

@MainActor
class CompetitionMatchesViewModel: StateStore<Match> {
    
    private var getCompetitionMatchesUserCase: GetCompetitionMatchesUserCase
    
    init(getCompetitionMatchesUserCase: GetCompetitionMatchesUserCase) {
        self.getCompetitionMatchesUserCase = getCompetitionMatchesUserCase
    }
    
    func loadMatches(by competitionID: String, and season: String?) async {
        await loadPage(page: 0) { [weak self] page, pagesize in
            guard let self = self else { throw StateError.cancelled }
            let data = try await getCompetitionMatchesUserCase.execute(by: competitionID, and: season)
            
            return data.matches
        }
    }
    
    func toggleLike(matchId: Int) {
        guard let match = model(withId: matchId) else { return }
        // Update UI
        update(matchId, keyPath: \.like, value: !match.like)
    }
    
    func reset() {
        setState(.idle)
    }
}
