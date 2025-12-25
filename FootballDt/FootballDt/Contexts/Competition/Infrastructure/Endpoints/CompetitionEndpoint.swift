//
//  CompetitionEndpoint.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation
//import Networking
import Alamofire

enum CompetitionEndpoint<T: Decodable> {
    case GetAllCompetition
    case GetLeaderboard(competitionCode: String, season: String?)
    case GetTeams(competitionCode: String, season: String?)
    case GetMatches(competitionID: String, season: String?)
    case GetScores(competitionCode: String, filters: Filters?)
}

extension CompetitionEndpoint: HttpRouter {
    typealias ResponseType = T
    
    var baseURL: String {
        return AppUtility.FootballDtBaseURL
    }
    
    var path: String {
        switch self {
        case .GetAllCompetition:
            "competitions"
        case .GetLeaderboard(competitionCode: let competitionCode, season: _):
            "competitions/\(competitionCode)/standings"
        case .GetTeams(competitionCode: let competitionCode, season: _):
            "competitions/\(competitionCode)/teams"
        case .GetMatches(competitionID: let competitionID, season: _):
            "competitions/\(competitionID)/matches"
        case .GetScores(competitionCode: let competitionCode, filters: let filters):
            "competitions/\(competitionCode)/scorers"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: [String : String]? {
        switch self {
        case .GetAllCompetition: return nil
        case .GetLeaderboard(competitionCode: _)
            , .GetTeams(competitionCode: _, season: _)
            , .GetMatches(competitionID: _, season: _)
            , .GetScores(competitionCode: _, filters: _):
            return ["X-Auth-Token": AppUtility.AuthTK]
        
        }
    }
    
    /*
    var headers: HTTPHeaders? {
        switch self {
        case .GetAllCompetition: return nil
        case .GetLeaderboard(competitionCode: _)
            , .GetTeams(competitionCode: _, season: _)
            , .GetMatches(competitionID: _, season: _):
            return ["X-Auth-Token": AppUtility.AuthTK]
        }
    }
    */
    
    var queryParameters: [String : Any]? {
        switch self {
        case .GetAllCompetition: return nil
        case .GetLeaderboard(competitionCode: _, season: let season):
            guard let season = season else { return nil }
            return ["season": season]
        case .GetTeams(competitionCode: _, season: let season):
            guard let season = season else { return nil }
            return ["season": season]
        case .GetMatches(competitionID: _, season: let season):
            guard let season = season else { return nil }
            return ["season": season]
        case .GetScores(competitionCode: let competitionCode, filters: let filters):
            guard let filters = filters else { return nil }
            
            let params = filters.toParams()
            return params.isEmpty ? nil : params
        }
    }
    
    /*
    var parameters: Parameters? {
        switch self {
        case .GetAllCompetition: return nil
        case .GetLeaderboard(competitionCode: _, season: let season):
            guard let season = season else { return nil }
            return ["season": season]
        case .GetTeams(competitionCode: _, season: let season):
            guard let season = season else { return nil }
            return ["season": season]
        case .GetMatches(competitionID: _, season: let season):
            guard let season = season else { return nil }
            return ["season": season]
        }
    }
    */
    
    var body: Data? {
        nil
    }
}
