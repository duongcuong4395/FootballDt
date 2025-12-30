//
//  MatchesByTeam.swift
//  FootballDt
//
//  Created by Macbook on 29/12/25.
//

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


struct ListMatchByCompetition {
    var listMatch: [MatchByCompetition]
}

import SwiftUI
struct MatchByCompetition: Identifiable {
    
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
