//
//  MatchDTO.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

// MARK: Matches By Head-To-Head API Response

struct MatchesByHeadToHeadAPIResponse: Codable {
    var message: String?
    var errorCode: Int?
    
    var filters: FiltersDTO?
    var resultSet: ResultSetDTO?
    var aggregates: AggregatesDTO?
    var matches: [MatchDTO]?
    
    
    func toDomain() -> MatchesByHeadToHead {
        MatchesByHeadToHead(
            message: message
            , errorCode: errorCode
            , filters: filters?.toDomain()
            , resultSet: resultSet?.toDomain()
            , aggregates: aggregates?.toDomain()
            , matches: matches?.map { $0.toDomain() })
    }
}

// MARK: Matches By Competition API Response

struct MatchesByCompetitionAPIResponse: Codable {
    var message: String?
    var errorCode: Int?
    
    var filters: FiltersDTO?
    var resultSet: ResultSetDTO?
    var competition: CompetitionDTO?
    var matches: [MatchDTO]
    
    func toDomain() -> MatchesByCompetition {
        MatchesByCompetition(resultSet: resultSet?.toDomain(), competition: competition?.toDomain(), matches: matches.map{ $0.toDomain() })
    }
}

// MARK: Matches By Team API Response

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

// MARK: - Match
struct MatchDTO: Codable {
    var area: AreaDTO
    var competition: CompetitionDTO
    var season: SeasonDTO
    var id: Int
    var utcDate: String
    var status:  MatchStatus // String
    var matchday: Int?
    var stage: String?
    var group: String?
    var lastUpdated: String
    var homeTeam, awayTeam: TeamDTO
    var score: ScoreDTO
    var odds: OddsDTO
    var referees: [RefereeDTO]
    
    func toDomain() -> Match {
        Match(
            id: id
            , area: area.toDomain()
            , competition: competition.toDomain()
            , season: season.toDomain()
            
            , utcDate: utcDate
            , status: status, matchday: matchday, stage: stage, group: group
            , lastUpdated: lastUpdated, homeTeam: homeTeam.toDomain(), awayTeam: awayTeam.toDomain()
            , score: score.toDomain(), odds: odds.toDomain(), referees: referees.map { $0.toDomain() })
    }
}


// MARK: - Aggregates
struct AggregatesDTO: Codable {
    var numberOfMatches, totalGoals: Int
    var homeTeam, awayTeam: AggregatesTeamDTO
    
    func toDomain() -> Aggregates {
        Aggregates(numberOfMatches: numberOfMatches, totalGoals: totalGoals, homeTeam: homeTeam.toDomain(), awayTeam: awayTeam.toDomain())
    }
    
}

// MARK: - AggregatesAwayTeam
struct AggregatesTeamDTO: Codable {
    var id: Int
    var name: String
    var wins, draws, losses: Int
    
    func toDomain() -> AggregatesTeam {
        AggregatesTeam(id: id, name: name, wins: wins, draws: draws, losses: losses)
    }
}
