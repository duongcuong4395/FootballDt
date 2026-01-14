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
    var status: MatchStatus
    var matchday: Int?
    var stage: String?
    var group: String?
    var lastUpdated: String
    var homeTeam, awayTeam: Team
    var score: Score
    var odds: Odds
    var referees: [Referee]
    
    // Computed properties (no storage)
    var isLive: Bool {
        status == .inPlay || status == .paused
    }
    
    var isFinished: Bool {
        status == .finished
    }
    
    var isUpcoming: Bool {
        status == .scheduled || status == .timed
    }
    
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

enum MatchStatus: String, Codable, Sendable {
    case finished = "FINISHED"
    case postponed = "POSTPONED"
    case scheduled = "SCHEDULED"
    case timed = "TIMED"
    case live = "LIVE"
    case inPlay = "IN_PLAY"
    case paused = "PAUSED"
    case cancelled = "CANCELLED"
    case suspended = "SUSPENDED"
    case awarded = "AWARDED"
      
    var displayName: String {
        switch self {
        case .scheduled, .timed: return "Sắp diễn ra"
        case .inPlay: return "Đang diễn ra"
        case .paused: return "Tạm dừng"
        case .finished: return "Kết thúc"
        case .postponed: return "Hoãn"
        case .cancelled: return "Hủy"
        case .suspended: return "Tạm ngừng"
        case .awarded: return "Đã trao giải"
        case .live: return "Trực tiếp"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled, .timed: return "blue"
        case .inPlay, .paused: return "green"
        case .finished: return "gray"
        case .postponed, .cancelled, .suspended: return "orange"
        case .awarded: return "purple"
        case .live: return "red"
        }
    }
    
    var sortPriority: Int {
        switch self {
        case .inPlay, .paused: return 0
        case .scheduled, .timed: return 1
        case .finished: return 2
        case .postponed, .suspended: return 3
        case .cancelled, .awarded: return 4
        case .live: return 5
        }
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
    
    var displayName: String {
        shortName ?? name ?? ""
    }
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
    var winner: ScoreWinner? // String?
    var duration: String?
    var fullTime, halfTime: TeamScore
    var regularTime, extraTime, penalties: Time?
    
    var totalGoals: Int {
        (fullTime.home ?? 0) + (fullTime.away ?? 0)
    }
    
    var isDecided: Bool {
        winner != nil
    }
}

enum ScoreWinner: String, Codable, Sendable {
    case home = "HOME_TEAM"
    case away = "AWAY_TEAM"
    case draw = "DRAW"
}



// MARK: - Time
struct Time: Codable, Sendable {
    var home, away: Int?
}

struct TeamScore: Equatable, Codable, Sendable {
    let home: Int?
    let away: Int?
    
    var isDraw: Bool {
        guard let h = home, let a = away else { return false }
        return h == a
    }
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
    var type: CompetitionType? //  String?
    var emblem: String?
    var plan: String?
    var currentSeason: Season?
    var numberOfAvailableSeasons: Int?
    var lastUpdated: String?
}

enum CompetitionType: String, Codable, Sendable {
    case cup = "CUP"
    case league = "LEAGUE"
    case playoffs = "PLAYOFFS"
    case superCup = "SUPER_CUP"
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
    
    var displayYears: String {
        let start = yearFrom(startDate)
        let end = yearFrom(endDate)
        return "\(start)-\(end)"
    }
    
    private func yearFrom(_ dateString: String) -> String {
        dateString.prefix(4).description
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

// PreviousEncounters
struct MatchesByHeadToHead {
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
    
    init(numberOfMatches: Int, totalGoals: Int, homeTeam: AggregatesTeam, awayTeam: AggregatesTeam) {
        self.numberOfMatches = numberOfMatches
        self.totalGoals = totalGoals
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }
    
    init() {
        self.numberOfMatches = 0
        self.totalGoals = 0
        self.homeTeam = AggregatesTeam()
        self.awayTeam = AggregatesTeam()
    }
    
    var homeWinPercentage: Double {
        guard numberOfMatches > 0 else { return 0 }
        return Double(homeTeam.wins) / Double(numberOfMatches) * 100
    }
    
    var drawPercentage: Double {
        guard numberOfMatches > 0 else { return 0 }
        return Double(homeTeam.draws) / Double(numberOfMatches) * 100
    }
    
    var awayWinPercentage: Double {
        guard numberOfMatches > 0 else { return 0 }
        return Double(awayTeam.wins) / Double(numberOfMatches) * 100
    }
}

// MARK: - AggregatesAwayTeam
struct AggregatesTeam: Codable {
    var id: Int
    var name: String
    var wins, draws, losses: Int
    
    init(id: Int, name: String, wins: Int, draws: Int, losses: Int) {
        self.id = id
        self.name = name
        self.wins = wins
        self.draws = draws
        self.losses = losses
    }
    
    init() {
        self.id = 0
        self.name = ""
        self.wins = 0
        self.draws = 0
        self.losses = 0
    }
    
    var totalMatches: Int {
        wins + draws + losses
    }
    
    var winPercentage: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(wins) / Double(totalMatches) * 100
    }
}
