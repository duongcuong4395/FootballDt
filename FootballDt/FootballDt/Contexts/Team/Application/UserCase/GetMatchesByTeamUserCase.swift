//
//  GetMatchesByTeamUserCase.swift
//  FootballDt
//
//  Created by Macbook on 29/12/25.
//

struct GetMatchesByTeamUserCase {
    let repository: TeamRepository
    
    func execute(by teamID: Int, and filter: Filters?) async throws -> MatchesByTeam {
        try await repository.getMatches(by: teamID, and: filter)
    }
}
