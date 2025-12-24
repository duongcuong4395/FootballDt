//
//  CompetitionMatchesDTO.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

struct GetCompetitionMatchesAPIResponse: Codable {
    var message: String?
    var errorCode: Int?
    
    var filters: FiltersDTO?
    var resultSet: ResultSetDTO?
    var competition: CompetitionDTO?
    var matches: [MatchDTO]
    
    func toDomain() -> CompetitionMatches {
        CompetitionMatches(resultSet: resultSet?.toDomain(), competition: competition?.toDomain(), matches: matches.map{ $0.toDomain() })
    }
}

// MARK: - Match
struct MatchDTO: Codable {
    var area: AreaDTO
    var competition: CompetitionDTO
    var season: SeasonSimpleDTO
    var id: Int
    var utcDate: String
    var status: String
    var matchday: Int
    var stage: String?
    var group: String?
    var lastUpdated: String
    var homeTeam, awayTeam: TeamDTO
    var score: ScoreDTO
    var odds: OddsDTO
    var referees: [RefereeDTO]
    
    func toDomain() -> Match {
        Match(
            area: area.toDomain()
            , competition: competition.toDomain()
            , season: season.toDomain()
            , id: id
            , utcDate: utcDate
            , status: status, matchday: matchday, stage: stage, group: group
            , lastUpdated: lastUpdated, homeTeam: homeTeam.toDomain(), awayTeam: awayTeam.toDomain()
            , score: score.toDomain(), odds: odds.toDomain(), referees: referees.map { $0.toDomain() })
    }
}

// MARK: - Odds
struct OddsDTO: Codable {
    var msg: String?
    func toDomain() -> Odds {
        Odds(msg: msg)
    }
}

// MARK: - Referee
struct RefereeDTO: Codable {
    var id: Int
    var name: String
    var type: String
    var nationality: String
    
    func toDomain() -> Referee {
        Referee(id: id, name: name, type: type, nationality: nationality)
    }
}

// MARK: - Score
struct ScoreDTO: Codable {
    var winner: String?
    var duration: String?
    var fullTime, halfTime: TimeDTO
    
    func toDomain() -> Score {
        Score(winner: winner, duration: duration, fullTime: fullTime.toDomain(), halfTime: halfTime.toDomain())
    }
}

// MARK: - Time
struct TimeDTO: Codable {
    var home, away: Int?
    
    func toDomain() -> Time {
        Time(home: home, away: away)
    }
}

// MARK: - Season
struct SeasonSimpleDTO: Codable {
    var id: Int
    var startDate, endDate: String
    var currentMatchday: Int
    var winner: String?
    
    func toDomain() -> SeasonSimple {
        SeasonSimple(
            id: id
            , startDate: startDate
            , endDate: endDate
            , currentMatchday: currentMatchday
            , winner: winner)
    }
}

// MARK: - ResultSet
struct ResultSetDTO: Codable {
    var count: Int
    var first, last: String
    var played: Int
     
    func toDomain() -> ResultSet {
        ResultSet(
            count: count
            , first: first
            , last: last
            , played: played)
    }
}
