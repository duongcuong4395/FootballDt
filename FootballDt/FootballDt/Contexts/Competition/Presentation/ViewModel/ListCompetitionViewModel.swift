//
//  ListCompetitionViewModel.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

class ListCompetitionViewModel: ObservableObject {
    @Published var listCompetitionStatus: ModelsStatus<[Competition]> = .idle
    @Published var competitionSelected: ModelsStatus<Competition> = .idle
    
    /*
     | WC | FIFA World Cup
     | CL | UEFA Champions League
     | BL1 | Bundesliga
     | DED | Eredivisie
     | BSA | Campeonato Brasileiro Série A
     | PD | Primera Division
     | FL1 | Ligue 1
     | ELC | Championship
     | PPL | Primeira Liga
     | EC | European Championship
     | SA | Serie A
     | PL | Premier League
     */
    
    var availableCompetitions: [String] = ["WC", "CL", "BL1", "DED", "BSA", "PD", "FL1", "ELC", "PPL", "EC", "SA", "PL"]
    
    // MARK: UserCase
    private var getAllCompetitionUserCase: GetAllCompetitionUserCase
    
    init(getAllCompetitionUserCase: GetAllCompetitionUserCase) {
        self.getAllCompetitionUserCase = getAllCompetitionUserCase
        
        Task {
            await getAllCompetition()
        }
    }
    
    func getAllCompetition() async {
        do {
            let data: [Competition] = try await getAllCompetitionUserCase.execute()
            
            let dt = data.filter {
                availableCompetitions.contains($0.code ?? "")
            }
            
            DispatchQueue.main.async {
                self.listCompetitionStatus = .success(data: dt)
            }
        } catch {
            DispatchQueue.main.async {
                self.listCompetitionStatus = .failure(error: error.localizedDescription)
            }
        }
    }
    
    func setCompetition(_ competition: Competition) {
        self.competitionSelected = .success(data: competition)
    }
    
    func resetAll() {
        self.competitionSelected = .idle
    }
    
    func resetCompetitionSelected() {
        self.competitionSelected = .idle
    }
}
