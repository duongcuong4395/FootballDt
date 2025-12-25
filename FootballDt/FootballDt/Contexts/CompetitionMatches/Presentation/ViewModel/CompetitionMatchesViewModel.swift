//
//  CompetitionMatchesViewModel.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

class CompetitionMatchesViewModel: ObservableObject {
    @Published var competitionMatchesStatus: ModelsStatus<CompetitionMatches> = .idle
    
    private var getCompetitionMatchesUserCase: GetCompetitionMatchesUserCase
    
    init(getCompetitionMatchesUserCase: GetCompetitionMatchesUserCase) {
        self.getCompetitionMatchesUserCase = getCompetitionMatchesUserCase
    }
    
    func getCompetitionMatches(by competitionID: String, and season: String?) async {
        DispatchQueue.main.async {
            self.competitionMatchesStatus = .loading
        }
        do {
            let data = try await getCompetitionMatchesUserCase.execute(by: competitionID, and: season)
            DispatchQueue.main.async {
                self.competitionMatchesStatus = .success(data: data)
            }
        } catch {
            DispatchQueue.main.async {
                self.competitionMatchesStatus = .failure(error: error.localizedDescription)
            }
        }
    }
    
    func reset() {
        self.competitionMatchesStatus = .idle
    }
}
