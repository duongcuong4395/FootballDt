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




// MARK: - Coach
struct Coach {
    var id: Int?
    var firstName, lastName, name: String?
    var dateOfBirth, nationality: String?
    var contract: Contract?
}

// MARK: - Contract
struct Contract {
    var start, until: String?
}
