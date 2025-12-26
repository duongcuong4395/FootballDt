//
//  ListCompetitionViewModel.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct CompetitionModel {
    var code: String
    var fullName: String
}


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

var availablecompetitions: [CompetitionModel] = [
    .init(code: "CL", fullName: "UEFA Champions League")
    , .init(code: "BL1", fullName: "Bundesliga")
    , .init(code: "DED", fullName: "Eredivisie")
    , .init(code: "BSA", fullName: "Campeonato Brasileiro Série A")
    , .init(code: "PD", fullName: "Primera Division")
    , .init(code: "FL1", fullName: "Ligue 1")
    , .init(code: "ELC", fullName: "Championship")
    , .init(code: "PPL", fullName: "Primeira Liga")
    , .init(code: "EC", fullName: "European Championship")
    , .init(code: "SA", fullName: "Serie A")
    , .init(code: "PL", fullName: "Premier League")
    //, .init(code: "WC", fullName: "FIFA World Cup")
    
]

class ListCompetitionViewModel: ObservableObject {
    @Published var listCompetitionStatus: ModelsStatus<[Competition]> = .idle
    @Published var competitionSelected: ModelsStatus<Competition> = .idle
    
    
    
    var availableCompetitions: [String] =  availablecompetitions.map{ $0.code }
    // ["CL", "BL1", "DED", "BSA", "PD", "FL1", "ELC", "PPL", "EC", "SA", "PL"]
    
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
