//
//  LeaderboardDTO.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation

struct GetLeaderboardAPIResponse: Codable {
    var message: String?
    var errorCode: Int?
    
    var filters: FiltersDTO?
    var area: AreaDTO?
    var competition: CompetitionDTO?
    var season: SeasonDTO?
    var rankings: [RankingsDTO]?
    
    func toDomain() -> Leaderboard {
        Leaderboard(
            area: area?.toDomain()
            , competition: competition?.toDomain()
            , season: season?.toDomain()
            , rankings: rankings?.map { $0.toDomain() })
    }
    
    enum CodingKeys: String, CodingKey {
        case message, errorCode
        
        case filters
        case area, competition, season
        case rankings = "standings"
    }
}

// MARK: - Standing
struct RankingsDTO: Codable {
    var stage, type: String?
    var group: String?
    var rankings: [RankDTO]
    
    func toDomain() -> Rankings {
        Rankings(stage: stage, type: type, group: group, rankings: rankings.map{ $0.toDomain() })
    }
    
    enum CodingKeys: String, CodingKey {
        case stage, type, group
        case rankings = "table"
    }
}

struct RankDTO: Codable {
    var position: Int
    var team: TeamDTO
    var playedGames: Int
    var form: String?
    var won, draw, lost, points: Int
    var goalsFor, goalsAgainst, goalDifference: Int
    
    func toDomain() -> Rank {
        Rank(
            position: position
            , team: team.toDomain()
            , playedGames: playedGames
            , form: form
            , won: won
            , draw: draw
            , lost: lost
            , points: points
            , goalsFor: goalsFor
            , goalsAgainst: goalsAgainst
            , goalDifference: goalDifference)
    }
}





struct CoachDTO: Codable {
    var id: Int?
    var firstName, lastName, name: String?
    var dateOfBirth, nationality: String?
    var contract: ContractDTO?
    
    func toDomain() -> Coach {
        Coach(
            id: id
            , firstName: firstName
            , lastName: lastName
            , name: name, dateOfBirth: dateOfBirth, nationality: nationality, contract: contract?.toDomain())
    }
}

// MARK: - Contract
struct ContractDTO: Codable {
    var start, until: String?
    
    func toDomain() -> Contract {
        Contract(start: start, until: until)
    }
}
