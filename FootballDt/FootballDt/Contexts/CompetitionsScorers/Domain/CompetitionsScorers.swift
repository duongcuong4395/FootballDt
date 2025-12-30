//
//  CompetitionsScorers.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

struct CompetitionsScorers {
    
    
    var count: Int?
    var filters: Filters?
    var competition: Competition?
    var season: Season?
    var scorers: [Scorer]?
}
import SwiftUI

// MARK: - Scorer
struct Scorer: Identifiable {
    var id = UUID()
    var player: Player
    var team: Team
    var playedMatches, goals: Int
    var assists, penalties: Int?
}

// MARK: - Player
struct Player {
    var id: Int
    var name, firstName, lastName, dateOfBirth: String
    var nationality: String
    var section: String
    var position: String?
    var shirtNumber: Int?
    var lastUpdated: String
    
    
    var birthDate: String {
        DateParser.convert(dateOfBirth, to: "dd/MM/yyyy")
    }
}

// MARK: - Filters
struct Filters {
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
