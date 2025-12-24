//
//  Leaderboard.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation

struct Rankings {
    var stage, type: String
    var group: String?
    var rankings: [Rank]
}

// MARK: - Table
struct Rank {
    var position: Int
    var team: Team
    var playedGames: Int
    var form: String?
    var won, draw, lost, points: Int
    var goalsFor, goalsAgainst, goalDifference: Int
}

struct Leaderboard {
    var area: Area?
    var competition: Competition?
    var season: Season?
    var rankings: [Rankings]?
}


struct Team {
    var id: Int
    var name, shortName, tla: String?
    var crest: String?
    
    var area: Area?
    
    var address: String?
    var website: String?
    var founded: Int?
    var clubColors, venue: String?
    var runningCompetitions: [Competition]?
    var coach: Coach?
    var squad, staff: [String]?
    var lastUpdated: String?
}

// MARK: - Coach
struct Coach {
    var id, firstName, lastName, name: String?
    var dateOfBirth, nationality: String?
    var contract: Contract
}

// MARK: - Contract
struct Contract {
    var start, until: String?
}
