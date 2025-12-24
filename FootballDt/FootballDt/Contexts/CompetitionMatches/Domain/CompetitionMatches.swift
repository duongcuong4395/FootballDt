//
//  CompetitionMatches.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation

struct CompetitionMatches {
    var resultSet: ResultSet?
    var competition: Competition?
    var matches: [Match]
}

// MARK: - Match
struct Match {
    var area: Area
    var competition: Competition
    var season: SeasonSimple
    var id: Int
    var utcDate: String
    var status: String
    var matchday: Int
    var stage: String?
    var group: String?
    var lastUpdated: String
    var homeTeam, awayTeam: Team
    var score: Score
    var odds: Odds
    var referees: [Referee]
}

// MARK: - Odds
struct Odds {
    var msg: String?
}

// MARK: - Referee
struct Referee {
    var id: Int
    var name: String
    var type: String
    var nationality: String
}

// MARK: - Score
struct Score {
    var winner: String?
    var duration: String?
    var fullTime, halfTime: Time
}

// MARK: - Time
struct Time: Codable {
    var home, away: Int?
}

// MARK: - Season
struct SeasonSimple {
    var id: Int
    var startDate, endDate: String
    var currentMatchday: Int
    var winner: String?
}

// MARK: - ResultSet
struct ResultSet {
    var count: Int
    var first, last: String
    var played: Int
}
