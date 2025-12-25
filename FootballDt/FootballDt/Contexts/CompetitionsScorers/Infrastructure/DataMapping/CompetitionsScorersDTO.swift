//
//  CompetitionsScorersDTO.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

import Foundation

struct GetCompetitionsScorersAPIResponse: Codable {
    var message: String?
    var errorCode: Int?
    
    var count: Int?
    var filters: FiltersDTO?
    var competition: CompetitionDTO?
    var season: SeasonDTO?
    var scorers: [ScorerDTO]?
    
    func toDomain() -> CompetitionsScorers {
        CompetitionsScorers(
            count: count
            , filters: filters?.toDomain()
            , competition: competition?.toDomain()
            , season: season?.toDomain()
            , scorers: scorers?.map { $0.toDomain() })
    }
}

// MARK: - Scorer
struct ScorerDTO: Codable {
    var player: PlayerDTO
    var team: TeamDTO
    var playedMatches, goals: Int
    var assists, penalties: Int?
    
    func toDomain() -> Scorer {
        Scorer(
            player: player.toDomain()
            , team: team.toDomain()
            , playedMatches: playedMatches
            , goals: goals
            , assists: assists
            , penalties: penalties)
    }
}

// MARK: - Player
struct PlayerDTO: Codable {
    var id: Int
    var name, firstName, lastName, dateOfBirth: String
    var nationality: String
    var section: String
    var position: String?
    var shirtNumber: Int?
    var lastUpdated: String
    
    func toDomain() -> Player {
        Player(
            id: id
            , name: name
            , firstName: firstName
            , lastName: lastName
            , dateOfBirth: dateOfBirth
            , nationality: nationality
            , section: section
            , position: position
            , shirtNumber: shirtNumber
            , lastUpdated: lastUpdated)
    }
}
