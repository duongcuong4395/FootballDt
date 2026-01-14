//
//  TeamRepository.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

protocol TeamRepository {
    func getTeamDetail(by teamID: Int) async throws -> Team
    
}
