//
//  CompetitionMatches.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation



// MARK: - Match


// MARK: - Odds
struct Odds {
    var msg: String?
}

// MARK: - Referee
struct Referee {
    var id: Int?
    var name: String?
    var type: String?
    var nationality: String?
}

// MARK: - Score
struct Score {
    var winner: String?
    var duration: String?
    var fullTime, halfTime: Time
    var regularTime, extraTime, penalties: Time?
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
    
    var competitions: String?
    var wins: Int?
    var draws: Int?
    var losses: Int?
    
    var fromDateToDate: String {
        return DateParser.convert(first, to: "dd/MM/yyyy") + " - " + DateParser.convert(last, to: "dd/MM/yyyy")
    }
}
