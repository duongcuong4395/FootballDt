//
//  CompetitionDTO.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//
import Foundation

struct GetAllCompetitionAPIResponse: Codable {
    var message: String?
    var errorCode: Int?
    
    var count: Int?
    var filters: FiltersDTO?
    var competitions: [CompetitionDTO]?
}

// MARK: - Filters
struct FiltersDTO: Codable {
    var season: String?
    var limit: Int?
    
    var competitions: String?
    var permission: String?
    
    enum CodingKeys: String, CodingKey {
        case season, limit, competitions, permission
    }
    
    func toDomain() -> Filters {
        Filters(season: season, limit: limit
                , competitions: competitions
                , permission: permission
        )
    }
}

// MARK: - Competition
struct CompetitionDTO: Codable {
    var id: Int
    var area: AreaDTO?
    var name: String
    var code: String?
    var type: CompetitionType? //String?
    var emblem: String?
    var plan: String?
    var currentSeason: SeasonDTO?
    var numberOfAvailableSeasons: Int?
    var lastUpdated: String?
    
    func toDomain() -> Competition {
        Competition(
            id: id
            , area: area?.toDomain()
            , name: name
            , code: code
            , type: type
            , emblem: emblem
            , plan: plan
            , currentSeason: currentSeason?.toDomain()
            , numberOfAvailableSeasons: numberOfAvailableSeasons
            , lastUpdated: lastUpdated)
    }
}

// MARK: - Area
struct AreaDTO: Codable {
    var id: Int
    var name: String?
    var countryCode: String?
    var code: String?
    var flag: String?
    var parentAreaID: Int?
    var parentArea: String?

    enum CodingKeys: String, CodingKey {
        case id, name, countryCode, code, flag
        case parentAreaID = "parentAreaId"
        case parentArea
    }
    
    func toDomain() -> Area {
        Area(id: id, name: name, countryCode: countryCode,
             code: code, flag: flag, parentAreaID: parentAreaID, parentArea: parentArea)
    }
}

// MARK: - Season
struct SeasonDTO: Codable {
    var id: Int
    var startDate, endDate: String
    var currentMatchday: Int?
    var winner: WinnerDTO?
    
    func toDomain() -> Season {
        Season(
            id: id
            , startDate: startDate, endDate: endDate
            , currentMatchday: currentMatchday
            , winner: winner?.toDomain())
    }
}

// MARK: - Winner
struct WinnerDTO: Codable {
    var id: Int
    var name: String
    var shortName, tla: String?
    var crest: String?
    var address: String
    var website: String?
    var founded: Int?
    var clubColors, venue: String?
    var lastUpdated: String
    
    func toDomain() -> Winner {
        Winner(
            id: id
            , name: name
            , shortName: shortName
            , tla: tla
            , crest: crest
            , address: address
            , website: website, founded: founded, clubColors: clubColors, venue: venue, lastUpdated: lastUpdated)
    }
}

