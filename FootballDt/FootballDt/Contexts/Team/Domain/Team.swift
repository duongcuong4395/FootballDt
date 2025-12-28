//
//  Team.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

import Foundation

struct Team: Identifiable, Equatable {
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
