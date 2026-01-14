//
//  TeamEndpoint.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

enum TeamEndpoint<T: Decodable> {
    case GetTeamDetail(teamID: Int)
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
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .GetTeamDetail(teamID: _): return ["X-Auth-Token": AppUtility.AuthTK]
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .GetTeamDetail(teamID: _): return nil
        }
    }
    
}
