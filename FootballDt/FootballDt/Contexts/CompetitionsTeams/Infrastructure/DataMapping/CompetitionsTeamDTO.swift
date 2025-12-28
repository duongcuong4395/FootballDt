//
//  CompetitionsTeamDTO.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation

struct GetCompetitionsTeamsAPIResponse: Codable {
    var message: String?
    var errorCode: Int?
    
    var count: Int?
    var filters: FiltersDTO?
    var competition: CompetitionDTO?
    var season: SeasonDTO?
    var teams: [TeamDTO]?
    
    enum CodingKeys: String, CodingKey {
        case filters, count
        case competition, season, teams
    }
    
    func toDomain() -> CompetitionsTeams {
        CompetitionsTeams(count: count, competition: competition?.toDomain(), season: season?.toDomain(), teams: teams?.map{ $0.toDomain() })
    }
}



struct SquadDTO: Codable {
    var id: Int
    var name: String?
    var position: String?
    var dateOfBirth: String?
    var nationality: String?
    
    func toDomain() -> Squad {
        Squad(
            id: id
            , name: name
            , position: position
            , dateOfBirth: dateOfBirth
            , nationality: nationality)
    }
}

