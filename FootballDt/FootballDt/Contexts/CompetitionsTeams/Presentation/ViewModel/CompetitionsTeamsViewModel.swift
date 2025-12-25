//
//  CompetitionsTeamsViewModel.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

class CompetitionsTeamsViewModel: ObservableObject {
    @Published var competitionsTeamsStatus: ModelsStatus<CompetitionsTeams> = .idle
    
    private var getCompetitionsTeamsUserCase: GetCompetitionsTeamsUserCase
    
    init(getCompetitionsTeamsUserCase: GetCompetitionsTeamsUserCase) {
        self.getCompetitionsTeamsUserCase = getCompetitionsTeamsUserCase
    }
    
    func getCompetitionsTeams(by competitionCode: String, and season: String?) async {
        DispatchQueue.main.async {
            self.competitionsTeamsStatus = .loading
        }
        do {
            let data = try await getCompetitionsTeamsUserCase.execute(by: competitionCode, and: season)
            DispatchQueue.main.async {
                self.competitionsTeamsStatus = .success(data: data)
            }
        } catch {
            DispatchQueue.main.async {
                self.competitionsTeamsStatus = .failure(error: error.localizedDescription)
            }
        }
    }
    
    func reset() {
        self.competitionsTeamsStatus = .idle
    }
}
