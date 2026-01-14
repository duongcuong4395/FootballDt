//
//  TeamEndpoint.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

enum TeamEndpoint<T: Decodable> {
    case GetTeamDetail(teamID: Int)
    case Getmatches(TeamID: Int, filter: Filters?)
}

import Alamofire
import Networking

extension TeamEndpoint: HttpRouter {
    
    typealias ResponseType = T
    
    var baseURL: String {
        AppUtility.FootballDtBaseURL
    }
    
    var path: String {
        switch self {
            
        case .GetTeamDetail(teamID: let teamID):
            "teams/\(teamID)"
        case .Getmatches(TeamID: let teamID, filter: _):
            "teams/\(teamID)/matches"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .GetTeamDetail(teamID: _): return ["X-Auth-Token": AppUtility.AuthTK]
        case .Getmatches(TeamID: _, filter: _):
            return ["X-Auth-Token": AppUtility.AuthTK]
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .GetTeamDetail(teamID: _): return nil
        case .Getmatches(TeamID: _, filter: let filters):
            guard let filters = filters else { return nil }
            
            let params = filters.toParams()
            return params.isEmpty ? nil : params
        }
    }
    
}
