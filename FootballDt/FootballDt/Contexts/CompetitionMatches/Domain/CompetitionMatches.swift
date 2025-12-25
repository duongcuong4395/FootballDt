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
struct Match: Identifiable {
    var id: Int
    var area: Area
    var competition: Competition
    var season: SeasonSimple
    
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
    
    var eventTime: String {
        DateParser.convert(utcDate, to: "dd/MM hh:mm")
    }
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
    var id: Int?
    var startDate, endDate: String?
    var currentMatchday: Int?
    var winner: String?
    
    var years: String {
        return yearStart + " - " + yearEnd
    }
    
    var yearStart: String {
        return DateParser.convert(startDate ?? "", to: "yyyy")
    }
    
    var yearEnd: String {
        return DateParser.convert(endDate ?? "", to: "yyyy")
    }
    
    var fromDateToDate: String {
        return DateParser.convert(startDate ?? "", to: "dd/MM/yyyy") + " - " + DateParser.convert(endDate ?? "", to: "dd/MM/yyyy")
    }
}

// MARK: - ResultSet
struct ResultSet {
    var count: Int
    var first, last: String
    var played: Int
    
    var fromDateToDate: String {
        return DateParser.convert(first, to: "dd/MM/yyyy") + " - " + DateParser.convert(last, to: "dd/MM/yyyy")
    }
}
