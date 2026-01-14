//
//  MatchEndpoint.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//


import Alamofire
import Networking

enum MatchEndpoint<T: Decodable> {
    case fetchMatchesByCompetition(competitionID: String, season: String?)
    case fetchMatchesByTeam(teamID: Int, filters: Filters?)
    case fetchMatchesByHeadToHead(matchID: Int, filters: Filters?)
}


extension MatchEndpoint: HttpRouter {
    typealias ResponseType = T
    
    var baseURL: String {
        AppUtility.FootballDtBaseURL
    }
    
    var path: String {
        switch self {
        case .fetchMatchesByHeadToHead(let matchID, _):
            "matches/\(matchID)/head2head"
        case .fetchMatchesByTeam(teamID: let teamID, filters: _):
            "teams/\(teamID)/matches"
        case .fetchMatchesByCompetition(competitionID: let competitionID, season: _):
            "competitions/\(competitionID)/matches"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        .get
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .fetchMatchesByHeadToHead(_, let filters):
            guard let filters = filters else { return nil }
            
            let params = filters.toParams()
            return params.isEmpty ? nil : params
        case .fetchMatchesByTeam(teamID: _, filters: let filters):
            guard let filters = filters else { return nil }
            
            let params = filters.toParams()
            return params.isEmpty ? nil : params
        case .fetchMatchesByCompetition(competitionID: _, season: let season):
            guard let season = season else { return nil }
            return ["season": season]
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchMatchesByHeadToHead(_, _)
            , .fetchMatchesByTeam(teamID: _, filters: _)
            , .fetchMatchesByCompetition(competitionID: _, season: _):
            return ["X-Auth-Token": AppUtility.AuthTK]
        }
    }
    
}
