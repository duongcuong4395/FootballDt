//
//  CompetitionsTeam.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation

struct CompetitionsTeams {
    var count: Int?
    var competition: Competition?
    var season: Season?
    var teams: [Team]?
}



struct Squad {
    var id: Int
    var name: String?
    var position: String?
    var dateOfBirth: String?
    var nationality: String?
}
