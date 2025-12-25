//
//  CompetitionsScorersViewModel.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

import SwiftUI

class CompetitionsScorersViewModel: ObservableObject {
    @Published var competitionsScorersStatus: ModelsStatus<CompetitionsScorers> = .idle
    
    private var getCompetitionsScorersUserCase: GetCompetitionsScorersUserCase
    
    init(getCompetitionsScorersUserCase: GetCompetitionsScorersUserCase) {
        self.getCompetitionsScorersUserCase = getCompetitionsScorersUserCase
    }
    
    func getCompetitionsScorers(by competitionCode: String, and filter: Filters?) async {
        DispatchQueue.main.async {
            self.competitionsScorersStatus = .loading
        }
        do {
            let data = try await getCompetitionsScorersUserCase.execute(by: competitionCode, and: filter)
            DispatchQueue.main.async {
                self.competitionsScorersStatus = .success(data: data)
            }
        } catch {
            DispatchQueue.main.async {
                self.competitionsScorersStatus = .failure(error: error.localizedDescription)
            }
        }
    }
    
    func reset() {
        self.competitionsScorersStatus = .loading
    }
}
