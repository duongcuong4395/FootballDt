//
//  MatchEndpoint.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//


import Alamofire
import Networking

enum MatchEndpoint<T: Decodable> {
    case getPreviousEncounters(matchID: Int, filters: Filters?)
}


extension MatchEndpoint: HttpRouter {
    typealias ResponseType = T
    
    var baseURL: String {
        AppUtility.FootballDtBaseURL
    }
    
    var path: String {
        switch self {
        case .getPreviousEncounters(let matchID, _):
            "matches/\(matchID)/head2head"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        .get
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .getPreviousEncounters(_, let filters):
            guard let filters = filters else { return nil }
            
            let params = filters.toParams()
            return params.isEmpty ? nil : params
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getPreviousEncounters(_, _):
            return ["X-Auth-Token": AppUtility.AuthTK]
        }
    }
    
}
