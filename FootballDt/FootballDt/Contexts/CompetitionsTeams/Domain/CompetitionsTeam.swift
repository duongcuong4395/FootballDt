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
    var season: SeasonSimple?
    var teams: [Team]?
}

struct Team: Identifiable {
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

struct Squad {
    var id: Int
    var name: String?
    var position: String?
    var dateOfBirth: String?
    var nationality: String?
}
