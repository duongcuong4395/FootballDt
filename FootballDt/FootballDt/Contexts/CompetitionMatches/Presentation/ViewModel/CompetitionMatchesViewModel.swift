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
        do {
            let data = try await getCompetitionMatchesUserCase.execute(by: competitionID, and: season)
            print("getCompetitionMatches.success: ", data.matches.count)
            DispatchQueue.main.async {
                self.competitionMatchesStatus = .success(data: data)
            }
        } catch {
            print("getCompetitionMatches.error: \(competitionID)", error.localizedDescription)
            DispatchQueue.main.async {
                self.competitionMatchesStatus = .failure(error: error.localizedDescription)
            }
        }
    }
}
