//
//  PreviousEncountersViewModel.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

import SwiftUI

@MainActor
class PreviousEncountersViewModel: BaseMatchesViewModel {
    let getPreviousEncountersUC: GetPreviousEncountersUseCase
    
    @Published var awayTeam: Team?
    @Published var homeTeam: Team?
    
    init(getPreviousEncountersUC: GetPreviousEncountersUseCase) {
        self.getPreviousEncountersUC = getPreviousEncountersUC
    }
    
    func getPreviousEncounters(by matchID: Int, and filters: Filters?) async {
        
        let dataSource = PreviousEncountersMatchesDataSource(
            useCase: getPreviousEncountersUC,
            matchID: matchID,
            filters: filters
        )
        
        await loadMatchesGrouped(dataSource: dataSource)
    }
}

struct PreviousEncountersMatchesDataSource: MatchesDataSource {
    let useCase: GetPreviousEncountersUseCase
    let matchID: Int
    let filters: Filters?
    
    func fetchMatches() async throws -> Matches {
        let data = try await useCase.execute(by: matchID, and: filters)
        return Matches(
            filters: data.filters
            , resultSet: data.resultSet
            , aggregates: data.aggregates
            , matches: data.matches ?? []
        )
    }
}
