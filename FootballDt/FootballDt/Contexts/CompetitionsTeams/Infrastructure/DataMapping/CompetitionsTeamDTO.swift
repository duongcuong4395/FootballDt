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
    var season: SeasonSimpleDTO? //SeasonDTO
    var teams: [TeamDTO]?
    
    enum CodingKeys: String, CodingKey {
        case filters, count
        case competition, season, teams
    }
    
    func toDomain() -> CompetitionsTeams {
        CompetitionsTeams(count: count, competition: competition?.toDomain(), season: season?.toDomain(), teams: teams?.map{ $0.toDomain() })
    }
}

// MARK: - Team
struct TeamDTO: Codable {
    var area: AreaDTO?
    var id: Int?
    var name: String?
    var shortName, tla: String?
    var crest: String?
    var address: String?
    var website: String?
    var founded: Int?
    var clubColors, venue: String?
    var runningCompetitions: [CompetitionDTO]?
    var coach: CoachDTO?
    var squad: [SquadDTO]?
    var staff: [String]?
    var lastUpdated: String?
    
    func toDomain() -> Team {
        Team(
            id: id
            , name: name
            , shortName: shortName
            , tla: tla
            , crest: crest
            , area: area?.toDomain()
            , address: address
            , website: website
            , founded: founded
            , clubColors: clubColors
            , venue: venue
            , runningCompetitions: runningCompetitions?.map{ $0.toDomain() }
            , coach: coach?.toDomain()
            , squad: squad?.map { $0.toDomain() }
            , staff: staff
            , lastUpdated: lastUpdated)
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
