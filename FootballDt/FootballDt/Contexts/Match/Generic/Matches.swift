//
//  Matches.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

struct Matches {
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
