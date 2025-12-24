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
    
    private var getAllCompetitionUserCase: GetAllCompetitionUserCase
    
    var listCompetition: [Competition] {
        listCompetitionStatus.data ?? []
    }
    
    init(getAllCompetitionUserCase: GetAllCompetitionUserCase) {
        self.getAllCompetitionUserCase = getAllCompetitionUserCase
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
            print("getAllCompetition.error", error.localizedDescription)
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
}
