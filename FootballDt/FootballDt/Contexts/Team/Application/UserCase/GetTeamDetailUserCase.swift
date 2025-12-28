//
//  GetTeamDetailUserCase.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

struct GetTeamDetailUserCase {
    let repository: TeamRepository
    
    func execute(by teamID: Int) async throws -> Team {
        try await repository.getTeamDetail(by: teamID)
    }
}
