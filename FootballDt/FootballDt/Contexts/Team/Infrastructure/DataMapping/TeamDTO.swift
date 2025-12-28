//
//  TeamDTO.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//
import Foundation

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
