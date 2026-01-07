//
//  Match.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

import Foundation

struct Matches: Sendable {
    var filters: Filters?
    var resultSet: ResultSet?
    var competition: Competition?
    var aggregates: Aggregates?
    var matches: [Match]
    
    
    var matchesByCompetition: [MatchByCompetition] {
        matches.groupedByCompetition()
    }
    
    init(
        filters: Filters? = nil, resultSet: ResultSet? = nil, competition: Competition? = nil
        , aggregates: Aggregates? = nil
        , matches: [Match]) {
            
        self.filters = filters
        self.resultSet = resultSet
        self.competition = competition
        self.aggregates = aggregates
        self.matches = matches
        self.matches = self.matches.sorted { $0.utcDate > $1.utcDate }
    }
}

// MARK: - ResultSet
struct ResultSet: Sendable {
    var count: Int
    var first, last: String
    var played: Int?
    
    var competitions: String?
    var wins: Int?
    var draws: Int?
    var losses: Int?
    
    var fromDateToDate: String {
        return DateParser.convert(first, to: "dd/MM/yyyy") + " - " + DateParser.convert(last, to: "dd/MM/yyyy")
    }
}



// Reult From Get MatchesByTeam API
struct MatchesByTeam: Sendable {
    var filters: Filters?
    var resultSet: ResultSet?
    var matches: [Match]?
    
    var matchesByCompetition: [MatchByCompetition] {
        matches?.groupedByCompetition() ?? []
    }
    
    init(filters: Filters? = nil, resultSet: ResultSet? = nil, matches: [Match]? = nil) {
        self.filters = filters
        self.resultSet = resultSet
        self.matches = matches
        self.matches = self.matches?.sorted { $0.utcDate > $1.utcDate }
    }
}

import SwiftUI
struct MatchByCompetition: Identifiable, Equatable, Sendable {
    static func == (lhs: MatchByCompetition, rhs: MatchByCompetition) -> Bool {
        lhs.competition.id == rhs.competition.id
    }
    
    
    var id = UUID()
    var competition: Competition
    var matches: [Match]?
    
    init(id: UUID = UUID(), competition: Competition, matches: [Match]? = nil) {
        self.id = id
        self.competition = competition
        self.matches = matches
        self.matches = self.matches?.sorted { $0.utcDate > $1.utcDate }
    }
}

struct CompetitionMatches: Sendable {
    var filters: Filters?
    var resultSet: ResultSet?
    var competition: Competition?
    var matches: [Match]
    
    var matchesByCompetition: [MatchByCompetition] {
        matches.groupedByCompetition()
    }
    
    init(filters: Filters? = nil, resultSet: ResultSet? = nil, competition: Competition? = nil, matches: [Match]) {
        self.filters = filters
        self.resultSet = resultSet
        self.competition = competition
        self.matches = matches
        self.matches = self.matches.sorted { $0.utcDate > $1.utcDate }
    }
}

struct Match: Identifiable, Equatable, Sendable {
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Int
    var area: Area
    var competition: Competition
    var season: Season
    
    var utcDate: String
    var status: String
    var matchday: Int?
    var stage: String?
    var group: String?
    var lastUpdated: String
    var homeTeam, awayTeam: Team
    var score: Score
    var odds: Odds
    var referees: [Referee]
    
    var eventTime: String {
        DateParser.convert(utcDate, to: "hh:mm dd/MM/yyyy")
    }
    
    var like: Bool = false
    var notify: Bool = false
    
    // Thêm method để toggle like
    mutating func toggleLike() {
        like.toggle()
    }
}

struct Team: Identifiable, Equatable, Sendable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Int?
    var name, shortName, tla: String?
    var crest: String?
    
    var area: Area?
    
    var address: String?
    var website: String?
    var founded: Int?
    var clubColors, venue: String?
    var runningCompetitions: [Competition]?
    
    var coach: Coach?
    var squad: [Squad]?
    var staff: [String]?
    
    var lastUpdated: String?
}

struct Squad: Sendable {
    var id: Int
    var name: String?
    var position: String?
    var dateOfBirth: String?
    var nationality: String?
}

