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



// MARK: - Odds
struct OddsDTO: Codable {
    var msg: String?
    func toDomain() -> Odds {
        Odds(msg: msg)
    }
}

// MARK: - Referee
struct RefereeDTO: Codable {
    var id: Int?
    var name: String?
    var type: String?
    var nationality: String?
    
    func toDomain() -> Referee {
        Referee(id: id, name: name, type: type, nationality: nationality)
    }
}

// MARK: - Score
struct ScoreDTO: Codable {
    var winner: ScoreWinner? // String?
    var duration: String?
    var fullTime, halfTime: TeamScore
    var regularTime, extraTime, penalties: TimeDTO?
    
    func toDomain() -> Score {
        Score(winner: winner, duration: duration, fullTime: fullTime, halfTime: halfTime
              , regularTime: regularTime?.toDomain()
              , extraTime: extraTime?.toDomain()
              , penalties: penalties?.toDomain())
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
    var startDate, endDate: String?
    var currentMatchday: Int?
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
    var played: Int?
    
    var competitions: String?
    var wins: Int?
    var draws: Int?
    var losses: Int?
     
    func toDomain() -> ResultSet {
        ResultSet(
            count: count
            , first: first
            , last: last
            , played: played
            , competitions: competitions
            , wins: wins
            , draws: draws
            , losses: losses
        )
    }
}
