//
//  MatchesByTeamDTO.swift
//  FootballDt
//
//  Created by Macbook on 29/12/25.
//

struct MatchesByTeamAPIResponse: Codable {
    
    var message: String?
    var errorCode: Int?
    
    var filters: FiltersDTO?
    var resultSet: ResultSetDTO?
    var matches: [MatchDTO]?
    
    
    
    func toDomain() -> MatchesByTeam {
        MatchesByTeam(filters: filters?.toDomain(), resultSet: resultSet?.toDomain(), matches: matches?.map{ $0.toDomain() })
    }
}