// MARK: - Coach
struct Coach: Sendable {
    var id: Int?
    var firstName, lastName, name: String?
    var dateOfBirth, nationality: String?
    var contract: Contract?
}

// MARK: - Contract
struct Contract: Sendable {
    var start, until: String?
}


// MARK: - Referee
struct Referee: Sendable {
    var id: Int?
    var name: String?
    var type: String?
    var nationality: String?
}

// MARK: - Odds
struct Odds: Sendable {
    var msg: String?
}

// MARK: - Score
struct Score: Sendable {
    var winner: String?
    var duration: String?
    var fullTime, halfTime: Time
    var regularTime, extraTime, penalties: Time?
}

// MARK: - Time
struct Time: Codable, Sendable {
    var home, away: Int?
}

extension Array where Element == Match {

    func groupedByCompetition() -> [MatchByCompetition] {
        Dictionary(grouping: self, by: { $0.competition.id })
            .compactMap { _, matches in
                guard let competition = matches.first?.competition else {
                    return nil
                }

                return MatchByCompetition(
                    competition: competition,
                    matches: matches
                )
            }
            .sorted { $0.competition.name < $1.competition.name }
    }
    
    
}

struct Competition: Sendable {
    
    var id: Int
    var area: Area?
    var name: String
    var code: String?
    var type: String?
    var emblem: String?
    var plan: String?
    var currentSeason: Season?
    var numberOfAvailableSeasons: Int?
    var lastUpdated: String?
}

struct Area: Sendable {
    var id: Int
    var name: String?
    var countryCode: String?
    var code: String?
    var flag: String?
    var parentAreaID: Int?
    var parentArea: String?
    
    
    init() {
        self.id = 0
        self.name = ""
    }
    
    init(id: Int, name: String?, countryCode: String? = nil, code: String? = nil, flag: String? = nil, parentAreaID: Int? = nil, parentArea: String? = nil) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.code = code
        self.flag = flag
        self.parentAreaID = parentAreaID
        self.parentArea = parentArea
    }
}


struct Season: Codable, Sendable {
    var id: Int
    var startDate, endDate: String
    var currentMatchday: Int?
    var winner: Winner?
    
    var years: String {
        return yearStart + " - " + yearEnd
    }
    
    var yearStart: String {
        return DateParser.convert(startDate, to: "yyyy")
    }
    
    var yearEnd: String {
        return DateParser.convert(endDate, to: "yyyy")
    }
    
    var fromDateToDate: String {
        return DateParser.convert(startDate, to: "dd/MM/yyyy") + " - " + DateParser.convert(endDate, to: "dd/MM/yyyy")
    }
}


// MARK: - Winner
struct Winner: Codable, Sendable {
    var id: Int
    var name: String
    var shortName, tla: String?
    var crest: String?
    var address: String
    var website: String?
    var founded: Int?
    var clubColors, venue: String?
    var lastUpdated: String
}


// MARK: - Filters
struct Filters: Sendable {
    var season: String?
    var limit: Int?
    
    var competitions: String?
    var permission: String?
    
    enum CodingKeys: String, CodingKey {
        case season, limit, competitions, permission
    }
}

protocol QueryParamConvertible {
    func toParams() -> [String: Any]
}

extension Filters: QueryParamConvertible {
    func toParams() -> [String: Any] {
        var params: [String: Any] = [:]

        limit.map { params["limit"] = $0 }
        season.map { params["season"] = $0 }

        return params
    }
}


struct PreviousEncounters {
    var message: String?
    var errorCode: Int?
    
    var filters: Filters?
    var resultSet: ResultSet?
    var aggregates: Aggregates?
    var matches: [Match]?
}


// MARK: - Aggregates
struct Aggregates: Codable {
    var numberOfMatches, totalGoals: Int
    var homeTeam, awayTeam: AggregatesTeam
}

// MARK: - AggregatesAwayTeam
struct AggregatesTeam: Codable {
    var id: Int
    var name: String
    var wins, draws, losses: Int
}
