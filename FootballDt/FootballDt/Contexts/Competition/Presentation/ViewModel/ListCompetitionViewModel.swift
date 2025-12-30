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

var availableCompetitionCodes: [String] =  availablecompetitions.map{ $0.code }



class ListCompetitionViewModel: ObservableObject {
    @Published var listCompetitionStatus: ModelsStatus<[Competition]> = .idle
    @Published var competitionSelected: ModelsStatus<Competition> = .idle
    
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
                availableCompetitionCodes.contains($0.code ?? "")
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
    
    func getListCompetition(by competitionCodes: String) -> [Competition] {
        let competitionCodesSplit: [String] = competitionCodes.components(separatedBy: ",")
        guard case .success(let competitions) = listCompetitionStatus else {
            return []
        }
        
        let res = competitions.filter { competitionCodesSplit.contains($0.code ?? "") }
        return res
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
