//
//  Match.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

import Foundation

// Reult From Get MatchesByTeam API
struct MatchesByTeam {
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
struct MatchByCompetition: Identifiable, Equatable {
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

struct CompetitionMatches {
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

struct Match: Identifiable, Equatable {
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
